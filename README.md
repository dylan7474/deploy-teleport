# Teleport Docker Deployment for Debian 13

This repository provides a simple deployment script for installing and running Teleport Community Edition in Docker on a Debian 13 host.

The script is intended for:

- Home labs
- Test environments
- Proof of concepts
- Small self-hosted deployments

The deployment:

- Installs Docker (if required)
- Grants the local user access to Docker
- Creates a Teleport deployment directory structure
- Generates a Docker Compose configuration
- Deploys Teleport as a container
- Configures automatic restart after host reboot

---

# Prerequisites

Before running the installer ensure:

- Debian 13 is installed and updated
- The local user has sudo privileges
- Internet access is available
- A DNS name has been created for the Teleport server (recommended)

Example:

```text
teleport.company.local
teleport.example.com
```

---

# Installation

Clone the repository:

```bash
git clone https://github.com/dylan7474/deploy-teleport.git

cd deploy-teleport
```

Make the script executable:

```bash
chmod +x deploy.sh
```

Run the installer:

```bash
./deploy.sh
```

---

# Docker Permissions

The script adds the current user to the Docker group.

After installation either:

```bash
logout
```

and log back in,

or reboot the server:

```bash
sudo reboot
```

Verify Docker access:

```bash
docker ps
```

No sudo should be required.

---

# Deployment Structure

The deployment creates:

```text
/opt/teleport
├── config
├── data
└── docker-compose.yml
```

Configuration:

```text
/opt/teleport/config
```

Persistent Teleport data:

```text
/opt/teleport/data
```

---

# Starting Teleport

Start the deployment:

```bash
cd /opt/teleport

docker compose up -d
```

Check status:

```bash
docker ps
```

View logs:

```bash
docker logs -f teleport
```

---

# Stopping Teleport

Stop the container:

```bash
docker compose down
```

Restart:

```bash
docker compose restart
```

---

# Updating Teleport

Pull the latest image:

```bash
docker compose pull
```

Restart the service:

```bash
docker compose up -d
```

---

# Initial Administrative User

Create an administrative user:

```bash
docker exec -it teleport tctl users add admin
```

Teleport will display a registration URL.

Open the URL in a browser and complete:

- Password setup
- MFA registration
- Initial login

---

# Useful Commands

Container status:

```bash
docker ps
```

Container logs:

```bash
docker logs -f teleport
```

Open a shell inside the container:

```bash
docker exec -it teleport /bin/sh
```

Check Teleport version:

```bash
docker exec -it teleport teleport version
```

---

# Backups

Back up the deployment directory:

```bash
sudo tar -czvf teleport-backup.tar.gz /opt/teleport
```

To restore:

```bash
sudo tar -xzvf teleport-backup.tar.gz -C /
```

---

# Uninstall

Stop Teleport:

```bash
cd /opt/teleport

docker compose down
```

Remove deployment files:

```bash
sudo rm -rf /opt/teleport
```

Remove Docker (optional):

```bash
sudo apt remove docker-ce docker-ce-cli containerd.io
```

---

# Security Notes

This deployment is intended as a starter configuration.

For production environments consider:

- Valid TLS certificates
- Entra ID / Azure AD SSO
- Regular backups
- Session recording
- External database backend
- High availability deployment
- Reverse proxy hardening
- Centralised logging and monitoring

---

# Disclaimer

This deployment script is provided as-is for learning, testing and small deployments. Production environments should be reviewed and hardened according to organisational security requirements.
