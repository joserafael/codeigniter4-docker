#!/bin/bash

# Script para configurar um novo projeto CodeIgniter 4 com Docker.

# Caminhos para os arquivos de configuração
DOCKER_COMPOSE_FILE="docker-compose.yml"
NGINX_CONF_FILE="docker/nginx/default.conf"

# Placeholder atual nos arquivos de configuração que será substituído.
# Certifique-se de que seus arquivos modelo usem este placeholder.
PLACEHOLDER_PROJECT_NAME="codeigniter_project"

# --- Solicitar nome do projeto ao usuário ---
read -p "Digite o nome para o seu projeto CodeIgniter (ex: meu_app_ci): " PROJECT_NAME

# Validar que o nome do projeto não esteja vazio
if [ -z "$PROJECT_NAME" ]; then
  echo "Erro: O nome do projeto não pode estar vazio. Abortando."
  exit 1
fi

# Validar caracteres permitidos para o nome do diretório (simplificado)
if [[ "$PROJECT_NAME" =~ [^a-zA-Z0-9_-] ]]; then
  echo "Erro: O nome do projeto só pode conter letras, números, underscores (_) e hífens (-). Abortando."
  exit 1
fi

# Verificar se o diretório do projeto já existe
if [ -d "$PROJECT_NAME" ]; then
  echo "Erro: O diretório '$PROJECT_NAME' já existe. Por favor, escolha outro nome ou remova o diretório existente. Abortando."
  exit 1
fi

# --- Criar projeto CodeIgniter ---
echo "Criando o projeto CodeIgniter '$PROJECT_NAME'..."
if ! composer create-project codeigniter4/appstarter "$PROJECT_NAME" --prefer-dist --no-interaction; then
  echo "Erro: Falha ao criar o projeto CodeIgniter com o Composer. Abortando."
  # Tenta limpar a pasta criada se o Composer falhar
  if [ -d "$PROJECT_NAME" ]; then
    rm -rf "$PROJECT_NAME"
  fi
  exit 1
fi
echo "Projeto CodeIgniter '$PROJECT_NAME' criado com sucesso na pasta './$PROJECT_NAME'."

echo "Atualizando arquivos de configuração para usar '$PROJECT_NAME'..."

# --- Actualizar docker-compose.yml ---
# Usa-se # como delimitador para o sed para evitar conflitos com as barras / nos caminhos.
# Cria-se um arquivo .bak como cópia de segurança.
if sed -i.bak \
    -e "s#\./${PLACEHOLDER_PROJECT_NAME}:/var/www/html/${PLACEHOLDER_PROJECT_NAME}#\./${PROJECT_NAME}:/var/www/html/${PROJECT_NAME}#g" \
    -e "s#working_dir: /var/www/html/${PLACEHOLDER_PROJECT_NAME}#working_dir: /var/www/html/${PROJECT_NAME}#g" \
    "$DOCKER_COMPOSE_FILE"; then
  echo "Arquivo '$DOCKER_COMPOSE_FILE' atualizado."
  rm -f "${DOCKER_COMPOSE_FILE}.bak" # Remover backup se o sed teve êxito
else
  echo "Erro: Falha ao atualizar '$DOCKER_COMPOSE_FILE'."
  if [ -f "${DOCKER_COMPOSE_FILE}.bak" ]; then
    echo "Restaurando '$DOCKER_COMPOSE_FILE' a partir de '${DOCKER_COMPOSE_FILE}.bak'..."
    if mv "${DOCKER_COMPOSE_FILE}.bak" "$DOCKER_COMPOSE_FILE"; then
      echo "'$DOCKER_COMPOSE_FILE' restaurado com sucesso."
    else
      echo "Erro crítico: Falha ao restaurar '$DOCKER_COMPOSE_FILE' a partir de '${DOCKER_COMPOSE_FILE}.bak'. Por favor, verifique manualmente."
    fi
  else
    echo "Não foi encontrado o arquivo de backup '${DOCKER_COMPOSE_FILE}.bak'. Não foi possível restaurar."
  fi
  exit 1
fi

# --- Actualizar docker/nginx/default.conf ---
if sed -i.bak "s#root /var/www/html/${PLACEHOLDER_PROJECT_NAME}/public;#root /var/www/html/${PROJECT_NAME}/public;#g" "$NGINX_CONF_FILE"; then
  echo "Arquivo '$NGINX_CONF_FILE' atualizado."
  rm -f "${NGINX_CONF_FILE}.bak" # Remover backup se o sed teve êxito
else
  echo "Erro: Falha ao atualizar '$NGINX_CONF_FILE'."
  if [ -f "${NGINX_CONF_FILE}.bak" ]; then
    echo "Restaurando '$NGINX_CONF_FILE' a partir de '${NGINX_CONF_FILE}.bak'..."
    if mv "${NGINX_CONF_FILE}.bak" "$NGINX_CONF_FILE"; then
      echo "'$NGINX_CONF_FILE' restaurado com sucesso."
    else
      echo "Erro crítico: Falha ao restaurar '$NGINX_CONF_FILE' a partir de '${NGINX_CONF_FILE}.bak'. Por favor, verifique manualmente."
    fi
  else
    echo "Não foi encontrado o arquivo de backup '${NGINX_CONF_FILE}.bak'. Não foi possível restaurar."
  fi
  exit 1
fi

echo ""
echo "Configuração concluída!"
echo "Seu projeto CodeIgniter está pronto na pasta: $PROJECT_NAME"
echo "Os arquivos '$DOCKER_COMPOSE_FILE' e '$NGINX_CONF_FILE' foram atualizados."
echo "Agora você pode executar 'docker-compose up -d --build' para iniciar seu ambiente Docker."

exit 0