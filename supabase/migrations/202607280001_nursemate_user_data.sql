create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.memos (
  owner_id uuid not null references auth.users(id) on delete cascade,
  id text not null,
  title text not null default '',
  content text not null default '',
  created_at timestamptz not null,
  updated_at timestamptz not null,
  highlights jsonb not null default '[]'::jsonb,
  photos jsonb not null default '[]'::jsonb,
  is_favorite boolean not null default false,
  primary key (owner_id, id)
);

create table if not exists public.duties (
  owner_id uuid not null references auth.users(id) on delete cascade,
  duty_date date not null,
  duty_type text not null check (
    duty_type in ('day', 'evening', 'night', 'off', 'annualLeave')
  ),
  updated_at timestamptz not null default now(),
  primary key (owner_id, duty_date)
);

alter table public.profiles enable row level security;
alter table public.memos enable row level security;
alter table public.duties enable row level security;

create policy "profiles_select_own"
on public.profiles for select to authenticated
using ((select auth.uid()) = user_id);

create policy "profiles_insert_own"
on public.profiles for insert to authenticated
with check ((select auth.uid()) = user_id);

create policy "profiles_update_own"
on public.profiles for update to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "memos_select_own"
on public.memos for select to authenticated
using ((select auth.uid()) = owner_id);

create policy "memos_insert_own"
on public.memos for insert to authenticated
with check ((select auth.uid()) = owner_id);

create policy "memos_update_own"
on public.memos for update to authenticated
using ((select auth.uid()) = owner_id)
with check ((select auth.uid()) = owner_id);

create policy "memos_delete_own"
on public.memos for delete to authenticated
using ((select auth.uid()) = owner_id);

create policy "duties_select_own"
on public.duties for select to authenticated
using ((select auth.uid()) = owner_id);

create policy "duties_insert_own"
on public.duties for insert to authenticated
with check ((select auth.uid()) = owner_id);

create policy "duties_update_own"
on public.duties for update to authenticated
using ((select auth.uid()) = owner_id)
with check ((select auth.uid()) = owner_id);

create policy "duties_delete_own"
on public.duties for delete to authenticated
using ((select auth.uid()) = owner_id);

grant select, insert, update on public.profiles to authenticated;
grant select, insert, update, delete on public.memos to authenticated;
grant select, insert, update, delete on public.duties to authenticated;

insert into storage.buckets (id, name, public)
values ('memo-images', 'memo-images', false)
on conflict (id) do update set public = false;

create policy "memo_images_select_own"
on storage.objects for select to authenticated
using (
  bucket_id = 'memo-images'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

create policy "memo_images_insert_own"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'memo-images'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

create policy "memo_images_update_own"
on storage.objects for update to authenticated
using (
  bucket_id = 'memo-images'
  and (storage.foldername(name))[1] = (select auth.uid())::text
)
with check (
  bucket_id = 'memo-images'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

create policy "memo_images_delete_own"
on storage.objects for delete to authenticated
using (
  bucket_id = 'memo-images'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (user_id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'display_name', ''));
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
