FROM maven:3.9.6-eclipse-temurin-11

ARG MCF_SOURCE_DIR=/usr/src/manifoldcf

ARG ANT_VERSION=1.10.12
ARG ANT_HOME=/opt/ant

RUN apt-get update && apt-get install -y --no-install-recommends wget openjfx 

RUN wget --no-cookies http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz \
    && wget --no-check-certificate --no-cookies http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz.sha512 \
    && echo "$(cat apache-ant-${ANT_VERSION}-bin.tar.gz.sha512) apache-ant-${ANT_VERSION}-bin.tar.gz" | sha512sum -c \
    && tar -zvxf apache-ant-${ANT_VERSION}-bin.tar.gz -C /opt/ \
    && ln -s /opt/apache-ant-${ANT_VERSION} /opt/ant \
    && rm -f apache-ant-${ANT_VERSION}-bin.tar.gz \
    && rm -f apache-ant-${ANT_VERSION}-bin.tar.gz.sha512 \
    && update-alternatives --install "/usr/bin/ant" "ant" "/opt/ant/bin/ant" 1 \
    && update-alternatives --set "ant" "/opt/ant/bin/ant"

WORKDIR ${MCF_SOURCE_DIR}