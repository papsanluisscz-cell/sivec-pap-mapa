# SIVEC — onde fica, como funciona, como se instala e como o governo paga

> Resumo para o autor (26/09/2026). Pontos que dependem de lei ou de contrato estão marcados **confirmar com o advogado/contador**.

## 1. Onde o sistema fica
O SIVEC é um **site**: ninguém instala programa, só abre um endereço no navegador.

| Parte | Onde fica | Hoje | Para a ampliação |
|---|---|---|---|
| **As telas** (o que as pessoas veem) | Hospedagem de sites | Arquivo `SIVEC-PAP-sistema.html` aberto no computador + "código de conexão" | Publicar num endereço próprio, ex.: **sivec.bo**, em Vercel ou Cloudflare Pages (grátis a US$ 20/mês) |
| **Os dados** (pacientes, lotes, laudos) | Banco PostgreSQL no **Supabase** (nuvem) | Projeto Supabase já em uso em San Luis | Supabase **Pro** (US$ 25 + computação) com a região **São Paulo**, a mais perto da Bolívia |
| **Login e senhas** | Supabase Auth | Já funciona | Igual |
| **Cópias de segurança** | Supabase (diárias) + cópia externa | Diárias do Supabase | + cópia semanal automática em outro provedor (Backblaze/S3) |

**Dado do governo em servidor fora da Bolívia:** algumas entidades públicas podem exigir que os dados de saúde fiquem no país. O Supabase é software livre e **pode ser instalado num servidor na Bolívia** (datacenter local ou do próprio governo). É mais caro e dá mais trabalho, mas é possível. **Confirmar com o advogado e a AGETIC antes do contrato.** O contrato deve dizer que **os dados são da entidade**, não da empresa.

## 2. Quanto custa manter (só a parte técnica)
| Item | Red Centro | Cidade de Santa Cruz | Bolívia |
|---|---|---|---|
| Banco de dados (Supabase) | US$ 40 | US$ 135 | US$ 2.500 |
| Hospedagem das telas | US$ 0–20 | US$ 20 | US$ 40 |
| Domínio | US$ 3 | US$ 3 | US$ 3 |
| Backup externo | US$ 5 | US$ 20 | US$ 200 |
| Monitoramento (erros e queda) | US$ 0 | US$ 51 | US$ 400 |
| WhatsApp para pacientes | US$ 30 | US$ 150 | US$ 3.000 |
| **Técnico por mês** | **~US$ 100** | **~US$ 380** | **~US$ 6.100** |

O resto dos custos da planilha é gente, transporte, escritório e segurança.

## 3. Como funciona e se comporta
- A pessoa abre **sivec.bo** no Chrome ou no Edge, entra com seu correio e senha e vê só o que é da sua função.
- Cada clique vai pela internet (HTTPS) até o banco. **O banco decide o que cada um pode ler** (as regras do Paso 22): mesmo quem descobrir o endereço não vê nada sem usuário.
- **Atualizar é publicar:** quando eu corrijo ou melhoro algo, publico uma versão nova e todos a recebem ao recarregar. Não se reinstala nada.
- **Precisa de internet.** Com internet fraca funciona, mas mais devagar. **Sem internet não funciona.** Para centros rurais sem conexão, o "modo sem internet" é uma etapa futura. Na cidade de Santa Cruz não é problema.
- **Aguenta crescer:** o mesmo banco atende uma rede ou o país. Só se aumenta a potência (o plano) no Supabase.

## 4. Como se instala num centro de saúde ou numa rede
**Não há instalação de programa.** Por centro, em uma visita de 2 a 4 horas:
1. **Computador:** qualquer PC ou notebook com Windows 10+, Chrome atualizado e internet (5 Mbps já basta). Pode ser o que o centro já tem.
2. **Atalho:** abrir sivec.bo e criar o ícone na área de trabalho (ou "Instalar app" no Chrome, que ainda falta ativar).
3. **Usuários:** o administrador cria no Admin as contas de cada profissional (minutos). Cada um troca a senha provisória no primeiro acesso.
4. **Equipamentos:** conectar o leitor de código de barras (USB, sem driver) e a impressora de etiquetas (driver da marca). Testar uma etiqueta.
5. **Capacitação:** registro, consulta, D1, lote e seguimento, com casos de teste no modo apresentação.
6. **Rede e gestor:** só precisam de login; o tablero e o mapa abrem no navegador (inclusive no celular).

## 5. Desde quando funciona
- **No mesmo dia da visita.** A conta é criada, a pessoa capacitada e já registra a próxima paciente.
- **1ª semana:** o implantador acompanha (presencial ou por WhatsApp) e corrige dúvidas.
- **Dados antigos:** os livros e planilhas podem ser carregados depois, como fizemos em San Luis. Não impedem começar.
- **Red Centro inteira:** 9 centros + hospital, com 1 implantador, em ~3 a 4 semanas; 3 meses é folgado.

## 6. Como o governo paga
Na Bolívia a compra pública segue as **Normas Básicas do Sistema de Administração de Bens e Serviços (DS 0181)**. **Confirmar os detalhes com o advogado.**

1. **Orçamento:** a entidade (Município ou Governação/SEDES) precisa ter a despesa no seu **POA e orçamento**. O orçamento do ano seguinte se prepara **agora (setembro–outubro)**. Se quer contrato em 2027, a conversa tem que ser já.
2. **Modalidade, pelo valor anual:**
   - até Bs 50.000: **contratação menor** (mais simples, rápida);
   - Bs 50.001 a 1.000.000: **ANPE** (a cidade de Santa Cruz, ~Bs 1 milhão/ano, fica no limite);
   - acima de Bs 1.000.000: **licitação pública**.
3. **Publicação no SICOES:** a entidade publica, você apresenta a proposta. Para isso a empresa precisa estar registrada: **NIT, SEPREC, conta bancária e RUPE**.
4. **Contrato:** normalmente **por gestão fiscal** (janeiro a dezembro). Vários anos exigem aprovação de contrato plurianual. **Valores em bolivianos**: transformar os preços de US$ para Bs na proposta.
5. **Garantias:** podem pedir garantia de seriedade da proposta e de cumprimento do contrato (boleta bancária) ou reter uma porcentagem de cada pagamento. **O contador confirma a porcentagem.**
6. **Pagamento mensal:**
   - a empresa presta o serviço do mês e emite a **fatura** (com NIT);
   - o responsável da entidade faz o **informe de conformidade**;
   - a tesouraria paga por **transferência pelo SIGEP** para a conta da empresa;
   - na prática o pagamento **demora de 30 a 60 dias ou mais** depois da fatura, então é preciso ter caixa para 2 a 3 meses de salários.
7. **Implantação:** pode ser um item separado, pago por marcos (ex.: "Red Centro em funcionamento"), ou diluída nas mensalidades.

## 7. O que falta fazer no sistema antes de ampliar
1. **Publicar o SIVEC como site** (sivec.bo), sem arquivo nem código de conexão: 1 a 2 dias.
2. Ativar o **"Instalar app"** no Chrome (ícone próprio na área de trabalho e no celular).
3. Colocar o projeto do Supabase no **plano Pro** (backups de 7 dias) e programar a cópia externa semanal.
4. Monitoramento de erros e de queda.
