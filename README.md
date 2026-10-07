# First Chair Prep

A home-screen app for a 10-week ski conditioning plan (Oct 8 – Dec 15, 2026).
Static files only: no build step. Vercel hosts it. Supabase stores your log and syncs it across devices.

## Files

| File | What it does |
|---|---|
| `index.html` | The whole app (plan, views, sync) |
| `config.js` | Your Supabase URL and key. **Edit this.** |
| `manifest.webmanifest` | App name, icon, full-screen mode |
| `sw.js` | Offline cache |
| `icons/` | Home-screen icons |
| `supabase/schema.sql` | Database table and security rules |
| `vercel.json` | Cache headers |

## 1. Set up Supabase (10 min)

1. Go to supabase.com → **New project**. Pick a name and a region near you (for example, West US). Save the database password somewhere safe.
2. Open **SQL Editor → New query**. Paste all of `supabase/schema.sql` and click **Run**.
3. Open **Authentication → Emails → Magic Link** (the template name can be "Magic link" or "Confirm sign in"). Replace the body with:
   ```html
   <h2>Your First Chair code</h2>
   <p>Enter this code in the app: <strong>{{ .Token }}</strong></p>
   ```
   The app signs you in with a code, not a link. A link opens Safari, and on iPhone a home-screen app does not share sign-in with Safari.
4. Open **Project Settings → API**. Copy the **Project URL** and the **anon public** key (or the **publishable** key). Paste both into `config.js`.

## 2. Deploy to Vercel (5 min)

**Option A: GitHub (best for updates)**
1. Make a new GitHub repo and push this folder to it.
2. On vercel.com → **Add New → Project** → import the repo.
3. Framework preset: **Other**. Leave the build command and output directory empty. Click **Deploy**.
4. Each later `git push` deploys again.

**Option B: Vercel CLI**
```bash
cd first-chair-app
npx vercel        # first time: log in and accept the defaults
npx vercel --prod
```

## 3. Finish Supabase auth settings

1. **Authentication → URL Configuration → Site URL**: paste your Vercel URL (for example `https://first-chair.vercel.app`).
2. Open the app, tap **Sign in to sync**, and sign in once with your email.
3. Then go to **Authentication → Sign In / Providers** and turn **off** "Allow new users to sign up". Now only you can use your database.

## 4. Install on your phone

- **iPhone:** open your Vercel URL in **Safari** → Share → **Add to Home Screen**. Open the app from the icon and sign in again (the home-screen app has its own storage).
- **Android:** open it in Chrome → menu → **Install app**.

## How sync works

- Every tap saves on the device first, so the app works with no signal.
- When you are online and signed in, changes go to Supabase about one second later. The app also syncs when you open it or come back to it.
- If the same day changes on two devices, the newest change wins.

## Updating the app

1. Edit the files.
2. In `sw.js`, change `VERSION` (for example `fc-v1` → `fc-v2`).
3. Deploy. Close the app fully and open it again to load the new version.

## Limits to know

- The free Supabase email sender allows only a few emails per hour. That is enough for one person.
- Free Supabase projects pause after about a week with no activity. Daily use keeps it awake. If it pauses, restore it from the dashboard. Your data stays.
