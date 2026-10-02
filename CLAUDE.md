# Finder

Premium lost-and-found application (Flutter app + Node backend) for reporting and recovering missing items.

Aland Agency project. Follow C:\Users\aland\Desktop\Aland Agency\Aland-HQ\rules\global-rules.md and the tiers in ..\playbooks\tiers.md (full path: C:\Users\aland\Desktop\Aland Agency\Aland-HQ\playbooks\tiers.md).

## Stack
- Flutter (Dart sdk ^3.9.2), Riverpod (flutter_riverpod, riverpod_generator), Firebase (core, messaging)
- Backend: Node.js (`backend/`), Express-style server (`server.js`), SQLite (`database.sqlite`), Docker + docker-compose, Railway (`railway.json`)
- CI: `codemagic.yaml`

## Commands
- Flutter install/run: `flutter pub get`, `flutter run`
- Flutter test: `flutter test`
- Backend install: `cd backend && npm install`
- Backend run: `cd backend && npm start` (SQLite locally; seed demo accounts with `npm run seed`, password Demo1234!)
- Backend tests: `cd backend && npm test` (node --test, throw-away SQLite via SQLITE_PATH)
- App strings: `python tool/merge_l10n.py` after editing `tool/l10n/**` (never edit `lib/l10n/app_*.arb`)
- Release APK: `flutter build apk --release --split-per-abi --target-platform android-arm64 --dart-define=API_URL=https://finder-app-production-7c49.up.railway.app` (JAVA_HOME = ~/.jdks/jdk-21.0.12.1+1), then adb install on both phones
- Docs: `docs/LOCALIZATION.md`, `docs/MODERATION.md`, `docs/CHAT_REALTIME.md`, `docs/DEPLOYMENT.md`

## Key folders
- `lib/` — app, core, data, features, models, providers, repositories, screens, services, theme, usecases, widgets
- `backend/` — Node server, routes, db.js, migrate.js, seed.js, websocket.js
- `android/`, `ios/`, `macos/`, `linux/`, `windows/` — platform projects
- `docs/`, `DESIGN.md`, `FINDER_PROJECT_DETAILED_OVERVIEW*.txt`, `state_management_explanation.txt`

## Specialists that fit (Agency Library)
- Mobile App Builder, Backend Architect, UI Designer, Database Optimizer

## Project rules
- Don't restyle existing UI unless Aland asks. Smallest change. No secrets in code.
- `backend/.env.example` exists; only put real secrets in `backend/.env` (gitignored) — never commit it.
- Repo is currently on branch `redesign/beacon-ui` with uncommitted changes to generated plugin registrant files (macos/windows) — leave these alone unless the task is about those platforms.
