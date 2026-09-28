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

### [24/09/2026] Seguimento dentro da linha do tempo — "onde está a paciente agora" (SIVEC completo)
**Ideia do autor:** a linha do tempo do SIVEC geral deve mostrar também o **seguimento**, para saber em que ponto do caminho a paciente está:
- se já **fez os exames** pedidos ou ainda não;
- se **foi ao laboratório** (amostra colhida, enviada, resultado pronto, entregue);
- se foi **derivada** e se chegou ao outro serviço (contrarreferência);
- se **faltou** ou **abandonou** (e há quantos dias).

**Requisito:** funciona de verdade só com **todos os centros e redes no SIVEC geral** (não só o PAP), porque cada passo acontece num lugar diferente (centro, laboratório, hospital, Oncológico).

**Sugestão do Claude:** no topo da ficha, uma **barra de etapas** do caso aberto (ex.: *Pedido → Laboratório → Resultado → Entregue → Tratamento → Alta*), com a etapa atual destacada, o centro responsável e os dias parado nela; cada etapa concluída vira um evento da linha do tempo. Casos parados há mais de X dias aparecem no Panel da rede ("para resgatar"). No PAP/VPH já existe uma versão disso (Seguimiento por etapas).

### [24/09/2026] Consulta com figuras (SOAP visual) — APROVADO e em implementação
- S e O com toques: sintomas, tempo de evolução, dados gineco-obstétricos, aspecto do colo, secreção em gotas, cor em amostras de cor.
- A e P: diagnósticos com sugestão (a doutora decide), **tratamento em cartões com ícone**, e a possibilidade de **acrescentar medicamentos e ícones próprios**.
- **Seletor de especialidade** com o código que vai no D1 (controle): Medicina general **17576016** · Ginecología **17576012**.
- O SOAP continua saindo na **folha de Historia clínica** oficial, como antes.
- Colposcopia com o **relógio do colo** (lesões por hora).

### [24/09/2026] Formulários próprios do SIVEC
**Ideia do autor:** criar **formulários próprios** do SIVEC, baseados nos oficiais que já usamos (D1, D8, PAP, Consentimento, Historia clínica), gerados pelo sistema na hora de imprimir, com letra mais legível e espaço para as figuras (ex.: relógio do colo na HC).
- Esboço em `docs/esboco-formularios.html` (aguardando aprovação).
- **Ponto a verificar na proposta:** quais formulários podem ser próprios e quais precisam manter o **modelo oficial do SUS/Ministério** (D1 e D8 costumam ser exigidos no formato oficial); para esses, o próprio pode reproduzir o mesmo layout com melhor letra.

### [24/09/2026] Formulários próprios — DENTRO DO SISTEMA como opção de prova
- Ainda **sem autorização** para usar formulários próprios. Ficam no sistema para **comparar**: na tela de impressão, **Formato: Oficial | SIVEC (prueba)**. A escolha fica lembrada no computador.
- Cada folha SIVEC leva a marca "FORMATO SIVEC · PRUEBA (NO OFICIAL)". No Drive continuam sendo salvos os **oficiais**.

### [24/09/2026] SIVEC Farmácia — receita enviada à farmácia, com estoque (SIVEC completo)
**Ideia do autor:** na consulta, opção **"Enviar a farmacia"**. A farmácia (versão SIVEC Farmácia dentro do SIVEC) recebe a receita, e **pelo estoque** já se sabe se o medicamento existe ou não. A paciente vai **só com a carteira de identidade** e tudo já está no sistema; a dispensação fica **vinculada à linha do tempo**.
- Requisitos: segurança, **auditoria** (quem prescreveu, quem dispensou, quando, quanto), perfis de acesso.
- Sugestões do Claude:
  - Na hora de prescrever, cada cartão de tratamento mostra 🟢 disponível / 🟠 pouco / 🔴 sem estoque, e sugere alternativa equivalente que esteja disponível.
  - A dispensação preenche sozinha a coluna **"Dispensada"** do D1 e desconta do estoque (entradas, lotes e vencimentos).
  - Receita com **código único** e estado (*emitida → dispensada parcial/total → vencida*); não pode ser dispensada duas vezes.
  - Painel da rede: consumo por medicamento e alerta de ruptura de estoque antes de acabar.
  - Ponto legal: validade da **receita digital** (firma digital/eletrônica do prescritor) e regras do SUS para dispensação.

### [24/09/2026] SIVEC em toda a rede — maternidade, Oncológico, laboratórios
**Visão do autor:** o SIVEC estará **em todo lugar**: centros, maternidade, hospital Oncológico e **laboratórios que processam PAP**. O laboratório **sobe o resultado direto** no sistema (acaba a perda de papel); o centro só **imprime quando a paciente vem à consulta**.
- Sugestões do Claude:
  - **Portal do laboratório:** lista das amostras recebidas por lote de envio (o SIVEC PAP/VPH já registra lote e data de envio); carrega Bethesda/VPH/genótipo com **validação do patologista** (firma) antes de liberar.
  - Ao liberar: aviso automático ao centro, "próximo passo" calculado na hora (positivo → busca ativa/derivação) e o indicador **tempo toma → resultado** passa a ser real.
  - **Oncológico/maternidade:** recebem a derivação no sistema e devolvem a **contrarreferência**, que aparece na linha do tempo.
  - Base técnica: identificação única da paciente (C.I. + SEGIP), padrões de interoperabilidade (**HL7 FHIR**), registro de acesso (quem viu o quê), consentimento da paciente, e funcionamento com internet ruim (fila offline).

### [24/09/2026] SIVEC Recepção → Triagem → Fila com painel na TV → Consultório (fluxo sem papel)
**Ideia do autor:**
1. **Recepção** coleta os primeiros dados da paciente (com C.I.). No SIVEC PAP, ao buscar a paciente pelo nome, a aba **Registrar se completa sozinha** com os dados da recepção.
2. A recepção **deriva para o doutor/área** (medicina geral, ginecologia, nutrição…).
3. **Triagem** registra os **sinais vitais** (entram direto na HC da consulta).
4. Gera **ficha/número de atendimento**; uma **TV grande** na sala de espera mostra o nome, o consultório e a área, com **aviso sonoro**.
5. No consultório, o SIVEC do doutor já abre com a **linha do tempo completa** da paciente (trajetória até ali).

**Sugestões do Claude:**
- Estados da fila visíveis para todos: *Na recepção → Triagem → Esperando → Chamada → Em atendimento → Finalizada / Derivada*, com tempo em cada etapa (indicador de tempo de espera por área).
- Painel da TV: mostrar **nome curto** (ex.: "María Q.") ou só o número, por privacidade; chamada com som + voz sintetizada ("Ficha A-023, consultorio 3"). Botão "chamar de novo" e "não compareceu".
- Triagem com classificação de prioridade (gestante, idosa, sinais de alarme) que reordena a fila.
- Recepção evita duplicados buscando pela C.I. (e, no futuro, SEGIP); foto opcional.
- Ao terminar a consulta, o doutor pode **derivar** para outra área do mesmo centro (vai para outra fila) ou para farmácia/laboratório.
- Funciona em rede local mesmo se a internet cair (a TV e as filas não podem parar).

### [24/09/2026] Modelo B de Historia clínica — APROVADO como base do SIVEC completo
- O autor gostou do **Modelo B** (resumo tipo International Patient Summary + nota orientada a problemas).
- **Exame físico por sistemas para todas as especialidades** (não só gineco): estado geral, pele e mucosas, cabeça, olhos, ouvidos, nariz, boca/orofaringe, pescoço, tórax/pulmões, coração, mamas, abdome, genitourinário/ginecológico, extremidades, coluna, neurológico, mental. Cada sistema com "normal" em um toque + campo de achado; o que é normal vira texto sozinho.
- **Protocolo cirúrgico e pós-operatório** como tipos de nota próprios (equipe, anestesia, diagnóstico pré/pós, técnica, achados, contagem de compressas, amostras enviadas a patologia, complicações, sangramento; pós-operatório com evolução, dor, ferida, drenos, alta).

### [24/09/2026] Assinatura eletrônica com impressão digital (biometria) — em todos os centros
**Ideia do autor:** médicos, internos, enfermeiros, auxiliares, farmácia **e pacientes** assinam com a **digital**, já que todos têm a digital registrada no **SEGIP**. Resolve o caso de quem não sabe assinar (idosos). Usar em todos os documentos que precisam da assinatura da paciente (consentimentos, recebimento de medicamentos, alta, contrarreferência) e dos profissionais (notas, receitas, protocolos).
**Sugestões do Claude:**
- Leitor biométrico USB em cada consultório/farmácia/recepção; a verificação é **1:1** (digital × C.I. informada) contra o SEGIP, se houver convênio/serviço, ou contra a digital cadastrada na recepção do SIVEC.
- Cada assinatura grava: quem, quando, onde (centro/terminal), qual documento e um **hash do conteúdo** (se o documento mudar depois, a assinatura deixa de valer) → auditoria completa.
- Para profissionais: digital + PIN (dois fatores) nas receitas e documentos legais; verificar o marco legal boliviano de **firma digital** (ADSIB/AGETIC) para validade jurídica.
- Plano B quando o leitor falhar: código por SMS ou assinatura manuscrita digitalizada, registrado como exceção.
- Dados biométricos são sensíveis: guardar só o necessário, criptografado, com consentimento.

### [24/09/2026] Módulos por especialidade (SIVEC Odonto e outros)
**Ideia do autor:** cada especialidade com **todas as suas funções próprias**, dentro do SIVEC completo, compartilhando paciente, linha do tempo, receitas, laboratório e referências. Exemplos a detalhar:
- **SIVEC Odonto:** odontograma interativo (dentes por número FDI, faces, cáries, restaurações, extrações, próteses), periodontograma, plano de tratamento por sessões, radiografias periapicais, índice CPO-D, flúor/selantes na escola.
- **SIVEC Materno:** controle pré-natal (CLAP/OPS), partograma, puerpério, recém-nascido.
- **SIVEC Nutrição:** antropometria, curvas OMS, planos alimentares.
- **SIVEC Cirurgia:** protocolo cirúrgico, lista de verificação da OMS (cirurgia segura), pós-operatório.
- **SIVEC PAP/VPH** (atual), **TB, Chagas, Raiva, Vacinas…** como programas.
- Regra: **"guardar tudo que for ideia"** para o SIVEC completo e para os específicos.

### [24/09/2026] Referência e contrarreferência entre níveis (1 → 2 → 3 → 4/Oncológico) — APROVADO pelo autor
Pedido do autor: pesquisar o mais ideal no mundo e desenhar para o SIVEC. Esboço em `docs/esboco-referencias.html`.
Referências de modelo: **Norma Nacional de Referencia y Contrarreferencia** (Bolivia); **NHS e-Referral Service** (Reino Unido: pedido eletrônico, triagem pelo especialista, agenda); **SISREG / centrais de regulação** (Brasil: regulador classifica prioridade e agenda); **eConsult** (Canadá: consulta escrita ao especialista antes de encaminhar; em Ontário, cerca de 4 em cada 10 e-consultas evitaram a viagem da paciente); recomendações da **OMS/OPS** sobre redes integradas de serviços de saúde (RISS).
Princípios para o SIVEC: dados mínimos obrigatórios + resumo clínico automático; prioridade com prazo (emergência/urgente/prioritária/rotina); triagem pelo nível receptor; **circuito fechado** com estados e prazos; **contrarreferência obrigatória** que volta à linha do tempo e ao centro de origem com "o que fazer no 1º nível"; e-consulta; indicadores por rede.

**Telas aprovadas (esboço `docs/esboco-referencias.html`):** 1) como funciona (4 níveis + circuito de 7 estados: enviada → recebida → classificada → cita → atendida → contrarreferência → fechada); 2) nova referência (destino sugerido com vagas/espera, prioridade com prazo, pergunta ao especialista, resumo clínico e anexos automáticos, assinatura com digital, opção e-consulta); 3) caixa de entrada do hospital (ordenada por prioridade/espera; dar cita, pedir dados, redirecionar, responder por e-consulta); 4) acompanhamento com alertas (sem cita em 3 dias, paciente não foi, contrarreferência atrasada); 5) contrarreferência com "o que o 1º nível deve fazer" → vira tarefa com data no centro; 6) indicadores da rede.

### [24/09/2026] "Para hacer hoy" por função (SIVEC completo)
- No SIVEC PAP/VPH já existe no Panel: tarefas do dia calculadas pelo "próximo passo" de cada paciente (buscar resultado atrasado, derivar, entregar, controle vencido…).
- No SIVEC completo **cada função tem o seu**: médico (por programa: PAP, pré-natal, TB…), **recepção** (citas do dia, contrarreferências a agendar, pacientes para chamar em busca ativa, referências com cita hoje), enfermagem/triagem (fila, vacinas pendentes), farmácia (receitas a dispensar, estoque baixo), laboratório (amostras a enviar/receber, resultados a liberar) e gestor da rede (alertas da rede).
- Esboço do fluxo recepção → triagem → consultório → assinatura com digital: `docs/esboco-recepcion-consultorio.html`.

### [24/09/2026] Identidade visual — marca SIVEC e família de logos (para vender o produto)
- Esboço em `docs/marca-sivec.html` (+ `marca-1-principal.png`, `marca-2-familia-modulos.png`, `marca-3-aplicaciones.png`).
- **Marca principal:** a "S" que une dois pontos (paciente ↔ serviço = *enlace*) cruzada por um pulso (*vigilância*), cor bordô.
- **Regra:** sempre **SIVEC + nome do lugar**, com ícone próprio e cor da família. 28 módulos em 5 famílias:
  - Atenção ao paciente: Recepción, Triaje, Turnos (TV), Consultorio, Historia clínica, Medicina general, Telesalud, Emergencias.
  - Especialidades: Ginecología, Materno, Pediatría, Odonto, Nutrición, Salud mental, Cirugía, Oncológico.
  - Programas: PAP/VPH, Vacunas, Tuberculosis, Chagas, Zoonosis (rabia).
  - Diagnóstico e tratamento: Farmacia, Laboratorio, Imagen.
  - Hospital e rede: Hospital, Referencias, Tránsito (traslados/ambulâncias/internação de trânsito), Red (gestor).
- Aplicações: barra do app, TV de turnos, cartaz de porta, receita impressa, app da paciente **"SIVEC Mi salud"** (ideia nova: a paciente vê resultados, citas e receitas no celular).
- Antes de vender: registrar a marca (SENAPI na Bolívia) e fazer a versão final com um designer.

### [24/09/2026] Organização da plataforma — "um só SIVEC" (pontos em aberto levantados pelo autor)
**Princípio:** o SIVEC é **uma só plataforma, um só login**. Os módulos (logos) não são sistemas separados: são **vistas por função**. O que a pessoa vê depende do seu perfil (recepcionista, médico, farmácia, motorista…). No centro de tudo está **a paciente e a sua linha do tempo**.
- **Serviços comuns** (usados por todos os módulos): cadastro da paciente, agenda/citas, ordens (exames), receita, **derivação/referência**, mensagens (SMS/WhatsApp), assinatura com digital, auditoria, notificações.
- **Várias especialidades (cardio, nefro, neuro…):** cada atenção é um "encontro" com **modelo próprio da especialidade** (ex.: cardio → ECG, eco, risco CV; nefro → creatinina/TFG com curva, diálise; neuro → escalas, EEG). Tudo cai na mesma linha do tempo, com **filtro por especialidade** e uma **lista de problemas única**. Cada especialista vê o que os outros fizeram.
- **Referência sem trocar de sistema:** dentro da consulta há **um botão "Derivar"** com 3 opções: (1) **volta a mim** (controle), (2) **outra especialidade no mesmo estabelecimento** (interconsulta / *hoja de tránsito* interna), (3) **outro estabelecimento** (referência). Os dados vão sozinhos. O **SIVEC Referencias** é só a *caixa de entrada* do hospital receptor e o painel da regulação.
- **Hoja de tránsito / interconsulta interna:** mesmo circuito fechado (pedida → aceita → atendida → resposta → volta ao solicitante), aparece nas duas filas e na linha do tempo.
- **Farmácia:** a receita assinada entra na fila da farmácia; dispensação com digital; estoque desconta sozinho; se faltar, avisa o médico/sugere alternativa.
- **Confirmações por telefone:** fase 1 **sem aplicativo** — SMS e **WhatsApp Business** (a paciente responde "1 confirmo / 2 mudar"); fase 2 app opcional **"SIVEC Mi salud"**. Quem não tem celular: ligação do centro, registrada no sistema.
- **Cada centro com 1 celular institucional** (ligações + WhatsApp Business do centro); cada ligação fica registrada na linha do tempo (atendeu / não atendeu / recado).
- **Recepção com câmera** (webcam) para a foto da paciente e para escanear documentos (C.I., resultados em papel).
- **SIVEC Tránsito (frota de ambulâncias):** inventário (placa, tipo, equipamentos), estado (operativa / manutenção / fora de serviço), manutenção preventiva por km/data, combustível, **GPS em tempo real** (rastreador com chip 4G ou app no celular do motorista — **AirTag não serve**: não dá posição em tempo real, depende de iPhones por perto e alerta como rastreamento indevido), equipe por turno (motorista, paramédico, enfermeiro), **despacho** (pedido → ambulância mais próxima disponível → a caminho → com paciente → entregue → disponível) com tempos, checklist de oxigênio/equipamento, ligado à referência e à linha do tempo.
- **O que mais contabilizar:** agenda e citas; **camas** (censo hospitalar); estoque de insumos (não só farmácia); **equipamentos biomédicos** e manutenção; pessoal, turnos e permissões; **informes automáticos para o SNIS** e prestações SUS; notificação epidemiológica obrigatória; banco de sangue; cadeia de frio das vacinas; certificados (nascimento, óbito); satisfação e reclamações; custos; auditoria, backups e modo sem internet.
- Esboço em `docs/esboco-plataforma.html`.

### [24/09/2026] PLANO — Organização da plataforma aprovada pelo autor
As ideias de "um só SIVEC" (vistas por função, paciente única, botão Derivar, hoja de tránsito, farmácia, mensagens, ambulâncias e a lista do que contabilizar) foram **aprovadas e entram no plano do projeto**.

### [24/09/2026] SIVEC Tránsito — app da ambulância ("tipo Uber", mas com regulação) — APROVADO
- **1 smartphone institucional por ambulância** (não o celular pessoal do motorista), com o app **SIVEC Tránsito**: login da tripulação do turno, GPS contínuo do próprio celular (+ rastreador veicular opcional como reserva).
- **Despacho:** o centro pede o traslado (botão Derivar → "precisa ambulância"); a **central de regulação** escolhe a ambulância (o sistema sugere a mais próxima disponível do tipo certo); o celular da ambulância **toca**, a tripulação **aceita** (se não aceitar em 60 s, passa para a próxima e a central é avisada).
- No celular: **ficha da paciente** (foto, dados, diagnóstico, sinais vitais, alergias), **origem e destino**, navegação, e se o **hospital receptor já aceitou** (serviço/cama). Estados: aceita → a caminho → no local → com paciente → chegou → entregue (com digital de quem recebe) → disponível.
- **A central telefônica continua:** chamadas do público e de emergência, e plano B quando falhar internet/app. O operador registra a chamada no SIVEC e despacha pelo mesmo sistema → tudo fica medido (tempos, km, quem atendeu) e na linha do tempo.

### [24/09/2026] Fluxo cirúrgico e hospitalar completo (pedido do autor) — APROVADO (esboço com 11 telas)
Formulários/telas a ter, todos ligados à linha do tempo e ao "onde está a paciente agora":
- **Solicitação de quirófano** (diagnóstico, procedimento, prioridade, tempo estimado, anestesia sugerida, sangue reservado, exames pré-op, consentimento).
- **Avaliação pré-anestésica** + **receita da anestesiologia**.
- **Protocolo quirúrgico** (já esboçado) e **protocolo de anestesia** (técnica, fármacos, registro de sinais vitais intraoperatórios, balanço hídrico).
- **Registro de enfermagem do quirófano** (checklist OMS, contagem, amostras) e **saída do quirófano**.
- **Recuperação pós-anestésica (sala de observação):** sinais vitais a cada 15 min, **escala de Aldrete**, dor, sangramento; alta da sala com ≥ 9.
- **Nota de ingresso ao piso** e **atribuição de cama** conforme a especialidade/procedimento (cesárea → piso de gineco-obstetrícia/puerpério; ARO; cirurgia; medicina interna…), com **horas na cama**.
- **Painel do chefe de piso:** ocupação, estância média, altas previstas, pendentes, **interconsultas entre pisos**.
- **Alta**: epicrise, indicações, receita, **contrarreferência** ao centro de saúde (ex.: retirada de pontos no dia 7, controle puerperal, planejamento familiar, controle do RN).
- **Monitorização fetal (NST/cardiotocografia)** como exame pedido na emergência gineco-obstétrica, com resultado e classificação no sistema — dentro de um **catálogo de exames**.
- **SIVEC Pediatria:** **calculadora de doses por peso**, **busca de medicamento por indicação**, controles (crescimento com curvas OMS, desenvolvimento, vacinas).
- Esboço em `docs/esboco-hospital.html`.

### [24/09/2026] App da paciente "SIVEC Mi salud" — APROVADO (esboço `docs/esboco-mi-salud.html`)
Fase 2 (a fase 1 é SMS/WhatsApp). Grátis para a paciente, Android e iPhone, e também versão web leve.
- **Entrar:** C.I. + código por SMS (primeira vez com validação no centro/SEGIP) e depois digital/rosto do próprio celular.
- **Início:** próxima cita, o que fazer hoje (remédios, controles), avisos.
- **Citas:** confirmar / pedir outro dia, **ficha e fila ao vivo** ("faltam 3 pessoas"), como chegar.
- **Resultados em linguagem simples** (PAP, laboratório) + PDF oficial; resultados que exigem conversa (ex.: PAP positivo) **só aparecem com a mensagem "venha ao centro, já temos sua cita"** — nunca um positivo solto.
- **Receitas e remédios:** horários com lembrete, "disponível na farmácia", **QR** para retirar.
- **Minha linha do tempo** simplificada.
- **Minhas referências:** onde está o pedido, cita no hospital, traslado.
- **Família:** filhos (controles, vacinas) e **gravidez** (semanas, controles pré-natais, sinais de alarme).
- **Carnê de vacinas digital** com QR.
- **Privacidade:** a paciente vê **quem acessou** a sua história (auditoria visível), autoriza familiar/cuidador.
- ~~Emergência no app~~ **retirado pelo autor** (guardado como ideia): a emergência já aciona a ambulância discando **160**. No lugar: **"Compartilhar meu resumo"** com código temporal de 24 h.
- Acessibilidade: letra grande, **áudio em espanhol e quechua/guarani/aimara**, funciona com internet fraca.

### [24/09/2026] Mapa do projeto — o que falta organizar (`docs/mapa-projeto.png`)
- **Já funciona:** SIVEC PAP/VPH, consulta com figuras, colposcopia com relógio, ficha com linha do tempo, documentos oficiais + formato SIVEC (prova), informes.
- **Desenhado e aprovado:** um só SIVEC, marca, recepção, triagem/TV, consultório e assinatura, HC modelo B, referências, hoja de tránsito, hospital/quirófano/camas/alta, chefe de piso, farmácia, mensagens, tránsito + app ambulância, Mi salud, pediatria, monitorização fetal.
- **Falta desenhar (ordem sugerida):** 1 SIVEC Admin (redes/centros/usuários/perfis/catálogos) · 2 Agenda e citas · 3 Laboratório (e portal do laboratório de PAP) · 4 Enfermagem de piso (kárdex, administração de medicamentos, balanço) · 5 Emergências (triagem por cores) · 6 Painel do gestor + informes SNIS · 7 Materno (CLAP, partograma) · 8 Vacinas · 9 Imagem · 10 Odonto · 11 Almoxarifado/logística · 12 Pessoal e plantões · 13 Epidemiologia · 14 Telessaúde · 15 App do profissional · 16 TB, Chagas, Zoonoses, Nutrição, Saúde mental.
- **Base (não aparece, mas sem ela não se vende):** segurança e proteção de dados, infraestrutura (nuvem/servidor, sem internet), integrações (SEGIP, SNIS, SUS, HL7 FHIR), legal (Ministério/SEDES, ADSIB, SENAPI), hardware por centro, implantação (piloto, migração, capacitação), suporte, qualidade.
- **Fases:** 0 agora (PAP/VPH + login seguro + redes/centros) → 1 núcleo do centro → 2 rede e hospital → 3 apps e especialidades.

### [24/09/2026] Módulo 1 · SIVEC Admin — APROVADO (esboço `docs/esboco-admin.html`, imagens `admin-01..08.png`)
Trabalho "um por um, com imagens de tudo" para as apresentações de venda.
1. Rede e estabelecimentos (árvore Ministério → SEDES → Rede → centros/hospitais; quem vê o quê).
2. Usuários (um por pessoa; profissão, especialidade e código, perfil, centros, digital, último acesso; desativar, nunca apagar).
3. Cadastro de profissional (SEGIP, matrícula, código D-1, 3 dedos + PIN, perfil e centros).
4. Perfis e permissões (ver/registrar/assinar/administrar por módulo; o administrador não vê dados clínicos).
5. Módulos por centro = **pacotes de venda** (Centro de saúde, Hospital, Rede).
6. Catálogos compartilhados (LINAME, exames, CIE-10, procedimentos, modelos, códigos D-1, textos SMS) com versão; o que um centro cria vira proposta.
7. Auditoria e segurança (quem viu o quê, alertas de uso estranho, backups).
8. Equipamentos e configuração do centro (leitores, câmera, TV, impressoras, celular; regras clínicas).
Respostas às 5 decisões pendentes de Redes/centros ficam propostas no desenho: responsável de Rede **vê** (edita só a regulação); um usuário **por profissional**; o administrador não vê dados clínicos.

### [24/09/2026] Módulo 2 · Agenda e citas — APROVADO ("melhor que o Zero Fila, sem papelada") (esboço `docs/esboco-agenda.html`, imagens `agenda-01..07.png`)
1. Agenda do dia (médicos em colunas; estados: confirmada, chegou, em atendimento, atendida, faltou, encaixe, livre) — a mesma agenda alimenta recepção, fila do médico, TV e Mi salud.
2. Dar uma cita (sistema avisa o que falta à paciente, sugere os primeiros horários livres, confirmação por WhatsApp com indicações e lembrete).
3. Agenda do médico (semana tipo por atividade, bloqueios, duração por tipo, vagas reservadas para referências, encaixes e Mi salud; vagas de referência liberadas 48 h antes).
4. Citas que chegam sozinhas (contrarreferência, programas PAP/pré-natal/vacinas, "retorno comigo", resultado positivo).
5. Médico ausente → reprogramação em bloco + WhatsApp "1 aceito / 2 outro dia".
6. Faltas (de programa → busca ativa), vaga liberada oferecida à lista de espera, encaixes só com motivo.
7. Indicadores (ocupação, faltas, dias de espera, confirmações).
**Ajuste pedido pelo autor — modalidade "ficha na hora":** no 1º nível (e também no 2º/3º) a paciente chega e pede consulta no momento. Acrescentado ao módulo 2:
- **Modalidade por estabelecimento e por serviço:** 🎫 ficha do dia (ordem de chegada + prioridade) · 📅 com cita (especialidades, referências, procedimentos) · 🔀 mista (parte fichas, parte citas) · 🚨 emergência por gravidade (triagem de cores).
- **Fichas do dia na recepção:** quantas fichas restam por médico, espera aproximada, ficha impressa ou SMS; se acabaram → outro médico, cita, lista de espera ou emergência.
- **Fila mista do médico:** citas na sua hora; entre elas fichas por ordem de chegada; prioridade (grávida, idoso, criança < 5, deficiência, alarme) sobe.
- **Ficha pelo celular** (Mi salud/WhatsApp) com hora aproximada; parte das fichas sempre reservada para a janela (quem não tem celular).
- Indicadores de fichas: entregues, % por celular, foram embora sem atenção, espera média, dias em que acabam cedo.
**Ajuste pedido pelo autor — camas no 1º nível:** centros de 1º nível também internam (poucas camas). Acrescentado ao Admin (`admin-09`, `admin-10`):
- **Capacidade do centro** (configuração no painel administrador): camas por área (observação, internação curta, sala de partos, puerpério, berços, curativos) com estância máxima sugerida; serviços habilitados (marcar "Internação" ativa o mapa de camas); atenção 24 h, consultórios, plantão, enfermeiras por turno, oxigênio com alerta, população assignada, hospital de referência, ambulância.
- **Internação no 1º nível:** mapa de camas pequeno, alertas (tempo máximo → referir, partograma, oxigênio), nota de ingresso/evolução, sinais vitais, kárdex, alta ou referência; a Rede vê as camas livres de todos os centros.
**Ajuste pedido pelo autor — "Sem fila" para especialistas (2º e 3º nível):** hoje a paciente com referência não urgente faz fila de madrugada para tirar ficha com especialista (existe o app "Zero Fila" do 3º nível: C.I. + data de nascimento + foto da referência em papel, e confirmar horas antes). **Proposta SIVEC, 100% digital** (`agenda-11..14`):
- O médico do 1º nível refere e **a cita sai marcada no mesmo momento**, escolhendo com a paciente um dos **cupos que o hospital reserva para a rede** (ou pré-cita que o especialista confirma em 48 h).
- A paciente recebe SMS/WhatsApp "não precisa fazer fila", confirma com "1" e recebe lembrete; **não viaja até ter cita**.
- No dia: chega 30 min antes e só dá **C.I. ou digital** (totem, recepção ou triagem) → ficha do consultório → chamada pela TV do piso. O especialista já tem tudo; a contrarreferência volta sozinha.
- Hospital reparte os cupos diários (ex.: 50% referências da rede, 20% controles, 15% interconsultas, 15% fichas do dia) e divide entre redes; não usados se liberam 48 h antes; urgências não usam cupo.
- Referência em papel de fora da rede: digitaliza uma vez (recepção ou foto pelo Mi salud) e recebe cita por mensagem. Sem celular: comprovante impresso no centro + ligação.

### [24/09/2026] Módulo 3 · Laboratório — DESENHADO (esboço `docs/esboco-laboratorio.html`, imagens `laboratorio-01..08.png`)
1. Circuito com código de barras: pedido → coleta → lote → recebida → em processo → validada → liberada → entregue (hora e responsável em cada passo); laboratório do centro, do hospital e de patologia/citologia.
2. Coleta de amostras: pedidos chegam do consultório com o tubo certo; etiqueta com código; escaneia ficha + tubo para não trocar; dados clínicos viajam com a amostra.
3. Lote de envio (evolução do "Balance envíos"): escaneia cada lâmina ao fechar; entrega e recebimento com digital.
4. Recepção no laboratório: lotes do dia; amostra rejeitada volta ao centro com motivo → tarefa "repetir coleta" + WhatsApp.
5. Mesa de trabalho: equipamentos conectados, faixas de referência, **valor crítico** com aviso imediato e registro de a quem se avisou, controle de qualidade.
6. **Portal PAP (citologia):** o laboratório de patologia carrega Bethesda, VPH e genótipo por toques, dupla leitura (validação obrigatória se não é NILM, 10% de NILM relidos), e o resultado entra direto no SIVEC PAP do centro com o próximo passo calculado.
7. Resultado ao médico: lista por prioridade com próximo passo sugerido; normais podem ser avisados sozinhos, alterados só com "venha, já tem cita".
8. Indicadores: PAP lidos, dias coleta→resultado por centro, rejeições e motivo, % positivos.
- **Catálogo completo de exames** (`laboratorio-09.png`): todas as áreas — hematologia, química, hepático (transaminases, fosfatases…), eletrólitos, sorologia (PCR, Widal, VIH, sífilis, Chagas…), coagulação, urina, fezes (moco fecal, coproparasitológico), parasitologia (gota grossa), microbiologia (baciloscopia, GeneXpert, cultivo), citologia/patologia, hormônios; perfis rápidos (pré-natal, renal, hepático, pré-operatório, diabetes, síndrome febril). Cada exame: tubo, preparo, faixas por idade/sexo, setor, tempo, código SUS, onde se faz. Novos exames pelo Admin → Catálogos.
- **Pedido de exames pelo médico → D-8 automático** (`laboratorio-10.png`, pedido do autor): na consulta aparecem as mesmas abas do catálogo (hematologia, química, hepático, sorologia, urina, fezes, parasitologia, microbiologia, citologia, coagulação, hormônios, imagem/gabinete); o médico marca exames ou um perfil (pré-natal, renal, hepático, pré-operatório, diabetes, febril, favoritos), vê preparo (jejum, primeira urina, consentimento) e onde se faz cada um; avisa exame repetido recente; o **D-8 se preenche sozinho** com as caixas marcadas; assina com digital e o pedido vai direto à coleta; preparo por SMS à paciente.
**Ressalva do autor — história clínica da paciente internada** (`enfermeria-09..11.png`): tem que reunir **dados, motivo de ingresso, o que aconteceu, laboratórios, imagem, entrada e saída do quirófano, ingresso ao piso, evolução SOAP, indicações médicas, indicações de enfermagem e seus controles** (+ interconsultas, epicrise e alta), tudo num só lugar.
- **Evolução SOAP diária:** o "O" já traz sinais vitais, balanço, alerta e laboratórios do dia; "copiar indicações de ontem e editar"; lembrete quando falta evolução (c/12 h em graves).
- **Internos (são muitos) — sem tablet para cada um:** PC na estação (2–3 por piso) + **o próprio celular** com acesso seguro (usuário + PIN, sessão que fecha sozinha, nada guardado no telefone) + 1–2 tablets compartilhados por piso para a ronda. O interno escreve em **rascunho** → residente/médico de planta revisa e assina; indicações do interno só chegam ao kárdex com assinatura do médico; fica registrado quem escreveu e quem validou. Ditado por voz, modelos por patologia, rascunho salvo sem wifi.
**Módulo 4 · Enfermagem de piso + história de internação — APROVADO.** Decisão do autor: o interno escreve (web no próprio smartphone ou terminal, com **comando de voz**), o **residente confere e dá o aval** com a sua assinatura antes de a história ser guardada. Correções depois da assinatura: permitidas, mas **a versão original fica guardada** (quem mudou, quando e por quê) — validade legal. Benefícios: sem papel, sem retrabalho, menos erros por cansaço.
- **Revisão do residente** (`enfermeria-12.png`, pedido do autor): o residente **marca no texto** o que está errado ou falta e escreve uma **nota para o interno**; o interno recebe o aviso, corrige e devolve; com tudo certo **os dois assinam** e só então a evolução vale (antes é "rascunho em revisão"). As correções ficam como histórico (ensino e auditoria); o chefe de serviço vê as correções por interno.

### [24/09/2026] Módulo 5 · Emergências — DESENHADO (`docs/esboco-emergencias.html`, `emergencias-01..07.png`)
1. Painel: pacientes por cor, boxes ao vivo, sala de espera **por gravidade**, alertas (tempo máximo, ambulância chegando, camas livres).
2. Triagem por cores (5 níveis tipo Manchester, tempos 0/10/60/120/240 min): motivo, sinais vitais, perguntas de gravidade; sistema sugere, enfermeira confirma.
3. Pré-aviso de ambulância: ficha, sinais da ambulância, antecedentes; ao aceitar reserva box, avisa especialista, banco de sangue e laboratório; entrega com digital.
4. Atendimento no box: SOAP rápido com dados da triagem, ordens de um toque, resultados ao vivo, interconsulta.
5. Códigos/protocolos com cronômetro e checklist (vermelho obstétrico, infarto, AVC; sepse, preeclâmpsia, trauma, RCP…).
6. Destino: alta, observação (≤ 24 h), quirófano, internar ou referir — cada um abre o formulário certo.
7. Indicadores: chegada→triagem, atendidos a tempo por cor, foram embora, estância > 24 h, consultas não urgentes por centro de origem.
- **Esclarecimento do autor — mesmo padrão na emergência** (`emergencias-07.png`): emergência também tem **recepção e triagem** (recepção → triagem → atendimento), como em todo o SIVEC. Vermelho entra direto no choque e a recepção completa os dados depois. Paciente inconsciente/sem documento: registro **NN** (ex.: "NN-0923 · mulher · ~40 anos") e união à história quando identificado (auditada). **Casos direto ao quirófano ficam inteiros na linha do tempo**: ambulância, recepção, triagem, choque, solicitação, entrada e saída do quirófano, recuperação/UTI e piso, com hora, lugar e responsável; tempo chegada→quirófano medido sozinho.

### [24/09/2026] Módulo 5 · Emergências — APROVADO. Módulo 6 · Painel do gestor de rede — DESENHADO (`docs/esboco-gestor.html`, `gestor-01..08.png`)
1. A rede hoje: números do dia, mapa com semáforo por centro, "o que olhar hoje"; o gestor vê números, não histórias (acesso a caso só com motivo e auditoria).
2. Comparar centros: indicadores × meta (verde/amarelo/vermelho) e leitura da causa.
3. Programas e metas: PAP/VPH, pré-natal, parto institucional, vacinas, TB, criança sadia; detalhe do PAP (positivos sem seguimento → busca ativa).
4. Recursos ao vivo: camas livres da rede, ambulâncias, pessoal do dia, estoque crítico com transferência entre centros com um toque.
5. Alertas para agir ("Para hacer hoy" do gestor) com responsável e estado.
6. Tendências mês a mês (tomas de PAP, dias até resultado) com filtros e download.
7. **Informes automáticos**: SNIS 301 e 302, prestações SUS, programa de câncer de colo, notificação imediata, informe mensal — saem do trabalho diário; o chefe revisa, assina com digital e envia; números fora do padrão são marcados antes.
8. Informe mensal da rede (3 folhas: resumo, centros, programas) em PDF.

### [24/09/2026] Módulo 6 · Painel do gestor — APROVADO. Módulo 7 · Materno — DESENHADO (`docs/esboco-materno.html`, `materno-01..07.png`)
Baseado na história clínica perinatal (CLAP/OPS) e na carteirinha perinatal, em digital e compartilhado (centro, hospital, Mi salud).
1. Carteirinha perinatal digital: semanas, FUM, data provável do parto, grupo/Rh, risco, os 8 contatos (OMS), laboratórios e vacinas da gestação.
2. Controle pré-natal: sinais em uma linha, curvas de altura uterina e ganho de peso com faixa normal, conduta por toques, alertas (anemia, curva de glicose, dTpa), próximo controle agendado.
3. Risco e plano de parto: fatores reunidos da história, classificação ARO → referir com um toque, plano (onde, como chega, casa materna, acompanhante), preferências culturais (parto vertical, idioma, placenta).
4. Partograma digital com linhas de alerta e ação (também no 1º nível, com botão Referir + ambulância).
5. Parto e RN: registro do parto, RN (peso, Apgar, cuidados); o bebê ganha ficha própria ligada à mãe; certificado de nascido vivo com digital; aviso ao centro.
6. Puerpério: controles dia 7 e 40 agendados, planejamento familiar (liga ao módulo "Métodos" do SIVEC PAP), triagem de depressão pós-parto (Edimburgo), sinais de alarma mãe/bebê pelo Mi salud.
7. Gestantes da rede: em controle, alto risco, captação no 1º trimestre e lista para buscar hoje.

### Materno · atención inmediata del RN por Pediatría (2º nivel) — agregado
- Al pasar a “expulsivo”, el SIVEC avisa a Pediatría con los riesgos del bebé.
- **Entrega obstetra → pediatra** con hora exacta y las dos huellas; desde ahí el RN tiene su propia ficha y su propio reloj. Obstetricia sigue con la mamá y Pediatría con el bebé, en dos pantallas al mismo tiempo.
- **Atención inmediata con hora en cada toque:** cuna radiante, secar y abrigar, ¿respira?, aspiración solo si hace falta, Apgar 1′/5′ (10′ si < 7) con reloj automático, apego, pulsera mamá-bebé + huella plantar, y luego vitamina K, profilaxis ocular, medidas y vestir.
- **Reanimación neonatal paso a paso** (minuto de oro): cada paso queda con su hora y se llama a UCIN.
- **Examen físico del RN por toques**, curvas OMS/Capurro, vacunas BCG/HepB y tamizaje neonatal.
- **Destino del bebé:** alojamiento conjunto, observación, UCIN o referir (la cama y la ambulancia se piden desde ahí). También salen la ficha propia, el certificado de nacido vivo y el aviso al centro.
- **1er nivel sin pediatra:** el mismo formulario lo llena quien atiende el parto.
- Imágenes: docs/materno-05 (entrega), 06 (atención inmediata), 07 (examen y destino).

### Historia clínica perinatal SIVEC + carnet impreso de la mamá — dibujado, para aprobar
- Problema: la HCP CLAP-OPS en papel tiene ~450 casillas en una hoja, se llena a mano, la mamá no la ve y se copia al SIP a mano.
- Modelo recomendado en el mundo: guías digitales de la OMS para el control prenatal (SMART Guidelines / DAK prenatal, 8 contactos), registro en manos de la mujer (OMS) y variables del SIP del CLAP.
- **Decisión (usuario): NO hacer app de embarazo** (demasiadas apps para coordinar).
  - Los datos viven en **una sola historia** dentro del SIVEC.
  - La mamá lleva un **carnet impreso**.
- **5 reglas:**
  1. cada dato se escribe una vez, donde ocurre;
  2. la pantalla muestra solo lo de ese momento;
  3. las casillas amarillas del CLAP pasan a ser alertas automáticas;
  4. carnet impreso con QR, sin app nueva;
  5. la HCP oficial, el SIP y el SNIS salen solos (CIE-10, HL7 FHIR).
- **Pantallas:**
  - resumen del embarazo en una mirada;
  - control prenatal guiado en 6 pasos; la fila de la HCP se arma sola.
- **Historia Clínica Perinatal SIVEC (formato propio, 2 hojas A4)**, llenada por el sistema:
  - Hoja 1: A identificación · B resumen y alertas · C antecedentes (lo positivo en rojo) · D gestación actual · E laboratorios por trimestre · F contactos prenatales (1 fila por control).
  - Hoja 2: G ingreso y partograma · H nacimiento (parto o cesárea) · I recién nacido (Pediatría) · J puerperio · K egreso materno y anticoncepción · L diagnósticos codificados · firmas con huella.
- **Carnet de la mamá:** 1 hoja A4 doblada, que se reimprime al cerrar cada control. Incluye controles, próximo control, exámenes, vacunas, plan de parto, señales de alarma, movimientos del bebé y un QR que abre la historia (solo personal con huella).
- También se puede imprimir la HCP en formato oficial y exportar al SIP y al SNIS.
- **RN también en cesárea:** el mismo formulario de Pediatría sirve en sala de partos, quirófano y sala de recuperación, con control del binomio mamá-RN cada 15 min.
- **Dos fichas vinculadas:**
  - la línea de tiempo de la mamá muestra “nació su bebé” con enlace;
  - el RN tiene su ficha propia, que hereda los datos del embarazo.
- Imágenes: docs/perinatal-01..09.png · esboco-carnet-perinatal.html

### Módulo 8 · Vacunas — dibujado, para aprobar
- **Carnet de vacunas** en grilla (aplicada / toca hoy / atrasada / próxima).
  - El SIVEC calcula edad e intervalos mínimos y dice todo lo que puede recibir hoy.
  - Sirve para todas las edades: embarazada (desde Materno), VPH escolar, adultos, 60+ y personal de salud.
  - Carnet impreso con QR, sin app.
- **Vacunatorio del día:** fila que llega de recepción, consulta, control prenatal y búsqueda activa (“no se pierde ninguna oportunidad”). Incluye observación de 30 min con reloj, botón ESAVI y frascos abiertos con hora.
- **Registro en 3 toques:**
  1. confirmar las vacunas sugeridas;
  2. escanear el frasco (lote y vencimiento; un lote vencido o retirado se bloquea);
  3. marcar el sitio en la figura y firmar con huella (vacunadora y mamá).
  - Al firmar: se descuenta del stock, se imprime el carnet, se agenda la próxima dosis y sale el SMS de recordatorio.
- **Atrasados y búsqueda activa:** lista por urgencia, aviso de edad máxima (rotavirus), ruta de visitas y SMS automáticos (sin mensajes uno por uno).
- **Campañas y brigadas:** meta, ritmo necesario, avance por centro, brigada casa por casa que funciona sin internet, y escuelas (VPH) con consentimiento.
- **Cadena de frío:** temperatura 2 veces al día o por sensor, rango 2–8 °C, alerta con acción y firma, y estado de toda la red.
- **Stock y lotes:** cuántos días alcanza, lote más próximo a vencer y pérdidas. El pedido al SEDES se arma solo; un lote retirado se bloquea en la red, con la lista de quién lo recibió.
- **Coberturas y ESAVI:** cobertura acumulada contra lo esperado, deserción Penta 1→3, ESAVI con lote, e informe mensual PAI automático (SNIS y gestor).
- Imágenes: docs/vacunas-01..08.png · esboco-vacunas.html

### Carnet de salud infantil (vacunas + crecimiento + desarrollo, impreso) — dibujado, para aprobar
- 1 hoja A4 horizontal, impresa en los 2 lados y doblada al medio (A5). Sale de la impresora del centro; en blanco y negro también sirve.
- **8 especificaciones:**
  1. identificación con QR (niño/a, mamá/tutor, centro);
  2. esquema completo por edad, con fecha, lote y quién vacunó;
  3. próxima vacuna grande en la portada;
  4. casillas en blanco para escribir a mano (brigada u otro centro), que después se pasan al SIVEC por el QR;
  5. campañas y otras vacunas;
  6. vitamina A, chispitas y antiparasitario;
  7. reacciones normales y señales de alarma (160);
  8. lenguaje simple, letra ≥ 9 pt, el mismo carnet para niña y niño.
- **Uso:** Pediatría lo imprime al nacer (BCG y HepB ya anotadas) y se reimprime después de cada vacuna. El QR siempre muestra la verdad del SIVEC.
- Imágenes: docs/carnet-vacunas-01..03.png · esboco-carnet-vacunas.html
- **Agregado (pedido del usuario):** el carnet pasa a ser un **cuadernillo A5 de 8 caras** (2 hojas A4).
  - **Curvas de crecimiento OMS** (peso y talla para la edad, niña o niño; zona verde, −2, −3 y +2). El SIVEC dibuja la línea del niño con las medidas reales. También hay páginas de 2–5 años, peso/talla y perímetro cefálico.
  - **Hitos del desarrollo por edad** (AIEPI-OPS), de 1 mes a 5 años: ✓ lo evaluado por el personal y ☐ para que la mamá marque en casa. Incluye señales de alerta y consejos de estimulación.
- **Control del niño sano en el SIVEC:**
  - Las medidas dan los puntajes Z automáticos (OMS), con alerta si la curva se aplana.
  - Los hitos dan la clasificación AIEPI (adecuado / con factores de riesgo / posible retraso → referir); se puede aplicar una escala completa.
  - Vacunas y suplementos se registran en el mismo control.
- **Todo queda en la base de datos:** cada medida y cada hito, con fecha y responsable.
  - Salen listas de búsqueda activa (desnutrición, talla baja, retraso, sin control).
  - Los indicadores van al SNIS y al gestor.
  - Al cerrar el control se reimprime el carnet.
- Imágenes: docs/carnet-vacunas-01..06.png

**Módulo 8 · Vacunas + Carnet de salud infantil: APROVADO.**

### Módulo 9 · Imagen — dibujado, para aprobar
- **Pedir un estudio desde la consulta:**
  - pestañas Rx / Eco / Mamografía / Tomografía; la región se elige por toques;
  - el motivo clínico es obligatorio y viene del SOAP;
  - prioridad y seguridad: embarazo, contraste, creatinina;
  - se muestra el estudio previo para comparar;
  - si el centro no tiene el equipo, se deriva con turno.
- **Sala de imagen del día:** lista de trabajo por equipo, urgentes primero, con origen y estado; el llamado sale en la TV.
- **Técnico:** confirma al paciente (huella o QR) y registra proyecciones, dosis y repeticiones.
  - Equipo digital: la imagen llega sola (DICOM).
  - Equipo con placa: foto guiada sobre el negativoscopio.
  - Las imágenes se guardan en un archivo de imágenes de la red (PACS pequeño, software libre).
- **Visor web** sin instalar nada: zoom, contraste, medir, marcar y comparar lado a lado con el estudio anterior.
- **Informe estructurado:** plantillas con frases por toques (Rx tórax, eco obstétrica, abdominal, BI-RADS, TI-RADS).
  - La eco obstétrica calcula la EG y el peso fetal y pasa sola a la historia perinatal.
  - Se puede dictar por voz; se firma con huella.
- **Hallazgo importante:** exige “visto”; si nadie lo ve en 24 h sube al jefe médico. Avisa al programa que corresponda (ej. TB).
- **Resultado:** queda en la línea de tiempo; el paciente recibe el informe impreso con QR (sin placa ni CD).
- **Informe a distancia (telerradiología) en la red:** bandeja del radiólogo por prioridad, más segunda opinión.
- **Indicadores y equipos:**
  - tiempo pedido→informe, repeticiones y hallazgos vistos en menos de 24 h;
  - estado y mantenimiento de cada equipo; si uno está parado, los pedidos se derivan solos;
  - las mamografías se cruzan con el programa PAP/VPH.
- Imágenes: docs/imagen-01..08.png · esboco-imagen.html
- **Abrir la imagen con el QR (pregunta del usuario):** sin app, en el navegador.
  - A) Dentro de la red no hace falta QR: se abre desde la ficha / línea de tiempo.
  - B) Médico de la red: escanea el QR con el celular o con el lector de la computadora y entra con usuario (huella o PIN).
  - C) Médico de fuera de la red: escribe el código de 6 números impreso junto al QR (el paciente lo muestra = su permiso); lo ve solo para mirar, 30 días.
  - El QR no lleva datos del paciente, solo una llave; queda registrado quién abrió y cuándo.
  - El visor es web (software libre) y funciona en el celular; la ecografía igual.
  - Imagen: docs/imagen-09.png

**Módulo 9 · Imagen: APROVADO** (incluye abrir con QR).

### Módulo 10 · Odonto — dibujado, para aprobar
- **Odontograma FDI por toques:** se toca la cara del diente (V, L, M, D, O) y se elige el hallazgo; rojo = por tratar, azul = realizado.
  - Hallazgos: caries, obturación, ausente, extracción indicada, corona, endodoncia y sellante.
  - Los índices CPO-D, IHO-S y riesgo de caries se calculan solos.
  - Queda el historial de odontogramas por fecha.
- **Historia y examen:**
  - trae de la ficha SIVEC las alertas (HTA, alergia a penicilina, embarazo);
  - motivo y hábitos por toques (incluye acullico);
  - tejidos blandos, con alerta de cáncer oral;
  - índice periodontal por sextante.
- **Plan de tratamiento** armado desde el odontograma:
  - por prioridad: urgencia, prevención, restaurador, cirugía, rehabilitación;
  - en sesiones agendadas, con cobertura SUS;
  - consentimiento con huella y derivación con el botón Derivar;
  - alta odontológica básica y control automático a los 6 meses.
- **Sesión en el sillón:**
  - procedimiento por toques (anestesia con aviso de dosis en HTA, material con lote);
  - receta que respeta las alergias;
  - paquete de instrumental escaneado (trazabilidad de la esterilización);
  - el odontograma se actualiza solo.
- **Niños, embarazadas y escuelas:**
  - dientes temporales y ceo-d, flúor y sellantes (aparece en el carnet de salud infantil);
  - la consulta de la embarazada queda ligada al control prenatal;
  - brigadas escolares sin internet.
- **Agenda de sillones** con lugares para urgencia (ficha del día); **esterilización** con ciclos del autoclave, prueba biológica y paquetes vencidos bloqueados.
- **Indicadores:** CPO-D a los 12 años (meta OMS < 3), altas, embarazadas con consulta, obturaciones vs extracciones, e insumos que se descuentan solos (Almacén).
- Imágenes: docs/odonto-01..07.png · esboco-odonto.html
- **Diente ausente (pregunta del usuario):** al marcar “ausente”, el SIVEC pregunta la causa: perdido por caries, extraído por ortodoncia, trauma, enfermedad de encías, no erupcionado (NE) o agenesia (AG).
  - Se ve como ✕ azul con la causa debajo; NE y AG en gris.
  - Solo “perdido por caries” cuenta como P en el CPO-D (regla OMS). La extracción indicada (todavía en boca) cuenta como C.
  - Si la extracción se hizo en el SIVEC, la causa y la fecha vienen solas de esa sesión.
  - Imagen: docs/odonto-02.png (las demás pantallas pasan a odonto-03..08).

**Módulo 10 · Odonto: APROVADO** (incluye diente ausente con causa).

### Módulo 11 · Almacén y logística — dibujado, para aprobar
- **Almacén del centro:** stock de todo (LINAME, insumos, reactivos, vacunas, odonto), con consumo por mes, cuántos días alcanza, el lote que vence primero y semáforo.
  - El consumo se descuenta solo cuando farmacia, laboratorio, odonto, vacunas o enfermería usan algo (adiós kárdex de papel).
- **Recibir mercadería:** se escanea cada caja y se compara con el pedido (lote, vencimiento). Las diferencias generan un reclamo automático; firman con huella el chofer y la responsable (reemplaza la nota de remisión).
- **Pedido automático:** consumo promedio × meses + seguridad − stock − lo que está en camino, ajustado por temporada y campañas.
  - Aprueban la responsable y el director (con huella).
  - Salen solos los formularios oficiales (SNUS/CEASS).
- **Entre centros de la red:**
  - sugerencias de transferencia (lo que sobra o está por vencer hacia donde falta);
  - buscador “¿quién tiene…?”;
  - préstamo urgente que viaja en la próxima ambulancia o entrega.
- **Vencimientos y bajas:** se entrega primero lo que vence primero (farmacia recibe el lote sugerido); baja con acta, foto y huella; las pérdidas del año bajan.
- **Equipos y mantenimiento:** QR en cada equipo; reportar una falla en 1 minuto (QR + foto) crea una orden de trabajo para el técnico. Si el equipo está parado, los pedidos se derivan.
- **Entregas en camino:** ruta del camión con firma de cada entrega en el celular del chofer. El mismo viaje lleva muestras de laboratorio y vacunas en caja térmica.
- **Tablero de abastecimiento:** disponibilidad de medicamentos trazadores por centro (meta ≥ 95%), quiebres, pedidos completos y pérdidas. Los quiebres de emergencia obstétrica avisan al instante.
- Imágenes: docs/almacen-01..08.png · esboco-almacen.html

**Módulo 11 · Almacén y logística: APROVADO.**

### Módulo 12 · Personal y guardias — dibujado, para aprobar
- **Rol de turnos mensual** por persona (M, T, N, guardia 24 h, vacación) con horas sumadas. El SIVEC avisa si un turno queda sin cubrir, si falta el descanso post-guardia o si se pasa el máximo de horas. Se publica por SMS, en la app del profesional y en el mural.
- **Quién está de guardia ahora:** por especialidad en el hospital (presencial o llamada, con tiempo de llegada) y centros de 1er nivel abiertos. Se usa al derivar o referir, y sale en la TV de emergencias.
- **Asistencia con huella** en el mismo lector de recepción: atrasos y faltas. A fin de mes, el resumen (horas, extras, faltas) se exporta al sistema de RRHH para la planilla; el SIVEC no paga sueldos.
- **Cambios y reemplazos:**
  - cambio entre colegas: los dos firman con huella y el jefe aprueba, con verificación de descanso y horas;
  - reemplazo urgente: el SIVEC sugiere quién puede venir y avisa por SMS; el primero que acepta queda en el rol.
- **Vacaciones, permisos y licencias:** saldo de días, certificado por foto, licencia de maternidad con reemplazo. El jefe ve la cobertura antes de aprobar.
- **Ficha del personal:** cargo, títulos y matrícula con aviso de vencimiento (RCP), vacunas del trabajador, accidente con aguja, y su producción en el SIVEC (solo ella y su jefe la ven).
- **Internos y residentes:** rotaciones con tutor, notas por validar, procedimientos para la evaluación, y guardias y descanso de los residentes.
- **Indicadores:**
  - turnos cubiertos, ausentismo, horas extra, certificados por vencer;
  - personal por 10.000 habitantes y carga real por centro, para pedir ítems con datos.
- Imágenes: docs/personal-01..08.png · esboco-personal.html

**Módulo 12 · Personal y guardias: APROVADO.**

### Módulo 13 · Epidemiología — dibujado, para aprobar
- **Notificar desde la consulta:** el médico escribe el diagnóstico como siempre. Si es de notificación obligatoria, el SIVEC avisa (inmediata o semanal) y la ficha ya viene llena.
  - También disparan la notificación: un resultado de laboratorio, un informe de imagen, un síndrome sin diagnóstico y la muerte materna o infantil.
- **Ficha epidemiológica:** faltan solo 3 preguntas por toques. La clasificación (sospechoso → confirmado) cambia sola con el laboratorio.
  - Al notificar llega al instante al epidemiólogo y al SEDES, entra al mapa y al canal endémico, y crea contactos.
- **Mapa de casos:** cada caso en su domicilio, sin nombres. El sistema detecta solo el conglomerado y sugiere bloqueo de foco; el mapa público muestra solo manchas por zona.
- **Canal endémico automático:** 5 años de referencia con zonas de éxito, seguridad, alerta y epidemia. La alerta de brote llega al epidemiólogo, al director y al SEDES; hay otras vigilancias en vivo.
- **Respuesta al brote:** plan con responsable, fecha y avance:
  - bloqueo de foco y búsqueda casa por casa sin internet;
  - eliminación de criaderos, alerta a consultorios, SMS de zona y camas reservadas;
  - cierre con informe final.
- **Contactos y seguimiento:**
  - TB: contactos desde la ficha familiar;
  - sarampión: vigilancia de 21 días y vacunación de bloqueo;
  - mordedura: observación del perro y esquema antirrábico con búsqueda activa si falta a una dosis.
- **Notificación semanal:** el formulario se arma solo desde el SOAP por grupos de edad; el responsable firma con huella. Se envía también en cero y se ve el estado de los envíos.
- **Tablero:**
  - oportunidad de notificación en menos de 24 h, centros al día, brotes activos y casos por evento;
  - enlazado con laboratorio, imagen, vacunas, almacén, camas y gestor.
- Imágenes: docs/epidemiologia-01..08.png · esboco-epidemiologia.html

**Módulo 13 · Epidemiología: APROVADO.**

### Módulo 14 · Telesalud — dibujado, para aprobar (sin app nueva: enlace en el navegador)
- **Interconsulta a distancia (asíncrona):** el caso se arma solo con la ficha; el médico agrega la pregunta y fotos (piel, ECG) y elige especialidad y urgencia. Muchas derivaciones se resuelven con la respuesta; si no, Derivar lleva todo.
- **Bandeja del especialista:** responde con la conducta (resolver en el centro, derivar con turno ya reservado o videoconsulta). Firma con huella, la respuesta vuelve a la ficha y cuenta como producción.
- **Videoconsulta asistida:** el paciente está en el centro rural con la enfermera y el especialista en el hospital.
  - Junto al video se ven los signos y el ECG; SOAP y receta como en el consultorio.
  - Si el internet cae, sigue por teléfono y queda registrado.
- **Desde la casa:** SMS con enlace → sala de espera en el navegador (acepto + fecha de nacimiento) → consulta. La receta y la cita llegan por SMS.
  - Sirve para crónicos estables, resultados, puerperio, salud mental y adultos mayores; no para la primera consulta de algo grave.
- **Seguimiento a distancia:** hipertensos, diabéticos y embarazadas ARO.
  - La promotora mide en la casa o el paciente responde un SMS.
  - Si sale de rango, avisa al médico; cada valor entra a la curva de la ficha.
- **Capacitación y ateneos** de la red por el mismo enlace, grabados, con certificado automático en la ficha del personal.
- **Indicadores:** interconsultas, respondidas en menos de 48 h, resueltas sin viajar, videoconsultas; viajes, km y días de trabajo ahorrados (argumento de venta).
- Imágenes: docs/telesalud-01..07.png · esboco-telesalud.html

**Módulo 14 · Telesalud: APROVADO.**

### Módulo 15 · SIVEC en el celular (antes “App del profesional”) — dibujado, para aprobar
- **Decisión:** NO hacer una app de tienda. Es el mismo SIVEC en el navegador del celular, con atajo en la pantalla de inicio (aplicación web progresiva).
  - No se instala desde la tienda y se actualiza solo para todos.
  - Funciona sin internet y en celulares baratos, sin depender de Google o Apple.
  - Una app pequeña solo haría falta para un lector de huella en el celular o el GPS continuo de la ambulancia.
- **Seguridad:** usuario + PIN, bloqueo a los 5 min, datos sin internet cifrados; si se pierde el celular, se desactiva desde Admin.
- **En el celular se ve, confirma, firma y registra rápido.** La consulta completa y la historia van en la computadora.
- **Médico de guardia:** alertas y pacientes; valor crítico con los datos para decidir y “visto”; firmar notas de internos con las marcas del residente y PIN.
- **Mi trabajo (todo el personal):** turno y semana; aceptar un reemplazo en un toque (con control de horas y descanso); pedir permiso con foto del certificado.
- **Trabajo de campo sin internet:** la lista de casas se descarga en el centro. En la casa se registran vacunas, fichas de dengue y criaderos sin señal; al volver la señal, un toque sincroniza y el vacunatorio, el epidemiólogo y el mapa ya lo ven.
- Imágenes: docs/celular-01..04.png · esboco-celular.html

**Módulo 15 · SIVEC en el celular: APROVADO.**

### Módulo 16 · Programas (TB, Chagas, Zoonosis, Nutrición, Salud mental) — dibujado, para aprobar
- **Cada programa es una “etiqueta” en la ficha del paciente**, no un sistema aparte. Todos siguen el mismo patrón:
  - entra solo por un diagnóstico o resultado;
  - tiene su tarjeta de control, con citas y dosis;
  - si el paciente falta, hay búsqueda activa;
  - termina con un resultado final y el informe sale automático.
- **TB (TAES):** cada dosis observada se marca con la huella del paciente (o la promotora en casa). Si falta, SMS y visita el mismo día.
  - La tarjeta incluye esquema, peso, BK de control, VIH/glucemia, contactos y profilaxis, y el resultado para la cohorte.
- **Chagas:**
  - tamizaje de la embarazada (desde Materno);
  - bebé de madre positiva: micrométodo al nacer y al mes, serología a los 8–10 meses;
  - tratamiento de 60 días con controles;
  - vigilancia de la vinchuca: la comunidad avisa y se programa el rociado.
- **Zoonosis:** mordeduras con observación del animal 10 días (el inspector registra en el celular) y esquema antirrábico que se suspende si el animal está sano; campaña de vacunación canina con brigada sin internet; mapa de mordeduras.
- **Nutrición:**
  - el niño entra solo desde las curvas del carnet; manejo en casa con alimento terapéutico y control semanal hasta el alta;
  - Nutribebé, chispitas y Carmelo registrados y descontados del almacén;
  - programa de anemia.
- **Salud mental y violencia:**
  - tamizajes breves con puntaje automático (PHQ-9, Edimburgo, AUDIT-C, violencia);
  - riesgo de suicidio: acción el mismo día y plan de seguridad;
  - ruta de violencia con aviso legal;
  - confidencialidad reforzada: solo el tratante y psicología ven las notas, y cada apertura queda registrada.
- **Cohortes e indicadores:** éxito y abandono de TB, tamizaje de Chagas y recuperación nutricional. Los informes de todos los programas van automáticos al SEDES y al gestor.
- Imágenes: docs/programas-01..07.png · esboco-programas.html

**✅ Con este módulo quedan dibujados los 16 módulos pendientes del mapa del proyecto.**

### PISO (internación) de Gineco-Obstetricia y todas las especialidades — dibujado, para aprobar (pedido del usuario)
- **Tablero del piso:** cada cama con lo que falta hoy (evolución de la mañana, indicaciones, farmacia, estudios, glicemia, curación, evolución de la tarde) en verde, naranja o rojo. Hay filtro por especialidad y el piso es igual para todas; cambia solo la plantilla.
- **Indicaciones médicas diarias:** el interno propone (copia las de ayer y las cambia), el residente revisa y firma con huella y la planta confirma en el pase de visita. Cada línea va sola a quien la cumple:
  - farmacia;
  - enfermería (kárdex y controles);
  - nutrición;
  - laboratorio (D-8);
  - agenda de ecografía;
  - alertas.
- **Evolución de la mañana (07:00) y de la tarde (16:00):** SOAP con lo automático ya puesto (signos, glicemias, balance, estudios), sin copiar a mano. El residente marca correcciones antes de firmar y firman los dos. Si a las 07:30 falta, avisa al interno; a las 08:00, al residente.
- **Farmacia – recetas de piso:** se generan desde las indicaciones firmadas, una bolsa por cama, y la farmacéutica marca hay / no hay. Todas las bolsas del piso van juntas en una canasta (“Gineco 2º piso · listo 10:30”) y el interno la retira en una sola pasada, con huella.
- **Lo que la familia compra:** lo que no hay va por SMS y en hoja impresa en la cama. Cuando la familia lo trae, enfermería lo escanea (“traído por familia”) y farmacia pide reposición a la red.
- **Ecografía desde el piso:** la indicación cae en la agenda del ecografista, que acepta o propone otra hora. Los pacientes de piso van por la mañana, primero las ARO; el informe vuelve a la evolución de la tarde y a la historia perinatal.
- **Controles indicados (glicemia c/6 h, PA, FCF, diuresis):** curva con rango meta y cumplimiento. Todo entra solo al “O” de la evolución; lo no hecho también aparece.
- **Curaciones indicadas (puérperas, cesáreas, cirugía…):** lista del día desde las indicaciones; registro por toques (aspecto, secreción, infección, dolor, material, foto opcional) con firma. Si está atrasada sale en rojo; un signo de infección avisa al residente.
- **Pase de visita** con el tablet del carro: por cama se ve lo que dice el interno, los datos del sistema y los pendientes. La doctora pregunta y corrobora; los cambios dictados se vuelven indicación urgente y se firman con huella en el carro.
- **Carro de visita:** tablet en brazo giratorio, lector de pulsera, lector de huella, cajones (guantes, curación, glucómetro), alcohol en gel, basura, batería para 8 h y ruedas con freno.
- Imágenes: docs/piso-01..10.png · esboco-piso.html
- **PISO: APROVADO.** Escenas ilustradas para presentación (docs/piso-escena-01..03.png · esboco-piso-escenas.html):
  1. El interno escribe o dicta la evolución de la mañana en la estación de enfermería; el residente revisa y firma con huella.
  2. Retiro de sonda vesical: la indicación aparece como tarea; el registro se hace en 30 s en el celular (hora, balón, orina, aspecto, molestia) y queda la alarma de 1ª micción en 6 h.
  3. Pase de visita con el carro: tablet visible para todo el equipo; la planta corrobora con la paciente y el residente firma en el carro.
- **Estilo “más realista” (prueba):** ilustración vectorial detallada con perspectiva, luz, sombras, proporciones reales y la pantalla real del SIVEC en el tablet (docs/escena-realista-pase-visita.png). Un estilo fotorrealista necesita fotos reales en el hospital (con consentimiento) o un ilustrador/generador de imágenes externo.

### Venta del SIVEC completo (pedido del usuario)
- **Qué falta:** `docs/negocio/SIVEC-que-falta.md`.
  - Especialidades: medicina interna/crónicos, cirugía/trauma, UTI/UCIN, banco de sangre, oftalmología, otorrino, oncología, nefrología, patología, rehabilitación, etc.
  - Programas SUS: Bono Juana Azurduy, SAFCI/carpeta familiar, adscripción SUS, VIH/ITS, ENT, cáncer de mama, malaria/leishmaniasis, muerte materna, adolescentes, adulto mayor, discapacidad, lepra, farmacovigilancia.
  - Transversal: login/roles, integraciones, sin internet, base de DEMO.
- **Modelo financiero editable:** `docs/negocio/SIVEC-modelo-financiero.xlsx` (supuestos, escenarios, métricas, qué se necesita para operar).
  - Referencia: 1er nivel US$180/mes, 2º US$1.400, 3er US$3.800.
  - Bolivia completa ≈ US$14,2 M/año ≈ US$1,16 por habitante por año.
  - Punto de equilibrio ≈ 108 centros de 1er nivel; el piloto solo no se paga (negociar contrato fijo o junto con la ampliación).
- **Demo en vivo:** `docs/SIVEC-demo.html` recorre 26 pasos (historia de una paciente por la red) con “qué decir” en cada pantalla. Esconde los avisos de esbozo y las notas (modo presentación `?demo`).
- **Presentación de venta** (27 diapositivas, en español) con notas del orador: problema → solución → prueba → modelo y precios → confianza → propuesta de piloto.
  - Arquetipo: Cuidador con voz de Sabio.
  - Números entre [__] se completan con datos reales.

### Ambulancias y traslados — dibujado, para aprobar (docs/ambulancias-01..08.png · esboco-ambulancias.html)
- **Central:** mapa en vivo (“Uber” de ambulancias) y sugerencia de la más cercana con el equipo necesario. Entradas: Derivar urgente, 160 y hospital.
- **Pedido desde el centro:** armado con la ficha, prioridad, destino con cama confirmada y requerimientos; SMS a la familia. Sin internet sale por SMS.
- **App del chofer** (navegador del celular): alarma de misión (aceptar en 60 s), ruta, estados con hora y control diario del vehículo.
- **Paramédico:** signos cada 10 min; si empeora, eleva la prioridad y alerta al hospital; funciona sin señal.
- **Hospital:** “llegan pronto”, con signos en vivo y qué preparar.
- **Entrega:** SBAR con huella de quien entrega y quien recibe; línea de tiempo automática en la ficha.
- **Flota:** turnos, oxígeno, km, mantenimiento. Sin control diario no recibe misiones rojas.
- **Indicadores:** tiempos pedido→salida y pedido→hospital, motivos, dónde faltan ambulancias.

### Funciona sin internet — dibujado, para aprobar (docs/sin-internet-01..07.png · esboco-sin-internet.html)
- El equipo guarda una copia cifrada de los pacientes del centro y una cola de envío; envía en orden, con la hora real.
- Barra de estado siempre visible; aviso si un equipo pasa más de 24 h sin enviar.
- Paciente nueva con número provisional; al volver la conexión se une a su historia (nunca se duplica).
- Si dos personas registran lo mismo, decide una persona y queda registrado. Consultas y notas se suman, no se pisan.
- Qué funciona sin internet y qué espera (SEGIP, referencias, resultados de fuera, SMS).
- Control de equipos: último envío, pendientes, bloqueo y borrado a distancia.

### Guía de empresa a venta: docs/negocio/SIVEC-guia-empresa-a-venta.md

### Kiosco de información — dibujado, para aprobar (docs/kiosco-01..05.png · esboco-kiosco.html)
- **Tótem táctil en la entrada:** 6 botones grandes (dónde voy, mi turno, ¿resultado listo?, documentos, campañas, encuesta). Audio en castellano, quechua y guaraní; se cierra solo a los 30 s.
- **Mapa del hospital por pisos** (idea del usuario): “usted está aquí” → destino, con indicaciones, audio, impresión y QR al celular. Ruta sin escaleras.
  - “Visitar a un internado” da piso y cama, sin diagnóstico.
  - El mismo mapa va en la TV y en el SMS de la cita.
- **Mi turno** con huella o CI: quien tiene cita imprime su ficha sin fila. Los resultados solo dicen “listo / en proceso”.
- **Encuesta de satisfacción** con caritas + 2 preguntas (¿le explicaron bien?, ¿le trataron con respeto?), anónima, a la salida.
- **Admin:** contenidos, traducciones, mapa editable, uso y equipos (tótem US$ 1.000–1.500, tablet US$ 300).
- **Idea pendiente:** gamificación de la satisfacción (“mi ganado / mi estancia” o árbol que crece). Privada por médico, pública solo por centro; crece con calidad + satisfacción; mínimo de 20 respuestas. **Esperando que el usuario elija la metáfora.**
- **PDF paso a paso (empresa → gobierno):** docs/negocio/SIVEC-passo-a-passo-empresa-governo.pdf (12 páginas). Fuente: docs/negocio/pdf-src/passo-a-passo.html. Usuario aprobó el kiosco con mapa y la encuesta de satisfacción.
- **SIVEC completo (prototipo navegable):** docs/SIVEC-completo.html. Entrar por función (médico, recepción, enfermería, hospital, farmacia, laboratorio, gestor, admin, ver todo), cada una con su “Para hacer hoy” y su menú de módulos; abre todas las pantallas diseñadas en modo presentación. Publicado como página.

## SIVEC PAP em camadas (para vender primeiro o PAP/VPH)
- Esboço `docs/esboco-pap-capas.html` (pap-capas-01/02.png): Centro de salud → lote de láminas → Oncológico (informa PAP/VPH/biopsia, firma digital) → resultado digital volta ao centro; derivação digital a colposcopia 2º nivel → biopsia → oncológico → resultado CIN → contrarreferencia ao centro.
- Capas: 1 Centro (funciona), 2 Oncológico (desenhado no esboço de laboratório, falta programar), 3 Gestor de red (parcial, por centro), 4 Administración (falta programar).
- Ordem para programar: 1) login+roles+redes/centros, 2) lote de envío, 3) portal oncológico, 4) derivação digital + contrarreferencia, 5) tablero gestor de red.

### [25/09/2026] SIVEC PAP · Passo 1 PROGRAMADO — login com papel + redes e centros
- Sistema real (`SIVEC-PAP-sistema.html`) + SQL **Paso 8** (redes nova + centros_salud e perfiles_usuario que já existiam no Supabase, tudo uuid; pacientes atuais → C.S. San Luis; contas atuais → pessoal de San Luis; administrador pelo correio) e **Paso 9** (RLS: cada centro vê o seu; gestor vê a rede sem editar; admin puro não vê dados clínicos).
- Papéis: Centro de salud · Gestor de red (seletor "Todos / centro X") · Oncológico · Colposcopia 2º nivel (portal "em construção", passos 3 e 4) · Administrador. Casilla "Administra" permite que uma doutora de centro também administre.
- Tela **Admin**: redes, estabelecimentos (1er nivel / 2º nivel colposcopia / oncológico), usuários (cria a conta com senha provisória ou usa a existente; desativar, nunca apagar).
- Com o Paso 8 feito, o login passa a ser obrigatório. Testado com Postgres local (permissões por papel) e no navegador com cada papel.
- Pendente para o passo 5 (painel do gestor): gestor ver números sem nomes, salvo positivos sem tratar.

### [26/09/2026] SIVEC PAP · Passo 2 PROGRAMADO — lote de envio ao oncológico
- SQL **Paso 10**: tabela `lotes` (código L-AAAA-NNNN, centro, destino, transporte, entrega, nº de amostras, estado enviado/recebido, quem recebeu), código de cada lâmina `M-AA-NNNNNN` em `pacientes`, função `sivec_armar_lote` (tudo num passo só). O oncológico vê e recebe só os lotes enviados a ele; o centro não altera um lote já recebido.
- No **Balance**: marcar tomas → destino, data, transporte, quem entrega → **📦 Armar lote** → imprimir **etiquetas** (código de barras Code 128 por lâmina) e **hoja de remisión** (2 cópias, assinatura de entrega e recepção). Lista "Últimos lotes enviados" com "em caminho · N dias" / "recebido".
- Consertos no Supabase do piloto: `consultas.fecha` é timestamp (mostrar/reabrir), `consultas_paciente_id_fkey` apontava para `pacientes_generales` (Paso 7b), regra `perfiles_usuario_rol_check` antiga.
- Imagens: `docs/pap-real/` (telas do sistema real com dados de teste).
- **Ajuste do autor (26/09):** o Oncológico **não é da Red Centro**: é hospital de **4º nível, departamental**, onde se derivam todas as pacientes com risco/suspeita oncológica, e também faz colposcopia. A **colposcopia se habilita por estabelecimento** (uns têm, outros não), independente do nível. SQL **Paso 11** (`hace_colposcopia`, `recibe_muestras` em `centros_salud`); Admin mostra as duas casinhas por estabelecimento; níveis 1º/2º/3º/4º; rede opcional ("departamental"). O papel "Laboratorio de citología" só pode ser dado em estabelecimento que recebe amostras; "Colposcopia" só onde está habilitada.
- **Correção do autor (26/09):** San Luis **não faz colposcopia** (as colposcopias registradas lá são de pacientes atendidas em outro lugar). Paso 11 não habilita mais colposcopia automaticamente. Quando em San Luis se decide **colposcopia ou biópsia**, a paciente é **referida** a outro centro que tenha colposcopia, a um **hospital de 2º nível** ou ao oncológico → isso é o **passo 4 (derivação digital + contrarreferência)**.

### [26/09/2026] SIVEC PAP · Passo 3 PROGRAMADO — portal do laboratório (oncológico) e resultado digital
- Decisão do autor: começar só pela **Red Centro**, deixando o sistema preparado para outras redes e hospitais de 1º, 2º e 3º nível (já é assim: Admin).
- SQL **Paso 12**: `sivec_lab_muestras`, `sivec_lab_recibir`, `sivec_lab_informar` (security definer; o oncológico não lê a tabela de pacientes, só as amostras enviadas a ele, com PAP anterior e anticonceptivo para contexto).
- Portal (papel "Laboratorio de citología"): **Recepção** (lotes em caminho; escanear código de barras de cada lâmina ou marcar; rejeitar com motivo: lâmina quebrada, sem identificação, dados não coincidem, fixação inadequada, amostra insuficiente, não chegou) → **Por ler** (ordem de antiguidade, >15 dias marcado; qualidade, ZT, Bethesda, achados não neoplásicos, VPH/genótipo; validação do patologista obrigatória se não for NILM) → **Firmar e liberar** → **Informadas** (corrigir reenviando).
- No centro: faixa azul **"🔬 N resultados novos do laboratório"** + etiqueta "Resultado novo / Muestra rechazada" e botão **✓ Visto** em cada paciente; próximo passo "Repetir toma (muestra rechazada: …)", "En camino al laboratorio", "En el laboratorio desde…".
- Imagens: `docs/pap-real/lab_*.png`.
- **[26/09] Primeiro lote real:** L-2026-0001 (3 amostras) montado no Supabase do piloto; etiquetas e hoja de remisión impressas. Ajustes: idade "NaN" → "—" quando a data de nascimento está mal cadastrada; impressão sem cabeçalho/rodapé do Chrome; **código de conexão** (⚙ Configuración → "Copiar código de conexión" → colar no outro computador) para conectar laboratório e outros centros sem digitar URL e chave.

### [26/09/2026] Circuito centro → oncológico → centro FUNCIONANDO no Supabase real
- O autor testou: lote L-2026-0001 enviado por San Luis, recebido e informado pelo usuário do laboratório (janela anônima), resultado chegou digital à ficha ("1 resultado nuevo del laboratorio").

### [26/09/2026] SIVEC PAP · Passo 4 PROGRAMADO — derivação digital a colposcopia/biópsia e contrarreferência
- SQL **Paso 13**: tabela `derivaciones` + funções (`sivec_derivar`, `sivec_colpo_lista`, `sivec_colpo_cita`, `sivec_colpo_atender`, `sivec_colpo_biopsia`, `sivec_colpo_no_asistio`, `sivec_der_visto`, `sivec_der_cancelar`). O hospital não lê a tabela de pacientes: só as derivadas a ele, com antecedentes PAP/VPH e celular.
- Centro: ⋯ → **🩺 Derivar a colposcopia / biopsia** (destino = estabelecimentos com colposcopia; motivo sugerido pelo Bethesda/VPH; indicação; prioridade urgente automática em alto grau/VPH 16-18) → boleta de referência impressa (com espaço de contrarreferência em papel para hospitais que ainda não usam o SIVEC). Etiqueta 🩺 no cartão (esperando cita / cita dd/mm / contrarreferencia · nueva), faixa roxa "contrarreferencias nuevas", próximo passo atualizado sozinho.
- Portal de colposcopia (papel "Colposcopia"): Derivadas / Citadas / Biopsia pendiente / Atendidas; cita, não compareceu (avisa o centro para busca ativa), colposcopia com toques (adequada, ZT, achados, Schiller, impressão), biópsia, tratamento (LEEP/cono, crioterapia, ablação, oncologia…), próximo controle, texto de contrarreferência automático → enviar. Resultado da biópsia (CIN 1/2/3, Ca in situ, AIS, invasor) volta a avisar o centro. Colposcopia gravada também na tabela `colposcopias` (ficha/HC) e seguimento PAP+ avança sozinho.
- Imagens: `docs/pap-real/der_*.png`.
- **Correção do autor (26/09):** a colposcopia não é só no oncológico (já era por estabelecimento); e **não deve haver um correio por serviço**: hospitais fazem PAP, leitura, colposcopia e biópsia, e o oncológico também toma PAP. → SQL **Paso 14**: papel único **"Profesional de salud"** + permissões por pessoa **Laboratorio** / **Colposcopia** (só se o estabelecimento tiver o serviço); Portal com seletor 🔬/🩺 quando a pessoa tem os dois. **Cobertura:** com SUS é grátis; sem SUS paga **Bs 30 no caixa do hospital** → a derivação registra SUS/sem SUS e valor; o hospital vê "cobrar Bs 30" e anota o nº do recibo; aparece na boleta de referência.
- **Esclarecimento do autor (26/09):** os **Bs 30 são da toma de PAP** para quem não tem SUS (pago no caixa do hospital). → SQL **Paso 15**: `cobertura`, `monto_pago`, `recibo_caja` na toma (registrar/editar), total cobrado no Balance. Na derivação a cobertura fica só como SUS/sem SUS, valor opcional.

### [26/09/2026] SIVEC PAP · Passo 5 PROGRAMADO — tablero da rede (gestor)
- SQL **Paso 16**: `sivec_red_resumen`, `sivec_red_mensual`, `sivec_red_pendientes` (security definer; gestor = sua rede; admin = todas), meta anual de PAP por estabelecimento (`meta_pap_anual`).
- Tela **Red**: indicadores (tomas e % da meta prorrateada, mulheres distintas, % enviadas ao laboratório, resultado atrasado >90 d, positivas sem tratar, dias do laboratório envio→laudo digital, cobrado sem SUS), gráfico de tomas por mês com detalhe por centro ao passar o mouse, tabela por estabelecimento ordenável com semáforo (⚠ atrasadas, ● sem tratar), lista nominal só das **positivas sem tratar** (busca ativa), Excel com as duas folhas. Períodos: este ano, 12 meses, este mês, tudo ou datas.
- Conforme o esboço aprovado: **o gestor não vê fichas nem nomes** (só o tablero); administradores (inclusive o autor, centro + admin) também veem o tablero e editam a meta ali.
- Imagem: `docs/pap-real/red_tablero.png` (dados de teste).
- **SIVEC PAP: passos 1–5 programados** (login/redes, lote, laboratório, derivação/contrarreferência, tablero).
- **Pedido do autor (26/09):** o tablero do gestor "com gráficos igual ao Panel, interativo, cheio de informação e com movimento, para dar a impressão de atualização a cada momento". → SQL **Paso 17** (`sivec_red_detalle`, `sivec_red_actividad`, `sivec_bethesda`, mensal com filtro por centro). Tela: 6 indicadores animados (tomas + minigráfico, % meta, % enviadas, % entregues, positivas com conduta, dias do laboratório), **funil do tamizaje ao tratamento** (tomas → enviadas → resultado → entregue → positivas → conduta → derivadas → colposcopia → tratamento), **feed "Actividad de la red" em vivo** (sem nomes), tomas por mês com detalhe por centro no hover, avance da meta por centro (semáforo), Bethesda, PAP/VPH com genótipo, idade, cobertura + cobrado, dias do laboratório por mês, tabela e positivas sem tratar. **Atualiza sozinho a cada 30 s** ("● En vivo · actualizado hace X s"), números rolam do valor anterior ao novo e o cartão pisca quando muda; eventos novos entram destacados. Vídeo: `docs/pap-real/red_en_vivo.webm`.
- **[26/09] Tablero em vivo funcionando com os dados reais** (529 tomas em 12 meses, 28 positivas, 15 sem tratar, feed com o lote L-2026-0001). Correção **Paso 18**: toma com resultado conta como enviada (o histórico não tinha data de envio → aparecia "0% enviadas"). Dado real que o tablero revelou: só 15 de 402 resultados estão marcados como **entregues à paciente** (campo "✅ Informada") → ou falta marcar no sistema, ou falta avisar as pacientes.
- **[26/09] Ajuste de dados pedido pelo autor:** resultados de tomas com mais de 90 dias e com resultado → marcados como entregues, data = toma + 3 meses (com tabela de respaldo e SQL para desfazer). Tomas sem resultado e de menos de 90 dias não foram tocadas.
- **[26/09] Lista de insumos do SIVEC PAP** (`docs/negocio/SIVEC-PAP-insumos.pdf`, em espanhol para compras): o que cada lugar precisa (centro, laboratório, colposcopia, gestão), lista detalhada com especificação, modelos de referência, preço referencial e prioridade, **instalação do leitor de código de barras** (USB = teclado, teste no Bloco de notas, guion ↔ teclado latino-americano já corrigido no SIVEC, sufixo Enter), onde vai a etiqueta (lâmina: grafite no esmerilado + etiqueta no porta-lâminas; fase 2: etiqueta de poliéster resistente a xilol com QR), orçamento do piloto Red Centro e checklist para um centro novo.
- **[26/09] Ajuste de dados:** todas as tomas de San Luis registradas como **enviadas ao Oncológico na data da toma** (lotes históricos mensais `L-HIST-AAAA-MM`, recebidos) e, no portal do laboratório, as que têm resultado como **informadas e devolvidas a San Luis** (sem inundar o aviso de "resultado novo"); as sem resultado ficam "Por leer". Com respaldo e SQL para desfazer.
- **[26/09] Resultado real:** 527 tomas em 12 lotes históricos, 402 informadas, 125 no laboratório sem resultado; tablero 12 meses: Enviadas 100%, com resultado 402 (76%), entregues 293 (73% dos resultados). O feed "Actividad de la red" agora ignora os lotes históricos `L-HIST-*` (não são atividade real).
- **[26/09] Cada um na sua função (pedido do autor):** o e-mail do Rodrigo vira **administrador geral** (sem centro nem rede): vê o tablero geral de todas as redes, com **tomas por profissional**, e a administração (redes, estabelecimentos, usuários, profissionais de cada centro). Contas separadas: `gestor.redcentro@sivec.bo` (gestor da Red Centro, só números da rede) e `medico.sanluis@sivec.bo` (centro San Luis, o sistema normal). Ninguém mais fica com "admin de costado". Novo: **profissionais por estabelecimento** (Admin → Establecimientos → 👩‍⚕️), que alimentam o seletor "Doctora responsable"; botão 🔑 para cada um trocar a senha provisória; botão sair sempre visível (troca de conta recarrega a página). SQL **Paso 19**.
- **[26/09] Antessala nova (pedido do autor):** tela de entrada "futurista" na identidade bordô: fundo com brilhos e rede de pontos pulsando, o fluxo Toma → Lote → Laboratório → Resultado → Colposcopia → Tratamento acendendo em sequência, e quatro botões de acesso — **Administración, Red de salud, Centro de salud, Hospital (2º/3º/4º nível)**. Cada botão lembra o último e-mail usado; o painel que abre é decidido pelo perfil do usuário (se escolheu o botão errado, avisa e abre o certo). Funciona no celular.
- **[26/09] Mapa por função:** o **gestor** ganhou o Mapa (busca ativa da rede) com seletor "Todos los centros / um centro"; o **administrador** vê todos os centros, hospitais de 2º/3º nível, oncológico e a **área de cada rede** (contorno tracejado). Cada estabelecimento tem um **ícone fixo** (cor por nível), e o centro vê o seu como ponto de partida. O administrador marca/arrasta a localização (📍 Ubicar establecimiento). SQL **Paso 20**. Gestor e admin não arrastam pins de pacientes.
- **[26/09] Ideia do autor — família de mascotes/avatares:** um para o SIVEC PAP, um para cada programa e um para o SIVEC completo. Opinião: sim, vale — para a comunidade (cartazes, WhatsApp, lembretes de toma) e para o sistema (estado vazio, ajuda, conquistas de meta), com um traço comum (ex.: a fita/laço do logo como "DNA" da família) e cada programa com cor e acessório próprio. Cuidado: tom respeitoso (câncer), não infantilizar, funcionar em preto e branco e pequeno. Próximo passo sugerido: 3 conceitos do mascote PAP antes de desenhar a família.
- **[26/09] Mascotes — conceitos desenhados** (`docs/negocio/mascotas/SIVEC-mascotas.html`): 1) **Lazi**, o laço do logo com vida; 2) **Paby**, a paraba frente roja (endêmica da Bolívia), a mensageira que avisa o resultado — **recomendado**; 3) **Sivi**, a promotora de saúde. Família "fauna da Bolívia": Tatú (vacinas), Vicu (TB), Hornerito (Chagas), Firu (zoonose/raiva), Capi (materno), **Yagua/jaguar = SIVEC completo**. Todos com o laço bordô como DNA e a cor do programa. Admin: botão 📍 Ubicar em cada estabelecimento.
- **[26/09] Pedido do autor:** (1) **editor** de redes (nome, município; excluir se não tiver estabelecimentos) e de estabelecimentos (nome, rede, nível, código, **endereço**) — ✏️ em cada linha; (2) **Centro de comando** do administrador: tema escuro tecnológico sempre ativo (grade, brilhos, linha néon no cabeçalho, relógio ao vivo, "Sistema en línea", 6 indicadores animados: redes, estabelecimentos, usuários, laboratórios, colposcopia, sem localizar); o tablero geral também fica no tema; (3) **ícones de hospital** no mapa: pin com prediozinho — pequeno no 1º nível, maior no 2º, maior com alas no 3º e o maior com o laço no oncológico, com sombra e onda pulsando; (4) **🛰 Buscar ubicaciones**: o sistema procura cada estabelecimento pelo nome e pelo endereço (Google se houver chave, Photon, OpenStreetMap) e coloca o ícone aproximado; o admin arrasta para ajustar. SQL **Paso 21** com os endereços da Red Centro pesquisados e o Oncológico já com coordenadas (Av. Noel Kempff Mercado #890).
- **[26/09] Mascotes v2 (autor achou infantil):** mesma ideia (paraba frente roja) em 3 estilos adultos, sem olhos de desenho animado nem bochechas: **A · Facetado** (emblema geométrico, planos de cor), **B · Monolínea** (um traço bordô + acento vermelho), **C · Selo** (insígnia institucional "SIVEC · PAP/VPH — Te avisa · Te cuida"). Família testada com o jaguar nos estilos A e B. Recomendação: A como mascote + C como versão oficial.
- **[26/09] Proteção de dados (Paso 22):** RLS ativa — centro lê/edita só o seu; gestor lê a rede; admin lê tudo (não edita); sem sessão nada; tabelas antigas/respaldo fechadas. **Linha do tempo entre centros** (ideia do autor: "a base de tudo do SIVEC geral é a linha do tempo"): a ficha mostra as tomas da mesma mulher feitas em OUTROS centros (por carnet ou nome+nascimento), só o resumo clínico, com selo "🏥 C.S. X"; no cadastro, ao digitar o carnet, avisa "esta mulher já tem N tomas em outro estabelecimento". Cada consulta fica registrada em `historial_accesos` (auditoria).
- **[26/09] Banco DEMO para vender** (`docs/negocio/SIVEC-DEMO.sql`, um único script para um Supabase novo): estrutura completa (base + todos os Pasos até o 22, testado do zero), 2 redes (Red Centro com 9 centros + Hospital Francés; Red Norte com 3 centros + hospital de 2º nível), San Juan de Dios (3º) e Oncológico, **~8.000 tomas fictícias em 18 meses** (nomes, CI, celulares e endereços inventados, com localização no mapa), 252 lotes, laudos digitais, ~580 derivações com colposcopia/biópsia/contrarreferência, positivas sem tratar para busca ativa, cobrança sem SUS, e 60 mulheres com tomas em dois centros (linha do tempo). 7 contas de teste (senha Demo-2026). O sistema detecta a base demo (`sivec_meta`) e mostra a faixa **"DEMOSTRACIÓN · datos ficticios"**; na entrada, cada botão já traz a conta de teste.
- **[26/09] Autor decidiu não usar a base DEMO: vai apresentar com os dados reais** (mais fiel). O script DEMO colado por engano na base real foi rejeitado pelo Supabase (erro → nada aplicado); o `SIVEC-DEMO.sql` agora se recusa a rodar se o projeto já tiver pacientes. Criado o **Modo presentación** (Configuración): números reais, mas nome, carnet, celular e endereço aparecem trocados por dados fictícios estáveis (a mesma mulher continua agrupada) e **nada é gravado** (insert/update/delete e RPCs de escrita bloqueados); faixa "MODO PRESENTACIÓN" visível.
- **[26/09] Apresentação de venda do SIVEC PAP** (14 slides, espanhol, com notas do orador): https://claude.ai/artifact/YVPekChWwUu5dU2FbX65vr — problema → dado real (15 de 402) → solução em 6 passos → telas reais (centro/linha do tempo, laboratório, colposcopia, gestor, mapa, centro de comando; capturas com dados de teste) → prova com números reais de San Luis (529 tomas, 100% enviadas, 73% entregues, 15 positivas sem tratar identificadas) → proteção de dados → piloto Red Centro em 3 meses (equipamento Bs 4.510–9.050; implantação e suporte [Bs __] a completar) → fechamento com contato [a completar].
- **[26/09] Apresentação ampliada para 34 slides (pedido do autor: "10 min não mostra valor")**: agenda; **a dor dos profissionais** (um dia de toma em papel em 6 passos; "5 vezes" — os mesmos dados em D1, D8, PAP, consentimento e HC); **a consulta passo a passo** com prints reais novos (entrada, cadastro em 3 passos, consulta SOAP com toques, tratamento que monta a receita, **D1 para a farmácia completo e legível**, 5 formulários num clique); **o seguimento** (lista com próximo passo, ficha/linha do tempo, lote com código de barras, laboratório, resultado chegando, PAP+ por etapas, derivação, colposcopia, métodos); **a rede** (painel do centro, mapa, gestor, comando); **valor** (tabela antes/com SIVEC por pessoa; "o que o piloto vai medir" com [__] a completar); prova San Luis; segurança; piloto; fechamento. Cada tela tem a faixa "Antes:" com a dor que resolve. Prints salvos em `docs/pap-real/presentacion/`.
- **[26/09] Correção do autor:** não é piloto — **San Luis já foi o piloto**; a proposta é **ampliar** (Red Centro → outras redes). Slides "piloto", "medimos" (antes / com SIVEC / meta na rede), "resultados" e "cierre" ajustados. **Pesquisa de mercado e preço** em `docs/negocio/SIVEC-precios-mercado.md`: não existe nada igual; registros públicos (SITAM, SISCAN, CSMS) são do governo, grátis e só registram; Austrália pagou A$ 220 mi/5 anos à Telstra pelo registro nacional; prontuários completos: Rayen ~US$ 6 mil de licença por estabelecimento, Epic US$ 500–1.000/leito, TELUS CAD 100+/mês por médico. Na Bolívia o Ministério tem SOAPS/SICE (SUIS, software livre) → vender o SIVEC como o circuito que falta e exportar para SNIS. **Proposta SIVEC PAP:** Bs 700/mês por centro de 1º nível, Bs 1.750 por hospital 2º nível, Bs 3.500 por laboratório/3º nível; implantação Bs 3.500/7.000/10.500. Red Centro ≈ Bs 138.600/ano (≈ Bs 29 por toma) + Bs 35.000 de implantação → ANPE. SIVEC geral: US$ 180/1.400/3.800 por mês por nível.
- **[26/09] Métrica Bolívia** (`docs/negocio/SIVEC-metrica-Bolivia.xlsx`, fórmulas vivas): preços do autor US$ 100 (1º nível), 250 (2º), 501 (3º/lab/oncológico) + **US$ 300 por rede (proposta, editável)**. Por departamento (106 redes, ~3.410 centros, 249 hospitais 2º, 51 de 3º/labs; estimativas marcadas) → Bolívia 100% ≈ **US$ 460.600/mês ≈ US$ 5,5 mi/ano (Bs 38,5 mi)**; 16 maiores cidades ≈ US$ 1,3 mi/ano. Fases: Red Centro US$ 1.951/mês; município SCZ US$ 14.208/mês; departamento SCZ US$ 104.813/mês; Bolívia US$ 460.601/mês. Equipe por fase (3 → 9 → 21 → 48 pessoas, 17 cargos) e ferramentas (Supabase, WhatsApp API, Sentry, backup, pentest…). Lucro líquido: negativo nas fases 1–2, ≈ US$ 479 mil/ano na fase 3 e ≈ US$ 2,76 mi/ano na fase 4 (margem ~50%).
- **[26/09] Métrica só Santa Cruz de la Sierra** (`docs/negocio/SIVEC-metrica-SantaCruz.xlsx`): 4 redes municipais, 65 centros de 1º nível (Red Centro 9 reais; Norte/Sur/Este estimados), 5 hospitais municipais de 2º nível (Francés, Villa 1ro de Mayo, Pampa de la Isla, Plan 3000, Bajío del Oriente), 5 de 3º nível (SJD, Japonés, Niños, Percy Boland + 1 a confirmar) e o Oncológico (4º). Com os preços do autor + US$ 300 por rede: **US$ 11.956/mês ≈ US$ 143.472/ano ≈ Bs 998.565/ano**. Equipe enxuta (7 pessoas em operação, 9 na implantação) + ferramentas US$ 1.655/mês → lucro líquido ≈ US$ 10,8 mil/ano (7,5%) a partir do ano 2; ano 1 ≈ US$ 29,7 mil com implantação (proposta US$ 500/1.000/1.500 por estabelecimento).
- **[26/09] Onde fica e como recebe** (`docs/negocio/SIVEC-onde-fica-e-como-recebe.md`): SIVEC = site (telas em Vercel/Cloudflare + dados no Supabase região São Paulo; opção de servidor na Bolívia se exigirem); custo técnico ~US$ 100/mês (Red Centro), ~US$ 380 (cidade), ~US$ 6.100 (país); instalação = navegador + atalho + usuários + leitor/impressora, funciona no mesmo dia; pagamento público: POA/orçamento (preparar em set–out), contratação menor/ANPE/licitação, SICOES + RUPE, contrato por gestão em Bs, garantias, fatura mensal → conformidade → SIGEP (30–60+ dias). Pendências técnicas: publicar como site sivec.bo, "Instalar app", Supabase Pro + backup externo, monitoramento.
- **[26/09] Cobro de Bs 30 desligado** (pedido do autor: "não vai ser preciso agora, depois implementamos"): `COBRO_ACTIVO = false` esconde cobertura SUS/sem SUS, monto e recibo no registro, derivação, portal de colposcopia, balance e tablero. Os dados guardados não se apagam; para voltar, `COBRO_ACTIVO = true`.
- **[26/09] Linha do tempo completa (Paso 23)**: cada toma mostra na ficha o recorrido inteiro como eventos — enviada (lote), recebida/rechaçada no laboratório, informe assinado, resultado entregue, derivada a colposcopia, cita, colposcopia, biópsia, contrarreferência, derivada a tratamento, tratamento realizado. O SQL estende `sivec_linea_tiempo` para trazer o mesmo recorrido quando a mulher se atendeu em outro estabelecimento. Mapa da rota: artifact "Rota da paciente SIVEC PAP".
- **Ideia (autor, 26/09):** atalho para hospital que colhe e lê a própria amostra (sem lote para si mesmo) e botão "Derivar aqui mesmo" no informe positivo.
- **[26/09] Autotoma de VPH (Paso 24)** — pedido do autor ao ver que outros hospitais já fazem autotoma: forma de toma (autotoma vaginal / profesional), autotoma no estabelecimento ou em casa com kit (entregue/devolvido; kit em casa não entra no lote), laboratório do lote: próprio, outro estabelecimento do SIVEC ou externo fora do SIVEC (nome livre), provas que cada laboratório processa (PAP/VPH), laboratório informa amostra só de VPH sem Bethesda e com a prova usada (GeneXpert, cobas, careHPV…). Pesquisa em `docs/SIVEC-VPH-autotoma.md`. Corrigido: antes o portal exigia Bethesda em amostra só de VPH.
- **Ideia:** triagem do VPH+ (16/18 → colposcopia direta; outros alto risco → PAP/IVAA) como sugestão automática no seguimento VPH+.
- **[26/09] Sitio + empresa** — `web/` (PWA, config.js, cabeceras) y guía `docs/SIVEC-publicar-sitio.md`; hospitales con laboratorio propio (Paso 25: lote interno recibido directo; derivación ofrece el propio hospital). Marca: empresa **Enlace Clínico S.R.L.** (eslabones) y producto **SIVEC** (línea de tiempo) en `docs/marca/`. Documentos en `docs/empresa/`: carpeta SENAPI (derecho de autor + marca; software no es patentable, CAN 486 art. 15), guía de la empresa (SEPREC, NIT, RUPE/SICOES, Trabajo, dominio, software libre DS 1793, posicionamiento, Supabase Pro, lo que falta), contrato modelo (US$ 100/250/501, provincias = 1er nivel, PI y datos protegidos) y video demostrativo con datos ficticios.
- **[27/09] Ponto 8 ("o que estamos esquecendo") feito**: no sistema — aceite de termos de uso/privacidade por usuário (Paso 26, tabela `sivec_aceptaciones`), consentimento da paciente no registro (`consent_registro_digital`), soporte por WhatsApp + versão em ⚙ Configuración (config.js `soporte`), **modo sem internet** (tomas novas ficam na computadora e enviam sozinhas; perfil guardado; service worker guarda as bibliotecas), **informe mensual SNIS** (Balance → Excel por grupo de idade, sem nomes; confirmar casilleros com o estatístico), páginas `web/terminos.html` e `web/privacidad.html`, `scripts/sello-version.sh` (huellas SHA-256 por versão). Documentos em `docs/empresa/01…07`: carta de conformidade do piloto, autorização de dados agregados, acordo de confidencialidade, consentimento da paciente, termos e privacidade, plano de incidentes e suporte, guia operativa (versões, SNIS, sem internet, contador, seguro). Nome/logo da empresa: em espera (painel com 8 opções).
- **[27/09] Colposcopia completa no portal do hospital** (pedido do autor): mapa do colo por horas (o mesmo círculo do centro), união escamocolunar, tamanho da lesão, achados IFCPC 2011 (normal, grau 1, grau 2, não específicos, suspeita de invasão, vários), IVAA, Schiller (Lugol), biópsia com fragmentos/sítios/legrado; contrarreferência imprimível com o mapa; **folha para a paciente em letra grande** (aonde ir, quando, para quê, o que levar). **Preços definidos**: 1º nível US$ 100 (com colposcopia e biópsia US$ 250), 2º US$ 250, 3º/4º e laboratórios PAP/VPH US$ 501; implantação 200/500/550; tablero de rede incluído. Exemplo Red Centro + Oncológico: US$ 1.801/mês, US$ 21.612/ano, implantação US$ 2.850, primeiro ano US$ 24.462 (Bs 170.255,52). Contrato, preços de mercado e apresentação (slides incluye/precios/ejemplo) atualizados.
- **[27/09] Formulários oficiais de referência e contrarreferência** (Norma Nacional de Referencia y Retorno, RM 1036/2008 — Formulário Nº 1 e Nº 2) no mesmo layout do D1, preenchidos com a derivação: estabelecimentos, paciente, motivo, anamnese, sinais vitais (em branco), exames, diagnóstico presuntivo com CIE-10 sugerido, condições do traslado, recepção; o Nº 2 com diagnóstico final, colposcopia com mapa do colo, biópsia, tratamento e recomendações. O PDF oficial não pôde ser baixado (bloqueado): conferir os campos com o formulário impresso da Red.
- **[27/09] Referência com todos os antecedentes (Paso 27)**: bloco na derivação (gineco-obstétricos completos, personais, familiares, sinais vitais, exame) pré-preenchido da última consulta e do histórico; vai ao Formulário Nº 1 e ao portal do hospital. Consulta SOAP ganhou menarca, ciclos, HV e data do último parto.

## 27/09/2026 · Animación de entrada al perfil (v1.5.0)
- Al iniciar sesión aparece una pantalla con cuatro bolitas que rebotan (colores del SIVEC) y el texto "Entrando como Centro de salud / Hospital / Red / Administración".
- Queda visible al menos 0,9 s y se desvanece al abrir el panel; si la contraseña falla, se quita al instante.
- Respeta "reducir movimiento" del sistema (sin rebote). Idea tomada del cargador de renderforest.
- v1.5.1: las bolitas ahora giran en forma de infinito (∞) dejando estela de color. Interactivo: el ∞ se inclina hacia el ratón o el dedo, y al tocarlo las bolitas aceleran (y el celular vibra un toque). Mensajes de avance: "Verificando tu acceso… → Cargando tu establecimiento… → Abriendo tus pacientes… → Casi listo…". Dura al menos 1,6 s.

## 27/09/2026 · Velo degradé en los gráficos (v1.5.2)
- "Tomas por mes" (panel del centro y tablero de la red): curva suave que une la punta de las columnas, con un velo en degradé lila que cae y se desvanece, y un punto brillante en el mes actual. Se dibuja de izquierda a derecha al abrir el panel.
- Las mini líneas de los indicadores también tienen el relleno en degradé.
- Presentación: slides "El panel del centro" y "La red en vivo" con capturas nuevas (datos de prueba).

## 27/09/2026 · Planilha de Santa Cruz com os preços novos, papel e vidas
- `docs/negocio/SIVEC-metrica-SantaCruz.xlsx` refeita: 4 cenários (Red Centro, Município enxuto, Município completo, Município + províncias), equipe, gastos (aluguel, transporte, viagens), caixa necessário.
- Abas novas: "Papel vs SIVEC" (papel, horas devolvidas, tomas repetidas) e "Vidas e impacto" (lesões tratadas a tempo, cânceres e mortes evitados, órfãos, valor da vida, tratamentos que o SUS deixa de pagar), com fontes.
- Proposta de slides de impacto (vidas, família, papel) enviada ao autor para validar antes de montar.
- Apresentação: 5 slides novos depois de "Funcionando con datos reales": "Cada día, 4 o 5", "María, 41 años" (caso ilustrativo), "Lo que el SIVEC evita cada año" (gráfico com véu), "¿Cuánto vale salvarla?" (sem valor em dólares da vida, como o autor decidiu) e "El papel vs el SIVEC" (1,7× só em tratamentos e tempo).
- Planilha: linha "Tablero da rede" (US$ 250 no slide de preços) em 0 por padrão; o slide "Incluye" diz que o tablero vem incluído — decidir.

## 27/09/2026 · Soporte dentro del sistema (v1.6.0 · Paso 28)
- Botón redondo 💬 abajo a la derecha en todas las pantallas (también en el inicio de sesión, para "no puedo entrar").
- WhatsApp con los datos del sistema ya escritos (versión, pantalla, centro, conexión, último error; nunca datos de pacientes), llamada y "Escribir al equipo": chat guardado en Supabase con categoría y marca de urgente.
- El equipo de soporte (`es_soporte`) ve la bandeja de todas las consultas, responde, cambia el estado y ve los datos del sistema. Aviso con número rojo cuando hay respuesta nueva; revisa cada minuto.
- Paso 28 probado en la copia local: cada uno ve lo suyo, nadie se hace pasar por soporte, el gestor no ve consultas ajenas.

## 27/09/2026 · Captura de pantalla obligatoria en el soporte (v1.6.1 · Paso 29)
- Al tocar 💬 el sistema saca solo la captura de la pantalla donde estaba la persona (html2canvas-pro, sin el botón ni la ventana).
- Para abrir una consulta la captura es obligatoria: se puede cambiar (📸 capturar pantalla en computadora, 📎 elegir del celular, pegar con Ctrl+V, arrastrar), pero el botón Enviar queda bloqueado sin imagen.
- En el chat, 📎 opcional para los dos lados (el equipo también manda capturas). Imágenes en Supabase Storage privado (bucket sivec-soporte), enlaces que vencen en 1 hora.

## 27/09/2026 · Presentación: slide "Derivar" con los Formularios Nº 1 y Nº 2 (v1.6.2)
- El slide 22 ahora muestra la referencia Nº 1 y la contrarreferencia Nº 2 del SIVEC (datos de prueba) en lugar de la hoja de la paciente.
- Correcciones en los formularios: talla en metros ("1.58 m"), próximo control con fecha DD/MM/AAAA, "Red: —" cuando el establecimiento no tiene red (Oncológico).

## 27/09/2026 · Firma electrónica con PIN (v1.7.0 · Paso 30)
- Decisión del autor: nada de celular personal (hay médicos mayores sin smartphone). PIN personal de 6 números para firmar: informe de laboratorio (PAP y VPH), colposcopia, referencia y contrarreferencia.
- La primera vez que firma, la persona crea su PIN; se guarda cifrado (bcrypt), 5 intentos fallidos = bloqueo de 15 min, el administrador lo restablece. PINs fáciles (111111, 123456) rechazados.
- Cada firma registra quién, cuándo, establecimiento y la huella SHA-256 del contenido; solo firma quien tiene que ver con el documento. Formularios Nº 1 y Nº 2 impresos: "Firmado electrónicamente… · código de verificación XXXX-XXXX · huella". ⚙ Configuración: crear/cambiar PIN, verificar un código, restablecer (admin).
- Sin el Paso 30 el sistema sigue funcionando como antes (sin firma).
- SIVEC completo (a futuro): lector de huella en cada computadora (kit opcional en la implantación, ~US$ 40–100 por lector) + convenio con el SEGIP para verificar identidad en línea; firma digital con certificado AGETIC/ADSIB (Bs 70 + token) cuando el SEDES la exija.

## 27/09/2026 · La firma con PIN en todo el recorrido (v1.7.1 · Paso 31)
- El PIN lo crea cada profesional (el administrador solo lo restablece). Un solo PIN para todo.
- Firma también: la consulta (sale en D1, D8, registro de PAP, consentimiento e historia clínica), la aceptación de la referencia en el hospital (al dar la cita) y la recepción de la contrarreferencia en el centro. Las firmas de la paciente siguen a mano.
- Ventana del PIN rediseñada (6 casillas, tarjeta del documento, sacudida si falla) y bloque "Firma electrónica" en ⚙ Configuración. Slide "Cada profesional firma con su PIN" después de "Derivar".
- Próximo tema: sonidos en el sistema (propuesta enviada al autor).

## 27/09/2026 · Presentación: tres slides de seguridad
- "Firmado de punta a punta" (4 firmas de una paciente derivada, con sus códigos, y los pies de los Formularios Nº 1 y Nº 2), "¿Esta firma es verdadera?" (verificación del código y huella que cambia si alguien altera el documento) y "Seis candados para los datos de cada mujer" (acceso por rol, PIN cifrado, huella, código, registro de accesos, copias diarias + HTTPS).
- Ojo: "copias diarias" requiere tener el Supabase Pro activo.
- Firma de la paciente: propuesta enviada (firma en pantalla con el dedo + huella a futuro); a definir con el autor.

## 27/09/2026 · Sonidos (v1.8.0)
- Sonidos sintetizados en el navegador (sin archivos, funcionan sin internet), volumen bajo: firma ✍ (3 notas que suben), resultado alterado ⚠ (alerta de 3 notas), mensaje 💬 (resultado nuevo, contrarreferencia, respuesta de soporte), error ✖ (PIN incorrecto, errores), guardado ✓, entrada al perfil (whoosh suave).
- ⚙ Configuración → Sonidos: Todos (por defecto) · Solo alertas · Apagado, por computadora, con botones para probar.
- Los avisos de resultados y contrarreferencias suenan solo cuando llegan nuevos (no se repiten).
- Corregido: los avisos con tipo 'error' salían verdes; ahora rojos.
- Firma de la paciente: sin celular → firma con el mouse en la pantalla; con celular → código por WhatsApp (a implementar).
- Muestras de los sonidos en docs/sonidos/.

## 27/09/2026 · Saludo con voz y tarjeta "Para hoy" (v1.9.0)
- Al entrar (una vez por día y por persona), la voz del navegador saluda por el nombre y el trato (doctora/doctor/licenciado…, sacado del nombre del perfil) y dice lo que hay para hoy según la función: centro (resultados nuevos y alterados, derivar, positivas sin conducta, contrarreferencias, entregar, atrasados), laboratorio (lotes por recibir, muestras por informar), hospital (referencias nuevas, citas de hoy, biopsias pendientes), gestor/admin (% de la meta del año, positivas sin tratar, atrasados).
- Nunca dice nombres de pacientes. Tarjeta "Para hoy" con los mismos números; cada ítem abre la lista ya filtrada. 🔊 para escuchar de nuevo. ⚙ → Sonidos → "Saludo con voz: Sí/No · Escuchar".
- Sonidos ajustados: los avisos verdes comunes ya no suenan; error más suave (triángulo, grave); sin sonido de entrada.

## 27/09/2026 · Voz masculina, clima y frases del día (v1.9.1)
- ⚙ → Sonidos → Saludo con voz: 👩 Femenina · 👨 Masculina · Sin voz. Si la computadora no tiene voz masculina en español, se aproxima con tono más grave.
- El saludo dice el clima (Open-Meteo, gratis, solo la ubicación del establecimiento): temperatura, estado, máxima; paraguas si lluvia ≥ 60 %, agua si ≥ 35 °C, abrigo si mínima ≤ 14 °C. En la tarjeta: ⛅ 29° · máx 34° · ☂ 70 %.
- Frase del día (día por medio, siempre si no hay pendientes): "Hoy es un buen día para salvar vidas", "Cada PAP que se toma hoy puede evitar un cáncer mañana"…
- Pregunta del autor: hospitales con recepción, consultorio de toma, colposcopia y laboratorio (recepción de láminas / lectura) → propuesta de "funciones" por usuario y cola del día (a definir).

## 27/09/2026 · Funciones por persona, cola del día y pantalla de espera (v1.10.0, Paso 32)
- Un usuario por persona. Admin → Usuarios → **Funciones**: Admisión/recepción · Consultorio de toma · Consultorio de colposcopia · Recepción del laboratorio · Lectura del laboratorio · Jefe. Sin marcar = ve todo (como hasta ahora; los centros de 1er nivel no cambian nada). Marcar colposcopia o laboratorio activa solo el permiso correspondiente.
- Cada función ve solo sus pantallas: recepción (Hoy, Registrar, Pacientes), toma (Hoy, Registrar, Pacientes, PAP+, VPH+), colposcopia (Hoy, Pacientes, Portal), laboratorio (Portal, con solo la pestaña de recepción de láminas o de lectura), jefe (todo).
- Admin → Establecimientos → 🚪: consultorios del establecimiento (ej: Consultorio 1, Consultorio 2, Colposcopia).
- Pantalla **Hoy**: la recepción busca a la paciente (o registra una nueva), elige Toma / Colposcopia / Consulta y el consultorio, y la manda ➜ recibe número de turno del día. Las citas de colposcopia de hoy aparecen para marcar "Llegó". En el consultorio aparecen solo sus pacientes: 📣 Llamar · Atender (abre la toma, la ficha o la colposcopia de esa derivación) · ✔ Atendida. Se actualiza sola cada 15 s y suena cuando llega una paciente nueva.
- 📺 Pantalla de espera para la TV de la sala: número de turno y consultorio (nunca el nombre), con sonido y voz "Turno 5, Consultorio 2".
- "Para hoy" suma "N pacientes esperando en la cola".
- Corregido de paso: las pestañas del laboratorio (Recepción/Por leer/Informadas) quedaban sin reaccionar cuando el usuario tenía laboratorio y colposcopia a la vez.
- Paso 32 del SQL: columnas `funciones` (usuarios) y `consultorios` (establecimientos) y tabla `sivec_turnos` con número automático por día y regla: solo el propio establecimiento.

## 27/09/2026 · Pantalla de espera desactivada por ahora
- Decisión del autor: la 📺 pantalla de la sala de espera no se usa por ahora (varios hospitales ya tienen su propio sistema de turnos). Se quitó el botón; el código queda guardado para activarlo si algún hospital lo pide. El 📣 Llamar sigue marcando en la cola que la paciente fue llamada.
- Guía visual paso a paso (12 pasos, datos ficticios) en docs/guias/fila-del-dia/ (PNG + PDF).

## 27/09/2026 · Pendientes anotados
- Próximo: tabla de accesos y, en el panel del administrador, organizar todos los profesionales y las computadoras (qué equipo, de qué establecimiento, quién lo usa).
- Pregunta del autor: voz más interactiva → propuesta enviada (avisos por voz en el momento, comandos de voz cortos, resumen del día, voces naturales de Edge; asistente conversacional más adelante).

## 27/09/2026 · Avisos por voz durante el día (v1.11.0)
- Frases cortas en el momento, después del sonido y sin cortar el saludo: "Llegó un resultado alterado del laboratorio", "Llegaron resultados nuevos", "Llegó una contrarreferencia nueva", "Tiene una paciente nueva en espera", "Referencia firmada" / "Contrarreferencia firmada y enviada" / "Informe firmado"…
- Metas: al pasar 25/50/75/100 % de la meta anual del establecimiento (una sola vez cada una): "El centro llegó al 50 % de la meta del año… ¡Sigan así!".
- Resumen del día (una vez, después de las 16:30 si el sistema está abierto): tomas de hoy comparadas con ayer, pacientes que pasaron por la cola, muestras informadas por el laboratorio.
- Nunca dice nombres de pacientes. El mismo aviso no se repite en 20 s.
- ⚙ → Sonidos → "Avisos por voz durante el día: Sí / No / ▶ Probar" (por computadora). "Sin voz" también los apaga.

## 27/09/2026 · Nombre de empresa: "Vittatech" (revisado, no recomendado)
- Vitta (Vitta Tecnologia em Saúde S.A., São Paulo, del grupo Stone) es una healthtech grande: historia clínica, gestión de clínicas, hospital digital; usa @vittatech en Instagram y Facebook y vittatech.com.br está tomado por otra Vitta Tech. También existen Vitta Technologies LLC (EE.UU., vittatech.us) y una farmacia "Vitta Tech".
- Riesgo: confusión en el mismo rubro (software de salud), redes sociales y dominios ocupados, posible oposición si Vitta registra en la región. Alternativa a evaluar: "Kuyay" (quechua: amar, cuidar) — solo aparece una chocolatería peruana, otro rubro.
- Segunda ronda (búsqueda en Google): **Tekove** (guaraní: vida; solo una residencia de ancianos en España y una consultora de RRHH; en Bolivia existe la escuela de salud Tekove Katu, sin fines de lucro) → recomendado. **Illari** (quechua: amanecer) → libre en salud/tecnología. **Kuyay** → libre en salud. Descartados: Kawsay (existe Kawsaytec, software) y Yuyay (Yuyay AI y cooperativa Yuyay).
- El autor no quiere nombres en guaraní, quechua u otras lenguas originarias. Tercera ronda (nombres de raíz española/latina, estilo "Vittatech"): **Vivacia** (de "vivaz": solo personajes de ficción, un suplemento en Reino Unido y una agencia; nada en salud/software en Latinoamérica) → recomendado. **Cuidara** (de "cuidar") → libre. **Prevenia** (de "prevenir") → existe PREVENIA S.L. en Asturias (prevención laboral), riesgo medio. Descartados por ocupados: Vidatech (varias en Brasil, software), Salvatech (Brasil/Colombia, tecnología), Vitalys/Vítaly (salud en España, software clínico en México).
- Cuarta ronda, con el apellido del autor: "Ferreira Tech" existe en Brasil (varias consultoras de informática, @ferreiratech48, @ferreiratech.solution; Ferreira Tecnologia – ferreiratec.com.br) → no conviene tal cual. "Ferreira Salud" / "Ferreira Health" en software: sin resultados → recomendado **Ferreira Salud Digital S.R.L.** (o marca corta "Ferreira Salud"). Ventaja: el apellido deja clara la autoría. Cuidado: una marca con apellido es más difícil de vender por separado si algún día se vende la empresa.

## 27/09/2026 · Nombre de la empresa definido: **Ferreira Salud Digital S.R.L.**
- Decisión del autor. Marca corta para logo y redes: **Ferreira Salud**. El producto sigue siendo **SIVEC** ("SIVEC, de Ferreira Salud Digital").
- Reemplaza la propuesta anterior "Enlace Clínico S.R.L." en: guía de la empresa (renombrada Ferreira-Salud-Digital-guia-empresa.docx; alternativas de homonimia: Ferreira Salud S.R.L., Ferreira HealthTech S.R.L.), carpeta SENAPI (marca de la empresa), contrato modelo (el PROVEEDOR), términos de uso (docx y web/terminos.html), privacidad (web/privacidad.html), acuerdo de confidencialidad, guía empresa-a-venta y presentación (portada y cierre).
- "Enlace Clínico" sigue solo dentro del nombre del sistema (Sistema Integral de Vigilancia y Enlace Clínico).
- Falta: homonimia en SEPREC, búsqueda en SENAPI (clases 9 y 42) y dominio (ferreirasalud.bo / sivec.bo) en nic.bo.

## 27/09/2026 · Firma de la paciente, los seis candados y presentación (v1.12.0, Paso 33)
- **Firma de la paciente sin papel** (Paso 33): con celular → código de 6 números por WhatsApp (mensaje listo desde el celular del centro; ella lo dice y el profesional lo escribe); sin celular → firma con el dedo o el mouse en la pantalla. Siempre el profesional firma como **testigo con su PIN**. Se guarda cómo firmó, los últimos 4 números del celular, la firma dibujada, la huella y el testigo; no se puede cambiar ni borrar. Sale impresa en el consentimiento informado y en el D1 (formato SIVEC). Botones: al guardar la toma ("✍ Firma de la paciente") y en Documentos (consentimiento y D1).
- **Los seis candados** dentro del sistema (⚙ Configuración y Administración): cada candado explicado con su estado real (usuario y lo que ve, mi PIN, huella de ejemplo, verificar un código, conexión HTTPS) y, para el administrador, el **registro de accesos** a historiales de otros centros (tabla historial_accesos, que ya existía sin pantalla).
- WhatsApp de soporte FICTICIO en web/config.js (59170000000) hasta que el autor compre el celular de soporte.
- Idea del autor: **cada establecimiento con su propio celular** para el WhatsApp de las pacientes y, después, la app **SIVEC Mi Salud**.
- Presentación: tablero de la red se cobra aparte (US$ 250; ya no figura como incluido — en su lugar "Firma sin papel"); soporte urgente en hasta 1 hora; Supabase Pro lo contrata el autor la semana que viene (se mantienen las "copias diarias"). Slides nuevos: **De 4 meses a menos de 3 semanas** (hoy 90–120 días para el resultado del PAP; con el SIVEC PAP en todos los niveles, 12 a 21 días), **El sistema trabaja con usted** (saludo con voz y avisos), **La paciente también firma**, **La fila del día en el hospital**, **Los candados dentro del sistema**; celular propio por centro en el plan.

## 28/09/2026 · Pregunta: campañas de PAP (un día, un lugar: PAP, VPH y colposcopia)
- Propuesta enviada al autor: **Modo Campaña** dentro del SIVEC (no un sistema aparte): crear la campaña (fecha, lugar, red, servicios, equipo), registro exprés, estaciones con la cola del día (registro → toma → colposcopia), etiquetas en serie y un lote de campaña, tablero en vivo por hora y estación, informe final, y cada mujer asignada a su centro de salud para que el resultado y el seguimiento no se pierdan. A definir con el autor.
- Firma de la paciente por WhatsApp: hoy es semiautomática (se abre WhatsApp con el mensaje listo y se toca Enviar, gratis). Automática de verdad = API oficial de WhatsApp Business (Meta), con empresa verificada (NIT), número propio y costo por mensaje; se deja para cuando esté la empresa.
- Respuestas del autor (28/09): la campaña la organizan los médicos responsables del programa de prevención de cada centro; la colposcopia de campaña es ver, IVAA, Schiller y evaluar (rara vez biopsia o crioterapia); en el lugar suele haber internet. Guía visual del Modo Campaña (propuesta, 4 páginas) en docs/guias/modo-campana/. A implementar cuando el autor apruebe.

## 28/09/2026 · Código SIVEC de los formularios, campaña aclarada y fecha local (v1.13.0, Paso 34)
- **Código SIVEC de los formularios** (Paso 34): en el paso 2 del registro, selector "🔢 Código SIVEC automático / 📒 Talonario (a mano)" (se recuerda por computadora). Automático: un mismo número para toda la toma, cambiando el prefijo: `PAP-SL-0926-014`, `D1-SL-0926-014`, `D8-SL-0926-014` (documento · sigla del establecimiento · mes y año de la toma · Nº de toma del mes). El contador está en la base de datos (nunca se repite entre computadoras); sin el Paso 34 cuenta con lo cargado. Sale en D1, D8, PAP, consentimiento e historia clínica. Sigla automática (San Luis → SL) o en Admin → Establecimientos → ✏️.
- **Campaña (aclaración del autor):** la colposcopia (IVAA/Schiller) se hace y se registra en el momento; el PAP y el VPH se toman en el momento pero van en lote al Instituto Oncológico, y el resultado vuelve a la ficha del centro de cada mujer (como ya funciona). Guía actualizada y slide "Campañas de PAP donde ninguna mujer se pierde" en la presentación (después de la fila del hospital).
- **Corregido:** la fecha de "hoy" se calculaba en UTC; en Bolivia, después de las 20:00 el sistema ya tomaba el día siguiente (cola del día, "Para hoy", resultados atrasados, fechas por defecto). Ahora usa la hora local; las fechas de las firmas también.

## 28/09/2026 · Presentación: campaña más clara, portada y ahorro por red, ciudad y país
- Portada: fila con los cinco lugares de trabajo (Centro de salud · Hospital · Laboratorio · Red · Campañas). La captura de la entrada sigue con 4 accesos hasta programar el Modo Campaña.
- Campaña en dos slides: (1) el flujo en dos bandas, "El mismo día, en el lugar" (registro · toma de PAP/VPH · colposcopia IVAA/Schiller con resultado en el momento) y "Después, como ya funciona" (lote al Oncológico · resultado firmado vuelve a la ficha del centro de cada mujer · seguimiento y WhatsApp); (2) las pantallas diseñadas (colposcopia y tablero en vivo).
- Slide 45 rehecho: "Lo que el SIVEC ahorra a las arcas públicas": Red Centro US$ 27 mil/año (Bs 189 mil), ciudad de Santa Cruz US$ 196 mil (Bs 1,4 millones), Bolivia US$ 3,6 millones (Bs 24,7 millones). Base: Bs 70 por toma (Bs 67 tratamientos de cáncer evitados netos + Bs 3 papel y tomas repetidas), 300 tomas/año por centro en la ciudad y 100 en el resto del país (3.410 centros). Horas devueltas: 900 (red), 6.400 = 3 enfermeras (ciudad), 117 mil = 55 enfermeras (país); una enfermera ≈ 2.100 h/año. El valor del tiempo ya no se suma al ahorro en dinero (no es dinero que sale de la caja).

## 28/09/2026 · Modo Campaña programado y quinta puerta (v1.14.0, Paso 35)
- **Quinta puerta** en la entrada: "Campaña de PAP" (el mismo usuario del centro entra directo a la campaña). Botón "Campaña" en el menú para quien tiene recepción, toma, colposcopia o jefe (o ninguna función).
- **Crear la campaña** (médico responsable del programa): nombre, fecha, lugar, meta y servicios (PAP, VPH, colposcopia).
- **📋 Registro:** carnet (si ya está en el SIVEC se completa solo y muestra su último PAP), nombre, nacimiento, celular, cobertura y **su centro de salud** (el que recibe el resultado); qué hace hoy (PAP, VPH, colposcopia) y consentimiento. Recibe turno y el código SIVEC de los formularios; botón para la firma de la paciente.
- **🧪 Toma:** la mujer aparece sola en la lista; "✔ Tomada" y, si también hace colposcopia, pasa sola a esa estación.
- **🩺 Colposcopia:** la ficha llega sola; IVAA, Schiller, unión E-C y conducta con botones; se firma con PIN (queda en colposcopias con ivaa, union_ec y campana_id). IVAA positivo: aviso.
- **📊 Tablero en vivo:** mujeres (y % de la meta), PAP, VPH, colposcopias, IVAA positivos, mujeres por hora, espera por estación, por centro de salud, muestras sin lote; botones Armar el lote, **Cerrar la campaña y enviar a cada centro** (las mujeres pasan a la ficha de su centro: allí llega el resultado del Oncológico) e Informe imprimible.
- Los turnos de campaña no se mezclan con la cola del día del establecimiento.
- Capturas (datos de prueba) en docs/guias/modo-campana/. Presentación: portada y "Paso 1 · Entrar" con la entrada de 5 puertas; slides de campaña con las pantallas reales.

## 28/09/2026 · Campaña en dos módulos (v1.14.1)
- Pedido del autor: la campaña tiene **dos módulos**. **📋 Recepción**: todos los datos de la paciente (y su centro de salud). **🩺 Consultorio**: la doctora hace todo en una sola atención: (1) la toma de PAP/VPH (se corrige si al final no se tomó), (2) la colposcopia con IVAA, Schiller y unión E-C (con casilla "se hizo"), (3) el **tratamiento en el momento**: crioterapia, cauterización, biopsia, metronidazol, clotrimazol, aseo vulvoperineal, orientación sexual (varios a la vez) y la conducta (esperar PAP/VPH, referir a colposcopia completa, control en 6 meses o en 1 año). Se firma con PIN solo si hubo colposcopia o tratamiento.
- Tablero: "tratadas en el momento" (con crioterapias y cauterizaciones); informe con la columna de tratadas. Presentación actualizada (dos módulos y pantallas nuevas).

## 28/09/2026 · Preços novos, acesso de demonstração (v1.15.0)
- **Preços** (pedido do autor): 1º nível sem colpo US$ 120 (Bs 835,20); com colpo e biópsia US$ 270 (Bs 1.879,20); 2º nível US$ 275 (Bs 1.914); 3º/4º e laboratórios US$ 521 (Bs 3.626,16); tablero da rede e administração US$ 250 (Bs 1.740). Implantação +US$ 25 em cada: 225 / 225 / 525 / 575 / 275. Red Centro + Oncológico: **US$ 2.026/mês, US$ 3.125 de implantação, primeiro ano US$ 27.437 (Bs 190.961,52)**. Cidade (65 centros + hospitais): ~US$ 157 mil/ano contra US$ 196 mil de economia → segue "se paga solo". Atualizados: slides precios, ejemplo, piloto e papel; `SIVEC-precios-mercado.md`; contrato modelo (tablero agora US$ 250).
- **Acesso de demonstração**: só na base DEMO (`sivec_meta.modo='demo'`), em qualquer porta usuário `demo` e senha `demo` entra com a conta ficticia da porta; barra inferior troca de porta ao vivo (Admin, Red, Centro, Hospital, Laboratorio, Campaña). Na base real não funciona. `docs/negocio/SIVEC-DEMO-pasos-23-35.sql` leva a base DEMO até o Paso 35.
- **Apresentação, 5 slides novos**: `testimonio` (depois de resultados; frase real de alguém de San Luis a completar, com permissão), `pasos` (semana 1 firma e contas → semanas 2–3 instalação e capacitação → meses 1–3 uso → mês 3 avaliação → mês 4 ampliar; pedido: data da firma e pessoa de enlace), `preguntas` (internet, dados, se a empresa fechar, segurança, equipamentos, SNIS), `demo` (roteiro ao vivo com demo/demo: Centro → Laboratorio → Hospital → Red → Campaña) e `comparacion` (4 números: 90–120 → 12–21 dias; 15 de 402 → 73%; 5 formulários → 1 registro; positivas: ninguém sabe → 15 com nome), antes do cierre.

## 28/09/2026 · Campanha testada ao vivo: ajustes (v1.16.0)
- **Mapa do colo dividido em dois anéis**: cada hora tem metade **interna** (perto do orifício / zona de transformação) e **externa** (periferia). A Historia clínica escreve "acetoblanco en 12 h interna y 3 h externa". Marcas antigas (hora inteira) continuam valendo; tocar uma metade de uma hora antiga deixa só a outra. Vale no centro, no hospital e na campanha.
- **Campanha usa a mesma colposcopia do sistema**: no consultório, "Registrar la colposcopia" abre o mesmo formulário (mapa, Schiller, ZT, impressão, lesões, derivação) com **IVAA e união E-C** e o bloco **Tratamiento en el momento** (crioterapia, cauterização, biópsia, metronidazol, clotrimazol, aseo, orientação), sempre visível. Reabrir modifica a mesma colposcopia sem perguntar. "Terminar la atención" fecha o turno e grava a toma.
- **Editar na campanha**: ✏ na recepção (com busca por nome ou CI) e na fila do consultório: corrige nome, CI, nascimento, celular, cobertura, centro de seguimento e o **pedido** (PAP, VPH, colposcopia) enquanto não foi atendida.
- **Voz**: ao salvar a colposcopia fala "Colposcopía realizada. Paciente: <nome>." (centro, campanha e hospital, junto com "Contrarreferencia enviada").
- **VPH positivo**: o genótipo (16, 18, 16 y 18, 16/18 + otros, otros de alto riesgo) passa a ser obrigatório ao salvar um VPH positivo; o tablero da campanha mostra negativos, positivo 16, positivo 18 e outros de alto risco.
- Sem SQL novo (usa as colunas do Paso 35).
