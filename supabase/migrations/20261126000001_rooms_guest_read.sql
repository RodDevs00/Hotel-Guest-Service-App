drop policy if exists rooms_staff_read on public.rooms;
create policy rooms_read on public.rooms for select to authenticated
  using (
    public.is_staff_or_admin()
    or id::text = coalesce(auth.jwt() -> 'app_metadata' ->> 'room_id', '')
  );
