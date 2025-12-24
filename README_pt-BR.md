# Ambiente de Desenvolvimento Docker para CodeIgniter 4

Este repositório fornece uma configuração Docker completa para desenvolver aplicações CodeIgniter 4. O ambiente inclui PHP, Nginx, MySQL, Redis, MailHog e Redis Commander.

## Funcionalidades

*   **PHP 8.2-FPM**
*   **Nginx** como servidor web.
*   **MySQL 8.0** como banco de dados.
*   **Redis** para cache ou sessões.
*   **MailHog** para capturar e visualizar e-mails enviados pela aplicação.
*   **Redis Commander** para visualizar e gerenciar dados no Redis.
*   **Script de Configuração (`setup.sh`)** para criar um novo projeto CodeIgniter 4 e configurar automaticamente os arquivos Docker.

## Pré-requisitos

Antes de começar, certifique-se de ter os seguintes softwares instalados em sua máquina:

*   Docker
*   Docker Compose
*   Composer (necessário para executar o script `setup.sh`)
*   Composer (necessário para executar o script `setup.sh`)

## Como Usar

### 1. Clonar o Repositório (Opcional)

Se você ainda não tem este setup localmente:
```bash
git clone https://github.com/joserafael/codeigniter4-docker.git
cd codeigniter4-docker
```

### 2. Configurar um Novo Projeto CodeIgniter

Este repositório inclui um script `setup.sh` para facilitar a criação de um novo projeto CodeIgniter 4 e a configuração dos arquivos Docker.

Execute o script e siga as instruções:
```bash
chmod +x setup.sh
./setup.sh
```
O script irá:
1.  Solicitar um nome para o seu novo projeto CodeIgniter (ex: `meu_app_ci`).
2.  Criar uma nova pasta com o nome fornecido e instalar o CodeIgniter 4 nela usando `composer create-project`.
3.  Atualizar automaticamente os arquivos `docker-compose.yml` e `docker/nginx/default.conf` para usar o nome do projeto que você forneceu.

**Nota:** O script assume que os arquivos `docker-compose.yml` e `docker/nginx/default.conf` inicialmente usam `codeigniter_project` como placeholder para o nome do diretório do projeto.

### 3. Configurar o Arquivo `.env` do CodeIgniter

Após o script `setup.sh` criar seu projeto (ex: na pasta `meu_app_ci`), navegue até essa pasta:
```bash
cd nome_do_seu_projeto # Ex: cd meu_app_ci
```
Copie o arquivo `env` para `.env` e configure as variáveis de ambiente da sua aplicação, especialmente as de banco de dados se forem diferentes dos padrões definidos no `docker-compose.yml`.
```bash
cp env .env
```
As configurações de banco de dados, Redis e e-mail no `docker-compose.yml` (seção `environment` do serviço `app`) são passadas para o CodeIgniter e geralmente sobrescrevem os valores do `.env`.

### 4. Iniciar o Ambiente Docker

Volte para a raiz do repositório do Docker (onde está o `docker-compose.yml`) e execute:
```bash
docker-compose up -d --build
```
Este comando irá construir as imagens (na primeira vez ou se o `Dockerfile.php` mudar) e iniciar todos os serviços em segundo plano.

### 5. Acessar os Serviços

*   **Sua Aplicação CodeIgniter**: `http://localhost:8080` (ou a porta configurada em `NGINX_HOST_PORT` no `docker-compose.yml`).
*   **MailHog (Interface Web para E-mails)**: `http://localhost:8025`
*   **Redis Commander**: `http://localhost:8081`
*   **MySQL**:
    *   Host (para clientes externos como DBeaver, TablePlus): `127.0.0.1`
    *   Porta: `33061` (ou a porta configurada em `MYSQL_HOST_PORT`)
    *   Usuário: `user` (ou o valor de `MYSQL_USER`)
    *   Senha: `password` (o valor de `MYSQL_PASSWORD`)
    *   Banco de Dados: `ci4_db` (o valor de `MYSQL_DATABASE`)
*   **Redis**:
    *   Host (para clientes externos): `127.0.0.1`
    *   Porta: `63791` (ou a porta configurada em `REDIS_HOST_PORT`)

### 6. Executar Comandos Composer e Spark

Para executar comandos Composer (como `install`, `update`, `require`) ou comandos `php spark` do CodeIgniter, você deve fazê-lo dentro do contêiner `app`:

```bash
# Exemplo para instalar dependências do Composer
docker-compose exec app composer install

# Exemplo para executar migrações do CodeIgniter
docker-compose exec app php spark migrate

# Exemplo para instalar um novo pacote
docker-compose exec app composer require vendor/pacote
```
O diretório de trabalho padrão dentro do contêiner `app` já é a raiz do seu projeto CodeIgniter.

### 7. Parar o Ambiente Docker

Para parar todos os contêineres:
```bash
docker-compose down
```
Se você quiser remover os volumes (e perder os dados do MySQL e Redis):
```bash
docker-compose down -v
```

## Estrutura do Projeto

*   `Dockerfile.php`: Define a imagem Docker para a aplicação PHP/CodeIgniter.
*   `docker-compose.yml`: Orquestra todos os serviços Docker.
*   `docker/`: Contém configurações específicas dos serviços Docker (ex: Nginx).
*   `setup.sh`: Script para inicializar um novo projeto CodeIgniter.
*   `.gitignore`: Arquivo para ignorar arquivos e pastas do controle de versão.
*   `NOME_DO_SEU_PROJETO/`: Pasta criada pelo `setup.sh` contendo sua aplicação CodeIgniter.

## Contribuindo

Sinta-se à vontade para abrir issues ou pull requests para melhorias.
