ARG PLANTUML_VERSION=1.2020.4

FROM maven:3.6-jdk-8 AS builder

ARG PLANTUML_VERSION

ENV PLANTUML_TARGZ_SHA256=4ef41b71d51b34dae57b38ac7a452cff7e63dd64eaa04e9246a657e7cccff2b9

RUN set -x \
 && wget https://github.com/plantuml/plantuml-server/archive/v${PLANTUML_VERSION}.tar.gz -O /plantuml.tar.gz \
 && echo "${PLANTUML_TARGZ_SHA256} plantuml.tar.gz" | sha256sum -c - \
 && mkdir /src \
 && cd /src \
 && tar xvfz /plantuml.tar.gz \
 && cd plantuml-server-${PLANTUML_VERSION} \
 && mvn clean package



FROM registry.cloudogu.com/official/java:8u302-1

LABEL NAME="official/plantuml" \
   VERSION="2020.4-2" \
   maintainer="robert.auer@cloudogu.com"

ARG PLANTUML_VERSION

# configure environment
ENV TOMCAT_MAJOR_VERSION=9 \
	TOMCAT_VERSION=9.0.33 \
	CATALINA_BASE=/opt/apache-tomcat \
	CATALINA_PID=/var/run/tomcat7.pid \
	CATALINA_SH=/opt/apache-tomcat/bin/catalina.sh \
	TOMCAT_TARGZ_SHA256=d5cd9463492f4552229295a9a8c00615748f85e9de36434847d495e95b0ef796 \
	SERVICE_TAGS=webapp

# run installation
RUN set -x \
 # install required packages
 && apk add --no-cache graphviz ttf-dejavu font-noto-cjk \
 # create group and user for plantuml
 && addgroup -S -g 1000 plantuml \
 && adduser -S -h /opt/apache-tomcat -s /bin/bash -G plantuml -u 1000 plantuml \
 # install tomcat
 && wget "http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz" \
 && echo "${TOMCAT_TARGZ_SHA256} *apache-tomcat-${TOMCAT_VERSION}.tar.gz" | sha256sum -c - \
 && tar xf apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /opt \
 && mv /opt/apache-tomcat-${TOMCAT_VERSION}/* ${CATALINA_BASE} \
 && rm -rf ${CATALINA_BASE}/webapps/* \
 && chown -R plantuml:plantuml ${CATALINA_BASE}

COPY --from=builder /src/plantuml-server-${PLANTUML_VERSION}/target/plantuml.war ${CATALINA_BASE}/webapps/

COPY resources /

EXPOSE 8080

HEALTHCHECK CMD doguctl healthy plantuml || exit 1

CMD "/startup.sh"
