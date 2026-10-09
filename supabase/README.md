# AILaga — Supabase Migrations

**Project:** `ailaga-d77b8` (Firebase) / `sgistmejqsbssutscbda` (Supabase)

## Apply order

Run migrations **in order** via the Supabase Dashboard → SQL Editor, or with the Supabase CLI:

| File | Description |
|---|---|
| `migrations/001_initial_schema.sql` | Creates all 7 tables + indexes |
| `migrations/002_rls_policies.sql` | Enables RLS + per-table access policies |

## Firebase JWT configuration (required for RLS)

RLS policies match rows using `firebase_uid = auth.uid()::text`. Supabase's
`auth.uid()` must be set to the Firebase UID, which requires configuring
Firebase as a Third Party Auth provider:

1. Open Supabase Dashboard → **Authentication → Third Party Auth**
2. Click **Add provider** → select **Firebase**
3. Enter Firebase Project ID: `ailaga-d77b8`
4. Save — Supabase fetches Firebase's public JWKS automatically

The Flutter sync service passes the Firebase ID token as the `Authorization: Bearer`
header before every Supabase request. See `lib/services/sync/` for implementation.

## Schema notes

- Primary keys are `text` (not `uuid` type) to match the Drift local DB which
  stores UUIDs as plain strings.
- `medication_occurrences` has no `updated_at` — it uses `status_updated_at`
  (matching the local schema). Local occurrence status is always authoritative
  on conflict.
- Table `measurement_logs` (not `measurements`) matches the Drift table name.
- All timestamps are `timestamptz` (UTC). The Flutter app sends UTC epoch
  milliseconds which PostgreSQL interprets correctly.

## Verification

After applying both migrations, run these checks in the SQL Editor:

```sql
-- 1. All 7 tables exist
select table_name from information_schema.tables
where table_schema = 'public'
  and table_name in (
    'care_recipients', 'family_contacts', 'medication_schedules',
    'medication_occurrences', 'measurement_logs', 'appointments', 'care_notes'
  );

-- 2. RLS is enabled on all 7 tables
select tablename, rowsecurity from pg_tables
where schemaname = 'public'
  and tablename in (
    'care_recipients', 'family_contacts', 'medication_schedules',
    'medication_occurrences', 'measurement_logs', 'appointments', 'care_notes'
  );

-- 3. Policies exist (should return 7 rows)
select tablename, policyname from pg_policies
where schemaname = 'public';
```
