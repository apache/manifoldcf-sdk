FROM apache/manifoldcf:${manifoldcf.version}
LABEL maintainer="The Apache ManifoldCF Project"

ARG MCF_USER=manifoldcf
ARG MCF_GROUP=manifoldcf
ARG APP_DIR=/usr/share/manifoldcf

COPY connectors.xml ${APP_DIR}
COPY properties.xml ${APP_DIR}/example
COPY logging.xml ${APP_DIR}/example
COPY start-options.env.unix ${APP_DIR}/example
COPY extensions/*.jar ${APP_DIR}/connector-lib/

USER ${MCF_USER}