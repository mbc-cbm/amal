# Amal - Islamic Impact Platform

## Quick Reference

- **App name:** Amal
- **Package:** `com.amal.app`
- **Stack:** Flutter + Firebase (iOS & Android)
- **State management:** Riverpod (`flutter_riverpod`)
- **Navigation:** `go_router`
- **Garden engine:** Flame (2.5D)
- **Languages:** en, bn (Bengali), ur (Urdu), ar (Arabic) — all wired from Day 1
- **Firebase project:** `amal-app-production`
- **Flutter analyze status:** No issues found
- **Current phase:** Phase 11 complete (QA). Next: Phase 12-14 (App Store / Play Store submission)

---

## Currency: Noor Coins

There is **ONE currency only: Noor Coins**. There are NO "Shining Points" — never write code referencing `shiningPoints`.

### Noor Coin Values (from `NoorCoinValues` constants)

| Action | Coins |
|---|---|
| Prayer | 300 per prayer |
| Fast (Ramadan) | 500 per day |
| Tasbeeh | 50 per session |
| Soul Stack (Rise/Shine/Glow) | 25,000 per stack |
| YWTL video | 15,000 per full watch |
| Garden access per Soul Stack | 6 hours |

---

## Critical Invariant: Wallet Security

**WalletService NEVER writes directly to Firestore wallet fields.** All earn/spend calls go through Cloud Functions: `updateNoorWallet` and `spendNoorCoins`.

Firestore rules block ALL client writes to `noorCoinBalance` and `totalNoorCoinsEarned`. Cloud Functions use Admin SDK to bypass rules safely.

Any feature that awards or deducts Noor Coins **must** go through `WalletService`, which delegates to Cloud Functions only.

---

## Project Structure

```
lib/
  main.dart                  — Firebase init, Riverpod ProviderScope, AppPreferences
  app.dart                   — MaterialApp.router, 4 locale delegates, light/dark themes
  firebase_options.dart      — Web config filled in; iOS/Android need flutterfire configure

  core/
    constants/
      app_colors.dart        — Design tokens (primaryGreen, primaryGold, creamWhite, etc.)
      app_typography.dart    — Text styles (incl. arabicBody for Quranic text)
      app_spacing.dart       — Spacing + radius constants
      noor_coin_values.dart  — Canonical coin amounts
      calculation_methods.dart — Prayer calculation method metadata

    theme/
      app_theme.dart         — Material 3 light + dark themes

    l10n/
      app_en.arb             — English (template, ~120+ keys)
      app_bn.arb             — Bengali
      app_ur.arb             — Urdu
      app_ar.arb             — Arabic
      app_localizations*.dart — Auto-generated (flutter gen-l10n)

    router/
      app_router.dart        — 25+ routes, auth redirect guard, remaining placeholders for unbuilt features

    providers/
      auth_provider.dart          — authServiceProvider, walletServiceProvider, signInProvider, biometric
      locale_provider.dart        — Locale state
      prayer_provider.dart        — Prayer times, log, next prayer, notification settings providers
      amal_gallery_provider.dart  — amalsProvider, amalDetailProvider, favouriteAmalIdsProvider, amalCompletionCountProvider
      amal_tracker_provider.dart  — trackerStatsProvider, recentCompletionsProvider, amalOfTheDayProvider, dailyGoalProvider, favouriteAmalsProvider
      soul_stack_provider.dart    — soulStackDayStatusProvider, dailyStackContentProvider, adServiceProvider
      garden_provider.dart        — gardenAccessProvider (stream), storeAssetsProvider, ownedAssetIdsProvider, rainforestIntensityProvider, referralCodeProvider

    services/
      firebase_service.dart
      auth_service.dart           — Google, Apple, Email sign-in/up, password reset
      wallet_service.dart         — Earn/spend via Cloud Functions, watchNoorCoinBalance stream
      notification_service.dart
      prayer_service.dart         — Location permission & GPS
      prayer_times_service.dart   — AlAdhan API + SharedPreferences caching
      prayer_log_service.dart     — Firestore prayer log CRUD
      azan_service.dart           — Audio playback + local notification scheduling
      biometric_service.dart      — Face ID / fingerprint
      user_service.dart           — Firestore user document CRUD
      amal_gallery_service.dart   — Amal queries (ALWAYS is_scholar_reviewed:true), completions, favourites
      amal_tracker_service.dart   — Streak stats stream, recent completions, Amal of the Day, daily goal
      soul_stack_service.dart     — Daily stack content, day status stream, completeStack (25000 NC + 6h garden)
      ad_service.dart             — google_mobile_ads interstitial with TEST IDs, showDoubleInterstitial
      garden_service.dart         — Access gate stream, store assets, purchase/restore, grid save/load, rainforest intensity, referral

    models/
      user_model.dart
      amal_model.dart             — AmalModel + enums: AmalCategory, AmalContentType, AmalCompletionType, AmalDifficulty
      asset_model.dart
      noor_transaction_model.dart
      prayer_log_model.dart       — DayPrayerLog, PrayerNotificationSettings, PrayerNotificationMode
      prayer_times_model.dart     — PrayerTimes, PrayerName enum

    utils/
      app_preferences.dart        — SharedPreferences wrapper (onboarding, locale, biometric, prayer location/cache)

  features/
    auth/
      auth_screen.dart
      email_auth_screen.dart      — Full email sign-in/up with validation
      providers/

    onboarding/                   — 8-screen flow (welcome→signup→language→tradition→method→profile→notifications→complete)
      onboarding_screen.dart
      providers/onboarding_provider.dart
      screens/ (8 screens)

    home/
      home_screen.dart            — BUILT: greeting header, Noor balance chip, prayer summary card

    prayer/
      prayer_screen.dart          — BUILT: full prayer times, GPS/city location picker, notification mode toggles

    qibla/
      qibla_screen.dart           — BUILT: CustomPainter compass, great-circle bearing to Kaaba, magnetometer calibration

    tasbeeh/
      tasbeeh_screen.dart         — BUILT: 4 dhikrs, circular counter, haptic/visual feedback, Firestore session logging

    ramadan/
      ramadan_screen.dart         — BUILT: countdown/tracker, fasting log (500 NC), Tarawih toggle, last 10 nights

    amal_gallery/
      amal_gallery_screen.dart    — BUILT: browsable list, category filter chips, search, favourites, content type badges
      amal_detail_screen.dart     — BUILT: static + video detail, completion flow, video_player, coin award

    amal_tracker/
      amal_tracker_screen.dart    — BUILT: 3-tab shell (Gallery/Tracker/Favourites) with IndexedStack + BottomNavigationBar
      tracker_dashboard.dart      — BUILT: Amal of the Day (gold glow), daily goal, 2x3 stats grid, recent activity
      favourites_tab.dart         — BUILT: favourite amals list with remove toggle

    soul_stack/
      soul_stack_screen.dart      — BUILT: 3 stack cards (Rise/Shine/Glow), progress, gold glow on completion
      soul_stack_flow_screen.dart — BUILT: 11-step flow state machine (ads→title→start→swipe→explain→ads→ready→5 videos→ads→achievement)

    jannah_garden/
      jannah_garden_screen.dart   — BUILT: access gate, Inner/Outer Circle toggle, timer, asset store bottom sheet, restoration dialog
      garden_game.dart            — BUILT: Flame FlameGame, 20x20 grid, pan/zoom, asset placement, vitality decay visuals, question marks
      rainforest_game.dart        — BUILT: Flame scene, trees/rain/waterfalls/glow particles scaled by intensity (0-100)
    ywtl/
      ywtl_screen.dart            — BUILT: weekly video schedule, video player, coin collection (15000 NC)
    noor_wallet/
      noor_wallet_screen.dart     — BUILT: balance display, transaction history (paginated), earning/spending guides
    profile/
      profile_screen.dart         — BUILT: personal info, community impact (FTC compliant), subscription, account deletion
    settings/
      settings_screen.dart        — BUILT: 5 notification types, prayer settings, app settings (theme/language/haptic/biometric)

  shared/
    widgets/
      amal_button.dart            — AmalPrimaryButton, AmalOutlinedButton, AmalGoldButton, AmalTextButton
      amal_logo.dart
      amal_text_field.dart        — AmalTextField
      prayer_card.dart            — PrayerCard, SunriseRow
    utils/

firestore.rules                   — Complete security rules with wallet field protection
functions/
  index.js                        — updateNoorWallet, spendNoorCoins, extendGardenAccess, generateDailyStacks
  package.json                    — Node 20, firebase-admin ^12, firebase-functions ^6
  seed_amals.js                   — 20 sample Amals (5 video, 15 static, 6 categories, real Quran/Hadith sources)
```

---

## Cloud Functions (functions/index.js)

| Function | Type | Purpose |
|---|---|---|
| `updateNoorWallet` | Callable | Awards Noor Coins atomically (balance + totalEarned + wallet_transactions). Valid sources: prayer, fast, tasbeeh, soul_stack, ywtl, amal |
| `spendNoorCoins` | Callable | Deducts from noorCoinBalance only (totalEarned never decreases), unlocks garden asset |
| `extendGardenAccess` | Callable | Extends gardenAccessTimer.expiresAt by N hours (adds to future expiry or sets from now) |
| `generateDailyStacks` | Scheduled (2AM UTC) | Selects 15 video amals (5 per stack), variation algorithm, writes to dailyStacks/{date}/rise\|shine\|glow |
| `calculateRainforestIntensity` | Scheduled (every 6h) | Traverses referral tree (10 levels), counts Soul Stack completions last 7 days, maps to 0-100 intensity |

---

## Firebase Config

- Web API Key: `AIzaSyA_CYfI1fB0vr7wtDenTZdxyCPz9TPo2uM`
- authDomain: `amal-app-production.firebaseapp.com`
- messagingSenderId: `1064683710947`
- Web appId: `1:1064683710947:web:cb4ce6237c390af416d8d6`
- measurementId: `G-R0M17MCQFL`
- iOS/Android appIds: **TODO** — run `flutterfire configure --project=amal-app-production`

---

## Routing

All routes defined in `AppRoutes` (lib/core/router/app_router.dart). Auth guard redirects:
- Not logged in -> `/welcome`
- Logged in, onboarding incomplete -> `/onboarding/language`
- Logged in + onboarded, tries auth/onboarding routes -> `/home`

### Active Routes (wired to real screens)
`/welcome`, `/sign-in`, `/auth/email`, `/onboarding/*` (6 routes), `/home`, `/prayer`, `/qibla`, `/tasbeeh`, `/ramadan`, `/amal-tracker`, `/amal-gallery`, `/amal-gallery/detail`, `/soul-stack`, `/soul-stack/flow`, `/jannah-garden`, `/ywtl`, `/noor-wallet`, `/profile`, `/settings`

### Placeholder Routes (still using _PlaceholderScreen)
`/auth/forgot-password`

---

## Build Status & Phase Progress

### Phase 3 — Day 1 (2026-03-29) — COMPLETE
Full project infrastructure: pubspec, Firebase, Riverpod, go_router, Flame, all 4 language ARBs, Firestore security rules, Cloud Functions (updateNoorWallet + spendNoorCoins), all core services/models/providers, auth flow (Google/Apple/Email/biometric), 8 onboarding screens, design system (colors, typography, spacing, Material 3 themes).

### Phase 4 — Day 2 (2026-03-30 to 2026-04-01) — COMPLETE
HomeScreen (greeting, Noor balance, prayer summary), PrayerScreen (AlAdhan API, GPS/city, notification mode toggles, caching), prayer providers/services/models, PrayerCard + SunriseRow widgets.

### Phase 5 — Days 3-4 (2026-04-01) — COMPLETE
QiblaScreen (CustomPainter compass, great-circle bearing, magnetometer, calibration detection), TasbeehScreen (4 dhikrs, circular counter, haptic feedback, 50 NC award, Firestore logging, session history), RamadanScreen (live countdown, Suhoor/Iftar times, fasting log 500 NC, Tarawih toggle, last 10 nights, date lookup 1446-1450 AH).

### Phase 6 — Days 5-6 (2026-04-01) — COMPLETE
AmalModel rewritten with full schema + 4 enums. AmalGalleryService (queries always filter is_scholar_reviewed:true, completions, favourites). AmalGalleryScreen (category filters, search, content type badges, favourite hearts). AmalDetailScreen (static + video with video_player, completion flow). AmalTrackerScreen (3-tab shell: Gallery/Tracker/Favourites). TrackerDashboard (Amal of the Day, daily goal, 2x3 stats grid, recent activity). FavouritesTab. Seed script with 20 authentic Amals. Streak fields in user doc (server-side).

### Phase 7 — Days 7-8 (2026-04-01) — COMPLETE
SoulStackService + AdService (google_mobile_ads test IDs, Completer-based). SoulStackScreen (3 stack cards, progress, gold glow). SoulStackFlowScreen (11-step state machine: ads→title→start→swipe→explain→ads→ready→5 videos→ads→achievement). Swipe lock during ads (PopScope + NeverScrollableScrollPhysics). Cloud Functions: extendGardenAccess + generateDailyStacks (scheduled 2AM UTC).

### Phase 8 — Days 9-11 (2026-04-01) — COMPLETE
GardenService (access gate stream, store assets, purchase/restore via Cloud Functions, grid state save/load via SharedPreferences, rainforest intensity, referral code). GardenGame (Flame FlameGame with 20x20 grid, pan/zoom via ScaleCallbacks, GardenAssetComponent with 4 vitality states, QuestionMarkComponent with pulse/reveal, _GridBackground). RainforestGame (intensity-driven: trees scale 3-25, rain particles, waterfalls at 30+, glow particles). JannahGardenScreen (access gate with Soul Stack/subscribe buttons, first-time warning dialog, Inner/Outer Circle toggle, timer overlay with countdown, asset store DraggableScrollableSheet with category filters, restoration dialog). Cloud Function: calculateRainforestIntensity (scheduled every 6h, traverses referral tree to 10 levels, counts Soul Stack completions last 7 days). AppPreferences extended with garden grid + warning seen. share_plus added to pubspec. ~18 new l10n keys across all 4 ARB files.

### Phase 9 — Day 12 (2026-04-01) — COMPLETE
YwtlScreen (weekly Impact Wing video schedule Mon-Sun, video_player with auto-play, completion detection, "Collect Your Noor Coins" button at end, 15000 NC award via Cloud Function, ywtlLog write, rewatch support, placeholder data fallback, 7-day scrollable schedule with today highlight). NoorWalletScreen (animated balance counter via TweenAnimationBuilder, totalNoorCoinsEarned from Firestore, paginated transaction history with source labels/icons/time-ago, pull-to-refresh, collapsible earning guide with all 6 sources, collapsible spending guide with garden link). Routes wired: /ywtl + /noor-wallet. ~23 new l10n keys across all 4 ARB files.

### Phase 10 — Day 13 (2026-04-01) — COMPLETE
ProfileScreen (editable photo/name, member since, Free/Premium badge, referral code with share_plus, total earned, community impact from amalStats/communityImpact with FTC-compliant "Data updated" footer, subscription management with Monthly/Annual pricing, Restore Purchases, Log Out with confirmation, Delete Account with two-step verification). SettingsScreen (5 notification types: prayer reminders with Silent/Notify/Azan per prayer, Soul Stack reminders with time pickers, YWTL toggle+time, Streak At Risk toggle, Asset Fading toggle; prayer settings: tradition/method/location/azan audio; app settings: language cards, theme segmented Light/Dark/System, haptic/sound/biometric switches). AppPreferences extended with theme, haptic, sound, Soul Stack/YWTL reminder times, streak/fading toggles, azan audio. Routes wired: /profile + /settings. ~42 new l10n keys across all 4 ARB files.

### Phase 11 — Day 14 (2026-04-01) — COMPLETE
Comprehensive QA pass. See QA Report below. All critical checks passed. flutter analyze: No issues found. 283 l10n keys verified across all 4 languages. Firestore security rules verified (4 test cases). App ready for beta submission.

### Next Steps
- Run `flutterfire configure --project=amal-app-production` for iOS/Android Firebase config
- **Phase 11 (Day 14):** QA, Testing & Bug Fixes
- **Phase 12-14:** App Store + Play Store submission

---

## Conventions

- **Localization:** Every user-visible string goes through `AppLocalizations`. Template is `app_en.arb`; run `flutter gen-l10n` after editing ARB files. Agents often edit generated .dart files but miss .arb source files — always add keys to .arb first.
- **Providers:** Core providers live in `lib/core/providers/`. Feature-specific providers go in `lib/features/<feature>/providers/`.
- **Services:** Business logic in `lib/core/services/`. Services are stateless singletons exposed via Riverpod `Provider`. Constructor pattern: optional `FirebaseFirestore?`, `FirebaseAuth?`, `FirebaseFunctions?` with defaults.
- **Widgets:** Reusable widgets in `lib/shared/widgets/`. Feature-specific widgets stay in their feature directory.
- **Routes:** Add new routes to `AppRoutes` in `app_router.dart`. Replace `_PlaceholderScreen` with real screens as built. Add route path constant + import + GoRoute entry.
- **Colors:** All from `AppColors` — never hardcode hex values outside `app_colors.dart`.
- **Ad IDs:** Always use TEST ad IDs during development. Real IDs swapped in before submission (see Appendix in build manual).
- **Amal queries:** MUST always filter `is_scholar_reviewed: true` — never display unreviewed content.
