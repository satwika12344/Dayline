# Dayline: AI Daily Task Manager (full stack)

| Layer | Tech |
|---|---|
| Frontend | Vanilla HTML/CSS/JS single page (`public/index.html`), no build step |
| API | Node.js 20+ and Express 5, REST + JSON |
| Database | SQLite via `better-sqlite3` (WAL mode), file `dayline.db` |
| Auth | Email + password (bcrypt), JWT in an httpOnly, SameSite=Lax cookie |
| Reminders | Server scheduler (every 20 s, per-user time zone) pushing Server-Sent Events |
| AI chatbot | Anthropic Claude via `@anthropic-ai/sdk`, key stays on the server |
| Hardening | Rate limits on auth and AI routes, input validation, CSP headers |

## Run it

```bash
npm install
cp .env.example .env        # then set JWT_SECRET and (optionally) ANTHROPIC_API_KEY
npm start                   # http://localhost:3000
```

Without `ANTHROPIC_API_KEY` everything works except the AI replies; the chat falls back to simple rule-based planning in the browser.

Docker: `docker build -t dayline . && docker run -p 3000:3000 -v dayline-data:/app/data -e JWT_SECRET=... -e ANTHROPIC_API_KEY=... dayline`

## API

| Method and path | Purpose |
|---|---|
| `POST /api/auth/register` `{email,password,tz}` | Create account, sets session cookie |
| `POST /api/auth/login` `{email,password,tz}` | Sign in |
| `POST /api/auth/logout` | Clear session |
| `GET /api/me` | Current user |
| `GET /api/tasks?from=YYYY-MM-DD` | List your tasks from a date |
| `PUT /api/tasks/:id` | Create or update a task (validated, owner-checked upsert) |
| `DELETE /api/tasks/:id` | Delete a task |
| `GET /api/events` | SSE stream; emits `reminder` events |
| `POST /api/assistant` `{message,date,now,history}` | Claude returns `{reply, schedule[], add[]}`, validated server-side |

## Production notes

- Serve over HTTPS and set `NODE_ENV=production` (secure cookies) and `TRUST_PROXY=1` behind a proxy.
- SQLite suits one server instance. For several instances, move to Postgres and replace the in-memory SSE client map with Redis pub/sub.
- Reminders fire only while the user has the page open (SSE connected); otherwise they stay pending until the next visit. Web Push would remove that limit.
- The CSP allows inline scripts because the page is one file. Split the CSS and JS into files and drop `'unsafe-inline'` for a stricter policy.
- Not included: password reset, email verification, per-user quotas, automated tests.
