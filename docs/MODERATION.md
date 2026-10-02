# Post review, AI pre-check and translations

Every new post waits for an admin. The AI (any supported provider, see below)
runs first and only advises; a person decides.

## Lifecycle

| status | who sees it | how it gets there |
|---|---|---|
| `pending` | owner, admins | `POST /posts` by a normal user; editing a `rejected` post |
| `active` | everyone | `POST /posts` by an admin (skips the queue, matching starts at once); `POST /admin/posts/:id/approve` (from `pending` or `rejected`); owner reopens a returned/archived post |
| `resolved` | everyone (badge "Returned") | owner marks returned |
| `rejected` | owner, admins | `POST /admin/posts/:id/reject {reason}` from `pending`, or from `active`/`resolved`/`expired` to take a post down |
| `expired` | owner, admins | sweeper, 90 days after creation while still `active` |

`GET /posts` without `status` returns `active`/`resolved` for other people and
every status for `ownerId = me`. `GET /posts/:id`, the share page `/p/:id`,
saved items, reports, "similar" and matching only ever touch public posts.
Matching (`lib/matching.js`) runs when a post is approved, not when it is created.

## Pipeline (`backend/lib/moderation.js`)

`POST /posts` answers 201 immediately, then `processNewPost(id)`:

1. `translatePost` → `source_lang`, `title_en/ar/ckb`, `description_en/ar/ckb`,
   `translation_status` (`done` | `failed` | `skipped` when no key; `skipped`
   rows are picked up by the sweeper as soon as a key is saved).
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

## AI provider and key

Any of four providers works; the admin picks one in the app:

| provider | default model | notes |
|---|---|---|
| Google AI Studio | `gemini-2.5-flash-lite` | cheapest; key from aistudio.google.com |
| OpenAI | `gpt-4o-mini` | `max_completion_tokens`, JSON mode |
| Anthropic | `claude-haiku-4-5-20251001` | Messages API, images as base64 blocks |
| Custom (OpenAI-compatible) | none, required | base URL required: OpenRouter, Groq, DeepSeek, Mistral, Ollama… |

- **In the app (recommended):** Admin console → AI assistant → provider, model,
  key (and base URL for custom) → Save. The server verifies the key with one
  request, stores the settings in `app_settings` (key sealed with AES-256-GCM
  under `JWT_SECRET`, so a database dump does not reveal it) and immediately
  translates and scores the backlog of posts (`sweepNow`, 50 per pass). The
  settings survive redeploys and apply to every user at once. Only admins can
  read or change them (`requireAdmin`); the key itself is never returned.
- **Env fallback:** `GEMINI_API_KEY`, `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, or
  `AI_PROVIDER=custom` + `AI_API_KEY` + `AI_BASE_URL`; `AI_MODEL` overrides the
  default model. Settings saved in the app take precedence.
- `AI_TIMEOUT_MS` (12000), `AI_DISABLED=true` as a kill switch.
- Routes: `GET /admin/ai` (status + `pendingTranslations`, `unscoredPending`),
  `POST /admin/ai {provider, model?, key, baseUrl?}`, `DELETE /admin/ai`.
  `GET/POST /admin/ai-key` remain as aliases for the previous app build.
- Cost: at most two calls per new post (translation ≈ 2k output tokens, risk
  check ≈ 256). Roughly a cent per post on the cheapest models.

## Admin

- Queue: Admin console → Posts (opens on **Pending**, oldest first). The sheet
  shows the photo, the text in the admin's language plus the original, the
  risk meter (green < 30, amber < 70, red ≥ 70) and the model's reasons.
- Approve → owner notified "Your post is live", matching runs.
- Reject (reason required, 3-300 chars) → owner notified with the reason and
  sees "Not approved" with **Edit & resubmit** in My posts; the edited post
  returns to the queue with a fresh check.
- `POST /admin/posts/:id/status` refuses pending/rejected posts (409).
