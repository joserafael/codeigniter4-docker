#!/bin/bash

# Script to configure a new CodeIgniter 4 project with Docker.

# Paths for configuration files
DOCKER_COMPOSE_FILE="docker-compose.yml"
NGINX_CONF_FILE="docker/nginx/default.conf"

# Current placeholder in configuration files that will be replaced.
# Make sure your template files use this placeholder.
PLACEHOLDER_PROJECT_NAME="codeigniter_project"

# --- Request project name from user ---
read -p "Enter the name for your CodeIgniter project (ex: my_ci_app): " PROJECT_NAME

# Validate that the project name is not empty
if [ -z "$PROJECT_NAME" ]; then
  echo "Error: Project name cannot be empty. Aborting."
  exit 1
fi

# Validate allowed characters for directory name (simplified)
if [[ "$PROJECT_NAME" =~ [^a-zA-Z0-9_-] ]]; then
  echo "Error: Project name can only contain letters, numbers, underscores (_) and hyphens (-). Aborting."
  exit 1
fi

# Check if project directory already exists
if [ -d "$PROJECT_NAME" ]; then
  echo "Error: Directory '$PROJECT_NAME' already exists. Please choose another name or remove the existing directory. Aborting."
  exit 1
fi

# --- Create CodeIgniter project ---
echo "Creating CodeIgniter project '$PROJECT_NAME'..."
if ! composer create-project codeigniter4/appstarter "$PROJECT_NAME" --prefer-dist --no-interaction; then
  echo "Error: Failed to create CodeIgniter project with Composer. Aborting."
  # Try to clean up created folder if Composer fails
  if [ -d "$PROJECT_NAME" ]; then
    rm -rf "$PROJECT_NAME"
  fi
  exit 1
fi
echo "CodeIgniter project '$PROJECT_NAME' created successfully in folder './$PROJECT_NAME'."

echo "Updating configuration files to use '$PROJECT_NAME'..."

# --- Update docker-compose.yml ---
# Uses # as delimiter for sed to avoid conflicts with slashes / in paths.
# Creates a .bak file as backup.
if sed -i.bak \
    -e "s#\./${PLACEHOLDER_PROJECT_NAME}:/var/www/html/${PLACEHOLDER_PROJECT_NAME}#\./${PROJECT_NAME}:/var/www/html/${PROJECT_NAME}#g" \
    -e "s#working_dir: /var/www/html/${PLACEHOLDER_PROJECT_NAME}#working_dir: /var/www/html/${PROJECT_NAME}#g" \
    "$DOCKER_COMPOSE_FILE"; then
  echo "File '$DOCKER_COMPOSE_FILE' updated."
  rm -f "${DOCKER_COMPOSE_FILE}.bak" # Remove backup if sed succeeded
else
  echo "Error: Failed to update '$DOCKER_COMPOSE_FILE'."
  if [ -f "${DOCKER_COMPOSE_FILE}.bak" ]; then
    echo "Restoring '$DOCKER_COMPOSE_FILE' from '${DOCKER_COMPOSE_FILE}.bak'..."
    if mv "${DOCKER_COMPOSE_FILE}.bak" "$DOCKER_COMPOSE_FILE"; then
      echo "'$DOCKER_COMPOSE_FILE' restored successfully."
    else
      echo "Critical error: Failed to restore '$DOCKER_COMPOSE_FILE' from '${DOCKER_COMPOSE_FILE}.bak'. Please check manually."
    fi
  else
    echo "Backup file '${DOCKER_COMPOSE_FILE}.bak' not found. Could not restore."
  fi
  exit 1
fi

# --- Update docker/nginx/default.conf ---
if sed -i.bak "s#root /var/www/html/${PLACEHOLDER_PROJECT_NAME}/public;#root /var/www/html/${PROJECT_NAME}/public;#g" "$NGINX_CONF_FILE"; then
  echo "File '$NGINX_CONF_FILE' updated."
  rm -f "${NGINX_CONF_FILE}.bak" # Remove backup if sed succeeded
else
  echo "Error: Failed to update '$NGINX_CONF_FILE'."
  if [ -f "${NGINX_CONF_FILE}.bak" ]; then
    echo "Restoring '$NGINX_CONF_FILE' from '${NGINX_CONF_FILE}.bak'..."
    if mv "${NGINX_CONF_FILE}.bak" "$NGINX_CONF_FILE"; then
      echo "'$NGINX_CONF_FILE' restored successfully."
    else
      echo "Critical error: Failed to restore '$NGINX_CONF_FILE' from '${NGINX_CONF_FILE}.bak'. Please check manually."
    fi
  else
    echo "Backup file '${NGINX_CONF_FILE}.bak' not found. Could not restore."
  fi
  exit 1
fi

echo ""
echo "Configuration complete!"
echo "Your CodeIgniter project is ready in folder: $PROJECT_NAME"
echo "Files '$DOCKER_COMPOSE_FILE' and '$NGINX_CONF_FILE' were updated."
echo "Now you can run 'docker-compose up -d --build' to start your Docker environment."

exit 0