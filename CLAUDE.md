# First Chair Prep

A phone-first web app (PWA) for a 10-week ski conditioning plan, Oct 8 – Dec 15, 2026.
Owner: Connor. This is his first app, and the repo is public as a portfolio piece. Explain
changes in plain language and keep commits small and clear.

## Stack
- Static files only. No build step, no framework, no package.json.
- Hosting: Vercel, auto-deploys on every push to `main`. Live at https://first-chair-taupe.vercel.app
- Data and auth: Supabase (project `qnazlsqsrtjbsovhakal`). Email + password accounts with email confirmation. Sign-ups are controlled in the Supabase dashboard (Authentication settings), not in code.
- Supabase JS is loaded from jsDelivr, pinned to `@supabase/supabase-js@2.110.0`.

## Files
- `index.html`: the whole app. CSS at the top; one inline script holds all data and logic.
  - `S`: research sources. `E`: exercise library (name, category, how, why, sources).
  - `VID`: one YouTube video ID per exercise.
  - `PH`: the six phases and doses. `TPL`: session templates. `plan(date)` builds a day.
  - `PROFILE` (localStorage `firstchair.profile`): first day, end date, sport, gear, days per week, experience, injuries, units, lifts. There is no session time limit: Connor asked that no exercise is ever cut for time. The plan, phase dates, calendar and copy all come from it. `DEFAULT_PROFILE` is Connor's original plan and must keep producing it exactly.
  - Experience (`exp`: new/some) and injuries (`inj`: knee/back/shoulder/wrist) adjust doses and swap or drop exercises (`INJURY`). They are not treatment; keep the physio note.
  - `parseDose(item)` reads a dose string into `{kind, sets, reps, secs, meters, side, rpe, rest, note}`. Kinds: reps, hold, carry, rounds, intervals, single (warm-up, cardio, cool-down). Set tracking and the rest timer build on this. If you add a new dose wording, add it to the parser.
  - Sets: `entry(day).sets[exerciseId]` is a list of `{w, wu, r, rpe, ok, t, ed}` (weight, weight unit, reps, optional RPE, done, time, hand-edited). `setsFor` fills rows (saved values, else last logged weight and planned reps); `putSet` saves a row and keeps `done` in step (all sets ok = exercise done). `LOAD` lists exercises that take a weight. Synced in the `workout_log.sets` column (change 003); sync falls back without it if the column is missing.
  - Rest timer: `T` in localStorage `fc.timer` (`{phase: rest|work|done, end, total, label, sub}`), counted from the end time so it survives a locked phone or reload. Rest times cite grgic2018 and schoenfeld2016.
  - Suggested weights: `suggest(day,item)` = estimated max ÷ (1 + (reps + 10 − RPE)/30), rounded (barbell 5 lb/2.5 kg, min empty bar; dumbbells 5 lb/2 kg). Estimated max (`estimate`) comes from, in order: that exercise's last logged session (rated sets first, else the dose's target RPE), the onboarding numbers for anchor lifts (`ANCHORS`, assumed 1 rep in reserve), then `REL` starting guesses from a related lift (rules of thumb, labelled as guesses). Accessories without an RPE target use RPE 7. No suggestion for bodyweight, holds, carries or `none` gear. Sources: reynolds2006, zourdos2016, helms2016. `PROFILE.lifts` holds the onboarding numbers; `PROFILE.units` is lb or kg.
  - Core videos: `CORE_VIDS` (YouTube IDs checked for 5–15 min length and embedding) and `CORE_PLAN` (session → video, start or end). `addCore` adds one `core` item per day. `addCoolDown` then adds couch stretch (2 × 45 s /side) and foam rolling (5 min) to any workout missing them; first-chair day is skipped. Heavy-lift and jump-landing days put it last (curi2024, vermeulen2023); on-ramp, deload, taper and special days use a 5-min warm-up at the start. Played in `#vsheet` (youtube-nocookie embed) outside `#app` so re-renders do not stop it. Only add videos you have checked exist and allow embedding.
  - What's new: `CHANGELOG` (newest first, plain language, unique `id`). The Day view shows a one-time card for the newest entry to existing users; the `news` view lists them all.
  - Workout finish: start and finish times live in `entry(day).sets._meta` (`st`, `fin`) so they sync without a new column; code that loops `sets` by exercise id ignores `_meta`. `setMeta` records the start on the first check-off. `workoutStats` drives the summary sheet (`#sumsheet`) and the day card; weight lifted = weight × reps × 2 for `TWO_DB` lifts × 2 for per-side sets.
  - Timers run a list of parts (`runParts`) with 5 s switches; `itemParts` reads stretch and minute doses; holds with `/side` count both sides. Completed set exercises fold (`state.unfold` reopens them).
  - Added sets: rows beyond the planned count carry `x:true`; `addSet` copies the last row, `removeSet` only removes added rows, `saveRows` keeps `done` in step. Counts in timers use the real row count.
  - Exercises added to a day: `sets._meta.add` (`{id, dose, m}`), merged by `addYours` before the cool-down and tagged `added`. Clear `planCache` after changing them.
  - Your own exercises: `CUSTOM` (localStorage `firstchair.custom`, synced to `custom_exercises`, change 004, soft-delete via `deleted`). `applyCustom` merges them into `E`/`LOAD`/`VID` with `custom:true`; text goes through `clean()` so it cannot become HTML. They show notes, never a research 'Why'.
  - The day row (`.dayhd`) is first in the Day view and sticks under the tab bar (`--dockh`, measured).
  - Onboarding shows only when a device has no profile and no logged workouts. Settings view (`set`) edits the profile; changes save and reload.
  - Snowboard (`PROFILE.sport==="board"`): same training; `BOARD_WHY` and `BOARD_PRINCIPLES` swap in riding-specific reasons, "Ride sim" replaces "Ski sim", and shoulder work (`extrot`) is added weekly. Sources: kim2012, chauffard2026, vernillo2018, platzer2009. The audience is experienced riders: no gear or beginner safety tips. Snowboard training research is thin; do not claim more than these sources support.
  - Sync: local-first in `localStorage`, pushed to the `workout_log` table by `sync()`. Settings sync through `profiles` in `syncProfile()`: the newest copy (`PROFILE.u`) wins, and a newer copy from another device reloads the plan. A missing `profiles` table is skipped quietly.
  - Account view: sign in, create account, forgot password, set new password (`PASSWORD_RECOVERY`), and delete synced data.
- `config.js`: Supabase URL and **publishable** key (safe to be public).
- `sw.js`: offline cache. **Change `VERSION` on every deploy that changes app files**, or phones keep the old version.
- `manifest.webmanifest`, `icons/`: home-screen install.
- `supabase/schema.sql`: tables + Row Level Security (full current schema). Numbered files like `002_profiles_and_limits.sql` are one-time changes Connor runs in the SQL Editor. If the schema changes, update this file and tell Connor to run the change in the Supabase SQL Editor.
- `vercel.json`: no-cache headers for `sw.js` and `config.js`.

## Rules
- Never commit a Supabase secret key (`sb_secret_...`) or a service_role key, or any password.
- Do not add a build step or framework unless Connor asks.
- Keep exercise science claims tied to a source in `S`. Do not invent citations.
- Copy style: plain, short sentences (Simplified Technical English). No filler.
- Test before pushing: run `python3 -m http.server` and open the page, check the console for errors, and check phone width (390px).
- For every update people can see, add an entry at the top of `CHANGELOG` in the same commit.
- After pushing, tell Connor what changed and that Vercel will be live in about a minute.
