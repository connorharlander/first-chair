-- First Chair Prep, change 004: your own exercises in the library.
-- Run this once in Supabase → SQL Editor → New query → Run.

-- One row per exercise you add. Deleted exercises stay as deleted = true so other devices learn about the delete.
create table if not exists public.custom_exercises (
  user_id    uuid        not null default auth.uid() references auth.users (id) on delete cascade,
  id         text        not null,
  data       jsonb       not null,
  deleted    boolean     not null default false,
  updated_at timestamptz not null default now(),
  primary key (user_id, id),
  constraint custom_id_length check (char_length(id) <= 40),
  constraint custom_size check (pg_column_size(data) < 4000)
);

alter table public.custom_exercises enable row level security;

-- Each signed-in person can see and change only their own exercises.
create policy "read own exercises"   on public.custom_exercises for select to authenticated using (auth.uid() = user_id);
create policy "insert own exercises" on public.custom_exercises for insert to authenticated with check (auth.uid() = user_id);
create policy "update own exercises" on public.custom_exercises for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "delete own exercises" on public.custom_exercises for delete to authenticated using (auth.uid() = user_id);
