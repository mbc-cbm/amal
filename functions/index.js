'use strict';

const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue, Timestamp } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();
const db = getFirestore();

// ── Valid earn sources ─────────────────────────────────────────────────────
const VALID_SOURCES = new Set([
  'prayer',
  'fast',
  'tasbeeh',
  'soul_stack',
  'ywtl',
  'amal',
  'iap_purchase',
]);

// ── updateNoorWallet ───────────────────────────────────────────────────────
/**
 * Awards Noor Coins for a completed Islamic action.
 *
 * Request payload:
 *   uid         {string}  — Firebase Auth UID of the earning user
 *   amount      {number}  — positive integer, Noor Coins to award
 *   source      {string}  — canonical source key (see VALID_SOURCES)
 *
 * Additional fields for source === 'prayer' (enables idempotent prayer logging):
 *   prayerName  {string}  — 'fajr' | 'dhuhr' | 'asr' | 'maghrib' | 'isha'
 *   date        {string}  — YYYY-MM-DD of the prayer day (Fajr-based, not midnight)
 *
 * Atomically (in one Firestore transaction):
 *   1. For 'prayer': checks users/{uid}/prayerLog/{date}.{prayerName}.completed.
 *      If already true, returns { alreadyLogged: true } without awarding coins.
 *   2. Increments noorCoinBalance AND totalNoorCoinsEarned.
 *   3. Appends a wallet_transactions entry.
 *   4. For 'prayer': writes the prayerLog entry.
 *
 * This function uses the Admin SDK and therefore bypasses Firestore security
 * rules. The client-side Firestore rules block direct writes to these fields.
 */
exports.updateNoorWallet = onCall(async (request) => {
  // Require authenticated caller.
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Authentication required.');
  }

  const { uid, amount, source, prayerName, date } = request.data;

  // ── Validate ──────────────────────────────────────────────────────────────
  if (typeof uid !== 'string' || uid.trim() === '') {
    throw new HttpsError('invalid-argument', 'uid must be a non-empty string.');
  }
  if (request.auth.uid !== uid) {
    throw new HttpsError('permission-denied', 'Cannot award coins to another user.');
  }
  if (!Number.isInteger(amount) || amount <= 0) {
    throw new HttpsError('invalid-argument', 'amount must be a positive integer.');
  }
  if (!VALID_SOURCES.has(source)) {
    throw new HttpsError(
      'invalid-argument',
      `source must be one of: ${[...VALID_SOURCES].join(', ')}.`
    );
  }

  const VALID_PRAYERS = new Set(['fajr', 'dhuhr', 'asr', 'maghrib', 'isha']);
  if (source === 'prayer') {
    if (!VALID_PRAYERS.has(prayerName)) {
      throw new HttpsError('invalid-argument', 'prayerName must be a valid prayer name.');
    }
    if (typeof date !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(date)) {
      throw new HttpsError('invalid-argument', 'date must be a YYYY-MM-DD string.');
    }
  }

  // ── Firestore transaction ──────────────────────────────────────────────────
  const userRef = db.collection('users').doc(uid);
  const txRef = userRef.collection('wallet_transactions').doc();
  const prayerLogRef = source === 'prayer'
    ? userRef.collection('prayerLog').doc(date)
    : null;

  const result = await db.runTransaction(async (tx) => {
    const reads = [tx.get(userRef)];
    if (prayerLogRef) reads.push(tx.get(prayerLogRef));
    const [userSnap, logSnap] = await Promise.all(reads);

    if (!userSnap.exists) {
      throw new HttpsError('not-found', 'User document not found.');
    }

    // ── Idempotency check for prayer ────────────────────────────────────────
    if (prayerLogRef && logSnap && logSnap.exists) {
      const logData = logSnap.data() ?? {};
      if (logData[prayerName]?.completed === true) {
        return { alreadyLogged: true };
      }
    }

    const currentBalance = userSnap.get('noorCoinBalance') ?? 0;
    const updatedBalance = currentBalance + amount;

    // Update wallet balance fields.
    tx.update(userRef, {
      noorCoinBalance: FieldValue.increment(amount),
      totalNoorCoinsEarned: FieldValue.increment(amount),
    });

    // Append an immutable wallet transaction record.
    tx.set(txRef, {
      type: 'earn',
      amount,
      source,
      ...(source === 'prayer' ? { prayerName, date } : {}),
      balanceAfter: updatedBalance,
      createdAt: FieldValue.serverTimestamp(),
    });

    // Write the prayerLog entry (merge so other prayers on the same day persist).
    if (prayerLogRef) {
      tx.set(prayerLogRef, {
        [prayerName]: {
          completed: true,
          completedAt: FieldValue.serverTimestamp(),
          coinsAwarded: amount,
        },
      }, { merge: true });
    }

    return { alreadyLogged: false, newBalance: updatedBalance };
  });

  if (result.alreadyLogged) {
    return { success: true, alreadyLogged: true };
  }
  return { success: true, alreadyLogged: false, newBalance: result.newBalance };
});

// ── spendNoorCoins ─────────────────────────────────────────────────────────
/**
 * Spends Noor Coins to unlock a garden asset.
 *
 * Request payload:
 *   uid     {string}  — Firebase Auth UID of the spending user
 *   amount  {number}  — positive integer, Noor Coins to deduct
 *   assetId {string}  — ID of the asset being purchased
 *
 * Atomically:
 *   1. Validates the user has sufficient noorCoinBalance.
 *   2. Decrements noorCoinBalance ONLY (totalNoorCoinsEarned never decreases).
 *   3. Writes the full asset schema to users/{uid}/gardenAssets/{assetId}.
 *   4. Appends a wallet_transactions spend record.
 *
 * Throws 'failed-precondition' if the balance is insufficient.
 */
exports.spendNoorCoins = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Authentication required.');
  }

  const { uid, amount, assetId } = request.data;

  // ── Validate ──────────────────────────────────────────────────────────────
  if (typeof uid !== 'string' || uid.trim() === '') {
    throw new HttpsError('invalid-argument', 'uid must be a non-empty string.');
  }
  if (request.auth.uid !== uid) {
    throw new HttpsError('permission-denied', 'Cannot spend coins for another user.');
  }
  if (!Number.isInteger(amount) || amount <= 0) {
    throw new HttpsError('invalid-argument', 'amount must be a positive integer.');
  }
  if (typeof assetId !== 'string' || assetId.trim() === '') {
    throw new HttpsError('invalid-argument', 'assetId must be a non-empty string.');
  }

  // ── Fetch asset template for tier info ─────────────────────────────────────
  const templateSnap = await db.collection('assetTemplates').doc(assetId).get();
  const tier = templateSnap.exists ? (templateSnap.data().tier || 'common') : 'common';

  // ── Firestore transaction ──────────────────────────────────────────────────
  const userRef = db.collection('users').doc(uid);
  const assetRef = userRef.collection('gardenAssets').doc(assetId);
  const txRef = userRef.collection('wallet_transactions').doc();

  const newBalance = await db.runTransaction(async (tx) => {
    const [userSnap, assetSnap] = await Promise.all([
      tx.get(userRef),
      tx.get(assetRef),
    ]);

    if (!userSnap.exists) {
      throw new HttpsError('not-found', 'User document not found.');
    }
    if (assetSnap.exists) {
      throw new HttpsError('already-exists', 'Asset already owned.');
    }

    const currentBalance = userSnap.get('noorCoinBalance') ?? 0;
    if (currentBalance < amount) {
      throw new HttpsError(
        'failed-precondition',
        'Insufficient Noor Coins.'
      );
    }

    const updatedBalance = currentBalance - amount;

    // Deduct from spendable balance only — lifetime total never decreases.
    tx.update(userRef, {
      noorCoinBalance: FieldValue.increment(-amount),
    });

    // Write full asset schema.
    tx.set(assetRef, {
      assetTemplateId: assetId,
      slotId: '',
      positionX: 0,
      positionY: 0,
      tier,
      isDiscovered: false,
      currentHealthState: 1,
      purchasedAt: FieldValue.serverTimestamp(),
      purchaseType: 'nc',
      originalNcPrice: amount,
      isPlaced: false,
      giftedFromUserId: null,
      giftedToUserId: null,
    });

    // Append spend transaction record.
    tx.set(txRef, {
      type: 'spend',
      amount,
      source: 'garden_asset',
      assetId,
      balanceAfter: updatedBalance,
      createdAt: FieldValue.serverTimestamp(),
    });

    return updatedBalance;
  });

  return { success: true, newBalance };
});

// ── purchaseAssetWithNc ──────────────────────────────────────────────────
/**
 * Purchases a garden asset using Noor Coins.
 * Reads ncPrice from assetTemplates, validates level gating and
 * scholar review, then runs atomic transaction.
 *
 * Request payload:
 *   uid     {string}  — Firebase Auth UID
 *   assetId {string}  — assetTemplates document ID
 *
 * Returns { success, newBalance, isSacredCentre }
 */
exports.purchaseAssetWithNc = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Authentication required.');
  }

  const { uid, assetId } = request.data;

  if (typeof uid !== 'string' || uid.trim() === '') {
    throw new HttpsError('invalid-argument', 'uid must be a non-empty string.');
  }
  if (request.auth.uid !== uid) {
    throw new HttpsError('permission-denied', 'Cannot purchase for another user.');
  }
  if (typeof assetId !== 'string' || assetId.trim() === '') {
    throw new HttpsError('invalid-argument', 'assetId must be a non-empty string.');
  }

  // ── Read asset template ────────────────────────────────────────────────────
  const templateSnap = await db.collection('assetTemplates').doc(assetId).get();
  if (!templateSnap.exists) {
    throw new HttpsError('not-found', 'Asset template not found.');
  }

  const template = templateSnap.data();
  if (template.isScholarReviewed !== true) {
    throw new HttpsError('permission-denied', 'Asset has not been scholar-reviewed.');
  }

  const ncPrice = template.ncPrice || 0;
  const tier = template.tier || 'common';
  const isLevelGated = template.isLevelGated === true;
  const requiredLevel = template.requiredLevel || 1;

  // ── Firestore transaction ──────────────────────────────────────────────────
  const userRef = db.collection('users').doc(uid);
  const assetRef = userRef.collection('gardenAssets').doc(assetId);
  const gardenStateRef = userRef.collection('gardenState').doc('state');
  const txRef = userRef.collection('wallet_transactions').doc();

  const result = await db.runTransaction(async (tx) => {
    const [userSnap, assetSnap, gardenSnap] = await Promise.all([
      tx.get(userRef),
      tx.get(assetRef),
      tx.get(gardenStateRef),
    ]);

    if (!userSnap.exists) {
      throw new HttpsError('not-found', 'User document not found.');
    }
    if (assetSnap.exists) {
      throw new HttpsError('already-exists', 'Asset already owned.');
    }

    // Level gate check
    const gardenData = gardenSnap.exists ? gardenSnap.data() : {};
    const currentLevel = gardenData.currentLevel || 1;
    if (isLevelGated && currentLevel < requiredLevel) {
      throw new HttpsError(
        'failed-precondition',
        `Garden level ${requiredLevel} required. Current: ${currentLevel}.`
      );
    }

    // Balance check
    const currentBalance = userSnap.get('noorCoinBalance') ?? 0;
    if (currentBalance < ncPrice) {
      throw new HttpsError('failed-precondition', 'Insufficient Noor Coins.');
    }

    const updatedBalance = currentBalance - ncPrice;

    // Deduct NC
    tx.update(userRef, {
      noorCoinBalance: FieldValue.increment(-ncPrice),
    });

    // Write garden asset with full schema
    tx.set(assetRef, {
      assetTemplateId: assetId,
      slotId: '',
      positionX: 0,
      positionY: 0,
      tier,
      isDiscovered: false,
      currentHealthState: 1,
      purchasedAt: FieldValue.serverTimestamp(),
      purchaseType: 'nc',
      originalNcPrice: ncPrice,
      isPlaced: false,
      giftedFromUserId: null,
      giftedToUserId: null,
    });

    // Wallet transaction
    tx.set(txRef, {
      type: 'spend',
      amount: ncPrice,
      source: 'garden_asset',
      assetId,
      balanceAfter: updatedBalance,
      createdAt: FieldValue.serverTimestamp(),
    });

    // Sacred centre logic
    let isSacredCentre = false;
    if (tier === 'sacred' && !gardenData.sacredCentreSlotKey) {
      tx.set(gardenStateRef, {
        sacredCentreSlotKey: '10,10', // default centre position
      }, { merge: true });
      isSacredCentre = true;
    }

    return { newBalance: updatedBalance, isSacredCentre };
  });

  return { success: true, newBalance: result.newBalance, isSacredCentre: result.isSacredCentre };
});

// ── hayatDrop ────────────────────────────────────────────────────────────
/**
 * Restores a single garden asset's health (Hayat Drop).
 * FIXED PRICE: 2,500 NC.
 *
 * Request payload:
 *   uid           {string}  — Firebase Auth UID
 *   targetAssetId {string}  — gardenAssets document ID to restore
 *   paymentType   {string}  — 'nc' | 'iap'
 */
exports.hayatDrop = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Authentication required.');
  }

  const { uid, targetAssetId, paymentType } = request.data;

  if (typeof uid !== 'string' || uid.trim() === '') {
    throw new HttpsError('invalid-argument', 'uid must be a non-empty string.');
  }
  if (request.auth.uid !== uid) {
    throw new HttpsError('permission-denied', 'Cannot restore for another user.');
  }
  if (typeof targetAssetId !== 'string' || targetAssetId.trim() === '') {
    throw new HttpsError('invalid-argument', 'targetAssetId must be a non-empty string.');
  }
  if (paymentType !== 'nc' && paymentType !== 'iap') {
    throw new HttpsError('invalid-argument', "paymentType must be 'nc' or 'iap'.");
  }

  const HAYAT_DROP_PRICE = 2500;
  const userRef = db.collection('users').doc(uid);
  const assetRef = userRef.collection('gardenAssets').doc(targetAssetId);
  const hayatLogRef = userRef.collection('hayatLog').doc();
  const txRef = userRef.collection('wallet_transactions').doc();

  await db.runTransaction(async (tx) => {
    const [userSnap, assetSnap] = await Promise.all([
      tx.get(userRef),
      tx.get(assetRef),
    ]);

    if (!userSnap.exists) {
      throw new HttpsError('not-found', 'User document not found.');
    }
    if (!assetSnap.exists) {
      throw new HttpsError('not-found', 'Asset not found.');
    }

    // NC payment
    if (paymentType === 'nc') {
      const balance = userSnap.get('noorCoinBalance') ?? 0;
      if (balance < HAYAT_DROP_PRICE) {
        throw new HttpsError('failed-precondition', 'Insufficient Noor Coins.');
      }
      tx.update(userRef, {
        noorCoinBalance: FieldValue.increment(-HAYAT_DROP_PRICE),
      });
      tx.set(txRef, {
        type: 'spend',
        amount: HAYAT_DROP_PRICE,
        source: 'hayat_drop',
        targetAssetId,
        balanceAfter: (userSnap.get('noorCoinBalance') ?? 0) - HAYAT_DROP_PRICE,
        createdAt: FieldValue.serverTimestamp(),
      });
    }

    // Restore asset health
    tx.update(assetRef, {
      currentHealthState: 1,
    });

    // Write hayat log
    tx.set(hayatLogRef, {
      type: 'drop',
      targetAssetId,
      paymentType,
      ncCost: paymentType === 'nc' ? HAYAT_DROP_PRICE : 0,
      restoredAt: FieldValue.serverTimestamp(),
      previousHealthState: assetSnap.data().currentHealthState || 1,
      newHealthState: 1,
    });
  });

  return { success: true };
});

// ── hayatBloom ───────────────────────────────────────────────────────────
/**
 * Restores ALL garden assets' health at once (Hayat Bloom).
 * FIXED PRICE: 8,000 NC.
 *
 * Request payload:
 *   uid         {string}  — Firebase Auth UID
 *   paymentType {string}  — 'nc' | 'iap'
 */
exports.hayatBloom = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Authentication required.');
  }

  const { uid, paymentType } = request.data;

  if (typeof uid !== 'string' || uid.trim() === '') {
    throw new HttpsError('invalid-argument', 'uid must be a non-empty string.');
  }
  if (request.auth.uid !== uid) {
    throw new HttpsError('permission-denied', 'Cannot bloom for another user.');
  }
  if (paymentType !== 'nc' && paymentType !== 'iap') {
    throw new HttpsError('invalid-argument', "paymentType must be 'nc' or 'iap'.");
  }

  const HAYAT_BLOOM_PRICE = 8000;
  const userRef = db.collection('users').doc(uid);
  const gardenStateRef = userRef.collection('gardenState').doc('state');
  const hayatLogRef = userRef.collection('hayatLog').doc();
  const txRef = userRef.collection('wallet_transactions').doc();

  // Read all garden assets that need restoration
  const assetsSnap = await userRef.collection('gardenAssets')
    .where('currentHealthState', '>', 1)
    .get();

  await db.runTransaction(async (tx) => {
    const userSnap = await tx.get(userRef);

    if (!userSnap.exists) {
      throw new HttpsError('not-found', 'User document not found.');
    }

    // NC payment
    if (paymentType === 'nc') {
      const balance = userSnap.get('noorCoinBalance') ?? 0;
      if (balance < HAYAT_BLOOM_PRICE) {
        throw new HttpsError('failed-precondition', 'Insufficient Noor Coins.');
      }
      tx.update(userRef, {
        noorCoinBalance: FieldValue.increment(-HAYAT_BLOOM_PRICE),
      });
      tx.set(txRef, {
        type: 'spend',
        amount: HAYAT_BLOOM_PRICE,
        source: 'hayat_bloom',
        balanceAfter: (userSnap.get('noorCoinBalance') ?? 0) - HAYAT_BLOOM_PRICE,
        createdAt: FieldValue.serverTimestamp(),
      });
    }

    // Restore all assets
    for (const doc of assetsSnap.docs) {
      tx.update(doc.ref, { currentHealthState: 1 });
    }

    // Update garden visual state
    tx.set(gardenStateRef, {
      currentVisualState: 1,
    }, { merge: true });

    // Write hayat log
    tx.set(hayatLogRef, {
      type: 'bloom',
      paymentType,
      ncCost: paymentType === 'nc' ? HAYAT_BLOOM_PRICE : 0,
      restoredAt: FieldValue.serverTimestamp(),
      assetsRestored: assetsSnap.size,
    });
  });

  return { success: true };
});

// ── recordQuestionMarkCompletion ─────────────────────────────────────────
/**
 * Records completion of a question mark video and awards the discovered asset.
 *
 * Request payload:
 *   uid            {string}  — Firebase Auth UID
 *   questionMarkId {string}  — questionMarks document ID
 *   watchedSeconds {number}  — seconds the user watched
 */
exports.recordQuestionMarkCompletion = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Authentication required.');
  }

  const { uid, questionMarkId, watchedSeconds } = request.data;

  if (typeof uid !== 'string' || uid.trim() === '') {
    throw new HttpsError('invalid-argument', 'uid must be a non-empty string.');
  }
  if (request.auth.uid !== uid) {
    throw new HttpsError('permission-denied', 'Cannot complete for another user.');
  }
  if (typeof questionMarkId !== 'string' || questionMarkId.trim() === '') {
    throw new HttpsError('invalid-argument', 'questionMarkId must be a non-empty string.');
  }
  if (typeof watchedSeconds !== 'number' || watchedSeconds < 0) {
    throw new HttpsError('invalid-argument', 'watchedSeconds must be a non-negative number.');
  }

  // ── Read question mark data ────────────────────────────────────────────────
  const qmRef = db.collection('users').doc(uid).collection('questionMarks').doc(questionMarkId);
  const qmSnap = await qmRef.get();

  if (!qmSnap.exists) {
    throw new HttpsError('not-found', 'Question mark not found.');
  }

  const qmData = qmSnap.data();
  const videoId = qmData.videoId;
  const rewardAssetTemplateId = qmData.rewardAssetTemplateId;

  // ── Read video content for duration validation ─────────────────────────────
  const videoSnap = await db.collection('questionMarkContent').doc(videoId).get();
  if (!videoSnap.exists) {
    throw new HttpsError('not-found', 'Video content not found.');
  }

  const durationSeconds = videoSnap.data().durationSeconds || 0;

  // SERVER VALIDATION: must watch nearly all of the video
  if (watchedSeconds < (durationSeconds - 5)) {
    throw new HttpsError('failed-precondition', 'Video not completed.');
  }

  // ── Read asset template for tier info ──────────────────────────────────────
  const templateSnap = await db.collection('assetTemplates').doc(rewardAssetTemplateId).get();
  const tier = templateSnap.exists ? (templateSnap.data().tier || 'common') : 'common';

  // ── Firestore transaction ──────────────────────────────────────────────────
  const userRef = db.collection('users').doc(uid);
  const discoveryRef = userRef.collection('discoveredAssets').doc();
  const newAssetRef = userRef.collection('gardenAssets').doc(discoveryRef.id);

  await db.runTransaction(async (tx) => {
    // Mark question mark as discovered
    tx.update(qmRef, {
      discoveredAt: FieldValue.serverTimestamp(),
      isActive: false,
    });

    // Write discovered asset record
    tx.set(discoveryRef, {
      questionMarkId,
      videoId,
      rewardAssetTemplateId,
      watchedSeconds,
      discoveredAt: FieldValue.serverTimestamp(),
    });

    // Write garden asset
    tx.set(newAssetRef, {
      assetTemplateId: rewardAssetTemplateId,
      slotId: '',
      positionX: 0,
      positionY: 0,
      tier,
      isDiscovered: true,
      currentHealthState: 1,
      purchasedAt: FieldValue.serverTimestamp(),
      purchaseType: 'discovered',
      originalNcPrice: 0,
      isPlaced: false,
      giftedFromUserId: null,
      giftedToUserId: null,
    });
  });

  return {
    success: true,
    rewardAssetId: discoveryRef.id,
    rewardAssetTemplateId,
  };
});

// ── updateGardenAccessTimer ──────────────────────────────────────────────
/**
 * Updates the garden access timer with daily cap enforcement.
 * Called by Soul Stack and YWTL completions.
 *
 * Request payload:
 *   uid        {string}  — Firebase Auth UID
 *   hoursToAdd {number}  — hours to add (always 6)
 *
 * Enforces 24-hour daily cap. Resets on new day.
 * Returns { success, expiresAt, hoursEarnedToday }
 */
exports.updateGardenAccessTimer = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Authentication required.');
  }

  const { uid, hoursToAdd } = request.data;

  if (typeof uid !== 'string' || uid.trim() === '') {
    throw new HttpsError('invalid-argument', 'uid must be a non-empty string.');
  }
  if (request.auth.uid !== uid) {
    throw new HttpsError('permission-denied', 'Cannot update timer for another user.');
  }
  if (!Number.isInteger(hoursToAdd) || hoursToAdd <= 0) {
    throw new HttpsError('invalid-argument', 'hoursToAdd must be a positive integer.');
  }

  const userRef = db.collection('users').doc(uid);
  const timerRef = userRef.collection('gardenAccessTimer').doc('timer');

  const result = await db.runTransaction(async (tx) => {
    const timerSnap = await tx.get(timerRef);
    const timerData = timerSnap.exists ? timerSnap.data() : {};

    const now = new Date();
    const todayStr = now.toISOString().slice(0, 10);

    // Reset daily counter if new day
    let hoursEarnedToday = timerData.hoursEarnedToday || 0;
    const dailyResetDate = timerData.dailyResetDate || '';
    if (dailyResetDate !== todayStr) {
      hoursEarnedToday = 0;
    }

    // Enforce 24-hour daily cap
    if (hoursEarnedToday + hoursToAdd > 24) {
      throw new HttpsError(
        'failed-precondition',
        `Daily cap reached. Earned today: ${hoursEarnedToday}h, max: 24h.`
      );
    }

    // Calculate new expiry: min(now + hoursToAdd, midnight tonight)
    const extensionMs = hoursToAdd * 60 * 60 * 1000;
    const midnight = new Date(now);
    midnight.setHours(23, 59, 59, 999);

    const proposedExpiry = new Date(now.getTime() + extensionMs);
    const actualExpiry = proposedExpiry < midnight ? proposedExpiry : midnight;

    const newHoursEarned = hoursEarnedToday + hoursToAdd;

    tx.set(timerRef, {
      todayAccessExpiresAt: Timestamp.fromDate(actualExpiry),
      hoursEarnedToday: newHoursEarned,
      dailyResetDate: todayStr,
      updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });

    // Also update the user doc's gardenAccessTimer for backward compatibility
    tx.update(userRef, {
      'gardenAccessTimer.expiresAt': Timestamp.fromDate(actualExpiry),
    });

    return {
      expiresAt: actualExpiry.toISOString(),
      hoursEarnedToday: newHoursEarned,
    };
  });

  return {
    success: true,
    expiresAt: result.expiresAt,
    hoursEarnedToday: result.hoursEarnedToday,
  };
});

// ── extendGardenAccess ────────────────────────────────────────────────────
/**
 * Extends the user's garden access timer (legacy — kept for backward compat).
 *
 * Request payload:
 *   uid   {string}  — Firebase Auth UID of the user
 *   hours {number}  — positive integer, hours to extend access by
 */
exports.extendGardenAccess = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Authentication required.');
  }

  const { uid, hours } = request.data;

  if (typeof uid !== 'string' || uid.trim() === '') {
    throw new HttpsError('invalid-argument', 'uid must be a non-empty string.');
  }
  if (request.auth.uid !== uid) {
    throw new HttpsError('permission-denied', 'Cannot extend access for another user.');
  }
  if (!Number.isInteger(hours) || hours <= 0) {
    throw new HttpsError('invalid-argument', 'hours must be a positive integer.');
  }

  const userRef = db.collection('users').doc(uid);
  const userSnap = await userRef.get();

  if (!userSnap.exists) {
    throw new HttpsError('not-found', 'User document not found.');
  }

  const userData = userSnap.data();
  const now = Date.now();
  const extensionMs = hours * 60 * 60 * 1000;

  let baseMs;
  const currentExpiry = userData.gardenAccessTimer?.expiresAt;

  if (currentExpiry && currentExpiry.toMillis() > now) {
    baseMs = currentExpiry.toMillis();
  } else {
    baseMs = now;
  }

  const newExpiry = Timestamp.fromMillis(baseMs + extensionMs);

  await userRef.update({
    'gardenAccessTimer.expiresAt': newExpiry,
  });

  return { success: true, expiresAt: newExpiry };
});

// ── generateDailyStacks (scheduled) ──────────────────────────────────────
/**
 * Runs at 2 AM UTC daily to generate three Soul Stack playlists.
 */
exports.generateDailyStacks = onSchedule('0 2 * * *', async (event) => {
  const amalsSnap = await db
    .collection('amals')
    .where('contentType', '==', 'video')
    .where('is_scholar_reviewed', '==', true)
    .where('isActive', '==', true)
    .get();

  if (amalsSnap.empty) {
    console.log('generateDailyStacks: No eligible video Amals found. Skipping.');
    return;
  }

  let amalIds = amalsSnap.docs.map((doc) => doc.id);

  const today = new Date();
  const yesterday = new Date(today);
  yesterday.setUTCDate(yesterday.getUTCDate() - 1);
  const yesterdayStr = yesterday.toISOString().slice(0, 10);
  const todayStr = today.toISOString().slice(0, 10);

  const stackNames = ['rise', 'shine', 'glow'];
  const yesterdayPositions = {};

  const yesterdaySnaps = await Promise.all(
    stackNames.map((name) =>
      db.doc(`dailyStacks/${yesterdayStr}/${name}/${name}`).get()
    )
  );

  yesterdaySnaps.forEach((snap, stackIdx) => {
    if (snap.exists) {
      const videos = snap.data().videos || [];
      videos.forEach((amalId, posIdx) => {
        const globalPos = stackIdx * 5 + posIdx;
        yesterdayPositions[globalPos] = amalId;
      });
    }
  });

  const shuffle = (arr) => {
    const a = [...arr];
    for (let i = a.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [a[i], a[j]] = [a[j], a[i]];
    }
    return a;
  };

  while (amalIds.length < 15) {
    amalIds = amalIds.concat(shuffle(amalIds));
  }

  let selected = shuffle(amalIds).slice(0, 15);

  if (Object.keys(yesterdayPositions).length > 0) {
    for (let i = 0; i < selected.length; i++) {
      if (yesterdayPositions[i] === selected[i]) {
        let swapped = false;
        for (let j = 0; j < selected.length; j++) {
          if (
            j !== i &&
            selected[j] !== yesterdayPositions[i] &&
            selected[i] !== yesterdayPositions[j]
          ) {
            [selected[i], selected[j]] = [selected[j], selected[i]];
            swapped = true;
            break;
          }
        }
        if (!swapped) {
          console.log(
            `generateDailyStacks: Could not avoid position collision at index ${i}.`
          );
        }
      }
    }
  }

  const batch = db.batch();
  stackNames.forEach((name, idx) => {
    const stackVideos = selected.slice(idx * 5, idx * 5 + 5);
    const docRef = db.doc(`dailyStacks/${todayStr}/${name}/${name}`);
    batch.set(docRef, {
      videos: stackVideos,
      createdAt: FieldValue.serverTimestamp(),
    });
  });

  await batch.commit();
  console.log(`generateDailyStacks: Wrote stacks for ${todayStr}.`);
});

// ── Rainforest Intensity Helpers ──────────────────────────────────────────

async function getDownstreamUsers(uid, maxDepth = 10) {
  const allUsers = new Set();
  const queue = [{ uid, depth: 0 }];

  while (queue.length > 0) {
    const { uid: currentUid, depth } = queue.shift();
    if (depth >= maxDepth) continue;

    const referralsSnap = await db.collection('users').doc(currentUid)
      .collection('referrals').get();

    for (const doc of referralsSnap.docs) {
      if (!allUsers.has(doc.id)) {
        allUsers.add(doc.id);
        queue.push({ uid: doc.id, depth: depth + 1 });
      }
    }
  }

  return allUsers;
}

async function countRecentStackCompletions(userIds) {
  let totalCompletions = 0;

  const now = new Date();
  const dateKeys = [];
  for (let i = 0; i < 7; i++) {
    const d = new Date(now);
    d.setDate(d.getDate() - i);
    dateKeys.push(d.toISOString().slice(0, 10));
  }

  const BATCH_SIZE = 50;
  for (let i = 0; i < userIds.length; i += BATCH_SIZE) {
    const batch = userIds.slice(i, i + BATCH_SIZE);
    const promises = batch.map(async (uid) => {
      let count = 0;
      for (const dateKey of dateKeys) {
        const logDoc = await db.collection('users').doc(uid)
          .collection('soulStackLog').doc(dateKey).get();
        if (logDoc.exists) {
          const data = logDoc.data();
          count += (data?.rise?.count || 0) + (data?.shine?.count || 0) + (data?.glow?.count || 0);
        }
      }
      return count;
    });
    const results = await Promise.all(promises);
    totalCompletions += results.reduce((a, b) => a + b, 0);
  }

  return totalCompletions;
}

function completionsToIntensity(completions) {
  if (completions === 0) return 0;
  if (completions <= 10) return Math.round(10 + (completions / 10) * 15);
  if (completions <= 50) return Math.round(26 + ((completions - 10) / 40) * 24);
  if (completions <= 200) return Math.round(51 + ((completions - 50) / 150) * 29);
  return Math.min(100, Math.round(81 + ((completions - 200) / 300) * 19));
}

// ── calculateRainforestIntensity (scheduled) ─────────────────────────────
exports.calculateRainforestIntensity = onSchedule('0 */6 * * *', async (event) => {
  console.log('calculateRainforestIntensity: Starting intensity calculation.');

  const usersSnap = await db.collection('users').get();

  const usersWithReferrals = [];
  for (const userDoc of usersSnap.docs) {
    const referralsSnap = await db.collection('users').doc(userDoc.id)
      .collection('referrals').limit(1).get();
    if (!referralsSnap.empty) {
      usersWithReferrals.push(userDoc.id);
    }
  }

  console.log(`calculateRainforestIntensity: Found ${usersWithReferrals.length} users with referrals.`);

  if (usersWithReferrals.length === 0) {
    console.log('calculateRainforestIntensity: No users with referrals. Done.');
    return;
  }

  const updates = [];

  for (const uid of usersWithReferrals) {
    try {
      const downstreamUsers = await getDownstreamUsers(uid);
      if (downstreamUsers.size === 0) {
        updates.push({ uid, intensity: 0 });
        continue;
      }

      const completions = await countRecentStackCompletions([...downstreamUsers]);
      const intensity = completionsToIntensity(completions);
      updates.push({ uid, intensity });
    } catch (err) {
      console.log(`calculateRainforestIntensity: Error processing user ${uid}: ${err.message}`);
    }
  }

  const MAX_BATCH = 500;
  for (let i = 0; i < updates.length; i += MAX_BATCH) {
    const batchSlice = updates.slice(i, i + MAX_BATCH);
    const writeBatch = db.batch();
    for (const { uid, intensity } of batchSlice) {
      writeBatch.update(db.collection('users').doc(uid), {
        rainforestIntensity: intensity,
      });
    }
    await writeBatch.commit();
  }

  console.log(`calculateRainforestIntensity: Updated ${updates.length} users. Done.`);
});

// ── aggregateRainfallIntensity (scheduled every 5 minutes) ──────────────
/**
 * For each user with an outerGardenStats document:
 *   - Count referrals where heartbeatAt > now - 60 minutes
 *   - Compute intensity = min(activeCount / 50, 1.0) as float 0.0-1.0
 *   - Write outerGardenStats.currentRainfallIntensity
 */
exports.aggregateRainfallIntensity = onSchedule('every 5 minutes', async (event) => {
  console.log('aggregateRainfallIntensity: Starting.');

  const usersSnap = await db.collectionGroup('outerGardenStats').get();

  if (usersSnap.empty) {
    console.log('aggregateRainfallIntensity: No users with outerGardenStats. Done.');
    return;
  }

  const oneHourAgo = Timestamp.fromDate(new Date(Date.now() - 60 * 60 * 1000));
  const writeBatch = db.batch();
  let updateCount = 0;

  for (const statsDoc of usersSnap.docs) {
    try {
      // Extract uid from path: users/{uid}/outerGardenStats/{docId}
      const pathParts = statsDoc.ref.path.split('/');
      const uid = pathParts[1];

      // Count active referrals (heartbeatAt within last 60 minutes)
      const referralsSnap = await db.collection('users').doc(uid)
        .collection('referrals')
        .where('heartbeatAt', '>', oneHourAgo)
        .get();

      const activeCount = referralsSnap.size;
      const intensity = Math.min(activeCount / 50, 1.0);

      writeBatch.update(statsDoc.ref, {
        currentRainfallIntensity: intensity,
        lastCalculatedAt: FieldValue.serverTimestamp(),
      });

      updateCount++;

      // Firestore batch limit is 500
      if (updateCount % 500 === 0) {
        await writeBatch.commit();
      }
    } catch (err) {
      console.log(`aggregateRainfallIntensity: Error for doc ${statsDoc.ref.path}: ${err.message}`);
    }
  }

  if (updateCount % 500 !== 0) {
    await writeBatch.commit();
  }

  console.log(`aggregateRainfallIntensity: Updated ${updateCount} users. Done.`);
});

// ── createUserDocument ────────────────────────────────────────────────────
exports.createUserDocument = onCall(async (request) => {
  console.log('createUserDocument: called');

  if (!request.auth) {
    console.log('createUserDocument: no auth');
    throw new HttpsError('unauthenticated', 'Authentication required.');
  }

  console.log('createUserDocument: auth uid =', request.auth.uid);
  console.log('createUserDocument: request.data =', JSON.stringify(request.data));

  try {
    const data = request.data || {};
    const uid = data.uid;
    const name = data.name || '';
    const photoUrl = data.photoUrl || '';
    const language = data.language || 'en';
    const prayerTradition = data.prayerTradition || 'sunni';
    const calculationMethod = data.calculationMethod || '2';
    const notificationsEnabled = data.notificationsEnabled === true;
    const biometricEnabled = data.biometricEnabled === true;

    if (typeof uid !== 'string' || uid.trim() === '') {
      console.log('createUserDocument: invalid uid');
      throw new HttpsError('invalid-argument', 'uid must be a non-empty string.');
    }
    if (request.auth.uid !== uid) {
      console.log('createUserDocument: uid mismatch', request.auth.uid, uid);
      throw new HttpsError('permission-denied', 'Cannot create document for another user.');
    }

    const userRef = db.collection('users').doc(uid);
    const existing = await userRef.get();
    if (existing.exists) {
      console.log('createUserDocument: doc already exists, returning early');
      return { success: true, alreadyExists: true };
    }

    const referralCode = uid.substring(0, 4).toUpperCase() +
      Math.random().toString(36).substring(2, 6).toUpperCase();

    const email = (request.auth.token && request.auth.token.email) || '';
    console.log('createUserDocument: email =', email, 'referralCode =', referralCode);

    const docData = {
      uid,
      displayName: name,
      email,
      photoUrl,
      language,
      prayerTradition,
      calculationMethod,
      notificationsEnabled,
      biometricEnabled,
      preferredLocale: language,
      noorCoinBalance: 0,
      totalNoorCoinsEarned: 0,
      subscriptionStatus: 'free',
      currentDailyStreak: 0,
      longestDailyStreak: 0,
      currentWeeklyStreak: 0,
      longestWeeklyStreak: 0,
      totalAmalsCompleted: 0,
      totalNoorCoinsFromAmals: 0,
      referralCode,
      rainforestIntensity: 0,
      isDeleted: false,
      createdAt: FieldValue.serverTimestamp(),
      lastActiveAt: FieldValue.serverTimestamp(),
    };

    console.log('createUserDocument: writing doc...');
    await userRef.set(docData);
    console.log('createUserDocument: doc written successfully');

    return { success: true, alreadyExists: false, referralCode };
  } catch (err) {
    console.error('createUserDocument: ERROR:', err.message, err.stack);
    if (err instanceof HttpsError) throw err;
    throw new HttpsError('internal', `Failed to create user document: ${err.message}`);
  }
});

// ── markActiveDay ────────────────────────────────────────────────────────
/**
 * Marks today as an active day for the garden neglect system.
 * Updates lastActiveDate and manages consecutiveActiveDays.
 *
 * Request payload:
 *   uid {string} — Firebase Auth UID
 *
 * Returns { success: true, consecutiveActiveDays }
 */
exports.markActiveDay = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Authentication required.');
  }

  const { uid } = request.data;

  if (typeof uid !== 'string' || uid.trim() === '') {
    throw new HttpsError('invalid-argument', 'uid must be a non-empty string.');
  }
  if (request.auth.uid !== uid) {
    throw new HttpsError('permission-denied', 'Cannot mark active for another user.');
  }

  const stateRef = db.collection('users').doc(uid)
    .collection('gardenState').doc('state');

  const todayStr = new Date().toISOString().slice(0, 10);

  const result = await db.runTransaction(async (tx) => {
    const stateSnap = await tx.get(stateRef);
    const stateData = stateSnap.exists ? stateSnap.data() : {};

    const lastDateStr = stateData.lastActiveDateStr || '';
    let consecutive = stateData.consecutiveActiveDays || 0;

    if (lastDateStr === todayStr) {
      // Already marked today
      return { consecutive, alreadyMarked: true };
    }

    // Check if yesterday was the last active day (for streak)
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const yesterdayStr = yesterday.toISOString().slice(0, 10);

    if (lastDateStr === yesterdayStr) {
      consecutive += 1;
    } else {
      consecutive = 1; // streak broken, start fresh
    }

    tx.set(stateRef, {
      lastActiveDate: FieldValue.serverTimestamp(),
      lastActiveDateStr: todayStr,
      consecutiveActiveDays: consecutive,
    }, { merge: true });

    return { consecutive, alreadyMarked: false };
  });

  return {
    success: true,
    consecutiveActiveDays: result.consecutive,
    alreadyMarked: result.alreadyMarked,
  };
});

// ── sellAsset ────────────────────────────────────────────────────────────
/**
 * Sells a placed garden asset back for 60% of its original NC price.
 * Removes the gardenAssets document and credits the user.
 * If the sold asset was the Sacred Centre, clears sacredCentreSlotKey.
 *
 * Request payload:
 *   uid     {string} — Firebase Auth UID
 *   assetId {string} — gardenAssets document ID (slotKey)
 *
 * Returns { success: true, refundedNc }
 */
exports.sellAsset = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Authentication required.');
  }

  const { uid, assetId } = request.data;

  if (typeof uid !== 'string' || uid.trim() === '') {
    throw new HttpsError('invalid-argument', 'uid must be a non-empty string.');
  }
  if (request.auth.uid !== uid) {
    throw new HttpsError('permission-denied', 'Cannot sell for another user.');
  }
  if (typeof assetId !== 'string' || assetId.trim() === '') {
    throw new HttpsError('invalid-argument', 'assetId must be a non-empty string.');
  }

  const userRef = db.collection('users').doc(uid);
  const assetRef = userRef.collection('gardenAssets').doc(assetId);
  const stateRef = userRef.collection('gardenState').doc('state');
  const txRef = userRef.collection('wallet_transactions').doc();

  const result = await db.runTransaction(async (tx) => {
    const [assetSnap, userSnap, stateSnap] = await Promise.all([
      tx.get(assetRef),
      tx.get(userRef),
      tx.get(stateRef),
    ]);

    if (!assetSnap.exists) {
      throw new HttpsError('not-found', 'Asset not found.');
    }
    if (!userSnap.exists) {
      throw new HttpsError('not-found', 'User not found.');
    }

    const assetData = assetSnap.data();
    const originalPrice = assetData.originalNcPrice || 0;
    const sellPrice = Math.ceil(originalPrice * 0.6);

    // Credit user (only spendable balance, NOT totalNcEverEarned)
    tx.update(userRef, {
      noorCoinBalance: FieldValue.increment(sellPrice),
    });

    // Remove the asset
    tx.delete(assetRef);

    // Write transaction record
    const currentBalance = userSnap.get('noorCoinBalance') ?? 0;
    tx.set(txRef, {
      type: 'sell',
      amount: sellPrice,
      source: 'garden_asset_sell',
      assetId,
      assetTemplateId: assetData.assetTemplateId || '',
      balanceAfter: currentBalance + sellPrice,
      createdAt: FieldValue.serverTimestamp(),
    });

    // Check if this was the Sacred Centre
    const stateData = stateSnap.exists ? stateSnap.data() : {};
    if (stateData.sacredCentreSlotKey === assetId) {
      tx.set(stateRef, { sacredCentreSlotKey: null }, { merge: true });
    }

    // Increment preLovedCount on the template (best effort)
    const templateId = assetData.assetTemplateId;
    if (templateId) {
      const templateRef = db.collection('assetTemplates').doc(templateId);
      tx.update(templateRef, {
        preLovedCount: FieldValue.increment(1),
      });
    }

    return { sellPrice };
  });

  return { success: true, refundedNc: result.sellPrice };
});

// ── spawnQuestionMark ────────────────────────────────────────────────────
/**
 * Spawns a new question mark in the user's garden if eligible.
 * Rules: active QM count < 3 AND last spawn was > 48 hours ago.
 *
 * Request payload:
 *   uid        {string} — Firebase Auth UID
 *   userLevel  {number} — current garden level (1-4)
 *
 * Returns { success, questionMarkId, positionX, positionY } or { skipped: true }
 */
exports.spawnQuestionMark = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Authentication required.');
  }

  const { uid, userLevel } = request.data;

  if (typeof uid !== 'string' || uid.trim() === '') {
    throw new HttpsError('invalid-argument', 'uid must be a non-empty string.');
  }
  if (request.auth.uid !== uid) {
    throw new HttpsError('permission-denied', 'Cannot spawn for another user.');
  }

  const level = typeof userLevel === 'number' ? userLevel : 1;
  const qmCol = db.collection('users').doc(uid).collection('questionMarks');

  // Check active count
  const activeSnap = await qmCol.where('isActive', '==', true).get();
  if (activeSnap.size >= 3) {
    return { success: true, skipped: true, reason: 'max_active' };
  }

  // Check last spawn time (48h cooldown)
  const recentSnap = await qmCol
    .orderBy('spawnedAt', 'desc')
    .limit(1)
    .get();

  if (!recentSnap.empty) {
    const lastSpawn = recentSnap.docs[0].data().spawnedAt;
    if (lastSpawn) {
      const hoursSince = (Date.now() - lastSpawn.toMillis()) / (1000 * 60 * 60);
      if (hoursSince < 48) {
        return { success: true, skipped: true, reason: 'cooldown' };
      }
    }
  }

  // Determine zone and position
  // Level 1-2 unlocked area: cells 4-15 (meadow)
  // Level 3 area: cells 2-17 (grove)
  const maxRange = level >= 3 ? 16 : 12;
  const minCell = level >= 3 ? 2 : 4;
  const posX = minCell + Math.floor(Math.random() * maxRange);
  const posY = minCell + Math.floor(Math.random() * maxRange);
  const landZone = level >= 3 ? 'grove' : 'meadow';
  const contentType = Math.random() > 0.5 ? 'dua' : 'history';

  // Pick a random video from questionMarkContent matching zone
  const contentSnap = await db.collection('questionMarkContent')
    .where('landZone', '==', landZone)
    .get();

  let videoId = '';
  let rewardAssetTemplateId = '';

  if (!contentSnap.empty) {
    const randomContent = contentSnap.docs[
      Math.floor(Math.random() * contentSnap.docs.length)
    ];
    videoId = randomContent.id;
    rewardAssetTemplateId = randomContent.data().rewardAssetTemplateId || '';
  }

  // If no content found, pick a random asset template as reward
  if (!rewardAssetTemplateId) {
    const rewardTier = landZone === 'grove' ? 'premium' : 'standard';
    const ownedSnap = await db.collection('users').doc(uid)
      .collection('gardenAssets').get();
    const ownedIds = new Set(ownedSnap.docs.map(d => d.data().assetTemplateId));

    const candidateSnap = await db.collection('assetTemplates')
      .where('tier', '==', rewardTier)
      .where('isScholarReviewed', '==', true)
      .get();

    const unowned = candidateSnap.docs.filter(d => !ownedIds.has(d.id));
    if (unowned.length > 0) {
      rewardAssetTemplateId = unowned[
        Math.floor(Math.random() * unowned.length)
      ].id;
    }
  }

  const now = new Date();
  const expiresAt = new Date(now.getTime() + 48 * 60 * 60 * 1000);

  const qmRef = qmCol.doc();
  await qmRef.set({
    spawnedAt: FieldValue.serverTimestamp(),
    expiresAt: Timestamp.fromDate(expiresAt),
    positionX: posX,
    positionY: posY,
    landZone,
    contentType,
    videoId,
    rewardAssetTemplateId,
    isActive: true,
    isExpired: false,
    discoveredAt: null,
    abandonedAt: null,
    notificationSentAt: null,
  });

  return {
    success: true,
    skipped: false,
    questionMarkId: qmRef.id,
    positionX: posX,
    positionY: posY,
  };
});

// ── checkAndExpireQuestionMarks (scheduled daily at 3 AM UTC) ─────────────
exports.checkAndExpireQuestionMarks = onSchedule('0 3 * * *', async (event) => {
  console.log('checkAndExpireQuestionMarks: Starting.');

  const now = Timestamp.now();
  const usersSnap = await db.collection('users').get();
  let expired = 0;

  for (const userDoc of usersSnap.docs) {
    const qmSnap = await db.collection('users').doc(userDoc.id)
      .collection('questionMarks')
      .where('isActive', '==', true)
      .where('expiresAt', '<', now)
      .get();

    if (qmSnap.empty) continue;

    const batch = db.batch();
    for (const qmDoc of qmSnap.docs) {
      batch.update(qmDoc.ref, {
        isActive: false,
        isExpired: true,
        abandonedAt: FieldValue.serverTimestamp(),
      });
      expired++;
    }
    await batch.commit();
  }

  console.log(`checkAndExpireQuestionMarks: Expired ${expired} question marks. Done.`);
});

// ── sendQuestionMarkReminder (scheduled every 6 hours) ───────────────────
exports.sendQuestionMarkReminder = onSchedule('0 */6 * * *', async (event) => {
  console.log('sendQuestionMarkReminder: Starting.');

  const now = Date.now();
  const usersSnap = await db.collection('users').get();
  let sent = 0;

  for (const userDoc of usersSnap.docs) {
    const qmSnap = await db.collection('users').doc(userDoc.id)
      .collection('questionMarks')
      .where('isActive', '==', true)
      .where('notificationSentAt', '==', null)
      .get();

    for (const qmDoc of qmSnap.docs) {
      const expiresAt = qmDoc.data().expiresAt;
      if (!expiresAt) continue;

      const hoursUntilExpiry = (expiresAt.toMillis() - now) / (1000 * 60 * 60);
      if (hoursUntilExpiry <= 24 && hoursUntilExpiry > 0) {
        // Mark notification as sent (actual FCM sending is a separate concern)
        await qmDoc.ref.update({
          notificationSentAt: FieldValue.serverTimestamp(),
        });
        sent++;
      }
    }
  }

  console.log(`sendQuestionMarkReminder: Marked ${sent} reminders. Done.`);
});

// ── Helper: send FCM to user by uid ──────────────────────────────────────
async function sendFcmToUser(uid, notification, data) {
  try {
    const userDoc = await db.collection('users').doc(uid).get();
    if (!userDoc.exists) return;
    const fcmToken = userDoc.data().fcmToken;
    if (!fcmToken) return;

    await getMessaging().send({
      token: fcmToken,
      notification,
      data: data || {},
      android: { priority: 'high' },
      apns: { payload: { aps: { sound: 'default' } } },
    });
  } catch (e) {
    console.log(`sendFcmToUser(${uid}): ${e.message}`);
  }
}

// ── Pre-designed neglect notification images (Option B for v1) ───────────
const NEGLECT_IMAGES = {
  3: 'https://firebasestorage.googleapis.com/v0/b/amal-app-production.appspot.com/o/assets%2Fnotifications%2Fresting.png?alt=media',
  4: 'https://firebasestorage.googleapis.com/v0/b/amal-app-production.appspot.com/o/assets%2Fnotifications%2Flonging.png?alt=media',
  5: 'https://firebasestorage.googleapis.com/v0/b/amal-app-production.appspot.com/o/assets%2Fnotifications%2Fwithering.png?alt=media',
};

// ── checkAndSendNeglectNotifications (scheduled daily at 10 AM UTC) ──────
/**
 * For each user with a gardenState document:
 * - Compute daysSinceActive from lastActiveDate.
 * - At 7, 14, 21 days: send FCM notification if not already sent.
 * - Reset notificationSent flags when user becomes active again.
 */
exports.checkAndSendNeglectNotifications = onSchedule('0 10 * * *', async (event) => {
  console.log('checkAndSendNeglectNotifications: Starting.');

  const usersSnap = await db.collection('users').get();
  let sent = 0;

  for (const userDoc of usersSnap.docs) {
    const uid = userDoc.id;

    try {
      const stateSnap = await db.collection('users').doc(uid)
        .collection('gardenState').doc('state').get();

      if (!stateSnap.exists) continue;
      const stateData = stateSnap.data();

      const lastActiveDate = stateData.lastActiveDate;
      if (!lastActiveDate) continue;

      const daysSince = Math.floor(
        (Date.now() - lastActiveDate.toMillis()) / (1000 * 60 * 60 * 24)
      );

      const notificationSent = stateData.notificationSent || {};

      // Reset flags if user was recently active (< 3 days)
      if (daysSince < 3 && Object.keys(notificationSent).length > 0) {
        await stateSnap.ref.update({ notificationSent: {} });
        continue;
      }

      // State 3: Resting (7 days)
      if (daysSince >= 7 && daysSince < 14 && !notificationSent.state3) {
        await sendFcmToUser(uid, {
          title: 'Ya ayyuha alladhina amanu',
          body: 'Your garden is resting. The rivers are waiting.',
          imageUrl: NEGLECT_IMAGES[3],
        }, { type: 'neglect', level: '3', deepLink: '/jannah-garden' });

        await stateSnap.ref.update({ 'notificationSent.state3': FieldValue.serverTimestamp() });
        sent++;
      }

      // State 4: Longing (14 days)
      if (daysSince >= 14 && daysSince < 21 && !notificationSent.state4) {
        await sendFcmToUser(uid, {
          title: 'Your paradise misses you',
          body: 'The waters of your paradise are receding. Return — even one Amal is enough.',
          imageUrl: NEGLECT_IMAGES[4],
        }, { type: 'neglect', level: '4', deepLink: '/jannah-garden' });

        await stateSnap.ref.update({ 'notificationSent.state4': FieldValue.serverTimestamp() });
        sent++;
      }

      // State 5: Withering (21 days)
      if (daysSince >= 21 && !notificationSent.state5) {
        await sendFcmToUser(uid, {
          title: 'Your Jannah is calling',
          body: 'Your Jannah is calling you home. It has not forgotten you.',
          imageUrl: NEGLECT_IMAGES[5],
        }, { type: 'neglect', level: '5', deepLink: '/jannah-garden' });

        await stateSnap.ref.update({ 'notificationSent.state5': FieldValue.serverTimestamp() });
        sent++;
      }
    } catch (e) {
      console.log(`checkAndSendNeglectNotifications: Error for ${uid}: ${e.message}`);
    }
  }

  console.log(`checkAndSendNeglectNotifications: Sent ${sent} notifications. Done.`);
});

// ── notifyReferrerOnJoin — called from createUserDocument ────────────────
/**
 * Sends an FCM notification to the referrer when a new user joins.
 *
 * Request payload:
 *   referrerId  {string} — UID of the referrer
 *   newUserName {string} — Display name of the new user
 */
exports.notifyReferrerOnJoin = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'Authentication required.');
  }

  const { referrerId, newUserName } = request.data;

  if (typeof referrerId !== 'string' || referrerId.trim() === '') {
    return { success: false, reason: 'no_referrer' };
  }

  const displayName = newUserName || 'Someone';

  try {
    await sendFcmToUser(referrerId, {
      title: 'Rain is falling in your garden',
      body: `${displayName} just joined Amal through your invitation.`,
    }, { type: 'referral_join', deepLink: '/jannah-garden/outer' });

    // Also write to referrer's referrals subcollection
    await db.collection('users').doc(referrerId)
      .collection('referrals').doc(request.auth.uid)
      .set({
        joinedAt: FieldValue.serverTimestamp(),
        displayName,
        heartbeatAt: FieldValue.serverTimestamp(),
      }, { merge: true });

    return { success: true };
  } catch (e) {
    console.log(`notifyReferrerOnJoin: ${e.message}`);
    return { success: false, reason: e.message };
  }
});
