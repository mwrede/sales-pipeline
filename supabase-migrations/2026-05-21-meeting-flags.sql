-- 2026-05-21: persist the "not attended" + "follow-up" flags on the
-- normalized meetings table. The JSONB pipeline_blob already stores
-- these as c.notAttendedDates / c.followUpDates per company, but the
-- queryable meetings table didn't have its own columns. Adding them
-- here so anyone querying public.meetings sees the same picture the UI
-- shows, and so follow-up totals on the Overview can come straight from
-- SQL instead of being recomputed from blobs.
--
-- Run this in the Supabase SQL editor:
--   https://supabase.com/dashboard/project/sylxsaquzuochdvonuzr/sql/new

alter table public.meetings
  add column if not exists not_attended boolean not null default false,
  add column if not exists follow_up    boolean not null default false;

-- Helpful indexes for the upcoming overview SQL that filters by flag
create index if not exists meetings_user_followup_idx
  on public.meetings (user_id, follow_up)
  where follow_up = true;

create index if not exists meetings_user_notattended_idx
  on public.meetings (user_id, not_attended)
  where not_attended = true;

-- After running this, the next time anyone opens the app and a sync
-- fires, cloudSyncTables() will populate both columns. Until then, the
-- app degrades gracefully — see the retry-without-columns fallback in
-- pipeline.html.
