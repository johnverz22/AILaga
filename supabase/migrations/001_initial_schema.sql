-- =============================================================================
-- AILaga — Supabase Remote Schema
-- Migration: 001_initial_schema
-- =============================================================================
--
-- PURPOSE
--   Mirror the local Drift SQLite schema so Supabase can serve as a cloud
--   backup and multi-device sync target.
--
-- DESIGN DECISIONS
--   • Primary keys are TEXT (not UUID type) to match Drift, which stores
--     UUIDs as plain strings. The application layer (UuidGenerator.generate())
--     guarantees valid v4 UUIDs before insertion.
--   • Foreign keys reference care_recipients(id) ON DELETE CASCADE so that
--     deleting a care recipient also removes all dependent rows remotely.
--   • firebase_uid is TEXT (not UUID) because Firebase UIDs are opaque string
--     tokens, not v4 UUIDs. It is the row-ownership key for RLS.
--   • Timestamps are stored as TIMESTAMPTZ (UTC). The Flutter app sends UTC
--     epoch-milliseconds; this column type preserves them correctly.
--   • The local Drift table for measurements is named measurement_logs; the
--     remote table matches that name for consistency with the sync service.
--   • medication_occurrences has no updated_at (matching the local schema);
--     it uses status_updated_at to track status changes instead.
--   • updated_at columns use DEFAULT now() so records inserted without an
--     explicit value get a server-side timestamp.
--
-- APPLYING THIS MIGRATION
--   Option A (Dashboard): Paste into Supabase Dashboard → SQL Editor → Run.
--   Option B (CLI):       supabase db push  (from project root with supabase CLI)
--
-- =============================================================================

-- ---------------------------------------------------------------------------
-- 1. Care Recipients
-- ---------------------------------------------------------------------------
create table if not exists care_recipients (
  id                text        primary key,
  firebase_uid      text        not null,
  display_name      text        not null,
  date_of_birth     timestamptz,
  allergies         text,
  important_notes   text,
  emergency_info    text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

comment on column care_recipients.firebase_uid is
  'Firebase Auth UID of the owning caregiver. Used by RLS policies.';

-- ---------------------------------------------------------------------------
-- 2. Family Contacts
-- ---------------------------------------------------------------------------
create table if not exists family_contacts (
  id                    text        primary key,
  firebase_uid          text        not null,
  care_recipient_id     text        not null references care_recipients(id) on delete cascade,
  display_name          text        not null,
  relationship          text,
  phone_number          text        not null,
  is_emergency_contact  boolean     not null default false,
  sort_order            integer     not null default 0,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- 3. Medication Schedules
-- ---------------------------------------------------------------------------
create table if not exists medication_schedules (
  id                       text        primary key,
  firebase_uid             text        not null,
  care_recipient_id        text        not null references care_recipients(id) on delete cascade,
  medication_name          text        not null,
  prescribed_instructions  text,
  schedule_times           text        not null, -- JSON array e.g. ["08:00","20:00"]
  start_date               timestamptz not null,
  end_date                 timestamptz,
  notes                    text,
  is_active                boolean     not null default true,
  created_at               timestamptz not null default now(),
  updated_at               timestamptz not null default now()
);

comment on column medication_schedules.schedule_times is
  'JSON array of "HH:mm" strings, e.g. ["08:00","20:00"]. Matches local Drift column.';

-- ---------------------------------------------------------------------------
-- 4. Medication Occurrences
--    NOTE: No updated_at — matches local Drift schema which uses status_updated_at
--    to track status changes. Local occurrence status is always authoritative.
-- ---------------------------------------------------------------------------
create table if not exists medication_occurrences (
  id                      text        primary key,
  firebase_uid            text        not null,
  medication_schedule_id  text        not null references medication_schedules(id) on delete cascade,
  scheduled_at            timestamptz not null,
  status                  text        not null default 'pending',
  -- pending | taken | skipped | not_confirmed
  status_updated_at       timestamptz,
  status_source           text        not null default 'manual',
  -- manual | ai_assisted
  status_note             text,
  recorded_by_label       text,
  created_at              timestamptz not null default now(),

  -- Enforce one occurrence per schedule per scheduled time (matches Drift uniqueKeys)
  unique (medication_schedule_id, scheduled_at)
);

comment on column medication_occurrences.status is
  'Caregiver-confirmed status. Local value always wins on conflict — never overwrite from remote.';

-- ---------------------------------------------------------------------------
-- 5. Measurement Logs
--    Table name is measurement_logs (not measurements) to match the local
--    Drift table name MeasurementLogs.
-- ---------------------------------------------------------------------------
create table if not exists measurement_logs (
  id                text        primary key,
  firebase_uid      text        not null,
  care_recipient_id text        not null references care_recipients(id) on delete cascade,
  measurement_type  text        not null,
  -- blood_pressure | pulse | temperature | weight | blood_glucose
  value1            numeric     not null, -- primary value, or systolic for BP
  value2            numeric,              -- diastolic for BP; null for others
  unit              text        not null,
  measured_at       timestamptz not null,
  recorded_at       timestamptz not null,
  source_type       text        not null default 'manual',
  -- manual | health_connect | ai_assisted | other
  source_label      text,
  notes             text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- 6. Appointments
-- ---------------------------------------------------------------------------
create table if not exists appointments (
  id                    text        primary key,
  firebase_uid          text        not null,
  care_recipient_id     text        not null references care_recipients(id) on delete cascade,
  provider_or_facility  text,
  purpose               text,
  scheduled_at          timestamptz not null,
  notes                 text,
  status                text        not null default 'scheduled',
  -- scheduled | completed | cancelled
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- 7. Care Notes
-- ---------------------------------------------------------------------------
create table if not exists care_notes (
  id                  text        primary key,
  firebase_uid        text        not null,
  care_recipient_id   text        not null references care_recipients(id) on delete cascade,
  observed_at         timestamptz not null,
  recorded_at         timestamptz not null,
  original_text       text        not null,
  structured_summary  text,
  source_type         text        not null default 'manual',
  -- manual | ai_assisted
  review_status       text        not null default 'unreviewed',
  -- unreviewed | confirmed
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now()
);

-- ---------------------------------------------------------------------------
-- Indexes for common sync and query patterns
-- ---------------------------------------------------------------------------
create index if not exists idx_cr_firebase_uid
  on care_recipients (firebase_uid);

create index if not exists idx_fc_firebase_uid
  on family_contacts (firebase_uid);

create index if not exists idx_ms_firebase_uid
  on medication_schedules (firebase_uid);

create index if not exists idx_mo_firebase_uid
  on medication_occurrences (firebase_uid);

create index if not exists idx_mo_schedule_id
  on medication_occurrences (medication_schedule_id);

create index if not exists idx_mo_scheduled_at
  on medication_occurrences (scheduled_at);

create index if not exists idx_ml_firebase_uid
  on measurement_logs (firebase_uid);

create index if not exists idx_ml_measured_at
  on measurement_logs (measured_at);

create index if not exists idx_ap_firebase_uid
  on appointments (firebase_uid);

create index if not exists idx_ap_scheduled_at
  on appointments (scheduled_at);

create index if not exists idx_cn_firebase_uid
  on care_notes (firebase_uid);

create index if not exists idx_cn_observed_at
  on care_notes (observed_at);
