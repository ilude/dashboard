DEFAULT_HOST := web-blue
DEFAULT_SITE := ilude

# check the last target passed, if its one of the STAGES, use it, otherwise production
STAGES := staging production

FLAGS = -f ./docker-compose.yml

DEPLOY_STAGE := $(or $(filter  $(lastword $(MAKECMDGOALS)),$(STAGES)), override)

# If the first argument is "attach" or "bash"...
ifneq (,$(filter  $(MAKECMDGOALS),attach bash))
	# default to influx container name
	ATTACH_HOST := $(or  $(filter-out $(STAGES) ilude, $(word 2,$(MAKECMDGOALS))), $(DEFAULT_HOST))
	DEPLOY_SITE := $(word 2,$(MAKECMDGOALS))
else
	# first target is verb(real make target) second is noun(DEPLOY_SITE)
	# default to ram if no verb provided
	DEPLOY_SITE := $(or $(INFLUX_SITE),$(filter-out $(STAGES), $(word 2,$(MAKECMDGOALS))), $(DEFAULT_SITE))
endif

ifneq (,$(filter  $(MAKECMDGOALS),logs))
	ATTACH_HOST := $(or $(filter-out $(STAGES) ilude, $(word 2,$(MAKECMDGOALS))),)
endif

# set the docker-compose FLAGS based on the DEPLOY_STAGE value
ifneq ("$(wildcard ./docker-compose.$(DEPLOY_STAGE).yml)","")
	FLAGS += -f ./docker-compose.$(DEPLOY_STAGE).yml
endif

# set the docker-compose FLAGS based on the DEPLOY_SITE value
ifneq ("$(wildcard ./docker-compose.$(DEPLOY_SITE).yml)","")
	FLAGS += -f ./docker-compose.$(DEPLOY_SITE).yml
endif

# determine the ip address on the interface that the default route goes out on
# on any of the OS's we use (ya that was fun!)
ifeq ($(OS),Windows_NT)
	HOSTNAME := $(COMPUTERNAME)
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
			HOSTNAME := $(shell hostname)
	endif
	ifeq ($(UNAME_S),Darwin)
			HOSTNAME := $(shell hostname -s)
	endif
endif

# check if HOSTNAME has an associated env file
HOSTNAME := $(shell echo $(HOSTNAME) | tr a-z A-Z)
ifneq ("$(wildcard ./config/container/envs/$(HOSTNAME).env)","")
	HOST_OVERRIDE = $(HOSTNAME)
else
	HOST_OVERRIDE = host-override
endif

# check if USERNAME has an associated env file
APP_USERNAME := $(or $(filter-out staging production, $(USERNAME)), not-set)
ifneq ("$(wildcard ./config/container/envs/$(APP_USERNAME).env)","")
	USER_OVERRIDE = $(APP_USERNAME)
else
	USER_OVERRIDE = user-override
endif

export DEPLOY_STAGE
export DEPLOY_SITE
export HOST_OVERRIDE
export USER_OVERRIDE

# get current timestamp
DATE := $(shell date "+%Y-%m-%d-%H.%M.%S")

# use the rest as arguments as empty targets
EMPTY_TARGETS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(EMPTY_TARGETS):;@:)


up: build
	docker-compose $(FLAGS) up --force-recreate --abort-on-container-exit --remove-orphans

start: build 
	docker-compose $(FLAGS) up --force-recreate --remove-orphans -d

down:
	docker-compose $(FLAGS) down --remove-orphans

restart: down start

attach:
	docker-compose $(FLAGS) exec $(ATTACH_HOST) bash

bash: build
	docker-compose $(FLAGS) run --rm $(ATTACH_HOST) bash

.PHONY: build
build:
	docker-compose $(FLAGS) build

clean: 
	docker-compose $(FLAGS) down --volumes --remove-orphans --rmi local
	docker-compose $(FLAGS) rm -f -v