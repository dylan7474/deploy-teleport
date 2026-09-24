#!/usr/bin/env bash
set -euo pipefail

IMAGE="public.ecr.aws/gravitational/teleport-distroless:18"
CONTAINER_NAME="teleport"
CONFIG_DIR="/etc/teleport"
DATA_DIR="/var/lib/teleport"
CLUSTER_NAME="${CLUSTER_NAME:-teleport.example.com}"

echo "==> Starting Teleport deployment on Debian 13..."

# 1. Install prerequisites and setup Docker APT repository
echo "==> Ensuring system dependencies..."
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release

if ! command -v docker &> /dev/null; then
    echo "==> Docker not detected. Installing Docker Engine..."
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    CODENAME=$(lsb_release -cs 2>/dev/null || ( . /etc/os-release && echo "$VERSION_CODENAME" ))
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian ${CODENAME} stable" \
      | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

# Ensure docker service is running
sudo systemctl enable --now docker

# Add user to docker group if not already present
if ! groups "$USER" | grep &>/dev/null '\bdocker\b'; then
    echo "==> Adding $USER to docker group..."
    sudo usermod -aG docker "$USER"
    echo "Note: Log out and back in to execute docker commands without sudo."
fi

# 2. Prepare host volume directories
echo "==> Preparing host directories..."
sudo mkdir -p "${CONFIG_DIR}" "${DATA_DIR}"

# 3. Pull Teleport v18 container image
echo "==> Pulling image ${IMAGE}..."
sudo docker pull "${IMAGE}"

# 4. Generate default config if missing (override entrypoint to run 'configure')
if [ ! -f "${CONFIG_DIR}/teleport.yaml" ]; then
    echo "==> Generating default Teleport configuration..."
    sudo docker run --rm --entrypoint teleport "${IMAGE}" configure --cluster-name="${CLUSTER_NAME}" | sudo tee "${CONFIG_DIR}/teleport.yaml" > /dev/null
fi

# 5. Clean up existing container instance if present
if sudo docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "==> Cleaning up previous ${CONTAINER_NAME} container..."
    sudo docker stop "${CONTAINER_NAME}" || true
    sudo docker rm "${CONTAINER_NAME}" || true
fi

# 6. Launch Teleport Container (uses default image entrypoint: teleport start)
echo "==> Launching Teleport container..."
sudo docker run -d \
  --name "${CONTAINER_NAME}" \
  --restart unless-stopped \
  --hostname "$(hostname -f)" \
  -v "${CONFIG_DIR}:/etc/teleport" \
  -v "${DATA_DIR}:/var/lib/teleport" \
  -p 443:443 \
  -p 3023:3023 \
  -p 3024:3024 \
  -p 3025:3025 \
  -p 3080:3080 \
  "${IMAGE}"

echo "==> Deployment complete!"
sudo docker ps --filter "name=${CONTAINER_NAME}"
