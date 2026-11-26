-- Lock down trigger helper from direct RPC
revoke all on function public.log_request_changes() from public, anon, authenticated;

-- Fix mutable search_path on helpers
create or replace function public.current_role()
returns text
language sql
stable
set search_path = public
as $$
  select coalesce(auth.jwt() -> 'app_metadata' ->> 'role', '');
$$;

create or replace function public.current_stay_id()
returns uuid
language sql
stable
set search_path = public
as $$
  select nullif(auth.jwt() -> 'app_metadata' ->> 'stay_id', '')::uuid;
$$;

create or replace function public.is_staff_or_admin()
returns boolean
language sql
stable
set search_path = public
as $$
  select public.current_role() in ('staff', 'admin');
$$;

create or replace function public.is_admin()
returns boolean
language sql
stable
set search_path = public
as $$
  select public.current_role() = 'admin';
$$;

create or replace function public.enforce_request_status_transition()
returns trigger
language plpgsql
set search_path = public
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

create or replace function public.guest_request_insert_guard()
returns trigger
language plpgsql
set search_path = public
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
