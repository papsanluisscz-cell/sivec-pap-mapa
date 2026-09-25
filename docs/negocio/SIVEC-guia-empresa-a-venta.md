# SIVEC — Guia completo: da titularidade e da empresa até a venda

> **Importante:** este guia organiza os passos e as perguntas certas. **Não substitui um advogado e um contador na Bolívia.**
> Os nomes de órgãos, leis e valores devem ser conferidos na hora de cada trâmite, porque mudam.
> Os termos oficiais aparecem em espanhol para você usar direto nos trâmites.

---

## 0. O caminho em 10 passos

| # | Quando | Passo |
|---|---|---|
| 1 | Semana 1 | Colocar todas as contas (código, banco de dados, domínio) no seu nome |
| 2 | Semana 1 | Consultar um advogado sobre o seu vínculo como servidor público |
| 3 | Semanas 2–4 | Registrar o SIVEC no SENAPI (direito de autor) e pedir a marca |
| 4 | Mês 1–2 | Abrir a empresa (S.R.L.), NIT, conta bancária e contador |
| 5 | Mês 2 | Contrato de licença: você (dono) → empresa (usa e vende) |
| 6 | Mês 2 | Formalizar o piloto do C.S. San Luis com um convênio escrito |
| 7 | Mês 2–4 | Fase 0 técnica: login real, permissões, backups, banco de DEMO |
| 8 | Mês 3 | Cadastro de fornecedor do Estado (RUPE / SICOES) |
| 9 | Mês 3–6 | Apresentações a município, SEDES e Ministério; proposta formal |
| 10 | Antes do POA seguinte | Entrar no orçamento do próximo ano do cliente |

---

## 1. Proteger o que já é seu (fazer já)

### 1.1 Contas no seu nome
- **Repositório do código:** o repositório atual se chama `papsanluisscz-cell`, um nome que parece do centro de saúde.
  - Confira quem é o dono da conta.
  - Crie uma conta ou organização sua (ex.: `sivec-bo`), com verificação em 2 passos, e **transfira o repositório**.
- **Banco de dados (Supabase), Google Drive, domínio, e-mail do sistema:** todos com o seu e-mail pessoal (depois, o da empresa) e pagos por você.
- **Senhas:** num gerenciador de senhas, com um contato de emergência de confiança.
- **Nunca** use a conta de e-mail ou o computador do Estado para o SIVEC.

### 1.2 Provas de autoria
- O histórico do código (cada mudança com data) já é uma prova. Mantenha e faça backup.
- Guarde os documentos de projeto (`docs/`), os desenhos, as datas e as conversas.
- **Opcional:** entregar num cartório (notaría de fe pública) uma cópia do código e dos documentos com data, lacrada.

### 1.3 Registro de direito de autor — SENAPI
- **Órgão:** SENAPI, área de *Derecho de Autor y Derechos Conexos*.
- **O que registrar:** o SIVEC como **programa de computador (software)**, com você como autor e titular.
- **O que costuma pedir:** formulário, descrição da obra, parte do código-fonte, manual ou descrição de funcionamento, documento de identidade e pagamento da taxa.
- O direito de autor nasce da criação; o registro serve como **prova pública e com data**.

### 1.4 Registro da marca — SENAPI
- **Primeiro:** fazer a busca de antecedentes (*búsqueda de antecedentes*). “SIVEC” existe em outros países e pode haver uma marca parecida.
- **Registrar:** o nome e o logo.
- **Classes sugeridas:** 9 (software), 42 (software como serviço, hospedagem) e 44 (serviços de saúde). O advogado confirma.

### 1.5 ⚠️ Servidor público: o ponto mais delicado
Se você trabalha como médico no sistema público:
- **Titularidade:** um programa criado **durante o trabalho, com recursos ou por encargo** do empregador pode ser reclamado por ele. Leve ao advogado:
  - o seu contrato;
  - quando e onde você desenvolveu o sistema;
  - quem pagou o quê.
- **Incompatibilidade:** existem proibições para servidores públicos **contratarem com o Estado**, sobretudo com a entidade onde trabalham. As saídas típicas são:
  - a empresa ser administrada por outra pessoa;
  - você não participar da contratação com a sua própria instituição;
  - ou deixar o cargo quando vier o contrato.
- **Faça isto antes de assinar qualquer venda.** É a coisa mais importante deste guia.

### 1.6 Código escrito com ajuda de IA
Parte do SIVEC foi escrita com ferramentas de IA. A proteção de obras geradas por IA ainda é uma área em discussão no mundo. O que te protege:
- o seu trabalho criativo (o que o sistema faz, o desenho, as decisões médicas);
- o histórico documentado;
- o registro como obra sua.

Comente com o advogado.

---

## 2. Abrir a empresa

### 2.1 Qual tipo
| Tipo | Vantagem | Desvantagem |
|---|---|---|
| **Empresa unipersonal** | simples e barata | você responde com o seu patrimônio pessoal; difícil entrar sócios |
| **S.R.L. (Sociedad de Responsabilidad Limitada)** ✅ recomendada | a responsabilidade fica limitada ao capital; permite sócios | um pouco mais de trâmite |
| S.A. | para grandes investimentos | cara e complexa no início |

### 2.2 Passos (conferir a ordem atual)
1. **Nome da empresa:** controle de homonímia no **SEPREC** (Servicio Plurinacional de Registro de Comercio).
2. **Escritura de constituição** num cartório, com o estatuto.
   - **Objeto:** desenvolvimento, licenciamento, hospedagem, implantação, capacitação e suporte de sistemas de informação em saúde.
3. **Matrícula de comércio** no SEPREC.
4. **NIT** no Servicio de Impuestos Nacionales (SIN).
   - Regime geral, com **faturamento eletrônico/em linha** (o Estado exige fatura).
   - **Impostos:** IVA 13%, IT 3%, IUE 25% sobre o lucro. O contador confirma as taxas vigentes.
5. **Licença de funcionamento** municipal.
6. **Conta bancária** da empresa.
7. **Registro como empregador** no Ministério de Trabalho, **seguro social de saúde** (Caja) e **aposentadoria** (Gestora) quando contratar pessoas.
8. **Contador** (mensal) e **advogado** (sob demanda).

### 2.3 Sócios
- Se entrar um sócio técnico ou investidor, a participação é na **empresa**, não no **SIVEC** (ver seção 3).
- Deixe por escrito o que cada sócio aporta, o que recebe e o que acontece se sair (*pacto de socios*).

---

## 3. Titularidade: “o SIVEC é meu e de mais ninguém”

### 3.1 A estrutura recomendada
```
VOCÊ (pessoa)  ── dono do SIVEC (código, marca, desenhos)
      │  contrato de LICENÇA exclusiva (renovável, com royalty)
      ▼
EMPRESA S.R.L. ── usa, vende, implanta e dá suporte
      │  contratos de serviço
      ▼
ESTADO (município / SEDES / Ministério) ── usa o serviço; os DADOS são dele e dos pacientes
```
- **Vantagem:** mesmo que a empresa tenha sócios, dívidas ou problemas, **o SIVEC continua seu**.
- **Royalty:** a empresa paga a você um percentual pelo uso (ex.: 5–10% do faturamento). Defina com o contador por causa dos impostos.
- **Alternativa:** aportar o SIVEC como capital da empresa. Aí ele passa a ser da empresa, o que é menos proteção para você.

### 3.2 Contratos com quem trabalhar no SIVEC
Todo programador, designer ou prestador assina:
- **cessão dos direitos patrimoniais** do que fizer para o SIVEC (a você ou à empresa, conforme a estrutura);
- **confidencialidade**, que inclui dados de pacientes;
- **não concorrência razoável**, se o advogado considerar válida.

### 3.3 Contratos com o Estado
- **Licença de uso, nunca cessão de direitos.** O Estado contrata o *serviço*; não compra o código.
- **Os dados** (pacientes, registros) **são do Estado e dos pacientes**. Isso dá confiança e não tira nada de você.
- **Saída do contrato:** entrega dos dados em formato padrão, sem entregar o código.
- **Se exigirem garantia de continuidade:** oferecer *depósito do código* (escrow) num cartório, que só se abre se a empresa deixar de existir.

### 3.4 Bibliotecas de terceiros
O SIVEC usa componentes de código aberto (mapas, PDF, banco de dados). As licenças (MIT, Apache, BSD etc.) permitem uso comercial, mas é preciso manter os avisos de autoria. Faça uma lista.

---

## 4. Autorizações, convênios e “concessões”

| Com quem | Para quê |
|---|---|
| **Ministério de Saúde / SEDES** | convênio ou autorização para operar nos estabelecimentos; validação dos formulários; integração com o SNIS e com o sistema de informação do Ministério |
| **Governo municipal** | é quem administra o 1º e o 2º nível no SUS: contrato de serviço |
| **SEGIP** | convênio para verificar identidade e huella (a biometria oficial exige convênio) |
| **AGETIC** | normas de governo eletrônico, interoperabilidade e preferência por software livre no Estado |
| **ADSIB** | domínio **.bo** (ex.: sivec.bo) e **assinatura digital** com validade legal |
| **Operadoras (Entel, Tigo, Viva)** | contrato de SMS em volume e internet para os centros |
| **Colégio Médico / comitê de ética** | se usar dados para pesquisa: aprovação ética e anonimização |

**Proteção de dados:** a Bolívia protege a intimidade na Constituição (ação de proteção de privacidade) e existe o sigilo da história clínica. Pratique o padrão internacional mesmo onde a lei é menos detalhada:
- consentimento;
- acesso mínimo necessário;
- registro de quem viu o quê;
- criptografia.

---

## 5. Equipe e cargos

| Fase | Pessoas | Cargos |
|---|---|---|
| **Piloto (1 rede)** | 5–7 | **Você:** direção médica e produto · **Líder técnico** (full-stack) · **1–2 programadores** · **1 suporte + capacitação** · contador e advogado externos |
| **Município / departamento** | ~15 | + 2 programadores · **qualidade (testes)** · **infraestrutura e segurança** · 3 suporte · 3 capacitadores · **chefe de implantação** · **relação com governo** · administração |
| **Nacional** | 40–60 | equipes por departamento (suporte + capacitação) · **dados e indicadores** · **responsável de segurança da informação** · jurídico · **sucesso do cliente** |

Custos de referência estão na planilha `SIVEC-modelo-financeiro.xlsx` (equipe central do piloto ≈ US$ 15.800/mês).

**O que só você deve fazer:** a visão médica, a relação com as autoridades e a decisão do que entra no sistema. A programação diária deve passar para a equipe.

---

## 6. Infraestrutura: onde fica o sistema e os dados

### 6.1 As 3 peças
1. **A página do sistema** (o arquivo HTML que você abre hoje do computador) → precisa de um endereço na internet, ex.: `app.sivec.bo`.
2. **O banco de dados** (Supabase, que você já usa) → onde ficam os pacientes e registros.
3. **Os arquivos** (PDF, fotos, raio-X, ecografias) → armazenamento de arquivos, separado e mais barato.

### 6.2 Por fase
| Fase | Onde | Custo aproximado |
|---|---|---|
| **Hoje / piloto** | Supabase **plano Pro** (região São Paulo) + página grátis (Cloudflare Pages, Netlify ou GitHub Pages) + domínio | US$ 25–150/mês |
| **Município / departamento** | Supabase Team ou servidor gerenciado; armazenamento de imagens à parte | US$ 500–2.000/mês |
| **Nacional** | o mesmo Supabase (é código aberto) **instalado num data center na Bolívia** (Entel, privado ou do Estado), com servidor de reserva | US$ 3.000–10.000/mês |

### 6.3 Quanto espaço a Bolívia inteira precisa (estimativa)
- **Dados clínicos (texto):** 1–3 TB em 5 anos. É pouco para um banco moderno.
- **Documentos PDF:** alguns TB.
- **Imagens (raio-X, eco):** é o que mais pesa, dezenas de TB. Guardar em armazenamento de arquivos com política de retenção (ex.: comprimir após 1 ano).

### 6.4 Obrigatório em qualquer fase
- Cópia de segurança diária **fora** do servidor principal e **teste de restauração** semanal.
- Registro de acessos (auditoria).
- Criptografia na transmissão (HTTPS) e no armazenamento.
- Plano de desastre: se o servidor cair, em quantas horas volta.

---

## 7. Internet e equipamentos por centro

| Nível | Internet | Equipamentos |
|---|---|---|
| **1º nível** | roteador 4G com plano de dados (5–10 Mbps) ou fibra se houver; o SIVEC funciona sem internet e sincroniza depois | 1 computador por consultório e recepção · leitor de huella · impressora · TV de turnos · 1 celular para brigadas |
| **2º nível** | fibra 50–100 Mbps + 4G de reserva | computadores por serviço · tablets nos carros de visita · leitores de código · servidor local de reserva (opcional) |
| **3º nível** | fibra 100+ Mbps + enlace de reserva | como o 2º nível, mais equipamentos de imagem conectados (DICOM) |

**Aplicativos:** nenhum de loja. Tudo abre no navegador e fica como atalho. Exceção futura provável: o app da ambulância, por causa do GPS contínuo.

---

## 8. Permissões (quem vê o quê)

| Perfil | Vê | Faz |
|---|---|---|
| Admin nacional / de rede | configuração, usuários, auditoria | cria centros, usuários, catálogos |
| Diretor do centro | o seu centro inteiro | aprova escalas, pedidos, relatórios |
| Médico | pacientes que atende + os do seu centro | consulta, receita, pedidos, referências |
| Residente | o seu serviço | valida e assina notas de internos |
| Interno | pacientes atribuídos | escreve notas “por validar” |
| Enfermagem | o seu serviço | sinais, medicação, curativos, vacinas |
| Recepção | dados de identificação e agenda | registrar, dar ficha, triagem administrativa |
| Farmácia / laboratório / imagem | pedidos do seu setor | dispensar, validar, laudar |
| Epidemiologia | fichas de notificação | investigar, fechar surtos |
| Gestor | **só números agregados** | vê painéis, não fichas individuais |
| Auditor | registro de acessos | somente leitura |

**Regras especiais:**
- **Notas confidenciais** (saúde mental, HIV, violência) só para quem trata o paciente.
- **Acesso de emergência** ao paciente de outro centro: permitido, mas justificado e registrado.
- **Tecnicamente:** login real + regras de acesso no próprio banco (*Row Level Security* no Supabase). É o trabalho da Fase 0.

---

## 9. Implantação num centro (checklist)

1. ☐ Convênio assinado e responsável local nomeado
2. ☐ Levantamento: pessoal, fluxos, equipamentos, internet
3. ☐ Compra e instalação de equipamentos e internet
4. ☐ Configuração: centro, serviços, usuários, perfis, catálogos
5. ☐ Capacitação por função (2–4 h cada) + 1 “referente SIVEC” por centro
6. ☐ Arranque acompanhado: capacitador no centro por 1–2 semanas
7. ☐ Papel em paralelo por 2–4 semanas
8. ☐ Pacientes registrados conforme chegam (sem digitar o arquivo antigo de uma vez)
9. ☐ Medir o uso: consultas no SIVEC em relação às consultas reais
10. ☐ Retirar o papel serviço por serviço
11. ☐ Reunião mensal com o diretor: indicadores e problemas

---

## 10. A venda

### 10.1 Quem decide e quem paga (SUS)
| Ator | Papel |
|---|---|
| **Governos municipais** | administram o 1º e o 2º nível: **clientes principais** para redes de centros |
| **SEDES (departamental)** | coordenam as redes e o 3º nível; podem padronizar o sistema no departamento |
| **Ministério de Saúde** | normas, SNIS, sistema nacional; aliado para validar e escalar |
| **Cooperação internacional** (OPS/OMS, BID, UNICEF, agências de cooperação) | pode **financiar pilotos** de saúde digital |

### 10.2 Como o Estado compra (normas de contratação pública; conferir valores vigentes)
| Modalidade | Faixa aproximada | Exemplo SIVEC |
|---|---|---|
| Contratação menor | até ~Bs 50.000 | demonstração ou piloto pequeno |
| ANPE (apoio nacional à produção e emprego) | ~Bs 50.001 a 1.000.000 | **piloto Red Centro (~Bs 490 mil/ano)** |
| Licitação pública | acima de ~Bs 1.000.000 | município, departamento |
| Contratação direta | casos especiais previstos em lei | exclusividade técnica, se aplicável |

**Documentos típicos para concorrer:**
- NIT e matrícula de comércio;
- RUPE (registro de fornecedores);
- proposta técnica e econômica;
- experiência (o piloto conta);
- **garantias bancárias** (seriedade da proposta e cumprimento do contrato), com porcentagens conforme a norma.

**Orçamento:** o Estado planeja no **POA** (plano operativo anual) do ano anterior. É preciso convencer **antes** de o orçamento ser montado (normalmente no meio do ano) para que o SIVEC entre no ano seguinte.

### 10.3 Sequência comercial
1. **Prova:** o piloto do C.S. San Luis com números reais.
2. **Aliado interno:** um diretor de rede ou autoridade que queira ser dono do sucesso.
3. **Apresentação executiva + demo ao vivo** (com banco de DEMO).
4. **Proposta formal:** alcance, metas, preço, cronograma.
5. **Piloto contratado de 6 meses** com metas acordadas.
6. **Relatório de impacto → ampliação** para município e departamento.

### 10.4 Preço (referência — ver planilha)
- 1º nível US$ 180/mês · 2º nível US$ 1.400 · 3º nível US$ 3.800, sem impostos, mais a implantação única.
- **Bolívia completa ≈ US$ 14,2 milhões por ano ≈ US$ 1,16 por habitante por ano.**
- O piloto sozinho não paga a equipe: negociar valor fixo ou vinculado à ampliação.

---

## 11. Riscos e como reduzi-los

| Risco | Como reduzir |
|---|---|
| Conflito como servidor público | advogado antes de tudo; estrutura com administrador separado |
| O Estado atrasa pagamentos (90+ dias) | capital de giro para 4 meses; faturamento mensal pontual |
| Mudança de autoridades | convênio com a instituição (não com a pessoa); resultados visíveis rapidamente |
| “O Ministério já tem sistema” | posicionar como **complemento integrado**, não como substituto: SIVEC envia ao sistema nacional |
| Tudo depende de você | documentar, contratar um líder técnico cedo, manuais |
| Vazamento de dados | segurança desde a Fase 0, auditoria externa anual, seguro |
| Internet fraca | modo sem internet programado de verdade antes de escalar |

---

## 12. Cronograma sugerido de 12 meses

| Mês | Jurídico e empresa | Técnico | Comercial |
|---|---|---|---|
| 1 | contas no seu nome · advogado · SENAPI | Supabase Pro · domínio · página publicada | levantar números do piloto |
| 2 | S.R.L. · NIT · licença SIVEC→empresa | login e permissões · backups | apresentações a diretores de rede |
| 3 | RUPE · contratos de equipe | banco de DEMO · modo sem internet (início) | apresentação ao município / SEDES |
| 4–6 | convênio de piloto | recepção, agenda, consulta (Fase 1) | proposta formal · piloto contratado |
| 7–9 | garantias · seguro | referências, laboratório, farmácia | acompanhamento de metas |
| 10–12 | revisão de contratos | hospital (Fase 2) | relatório de impacto · ampliação no POA seguinte |
