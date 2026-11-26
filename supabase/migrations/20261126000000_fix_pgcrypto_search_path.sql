-- pgcrypto lives in extensions schema; keep it reachable from SECURITY DEFINER helpers
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
