# Post review, AI pre-check and translations

Every new post waits for an admin. The AI (Google AI Studio, Gemini) runs
first and only advises; a person decides.

## Lifecycle

| status | who sees it | how it gets there |
|---|---|---|
| `pending` | owner, admins | `POST /posts`; editing a `rejected` post |
| `active` | everyone | `POST /admin/posts/:id/approve`; owner reopens a returned/archived post |
| `resolved` | everyone (badge "Returned") | owner marks returned |
| `rejected` | owner, admins | `POST /admin/posts/:id/reject {reason}` |
| `expired` | owner, admins | sweeper, 90 days after creation while still `active` |

`GET /posts` without `status` returns `active`/`resolved` for other people and
every status for `ownerId = me`. `GET /posts/:id`, the share page `/p/:id`,
saved items, reports, "similar" and matching only ever touch public posts.
Matching (`lib/matching.js`) runs when a post is approved, not when it is created.

## Pipeline (`backend/lib/moderation.js`)

`POST /posts` answers 201 immediately, then `processNewPost(id)`:

1. `translatePost` → `source_lang`, `title_en/ar/ckb`, `description_en/ar/ckb`,
   `translation_status` (`done` | `failed` | `skipped` when no key).
2. `moderatePost` (text + the post's own image read from `uploads/posts`) →
   `ai_risk` 0-100, `ai_reasons` JSON, `ai_checked_at_ms`.
3. One notification per admin (`type: update`, `data.type: post_review`).

The sweeper (every 5 min, `startSweeper()` in `server.js`) retries failed or
missing translations (max 3 attempts, 20 rows per run), scores pending posts
that were never checked (server restarted mid-way) and archives old posts.

Nothing in the pipeline can block a user: every AI call has a 12 s timeout,
one retry, zod-validated output and resolves `null` on failure.

## Viewer language

The app sends `Accept-Language: en|ar|ckb`. `mapPost(row, {lang})` returns the
translation in that language when it exists and the original otherwise, plus
`originalTitle`, `originalDescription`, `sourceLang`. Edit screens always edit
the original. Old app builds send no header and get the original text.

## Gemini key

- `GEMINI_API_KEY` env var, **or** paste it in the app: Admin console → AI
  assistant (stored as `private/gemini-key.json`, verified with one request).
- `GEMINI_MODEL` (default `gemini-2.5-flash-lite`), `AI_TIMEOUT_MS` (12000),
  `AI_DISABLED=true` as a kill switch.
- Cost: at most two calls per new post (translation ≈ 2k output tokens, risk
  check ≈ 256). Roughly a cent per post on the flash-lite model.

## Admin

- Queue: Admin console → Posts (opens on **Pending**, oldest first). The sheet
  shows the photo, the text in the admin's language plus the original, the
  risk meter (green < 30, amber < 70, red ≥ 70) and the model's reasons.
- Approve → owner notified "Your post is live", matching runs.
- Reject (reason required, 3-300 chars) → owner notified with the reason and
  sees "Not approved" with **Edit & resubmit** in My posts; the edited post
  returns to the queue with a fresh check.
- `POST /admin/posts/:id/status` refuses pending/rejected posts (409).
