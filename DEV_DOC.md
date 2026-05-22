# DEV_DOC

## Purpose

This document explains how to set up, build, run, inspect, and maintain the Inception project as a developer.

## Prerequisites

Before running the project, make sure you have:

- a Linux virtual machine
- Docker installed
- Docker Compose installed
- Make installed
- a local domain configured to point to the VM IP: `fmontini.42.fr`  

The subject requires the whole project to run inside a virtual machine, using Docker Compose, custom Dockerfiles, a dedicated Docker network, and named volumes for persistence.  

## Project Structure

Main files:

- `Makefile`
- `README.md`
- `USER_DOC.md`
- `DEV_DOC.md`
- `srcs/docker-compose.yml`
- `srcs/.env`
- `secrets/`

Service directories:

- `srcs/requirements/nginx/`
- `srcs/requirements/wordpress/`
- `srcs/requirements/mariadb/`

Each service has its own configuration and startup script. The compose file defines the three services, the two named volumes, the internal bridge network, and the Docker secrets. 

## Configuration

### Environment variables

The `.env` file stores non-sensitive configuration values such as:

- domain name
- database name
- usernames
- site title
- email addresses

The project requires the use of environment variables and a `.env` file.  

### Secrets

Sensitive values such as passwords are stored separately in the `secrets/` directory and injected into the containers through Docker secrets. In the compose file, the project uses:

- `db_password`
- `db_root_password`
- `wp_admin_password`
- `wp_user_password`

The WordPress and MariaDB startup scripts read these values from `/run/secrets/...`, which keeps passwords out of Dockerfiles and regular environment variable storage. 

## Build and Launch

All commands must be run from the root of the repository.

### Start the project:

```bash
make
```
or:
```bash
make up
```
### Stop and remove containers while keeping persistent volumes:
```bash
make down
```
### Recreate the project:
```bash
make re
```
### If needed, you can also use Docker Compose directly:
```bash
docker compose -f srcs/docker-compose.yml up --build
docker compose -f srcs/docker-compose.yml down
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs
```
The evaluation explicitly checks that the stack is launched through the Makefile and Docker Compose.

## Container Inspection

### Check running containers:
```bash
docker compose -f srcs/docker-compose.yml ps
```
### Check logs:
```bash
docker compose -f srcs/docker-compose.yml logs
```
### Follow logs in real time:
```bash
docker compose -f srcs/docker-compose.yml logs -f
```
### Open a shell inside a container:
```bash
docker exec -it nginx sh
docker exec -it wordpress sh
docker exec -it mariadb sh
```
---

## Volumes and Persistence
The project uses two named volumes:  
* mariadb_data mounted to /var/lib/mysql
* wordpress_data mounted to /var/www/html
These volumes are required because MariaDB data and WordPress files must persist even if containers are stopped, removed, or recreated. The subject explicitly requires named volumes and forbids bind mounts for these persistent storages.  

**Useful commands:**  
```bash
docker volume ls
docker volume inspect <volume_name>
```
**You can also verify the expected host-side storage path:**
```bash
ls /home/$USER/data
ls /home/$USER/data/mariadb
ls /home/$USER/data/wordpress
```
The subject states that both named volumes must store their data inside /home/login/data on the host machine.
---

## Network
The stack uses a dedicated bridge network called inception. This allows internal communication between services by service name instead of exposing them directly on the host.

Main internal connections:
* nginx -> wordpress:9000
* wordpress -> mariadb:3306
The subject and the evaluation both require a Docker network and forbid host networking and links.
---

## Service Notes

### NGINX
NGINX is the only public entry point of the infrastructure. It listens only on port 443, serves the WordPress files, and forwards PHP requests to the WordPress container through FastCGI. Its configuration allows only TLSv1.2 and TLSv1.3. A self-signed certificate is generated when the container starts.

### WordPress
The WordPress setup script waits until MariaDB is reachable, tests the database connection, downloads WordPress if needed, creates wp-config.php, installs the site, creates the administrator account, creates a second non-admin user, and finally runs php-fpm in foreground mode.

### MariaDB
The MariaDB init script validates the required environment variables, reads the database passwords from Docker secrets, initializes the database directory if needed, starts a temporary MariaDB instance, creates the WordPress database and user, sets the root password, and then launches the final MariaDB server process.

---

## Database Checks
To connect to MariaDB from inside the container:
```bash
docker exec -it mariadb sh
mysql -u root -p
```
Use the root password stored in:
```bash
secrets/db_root_password.txt
```
Useful SQL commands:
```bash
SHOW DATABASES;
USE <your_database_name>;
SHOW TABLES;
SELECT * FROM wp_users;
SELECT * FROM wp_comments;
```
These checks help confirm that WordPress has been installed correctly and that data is being stored in the database.

## Quick Verification

After deployment, verify that:
- the website opens at `https://fmontini.42.fr`
- the WordPress installation page does not appear
- `/wp-admin` is accessible
- content changes persist after restart
- TLS works correctly on port 443
