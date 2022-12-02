SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-print-directory

up:
	@docker network create --driver=bridge --subnet=192.168.80.254/24 ec2-network
	@docker-compose build
	@docker-compose up -d
down:
	@docker-compose down --remove-orphans
	@docker network rm ec2-network
