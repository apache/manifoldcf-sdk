FROM eclipse-temurin:11-jre
LABEL maintainer="The Apache ManifoldCF Project"

ARG MCF_VERSION=${manifoldcf.version}
ARG MCF_USER=manifoldcf
ARG MCF_USER_ID=100001

ARG MCF_GROUP=manifoldcf
ARG MCF_GROUP_ID=100002

ARG APP_DIR=/usr/share/manifoldcf

RUN apt-get update && apt-get install -y iputils-ping && \
	apt-get update && apt-get install -y dnsutils

RUN wget https://dlcdn.apache.org/manifoldcf/apache-manifoldcf-${MCF_VERSION}/apache-manifoldcf-${MCF_VERSION}-bin.tar.gz && \
    tar -xzvf apache-manifoldcf-${MCF_VERSION}-bin.tar.gz && \
    cp -R apache-manifoldcf-${MCF_VERSION} ${APP_DIR} && \
    rm apache-manifoldcf-${MCF_VERSION}-bin.tar.gz

COPY connectors.xml ${APP_DIR}
COPY properties.xml ${APP_DIR}/example
COPY logging.xml ${APP_DIR}/example
COPY extensions/mcf-extensions-jar-${project.version}.jar ${APP_DIR}/connector-lib

RUN set -ex; \
    groupadd -r --gid "$MCF_GROUP_ID" "$MCF_GROUP"; \
    useradd -r --uid "$MCF_USER_ID" --gid "$MCF_GROUP_ID" "$MCF_USER"

RUN chown ${MCF_USER}:${MCF_USER} -R ${APP_DIR}
RUN chmod +x ${APP_DIR}/example/start.sh

USER ${MCF_USER}
WORKDIR ${APP_DIR}/example
CMD ["./start.sh"]