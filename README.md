# Docker Development Environment for CodeIgniter 4

This repository provides a complete Docker configuration for developing CodeIgniter 4 applications. The environment includes PHP, Nginx, MySQL, Redis, MailHog, and Redis Commander.

## Features

*   **PHP 8.3-FPM**
*   **Nginx** as web server.
*   **MySQL 8.0** as database.
*   **Redis** for cache or sessions.
*   **MailHog** to capture and view emails sent by the application.
*   **Redis Commander** to view and manage data in Redis.
*   **Setup Script (`setup.sh`)** to create a new CodeIgniter 4 project and automatically configure Docker files.

## Prerequisites

Before starting, make sure you have the following software installed on your machine:

*   Docker
*   Docker Compose
*   Composer (required to run the `setup.sh` script)

## How to Use

### 1. Clone the Repository (Optional)

If you don't have this setup locally yet:
```bash
git clone https://github.com/joserafael/codeigniter4-docker.git
cd codeigniter4-docker
```

### 2. Configure a New CodeIgniter Project

This repository includes a `setup.sh` script to facilitate creating a new CodeIgniter 4 project and configuring Docker files.

Run the script and follow the instructions:
```bash
chmod +x setup.sh
./setup.sh
```
The script will:
1.  Request a name for your new CodeIgniter project (e.g., `my_app_ci`).
2.  Create a new folder with the provided name and install CodeIgniter 4 in it using `composer create-project`.
3.  Automatically update `docker-compose.yml` and `docker/nginx/default.conf` files to use the project name you provided.

**Note:** The script assumes that `docker-compose.yml` and `docker/nginx/default.conf` files initially use `codeigniter_project` as a placeholder for the project directory name.

### 3. Configure the CodeIgniter `.env` File

After the `setup.sh` script creates your project (e.g., in the `my_app_ci` folder), navigate to that folder:
```bash
cd your_project_name # Ex: cd my_app_ci
```
Copy the `env` file to `.env` and configure your application's environment variables, especially the database ones if they are different from the defaults defined in `docker-compose.yml`.
```bash
cp env .env
```
The database, Redis, and email settings in `docker-compose.yml` (`environment` section of the `app` service) are passed to CodeIgniter and generally override the values in `.env`.

### 4. Start the Docker Environment

Go back to the root of the Docker repository (where `docker-compose.yml` is) and run:
```bash
docker-compose up -d --build
```
This command will build the images (the first time or if `Dockerfile.php` changes) and start all services in the background.

### 5. Access the Services

*   **Your CodeIgniter Application**: `http://localhost:8080` (or the port configured in `NGINX_HOST_PORT` in `docker-compose.yml`).
*   **MailHog (Web Interface for Emails)**: `http://localhost:8025`
*   **Redis Commander**: `http://localhost:8081`
*   **MySQL**:
    *   Host (for external clients like DBeaver, TablePlus): `127.0.0.1`
    *   Port: `33061` (or the port configured in `MYSQL_HOST_PORT`)
    *   User: `user` (or the value of `MYSQL_USER`)
    *   Password: `password` (the value of `MYSQL_PASSWORD`)
    *   Database: `ci4_db` (the value of `MYSQL_DATABASE`)
*   **Redis**:
    *   Host (for external clients): `127.0.0.1`
    *   Port: `63791` (or the port configured in `REDIS_HOST_PORT`)

### 6. Run Composer and Spark Commands

To run Composer commands (like `install`, `update`, `require`) or CodeIgniter `php spark` commands, you must do so inside the `app` container:

```bash
# Example to install Composer dependencies
docker-compose exec app composer install

# Example to run CodeIgniter migrations
docker-compose exec app php spark migrate

# Example to install a new package
docker-compose exec app composer require vendor/package
```
The default working directory inside the `app` container is already the root of your CodeIgniter project.

### 7. Stop the Docker Environment

To stop all containers:
```bash
docker-compose down
```
If you want to remove volumes (and lose MySQL and Redis data):
```bash
docker-compose down -v
```

## Project Structure

*   `Dockerfile.php`: Defines the Docker image for the PHP/CodeIgniter application.
*   `docker-compose.yml`: Orchestrates all Docker services.
*   `docker/`: Contains specific Docker service configurations (e.g., Nginx).
*   `setup.sh`: Script to initialize a new CodeIgniter project.
*   `.gitignore`: File to ignore files and folders from version control.
*   `YOUR_PROJECT_NAME/`: Folder created by `setup.sh` containing your CodeIgniter application.

## Contributing

Feel free to open issues or pull requests for improvements.