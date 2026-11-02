ARG PLANTUML_VERSION=1.2026.9
ARG PLANTUML_TARGZ_SHA256=bbc5ea9c8c86037aa2023be86fff880a8ed8d78e871d3c6c9d10e8f699f9e5e9

ARG TOMCAT_VERSION=10.1.61
ARG TOMCAT_TARGZ_SHA256=a9341c2ed0639896eb0760320c42430a303bef917f83ff3e6f16046f3ae2af79
ARG TOMCAT_NATIVE_VERSION=2.0.16-r0

FROM registry.cloudogu.com/official/java:25.0.5-1 AS builder

ARG PLANTUML_VERSION
ARG PLANTUML_TARGZ_SHA256

RUN set -eux \
 && apk update \
 && apk add --no-cache maven wget
WORKDIR /src
RUN wget https://github.com/plantuml/plantuml-server/archive/refs/tags/v${PLANTUML_VERSION}.tar.gz -O plantuml.tar.gz
RUN echo "${PLANTUML_TARGZ_SHA256} plantuml.tar.gz" | sha256sum -c -
RUN tar xvfz plantuml.tar.gz
RUN cd plantuml-server-${PLANTUML_VERSION} && mvn --batch-mode --define java.net.useSystemProxies=true -Dapache-jsp.scope=compile package

FROM registry.cloudogu.com/official/base:3.24.3-1 AS tomcat

ARG TOMCAT_VERSION
ARG TOMCAT_TARGZ_SHA256

ENV TOMCAT_VERSION=${TOMCAT_VERSION} \
    TOMCAT_TARGZ_SHA256=${TOMCAT_TARGZ_SHA256}

RUN apk add --no-cache wget
RUN wget -O  "apache-tomcat-${TOMCAT_VERSION}.tar.gz" \
  "http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_VERSION%%.*}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"
RUN echo "${TOMCAT_TARGZ_SHA256} *apache-tomcat-${TOMCAT_VERSION}.tar.gz" | sha256sum -c -
RUN gunzip "apache-tomcat-${TOMCAT_VERSION}.tar.gz"
RUN tar xf "apache-tomcat-${TOMCAT_VERSION}.tar" -C /opt
RUN rm "apache-tomcat-${TOMCAT_VERSION}.tar"


FROM registry.cloudogu.com/official/java:25.0.5-1 AS plantuml

LABEL NAME="official/plantuml" \
   VERSION="2026.9-0" \
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

CMD ["/startup.sh"]
