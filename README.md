# Apache ManifoldCF SDK 0.0.5
This is the SDK project of Apache ManifoldCF dedicated to developers that need to extend the platform with new components, connectors or integrations using Maven and Docker. On the other hand this SDK can be extremely useful also for all the developers who want to contribute to the ManifoldCF project.
This project has started with an initial contribution by @OpenPj and @binduwavell.

The SDK will take care of the following tasks:
* Creating custom containers using the official ManifoldCF Docker Images
* Creating the Docker Volumes for the MCF Maven Repo and the MCF installation
* Preparing the Docker Image for executing the build installing Ant and Maven
* Running the container for executing the building process with Ant and then with Maven
* Copying the entire Maven Repo in the Maven target folder in the host machine (locally)
* Generating the MCF official site

ManifoldCF SDK is using the ManifoldCF Docker repository:
[https://hub.docker.com/r/apache/manifoldcf](https://hub.docker.com/r/apache/manifoldcf)

What's new in v0.0.5
* The Maven profile `docker-hub` now is enabled by default
* MCF SDK now by default is building the image from the official Docker images
* Added a debug port (5005) for accelerate connectors development with remote debugging
* Default Maven dependencies version now is 2.27-SNAPSHOT (publicly available)

If you need to build your custom Docker image using dependencies built from the MCF source code and stored in the target folder (using the `init` script mentioned below), please use the `local` Maven profile.

Examples of commands using the main bash script for a typical usage:
* `./run.sh init 2.26 ga` -> start the init process for ManifoldCF 2.26 GA
* `./run.sh init custom-version local /<USER_HOME>/Documents/workspaces/manifoldcf/custom-project` -> start the init process for a custom ManifoldCF project
* `./run.sh build_start` -> build extensions and run everything with Docker locally using an official ManifoldCF distribution
* `./run.sh build_start_local` -> build extensions and run everything with Docker locally using a custom local ManifoldCF source code repository
* `./run.sh start` -> start all the containers (MCF dist and PostgreSQL)
* `./run.sh stop` -> stop all the containers (MCF dist and PostgreSQL)
* `./run.sh start_local` -> start all the containers (custom MCF project and PostgreSQL)
* `./run.sh stop_local` -> stop all the containers (custom MCF project and PostgreSQL)

Examples of commands for developing and testing MCF itself:
* `./run.sh init 2.22.1 rc` -> start the init process for ManifoldCF 2.22.1 RC
* `./run.sh test` -> execute unit and integration tests in the MCF source bundle
* `./run.sh clean` -> execute ant clean; mvn clean in the MCF source bundle
* `./run.sh purge` -> removes all the Docker Volumes and the MCF init container

Examples of commands for generating the MCF website contents:
* `./run-site.sh build` -> Start Apache ManifoldCF SDK initialization for generating website contents
* `./run-site.sh start` -> Run ManifoldCF Site Docker container
* `./run-site.sh purge` -> Remove the ManifoldCF Site Docker artifacts and volumes
* `./run-site.sh clean` -> Start the mcf-sdk-site in order to clean the project
* `./run-site.sh stop` -> Stop the mcf-sdk-site

# Initializing the local Maven repository using Docker (optional)
In order to compile extensions with Maven, the SDK provides an initialization script that will download the source code of ManifoldCF and then build it in the container. At the end of the build process the Maven repository included in the container will be copied in the local folder `target/mcf-maven-repo`. The local Maven repo will be used as the main reference for compiling the extension code.

The initialization command consists of the following arguments:
* MCF version
* MCF distribution: ga for GA release and rc for a Release Candidate

Example for initializing ManifoldCF 2.26 GA release:
* `./run.sh init 2.26 ga`

Example for initializing ManifoldCF 2.27.1 RC release:
* `./run.sh init 2.27.1 rc`

The initialization process will be executed with the following command:
* `/run.sh init 2.21 ga`

# Building extensions, overlaying and run Docker
A Dockerfile and a Docker Compose file is provided in order to build the ManifoldCF container and for running the instance with its own database, a PostgreSQL container.

The following command will take care of building extensions, run tests and building and running the ManifoldCF container
* `./run.sh build_start`

To stop all the containers:
* `./run.sh stop`

# Executing tests in the container
For running MCF tests related to the source code bundle:
* `./run.sh test` -> execute unit and integration tests for the related MCF version initialized in the Docker Volumes

# Docker images, containers and volumes
The Docker images, containers and volumes managed by ManifoldCF SDK are the following:

## run.sh (.bat)

The Docker image created with for creating the ManifoldCF installation and Maven repo is `mcf-sdk-init`.
The Docker container built by the SDK in order to create the installation folder and the Maven repo is `mcf-sdk-init-container`.

### Containers & Images

* `mcf-sdk-init` -> image created with for creating the ManifoldCF installation
* `mcf-sdk-init-container` -> container built by the SDK in order to create the installation folder and the Maven repo 

### Volumes
* `mcf-maven-repo` -> this volume contains the Maven repo created by the initialization process
* `mcf-app-volume` -> this volume contains the installation storage of ManifoldCF

## run-site.sh (.bat)

### Containers & Images

* `mcf-sdk-site` -> image created with specific version of Apache Ant 1.9.x, Python 2.7.x and OpenJDK 8
* `mcf-sdk-site` -> container running the generation process of the website contents

### Volumes
* `mcf-site-source` -> this volume contains the site trunk code
* `mcf-site-generated-volume` -> this volume contains the generated site

