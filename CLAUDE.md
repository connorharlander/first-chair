# First Chair Prep

A phone-first web app (PWA) for a 10-week ski conditioning plan, Oct 8 – Dec 15, 2026.
Owner: Connor. This is his first app, and the repo is public as a portfolio piece. Explain
changes in plain language and keep commits small and clear.

## Stack
- Static files only. No build step, no framework, no package.json.
- Hosting: Vercel, auto-deploys on every push to `main`. Live at https://first-chair-taupe.vercel.app
- Data and auth: Supabase (project `qnazlsqsrtjbsovhakal`). Email + password sign-in. One user. Sign-ups are off.
- Supabase JS is loaded from jsDelivr, pinned to `@supabase/supabase-js@2.110.0`.

## Files
- `index.html`: the whole app. CSS at the top; one inline script holds all data and logic.
  - `S`: research sources. `E`: exercise library (name, category, how, why, sources).
  - `VID`: one YouTube video ID per exercise.
  - `PH`: the six phases and doses. `TPL`: session templates. `plan(date)` builds a day.
  - `PROFILE` (localStorage `firstchair.profile`): first day, end date, days per week, minutes, gear. The plan, phase dates, calendar and copy all come from it. `DEFAULT_PROFILE` is Connor's original plan and must keep producing it exactly.
  - Onboarding shows only when a device has no profile and no logged workouts. Settings view (`set`) edits the profile; changes save and reload.
  - Snowboard (`PROFILE.sport==="board"`): same training; `BOARD_WHY` and `BOARD_PRINCIPLES` swap in riding-specific reasons, "Ride sim" replaces "Ski sim", and shoulder work (`extrot`) is added weekly. Sources: kim2012, chauffard2026, vernillo2018, platzer2009. The audience is experienced riders: no gear or beginner safety tips. Snowboard training research is thin; do not claim more than these sources support.
  - Sync: local-first in `localStorage`, pushed to the `workout_log` table by `sync()`.
- `config.js`: Supabase URL and **publishable** key (safe to be public).
- `sw.js`: offline cache. **Change `VERSION` on every deploy that changes app files**, or phones keep the old version.
- `manifest.webmanifest`, `icons/`: home-screen install.
- `supabase/schema.sql`: table + Row Level Security. If the schema changes, update this file and tell Connor to run the change in the Supabase SQL Editor.
- `vercel.json`: no-cache headers for `sw.js` and `config.js`.

## Rules
- Never commit a Supabase secret key (`sb_secret_...`) or a service_role key, or any password.
- Do not add a build step or framework unless Connor asks.
- Keep exercise science claims tied to a source in `S`. Do not invent citations.
- Copy style: plain, short sentences (Simplified Technical English). No filler.
- Test before pushing: run `python3 -m http.server` and open the page, check the console for errors, and check phone width (390px).
- After pushing, tell Connor what changed and that Vercel will be live in about a minute.
