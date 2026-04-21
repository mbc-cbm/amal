# Contributing to Amal

Welcome! This guide gets you from `git clone` to a running app.

## Prerequisites

- **Flutter** 3.x (`flutter --version`)
- **Xcode** (iOS) and **Android Studio** (Android) with simulators
- **Node.js** 20.x (for Cloud Functions)
- **CocoaPods** (`sudo gem install cocoapods`)
- **Firebase CLI** (`npm install -g firebase-tools`)

## 1. Clone & install dependencies

```bash
git clone https://github.com/mbc-cbm/amal.git
cd amal
flutter pub get
cd ios && pod install && cd ..
cd functions && npm install && cd ..
```

## 2. Get the secret files

These are **not** in the repo. Ask the project lead for them via 1Password (or your secure channel):

| File | Path | Purpose |
|---|---|---|
| `GoogleService-Info.plist` | `ios/Runner/` | Firebase iOS config |
| `google-services.json` | `android/app/` | Firebase Android config |
| `service-account-key.json` | `scripts/` | Firebase Admin SDK (seed scripts only — never deploy) |

Drop each file into the path shown. **Never commit them.** They are listed in `.gitignore`.

## 3. Run the app

```bash
flutter run                    # picks default device
flutter run -d <device-id>     # specific simulator/device
flutter devices                # list available devices
```

## 4. Before you push

```bash
flutter analyze                # must report "No issues found"
flutter test                   # run widget tests
```

## Project context

Read [CLAUDE.md](./CLAUDE.md) for the full architecture overview: app structure, Noor Coin economy, wallet security invariants, Firestore schema, Cloud Functions, and routing.

## Branch & PR conventions

- Branch off `main`: `git checkout -b feat/short-description` or `fix/short-description`
- Keep PRs scoped to one feature or fix
- PR description should explain **why**, not just what (the diff shows what)
- Run `flutter analyze` and `flutter test` before requesting review

## Things to know

- **Localization:** All user-visible strings go through `AppLocalizations`. Add keys to `lib/core/l10n/app_en.arb` first, then run `flutter gen-l10n`. Mirror the key into `app_bn.arb`, `app_ur.arb`, `app_ar.arb`.
- **Wallet writes:** Never write directly to Firestore wallet fields. All Noor Coin earn/spend goes through Cloud Functions (`updateNoorWallet`, `spendNoorCoins`). Firestore rules enforce this.
- **Amal queries:** Always filter `is_scholar_reviewed: true`. Never display unreviewed content.
- **Ad IDs:** Use TEST IDs during development. Production IDs are swapped in only at submission time.

## Cloud Functions

```bash
cd functions
npm run serve     # local emulator
npm run deploy    # deploy to amal-app-production (requires Firebase login)
```

## Need help?

Ping the project lead or check `CLAUDE.md` for service-by-service architecture notes.
