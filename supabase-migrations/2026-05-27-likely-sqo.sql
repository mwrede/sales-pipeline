-- 2026-05-27: persist the "Likely SQO" flag on S1-stage opportunities.
-- The flag lives in pipeline_blob.data already (c.likelySQO per company);
-- this adds the queryable mirror column on public.opportunities so SQL
-- reports can filter for it the same way they do for likely_s1.
--
-- Run this in the Supabase SQL editor:
--   https://supabase.com/dashboard/project/sylxsaquzuochdvonuzr/sql/new

alter table public.opportunities
  add column if not exists likely_sqo boolean not null default false;

create index if not exists opportunities_user_likely_sqo_idx
  on public.opportunities (user_id, likely_sqo)
  where likely_sqo = true;

-- Until you run this, cloudSyncTables() falls back to inserting without
-- likely_sqo (see the PGRST204 retry in pipeline.html). The JSONB blob
-- remains authoritative either way.
