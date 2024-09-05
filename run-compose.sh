#!/bin/sh
mcfversion=$2
mcfdist=$3

export COMPOSE_FILE_PATH="${PWD}/target/docker-compose/docker-compose.yml"

if [ -z "${M2_HOME}" ]; then
  export MVN_EXEC="mvn"
else
  export MVN_EXEC="${M2_HOME}/bin/mvn"
fi

build_start() {
	echo "Building with Maven skipping tests and run Docker containers"
	mvn clean install docker:build docker:start -DskipTests -DskipITs
}

build() {
	echo "Building with Maven skipping tests"
	mvn clean install -DskipTests -DskipITs
}

build_mcf() {
	docker compose -f "$COMPOSE_FILE_PATH" kill mcf-current-project
    yes | docker compose -f "$COMPOSE_FILE_PATH" rm -f mcf-current-project
    $MVN_EXEC clean install -pl mcf-extensions-jar,mcf-docker-overlay
}

tail() {
    docker compose -f "$COMPOSE_FILE_PATH" logs -f
}

tail_all() {
    docker compose -f "$COMPOSE_FILE_PATH" logs --tail="all"
}

build_test() {
	echo "Building with Maven executing tests"
	mvn clean install
}

unittests() {
	echo "Executing unit tests"
	mvn clean test
}

integrationtests() {
	echo "Executing integration tests"
	mvn clean integration-test
}

start() {
    docker volume create mcf-postgres-volume
    docker compose -f "$COMPOSE_FILE_PATH" up --build -d --remove-orphans
}

start_mcf() {
    docker volume create mcf-postgres-volume
    docker compose -f "$COMPOSE_FILE_PATH" up --build -d mcf-current-project --remove-orphans 
}

down() {
    if [ -f "$COMPOSE_FILE_PATH" ]; then
        docker compose -f "$COMPOSE_FILE_PATH" down
    fi
}

test() {
	echo "Starting the mcf-sdk-test-container to execute unit and integration tests"
	docker run -it --rm -v mcf-maven-repo:/root/.m2 -v mcf-app-volume:/usr/src/manifoldcf -t mcf-sdk-init ant test
}

purge() {
	echo "Removing the ManifoldCF Maven repo and installation volumes"
	docker volume rm mcf-postgres-volume
}

case "$1" in
  build_start)
		down
	    build
	    start
	    tail
	    ;;
	start)
		start
	    tail
	    ;;
	stop)
		down
		;;
	unittests)
		unittests
		;;
	integrationtests)
		integrationtests
		;;
	test)
	    test
	    ;;
	purge)
	    down
	    purge
	    ;;
	tail)
	    tail
	    ;;
	reload_mcf)
	    build_mcf
	    start
	    tail
	    ;;
  *)
    echo "Usage: $0 {build_start|start|reload_mcf|stop|unittests|integrationtests|tail|test|purge}"
esac