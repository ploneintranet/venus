PROJECT=venus

default: usage

usage:
	@echo "Usage: make <target>"
	@echo "-------------"
	@echo "docker-build:	create a docker container"
	@echo "docker-run:	start the docker container"
	@echo "buildout:	build ploneintranet"
	@echo "test:		run all tests to verify install"
	@echo "start:		start all services"
	@echo "stop:		stop all services"
	@echo "clean:		remove all data to prepare for fresh re-build (destructive!)"
	@echo "-------------"

Dockerfile:
	wget https://raw.githubusercontent.com/ploneintranet/ploneintranet/master/Dockerfile
	sed -i -e 's/ploneintranet/venus/' Dockerfile

docker-build: Dockerfile
	docker build -t $(PROJECT) .

# re-uses ssh agent
# also loads your standard .bashrc
docker-run:  ## Start docker container
	docker run -i -t \
                --net=host \
                -v /var/tmp:/var/tmp \
                -v $(SSH_AUTH_SOCK):/tmp/auth.sock \
                -v $(HOME)/.bashrc:/app/.bashrc \
                -v $(HOME)/.buildout:/app/.buildout \
                -v $(HOME)/.pypirc:/app/.pypirc \
                -v $(HOME)/.gitconfig:/app/.gitconfig \
                -v $(HOME)/.gitignore_global:/app/.gitignore_global \
                -e SSH_AUTH_SOCK=/tmp/auth.sock \
		-e PYTHON_EGG_CACHE=/var/tmp/python-eggs \
		-e LC_ALL=en_US.UTF-8 \
		-e LANG=en_US.UTF-8 \
                -v $(PWD):/app -w /app -u app $(PROJECT)


buildout: bin/buildout buildout.cfg
	bin/buildout

bin/buildout: bin/python2.7 requirements.txt
	@bin/pip install -r requirements.txt

bin/python2.7:
	@virtualenv --clear -p python2.7 .

requirements.txt:
	wget https://raw.githubusercontent.com/ploneintranet/ploneintranet/master/requirements.txt

test-robot: ## Run robot tests with a virtual X server
	Xvfb :99 1>/dev/null 2>&1 & HOME=/app DISPLAY=:99 bin/test -t 'robot' -x
	@ps | grep Xvfb | grep -v grep | awk '{print $2}' | xargs kill 2>/dev/null

test-norobot: ## Run all tests apart from robot tests
	bin/test -t '!robot' -x

test:: ## 	 Run all tests, including robot tests with a virtual X server
	Xvfb :99 1>/dev/null 2>&1 & HOME=/app DISPLAY=:99 bin/test -x
	@ps | grep Xvfb | grep -v grep | awk '{print $2}' | xargs kill 2>/dev/null

start:
	bin/supervisord

stop:
	bin/supervisorctl shutdown

clean:
	git clean -fdX

# no-op target needed by generated script
fetchrelease:
	@echo
