# LabGest

Sistema de gestão de laboratórios de informática da UFPel — abertura e atendimento de chamados técnicos, e agendamento/retirada de chaves de laboratório por professores.

Projeto acadêmico (disciplina de Projeto de Banco de Dados).

## Stack

- **PHP 8.3** puro (sem framework), usando `PDO` para acesso ao banco
- **PostgreSQL 16**
- HTML + CSS puro no front-end (sem JS além de um `confirm()` nativo)

Não há gerenciador de dependências (Composer): o projeto não usa nenhuma lib externa.

## Estrutura de pastas

```
public/     páginas acessadas diretamente pelo navegador (é o DocumentRoot)
includes/   lógica compartilhada: conexão com o banco, carregamento do .env, CSRF
sql/        schema + dados de exemplo do banco (dump único e versionado)
docs/       PDFs da apresentação/relatório da disciplina
```

`includes/` e `sql/` ficam **fora** de `public/` de propósito: em um deploy real (Apache/Nginx apontando para `public/`), esses arquivos não são acessíveis via URL.

## Perfis de usuário

O sistema tem três perfis (`tipo_usuario` na tabela `usuario`), definidos no banco — não é possível escolher o perfil na tela de login:

| Perfil | Pode |
|---|---|
| `aluno` | Abrir e ver seus próprios chamados |
| `professor` | Abrir/ver chamados, agendar laboratório, ver suas chaves retiradas e registrar a devolução |
| `tecnico` | Ver e atualizar status dos chamados atribuídos; cadastrar laboratórios, equipamentos, turmas e usuários; associar alunos e turmas a laboratórios; e acessar as consultas gerais |

## Banco de dados

Schema principal (`sql/laboratorio_ufpel.sql`): `usuario`, `professor`, `aluno`, `tecnico_ti`, `laboratorio`, `equipamentos`, `solicitacao`, `agenda_labs_chave`, `turma`, `ministra`, `pertence`, `utiliza`.

O arquivo já inclui dados de exemplo (20 usuários — 5 professores, 5 técnicos, 10 alunos) com senhas em hash, prontos para teste local.

## Como rodar localmente

### 1. Pré-requisitos

- PHP >= 8.1 com extensão `pdo_pgsql`
- PostgreSQL rodando localmente

### 2. Banco de dados

```bash
sudo systemctl start postgresql
createdb -U postgres laboratorio_ufpel
psql -U postgres -d laboratorio_ufpel -f sql/laboratorio_ufpel.sql
```

### 3. Configuração

Copie o template e ajuste as credenciais do seu Postgres local:

```bash
cp .env.example .env
```

`.env` **não é versionado** (está no `.gitignore`) — cada ambiente (sua máquina, a do seu colega, produção) tem o seu.

### 4. Subir o servidor

```bash
php -S localhost:8000 -t public
```

Acesse `http://localhost:8000/login.php`.

### Usuários de teste

Senha é a mesma para todos do mesmo perfil (dados de exemplo do seed):

| Perfil | E-mail (exemplo) | Senha |
|---|---|---|
| Professor | carlos.henrique@email.com | `123456` |
| Técnico | camila.martins@email.com | `234567` |
| Aluno | gabriel.santos@email.com | `345678` |

## Decisões de segurança

Pontos que valem registro para quem for mexer no código depois:

- **Senhas em hash**: armazenadas com `password_hash()` (bcrypt) e verificadas com `password_verify()`. Nunca comparar senha em texto puro no SQL.
- **CSRF**: todo formulário POST carrega um token de sessão (`includes/csrf.php`), validado antes de qualquer escrita no banco. Ao criar um novo formulário POST, sempre incluir `<?= csrf_input() ?>` e chamar `csrf_verificar()` no script que o processa.
- **Perfil de acesso vem do banco**, nunca do formulário — evita que o usuário escolha se é "aluno" ou "técnico" na tela de login.
- **Prepared statements** (`PDO` com parâmetros nomeados) em todas as queries — nunca concatenar valores de `$_POST`/`$_GET` direto no SQL.
- **Credenciais fora do código**: `conexao.php` lê host/usuário/senha do `.env` via `includes/env.php`. Nunca commitar `.env`.
- Erros de conexão com o banco vão para o `error_log` do PHP, não para a tela — evita vazar detalhes internos (versão do driver, estrutura de erro, etc.) para o usuário final.

## Limitações conhecidas

- Sem testes automatizados.
- Sem paginação nas listagens (`meus_chamados.php`, `chamados_tecnico.php`) — ok para o volume de dados de um projeto acadêmico, mas não escala.
