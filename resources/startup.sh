#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

# create truststore, which is used in the setenv.sh
create_truststore.sh "${TRUSTSTORE}" > /dev/null

# startup tomcat
"${CATALINA_SH}" run
