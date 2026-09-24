#!/bin/bash

set -euo pipefail

#
# Configuration
#

TELEPORT_VERSION="18"
TELEPORT_DOMAIN="teleport.example.com"

INSTALL_DIR="/opt/teleport"
CONFIG_DIR="${INSTALL_DIR}/config"
DATA_DIR="${INSTALL_DIR}/data"

echo "[+] Installing Docker"

apt-get update
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/debian/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update

apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

systemctl enable docker
systemctl start docker

echo "[+] Creating directories"

mkdir -p "${CONFIG_DIR}"
mkdir -p "${DATA_DIR}"

echo "[+] Generating Teleport configuration"

docker run --rm \
  -v "${CONFIG_DIR}:/etc/teleport" \
  public.ecr.aws/gravitational/teleport:${TELEPORT_VERSION} \
  teleport configure \
     --cluster-name="${TELEPORT_DOMAIN}" \
     --public-addr="${TELEPORT_DOMAIN}:443" \
     --roles=auth,proxy,node \
     > "${CONFIG_DIR}/teleport.yaml"

echo "[+] Creating docker-compose.yml"

cat > "${INSTALL_DIR}/docker-compose.yml" <<EOF
services:

  teleport:
    image: public.ecr.aws/gravitational/teleport:${TELEPORT_VERSION}

    container_name: teleport

    restart: unless-stopped

    hostname: ${TELEPORT_DOMAIN}

    command:
      - teleport
      - start
      - --config=/etc/teleport/teleport.yaml

    volumes:
      - ${CONFIG_DIR}:/etc/teleport
      - ${DATA_DIR}:/var/lib/teleport

    ports:
      - "443:443"
      - "3022:3022"
      - "3023:3023"
      - "3024:3024"
      - "3025:3025"
EOF

echo "[+] Starting Teleport"

cd "${INSTALL_DIR}"
docker compose up -d

echo
echo "======================================"
echo "Teleport deployment complete"
echo "======================================"
echo
echo "Check status:"
echo "docker ps"
echo
echo "Logs:"
echo "docker logs -f teleport"
echo
echo "Initial setup:"
echo "docker exec -it teleport tctl users add admin --roles=editor,access"
echo
