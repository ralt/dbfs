ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
SOURCES := $(wildcard src/*.lisp) $(wildcard *.asd) $(wildcard t/*.lisp)
APP_NAME=dbfs

.PHONY: clean docker-create docker-start docker-stop

$(APP_NAME): quicklisp-manifest.txt $(SOURCES)
	@buildapp  --manifest-file quicklisp-manifest.txt \
		--eval '(push "$(ROOT_DIR)/" asdf:*central-registry*)' \
		--load-system $(APP_NAME) \
		--eval '($(APP_NAME):disable-debugger)' \
		--compress-core \
		--output $(APP_NAME) --entry $(APP_NAME):main

quicklisp-manifest.txt:
	@sbcl --non-interactive \
		--eval '(push #P"$(ROOT_DIR)/" asdf:*central-registry*)' \
		--eval '(ql:quickload :$(APP_NAME))' \
		--eval '(ql:write-asdf-manifest-file "quicklisp-manifest.txt")'

clean:
	@rm -f $(APP_NAME) quicklisp-manifest.txt

docker-create:
	docker run -d \
		--volume=/var/lib/mysql \
		--env="POSTGRES_USER=dbfs" \
		--env="POSTGRES_PASSWORD=pass" \
		--publish="5432:5432" \
		--name="dbfs-postgresql" \
		postgres

docker-start:
	docker start dbfs-postgresql

docker-stop:
	docker stop dbfs-postgresql
