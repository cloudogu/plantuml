#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

sourcingExitCode=0
# shellcheck disable=SC1090
# shellcheck disable=SC1091
source "${STARTUP_DIR}"/logging.sh || sourcingExitCode=$?
if [[ ${sourcingExitCode} -ne 0 ]]; then
  echo "ERROR: An error occurred while sourcing /logging.sh."
fi

runMain() {

  # create truststore, which is used in the setenv.sh
  create_truststore.sh "${TRUSTSTORE}" >/dev/null

  renderLoggingFiles

  # startup tomcat
  "${CATALINA_SH}" run
}

# make the script only run when executed, not when sourced from bats tests)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  runMain
fi
