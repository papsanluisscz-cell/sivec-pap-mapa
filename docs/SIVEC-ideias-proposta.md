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
