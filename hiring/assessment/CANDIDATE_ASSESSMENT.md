# Amal — Developer Technical Assessment

**Duration:** 45 minutes
**Rules:**
- You may reference official documentation (flutter.dev, pub.dev, firebase.google.com)
- No AI tools (ChatGPT, Copilot, Claude, Gemini, etc.)
- Keep your screen shared at all times
- You may talk through your thinking — we encourage it

---

## Part A — Written Quiz (15 minutes)

Type your answers below each question. Short, clear answers are preferred.

---

### Section 1: Dart & Flutter

**Q1.** What is the difference between a `StatelessWidget` and a `StatefulWidget`? When would you choose one over the other?

> Your answer:

**Q2.** What does adding `const` to a widget constructor do, and why does it matter for performance?

> Your answer:

**Q3.** What is the difference between a `Future` and a `Stream` in Dart? Give one real-world example of when you'd use each.

> Your answer:

**Q4.** What does this code print, and why?

```dart
final list = [1, 2, 3];
final copy = list;
copy.add(4);
print(list.length);
```

> Your answer:

---

### Section 2: Riverpod State Management

**Q5.** In one sentence each, describe when you would use:
- `Provider`
- `StateNotifierProvider`
- `StreamProvider`

> Your answer:

**Q6.** What is the difference between `ref.watch()` and `ref.read()`? When should you use each?

> Your answer:

**Q7.** You need to display a user's wallet balance that updates in real-time from Firestore. Which Riverpod provider type would you use and why?

> Your answer:

---

### Section 3: Firebase

**Q8.** Write a Firestore security rule for a `/users/{userId}` document that:
- Allows authenticated users to read only their own document
- Allows authenticated users to write to their own document BUT blocks writes to the `balance` field

> Your answer:

**Q9.** Why would you use a Firebase Cloud Function (server-side) instead of a direct client-side Firestore write for awarding in-app currency to a user?

> Your answer:

**Q10.** What is the difference between a Firestore `transaction` and a `batch write`? When would you use each?

> Your answer:

---

## Part B — Coding Exercise (30 minutes)

### Build: "Daily Dhikr Tracker" Mini-App

Build a small Flutter app that lets users track daily dhikr (remembrance) sessions. This mirrors the architecture patterns used in our production app.

### Requirements

**1. Data Model** — Create a `DhikrSession` model:
```
- id: String
- dhikrName: String (e.g., "SubhanAllah", "Alhamdulillah", "Allahu Akbar")
- count: int
- completedAt: DateTime
- userId: String
```

**2. Service Layer** — Create a `DhikrService` class that:
- Reads dhikr sessions from a Firestore collection `dhikr_sessions` (filtered by current user)
- Writes a new session document after the user completes a dhikr round
- Returns a `Stream<List<DhikrSession>>` for real-time updates

**3. Riverpod Providers** — Set up:
- A provider that exposes the `DhikrService`
- A `StreamProvider` that watches the user's dhikr sessions
- State management for the active counter (tracks taps during a session)

**4. UI — Two Screens:**

**Screen A: Dhikr Counter**
- Display the current dhikr name (hardcode 3 options: SubhanAllah, Alhamdulillah, Allahu Akbar)
- A large tap target that increments a counter
- Show the current count prominently
- A "Save Session" button that writes to Firestore and resets the counter

**Screen B: Session History**
- Display a list of past sessions from Firestore (real-time via StreamProvider)
- Show dhikr name, count, and date for each session
- Handle loading and empty states

**5. Localization** — Create an ARB file with at least 5 localized strings used in the UI (English only is fine, but the setup must be correct so adding another language later is trivial).

### What We're Evaluating

- **Project structure:** How you organize files (models, services, providers, screens)
- **Riverpod usage:** Correct provider types, proper `ref.watch` / `ref.read` usage
- **Firebase patterns:** Clean Firestore reads/writes, stream handling
- **Code quality:** Dart conventions, null safety, readability
- **Localization readiness:** ARB setup wired correctly

### What We're NOT Evaluating

- Visual design or pixel-perfect UI — functional is fine
- Tests (skip them for time)
- Authentication flow — you can hardcode a mock userId
- Navigation library — use whatever you're comfortable with

### Getting Started

Use the starter project provided, or create a new Flutter project with:
```bash
flutter create dhikr_tracker
cd dhikr_tracker
flutter pub add flutter_riverpod cloud_firestore firebase_core flutter_localizations intl
```

Then set up Firebase however you're comfortable (your own project, or just structure the code correctly — we'll evaluate the patterns, not whether it compiles against a live project).

---

**Good luck. Focus on clean architecture over feature completeness — a well-structured partial solution beats a messy complete one.**
