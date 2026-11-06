# SC Delivery Board

The AppliedAI Solutions Consulting delivery board: projects, phases, weekly health check-ins, OKRs and team updates. It is a single web page hosted on Vercel, with data and Google sign-in handled by Supabase. Only @aaico.com and @appliedai.com Google accounts can open it.

## What's in this folder

| File | What it is |
|---|---|
| `index.html` | The board itself. No build step. |
| `config.js` | Your Supabase URL and anon key. The only file you must edit. |
| `favicon.png` | Browser tab icon (AppliedAI mark). |
| `vercel.json` | Hosting settings for Vercel. |
| `supabase/schema.sql` | Creates the database table, the access rules and live updates. |
| `supabase/seed.sql` | The board's data as of 6 Nov 2026: 14 people, 6 projects, 12 OKRs, 5 updates. |

## Setup, about 30 minutes, once

### 1. Create the Supabase project
1. Sign in at supabase.com and create a new project. Pick a region close to most of the team (Frankfurt or Mumbai for the UAE team).
2. Open **SQL Editor > New query**, paste all of `supabase/schema.sql`, and click **Run**.
3. Open another new query, paste all of `supabase/seed.sql`, and click **Run**.
4. Go to **Project Settings > API** and copy the **Project URL** and the **anon public** key.

### 2. Turn on Google sign-in
1. In Google Cloud Console, open **APIs & Services > OAuth consent screen**.
   - If @aaico.com and @appliedai.com are in the same Google Workspace, choose **Internal**.
   - If they are separate Workspaces, choose **External** and publish the app. The database still blocks every other domain.
2. Open **Credentials > Create credentials > OAuth client ID**, type **Web application**.
3. Under **Authorized redirect URIs** add `https://YOUR-PROJECT-REF.supabase.co/auth/v1/callback` (your Project URL plus `/auth/v1/callback`).
4. Copy the client ID and client secret.
5. In Supabase, open **Authentication > Sign In / Providers > Google**, switch it on, paste the client ID and secret, and save.

### 3. Add your keys
Edit `config.js` and replace the two placeholder values with the Project URL and anon key from step 1. The anon key is safe to commit: the database rules decide who can read or write.

### 4. Put the code on GitHub
Create a **private** repository (for example `sc-delivery-board`) and upload every file in this folder, keeping the `supabase` folder. Uploading through the GitHub website works fine.

### 5. Deploy on Vercel
1. In Vercel, click **Add New > Project** and import the GitHub repository.
2. Framework preset: **Other**. Leave the build command and output directory empty.
3. Click **Deploy** and copy the address Vercel gives you, for example `https://sc-delivery-board.vercel.app`.

### 6. Tell Supabase where the board lives
In Supabase, open **Authentication > URL Configuration**:
- **Site URL:** your Vercel address.
- **Redirect URLs:** add `https://your-vercel-address/**`. Add your custom domain too if you set one up later.

### 7. Check it
- Open the Vercel address and sign in with your AAICO Google account. You should see all six projects.
- Try a personal Gmail account. It should be turned away and see no data.
- Open the board in two browsers and change a rating in one; it appears in the other within a second or two.

## Day to day
- **Changing the page:** edit a file in GitHub. Vercel redeploys automatically within a minute.
- **Adding an email domain:** change the pattern in two places, `is_team_member()` in `supabase/schema.sql` (then re-run it in the SQL Editor) and `ALLOWED` near the bottom of `index.html`.
- **Phases, health criteria and check-in length:** the "Board settings" block at the top of the script in `index.html`.

## Things to know
- **Free Supabase projects pause after 7 days without use.** Weekly check-ins normally keep it awake. If the team takes a break, open the Supabase dashboard and click Restore. The Pro plan never pauses and adds daily backups.
- **Backups:** the free plan has no automatic backups. Use **Import & sources > Export** to copy the data into a Google Sheet now and then, or move to Pro.
- **The Claude version of the board** stays where it was. The data here is a snapshot from 6 Nov 2026; after the team switches to the Vercel board, stop editing the Claude one so the two don't drift apart.
