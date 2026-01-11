##################
# Variables
##################

DOCKER_COMPOSE = docker-compose --env-file=./.env -f ./docker-compose.yml -p drinkks

PHP_FPM=php

##################
# Docker compose
##################

build:
	${DOCKER_COMPOSE} build

rebuild:
	${DOCKER_COMPOSE} up -d --build --force-recreate

start:
	${DOCKER_COMPOSE} start

stop:
	${DOCKER_COMPOSE} stop

up:
	${DOCKER_COMPOSE} up -d --remove-orphans

down:
	${DOCKER_COMPOSE} down

restart: stop start

ps:
	${DOCKER_COMPOSE} ps

logs:
	${DOCKER_COMPOSE} logs -f

dc_down:
	${DOCKER_COMPOSE} down -v --rmi=all --remove-orphans

restart:
	make dc_stop dc_start

bash_symfony:
	${DOCKER_COMPOSE} exec -ti ${PHP_FPM} bash