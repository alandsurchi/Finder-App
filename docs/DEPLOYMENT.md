# Deploying Finder

## 1. Backend

The API is a single Node process. It needs Postgres, a JWT secret, SMTP for e-mails and a volume for photos.

### Environment variables

| Variable | Required | Notes |
|---|---|---|
| `NODE_ENV` | yes | `production` |
| `PORT` | no | Provided by the host, defaults to 3001 |
| `DATABASE_URL` | yes | `postgres://…`; append `?sslmode=disable` for local Docker only |
| `JWT_SECRET` | yes | ≥ 32 random chars. `node -e "console.log(require('crypto').randomBytes(48).toString('hex'))"` |
| `CORS_ORIGINS` | web only | Comma-separated origins of the web app, e.g. `https://app.finder.app` |
| `PUBLIC_URL` | yes | Public https URL of the API (used in seed links and legal pages) |
| `RESEND_API_KEY` or `SMTP_*` | yes | Without e-mail settings signups auto-verify (demo mode). Railway trial/hobby plans block outbound SMTP, so use Resend's HTTPS API: either `RESEND_API_KEY=re_…`, or `SMTP_HOST=smtp.resend.com` + `SMTP_PASS=re_…` (detected automatically). `SMTP_FROM` sets the sender; it must be on a domain verified in Resend, otherwise only the Resend account owner receives mail |
| `UPLOADS_DIR` | yes | Directory on a persistent volume for photos, e.g. `/data/uploads` (the Dockerfile default) |
| `SUPPORT_EMAIL` | no | Shown in error texts |
| `RATE_LIMIT_*` | no | Per 15 minutes per IP: general 600, auth 30, reset 5 |

### Railway (recommended, this repo is already set up for it)

Current production deployment: project **jubilant-respect** → service **Finder-App**, URL `https://finder-app-production-7c49.up.railway.app`, deploying `backend/` from branch `redesign/beacon-ui` on every push. Do not put a `VOLUME` instruction in the Dockerfile; Railway rejects it and manages volumes itself.

1. New project → Deploy from GitHub → root directory `backend`. `railway.json` selects the Dockerfile and `/health`.
2. Add a Postgres database; Railway injects `DATABASE_URL`. Add a Volume to the API service mounted at `/data`.
3. Set the variables above in the service settings. Generate a domain (or attach `api.finder.app`).
4. First deploy creates the tables automatically (`initDb`). Do **not** run `npm run seed` in production; it refuses unless `SEED_FORCE=1`.

Any Docker host works the same way: `docker build -t finder-api backend && docker run -p 3001:3001 --env-file backend/.env finder-api`.

### Local production-like stack

```bash
cd backend
docker compose up --build          # Postgres + API on http://localhost:3001
docker compose exec api node seed.js   # optional demo data
```

### Health and logs

`GET /health` returns `{status, database, uploads}`. Every request is logged as `METHOD path status ms`. Account deletions are logged as `[ACCOUNT DELETED] email`.

## 2. Photo storage

Photos are stored by the API itself under `UPLOADS_DIR` and served from `/uploads/<folder>/<file>`. In Railway add a **Volume** to the API service mounted at `/data`; the Dockerfile already sets `UPLOADS_DIR=/data/uploads`. Without a volume, uploads are lost on every deploy.

## 3. The app

Every release build must be given the API URL:

```bash
flutter build apk --release --dart-define=API_URL=https://api.finder.app
flutter build appbundle --release --dart-define=API_URL=https://api.finder.app
flutter build web --release --dart-define=API_URL=https://api.finder.app
```

A release build without `API_URL`, or with an `http://` URL, shows a configuration error screen instead of starting.

### Android signing

```bash
keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
cp android/key.properties.example android/key.properties   # fill in the passwords
```

`android/key.properties` and `*.jks` are git-ignored. Back the keystore up somewhere safe: losing it means you can never update the app on Google Play. Without `key.properties`, release builds fall back to the debug key so local `flutter run --release` still works.

### Google sign-in

The application id is now `com.finderapp.finder`. Google OAuth Android clients are bound to package name + signing certificate, so:

1. Get the SHA-1 of the upload keystore: `keytool -list -v -keystore android/upload-keystore.jks -alias upload`.
2. Google Cloud Console → Credentials → create an **Android** OAuth client with package `com.finderapp.finder` and that SHA-1 (add the debug keystore SHA-1 as a second client for development).
3. Add the new client id to the `audience` list in `backend/routes/auth.js` (google-login).
4. For web, set the web client id in `lib/services/auth/railway_auth_service.dart` and add the web app origin to the client's authorised JavaScript origins.

### Web hosting

`flutter build web --release --dart-define=API_URL=…` produces `build/web`. Serve it from any static host (Netlify, Vercel, Cloudflare Pages, Firebase Hosting) and add its origin to `CORS_ORIGINS` on the API.

## 4. Store listing requirements already covered

- Privacy policy URL: `https://<api>/legal/privacy`
- Terms URL: `https://<api>/legal/terms`
- In-app account deletion: Profile → Privacy & safety → Delete account
- Launcher icons: generated into Android mipmaps, iOS AppIcon set and web icons from `assets/branding/icon-1024.png`
