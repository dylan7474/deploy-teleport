# Teleport Docker Deployment for Debian 13

A simple deployment script for installing and running Teleport Community Edition in Docker on a Debian 13 server.

## Overview

This repository provides an automated deployment process that:

- Installs Docker (if required)
- Adds the current user to the Docker group
- Creates the required Teleport directory structure
- Generates a Docker Compose configuration
- Deploys Teleport in a containerised environment
- Configures automatic restart on host reboot

## Prerequisites

- Debian 13
- User account with sudo privileges
- Internet connectivity
- DNS record pointing to the host (recommended)

## Quick Start

```bash
git clone https://github.com/dylan7474/deploy-teleport.git
cd deploy-teleport
chmod +x deploy.sh
./deploy.sh
```

Log out and back in after installation:

```bash
logout
```

Verify Docker access:

```bash
docker ps
```

Start Teleport:

```bash
cd /opt/teleport
docker compose up -d
```

## Accessing Teleport

### Check Container Status

```bash
docker ps
```

You should see a running container named:

```text
teleport
```

### View Startup Logs

```bash
docker logs -f teleport
```

### Create the First Administrator Account

```bash
docker exec -it teleport tctl users add admin --roles=editor,access
```

Teleport will generate a registration URL.

Example:

```text
https://teleport.example.com/web/invite/xxxxxxxxxxxxxxxx
```

Open the generated URL in a web browser.

### Complete Registration

Follow the wizard to:

- Set a password
- Configure MFA
- Activate the administrator account

### Login to Teleport

Browse to:

```text
https://<server-name>
```

or

```text
https://<server-ip>
```

Examples:

```text
https://teleport.example.com
https://192.168.1.50
```

Log in using the administrator account created above.

## Deployment Structure

```text
/opt/teleport
├── config
├── data
└── docker-compose.yml
```

## Useful Commands

### Start

```bash
docker compose up -d
```

### Stop

```bash
docker compose down
```

### Restart

```bash
docker compose restart
```

### Logs

```bash
docker logs -f teleport
```

### Version

```bash
docker exec -it teleport teleport version
```

## Firewall Requirements

| Port | Purpose |
|------|---------|
| 443 | Web UI / HTTPS |
| 3022 | SSH |
| 3023 | Proxy |
| 3024 | Reverse Tunnel |
| 3025 | Auth Service |

For most deployments only TCP 443 needs to be publicly accessible.

## Updating Teleport

```bash
cd /opt/teleport
docker compose pull
docker compose up -d
```

## Backup

```bash
sudo tar -czvf teleport-backup.tar.gz /opt/teleport
```

## Troubleshooting

Check Docker:

```bash
systemctl status docker
```

Check Teleport:

```bash
docker logs teleport
```

Verify Docker group membership:

```bash
groups
```

## Production Considerations

For production environments consider:

- Trusted TLS certificates
- Entra ID / Azure AD integration
- Session recording
- Centralised logging
- Monitoring and alerting
- Regular backups
- High availability design

## Disclaimer

This deployment is intended as a starter deployment for testing, evaluation and small self-hosted environments.
