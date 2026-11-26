# Hotel Guest Service Request App

Flutter app for hotel guests (Android) and hotel staff (web dashboard), backed by a **Supabase Free** project.

Guests sign in with a room number and check-in code, submit service requests, and track status: **Pending → In Progress → Completed**. Staff assign requests and update status. Admins manage the service menu, rooms, stays, and staff accounts.

## Features (contract scope)

1. Guest room sign-in (room number + check-in code)
2. Service request menu (DND, cleaning, towels, toiletries, maintenance, room service, laundry, wake-up call, other)
3. Send a request with quantity/notes
4. Track request status
5. Request history for the current stay
6. Staff sign-in
7. Staff request list (newest first)
8. Assign to department or person
9. Status updates with name/time audit log
10. Admin service menu management
11. Secure storage (RLS, hashed codes, roles) + privacy notice
12. Screen design aligned with the Pending / In Progress / Completed workflow
13. Tests and this user guide

Out of scope: iPhone build, push notifications, balances, analytics, PMS/billing integration, hosting after handover.

## Project layout

- `lib/features/guest/` — guest mobile screens
- `lib/features/staff/` — staff web dashboard
- `lib/features/admin/` — admin setup screens
- `supabase/migrations/` — Postgres schema, RLS, seeds
- `supabase/functions/guest-sign-in/` — room + code sign-in
- `supabase/functions/admin-create-user/` — create staff/admin accounts

## Setup (Supabase Free)

1. Create a Free organization and project at [supabase.com](https://supabase.com).
2. In the SQL Editor, run [`supabase/migrations/20261125000000_init.sql`](supabase/migrations/20261125000000_init.sql).
3. Deploy Edge Functions:
   - `guest-sign-in` (JWT verification **off**)
   - `admin-create-user` (JWT verification **on**)
4. Create the first admin in **Authentication → Users** (email confirmed). Then in SQL:

```sql
insert into public.profiles (id, full_name, role)
values ('YOUR_AUTH_USER_UUID', 'Hotel Admin', 'admin');

update auth.users
set raw_app_meta_data =
  coalesce(raw_app_meta_data, '{}'::jsonb) || '{"role":"admin"}'::jsonb
where id = 'YOUR_AUTH_USER_UUID';
```

5. Create a demo stay (room `101`, code `demo1234`):

```sql
insert into public.stays (room_id, check_in_code_hash, is_active)
select id, crypt('demo1234', gen_salt('bf')), true
from public.rooms where room_number = '101';
```

6. Copy **Project URL** and **anon public** key from Project Settings → API.

### Free plan notes

- Projects **pause after 1 week of inactivity**. Restore from the Supabase dashboard.
- No automatic backups on Free.
- Staff accounts are created with email already confirmed (no mailer required).

## Run locally

```bash
cd Hotel-Guest-Service-App

# Guest Android app
flutter run -d android \
  --dart-define=SUPABASE_URL=YOUR_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY

# Staff / admin web dashboard
flutter run -d chrome \
  --dart-define=SUPABASE_URL=YOUR_URL \
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

Never put the **service role** key in the Flutter app or in git. It belongs only in Edge Function secrets.

## User guide

### Guests (phone)

1. Read the privacy notice and continue.
2. Enter room number and check-in code from the front desk.
3. Open **Services**, choose a type, add quantity/notes if needed, and submit.
4. Open **My Requests** to watch Pending / In Progress / Completed (updates live).
5. Open **History** for completed requests during this stay.
6. Tap a request for the status timeline.

### Staff (web)

1. Sign in with email and password.
2. Open the request list (newest first). Filter by status or department.
3. Open a request to assign a department and/or staff member.
4. Mark **In Progress** or **Completed**. Each change is recorded with your name and time.

### Admin (web)

1. Sign in with an admin account.
2. Use **Admin** in the rail:
   - **Services** — add, edit, or hide menu items
   - **Rooms** — add rooms and set active/inactive
   - **Stays** — start a stay with a check-in code, reset a code, or end a stay
   - **Staff** — create staff or admin accounts

## Tests

```bash
flutter test
```

## Handover

The client owns the Supabase Free project and all guest/request data after final payment. Hosting the Flutter web build on a public URL (Firebase Hosting, Netlify, etc.) is separate from this contract.
