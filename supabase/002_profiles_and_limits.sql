-- First Chair Prep, change 002: sync settings across devices, and size limits.
-- Run this once in Supabase → SQL Editor → New query → Run.

-- One row per person: their plan settings (first day, sport, gear, days, minutes, experience, injuries).
create table if not exists public.profiles (
  user_id    uuid        primary key default auth.uid() references auth.users (id) on delete cascade,
  data       jsonb       not null,
  updated_at timestamptz not null default now(),
  constraint profile_size check (pg_column_size(data) < 4000)
);

alter table public.profiles enable row level security;

-- Each signed-in person can see and change only their own row.
create policy "read own profile"   on public.profiles for select to authenticated using (auth.uid() = user_id);
create policy "insert own profile" on public.profiles for insert to authenticated with check (auth.uid() = user_id);
create policy "update own profile" on public.profiles for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "delete own profile" on public.profiles for delete to authenticated using (auth.uid() = user_id);

-- Limits so one account cannot store very large rows.
alter table public.workout_log add constraint note_length check (char_length(note) <= 2000);
alter table public.workout_log add constraint done_count  check (cardinality(done) <= 60);
