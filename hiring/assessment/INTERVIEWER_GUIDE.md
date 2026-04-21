# Amal — Developer Technical Assessment: Interviewer Guide

**Duration:** 45 minutes total (supervised over Zoom)
**Format:** Part A (Written Quiz, 15 min) + Part B (Coding Exercise, 30 min)

---

## Before the Session

1. Send the candidate the `CANDIDATE_ASSESSMENT.md` file **at the start** of the Zoom call — not before.
2. Send the `coding_exercise/` starter project as a zip (or GitHub repo link) at the same time.
3. Have them share their screen for the entire session.
4. They may use official docs (flutter.dev, pub.dev, firebase.google.com) but **no AI tools** (ChatGPT, Copilot, Claude, etc.).
5. They may use their own IDE of choice.

---

## Timing Script

| Time | Activity |
|------|----------|
| 0:00 - 0:02 | Introductions, explain rules, share files |
| 0:02 - 0:17 | **Part A:** Written quiz (15 min) — they type answers in the quiz doc |
| 0:17 - 0:47 | **Part B:** Coding exercise (30 min) — screen shared, they can talk through their thinking |

---

## Part A — Answer Key & Scoring

### Section 1: Dart & Flutter (4 questions, 8 points)

**Q1 (2 pts):** Difference between `StatelessWidget` and `StatefulWidget`.
- **Good answer:** StatelessWidget is immutable — `build()` depends only on constructor args. StatefulWidget has a mutable `State` object that persists across rebuilds; calling `setState()` triggers a rebuild. (2 pts)
- **Acceptable:** Mentions state/no-state distinction without detail. (1 pt)

**Q2 (2 pts):** What does `const` do on a widget constructor and why does it matter?
- **Good answer:** Creates a compile-time constant — Flutter can skip rebuilding the widget entirely because it knows nothing changed. Improves performance by reducing widget tree rebuilds. (2 pts)
- **Acceptable:** "It's for performance" without explaining the mechanism. (1 pt)

**Q3 (2 pts):** `Future` vs `Stream` — when to use each.
- **Good answer:** Future = single async result (HTTP call, file read). Stream = sequence of values over time (Firestore snapshot listener, WebSocket, sensor data). (2 pts)
- **Acceptable:** Correct distinction but weak examples. (1 pt)

**Q4 (2 pts):** What does this print?
```dart
final list = [1, 2, 3];
final copy = list;
copy.add(4);
print(list.length);
```
- **Correct:** `4` — lists are reference types, `copy` points to the same list. (2 pts)
- **Partial:** Gets the answer right but can't explain why. (1 pt)

---

### Section 2: Riverpod (3 questions, 6 points)

**Q5 (2 pts):** `Provider` vs `StateNotifierProvider` vs `StreamProvider` — one-sentence use case for each.
- **Good answer:**
  - `Provider`: exposes a computed value or service singleton (no state changes)
  - `StateNotifierProvider`: manages mutable state with defined mutation methods
  - `StreamProvider`: wraps a Stream (e.g., Firestore real-time listener) and gives AsyncValue
- (2 pts for all 3 correct, 1 pt for 2 correct)

**Q6 (2 pts):** What is `ref.watch()` vs `ref.read()` — when do you use each?
- **Good answer:** `ref.watch()` inside `build()` — widget rebuilds when the value changes. `ref.read()` for one-shot reads inside callbacks/event handlers — doesn't set up a subscription. Using `ref.watch()` in a callback is a bug. (2 pts)
- **Acceptable:** Correct distinction but doesn't mention the callback rule. (1 pt)

**Q7 (2 pts):** You have a Firestore stream of wallet balance. Which Riverpod provider type and why?
- **Correct:** `StreamProvider` — it wraps the Firestore `snapshots()` stream and gives `AsyncValue<int>` with loading/error/data states built in. (2 pts)
- **Acceptable:** Says StreamProvider but can't explain AsyncValue. (1 pt)

---

### Section 3: Firebase (3 questions, 6 points)

**Q8 (2 pts):** Write a Firestore security rule that lets users read their own document but not write to the `balance` field.
- **Good answer (or close):**
```
match /users/{userId} {
  allow read: if request.auth != null && request.auth.uid == userId;
  allow write: if request.auth != null
    && request.auth.uid == userId
    && !request.resource.data.diff(resource.data).affectedKeys().hasAny(['balance']);
}
```
- (2 pts for correct logic, 1 pt if they get the auth check right but miss the field protection)

**Q9 (2 pts):** Why would you use a Cloud Function instead of a direct client write for awarding currency?
- **Key points (any 2 for full marks):**
  - Server-side validation — client can't cheat the amount
  - Atomic operations (transactions/batches) guaranteed to complete
  - Can enforce business rules (max earning limits, source validation)
  - Client Firestore rules can block the field entirely
- (2 pts for 2+ points, 1 pt for 1 point)

**Q10 (2 pts):** What's the difference between a Firestore `transaction` and a `batch write`?
- **Good answer:** Transaction reads then writes atomically — if the data changed between read and write, it retries. Batch write groups multiple writes into one atomic operation but does no reads. Use transaction when you need to read-then-write (e.g., increment balance). Use batch when you just need multiple writes to succeed or fail together. (2 pts)
- **Acceptable:** Gets the basic difference but misses retry behavior. (1 pt)

---

### Total Part A: 20 points

---

## Part B — Coding Exercise Evaluation Rubric

### What They're Building
A mini "Daily Dhikr Tracker" app with Riverpod + Firebase patterns. See `CANDIDATE_ASSESSMENT.md` for full spec.

### Rubric (30 points)

| Criteria | Excellent (full) | Acceptable (half) | Poor (0) |
|----------|------------------|--------------------|----------|
| **Project structure** (4 pts) | Clean separation: models/, services/, providers/, screens/. Files are well-organized. | Some structure but services mixed with UI. | Everything in one file or random structure. |
| **DhikrModel** (3 pts) | Immutable class with `fromJson`/`toJson`, proper types, null safety. | Model exists but missing serialization or has nullable issues. | No model or a raw Map. |
| **Riverpod providers** (6 pts) | Correct use of `StreamProvider` for Firestore stream, proper `ref.watch()` in UI, state management for counter. | Providers exist but wrong types or misused (e.g., `ref.watch` in callbacks). | No Riverpod or entirely wrong usage. |
| **Firestore integration** (5 pts) | Reads from collection, writes sessions correctly, uses proper async patterns. | Basic CRUD works but error handling missing or uses wrong patterns. | Doesn't connect to Firestore or hardcodes data. |
| **UI implementation** (5 pts) | Clean, functional UI: dhikr list, tap counter, session save. Uses Flutter widgets correctly. | UI works but rough — layout issues, no loading states. | Broken or incomplete UI. |
| **Localization setup** (3 pts) | ARB file created with at least 5 keys, `AppLocalizations.of(context)` used in UI. | ARB file exists but not wired into the app properly. | No localization attempt. |
| **Code quality** (4 pts) | Clean Dart, good naming, null safety, no analyzer warnings. | Some issues but generally readable. | Messy, inconsistent, or multiple analyzer errors. |

---

## Scoring Summary

| Part | Max Points |
|------|-----------|
| Part A — Written Quiz | 20 |
| Part B — Coding Exercise | 30 |
| **Total** | **50** |

### Hiring Thresholds (Suggested)

| Score | Recommendation |
|-------|---------------|
| 40-50 | Strong hire — can own features independently |
| 30-39 | Hire — solid foundation, may need ramp-up time on some areas |
| 20-29 | Borderline — consider a follow-up interview on weak areas |
| Below 20 | Pass — significant gaps in core stack |

### Red Flags (Automatic Concerns)

- Cannot explain `ref.watch()` vs `ref.read()` — will write buggy state management
- No understanding of why Cloud Functions handle currency — will create security vulnerabilities
- Cannot set up a basic Riverpod provider — will struggle with the entire Amal codebase
- Puts business logic directly in widgets — will create unmaintainable code
- Cannot write a Firestore security rule — cannot be trusted with production data

### Green Flags (Strong Signals)

- Mentions `AsyncValue` pattern (loading/error/data) without being prompted
- Thinks about field-level security in Firestore rules
- Structures code like a real project even in a 30-min exercise
- Asks clarifying questions about requirements before coding
- Handles edge cases (empty states, errors) even under time pressure

---

## Notes for the 9-Year vs 2-Year Experience Gap

The assessment is designed to be fair to both levels:
- The **quiz** tests knowledge that anyone using this stack should have, regardless of years
- The **coding exercise** has a baseline (get it working) that a 2-year dev should hit, and quality signals (clean architecture, edge cases, localization) where the 9-year dev should shine
- Don't penalize the junior dev for being slower — focus on whether their approach is correct
- The senior dev should be expected to score 35+ to justify the experience level
