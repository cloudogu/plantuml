ARG PLANTUML_VERSION=1.2020.4

FROM maven:3.3-jdk-8 AS builder

ARG PLANTUML_VERSION

RUN set -x \
 && wget https://github.com/plantuml/plantuml-server/archive/v${PLANTUML_VERSION}.tar.gz -O /plantuml.tar.gz \
 && mkdir /src \
 && cd /src \
 && tar xvfz /plantuml.tar.gz \
 && cd plantuml-server-${PLANTUML_VERSION} \
 && mvn clean package



FROM registry.cloudogu.com/official/java:8u171-1

LABEL NAME="official/plantuml" \
   VERSION="2020.4-1" \
   maintainer="robert.auer@cloudogu.com"

ARG PLANTUML_VERSION

# configure environment
ENV TOMCAT_MAJOR_VERSION=8 \
	TOMCAT_VERSION=8.5.37 \
	CATALINA_BASE=/opt/apache-tomcat \
	CATALINA_PID=/var/run/tomcat7.pid \
	CATALINA_SH=/opt/apache-tomcat/bin/catalina.sh \
	SERVICE_TAGS=webapp

# run installation
RUN set -x \
 # install required packages
 && apk add --no-cache graphviz ttf-dejavu \
 # create group and user for plantuml
 && addgroup -S -g 1000 plantuml \
 && adduser -S -h /opt/apache-tomcat -s /bin/bash -G plantuml -u 1000 plantuml \
 # install tomcat
 && mkdir -p /opt \
 && curl --fail --silent --location --retry 3 \
 		http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz \
 | gunzip \
 | tar x -C /opt \
 && mv /opt/apache-tomcat-* ${CATALINA_BASE} \
 && rm -rf ${CATALINA_BASE}/webapps/* \
 && chown -R plantuml:plantuml ${CATALINA_BASE}

COPY --from=builder /src/plantuml-server-${PLANTUML_VERSION}/target/plantuml.war ${CATALINA_BASE}/webapps/

COPY resources /

EXPOSE 8080

HEALTHCHECK CMD doguctl healthy plantuml || exit 1

CMD "/startup.sh"
