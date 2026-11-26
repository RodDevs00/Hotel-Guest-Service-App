-- Hotel Guest Service Request App — initial schema
create extension if not exists pgcrypto;

-- Enums
do $$ begin
  create type public.user_role as enum ('guest', 'staff', 'admin');
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.request_status as enum ('pending', 'in_progress', 'completed');
exception when duplicate_object then null;
end $$;

-- Tables
create table if not exists public.hotel_settings (
  id int primary key default 1 check (id = 1),
  hotel_name text not null default 'Hotel Service',
  updated_at timestamptz not null default now()
);

create table if not exists public.departments (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.rooms (
  id uuid primary key default gen_random_uuid(),
  room_number text not null unique,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.stays (
  id uuid primary key default gen_random_uuid(),
  room_id uuid not null references public.rooms(id) on delete restrict,
  check_in_code_hash text not null,
  is_active boolean not null default true,
  guest_user_id uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists stays_room_active_idx on public.stays(room_id) where is_active;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  role public.user_role not null,
  department_id uuid references public.departments(id) on delete set null,
  created_at timestamptz not null default now()
);

create table if not exists public.service_types (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  allows_quantity boolean not null default false,
  default_department_id uuid references public.departments(id) on delete set null,
  sort_order int not null default 0,
  is_hidden boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.requests (
  id uuid primary key default gen_random_uuid(),
  stay_id uuid not null references public.stays(id) on delete cascade,
  room_id uuid not null references public.rooms(id) on delete restrict,
  service_type_id uuid not null references public.service_types(id) on delete restrict,
  quantity int,
  notes text,
  status public.request_status not null default 'pending',
  assigned_department_id uuid references public.departments(id) on delete set null,
  assigned_staff_id uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists requests_created_at_idx on public.requests(created_at desc);
create index if not exists requests_stay_id_idx on public.requests(stay_id);
create index if not exists requests_status_idx on public.requests(status);

create table if not exists public.request_events (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references public.requests(id) on delete cascade,
  event_type text not null,
  from_status public.request_status,
  to_status public.request_status,
  actor_id uuid references auth.users(id) on delete set null,
  actor_name text not null default 'System',
  note text,
  created_at timestamptz not null default now()
);

create index if not exists request_events_request_id_idx on public.request_events(request_id, created_at);

-- Helpers
create or replace function public.current_role()
returns text
language sql
stable
as $$
  select coalesce(auth.jwt() -> 'app_metadata' ->> 'role', '');
$$;

create or replace function public.current_stay_id()
returns uuid
language sql
stable
as $$
  select nullif(auth.jwt() -> 'app_metadata' ->> 'stay_id', '')::uuid;
$$;

create or replace function public.is_staff_or_admin()
returns boolean
language sql
stable
as $$
  select public.current_role() in ('staff', 'admin');
$$;

create or replace function public.is_admin()
returns boolean
language sql
stable
as $$
  select public.current_role() = 'admin';
$$;

-- Status transition enforcement
create or replace function public.enforce_request_status_transition()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'UPDATE' and new.status is distinct from old.status then
    if not (
      (old.status = 'pending' and new.status in ('in_progress', 'completed'))
      or (old.status = 'in_progress' and new.status = 'completed')
    ) then
      raise exception 'Invalid status transition from % to %', old.status, new.status;
    end if;
  end if;

  if tg_op = 'INSERT' and new.status <> 'pending' then
    raise exception 'New requests must start as pending';
  end if;

  return new;
end;
$$;

drop trigger if exists trg_enforce_request_status on public.requests;
create trigger trg_enforce_request_status
before insert or update on public.requests
for each row execute function public.enforce_request_status_transition();

-- Audit events
create or replace function public.log_request_changes()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  actor text;
begin
  actor := coalesce(
    (select full_name from public.profiles where id = auth.uid()),
    case when public.current_role() = 'guest' then 'Guest' else 'System' end
  );

  if tg_op = 'INSERT' then
    insert into public.request_events(request_id, event_type, to_status, actor_id, actor_name)
    values (new.id, 'created', new.status, auth.uid(), actor);
    return new;
  end if;

  if old.status is distinct from new.status then
    insert into public.request_events(request_id, event_type, from_status, to_status, actor_id, actor_name)
    values (new.id, 'status_changed', old.status, new.status, auth.uid(), actor);
  end if;

  if old.assigned_department_id is distinct from new.assigned_department_id
     or old.assigned_staff_id is distinct from new.assigned_staff_id then
    insert into public.request_events(request_id, event_type, actor_id, actor_name, note)
    values (
      new.id,
      'assigned',
      auth.uid(),
      actor,
      coalesce(
        (select name from public.departments where id = new.assigned_department_id),
        ''
      ) || case when new.assigned_staff_id is not null then
        ' / ' || coalesce((select full_name from public.profiles where id = new.assigned_staff_id), '')
      else '' end
    );
  end if;

  return new;
end;
$$;

drop trigger if exists trg_log_request_changes on public.requests;
create trigger trg_log_request_changes
after insert or update on public.requests
for each row execute function public.log_request_changes();

-- Guest insert guard: force pending and own stay
create or replace function public.guest_request_insert_guard()
returns trigger
language plpgsql
as $$
begin
  if public.current_role() = 'guest' then
    if new.stay_id is distinct from public.current_stay_id() then
      raise exception 'Guests may only create requests for their stay';
    end if;
    new.status := 'pending';
    new.assigned_department_id := null;
    new.assigned_staff_id := null;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_guest_request_insert_guard on public.requests;
create trigger trg_guest_request_insert_guard
before insert on public.requests
for each row execute function public.guest_request_insert_guard();

-- Admin RPCs for hashed stay codes
create or replace function public.admin_create_stay(p_room_id uuid, p_check_in_code text)
returns public.stays
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  created public.stays;
begin
  if not public.is_admin() then
    raise exception 'Admin only';
  end if;

  -- End any existing active stay for this room
  update public.stays set is_active = false, updated_at = now()
  where room_id = p_room_id and is_active = true;

  insert into public.stays(room_id, check_in_code_hash, is_active)
  values (p_room_id, crypt(p_check_in_code, gen_salt('bf')), true)
  returning * into created;

  return created;
end;
$$;

create or replace function public.admin_reset_stay_code(p_stay_id uuid, p_check_in_code text)
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
  if not public.is_admin() then
    raise exception 'Admin only';
  end if;

  update public.stays
  set check_in_code_hash = crypt(p_check_in_code, gen_salt('bf')),
      updated_at = now()
  where id = p_stay_id;
end;
$$;

-- Verify guest credentials (service role / edge function)
create or replace function public.verify_guest_credentials(p_room_number text, p_check_in_code text)
returns table(stay_id uuid, room_id uuid, guest_user_id uuid)
language plpgsql
security definer
set search_path = public, extensions
as $$
begin
  return query
  select s.id, s.room_id, s.guest_user_id
  from public.stays s
  join public.rooms r on r.id = s.room_id
  where r.room_number = p_room_number
    and s.is_active = true
    and r.is_active = true
    and s.check_in_code_hash = crypt(p_check_in_code, s.check_in_code_hash)
  limit 1;
end;
$$;

revoke all on function public.verify_guest_credentials(text, text) from public, anon, authenticated;
grant execute on function public.verify_guest_credentials(text, text) to service_role;

revoke all on function public.admin_create_stay(uuid, text) from public, anon;
grant execute on function public.admin_create_stay(uuid, text) to authenticated;

revoke all on function public.admin_reset_stay_code(uuid, text) from public, anon;
grant execute on function public.admin_reset_stay_code(uuid, text) to authenticated;

-- RLS
alter table public.hotel_settings enable row level security;
alter table public.departments enable row level security;
alter table public.rooms enable row level security;
alter table public.stays enable row level security;
alter table public.profiles enable row level security;
alter table public.service_types enable row level security;
alter table public.requests enable row level security;
alter table public.request_events enable row level security;

-- hotel_settings (public hotel name on sign-in screens)
grant select on public.hotel_settings to anon, authenticated;
create policy hotel_settings_read on public.hotel_settings for select to anon, authenticated using (true);
create policy hotel_settings_admin on public.hotel_settings for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- departments
create policy departments_read on public.departments for select to authenticated using (true);
create policy departments_admin on public.departments for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- rooms
create policy rooms_read on public.rooms for select to authenticated
  using (
    public.is_staff_or_admin()
    or id::text = coalesce(auth.jwt() -> 'app_metadata' ->> 'room_id', '')
  );
create policy rooms_admin_write on public.rooms for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- stays: guests can read own stay; staff/admin read all; admin write
create policy stays_guest_read on public.stays for select to authenticated
  using (id = public.current_stay_id() or public.is_staff_or_admin());
create policy stays_admin_write on public.stays for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- profiles
create policy profiles_self_or_staff on public.profiles for select to authenticated
  using (id = auth.uid() or public.is_staff_or_admin());
create policy profiles_admin_write on public.profiles for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- service types
create policy service_types_guest_read on public.service_types for select to authenticated
  using (is_hidden = false or public.is_staff_or_admin());
create policy service_types_admin_write on public.service_types for all to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- requests
create policy requests_guest_select on public.requests for select to authenticated
  using (stay_id = public.current_stay_id() or public.is_staff_or_admin());

create policy requests_guest_insert on public.requests for insert to authenticated
  with check (
    public.current_role() = 'guest'
    and stay_id = public.current_stay_id()
    and status = 'pending'
  );

create policy requests_staff_update on public.requests for update to authenticated
  using (public.is_staff_or_admin())
  with check (public.is_staff_or_admin());

-- request events
create policy request_events_read on public.request_events for select to authenticated
  using (
    exists (
      select 1 from public.requests r
      where r.id = request_id
        and (r.stay_id = public.current_stay_id() or public.is_staff_or_admin())
    )
  );

create policy request_events_staff_insert on public.request_events for insert to authenticated
  with check (public.is_staff_or_admin() or public.current_role() = 'guest');

-- Realtime
alter publication supabase_realtime add table public.requests;

-- Seed data
insert into public.hotel_settings (id, hotel_name)
values (1, 'Hotel Service')
on conflict (id) do nothing;

insert into public.departments (name) values
  ('Housekeeping'),
  ('Maintenance'),
  ('Room Service'),
  ('Laundry'),
  ('Front Office')
on conflict (name) do nothing;

insert into public.service_types (name, allows_quantity, default_department_id, sort_order, is_hidden)
select v.name, v.allows_quantity, d.id, v.sort_order, false
from (values
  ('Do Not Disturb', false, 'Front Office', 1),
  ('Room cleaning', false, 'Housekeeping', 2),
  ('Towels', true, 'Housekeeping', 3),
  ('Toiletries', true, 'Housekeeping', 4),
  ('Maintenance', false, 'Maintenance', 5),
  ('Room service', false, 'Room Service', 6),
  ('Laundry', true, 'Laundry', 7),
  ('Wake-up call', false, 'Front Office', 8),
  ('Other', false, 'Front Office', 9)
) as v(name, allows_quantity, dept_name, sort_order)
join public.departments d on d.name = v.dept_name
on conflict (name) do nothing;

-- Demo rooms (optional starter set)
insert into public.rooms (room_number) values
  ('101'), ('102'), ('103'), ('201'), ('202'), ('301')
on conflict (room_number) do nothing;
