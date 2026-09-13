# Finder — Launch plan

Status legend: `[x]` done · `[ ]` open · `[~]` partially done

The demo build (branch `redesign/beacon-ui`) has every screen wired to the backend.
This plan lists what separates it from a public, paid product, in the order it should be done.

## Phase 1 — Safe to put in front of real users

Security
- [x] `JWT_SECRET` required in production; the server refuses to start with the built-in default
- [x] `helmet`, request rate limiting (global, auth, password reset) and a CORS allow-list from `CORS_ORIGINS`
- [x] Schema validation on every write endpoint (auth, posts, chats, profile, settings, search)
- [x] Password policy: at least 8 characters with a letter and a number (server and client)
- [x] Signed Cloudinary uploads through `POST /uploads/sign`; the unsigned preset only works in debug builds
- [x] Seed script refuses to run against a production database

Infrastructure
- [x] Postgres path verified with `docker compose` (backend + Postgres)
- [x] `Dockerfile`, `docker-compose.yml`, `railway.json`, health check
- [x] `.env.example` covers every variable; `docs/DEPLOYMENT.md` explains hosting, SMTP (Resend), Cloudinary, Google OAuth
- [ ] Deploy the backend to Railway/Render with Postgres and a custom domain (needs your accounts)
- [ ] Point SMTP at Resend (or another provider) so verification and reset e-mails go out

App
- [x] `API_URL` is required for release builds (`--dart-define=API_URL=https://…`); debug keeps localhost
- [x] Application id `com.finderapp.finder`, label "Finder", iOS bundle id aligned
- [x] Release signing from `android/key.properties` (keystore stays out of git)
- [ ] Generate the upload keystore and register the new Android OAuth client (package + SHA-1) for Google sign-in
- [x] Launcher icon and splash generated from the Beacon mark
- [x] Privacy policy and terms of service: in-app screens plus hosted HTML for store listings
- [x] Account deletion that really deletes (posts, chats, messages, settings, profile) with password confirmation
- [ ] Review the legal texts with a lawyer before publishing

## Phase 2 — Feels like a real product

- [ ] Push notifications (Firebase Cloud Messaging) driven by the existing `notify()` helper
- [ ] Live chat over the existing WebSocket server instead of polling
- [ ] Coordinates on posts (geolocator), distance search on the server, real map on the details screen
- [ ] Server-side search, category and date filters; feed paging with the cursor the API already returns
- [ ] Match engine: compare new posts by category, keywords and distance, create `match` notifications
- [ ] Admin endpoints and a minimal admin page: reports queue, verification approvals, bans
- [ ] Google sign-in on web (client id) and iOS (URL scheme), Apple sign-in for App Store
- [ ] Backend test suite (the smoke matrix as Jest/Vitest tests), widget tests for the main flows
- [ ] GitHub Actions: analyze + test + build on every push, deploy backend from `main`

## Phase 3 — Business layer

- [ ] Monetisation: featured posts, premium verification, business accounts for venues/transit (Stripe)
- [ ] Organisation accounts with their own dashboard
- [ ] Analytics (product) and crash reporting (Sentry) in app and backend
- [ ] Structured logging, uptime alerts, database backups
- [ ] Localisation (`flutter_localizations`), accessibility pass, offline cache
- [ ] iOS release (certificates, TestFlight)

## Housekeeping

- [x] Remove stray one-off scripts from the repo root
- [x] Remove unused Firebase artefacts (`firebase-admin`, `google-services.json`)
- [ ] Remove the migrated legacy users (shared placeholder password) before the first production seed
