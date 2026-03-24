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

# Root of the repository
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${REPO_ROOT}"

# Build the binaries locally if they don't exist
# We assume the user has Go installed and can build for linux.
# If they are on another OS, they need to set GOOS=linux.
export GOOS=linux
make binaries crictl-e2e

# Determine architecture for mounting the right binary directory
ARCH=$(go env GOARCH)
BINARY_DIR="${REPO_ROOT}/build/bin/linux/${ARCH}"

# Image name
IMAGE_NAME="containerd-local-test:latest"

# Build the runner image
echo "Building the containerd local test image..."
docker build -t "${IMAGE_NAME}" -f images/containerd-local-test/Dockerfile .

# If no command is provided, default to critest
if [ $# -eq 0 ]; then
    set -- /usr/local/bin/critest-tools/critest --runtime-endpoint=unix:///run/containerd/containerd.sock
fi

# Run the e2e tests in the container
# We mount the local build directory to /usr/local/bin/critest-tools
# so that the container has access to the locally built binaries.
# We also use a volume for containerd's data directory so that
# pulled images are persisted between runs.
echo "Running in the container..."

# Build optional volume mounts that may not exist on all platforms (e.g., macOS)
OPTIONAL_MOUNTS=()
if [ -d "/lib/modules" ]; then
    OPTIONAL_MOUNTS+=(-v "/lib/modules:/lib/modules:ro")
fi
if [ -d "/etc/apparmor.d" ]; then
    OPTIONAL_MOUNTS+=(-v "/etc/apparmor.d:/etc/apparmor.d:ro")
fi

docker run --rm --privileged \
    -e "RUNTIME=${RUNTIME:-io.containerd.runc.v2}" \
    -v "${BINARY_DIR}:/usr/local/bin/critest-tools:ro" \
    -v "containerd-local-test-data:/var/lib/containerd" \
    ${OPTIONAL_MOUNTS[@]+"${OPTIONAL_MOUNTS[@]}"} \
    "${IMAGE_NAME}" \
    "$@"
