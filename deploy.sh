#!/bin/bash

set -euo pipefail

#
# Verify sudo access
#

if ! sudo -v; then
    echo "This user requires sudo privileges."
    exit 1
fi

CURRENT_USER=$(whoami)

echo "[+] Running as user: ${CURRENT_USER}"
