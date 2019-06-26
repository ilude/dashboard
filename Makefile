bash: build
	docker-compose run --rm web-blue bash

.PHONY: build
build:
	docker-compose build
