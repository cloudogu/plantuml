ARG PLANTUML_VERSION=1.2026.2
ARG PLANTUML_TARGZ_SHA256=a2d26b1c65d67de5cad270804b6ebefb156817242446ab895dcdb04a6f4faa92

ARG TOMCAT_MAJOR_VERSION=10
ARG TOMCAT_VERSION=10.1.50
ARG TOMCAT_TARGZ_SHA256=f74f9f1a7ac2cf6eeede2c50f45088d9c3e55f77d5777f9f7033ed3d43ef529c
ARG TOMCAT_NATIVE_VERSION=2.0.8-r0

FROM maven:3.9.9-eclipse-temurin-11 AS builder

ARG PLANTUML_VERSION
ARG PLANTUML_TARGZ_SHA256

RUN set -eux \
 && apt-get update \
 && apt-get install -y wget
WORKDIR /src
RUN wget https://github.com/plantuml/plantuml-server/archive/refs/tags/v${PLANTUML_VERSION}.tar.gz -O plantuml.tar.gz
RUN echo "${PLANTUML_TARGZ_SHA256} plantuml.tar.gz" | sha256sum -c -
RUN tar xvfz plantuml.tar.gz
RUN cd plantuml-server-${PLANTUML_VERSION} && mvn --batch-mode --define java.net.useSystemProxies=true -Dapache-jsp.scope=compile package

FROM registry.cloudogu.com/official/base:3.23.3-4 AS tomcat

ARG TOMCAT_MAJOR_VERSION
ARG TOMCAT_VERSION
ARG TOMCAT_TARGZ_SHA256

ENV TOMCAT_MAJOR_VERSION=${TOMCAT_MAJOR_VERSION} \
    TOMCAT_VERSION=${TOMCAT_VERSION} \
    TOMCAT_TARGZ_SHA256=${TOMCAT_TARGZ_SHA256}

RUN apk add --no-cache wget
RUN wget -O  "apache-tomcat-${TOMCAT_VERSION}.tar.gz" \
  "http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"
RUN echo "${TOMCAT_TARGZ_SHA256} *apache-tomcat-${TOMCAT_VERSION}.tar.gz" | sha256sum -c -
RUN gunzip "apache-tomcat-${TOMCAT_VERSION}.tar.gz"
RUN tar xf "apache-tomcat-${TOMCAT_VERSION}.tar" -C /opt
RUN rm "apache-tomcat-${TOMCAT_VERSION}.tar"


FROM registry.cloudogu.com/official/java:21.0.10-4

LABEL NAME="official/plantuml" \
   VERSION="2025.10-6" \
   maintainer="hello@cloudogu.com"

ARG PLANTUML_VERSION
ARG TOMCAT_VERSION
ARG TOMCAT_NATIVE_VERSION

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
RUN apk update \
 && apk upgrade \
 && apk add graphviz font-dejavu font-noto-cjk tomcat-native=${TOMCAT_NATIVE_VERSION} jetty-runner \
 && rm -rf /var/cache/apk/*

# create group and user for plantuml
RUN addgroup -S -g 1000 plantuml \
 && adduser -S -h /opt/apache-tomcat -s /bin/bash -G plantuml -u 1000 plantuml

# install tomcat
COPY --from=tomcat --chown=plantuml:plantuml /opt/apache-tomcat-${TOMCAT_VERSION} ${CATALINA_BASE}
COPY --from=builder --chown=plantuml:plantuml /src/plantuml-server-${PLANTUML_VERSION}/target/plantuml.war ${CATALINA_BASE}/webapps/
COPY --chown=plantuml:plantuml resources ${STARTUP_DIR}

USER 1000

EXPOSE 8080

HEALTHCHECK CMD doguctl healthy plantuml || exit 1

CMD "/startup.sh"
