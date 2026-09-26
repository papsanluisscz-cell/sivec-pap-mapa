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

## 3. SIVEC PAP — preço proposto

| Estabelecimento | Mensalidade | Implantação (uma vez) |
|---|---|---|
| Centro de saúde (1º nível) | **Bs 700** (~US$ 100) | Bs 3.500 |
| Hospital 2º nível (colposcopia) | **Bs 1.750** | Bs 7.000 |
| 3º nível / laboratório / Oncológico | **Bs 3.500** | Bs 10.500 |
| Tablero da rede (gestor) e administração | incluído | — |

**Faixa de negociação:** mínimo Bs 500 e teto Bs 1.000 por centro de 1º nível; os demais valores na mesma proporção.

### O que isso dá

| Escala | Composição (**suposto**, confirmar) | Por mês | Por ano | Implantação |
|---|---|---|---|---|
| **Red Centro** | 9 centros + 1 hospital 2º nível + Oncológico | Bs 11.550 | **Bs 138.600** (~US$ 19.900) | Bs 35.000 (8 centros novos + hospital) |
| **Município de Santa Cruz** | ~50 centros + 5 hospitais 2º + 1 laboratório | Bs 47.250 | **Bs 567.000** (~US$ 81.500) | ~Bs 200.000 |
| **Bolívia** | ~3.000 estabelecimentos de 1º nível | ~Bs 2,1 milhões | **~Bs 25 milhões** (~US$ 3,6 mi) | — |

- **Custo por toma na Red Centro:** Bs 138.600 ÷ ~4.800 tomas/ano ≈ **Bs 29 por toma**. É quase o mesmo que a taxa de uma toma sem SUS (Bs 30), um argumento fácil de entender.
- **Comparação:** o registro da Austrália custa ≈ US$ 1,1 por habitante por ano. O SIVEC PAP nacional sairia por ≈ US$ 0,29 por habitante por ano, e faz mais: consulta, D1 e circuito do laboratório.
- **Forma de contratação na Bolívia:**
  - Red Centro, no 1º ano (~Bs 174 mil com a implantação): **ANPE** (Bs 50 mil a 1 milhão).
  - Um contrato-teste abaixo de Bs 50 mil pode ser **contratação menor**.
  - O município inteiro fica perto do limite da ANPE. Acima disso, **licitação pública**.

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
