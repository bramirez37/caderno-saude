# Caderno de Saúde — Roadmap de Desenvolvimento

## v2.1 — Bugs + Devices (pendente)
- [ ] **Bug #1** — Equipamento vazio após import (o importador JSON não trata a chave `equipamento`)
- [ ] **Bug #2** — Botões A− / A+ de fonte ausentes do código (foram removidos ou nunca implementados)
- [ ] **Nova tabela `devices`** — registo permanente dos dispositivos:
  - Bomba: marca, modelo, número de série
  - Sensor: marca, modelo, número de série, número de lote
  - Tab Equipamento passa a ter duas secções: "Os meus dispositivos" + "Log de eventos"
  - Migration `002_devices.sql`

## v2.2 — UX (pendente)
- [ ] Editar registos (actualmente só existe apagar)
- [ ] Filtro por data em todas as tabelas (existe filtro por gravidade em Incidentes; nada mais)
- [ ] Melhor aproveitamento de espaço horizontal

## v2.3 — Análise (pendente)
- [ ] Gráfico de tendência de glicemia
- [ ] Relatório mensal para consulta
- [ ] HbA1c timeline

## v2.4 — Import (pendente)
- [ ] Suporte a `medicacaoCronica` no importador (`confirmImport`)
  - Tabela Supabase: `medications_baseline`
  - Campos: `id`, `name`, `dose`, `unit`, `frequency`, `device`, `start_date`, `notes`, `active`
  - Chaves JSON a aceitar: `medicacaoCronica` ou `medications_baseline`

## v2.5 — Digitalizar (em desenvolvimento)
- [ ] Novo tab "Digitalizar" com upload de foto de documento físico
- [ ] Compressão client-side da imagem antes do envio
- [ ] Análise por IA (Claude API com visão) — extracção de dados clínicos relevantes
- [ ] Preview dos dados extraídos antes de guardar
- [ ] Confirmação e gravação nas tabelas correctas (consultas, historial, medicação, episódios)
- [ ] Chave API Anthropic guardada em localStorage (nunca no código)
- [ ] Requisições de exames ainda por fazer: identificadas mas não registadas como resultados

## v2.6 — Tab CGM / Sensor (pendente)
- [ ] Substituir tab Glicemia vazio por tab CGM estruturado
- [ ] Campos e intervalos de referência clínica documentados no roadmap

## v2.7 — Resultados de Análises (pendente)
- [ ] Tabela `lab_results` — valores laboratoriais estruturados
  - `id`, `date`, `report_id` (FK futura), `test_name`, `value`, `unit`, `ref_min`, `ref_max`, `flag`
  - Integração com tab Digitalizar para extracção automática de analíticas
  - Timeline de valores por parâmetro (HbA1c, TSH, ferritina, função renal, lípidos)

## v2.8 — Multilíngue (pendente)
- [ ] Suporte PT, ES, EN
