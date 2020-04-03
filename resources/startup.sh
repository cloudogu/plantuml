#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

# adjust webapp permissions
chown -R plantuml:plantuml "${CATALINA_BASE}"/webapps/

# create truststore, which is used in the setenv.sh
create_truststore.sh > /dev/null

# startup tomcat
exec su - plantuml -c "${CATALINA_SH} run"
