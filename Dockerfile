FROM registry.cloudogu.com/official/java:8u171-1
MAINTAINER Sebastian Sdorra <sebastian.sdorra@cloudogu.com>

# configure environment
ENV TOMCAT_MAJOR_VERSION=8 \
	TOMCAT_VERSION=8.0.45 \
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
 && mkdir /opt \
 && curl --fail --silent --location --retry 3 \
 		http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz \
 | gunzip \
 | tar x -C /opt \
 && mv /opt/apache-tomcat-* ${CATALINA_BASE} \
 && rm -rf ${CATALINA_BASE}/webapps/* \
 && chown -R plantuml:plantuml ${CATALINA_BASE}

COPY dist/plantuml.war ${CATALINA_BASE}/webapps/

COPY resources /

EXPOSE 8080

CMD "/startup.sh"
