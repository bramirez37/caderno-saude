-- =============================================================================
-- Caderno de Saúde — Schema Completo v2
-- Corre isto no Supabase SQL Editor (tudo de uma vez)
-- Idempotente — seguro de correr múltiplas vezes
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. INCIDENTES MÉDICOS (expandido)
-- -----------------------------------------------------------------------------
create table if not exists medical_incidents (
  id text primary key,
  date date not null,
  time text,
  end_date date,                    -- para episódios multi-dia
  end_time text,                    -- para episódios com hora de fim
  type text not null,
  type_custom text,
  severity integer not null check (severity in (1, 2, 3)),
  sensor_active boolean,
  glucose_at_event integer,         -- mg/dL no momento
  ketones text check (ketones in ('negativo','traços','moderado','alto')),
  location text check (location in ('casa','hospital','trabalho','carro','exterior','outro')),
  trigger text check (trigger in ('doença','exercício','refeição','stress','sono','medicação','outro')),
  sick_day boolean default false,
  symptoms text,
  action text,
  recovery_time text,
  medication_note text,
  notes text,
  created_at timestamptz default now()
);

-- Adicionar colunas se tabela já existia (idempotente)
alter table medical_incidents add column if not exists end_date date;
alter table medical_incidents add column if not exists end_time text;
alter table medical_incidents add column if not exists glucose_at_event integer;
alter table medical_incidents add column if not exists ketones text;
alter table medical_incidents add column if not exists location text;
alter table medical_incidents add column if not exists trigger text;
alter table medical_incidents add column if not exists sick_day boolean default false;
alter table medical_incidents add column if not exists medication_note text;

create index if not exists idx_incidents_date on medical_incidents (date desc, time desc);
alter table medical_incidents enable row level security;
drop policy if exists "allow_all" on medical_incidents;
create policy "allow_all" on medical_incidents for all using (true) with check (true);

-- -----------------------------------------------------------------------------
-- 2. LEITURAS DE GLICEMIA
-- -----------------------------------------------------------------------------
create table if not exists glucose_readings (
  id text primary key,
  datetime timestamptz not null,
  value_mgdl integer not null,
  context text check (context in ('jejum','pré-refeição','pós-refeição-1h','pós-refeição-2h','noturno','exercício','sick-day','outro')),
  source text check (source in ('sensor','picada','outro')),
  sensor_model text,
  notes text,
  incident_id text references medical_incidents(id) on delete set null,
  created_at timestamptz default now()
);

create index if not exists idx_glucose_datetime on glucose_readings (datetime desc);
alter table glucose_readings enable row level security;
drop policy if exists "allow_all" on glucose_readings;
create policy "allow_all" on glucose_readings for all using (true) with check (true);

-- -----------------------------------------------------------------------------
-- 3. LOG DE EQUIPAMENTO
-- -----------------------------------------------------------------------------
create table if not exists equipment_log (
  id text primary key,
  date date not null,
  time text,
  equipment_type text not null check (equipment_type in ('sensor','bomba','reservatório','cateter','outro')),
  equipment_model text,
  event_type text not null check (event_type in ('troca','falha','alarme','calibração','outro')),
  notes text,
  incident_id text references medical_incidents(id) on delete set null,
  created_at timestamptz default now()
);

create index if not exists idx_equipment_date on equipment_log (date desc);
alter table equipment_log enable row level security;
drop policy if exists "allow_all" on equipment_log;
create policy "allow_all" on equipment_log for all using (true) with check (true);

-- -----------------------------------------------------------------------------
-- 4. CONSULTAS MÉDICAS
-- -----------------------------------------------------------------------------
create table if not exists medical_appointments (
  id text primary key,
  date date not null,
  specialty text not null,
  doctor text,
  location text,
  hospital text,
  hba1c numeric(4,2),
  notes text,
  next_appointment date,
  created_at timestamptz default now()
);

create index if not exists idx_appointments_date on medical_appointments (date desc);
alter table medical_appointments enable row level security;
drop policy if exists "allow_all" on medical_appointments;
create policy "allow_all" on medical_appointments for all using (true) with check (true);

-- -----------------------------------------------------------------------------
-- 5. MEDICAÇÃO CRÓNICA
-- -----------------------------------------------------------------------------
create table if not exists medications_baseline (
  id text primary key,
  name text not null,
  dose text,
  unit text,
  frequency text,
  device text,
  start_date date,
  notes text,
  active boolean default true,
  created_at timestamptz default now()
);

alter table medications_baseline enable row level security;
drop policy if exists "allow_all" on medications_baseline;
create policy "allow_all" on medications_baseline for all using (true) with check (true);

-- -----------------------------------------------------------------------------
-- 6. MEDICAÇÃO TEMPORÁRIA
-- -----------------------------------------------------------------------------
create table if not exists medications_temporary (
  id text primary key,
  name text not null,
  dose text,
  unit text,
  frequency text,
  start_date date not null,
  end_date date,
  duration_days integer,
  reason text,
  notes text,
  incident_id text references medical_incidents(id) on delete set null,
  hospital_episode_id text,         -- ligação ao episódio hospitalar
  created_at timestamptz default now()
);

create index if not exists idx_medtemp_start on medications_temporary (start_date desc);
alter table medications_temporary enable row level security;
drop policy if exists "allow_all" on medications_temporary;
create policy "allow_all" on medications_temporary for all using (true) with check (true);

-- -----------------------------------------------------------------------------
-- 7. EPISÓDIOS HOSPITALARES / URGÊNCIAS
-- -----------------------------------------------------------------------------
create table if not exists hospital_episodes (
  id text primary key,
  date_in date not null,
  time_in text,
  date_out date,
  time_out text,
  hospital text not null,
  service text,                     -- ORL, Urgências, Cardiologia, etc
  doctor text,
  episode_type text check (episode_type in ('urgente','programado','consulta','cirurgia','outro')),
  reason_in text,                   -- motivo de ingresso
  diagnosis text,                   -- diagnóstico principal
  procedures text,                  -- procedimentos realizados
  evolution text,                   -- evolução clínica
  discharge_notes text,             -- instruções de alta
  glucose_at_admission integer,     -- glicemia na entrada
  hba1c_at_admission numeric(4,2),  -- HbA1c se pedida
  notes text,
  created_at timestamptz default now()
);

create index if not exists idx_episodes_date on hospital_episodes (date_in desc);
alter table hospital_episodes enable row level security;
drop policy if exists "allow_all" on hospital_episodes;
create policy "allow_all" on hospital_episodes for all using (true) with check (true);

-- Adicionar FK de medications_temporary para hospital_episodes
alter table medications_temporary
  add constraint fk_medtemp_episode
  foreign key (hospital_episode_id)
  references hospital_episodes(id)
  on delete set null;

-- -----------------------------------------------------------------------------
-- 8. HISTORIAL MÉDICO (lista cronológica de diagnósticos)
-- -----------------------------------------------------------------------------
create table if not exists medical_history (
  id text primary key,
  date date not null,
  diagnosis text not null,
  source text check (source in ('SNS','privado','auto','outro')),
  status text check (status in ('ativo','resolvido','crónico','em-seguimento')) default 'ativo',
  specialty text,
  notes text,
  episode_id text references hospital_episodes(id) on delete set null,
  created_at timestamptz default now()
);

create index if not exists idx_history_date on medical_history (date desc);
alter table medical_history enable row level security;
drop policy if exists "allow_all" on medical_history;
create policy "allow_all" on medical_history for all using (true) with check (true);

-- -----------------------------------------------------------------------------
-- 9. PERFIL MÉDICO BASE (registo único — upsert por id fixo)
-- -----------------------------------------------------------------------------
create table if not exists medical_profile (
  id text primary key default 'bernardo',
  allergies text,
  chronic_conditions text,          -- lista texto livre
  surgeries text,                   -- cirurgias prévias
  family_history text,              -- antecedentes familiares
  habits text,                      -- hábitos (ex-fumador, etc)
  active_devices text,              -- dispositivos ativos (bomba, sensor)
  blood_type text,
  notes text,
  updated_at timestamptz default now()
);

alter table medical_profile enable row level security;
drop policy if exists "allow_all" on medical_profile;
create policy "allow_all" on medical_profile for all using (true) with check (true);

-- Inserir perfil base do Bernardo (não sobrescreve se já existir)
insert into medical_profile (id, allergies, chronic_conditions, surgeries, family_history, habits, active_devices, notes)
values (
  'bernardo',
  'Episódio de cetoacidose euglicémica por dapagliflozina',
  'Diabetes Mellitus tipo 1 (desde 2003) · Síndrome ansioso-depressivo · Obesidade · RGE · SAOS · Nódulo tiróide 8.2mm · Retinopatia diabética · Meralgia parestésica · Hernia discal L4-L5',
  'Túnel cárpico · Fimose · Criptorquidia direita',
  'Pai: DM · HTA · Hipoacusia · Obesidade',
  'Ex-fumador (>8 anos sem fumar) · Sem álcool · Sem outras substâncias',
  'Medtronic 780G (bomba insulina) · Guardian 4 (sensor CGM) · Insulina Novorrapid',
  'Seguimento endocrinologia. DM1 com bomba desde 2003.'
)
on conflict (id) do nothing;
