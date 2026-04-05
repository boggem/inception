RESET=$(shell echo -e "\033[0m")
GREEN=$(shell echo -e "\033[1;32m")

DATA_DIR=/home/gboggion/data
MARIADB_DIR=$(DATA_DIR)/mariadb
WORDPRESS_DIR=$(DATA_DIR)/wordpress

COMPOSE_FILE=srcs/docker-compose.yml

env_check:
	@test -f srcs/.env || { echo "ERROR: srcs/.env not found"; exit 1; }
	@grep -q INCEPTION_NGINX_PORT srcs/.env || { echo "ERROR: INCEPTION_NGINX_PORT missing from .env"; exit 1; }
	@grep -q INCEPTION_WP_PORT srcs/.env || { echo "ERROR: INCEPTION_WP_PORT missing from .env"; exit 1; }
	@grep -q INCEPTION_MARIADB_PORT srcs/.env || { echo "ERROR: INCEPTION_MARIADB_PORT missing from .env"; exit 1; }

all: env_check mariadb_data wordpress_data
	@mkdir -p $(MARIADB_DIR) #creating mariadb data dir
	@mkdir -p $(WORDPRESS_DIR)
	@echo "++++ Containers are being configured ++++"
	@$(MAKE) images
	@$(MAKE) up
	@echo "$(GREEN)SUCCESSFULLY BUILT$(RESET)"

images:
	@echo "Docker images: Building"
	@docker compose -f $(COMPOSE_FILE) build

up:
	@echo "Containers: Starting"
	@docker compose -f $(COMPOSE_FILE) up -d

down:
	@echo "Containers: Stopping"
	@docker compose -f $(COMPOSE_FILE) down

clean:
	@echo "Removing: containers, images & volumes"
	@docker compose -f $(COMPOSE_FILE) down --rmi all -v

fclean: clean
	@echo "Removing: data directories"
	@sudo rm -rf $(DATA_DIR)
	@docker system prune -f --volumes

re: fclean all

.PHONY: all clean fclean re up down wordpress_data mariadb_data images
