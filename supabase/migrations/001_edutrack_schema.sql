-- EduTrack → Supabase (PostgreSQL) şema + RLS
-- Uygulama: Supabase Dashboard → SQL Editor → New query → Run
--
-- Notlar:
-- 1) Tüm iş verisi owner_id = auth.uid() ile öğretmenlere ayrılır.
-- 2) Önce Authentication'da bir kullanıcı oluştur (email/password veya magic link).
-- 3) service_role key'i Flutter'a KOYMA; sadece anon + RLS.

-- ── Yardımcı: updated_at tetikleyicisi ───────────────────
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ── Profil (öğretmen) ────────────────────────────────────
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text not null default '',
  phone text,
  photo_path text,
  branches jsonb not null default '[]'::jsonb,
  visible_folders jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- Yeni auth kullanıcısı → profil satırı
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', ''))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ── Öğrenciler ───────────────────────────────────────────
create table if not exists public.students (
  id text primary key,
  owner_id uuid not null references auth.users (id) on delete cascade,
  full_name text not null,
  phone text,
  hourly_rate integer not null default 0,
  notes text,
  is_active boolean not null default true,
  guardian_full_name text,
  guardian_phone text,
  book_resource text,
  book_resource_practice text,
  grade_level text,
  created_at timestamptz not null default now()
);
create index if not exists students_owner_idx on public.students (owner_id);

-- ── Haftalık şablonlar ───────────────────────────────────
create table if not exists public.schedule_templates (
  id text primary key,
  owner_id uuid not null references auth.users (id) on delete cascade,
  student_id text not null references public.students (id) on delete cascade,
  weekday integer not null check (weekday between 1 and 7),
  start_time text not null,
  duration_min integer not null,
  start_date text not null,
  end_date text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (student_id, weekday, start_time)
);
create index if not exists schedule_templates_owner_idx
  on public.schedule_templates (owner_id);

-- ── Şablon override ──────────────────────────────────────
create table if not exists public.schedule_overrides (
  id text primary key,
  owner_id uuid not null references auth.users (id) on delete cascade,
  template_id text not null references public.schedule_templates (id) on delete cascade,
  date text not null,
  override_type text not null,
  new_weekday integer,
  new_start_time text,
  new_duration_min integer,
  created_at timestamptz not null default now()
);
create index if not exists schedule_overrides_owner_idx
  on public.schedule_overrides (owner_id);

-- ── Ders oluşumları ──────────────────────────────────────
create table if not exists public.session_occurrences (
  id text primary key,
  owner_id uuid not null references auth.users (id) on delete cascade,
  student_id text not null references public.students (id) on delete cascade,
  template_id text references public.schedule_templates (id) on delete set null,
  date text not null,
  start_time text not null,
  duration_min integer not null,
  status text not null,
  not_done_reason_type text,
  not_done_reason_note text,
  payment_id text,
  completed_at timestamptz,
  postponed_from_date text,
  postponed_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (student_id, date, start_time)
);
create index if not exists session_occurrences_owner_idx
  on public.session_occurrences (owner_id);
create index if not exists session_occurrences_date_idx
  on public.session_occurrences (owner_id, date);

drop trigger if exists session_occurrences_set_updated_at on public.session_occurrences;
create trigger session_occurrences_set_updated_at
  before update on public.session_occurrences
  for each row execute function public.set_updated_at();

-- ── Ders kayıtları ───────────────────────────────────────
create table if not exists public.lessons (
  id text primary key,
  owner_id uuid not null references auth.users (id) on delete cascade,
  student_id text not null references public.students (id) on delete cascade,
  occurrence_id text unique references public.session_occurrences (id) on delete set null,
  start_date_time timestamptz not null,
  duration_min integer not null,
  topic text,
  homework text,
  homework_resource text,
  fee_expected integer not null default 0,
  fee_paid_amount integer not null default 0,
  note text,
  lesson_notes text,
  status text,
  status_reason text,
  status_reason_source text,
  status_changed_at timestamptz,
  created_at timestamptz not null default now()
);
create index if not exists lessons_owner_idx on public.lessons (owner_id);

-- ── Ödev kalemleri ───────────────────────────────────────
create table if not exists public.homework_items (
  id text primary key,
  owner_id uuid not null references auth.users (id) on delete cascade,
  lesson_id text not null references public.lessons (id) on delete cascade,
  student_id text not null references public.students (id) on delete cascade,
  assigned_at timestamptz not null,
  resource text,
  topic text not null,
  detail text,
  status text not null default 'pending',
  status_note text,
  due_at timestamptz,
  status_changed_at timestamptz,
  created_at timestamptz not null default now()
);
create index if not exists homework_items_owner_idx on public.homework_items (owner_id);

-- ── Yapılacaklar ─────────────────────────────────────────
create table if not exists public.teacher_todos (
  id text primary key,
  owner_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  student_id text,
  student_name text,
  homework_item_id text,
  homework_topic text,
  is_done boolean not null default false,
  notify_at timestamptz,
  created_at timestamptz not null default now()
);
create index if not exists teacher_todos_owner_idx on public.teacher_todos (owner_id);

-- ── Ekler (metadata; dosya Storage'da) ────────────────────
create table if not exists public.attachments (
  id text primary key,
  owner_id uuid not null references auth.users (id) on delete cascade,
  lesson_id text not null references public.lessons (id) on delete cascade,
  file_path text not null,
  storage_path text,
  created_at timestamptz not null default now()
);
create index if not exists attachments_owner_idx on public.attachments (owner_id);

-- ── Uygulama ayarları (öğretmen bazlı) ───────────────────
create table if not exists public.app_settings (
  owner_id uuid not null references auth.users (id) on delete cascade,
  key text not null,
  value text not null,
  primary key (owner_id, key)
);

-- ── Ödemeler ─────────────────────────────────────────────
create table if not exists public.payments (
  id text primary key,
  owner_id uuid not null references auth.users (id) on delete cascade,
  student_id text not null references public.students (id) on delete cascade,
  paid_at timestamptz not null,
  amount integer not null,
  method text not null,
  note text,
  created_at timestamptz not null default now()
);
create index if not exists payments_owner_idx on public.payments (owner_id);

-- session_occurrences.payment_id FK (payments tablosu sonra)
do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'session_occurrences_payment_id_fkey'
  ) then
    alter table public.session_occurrences
      add constraint session_occurrences_payment_id_fkey
      foreign key (payment_id) references public.payments (id) on delete set null;
  end if;
end $$;

create table if not exists public.lesson_payments (
  id text primary key,
  owner_id uuid not null references auth.users (id) on delete cascade,
  payment_id text not null references public.payments (id) on delete cascade,
  lesson_id text not null references public.lessons (id) on delete cascade,
  applied_amount integer not null,
  created_at timestamptz not null default now(),
  unique (payment_id, lesson_id)
);
create index if not exists lesson_payments_owner_idx on public.lesson_payments (owner_id);

-- ── Müfredat ─────────────────────────────────────────────
create table if not exists public.curriculum_subjects (
  id text primary key,
  owner_id uuid not null references auth.users (id) on delete cascade,
  name text not null,
  folder text not null default 'MATEMATİK',
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);
create index if not exists curriculum_subjects_owner_idx
  on public.curriculum_subjects (owner_id);

create table if not exists public.curriculum_units (
  id text primary key,
  owner_id uuid not null references auth.users (id) on delete cascade,
  subject_id text not null references public.curriculum_subjects (id) on delete cascade,
  name text not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.curriculum_topics (
  id text primary key,
  owner_id uuid not null references auth.users (id) on delete cascade,
  unit_id text not null references public.curriculum_units (id) on delete cascade,
  name text not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.curriculum_outcomes (
  id text primary key,
  owner_id uuid not null references auth.users (id) on delete cascade,
  topic_id text not null references public.curriculum_topics (id) on delete cascade,
  name text not null,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

-- ── RLS ──────────────────────────────────────────────────
alter table public.profiles enable row level security;
alter table public.students enable row level security;
alter table public.schedule_templates enable row level security;
alter table public.schedule_overrides enable row level security;
alter table public.session_occurrences enable row level security;
alter table public.lessons enable row level security;
alter table public.homework_items enable row level security;
alter table public.teacher_todos enable row level security;
alter table public.attachments enable row level security;
alter table public.app_settings enable row level security;
alter table public.payments enable row level security;
alter table public.lesson_payments enable row level security;
alter table public.curriculum_subjects enable row level security;
alter table public.curriculum_units enable row level security;
alter table public.curriculum_topics enable row level security;
alter table public.curriculum_outcomes enable row level security;

-- Profil: sadece kendi satırı
drop policy if exists profiles_select_own on public.profiles;
create policy profiles_select_own on public.profiles
  for select using (auth.uid() = id);
drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
  for update using (auth.uid() = id) with check (auth.uid() = id);
drop policy if exists profiles_insert_own on public.profiles;
create policy profiles_insert_own on public.profiles
  for insert with check (auth.uid() = id);

-- Genel owner_id politikası üretici
do $$
declare
  t text;
begin
  foreach t in array array[
    'students',
    'schedule_templates',
    'schedule_overrides',
    'session_occurrences',
    'lessons',
    'homework_items',
    'teacher_todos',
    'attachments',
    'app_settings',
    'payments',
    'lesson_payments',
    'curriculum_subjects',
    'curriculum_units',
    'curriculum_topics',
    'curriculum_outcomes'
  ]
  loop
    execute format('drop policy if exists %I_all_own on public.%I', t, t);
    execute format(
      'create policy %I_all_own on public.%I for all using (auth.uid() = owner_id) with check (auth.uid() = owner_id)',
      t, t
    );
  end loop;
end $$;

-- ── Storage bucket (profil + ders fotoğrafları) ───────────
insert into storage.buckets (id, name, public)
values ('edutrack', 'edutrack', false)
on conflict (id) do nothing;

drop policy if exists edutrack_storage_select on storage.objects;
create policy edutrack_storage_select on storage.objects
  for select using (
    bucket_id = 'edutrack' and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists edutrack_storage_insert on storage.objects;
create policy edutrack_storage_insert on storage.objects
  for insert with check (
    bucket_id = 'edutrack' and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists edutrack_storage_update on storage.objects;
create policy edutrack_storage_update on storage.objects
  for update using (
    bucket_id = 'edutrack' and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists edutrack_storage_delete on storage.objects;
create policy edutrack_storage_delete on storage.objects
  for delete using (
    bucket_id = 'edutrack' and auth.uid()::text = (storage.foldername(name))[1]
  );
