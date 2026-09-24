#!/bin/bash

set -euo pipefail

CURRENT_USER=$(whoami)

echo "[+] Running as ${CURRENT_USER}"

#
# Install dependencies
#

sudo apt-get update

sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    git

#
# Install Docker if not present
#

if ! command -v docker >/dev/null 2>&1; then

    echo "[+] Installing Docker"

    curl -fsSL https://get.docker.com | sudo sh

else

    echo "[+] Docker already installed"

fi

#
# Docker permissions
#

sudo groupadd -f docker

sudo usermod -aG docker "${CURRENT_USER}"

#
# Deployment directories
#

sudo mkdir -p /opt/teleport/{config,data}

sudo chown -R "${CURRENT_USER}:${CURRENT_USER}" /opt/teleport

#
# Create compose file
#

cat >/opt/teleport/docker-compose.yml <<'EOF'
services:

  teleport:

    image: public.ecr.aws/gravitational/teleport:18

    container_name: teleport

    restart: unless-stopped

    command:
      - teleport
      - start

    volumes:
      - ./config:/etc/teleport
      - ./data:/var/lib/teleport

    ports:
      - "443:443"
      - "3022:3022"
      - "3023:3023"
      - "3024:3024"
      - "3025:3025"

EOF

echo
echo "=================================================="
echo "Docker installed."
echo
echo "IMPORTANT:"
echo
echo "Log out and back in before continuing."
echo
echo "Then run:"
echo
echo "cd /opt/teleport"
echo "docker compose up -d"
echo
echo "=================================================="
