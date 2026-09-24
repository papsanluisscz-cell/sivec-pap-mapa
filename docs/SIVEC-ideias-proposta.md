# SIVEC — Anotações para a proposta

> Arquivo vivo: aqui se juntam as ideias para a proposta do SIVEC antes de redigir o documento final.
> Cada ideia nova é acrescentada; nada é apagado sem combinar.

**SIVEC = Sistema Integral de Vigilancia y Enlace Clínico**

---

## 1. Visão geral (ideias do autor)

- O SIVEC deve ser **um sistema único que vincule todas as redes e todos os centros de saúde**.
- Deve servir **desde o primeiro contato com o paciente** (recepção) como **história clínica digital**.
- **Todos os formulários digitais**: acabar com o papel.
- **Compartilhamento de dados entre redes**: se um paciente cadastrado em outra rede for atendido, quem o atende **fica sabendo e pode informar** (histórico acessível em qualquer centro).
- Implementação planejada: começar na **Red Centro** (todos os seus centros) e depois expandir para outras redes.
- O que existe hoje (SIVEC PAP/VPH) vira **um programa (módulo) dentro do SIVEC maior**.

## 2. Programas / módulos que devem estar dentro

- PAP / VPH (já existe: SIVEC PAP/VPH)
- Tuberculose
- Raiva
- Chagas
- "Ravia" (confirmar com o autor qual programa é)
- **Todos os programas** de saúde do centro (lista a completar)

## 3. Funcionalidades clínicas desejadas

- **Receituário** digital.
- **Laboratórios**: pedido digital + lugar para registrar o resultado quando chegar.
- **Histórico do paciente** (botão "Historial"), gerado automaticamente, por exemplo:
  - nome, idade, naturalidade (de onde é);
  - antecedentes patológicos, cirúrgicos, alérgicos;
  - resistência a medicamentos;
  - últimos laboratórios com data;
  - **foto tirada na recepção** no momento de abrir a história clínica.
- **Derivação** (referência / contrarreferência) com registro dos **tempos** de cada etapa.
- **Resgate** (busca ativa) do paciente quando necessário.
- Registro do **tempo de tudo** (da toma ao resultado, do resultado à entrega, da derivação ao atendimento etc.).

## 4. Métricas e painéis

- Cada **responsável de rede** deve ter **métricas e painéis** próprios para ver tudo e acessar os dados da sua rede.
- (A definir) níveis: centro → rede → SEDES.

## 5. Integrações externas

- **SEGIP** (emite a cédula de identidade e as licenças de conduzir na Bolívia): usar para **identidade única** do paciente (CI + complemento). Integração via **convênio institucional** (pedido pela Red/SEDES). Condições técnicas a confirmar com o SEGIP.
- **Hospital Oncológico**: receber os **resultados das tomas** direto no sistema (sem papel).
- (A confirmar) sistemas oficiais do Ministério / SUS / SNIS para integrar em vez de duplicar.

## 6. Organização proposta (sugestão do Claude, a discutir)

- A **pessoa é o centro**, os **programas são módulos**:
  - PERSONA (única: CI + complemento, nome, nascimento, foto, contato)
  - Resumo clínico (antecedentes, alergias, resistências, últimos labs)
  - Atenções (quem, onde, quando), em qualquer centro de qualquer rede
  - Programas (PAP/VPH, TB, Chagas, Raiva, …)
  - Laboratório (pedido → resultado), Receita, Referência/contrarreferência/resgate
  - ESTABELECIMENTO → REDE → SEDES (define quem vê o quê e os painéis)
- **Fases**:
  0. PAP/VPH estável no San Luis (SQL passos 1–2, login + RLS).
  1. Multi-centro: tabela de centros/redes, seletor de centro, usuários por centro, sistema hospedado na web (sem arquivo HTML).
  2. Pessoa única + resumo clínico ("Historial" com foto e antecedentes); PAP/VPH como primeiro módulo.
  3. Laboratório, receita e outros programas sobre a mesma base.
  4. Painéis por rede/SEDES; integrações (SEGIP, Oncológico) via API; referência e resgate com tempos.
- **Piloto** em 2–3 centros antes de expandir.

## 7. Riscos e condições a tratar na proposta

- Autorização institucional (Red/SEDES), consentimento e **registro de quem acessou cada ficha** (auditoria).
- Não duplicar sistemas oficiais existentes; integrar-se.
- Zonas rurais sem internet: funcionar **offline** e sincronizar depois.
- **Armazenamento e custos** (fotos, laudos): orçamento e responsável pelo servidor.
- Não depender de uma só pessoa: documentação e equipe de manutenção.

## 8. Decisões já tomadas no SIVEC PAP/VPH (referência)

- Nome: **SIVEC PAP/VPH**; cabeçalho com a sigla por extenso.
- Futuro **seletor de centro de saúde** (Red Centro) no lugar do nome fixo "Centro de Salud San Luis".
- Resultados enviados às pacientes pelo **grupo de WhatsApp do Papanicolau** (por isso não há botão de WhatsApp individual).
- Mapa para toda a Bolívia (províncias e zonas rurais).
- Pastas do Google Drive mantêm o nome "SIVEC-PAP San Luis" até organizarmos por centro.
- Pendentes para a versão final: menu inferior para celular; tela de "Início" com as tarefas do dia.

---

## Novas ideias (acrescentar abaixo)


### [23/09/2026] Resultados compartilhados entre centros (sem papel)

**Ideia do autor:** quando um centro envia o paciente a outro centro para fazer **raio X, ecografia ou laboratórios**, o centro que realiza o estudo **coloca o resultado direto na ficha do paciente** e **todos podem ver**, independentemente do centro. Sem papel.

**Proposta de funcionamento (sugestão do Claude):**
- Um único módulo **"Estudios"** (pedido → resultado) para tudo: laboratório, imagem (RX, eco), PAP/VPH, anatomia patológica.
  O PAP/VPH que já existe é exatamente esse fluxo (toma → resultado do Oncológico), então vira o primeiro caso do módulo.
- **1. Pedido digital** no centro de origem: tipo de estudo, motivo/diagnóstico presuntivo, urgência, centro de destino, quem pediu.
  Gera um **código/QR** (a paciente pode levar no celular ou impresso, mas não é obrigatório: basta o CI).
- **2. Centro que realiza**: busca pelo CI, vê os **pedidos pendentes** daquela pessoa, registra "realizado" e depois carrega o **resultado**:
  - laboratório: valores estruturados (ex.: hemoglobina 11,2 g/dL, com referência) → permite gráficos de evolução e alertas de valores críticos;
  - imagem: **laudo** em texto + arquivo (PDF/foto do laudo; imagens-chave). Imagens completas (DICOM/PACS) ficam para uma fase posterior pelo tamanho.
  - quem assinou o resultado e quando.
- **3. Aviso automático** ao profissional/centro que pediu ("resultado disponível"), e o resultado aparece no **Historial** do paciente em qualquer centro.
- **Estados e tempos**: pedido → realizado → resultado → visto pelo solicitante → entregue ao paciente. Cada etapa com data/hora → métricas de demora por centro e por tipo de estudo para os painéis de rede.
- Também permitir **resultados sem pedido prévio** (paciente chegou direto) ligados ao CI.
- **Valores críticos** (ex.: glicemia muito alta, HSIL): alerta destacado ao solicitante e ao responsável.
- **Segurança**: cada acesso a um resultado fica registrado (quem viu, quando, de qual centro).
- **Padrão de interoperabilidade**: desenhar desde o início compatível com **HL7 FHIR** (ServiceRequest = pedido, DiagnosticReport/Observation = resultado), o que facilita integrar depois com o Oncológico, laboratórios privados e o Ministério.
- **Impacto esperado**: menos estudos repetidos, menos papel perdido, menos viagens da paciente só para buscar resultado, e métricas reais de tempo de espera.

### [23/09/2026] Imagens de raio X/ecografia e laudos com modelo pronto

**Ideia do autor:** as **imagens** (raio X, eco) **precisam** estar no sistema, apesar de pesadas. O médico que informa deve ter o **laudo pré-pronto (modelo) para editar**.

**Proposta de funcionamento (sugestão do Claude):**
- **Imagens em dois níveis**
  1. **Imagem para visualizar** (sempre): versão comprimida em JPEG/WebP (~0,3–1 MB por imagem), com visor web simples (zoom, brilho/contraste, girar). Abre rápido até com internet fraca.
  2. **Arquivo original** (quando existir): o DICOM do equipamento digital, guardado em armazenamento separado ("arquivo frio", mais barato), baixado só quando o especialista precisa. Mais adiante, visor DICOM completo (ex.: OHIF, software livre).
- **Como a imagem entra**, conforme o equipamento de cada centro:
  - equipamento digital (CR/DR, ecógrafo com saída): exportar a imagem/DICOM e subir;
  - equipamento com filme: **foto do filme no negatoscópio** com o celular, direto no sistema (menor qualidade, mas melhor que papel perdido);
  - ecografia: capturas-chave do ecógrafo.
  → Fazer **levantamento dos equipamentos** de cada centro da Red Centro (dado importante para a proposta).
- **Estimativa de espaço** (a validar com números reais):
  - só JPEG/WebP: ~0,5 MB × 10.000 estudos/ano ≈ **5 GB/ano** → barato;
  - com DICOM original: ~10–30 MB por estudo → **100–300 GB/ano** → requer orçamento e política de retenção (ex.: original por X anos, versão leve permanente).
- **Laudos com modelos editáveis**
  - **Modelos por tipo de estudo** (ex.: RX de tórax normal, eco obstétrica, eco pélvica, eco abdominal…) com o texto padrão e campos a preencher (medidas, idade gestacional etc.).
  - Botão **"Normal"**: carrega o modelo normal inteiro; o médico **só edita o que muda**.
  - **Frases frequentes** reutilizáveis e modelos próprios de cada médico.
  - Campos estruturados onde fizer sentido (ex.: medidas da eco) → permitem estatísticas e alertas.
  - Laudo **assinado** (nome, matrícula, data/hora); depois de assinado, qualquer correção fica registrada como **adendo** (não se apaga o original).
- O laudo + imagens aparecem no **Historial** do paciente em qualquer centro, e o solicitante recebe o aviso "resultado disponível".

### [23/09/2026] Códigos/números de registro gerados pelo próprio sistema

**Ideia do autor:** depois de aprovado, o SIVEC deve **gerar seus próprios códigos** (N° de registro D1, D8, PAP, história clínica etc.) em vez de ter campos para digitar números de folio do papel.

**Sugestão do Claude:**
- Numeração automática, **sequencial por centro e por ano**, sem repetição, ex.: `SL-2026-PAP-000123` (SL = centro San Luis).
- O código aparece impresso/QR nos documentos e serve para buscar o registro.
- Durante a transição, manter o campo do folio de papel como **"folio anterior"** (só para consulta), para não perder a ligação com os arquivos físicos.

### [23/09/2026] Foto do paciente

**Pergunta do autor:** colocar foto da paciente já no SIVEC PAP/VPH ou deixar para o SIVEC completo (ficha / história clínica)?

**Recomendação do Claude:** **deixar para o SIVEC completo**, na **recepção** (abertura da ficha), e não no PAP/VPH agora, porque:
- a foto é dado pessoal sensível → precisa **consentimento** e **segurança ativa (login + RLS)** antes;
- ocupa armazenamento e precisa de política (quem vê, por quanto tempo);
- no PAP/VPH a identificação já se resolve com CI + nome + data de nascimento;
- no SIVEC a foto será **uma só por pessoa**, compartilhada por todos os programas (não uma por módulo).

### [23/09/2026] "Chat" / assistente com a história clínica

**Ideia do autor:** um tipo de **chat** que apresente a **história clínica atual**, os **resultados de laboratório** e os **antecedentes** do paciente.

**Como formular (sugestão do Claude)** — em três camadas, cada uma útil sozinha:
1. **Dados organizados** (base obrigatória): antecedentes, alergias, resistências, medicação, estudos e resultados, atenções — tudo estruturado e com data/centro/autor. Sem isso, nenhum chat funciona bem.
2. **"Resumo clínico" automático** (botão *Historial*): uma ficha de uma tela gerada pelo sistema, sempre igual e confiável:
   - identificação (nome, idade, naturalidade, foto);
   - **alertas** em destaque (alergias, resistência a medicamentos, gestação, valores críticos);
   - problemas ativos e antecedentes (patológicos, cirúrgicos, gineco-obstétricos);
   - últimos resultados com data e centro; programas em que está (PAP/VPH, TB…); pendências (estudos pedidos, derivações abertas).
3. **Assistente em conversa (opcional, fase posterior)**: o profissional pergunta em linguagem natural, ex.: *"quais foram os últimos laboratórios da paciente?"*, *"teve algum PAP alterado?"*, *"resuma a evolução da glicemia"*, e o assistente responde **só com os dados da ficha**, **citando a data e o centro de cada dado**.

**Regras para o assistente (a incluir na proposta):**
- Responde apenas com o que está registrado; **se não houver dado, diz que não há** (não inventa).
- Mostra sempre a **fonte** (qual registro, data, centro) para o profissional conferir.
- **Não decide condutas**: apoia a leitura; a decisão é do profissional.
- Cada consulta fica no **registro de auditoria**.
- **Privacidade**: enviar dados de pacientes a um serviço de IA externo exige **autorização institucional** e acordo de proteção de dados; alternativa: rodar o modelo em servidor próprio. Decidir isso com a Red/SEDES.
- **Decisão do autor (23/09/2026):** aprovado incluir no plano. Na proposta, apresentar o **Resumo clínico** como **entrega garantida** e o **assistente em conversa** como **evolução** (depende de autorização sobre privacidade/IA).

### [23/09/2026] Redes, centros e usuários — APROVADO (implementar em breve)

O autor aprovou o esboço `docs/esboco-redes-centros.html` (painel de administração e métricas por centro). **Implementar em breve, não agora.**
- Login obrigatório; cada usuário pertence a um **centro** (vê só o seu) ou a uma **Rede** (vê todos os centros da Rede, com seletor "Todos / centro X").
- **Panel de Red** com tabela comparativa por centro.
- **Administração** (só o administrador): criar Redes, centros, usuários e a lista de doutoras de cada centro.
- Proteção pelo banco (RLS); pacientes atuais → **C.S. San Luis**.
- **Pendente de decisão do autor antes de implementar:**
  1. responsável de Rede só vê ou também edita?
  2. aviso "🔗 também em outro centro" (sem dados clínicos)?
  3. quem é o Administrador?
  4. lista exata dos centros da Red Centro e suas doutoras;
  5. um usuário por centro ou um por profissional (recomendado: um por profissional).

### [23/09/2026] Panel novo (esboço `docs/esboco-panel.html`, aguardando aprovação)
Números animados com tendência, embudo "Del tamizaje al seguimiento", "Para hacer hoy", barras em vez de tortas, filtros de período e doutora, modo escuro.

### [24/09/2026] Linha do tempo da paciente — IMPLEMENTADA no PAP/VPH e base do "Historial" do SIVEC

**Decisão do autor:** a ficha lateral com **linha do tempo** é exatamente o modelo de história clínica que se quer para o **SIVEC completo** (não só PAP).
- Já implementada no SIVEC PAP/VPH (aba Pacientes → tocar a paciente): identificação, próximo passo, alertas e todos os eventos em ordem (tomas, resultados PAP/Bethesda, VPH e genótipo, entregas, seguimento, derivação, colposcopias, método anticonceptivo, próximo controle), com botões Editar / Imprimir / Nova toma.
- **No SIVEC completo** a mesma linha do tempo recebe eventos de todos os módulos, cada um com ícone/cor própria e o **centro** onde aconteceu:
  consultas, **resultados de laboratório** (valores + referência), **imagens e laudos** (RX/eco), receitas, vacinas, programas (TB, Chagas, Raiva…), derivações/contrarreferências, internações.
- Filtros por tipo de evento e por período; no topo, o **Resumo clínico** (alergias, resistências, antecedentes) e a foto da recepção.

### [24/09/2026] Linha do tempo completa (SIVEC) — organização
**Ideia do autor:** a linha do tempo do SIVEC deve ter **todas** as informações, organizadas por tipo:
- **Laboratórios recentes** (destacados no topo);
- **Laboratórios de rotina** (histórico, com evolução dos valores);
- **Imagens** (RX, eco — laudo + imagem);
- **Pedidos de laboratório/imagem não realizados** (pendentes, com dias de espera);
- tudo se completando automaticamente à medida que os centros ficam interligados.

**Sugestão do Claude para a tela:** abas/filtros no topo da ficha — *Tudo · Laboratório · Imagens · Pedidos pendentes · Programas · Receitas* — e um bloco fixo "Últimos resultados" (os 5 mais recentes, com seta ↑↓ comparando com o anterior).

### [24/09/2026] Modelo de negócio (ideia do autor, a desenvolver)
- Vender o SIVEC PAP/VPH (estimativa do autor: USD 8.000–16.000), escalável por redes/centros.
- Depois vender a **atualização para o SIVEC completo** (todos os módulos).
- Pontos a resolver antes de vender: titularidade/direitos do software, hospedagem e backups profissionais, segurança (login+RLS), contrato de suporte e manutenção, adequação às regras de contratação pública.

### [24/09/2026] Piloto, autoria e financeiro
- **Piloto:** o SIVEC PAP/VPH já funciona como piloto no C.S. San Luis com dados **desde janeiro de 2026**. Usar esses dados como evidência na proposta (indicadores reais: tomas, tempo toma→entrega, % entregues, positivas com seguimento, cobertura por idade, busca ativa).
- **Autoria:** a instituição quer dar ao autor um **reconhecimento e um documento de autoria** do programa. Depois, conversa sobre o **financeiro**.
- Incluir na proposta a seção **"Modelo de implantação e sustentabilidade"** (implantação + suporte/manutenção, por centro/rede; valores a completar pelo autor).
