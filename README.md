# Caderno de Saúde 🩺

App pessoal para registo de incidentes médicos — diabetes tipo 1, hipoglicemias, e outros eventos de saúde.

## Stack

- **Frontend**: HTML + CSS + JS vanilla (ficheiro único, sem build)
- **Backend**: [Supabase](https://supabase.com) (PostgreSQL via REST API)
- **Deploy**: Abre o `index.html` diretamente no browser

## Setup

### 1. Supabase

Cria o projeto em [supabase.com](https://supabase.com) e corre o seguinte SQL no **SQL Editor**:

```sql
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

create index if not exists medical_incidents_date_idx
  on medical_incidents (date desc, time desc);

alter table medical_incidents enable row level security;

create policy "allow_all" on medical_incidents
  for all using (true) with check (true);
```

### 2. Configura o `index.html`

Edita as duas constantes no início do script:

```js
const SUPABASE_URL = 'https://SEU-PROJETO.supabase.co';
const SUPABASE_KEY = 'SUA-ANON-KEY';
```

> ⚠️ **Nunca commites a anon key para um repositório público.**  
> Usa um ficheiro `.env` local ou guarda o HTML fora do repo se for público.

### 3. Abre no browser

```
open index.html
```

Não precisa de servidor. Abre direto no browser.

## Campos de cada incidente

| Campo | Tipo | Descrição |
|---|---|---|
| `id` | text | Identificador único (`inc-TIMESTAMP`) |
| `date` | date | Data (YYYY-MM-DD) |
| `time` | text | Hora (HH:MM) |
| `type` | text | Tipo de incidente (ver lista abaixo) |
| `typeCustom` | text | Descrição livre se `type = "Outro"` |
| `severity` | int | 1=Leve, 2=Moderado, 3=Grave |
| `sensorActive` | bool | Sensor de glicose ativo? (true/false/null) |
| `symptoms` | text | O que sentiu |
| `action` | text | O que fez |
| `recoveryTime` | text | Tempo a recuperar |
| `notes` | text | Notas adicionais |

**Tipos disponíveis**: Hipoglicemia, Hiperglicemia, Dor aguda, Tontura/desmaio, Reação adversa, Crise de pressão, Problema cardíaco, Reação alérgica, Outro.

## Importar do Claude

Quando reportares um incidente ao Claude, pede o JSON com este formato:

```json
{
  "id": "inc-1742089800000",
  "date": "2026-03-16",
  "time": "03:30",
  "type": "Hipoglicemia",
  "typeCustom": "",
  "severity": 3,
  "sensorActive": false,
  "symptoms": "Acordei com sensação de açúcares muito baixos",
  "action": "Comi tudo o que estava à frente",
  "recoveryTime": "~1 hora",
  "notes": "Sensor tinha acabado na véspera."
}
```

Cola no tab **Importar JSON** da app e clica em importar.

## Contexto

- Diabetes tipo 1 com sensor de glicose (troca às segundas de manhã)
- Incidentes podem ser de qualquer tipo médico, não só diabetes
- App para uso pessoal, sem autenticação (RLS aberta com anon key)
