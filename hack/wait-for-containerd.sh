#!/usr/bin/env bash

# Copyright The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail


# This script waits for containerd to be ready by checking its socket or logs.
# It is used by both the local containerized tests and the CI.

CONTD_SOCKET="${CONTD_SOCKET:-/run/containerd/containerd.sock}"
CONTD_LOG="${CONTD_LOG:-/var/log/containerd.log}"
MAX_WAIT="${MAX_WAIT:-30}"
WAIT_COUNT=0

echo "Waiting for containerd to be ready (Socket: ${CONTD_SOCKET}, Log: ${CONTD_LOG})..."

while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
    # Check socket
    if [ -S "${CONTD_SOCKET}" ]; then
        # Double check with logs if possible
        if [ ! -f "${CONTD_LOG}" ] || grep -q 'containerd successfully booted' "${CONTD_LOG}" 2>/dev/null; then
            echo "Containerd is ready."
            exit 0
        fi
    fi
    sleep 1
    WAIT_COUNT=$((WAIT_COUNT + 1))
done

echo "ERROR: Containerd failed to start within ${MAX_WAIT} seconds."
if [ -f "${CONTD_LOG}" ]; then
    echo "--- Containerd Logs ---"
    cat "${CONTD_LOG}"
    echo "--- End of Logs ---"
fi
exit 1
