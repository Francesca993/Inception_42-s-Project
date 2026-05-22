*This project has been created as part of the 42 curriculum by fmontini.*

# Inception

## Description

Inception is a system administration project from the 42 curriculum.  
Its goal is to build a small web infrastructure inside a virtual machine using Docker Compose.

This infrastructure is composed of three custom services running in separate containers:

- **NGINX** as the only public entry point, accessible through HTTPS on port 443
- **WordPress + php-fpm** to serve the website
- **MariaDB** to store the WordPress data

The project also requires persistent storage for both the database and the website files, a dedicated Docker network for inter-container communication, and a configuration based on environment variables and Docker secrets.  
The whole stack is launched from a `Makefile` and must respect the rules of the subject, including custom Dockerfiles, no ready-made service images, and no passwords stored directly in the Dockerfiles or repository files outside properly managed secrets.

## Project Architecture

The infrastructure follows a simple flow:

`Browser -> NGINX -> WordPress/php-fpm -> MariaDB`

```txt

Internet / Browser
        |
      HTTPS
        |
      NGINX
        |
   Docker network
    /         \
WordPress   MariaDB

```

NGINX is the only container exposed to the host on port 443.  
WordPress is not exposed directly: it communicates internally with NGINX through FastCGI on port 9000.  
MariaDB is also internal-only and is reached by WordPress through the Docker network on port 3306.

## Services

### NGINX
The NGINX container is the public entry point of the stack.  
It listens only on port 443, uses a self-signed SSL certificate, and allows only TLSv1.2 and TLSv1.3.  
It serves the WordPress files from the shared website volume and forwards PHP requests to the WordPress container.

### WordPress + php-fpm
The WordPress container installs and configures WordPress automatically using `wp-cli`.  
It waits for MariaDB to become reachable, creates the WordPress configuration, installs the site, creates the administrator account, and also creates a second non-admin user as required by the subject.

### MariaDB
The MariaDB container initializes the database directory if needed, starts a temporary bootstrap server, creates the WordPress database and user, sets the root password, and then starts the final MariaDB server process.  
Its data is stored in a persistent named volume.

## Design Choices

I chose to separate the infrastructure into three dedicated containers in order to respect the subject requirements and keep each service focused on a single responsibility.

Main choices:
- one container per service
- one internal bridge network for communication
- one named volume for MariaDB data
- one named volume for WordPress files
- `.env` for non-sensitive configuration values
- Docker secrets for passwords
- HTTPS access only through NGINX
- automatic WordPress and MariaDB bootstrap using startup scripts

This design keeps the stack modular, easier to debug, and closer to real deployment logic.

## Required Comparisons

### Virtual Machines vs Docker

A virtual machine emulates a full operating system.  
Docker containers share the host kernel and isolate only the application and its dependencies.

For this project, Docker is lighter, faster to start, easier to reproduce, and better suited for service-based infrastructure.  
The virtual machine is still required by the subject because it provides the host environment where Docker runs.

### Secrets vs Environment Variables

Environment variables are useful for non-sensitive configuration such as:
- domain name
- database name
- usernames
- site title
- email addresses

Docker secrets are better for sensitive data such as passwords.  
In my project, passwords are stored in files inside the `secrets/` directory and injected into the containers through Docker secrets, while the `.env` file only stores non-secret values.

### Docker Network vs Host Network

A Docker bridge network isolates the services and lets containers communicate using service names such as `mariadb` or `wordpress`.  
This is safer and cleaner than host networking.

Host networking would remove that isolation and is forbidden by the subject.  
Using a dedicated Docker network also makes the stack easier to understand and control.

### Docker Volumes vs Bind Mounts

A Docker named volume is managed by Docker and is meant for persistent service data.  
A bind mount directly maps a host path into a container.

The subject explicitly requires named volumes for WordPress files and MariaDB data.  
Volumes are better here because they are cleaner to manage, work well with container recreation, and keep persistence separate from the container lifecycle.
---

## Instructions

All commands must be run from the root of the repository.

### Main Makefile commands

#### Build and start the whole project
```bash
make
```
or
```bash
make up
```
### Stop and remove containers, while keeping persistent volumes
```bash
make down
```
### Start existing stopped containers
```bash
make start
```
### Stop running containers without removing them
```bash
make stop
```
### Restart running containers
```bash
make restart
```
### Build images without starting containers
```bash
make build
```
### Recreate the project without deleting persistent data
```bash
make re
```
### Show and follow logs
```bash
make logs
```
### Show container status
```bash
make ps
```
## Show a quick project overview
```bash
make status
```
### Show all available Makefile commands
```bash
make help
```
For more advanced maintenance and debugging commands, see DEV_DOC.md.
---

## Project Structure

```txt
.
├── Makefile
├── secrets/
├── srcs/
│   ├── .env
│   ├── docker-compose.yml
│   └── requirements/
│       ├── mariadb/
│       ├── nginx/
│       └── wordpress/

```

* srcs/.env stores non-sensitive environment variables
* secrets/ stores password files used by Docker secrets
* requirements/ contains one custom Dockerfile and configuration for each service

## Data Persistence
The project uses two named volumes:
* one for MariaDB data
* one for WordPress website files

This means the data survives container stop, removal, and recreation.
Persistence is essential because WordPress content and database tables must still exist after a restart or rebuild.

## Resources
* Docker documentation
* Docker Compose documentation
* NGINX documentation
* MariaDB documentation
* WordPress documentation
* WP-CLI documentation
* OpenSSL documentation

## AI Usage
AI was used only as a support tool for:
- clarifying Docker, volumes, networks, and persistence concepts
- reviewing configuration choices
- improving documentation structure and readability
- transforming personal technical notes into clearer English documentation
All generated explanations were reviewed, rewritten, and adapted to match the actual implementation of the project.