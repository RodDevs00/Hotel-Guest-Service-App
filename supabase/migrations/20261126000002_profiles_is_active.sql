alter table public.profiles
  add column if not exists is_active boolean not null default true;

create index if not exists profiles_active_staff_idx
  on public.profiles (role)
  where is_active = true and role in ('staff', 'admin');
