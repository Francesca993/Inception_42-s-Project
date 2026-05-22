*This project has been created as part of the 42 curriculum by fmontini.*

# USER_DOC

## Overview

This project provides a small self-hosted WordPress infrastructure composed of:
- an HTTPS reverse proxy with NGINX
- a WordPress website running with php-fpm
- a MariaDB database
- persistent storage for website files and database data

The only public entry point is NGINX over HTTPS.

## Start the project

From the root of the repository, run:

```bash
make
```
or:
```bash
make up
```
## Stop / Restart the project
Stop and remove containers while keeping persistent volumes:
```bash
make down
```

## Stop running containers without removing them:
```bash
make stop
```
## Start existing stopped containers:
```bash
make start
```
## Restart running containers:
```bash
make restart
```
## Recreate the project without deleting persistent data:
```bash
make re
```
---

## Access the website

Open the website in your browser:  
```txt
https://fmontini.42.fr 
```

HTTP should not be available.  
Only HTTPS on port 443 is expected.  

## Access the WordPress admin panel
Open:
```txt
https://fmontini.42.fr/wp-admin
```  
Then log in with the administrator username and password configured during setup.  
---

## Credentials
Non-sensitive values such as usernames, domain name, and database name are stored in:  
```txt
srcs/.env
```
Sensitive values such as passwords are stored in Docker secret files inside:
```txt
secrets/
```  

Typical secret files:
* db_password.txt
* db_root_password.txt
* wp_admin_password.txt
* wp_user_password.txt
---

## Check services status

### Show running containers:
```bash
make ps
```
### Show logs:
```bash
make logs
```

### Show project overview:
```bash
make status
```

### Check the TLS certificate:
```bash
openssl s_client -connect fmontini.42.fr:443
```

## Advanced checks

### Check container status with Docker Compose:
```bash
docker compose -f srcs/docker-compose.yml ps
```

### Check logs with Docker Compose:
```bash
docker compose -f srcs/docker-compose.yml logs
```

### Check Docker volumes
```bash
docker volume ls
docker volume inspect <volume_name>
```
--- 

## Basic usage checks
To verify that the project works correctly:
* open the website in the browser
* confirm that the site loads through HTTPS
* confirm that the WordPress installation page does not appear
* open /wp-admin
* log in with the administrator account
* create or edit a page
* add a comment with a WordPress user
* refresh the website and confirm the changes are visible
* restart the stack and confirm the changes are still present