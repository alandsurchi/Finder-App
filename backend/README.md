# Finder backend

Express + SQLite (or PostgreSQL) API for the Finder app.

## Run locally

```bash
npm install
cp .env.example .env      # optional; defaults already work for a local demo
npm run seed              # demo accounts, posts, chats, notifications
npm start                 # http://localhost:3001
```

`GET /health` reports which database is in use and where uploads are stored.

Production settings (JWT secret, CORS allow-list, Postgres, SMTP, Cloudinary, rate limits) are
described in [`docs/DEPLOYMENT.md`](../docs/DEPLOYMENT.md). Every write endpoint validates its
body; passwords need at least 8 characters with a letter and a number.

## Demo accounts

Password for all of them: `Demo1234!`

| Email | Who |
|---|---|
| demo@finder.app | Alex Rivera, identity verified, has posts, chats, saved items and notifications |
| sara@finder.app | Sara Ahmed, chats with Alex about the wallet |
| omar@finder.app | Omar Haddad |
| lina@finder.app | Lina Park |

Accounts migrated from Firebase (the other rows in `database.sqlite`) all have the
password `FinderChangeMe123!`.

`npm run seed` is idempotent: it replaces every `seed-*` row and re-hashes the demo
passwords, and leaves everything else untouched.

## Demo mode (no SMTP)

When `SMTP_HOST`, `SMTP_USER` and `SMTP_PASS` are not set:

- signups are verified immediately (no e-mail can be delivered);
- the e-mail verification endpoint accepts any code;
- password-reset codes are printed to the server console
  (`[PASSWORD RESET CODE] Email: …, Code: …`).

Set the SMTP variables to get real verification and reset e-mails.

## Running the app against this backend

Web:

```bash
flutter run -d chrome --web-port 5179
```

Physical Android phone over USB (no Wi-Fi needed):

```bash
adb reverse tcp:3001 tcp:3001
flutter run -d <device-id> --dart-define=API_URL=http://localhost:3001
```

Android emulator: `SEED_PUBLIC_URL=http://10.0.2.2:3001 npm run seed` so demo image
links resolve from inside the emulator.

## Identity verification

Users upload ID front/back and a live selfie through `POST /profile/verification/upload`
(stored privately under `PRIVATE_DIR`) and submit them with `POST /profile/verification`.
Accounts listed in `ADMIN_EMAILS` review the queue in the app (Profile → Admin · Review queue)
or through the `/admin/verification` routes; approving sets `users.identity_verified`, rejecting
records a reason. Both outcomes notify the user (in-app and push).

## Push notifications

`notify()` stores a row and, when `FIREBASE_SERVICE_ACCOUNT` is set, pushes it through Firebase
Cloud Messaging to every device registered with `POST /profile/push-token`. See docs/DEPLOYMENT.md.

## Endpoints

| Area | Routes |
|---|---|
| Auth | `POST /auth/signup`, `POST /auth/login`, `GET /auth/me`, `POST /auth/google-login`, `POST /auth/forgot-password`, `POST /auth/verify-reset-code`, `POST /auth/reset-password`, `POST /auth/verify-email`, `POST /auth/resend-verification` |
| Posts | `GET /posts`, `GET /posts/:id`, `GET /posts/:id/similar`, `POST /posts`, `PUT /posts/:id`, `DELETE /posts/:id`, `POST /posts/:id/report` |
| Chats | `GET /chats`, `POST /chats/initiate`, `GET /chats/:id/messages`, `POST /chats/:id/messages` (`text` and/or `imageUrl`) |
| Profile | `GET/PUT /profile`, `GET /profile/:userId`, `GET/PUT /profile/privacy`, `GET/PUT /profile/notification-settings`, `GET/POST /profile/verification`, `GET/POST/DELETE /profile/blocked`, `GET/POST/DELETE /profile/saved` |
| Notifications | `GET /notifications`, `PUT /notifications/read-all`, `PUT /notifications/:id/read` |
| Users | `GET /users/search?q=` |
| Uploads | `POST /uploads` (multipart `file` + `folder` = `posts`/`avatars`/`chat`/`verification`) → `{url}`; files served from `/uploads/…` |
| Account | `DELETE /profile` (`{password}` or `{confirm:"DELETE"}` for Google accounts) |
| Push | `POST /profile/push-token`, `DELETE /profile/push-token` |
| Verification | `GET /profile/verification`, `POST /profile/verification/upload` (multipart `file` + `slot`), `POST /profile/verification`, `GET /profile/verification/file/:slot` |
| Admin | `GET /admin/verification?status=`, `GET /admin/verification/:id`, `GET /admin/verification/:id/file/:slot`, `POST /admin/verification/:id/approve`, `POST /admin/verification/:id/reject` (admins from `ADMIN_EMAILS`) |
| Geo | `GET /geo/search?q=` (places for a query), `GET /geo/reverse?lat=&lon=` (address at a point); proxied to OpenStreetMap Nominatim, cached, 60 req/min per user |
| Legal | `GET /legal/privacy`, `GET /legal/terms` |

All routes except `/auth/*` and `/health` need `Authorization: Bearer <token>`.
Blocked users cannot see each other's posts, conversations or profiles, and cannot
start or continue chats. Profile privacy settings control what other users see.
