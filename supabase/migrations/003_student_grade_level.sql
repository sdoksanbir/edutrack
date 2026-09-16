-- Öğrenci sınıf / seviye
alter table public.students
  add column if not exists grade_level text;
