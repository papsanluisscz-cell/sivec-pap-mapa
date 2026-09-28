# SIVEC — Mercado e preço (pesquisa de 26/09/2026)

> Estimativa para decidir o preço. Valores em bolivianos (Bs) com US$ 1 ≈ Bs 6,96.
> Onde diz **suposto**, é um número que precisa ser confirmado antes de entrar numa proposta.

## 1. Existe algo igual ao SIVEC no mundo?

**Igual, não.** O que existe se divide em dois grupos. Nenhum faz o circuito inteiro do tamizaje com a consulta, a receita e o seguimento no mesmo lugar, como o SIVEC PAP.

### A. Registros de tamizaje do governo
São feitos pelo próprio governo e gratuitos para quem usa. Servem para registrar exames e resultados; não fazem consulta, receita nem D1.

| País | Sistema | Quem fez / quem paga | Como funciona | Custo público |
|---|---|---|---|---|
| Argentina | **SITAM** (desde 2009, 21 províncias) | Instituto Nacional del Cáncer (governo) | Online, registra toma → diagnóstico → tratamento; dados agregados por província, laboratório e unidade de toma; mesa de ajuda e capacitação | Não publicado (feito internamente) |
| Brasil | **SISCAN** (substituiu SISCOLO/SISMAMA) | DATASUS / Ministério da Saúde | Web; requisição e laudo do citopatológico; painéis públicos no TabNet | Não publicado (DATASUS interno) |
| Austrália | **National Cancer Screening Register** | Contratado à **Telstra**: **A$ 220 milhões em 5 anos** | Registro nacional de chamado e seguimento do colo do útero e do intestino | ≈ A$ 44 milhões/ano. Auditoria (ANAO): atrasos, custos extras e falta de plano de privacidade |
| Inglaterra | **CSMS** (substituiu o Open Exeter/NHAIS) | NHS England Digital | Chamado e rechamado nacional, histórico da mulher | Valor do contrato não publicado |
| EUA | NBCCEDP (CDC) | Estados, via acordos com o CDC | O tamizaje fica dentro do prontuário de cada hospital (Epic, Oracle) | — |

### B. Prontuários eletrônicos completos (o que seria o "SIVEC geral")
São vendidos por empresas.

| Sistema | Empresa | Onde | Preço público encontrado |
|---|---|---|---|
| **Rayen** | Rayen Salud / Saydex (Chile) | 76% da atenção primária do Chile, mais de 400 estabelecimentos | Licença com agenda, farmácia, prontuário e vacinas: **US$ 5.800–6.670** |
| **TrakCare** | InterSystems (EUA) | 25 países; Uruguai, Chile, Colômbia, Peru | Não publicado (contratos grandes) |
| **Epic** | Epic Systems (EUA) | 42% dos leitos dos EUA | Licença de **US$ 500–1.000 por leito**; implantações de **US$ 50–200 milhões**; redes grandes acima de US$ 1 bilhão |
| **TELUS Health** | TELUS (Canadá) | O mais usado na atenção primária do Canadá | A partir de **CAD 100/mês por médico** |
| SaaS de consultório LatAm | Software Médico (CO), Integrando Salud (AR) etc. | Consultórios privados | Licença única de **~US$ 750** ou assinatura mensal |
| **EDUS** | CCSS (Costa Rica, feito internamente) | País inteiro | Não publicado |
| **HCEN** | Salud.uy / Agesic (Uruguai) | País inteiro, 92% da população com documentos | **~US$ 21 milhões do BID** (2013–2021), só para a interoperabilidade nacional |
| **DHIS2** | Universidade de Oslo (software livre) | Mais de 70 países | Software grátis; o país paga servidor, equipamentos e capacitação |

### C. Na Bolívia (o concorrente mais importante)
- O Ministério tem o **SOAPS** no 1º nível e o **SICE** no 2º e 3º níveis, dentro do **SUIS** (RM 0323/2024). A política é de **software livre e padrões abertos**.
- **Isso é concorrência e oportunidade ao mesmo tempo.** O SIVEC não pode ser vendido como "substituto" de um sistema que o Ministério entrega de graça. Tem que ser vendido como **o circuito que falta**: lote com código de barras, laudo digital do laboratório, derivação e contrarreferência de colposcopia, busca ativa e tablero da rede. E, com o tempo, precisa **exportar para o SNIS/SOAPS**, para ninguém digitar duas vezes.
- **Quem compra:**
  - O **município** (GAM Santa Cruz) é dono do 1º nível: os centros de saúde.
  - A **Gobernación/SEDES** responde pelo 2º, 3º e 4º níveis: hospitais e Oncológico.
  - O **programa de câncer** pode ser o patrocinador.

## 2. Como cobrar (modelo recomendado)

**Assinatura mensal por estabelecimento** (SaaS). Inclui hospedagem, cópias de segurança, suporte, atualizações e capacitação de pessoal novo. A implantação é um valor único por estabelecimento, cobrado à parte.

- **Por que por estabelecimento, e não por usuário:** o governo quer que todo o pessoal use, sem contar pessoas.
- **Alternativa se o comprador exigir "ser dono":** licença perpétua do município mais suporte anual de 20%. Nesse caso a hospedagem é paga por eles.

## 3. SIVEC PAP — preços definidos pelo autor (atualizados 28/09/2026)

| Estabelecimento | Mensalidade | Implantação (uma vez) |
|---|---|---|
| 1º nível sem colposcopia nem biópsia (cidade ou província) | **US$ 120** (Bs 835,20) | US$ 225 (Bs 1.566) |
| 1º nível com colposcopia e biópsia | **US$ 270** (Bs 1.879,20) | US$ 225 (Bs 1.566) |
| 2º nível (hospital) | **US$ 275** (Bs 1.914) | US$ 525 (Bs 3.654) |
| 3º e 4º nível e laboratórios de citologia PAP e de VPH | **US$ 521** (Bs 3.626,16) | US$ 575 (Bs 4.002) |
| Tablero da rede e administração | **US$ 250** (Bs 1.740) | US$ 275 (Bs 1.914) |

### Exemplo: Red Centro + Oncológico
| Estabelecimento | Qtd. | US$/mês | Implantação US$ |
|---|---|---|---|
| 1º nível sem colposcopia | 8 | 960 | 1.800 |
| 1º nível com colposcopia e biópsia | 1 | 270 | 225 |
| 2º nível | 1 | 275 | 525 |
| Oncológico com laboratório PAP/VPH | 1 | 521 | 575 |
| **Total** | **11** | **US$ 2.026/mês** (Bs 14.100,96) · **US$ 24.312/ano** (Bs 169.211,52) | **US$ 3.125** (Bs 21.750) |

**Primeiro ano (mensalidades + implantação): US$ 27.437 (Bs 190.961,52).** Contratação por ANPE (entre Bs 50 mil e 1 milhão).

## 4. SIVEC geral (completo) — referência

Usando o modelo financeiro (`SIVEC-modelo-financiero.xlsx`), que já estava calibrado:

| Estabelecimento | Mensalidade |
|---|---|
| 1º nível | **US$ 180** (~Bs 1.250) |
| 2º nível | **US$ 1.400** (~Bs 9.750) |
| 3º nível | **US$ 3.800** (~Bs 26.450) |

- **Bolívia completa:** ≈ **US$ 14,2 milhões/ano**, ou ≈ US$ 1,16 por habitante por ano. Ponto de equilíbrio ≈ 108 centros de 1º nível.
- **Comparação:** o Rayen cobra ~US$ 6 mil de licença por estabelecimento, mais manutenção. O SIVEC geral custa US$ 2.160/ano por centro, com hospedagem e suporte incluídos. O Uruguai gastou ~US$ 21 milhões só para interligar os prontuários. O Epic está em outra escala: centenas de milhões.
- **O SIVEC PAP é a porta de entrada.** Cada módulo novo (pré-natal, vacinas, TB, farmácia) sobe o preço por centro até chegar ao SIVEC geral. Quem já usa o PAP não precisa de implantação nova.

## 5. Antes de apresentar o preço

1. Confirmar com o município quantos centros e hospitais existem por rede (troca os **supostos**).
2. Registrar o software no **SENAPI** (direito de autor) antes de mostrar a outros compradores.
3. Ter a empresa constituída e habilitada no SICOES, para poder ser contratado (ver `SIVEC-guia-empresa-a-venta.md`).
4. Preparar a exportação para SNIS/SOAPS: é a primeira pergunta que o Ministério vai fazer.

## Fontes
- ANAO — [Procurement of the National Cancer Screening Register](https://www.anao.gov.au/work/performance-audit/procurement-national-cancer-screening-register) · [iTnews: contrato de US$ 220 mi da Telstra](https://www.itnews.com.au/news/telstra-could-lose-220m-cancer-register-contract-514144)
- Argentina — [SITAM, Instituto Nacional del Cáncer](https://www.argentina.gob.ar/salud/instituto-nacional-del-cancer/institucional/sitam)
- Brasil — [SISCAN, DATASUS](https://datasus.saude.gov.br/acesso-a-informacao/sistema-de-informacao-do-cancer-siscan-colo-do-utero-e-mama/)
- Inglaterra — [CSMS, NHS England Digital](https://digital.nhs.uk/services/cervical-screening-management-system)
- Chile — [Rayen Salud](https://www.rayensalud.com/) · [Saydex](https://www.gerencia.cl/proveedores/saydex-innovacion-en-registro-clinico-electronico-en-chile/)
- InterSystems — [TrakCare](https://www.intersystems.com/products/trakcare/)
- Epic — [Custos de implantação](https://hyscaler.com/insights/epic-cost-for-a-hospital/) · [Preços 2026](https://topflightapps.com/ideas/epic-ehr-cost/)
- Canadá — [Guia de EMR da atenção primária](https://tali.ai/resources/a-guide-to-canadian-primary-care-s-electronic-medical-record) · [OSCAR vs TELUS](https://www.itqlick.com/compare/oscar-emr/inputhealth)
- Uruguai — [HCEN (BID)](https://publications.iadb.org/en/uruguays-national-electronic-health-record-system) · [Salud digital](https://saluddigital.com/big-data/la-transformacion-digital-de-la-salud-en-uruguay-y-la-historia-clinica-electronica/)
- Costa Rica — [EDUS (BID)](https://publications.iadb.org/en/costa-ricas-unified-digital-health-record-edus-system-best-practices-history-and-implementation)
- DHIS2 — [Planejamento e orçamento](https://docs.dhis2.org/en/implement/implementing-dhis2/planning-and-budgeting.html)
- Bolívia — [SOAPS, SNIS](https://snis.minsalud.gob.bo/soaps) · [SUIS (Ministério de Saúde, 2025)](https://transformaciondigital.ubpbo.net/assets/pdf/14%20-%20SUIS%20-%20Grisel%20Villalta%20-%20Ministerio%20de%20Salud.pdf)
- SaaS LatAm — [Software Médico (preços)](https://softwaremedico.com.co/precios/)
