-- Tam yedekleme: ödev attention_cleared + bitirilen konular tablosu

alter table public.homework_items
  add column if not exists attention_cleared boolean not null default false;

create table if not exists public.student_topic_progress (
  id text primary key,
  owner_id uuid not null references auth.users (id) on delete cascade,
  student_id text not null references public.students (id) on delete cascade,
  label text not null,
  created_at timestamptz not null default now(),
  unique (student_id, label)
);
create index if not exists student_topic_progress_owner_idx
  on public.student_topic_progress (owner_id);

alter table public.student_topic_progress enable row level security;

drop policy if exists student_topic_progress_all_own on public.student_topic_progress;
create policy student_topic_progress_all_own on public.student_topic_progress
  for all using (auth.uid() = owner_id) with check (auth.uid() = owner_id);
