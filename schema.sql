-- Caderno de Saúde — Bernardo
-- Corre isto no Supabase SQL Editor

create table if not exists medical_incidents (
  id text primary key,
  date date not null,
  time text,
  type text not null,
  type_custom text,
  severity integer not null check (severity in (1, 2, 3)),
  sensor_active boolean,
  symptoms text,
  action text,
  recovery_time text,
  notes text,
  created_at timestamptz default now()
);

-- Ordenação padrão: mais recente primeiro
create index if not exists medical_incidents_date_idx on medical_incidents (date desc, time desc);

-- Row Level Security — desativa acesso anónimo de escrita se quiseres restringir
-- Por agora deixamos aberto com anon key (app pessoal, sem autenticação)
alter table medical_incidents enable row level security;

create policy "allow_all" on medical_incidents
  for all
  using (true)
  with check (true);
