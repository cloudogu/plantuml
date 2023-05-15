ARG PLANTUML_VERSION=1.2023.6
ARG TOMCAT_MAJOR_VERSION=10
ARG TOMCAT_VERSION=10.0.16
ARG TOMCAT_TARGZ_SHA256=4931f74f8b564d937a95b8afca43a187b94489c2a1fa4d17551acb6cca2d5051

FROM maven:3.8.5-openjdk-11-slim AS builder

ARG PLANTUML_VERSION

ENV PLANTUML_TARGZ_SHA256=ef2476a1f02305d90ef54bed24c78683e7336d501ebebaac80fe0e62e00ebb96

RUN set -x \
 && apt update \
 && apt install -y wget \
 && wget https://github.com/plantuml/plantuml-server/archive/refs/tags/v${PLANTUML_VERSION}.tar.gz -O /plantuml.tar.gz \
 && echo "${PLANTUML_TARGZ_SHA256} plantuml.tar.gz" | sha256sum -c - \
 && mkdir /src \
 && cd /src \
 && tar xvfz /plantuml.tar.gz \
 && cd plantuml-server-${PLANTUML_VERSION} \
 && mvn --batch-mode --define java.net.useSystemProxies=true -Dapache-jsp.scope=compile package

FROM registry.cloudogu.com/official/base:3.17.3-2 as tomcat

ARG TOMCAT_MAJOR_VERSION
ARG TOMCAT_VERSION
ARG TOMCAT_TARGZ_SHA256

ENV TOMCAT_MAJOR_VERSION=${TOMCAT_MAJOR_VERSION} \
    TOMCAT_VERSION=${TOMCAT_VERSION} \
    TOMCAT_TARGZ_SHA256=${TOMCAT_TARGZ_SHA256}

RUN apk update && apk add wget && wget -O  "apache-tomcat-${TOMCAT_VERSION}.tar.gz" \
  "http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz" \
  && echo "${TOMCAT_TARGZ_SHA256} *apache-tomcat-${TOMCAT_VERSION}.tar.gz" | sha256sum -c - \
  && gunzip "apache-tomcat-${TOMCAT_VERSION}.tar.gz" \
  && tar xf "apache-tomcat-${TOMCAT_VERSION}.tar" -C /opt \
  && rm "apache-tomcat-${TOMCAT_VERSION}.tar"


FROM registry.cloudogu.com/official/java:11.0.18-1

LABEL NAME="official/plantuml" \
   VERSION="2022.4-2" \
   maintainer="hello@cloudogu.com"

ARG PLANTUML_VERSION
ARG TOMCAT_VERSION

# configure environment
ENV TOMCAT_VERSION=${TOMCAT_VERSION} \
    JAVA_CACERTS=$JAVA_HOME/jre/lib/security/cacerts \
	CATALINA_BASE=/opt/apache-tomcat \
	CATALINA_PID=/var/run/tomcat10.pid \
	CATALINA_SH=/opt/apache-tomcat/bin/catalina.sh \
	SERVICE_TAGS=webapp \
    BASE_URL=plantuml

# run installation
RUN set -o errexit \
 && set -o nounset \
 && set -o pipefail \
 && apk update \
 && apk upgrade \
 # install required packages
 && apk add --no-cache graphviz font-dejavu font-noto-cjk tomcat-native jetty-runner \
 # create group and user for plantuml
 && addgroup -S -g 1000 plantuml \
 && adduser -S -h /opt/apache-tomcat -s /bin/bash -G plantuml -u 1000 plantuml

#install tomcat
COPY --from=tomcat /opt/apache-tomcat-${TOMCAT_VERSION} ${CATALINA_BASE}

RUN chown -R plantuml:plantuml ${CATALINA_BASE}

COPY --from=builder /src/plantuml-server-${PLANTUML_VERSION}/target/plantuml.war ${CATALINA_BASE}/webapps/

COPY resources /

EXPOSE 8080

HEALTHCHECK CMD doguctl healthy plantuml || exit 1

CMD "/startup.sh"
