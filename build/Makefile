
WORKING_DIR := $(shell powershell -command '(get-item $$(pwd) ).parent.FullName')
UID := $(shell id -u)
GID := $(shell id -g)

bash: build
	docker run -it --rm --user "$(UID):$(GID)" -v "$(WORKING_DIR):/usr/src" rails-builder:6 bash
build:
	docker build . -t rails-builder:6