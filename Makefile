# Variables

APP_NAME = gfldev_portfolio_api
COMPOSE_PROJECT_NAME=gfldev
DOCKER_DIR = ./build/docker

DC_DEV = $(DOCKER_DIR)/docker-compose.dev.yml
DC_TEST = $(DOCKER_DIR)/docker-compose.test.yml
DC_PROD = $(DOCKER_DIR)/docker-compose.prod.yml

DOCKERFILE = ./Dockerfile

# Help

.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make build         - build local (without docker)"
	@echo "  make run-dev       - execute the app directly as development"
	@echo "  make run-test      - execute the app's tests directly"
	@echo "  make run           - execute the app directly"
	@echo "  make clean         - remove binaries"
	@echo "  make coverage-html - tests coverage" 
	@echo "  make ci            - run ci"
	@echo "  make docker-build  - build docker"
	@echo "  make dev           - create and start docker-compose dev services"
	@echo "  make dev-down      - stop and remove docker-compose dev services" 
	@echo "  make test          - create and start docker-compose test services"
	@echo "  make prod          - start prod + redis"
	@echo "  make prod-up       - start only prod (redis must be running)"
	@echo "  make prod-down     - stop docker-compose prod services"
   
# Go commands

.PHONY: build
build:
	CGO_ENABLED=0 go build \
				 -tags netgo \
				 -o bin/$(APP_NAME) \
				 ./cmd/$(APP_NAME)

.PHONY: run-dev
run-dev:
	GO_ENV=development go run ./cmd/$(APP_NAME)

.PHONY: run-test
run-test:
	go test ./...

.PHONY: run
run:
	GO_ENV=production go run ./cmd/$(APP_NAME)

.PHONY: coverage-html
coverage-html:
	go tool cover -html=coverage.out -o coverage.html

.PHONY: clean
clean:
	rm -rf bin/

.PHONY: ci
ci:
	test coverage-html

# Docker commands

.PHONY: docker-build
docker-build:
	docker build \
		--env-file=.env.prod \
		-f $(DOCKERFILE) \
		-t $(APP_NAME):latest .

.PHONY: dev
dev:
	docker compose \
		-p $(COMPOSE_PROJECT_NAME)-dev \
		--env-file=.env.dev \
		-f $(DC_DEV) up --build

.PHONY: dev-down
dev-down:
	docker compose \
		-p $(COMPOSE_PROJECT_NAME)-dev \
		-f $(DC_DEV) down

.PHONY: test
test:
	docker compose \
		-p $(COMPOSE_PROJECT_NAME)-test \
		--env-file=.env.test \
		-f $(DC_TEST) up --build --abort-on-container-exit
	go test -coverprofile=coverage.out ./...
	docker compose \
		-p $(COMPOSE_PROJECT_NAME)-test \
		-f $(DC_TEST) down

.PHONY: prod
prod:
	docker compose \
		-p $(COMPOSE_PROJECT_NAME)-prod \
		--env-file=.env.prod \
		-f $(DC_PROD) up --build -d

.PHONY: prod-up
prod-up:
	docker compose \
		-p $(COMPOSE_PROJECT_NAME)-prod \
		--env-file=.env.prod \
		-f $(DC_PROD) up --build -d

.PHONY: prod-down
prod-down:
	docker compose \
		-p $(COMPOSE_PROJECT_NAME)-prod \
		-f $(DC_PROD) down
