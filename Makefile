.PHONY: build init

build:
	docker build -t coopernurse/claude-docker .

init:
	docker volume create claude-data
