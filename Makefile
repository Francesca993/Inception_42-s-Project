# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: francesca <francesca@student.42.fr>        +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/04/23 12:39:22 by francesca         #+#    #+#              #
#    Updated: 2026/05/22 08:14:48 by francesca        ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME        = inception
COMPOSE     = docker compose -f srcs/docker-compose.yml

LOGIN       = $USER
DATA_DIR    = /home/$(LOGIN)/data

.PHONY: all up down start stop restart build re clean fclean logs ps \
        exec-nginx exec-wordpress exec-mariadb volumes network status help

# Default target: builds and starts the whole infrastructure
all: up

# Build images if needed and start all containers
up:
	sudo mkdir -p $(DATA_DIR)/mariadb
	sudo mkdir -p $(DATA_DIR)/wordpress
	$(COMPOSE) up --build

# Stop and remove containers and network, but keep volumes
down:
	$(COMPOSE) down

# Start existing stopped containers
start:
	$(COMPOSE) start

# Stop running containers without removing them
stop:
	$(COMPOSE) stop

# Restart running containers
restart:
	$(COMPOSE) restart

# Build all images without starting containers
build:
	$(COMPOSE) build

# Recreate the project without deleting persistent data
re: down up

# Stop everything and remove containers, network and volumes
clean:
	$(COMPOSE) down -v

# Full cleanup: remove containers, network, volumes and images
fclean:
	sudo rm -rf $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	$(COMPOSE) down -v --rmi all --remove-orphans

# Show and follow container logs
logs:
	$(COMPOSE) logs -f

# Show container status
ps:
	$(COMPOSE) ps

# Open a shell inside the NGINX container
exec-nginx:
	docker exec -it nginx bash

# Open a shell inside the WordPress container
exec-wordpress:
	docker exec -it wordpress bash

# Open a shell inside the MariaDB container
exec-mariadb:
	docker exec -it mariadb bash

# List Docker volumes
volumes:
	docker volume ls

# Inspect Docker networks
network:
	docker network ls

# Show a quick overview of containers and volumes
status:
	@$(COMPOSE) ps
	@echo ""
	@docker volume ls

# Show available Makefile commands
help:
	@echo "Available targets:"
	@echo "  make / make up         - Build and start the project"
	@echo "  make down              - Stop and remove containers, keep volumes"
	@echo "  make start             - Start existing containers"
	@echo "  make stop              - Stop running containers"
	@echo "  make restart           - Restart containers"
	@echo "  make build             - Build images only"
	@echo "  make re                - Recreate project without deleting data"
	@echo "  make clean             - Remove containers, network and volumes"
	@echo "  make fclean            - Full cleanup including images"
	@echo "  make logs              - Show logs"
	@echo "  make ps                - Show containers status"
	@echo "  make exec-nginx        - Enter nginx container"
	@echo "  make exec-wordpress    - Enter wordpress container"
	@echo "  make exec-mariadb      - Enter mariadb container"
	@echo "  make volumes           - List Docker volumes"
	@echo "  make network           - List Docker networks"
	@echo "  make status            - Quick project overview"


#notes:
#docker ps
#docker ps -a
#docker images
#docker volume ls
#docker network ls
#docker compose logs
#docker compose logs nginx
#docker compose logs wordpress
#docker compose logs mariadb
#docker exec -it nginx bash
#docker exec -it wordpress bash
#docker exec -it mariadb bash
#docker port nginx
#docker port wordpress
#docker port mariadb
#curl -k -I https://fmontini.42.fr
#curl -I http://fmontini.42.fr
#openssl s_client -connect fmontini.42.fr:443 -tls1_2
#openssl s_client -connect fmontini.42.fr:443 -tls1_3
#docker network inspect srcs_inception
#docker volume inspect srcs_mariadb_data
#docker volume inspect srcs_wordpress_data
#
#