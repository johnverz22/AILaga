-- =============================================================================
-- AILaga — Row-Level Security Policies
-- Migration: 002_rls_policies
-- =============================================================================
--
-- PURPOSE
--   Ensure every user can only read and write their own rows.
--   All tables use firebase_uid as the row-ownership column.
--
-- FIREBASE JWT INTEGRATION
--   Supabase's auth.uid() normally returns the Supabase Auth UUID. Because
--   AILaga uses Firebase Auth (not Supabase Auth), we pass the Firebase ID
--   token as the Authorization: Bearer header on every Supabase request.
--   Supabase verifies it via "Third Party Auth" (Authentication → Third Party
--   Auth in the dashboard). Once configured, auth.uid() returns the Firebase
--   UID string, matching the firebase_uid column in each table.
--
-- CONFIGURATION STEPS (one-time, in Supabase dashboard)
--   1. Go to Authentication → Third Party Auth → Add provider → Firebase.
--   2. Enter your Firebase Project ID: ailaga-d77b8
--   3. Save. Supabase will fetch Firebase's public JWKS and verify tokens.
--   4. In your Flutter app, attach the Firebase ID token as the auth header:
--        final idToken = await FirebaseAuth.instance.currentUser!.getIdToken();
--        Supabase.instance.client.auth.setSession(accessToken: idToken, ...)
--      (The sync service handles this before every Supabase request.)
--
-- UNAUTHENTICATED BEHAVIOUR
--   With RLS enabled and no matching policy for anonymous callers, an
--   unauthenticated query returns an empty result set (not an error).
--   This is the expected behaviour for offline / not-signed-in usage.
--
-- APPLYING THIS MIGRATION
--   Apply AFTER 001_initial_schema.sql. Run in Supabase Dashboard → SQL Editor.
--
-- =============================================================================

-- ---------------------------------------------------------------------------
-- Enable RLS on all 7 tables
-- ---------------------------------------------------------------------------
alter table care_recipients       enable row level security;
alter table family_contacts       enable row level security;
alter table medication_schedules  enable row level security;
alter table medication_occurrences enable row level security;
alter table measurement_logs      enable row level security;
alter table appointments          enable row level security;
alter table care_notes            enable row level security;

-- ---------------------------------------------------------------------------
-- RLS Policies
--
-- Pattern: firebase_uid = auth.uid()::text
--   • auth.uid() is the Firebase UID when Third Party Auth is configured.
--   • ::text cast is defensive — auth.uid() returns text already but the
--     explicit cast makes the intent unambiguous.
--   • "for all" covers SELECT, INSERT, UPDATE, DELETE in one policy.
--     If you need separate policies per operation for audit purposes, split
--     this into individual policies with `for select`, `for insert`, etc.
-- ---------------------------------------------------------------------------

-- 1. Care Recipients
create policy "Users can only access their own care recipients"
  on care_recipients
  for all
  using       (firebase_uid = auth.uid()::text)
  with check  (firebase_uid = auth.uid()::text);

-- 2. Family Contacts
create policy "Users can only access their own family contacts"
  on family_contacts
  for all
  using       (firebase_uid = auth.uid()::text)
  with check  (firebase_uid = auth.uid()::text);

-- 3. Medication Schedules
create policy "Users can only access their own medication schedules"
  on medication_schedules
  for all
  using       (firebase_uid = auth.uid()::text)
  with check  (firebase_uid = auth.uid()::text);

-- 4. Medication Occurrences
create policy "Users can only access their own medication occurrences"
  on medication_occurrences
  for all
  using       (firebase_uid = auth.uid()::text)
  with check  (firebase_uid = auth.uid()::text);

-- 5. Measurement Logs
create policy "Users can only access their own measurement logs"
  on measurement_logs
  for all
  using       (firebase_uid = auth.uid()::text)
  with check  (firebase_uid = auth.uid()::text);

-- 6. Appointments
create policy "Users can only access their own appointments"
  on appointments
  for all
  using       (firebase_uid = auth.uid()::text)
  with check  (firebase_uid = auth.uid()::text);

-- 7. Care Notes
create policy "Users can only access their own care notes"
  on care_notes
  for all
  using       (firebase_uid = auth.uid()::text)
  with check  (firebase_uid = auth.uid()::text);

-- ---------------------------------------------------------------------------
-- Verification queries (run manually after applying)
-- ---------------------------------------------------------------------------
-- Check RLS is enabled on all tables:
--   select tablename, rowsecurity
--   from pg_tables
--   where schemaname = 'public'
--     and tablename in (
--       'care_recipients', 'family_contacts', 'medication_schedules',
--       'medication_occurrences', 'measurement_logs', 'appointments', 'care_notes'
--     );
--
-- Check policies exist:
--   select tablename, policyname, cmd, qual
--   from pg_policies
--   where schemaname = 'public';
--
-- Test unauthenticated access (should return 0 rows, no error):
--   set role anon;
--   select count(*) from care_recipients;
--   reset role;
