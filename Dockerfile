ARG PLANTUML_VERSION=1.2025.2
ARG TOMCAT_MAJOR_VERSION=10
ARG TOMCAT_VERSION=10.1.39
ARG TOMCAT_TARGZ_SHA512=55998c7e906a37340f4b56ca66d4a1ef7c0f7a061a9b868e7ed90cce8188f469495ee590d9971eb8d9870dc34ed89b63d6b870a281cb7e84de14a7555fc100e1

FROM maven:3.8.5-openjdk-11-slim AS builder

ARG PLANTUML_VERSION

ENV PLANTUML_TARGZ_SHA256=45718831c7f6f034443ff383ff8bd88d3bec03cf242047d2a39cbde577ea6eaf

RUN set -eux \
 && apt update \
 && apt install -y wget
WORKDIR /src
RUN wget https://github.com/plantuml/plantuml-server/archive/refs/tags/v${PLANTUML_VERSION}.tar.gz -O plantuml.tar.gz
RUN echo "${PLANTUML_TARGZ_SHA256} plantuml.tar.gz" | sha256sum -c -
RUN tar xvfz plantuml.tar.gz
RUN cd plantuml-server-${PLANTUML_VERSION} && mvn --batch-mode --define java.net.useSystemProxies=true -Dapache-jsp.scope=compile package

FROM registry.cloudogu.com/official/base:3.21.0-1 AS tomcat

ARG TOMCAT_MAJOR_VERSION
ARG TOMCAT_VERSION
ARG TOMCAT_TARGZ_SHA512

ENV TOMCAT_MAJOR_VERSION=${TOMCAT_MAJOR_VERSION} \
    TOMCAT_VERSION=${TOMCAT_VERSION} \
    TOMCAT_TARGZ_SHA256=${TOMCAT_TARGZ_SHA512}

RUN apk update && apk add wget
RUN wget -O  "apache-tomcat-${TOMCAT_VERSION}.tar.gz" \
  "http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"
RUN echo "${TOMCAT_TARGZ_SHA512} *apache-tomcat-${TOMCAT_VERSION}.tar.gz" | sha512sum -c -
RUN gunzip "apache-tomcat-${TOMCAT_VERSION}.tar.gz"
RUN tar xf "apache-tomcat-${TOMCAT_VERSION}.tar" -C /opt
RUN rm "apache-tomcat-${TOMCAT_VERSION}.tar"


FROM registry.cloudogu.com/official/java:21.0.5-1

LABEL NAME="official/plantuml" \
   VERSION="2025.0-2" \
   maintainer="hello@cloudogu.com"

ARG PLANTUML_VERSION
ARG TOMCAT_VERSION

# configure environment
ENV TOMCAT_VERSION=${TOMCAT_VERSION} \
    JAVA_CACERTS=$JAVA_HOME/jre/lib/security/cacerts \
	CATALINA_BASE=/opt/apache-tomcat \
    TRUSTSTORE=/opt/apache-tomcat/truststore.jks \
	CATALINA_PID=/var/run/tomcat10.pid \
	CATALINA_SH=/opt/apache-tomcat/bin/catalina.sh \
	SERVICE_TAGS=webapp \
    BASE_URL=plantuml \
    STARTUP_DIR=/

# run installation
RUN set -o errexit \
 && set -o nounset \
 && set -o pipefail \
 && apk update \
 && apk upgrade \
 && apk add --no-cache graphviz font-dejavu font-noto-cjk tomcat-native jetty-runner \
 # create group and user for plantuml
 && addgroup -S -g 1000 plantuml \
 && adduser -S -h /opt/apache-tomcat -s /bin/bash -G plantuml -u 1000 plantuml

#install tomcat
COPY --from=tomcat --chown=plantuml:plantuml /opt/apache-tomcat-${TOMCAT_VERSION} ${CATALINA_BASE}
COPY --from=builder --chown=plantuml:plantuml /src/plantuml-server-${PLANTUML_VERSION}/target/plantuml.war ${CATALINA_BASE}/webapps/
COPY --chown=plantuml:plantuml resources ${STARTUP_DIR}

USER 1000

EXPOSE 8080

HEALTHCHECK CMD doguctl healthy plantuml || exit 1

CMD "/startup.sh"
