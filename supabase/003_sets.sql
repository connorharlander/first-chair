-- First Chair Prep, change 003: log each set (weight, reps, optional RPE).
-- Run this once in Supabase → SQL Editor → New query → Run.

-- One object per day: { exerciseId: [ {w, r, rpe, ok, t}, ... ] }
alter table public.workout_log add column if not exists sets jsonb not null default '{}'::jsonb;

-- Size limit so one day cannot store a very large object.
alter table public.workout_log add constraint sets_size check (pg_column_size(sets) < 16000);
