-- Run this in Supabase: SQL Editor -> New query -> Run
create table if not exists public.love_letter_acknowledgements (
  letter_id text primary key,
  acknowledged boolean not null default false,
  acknowledged_at timestamptz
);

alter table public.love_letter_acknowledgements enable row level security;

-- Simple setup for this personal, low-sensitivity acknowledgement page.
-- Anyone with the public page can read/write the acknowledgement row.
-- This is convenient but NOT tamper-proof; use a server-side function for stronger security.
drop policy if exists "Public can read love letter acknowledgement" on public.love_letter_acknowledgements;
create policy "Public can read love letter acknowledgement"
on public.love_letter_acknowledgements for select to anon using (true);

drop policy if exists "Public can insert love letter acknowledgement" on public.love_letter_acknowledgements;
create policy "Public can insert love letter acknowledgement"
on public.love_letter_acknowledgements for insert to anon with check (true);

drop policy if exists "Public can update love letter acknowledgement" on public.love_letter_acknowledgements;
create policy "Public can update love letter acknowledgement"
on public.love_letter_acknowledgements for update to anon using (true) with check (true);

insert into public.love_letter_acknowledgements (letter_id, acknowledged, acknowledged_at)
values ('bv-23ae3fffc1dad170', false, null)
on conflict (letter_id) do nothing;
