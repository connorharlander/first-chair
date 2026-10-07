-- First Chair Prep: one row per user per day.
-- Run this once in Supabase → SQL Editor → New query → Run.

create table if not exists public.workout_log (
  user_id    uuid        not null default auth.uid() references auth.users (id) on delete cascade,
  day        date        not null,
  done       text[]      not null default '{}',
  rpe        smallint    check (rpe between 1 and 10),
  note       text        not null default '',
  updated_at timestamptz not null default now(),
  primary key (user_id, day)
);

alter table public.workout_log enable row level security;

-- Each signed-in person can see and change only their own rows.
create policy "read own log"   on public.workout_log for select to authenticated using (auth.uid() = user_id);
create policy "insert own log" on public.workout_log for insert to authenticated with check (auth.uid() = user_id);
create policy "update own log" on public.workout_log for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "delete own log" on public.workout_log for delete to authenticated using (auth.uid() = user_id);
