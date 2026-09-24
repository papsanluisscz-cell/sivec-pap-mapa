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
