#!/bin/bash
set -euo pipefail

LOGS_DIR="${HOME}/workstation_config/logs/"
if [[ ! -d ${LOGS_DIR} ]]; then
	mkdir -p "${LOGS_DIR}"
fi
echo "Action: ${DPKG_HOOK_ACTION}, Package: ${DPKG_MAINTSCRIPT_PACKAGE}" >>"${LOGS_DIR}/package_actions.log"
dpkg --get-selections >"${LOGS_DIR}/package_manifest.txt"
