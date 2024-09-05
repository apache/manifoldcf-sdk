FROM apache/manifoldcf:2.26
LABEL maintainer="The Apache ManifoldCF Project"

ARG MCF_VERSION=2.27-RC1
ARG MCF_USER=manifoldcf

ARG MCF_GROUP=manifoldcf

ARG APP_DIR=/usr/share/manifoldcf

COPY connectors.xml ${APP_DIR}
COPY properties.xml ${APP_DIR}/example
COPY logging.xml ${APP_DIR}/example
COPY start-options.env.unix ${APP_DIR}/example
COPY extensions/*.jar ${APP_DIR}/connector-lib/

USER ${MCF_USER}