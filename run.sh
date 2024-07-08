#!/bin/sh
mcfversion=$2
mcfdist=$3
mcfdisturl=$4

initLocal() {
	echo "Starting Apache ManifoldCF SDK initialization for version $mcfversion - Init Local"

	mcfversionInFuction=$1
	echo "Init - 1 - MCF version = $1"
	
	mcfdistInFunction=$2
	echo "Init - 2 - MCF DIST URL = $2"
	
	mcfdistTypeInFunction=$3
	echo "Init - 3 - MCF DIST TYPE = $3"

	echo "Updating the ManifoldCF version inside the pom.xml"
	mvn versions:set-property -Dproperty=manifoldcf.version -DnewVersion=$mcfversionInFuction
    
  echo "Creating Docker Volume for the ManifoldCF Maven Repository"
  docker volume create --name mcf-maven-repo
    
  echo "Creating Docker Volume for the ManifoldCF Installation..."
  docker volume create --name mcf-app-volume
    
  echo "Creating simlink for the local MCF source code repository: $mcfdistInFunction"
  mkdir target
  cd target 
  ln -s $mcfdistInFunction mcf-local
  cd ..

  echo "Building the Docker Container for executing Ant and Maven build..."
	docker build src/main/docker-local -t mcf-sdk-init

	echo "Copying local source code into the container..."
	docker run -itd --rm --name mcf-sdk-init-container -v mcf-maven-repo:/root/.m2 -v mcf-app-volume:/usr/src/manifoldcf -t mcf-sdk-init  bash
  docker cp target/mcf-local/. mcf-sdk-init-container:/usr/src/manifoldcf
  docker stop mcf-sdk-init-container
	
	echo "Starting the mcf-sdk-build-container for executing the Maven and Ant building process..."
	docker run -it --rm --name mcf-sdk-init-container -v mcf-maven-repo:/root/.m2 -v mcf-app-volume:/usr/src/manifoldcf -t mcf-sdk-init /bin/bash -c "ant make-core-deps make-deps image; \
	mvn install:install-file -DgroupId=org.apache.manifoldcf -DartifactId=mcf-api-service -Dversion=$mcfversion -Dpackaging=war -Dfile=/usr/src/manifoldcf/dist/web/war/mcf-api-service.war; \
	mvn install:install-file -DgroupId=org.apache.manifoldcf -DartifactId=mcf-authority-service -Dversion=$mcfversion -Dpackaging=war -Dfile=/usr/src/manifoldcf/dist/web/war/mcf-authority-service.war; \
	mvn install:install-file -DgroupId=org.apache.manifoldcf -DartifactId=mcf-combined-service -Dversion=$mcfversion -Dpackaging=war -Dfile=/usr/src/manifoldcf/dist/web/war/mcf-combined-service.war; \
	mvn install:install-file -DgroupId=org.apache.manifoldcf -DartifactId=mcf-crawler-ui -Dversion=$mcfversion -Dpackaging=war -Dfile=/usr/src/manifoldcf/dist/web/war/mcf-crawler-ui.war
	mvn -B -e -T 1C clean install -DskipTests -DskipITs"

	echo "Starting the mcf-sdk-init-container to export the Maven repository in target/mcf-maven-repo..."
	docker run --rm --name mcf-sdk-init-container -itd -v mcf-maven-repo:/root/.m2 -v mcf-app-volume:/usr/src/manifoldcf -t mcf-sdk-init bash
	
	echo "Copying the ManifoldCF Maven Repo in target/mcf-maven-repo..."
	mkdir target
	docker cp mcf-sdk-init-container:/root/.m2/repository target/mcf-maven-repo

	mkdir target/mcf-dist
	echo "Copying the mcf-dist in target/mcf-dist"
	docker cp mcf-sdk-init-container:/usr/src/manifoldcf/dist/apache-manifoldcf-$mcfdistInFunction-dev-bin.tar.gz target/mcf-dist

	tar -xvz target/mcf-dist/apache-manifoldcf-$mcfdistInFunction-dev-bin.tar.gz -C target/mcf-dist
	rm apache-manifoldcf-$mcfdistInFunction-dev-bin.tar.gz
	
	echo "Stopping and removing the existent building container..."
	docker stop mcf-sdk-init-container
	
	#echo "Merging the ManifoldCF Maven Repository with the local Maven Repo"
	#cp -n target/mcf-maven-repo $HOME/.m2
}

init226() {
	echo "Starting Apache ManifoldCF SDK initialization for version $mcfversion - Init 2.26"

	mcfversionInFuction=$1
	echo "Init - 1 - MCF version = $1"

	mcfdistInFunction=$2
	echo "Init - 2 - MCF DIST URL = $2"
	
	mcfdistTypeInFunction=$3
	echo "Init - 3 - MCF DIST TYPE = $3"

	echo "Updating the ManifoldCF version inside the pom.xml"
	mvn versions:set-property -Dproperty=manifoldcf.version -DnewVersion=$mcfversionInFuction
    
  echo "Creating Docker Volume for the ManifoldCF Maven Repository"
  docker volume create --name mcf-maven-repo
    
  echo "Creating Docker Volume for the ManifoldCF Installation..."
  docker volume create --name mcf-app-volume
    
  echo "Building the Docker Container for executing Ant and Maven build..."
	docker build --build-arg MCF_VERSION=$mcfversionInFuction --build-arg MCF_DIST_URL=$mcfdistInFunction src/main/docker -t mcf-sdk-init
	
  
	echo "Starting the mcf-sdk-build-container for executing the Maven and Ant building process..."
	docker run -it --rm --name mcf-sdk-init-container -v mcf-maven-repo:/root/.m2 -v mcf-app-volume:/usr/src/manifoldcf -t mcf-sdk-init /bin/bash -c "sed -i -e 's/<fileset dir=\"test-materials\" excludes/<fileset dir=\"test-materials\" erroronmissingdir=\"false\" excludes/g' connectors/solr/build.xml; \
	sed -i -e 's/<?xml version=\"1\.0\" encoding=\"UTF-8\"?>/ /g' connectors/csv/pom.xml; \
	sed -i -e 's/https\:\/\/maven.nuxeo.org\/nexus\/content\/repositories\/public-releases/https\:\/\/packages.nuxeo.com\/repository\/maven-public-archives/g' build.xml; \
	sed -i -e 's/https\:\/\/maven.nuxeo.org\/nexus\/content\/repositories\/public-releases\//https\:\/\/packages.nuxeo.com\/repository\/maven-public-archives/g' connectors/nuxeo/pom.xml; \
	sed -i -e 's/<\/dependencies>/<dependency><groupId>org.apache.hadoop<\/groupId><artifactId>hadoop-annotations<\/artifactId><version>\${hadoop.version}<\/version><exclusions><exclusion><groupId>jdk.tools<\/groupId><artifactId>jdk.tools<\/artifactId><\/exclusion><\/exclusions><\/dependency><\/dependencies>/g' connectors/hdfs/pom.xml
	ant make-core-deps make-deps build; \
	mvn install:install-file -DgroupId=org.apache.manifoldcf -DartifactId=mcf-api-service -Dversion=$mcfversion -Dpackaging=war -Dfile=/usr/src/manifoldcf/dist/web/war/mcf-api-service.war; \
	mvn install:install-file -DgroupId=org.apache.manifoldcf -DartifactId=mcf-authority-service -Dversion=$mcfversion -Dpackaging=war -Dfile=/usr/src/manifoldcf/dist/web/war/mcf-authority-service.war; \
	mvn install:install-file -DgroupId=org.apache.manifoldcf -DartifactId=mcf-combined-service -Dversion=$mcfversion -Dpackaging=war -Dfile=/usr/src/manifoldcf/dist/web/war/mcf-combined-service.war; \
	mvn install:install-file -DgroupId=org.apache.manifoldcf -DartifactId=mcf-crawler-ui -Dversion=$mcfversion -Dpackaging=war -Dfile=/usr/src/manifoldcf/dist/web/war/mcf-crawler-ui.war
	mvn -B -e -T 1C clean install -DskipTests -DskipITs"
  
	echo "Starting the mcf-sdk-init-container to export the Maven repository in target/mcf-maven-repo..."
	docker run --rm --name mcf-sdk-init-container -itd -v mcf-maven-repo:/root/.m2 -v mcf-app-volume:/usr/src/manifoldcf -t mcf-sdk-init bash
	
	echo "Copying the ManifoldCF Maven Repo in target/mcf-maven-repo..."
	mkdir target
	docker cp mcf-sdk-init-container:/root/.m2/repository target/mcf-maven-repo
	
	echo "Stopping and removing the existent building container..."
	docker stop mcf-sdk-init-container
	
	#echo "Merging the ManifoldCF Maven Repository with the local Maven Repo"
	#cp -n target/mcf-maven-repo $HOME/.m2
}

init() {
	echo "Starting Apache ManifoldCF SDK initialization for version $mcfversion - Init"

	mcfversionInFuction=$1
	echo "Init - 1 - MCF version = $1"

	mcfdistInFunction=$2
	echo "Init - 2 - MCF DIST URL = $2"
	
	mcfdistTypeInFunction=$3
	echo "Init - 3 - MCF DIST TYPE = $3"

	echo "Updating the ManifoldCF version inside the pom.xml"
	mvn versions:set-property -Dproperty=manifoldcf.version -DnewVersion=$mcfversionInFuction
    
  echo "Creating Docker Volume for the ManifoldCF Maven Repository"
  docker volume create --name mcf-maven-repo
    
  echo "Creating Docker Volume for the ManifoldCF Installation..."
  docker volume create --name mcf-app-volume
    
  echo "Building the Docker Container for executing Ant and Maven build..."
	docker build --build-arg MCF_VERSION=$mcfversionInFuction --build-arg MCF_DIST_URL=$mcfdistInFunction src/main/docker -t mcf-sdk-init
	
	echo "Starting the mcf-sdk-build-container for executing the Maven and Ant building process..."
	docker run -it --rm --name mcf-sdk-init-container -v mcf-maven-repo:/root/.m2 -v mcf-app-volume:/usr/src/manifoldcf -t mcf-sdk-init /bin/bash -c "ant make-core-deps make-deps build; \
	mvn install:install-file -DgroupId=org.apache.manifoldcf -DartifactId=mcf-api-service -Dversion=$mcfversion -Dpackaging=war -Dfile=/usr/src/manifoldcf/dist/web/war/mcf-api-service.war; \
	mvn install:install-file -DgroupId=org.apache.manifoldcf -DartifactId=mcf-authority-service -Dversion=$mcfversion -Dpackaging=war -Dfile=/usr/src/manifoldcf/dist/web/war/mcf-authority-service.war; \
	mvn install:install-file -DgroupId=org.apache.manifoldcf -DartifactId=mcf-combined-service -Dversion=$mcfversion -Dpackaging=war -Dfile=/usr/src/manifoldcf/dist/web/war/mcf-combined-service.war; \
	mvn install:install-file -DgroupId=org.apache.manifoldcf -DartifactId=mcf-crawler-ui -Dversion=$mcfversion -Dpackaging=war -Dfile=/usr/src/manifoldcf/dist/web/war/mcf-crawler-ui.war
	mvn -B -e -T 1C clean install -DskipTests -DskipITs"
  

	echo "Starting the mcf-sdk-init-container to export the Maven repository in target/mcf-maven-repo..."
	docker run --rm --name mcf-sdk-init-container -itd -v mcf-maven-repo:/root/.m2 -v mcf-app-volume:/usr/src/manifoldcf -t mcf-sdk-init bash
	
	echo "Copying the ManifoldCF Maven Repo in target/mcf-maven-repo..."
	mkdir target
	docker cp mcf-sdk-init-container:/root/.m2/repository target/mcf-maven-repo
	
	echo "Stopping and removing the existent building container..."
	docker stop mcf-sdk-init-container
	
	#echo "Merging the ManifoldCF Maven Repository with the local Maven Repo"
	#cp -n target/mcf-maven-repo $HOME/.m2
}



build_start() {
	echo "Building with Maven skipping tests and run Docker containers"
	mvn clean install docker:build docker:start -DskipTests -DskipITs
}

build_start_local() {
	echo "Building with Maven skipping tests and run Docker containers"
	mkdir target/mcf-dist
	cp -R target/mcf-local/dist/. target/mcf-dist
	mvn clean install docker:build docker:start -DskipTests -DskipITs -Plocal
}

build() {
	echo "Building with Maven skipping tests"
	mvn clean install -DskipTests -DskipITs
}

build_local() {
	echo "Building with Maven skipping tests"
	mvn clean install -DskipTests -DskipITs -Plocal
}

build_test() {
	echo "Building with Maven executing tests"
	mvn clean install
}

build_test_local() {
	echo "Building with Maven executing tests"
	mvn clean install -Plocal
}

unittests() {
	echo "Executing unit tests"
	mvn clean test
}

integrationtests() {
	echo "Executing integration tests"
	mvn clean integration-test
}

integrationtests_local() {
	echo "Executing integration tests"
	mvn clean integration-test -Plocal
}

start() {
	echo "Run ManifoldCF Docker containers"
	mvn docker:start
}

start_local() {
	echo "Run ManifoldCF Docker containers"
	mvn docker:start -Plocal
}

stop() {
	echo "Stop ManifoldCF Docker containers"
	mvn docker:stop
}

stop_local() {
	echo "Stop ManifoldCF Docker containers"
	mvn docker:stop -Plocal
}

test() {
	echo "Starting the mcf-sdk-test-container to execute unit and integration tests"
	docker run -it --rm -v mcf-maven-repo:/root/.m2 -v mcf-app-volume:/usr/src/manifoldcf -t mcf-sdk-init ant test
}

clean() {
	echo "Starting the mcf-sdk-clean-container to clean the project"
	docker run -it --rm -v mcf-maven-repo:/root/.m2 -v mcf-app-volume:/usr/src/manifoldcf -t mcf-sdk-init ant clean; mvn clean
}

purge() {
	echo "Removing the ManifoldCF Maven repo and installation volumes"
	docker volume rm mcf-maven-repo
  docker volume rm mcf-app-volume
  docker image rm mcf-sdk-init
}

case "$1" in
  init)
    if [ ! -n "$mcfversion" ] && [ "$mcfdist" != "local" ];
	then
	    echo "$0 - Error ManifoldCF version is not set. Usage for using ManifoldCF 2.26: $0 init 2.26 ga or $0 init 2.27 rc"
	    exit 1
	else
	    echo "ManifoldCF version is correctly set"
	fi
	if [ ! -n "$mcfdist" ];
	then
	    echo "$0 - Error ManifoldCF release type is not set, it should be ga or rc. Usage for using ManifoldCF 2.21: $0 init 2.21 ga or $0 init 2.21 rc or $0 init local YOUR_LOCAL_PATH"
	    exit 1
	else
	    echo "ManifoldCF release type is correctly set and now starting Apache ManifoldCF SDK initialization script..."
	fi

	if [ "$mcfdist" -eq "ga" ];
		then
		mcfdisturl="https://dlcdn.apache.org/manifoldcf"
		echo "Building a GA release with artifact base URL: $mcfdisturl"
	elif [ "$mcfdist" -eq "rc" ];
		then
		mcfdisturl="https://dist.apache.org/repos/dist/dev/manifoldcf"
		echo "Building a RC release with artifact base URL: $mcfdisturl"
	elif [ "$mcfdist" -eq "local" ];
		then
		echo "Building a local build: $mcfdisturl"
	fi

	if [ "$mcfdist"=="ga" ] && [ "$mcfversion" -eq "2.26" ];
    then
    	echo "mcfversion=$mcfversion | mcfdisturl: $mcfdisturl | mcfdist: $mcfdist"
    	init226 $mcfversion $mcfdisturl $mcfdist
  elif [ "$mcfdist"=="local" ];
  	then
  		echo "mcfversion=$mcfversion | mcfdisturl: $mcfdisturl | mcfdist: $mcfdist"
  		initLocal $mcfversion $mcfdisturl $mcfdist
  else
  	 echo "mcfversion=$mcfversion | mcfdisturl: $mcfdisturl | mcfdist: $mcfdist"
  	 init $mcfversion $mcfdisturl $mcfdist
  fi
    ;;
  clean)
    clean
    ;;
  build_start)
		build_start
		;;
	build_start_local)
		build_start_local
		;;
	start)
		start
		;;
	start_local)
		start_local
		;;
	stop)
		stop
		;;
	stop_local)
		stop_local
		;;
	unittests)
		unittests
		;;
	integrationtests)
		integrationtests
		;;
	integrationtests_local)
		integrationtests_local
		;;
  test)
    test
    ;;
  purge)
    purge
    ;;
  *)
    echo "Usage: $0 {init|clean|build_start|build_start_local|start|start_local|stop|stop_local|unittests|integrationtests|integrationtests_local|test|purge}"
esac