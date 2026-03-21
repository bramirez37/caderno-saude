# Caderno de Saúde v2 🩺

App pessoal para gestão de saúde — diabetes tipo 1, incidentes médicos, historial clínico completo.

## Stack
- **Frontend**: HTML + CSS + JS vanilla (ficheiro único)
- **Backend**: Supabase (PostgreSQL via REST API)
- **Deploy**: GitHub Pages ou abrir localmente

## Setup rápido

### 1. Supabase — cria o schema
No SQL Editor do Supabase, corre o ficheiro `migrations/001_full_schema.sql` na íntegra.
Cria todas as tabelas, índices, RLS e insere o perfil base do Bernardo.

### 2. GitHub Pages
Faz upload do `caderno-saude.html` para o repositório e activa GitHub Pages.

## Tabelas

| Tabela | Descrição |
|---|---|
| `medical_incidents` | Incidentes do dia-a-dia (hipos, hipers, dores...) |
| `glucose_readings` | Leituras de glicemia |
| `equipment_log` | Trocas e falhas de sensor/bomba |
| `hospital_episodes` | Internamentos e urgências com papel |
| `medical_history` | Historial cronológico de diagnósticos |
| `medical_appointments` | Consultas médicas + HbA1c |
| `medications_baseline` | Medicação crónica |
| `medications_temporary` | Cursos temporários (antibióticos, etc) |
| `medical_profile` | Perfil base único (alergias, antecedentes...) |

## Funcionalidades

- **Dashboard** — glicemia atual, medicação ativa com countdown, próxima consulta
- **Incidentes** — com duração, glicemia, acetonas, sick day flag, trigger
- **Vista resumo** — últimos 10/20/50 em tabela + export CSV
- **Episódios hospitalares** — internamentos completos com diagnóstico, procedimentos, alta
- **Historial** — lista cronológica retroativa de todos os diagnósticos
- **Medicação** — crónica (lista estática) + temporária (com countdown)
- **Perfil** — alergias, doenças crónicas, cirurgias, antecedentes familiares
- **Importar** — preview antes de confirmar, múltiplos JSONs em simultâneo
- **Exportar** — backup completo com data + CSV de incidentes
- **Backup reminder** — aviso se não exportares há mais de 7 dias

## Importar do Claude

Quando reportares um episódio, o Claude gera o JSON completo.
Formato suportado — um objeto com múltiplos arrays:

```json
{
  "incidentes": [...],
  "glicemias": [...],
  "episodiosHospitalares": [...],
  "historico": [...],
  "medicacaoTemporaria": [...]
}
```

## Historial médico retroativo (lista SNS)

Para importar a lista de episódios do SNS (das interconsultas), usa:

```json
{
  "historico": [
    {"date": "2023-10-27", "diagnosis": "Retinopatia diabética", "status": "em-seguimento", "source": "SNS"},
    {"date": "2023-05-16", "diagnosis": "Trastorno depressivo persistente", "status": "crónico", "source": "SNS"},
    {"date": "2021-03-24", "diagnosis": "Cefaleia em cachos / cluster", "status": "em-seguimento", "source": "SNS"}
  ]
}
```

## Backlog

Ver BACKLOG.md para melhorias planeadas.
