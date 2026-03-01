##################
# Variables
##################

DOCKER_COMPOSE = docker compose --env-file=./.env -f ./docker-compose.yaml -p sfu

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
