# AGENTS.md

## Objetivo

Este arquivo define o contexto, padrões e regras para agentes de IA
(Codex, Claude, ChatGPT, etc.) trabalharem neste repositório com consistência,
segurança e previsibilidade.

O objetivo não é documentar tudo em excesso, mas deixar claro o suficiente para
evitar decisões erradas, arquivos fora do padrão e commits ruins.

---

## Contexto do projeto

Este projeto é um sistema de agendamento para a barbearia **Sr. Reis**.

No MVP atual, o sistema é exclusivo para o Sr. Reis e será organizado
principalmente por **unidades**. Não tratar como SaaS multi-tenant genérico
neste momento.

A aplicação terá:

- Web/Admin interno com Next.js
- App mobile do cliente com React Native/Expo
- Backend, Auth, banco e RLS com Supabase
- TypeScript em todo o projeto

O fluxo central do MVP é:

> cliente agenda pelo app → loja/unidade vê no painel → funcionário atende →
> atendimento é finalizado.

---

## Superfícies do sistema

### Web/Admin interno

Usado por Admin, Unidade/PDV e Funcionário.

Perfis principais:

- **Admin**
  - gerencia unidades
  - gerencia serviços
  - gerencia funcionários
  - visualiza agenda geral
  - acompanha operação

- **Unidade/PDV**
  - representa uma unidade específica
  - fica logada no computador da loja
  - vê agenda da própria unidade
  - cria agendamentos manuais
  - faz check-in
  - altera status de atendimento

- **Funcionário**
  - vê a própria agenda
  - acompanha atendimentos
  - pode iniciar/finalizar atendimento, conforme permissão

### App mobile

Usado pelo Cliente.

Fluxos principais:

- cadastro/login
- escolher unidade
- escolher serviço
- escolher funcionário
- escolher data e horário
- confirmar agendamento
- ver próximos agendamentos
- cancelar agendamento

---

## Stack

- Web: Next.js
- Mobile: Expo / React Native
- Banco/Auth: Supabase
- Linguagem: TypeScript
- Validação: Zod
- UI Web: Tailwind/shadcn quando aplicável
- Formulários: React Hook Form quando aplicável

---

## Estrutura esperada do monorepo

A estrutura pode evoluir, mas a direção esperada é:

```txt
apps/
  web/
  mobile/

packages/
  shared/
  database/
  validations/
  types/
```

Regras gerais:

- `apps/web` contém a aplicação Next.js.
- `apps/mobile` contém a aplicação Expo.
- `packages/shared` contém código compartilhável entre web e mobile.
- `packages/types` contém tipos globais ou gerados.
- `packages/validations` contém schemas Zod compartilháveis.
- `packages/database` pode conter tipos, helpers ou arquivos relacionados ao banco.

Não compartilhar UI entre web e mobile no começo, a menos que exista um motivo muito claro.

---

## Arquitetura backend

Para a aplicação web, seguir arquitetura em camadas.

Fluxo padrão para casos simples:

```txt
Action -> Service -> Repo
```

Fluxo para casos complexos:

```txt
Action -> Use-case -> Service(s) -> Repo(s)
```

### Quando usar Use-case

Usar `use-case` apenas quando existir orquestração real, por exemplo:

- múltiplas operações coordenadas
- rollback manual
- chamada de mais de um service
- validações com ramificações importantes
- efeitos colaterais
- auditoria
- criação de usuário envolvendo Auth + tabela pública

Não criar use-case para CRUD simples sem necessidade.

---

## Responsabilidade das camadas

### Action

- Recebe input vindo da UI.
- Valida dados com Zod.
- Chama Service ou Use-case.
- Não acessa Supabase diretamente.
- Não contém regra de negócio complexa.
- Retorna DTO seguro para o cliente.

### Use-case

- Orquestra fluxos complexos.
- Pode chamar múltiplos services.
- Não acessa Supabase diretamente.
- Deve deixar claro o fluxo principal e os cenários de erro.
- Deve retornar resposta padronizada.

### Service

- Centraliza regra de negócio.
- Chama repositories.
- Trata erros esperados.
- Não deve depender de outro service sem necessidade clara.

### Repo

- Camada fina de acesso a dados.
- Executa queries no Supabase.
- Não contém regra de negócio.
- Não valida input de usuário.
- Não faz orquestração.

---

## Estrutura recomendada por módulo no web

Dentro de `apps/web`, preferir organização feature-first:

```txt
src/
  app/
  modules/
    auth/
    branches/
    services/
    employees/
    appointments/
    dashboard/
  shared/
  lib/
```

Estrutura server por módulo:

```txt
src/modules/<module>/server/repos/
src/modules/<module>/server/services/
src/modules/<module>/server/slices/<slice>/actions/
src/modules/<module>/server/slices/<slice>/use-cases/
```

Estrutura shared por módulo:

```txt
src/modules/<module>/shared/
src/modules/<module>/shared/ui/
```

Componentes globais reutilizáveis:

```txt
src/shared/components/
```

Primitives do shadcn/ui:

```txt
src/shared/components/ui/
```

---

## Next.js App Router

- Manter `src/app/` apenas como camada de rotas.
- Não colocar regra de negócio dentro de `page.tsx`.
- Não criar services, repos, helpers ou validações dentro de `src/app/`.
- `page.tsx` e `layout.tsx` devem ser Server Components por padrão.
- Usar `"use client"` apenas quando necessário.
- Quando precisar de client component, criar componente separado e importar na page.
- Código dentro de `server/` nunca deve ser importado por componentes client.

---

## Supabase

Regras obrigatórias:

- Nunca expor `service_role` no client.
- Nunca usar cliente admin no mobile ou em componentes client.
- Operações sensíveis devem acontecer no server.
- Repositories que precisam de privilégios administrativos devem ser separados.
- Sempre manter types do Supabase atualizados após mudanças de schema.
- RLS é obrigatória para proteger dados reais.
- O frontend pode esconder botão/menu, mas a segurança real deve estar no banco/server.

---

## Regras de autenticação e usuários

O Supabase Auth é a fonte de autenticação.

A tabela pública de perfil deve guardar dados da aplicação, como:

- nome
- telefone
- role/tipo de usuário
- dados complementares

Roles previstas:

```txt
admin
unit
employee
customer
```

Observação:

- `unit` representa a conta logável da unidade/PDV.
- `employee` representa funcionário logável.
- `customer` representa cliente final.
- Funcionário deve ter `user_id`.
- A conta Unidade/PDV representa uma unidade específica.

---

## Regras de domínio importantes

- A unidade é a principal divisão operacional do MVP.
- Serviços podem ter preço diferente por unidade.
- Agendamentos devem guardar snapshot de informações importantes, como:
  - nome do serviço
  - preço no momento do agendamento
  - duração
  - unidade
  - funcionário
  - data/hora
- Funcionário pode trabalhar temporariamente em outra unidade.
- Evitar modelagem SaaS genérica antes da hora.
- Não adicionar `organization_id` no MVP sem decisão explícita.

---

## Naming

### Arquivos

Usar kebab-case.

Exemplos:

```txt
sign-in.action.ts
create-appointment.use-case.ts
appointments.service.ts
appointments.repo.ts
appointments.admin.repo.ts
```

### Funções

Usar camelCase com sufixo da camada quando fizer sentido:

```ts
signInAction
createAppointmentUseCase
createAppointmentService
createAppointmentRepo
```

### Componentes React

Preferir:

```tsx
const ComponentName = () => {
  return <div />
}
```

Exceção: componentes gerados pelo shadcn/ui podem manter o padrão do gerador.

---

## Padrões gerais de código

- Usar TypeScript.
- Evitar `any`.
- Evitar `@ts-ignore`.
- Preferir `async/await` a `.then()`.
- Usar imports absolutos quando o projeto tiver alias configurado.
- Não criar barrel files (`index.ts`) para re-exportar tudo.
- Não misturar lógica de domínio com UI.
- Não commitar código comentado sem motivo claro.
- Não silenciar lint sem justificativa.
- Não criar abstrações genéricas cedo demais.

---

## Comandos do projeto

Os comandos reais devem ser conferidos no `package.json` da raiz e de cada app.

Preferir scripts do monorepo quando existirem.

Comandos esperados:

```bash
pnpm install
pnpm dev
pnpm build
pnpm lint
pnpm format
pnpm typecheck
```

Para app específico, usar filtros se o workspace estiver configurado:

```bash
pnpm --filter web dev
pnpm --filter mobile start
```

Antes de finalizar uma tarefa, rodar quando disponível:

```bash
pnpm format
pnpm lint
pnpm typecheck
```

Se algum comando não existir, não inventar. Verificar o `package.json` e usar o script correto.

---

## Git / Commits

Mensagens de commit devem ser sempre em inglês.

Usar Conventional Commits:

```txt
feat:
fix:
refactor:
chore:
test:
docs:
style:
```

Regras:

- Título em inglês.
- Título curto, semântico e com até 72 caracteres.
- Não usar ponto final no título.
- Não usar mensagens genéricas como:
  - `update`
  - `fix stuff`
  - `changes`
  - `wip`
- Não incluir `Co-Authored-By`.
- Não commitar segredos.
- Não dar push direto para `main` ou `master`.
- Preferir commits pequenos e coerentes.

Exemplos bons:

```txt
feat: add customer sign-up flow
fix: prevent duplicate appointments
refactor: split appointment creation use case
chore: update Supabase generated types
docs: add project agent guidelines
```

Para mudanças maiores, usar body com tópicos:

```txt
feat: add appointment creation flow

- Add appointment creation action and use case
- Validate customer, unit, service and employee availability
- Store appointment snapshots for service price and duration
- Update generated Supabase types
```

---

## Segurança

- Nunca commitar `.env`.
- Nunca commitar tokens, senhas ou chaves privadas.
- Se adicionar variável de ambiente, atualizar `.env.example`.
- Não rodar comandos destrutivos em produção.
- Não apagar migrations antigas sem orientação explícita.
- Não resetar banco remoto sem confirmação humana.
- Não expor dados sensíveis no client.
- Não usar service role fora do server.

---

## Banco e migrations

- Toda mudança estrutural no banco deve virar migration.
- Migrations devem ter nomes semânticos.
- Evitar migrations gigantes quando fizer sentido separar por domínio.
- Após alterar schema, gerar tipos novamente.
- RLS deve ser considerada parte da feature, não etapa opcional.
- Seeds devem ser usados para dados iniciais do Sr. Reis quando fizer sentido.

Exemplos de nomes de migration:

```txt
create_profiles_table.sql
create_units_table.sql
create_services_table.sql
create_employees_table.sql
create_appointments_table.sql
add_appointment_snapshot_fields.sql
```

---

## Como agir quando houver dúvida

Se a regra de negócio estiver ambígua:

1. Não inventar regra crítica.
2. Procurar contexto nos documentos do projeto.
3. Fazer a menor implementação segura.
4. Deixar comentário ou TODO apenas quando realmente necessário.
5. Perguntar antes de tomar decisão que afete banco, segurança ou arquitetura.

Para tarefas simples, seguir o padrão existente no código.

Para tarefas complexas, priorizar clareza, consistência e segurança.
