# Teleport Deployment Guide

This repository contains a deployment script (`deploy.sh`) to automatically install and configure a [Teleport](https://goteleport.com/) v18 instance using the official Distroless Docker image on a fresh Debian 13 system.

## Prerequisites
* A Debian 13 server (or compatible Linux distribution).
* A user account with `sudo` privileges.
* The following ports must be open on your host firewall:
  * **443**: Web UI & HTTPS Proxy
  * **3023**: SSH Proxy
  * **3024**: Reverse Tunnel (for agent connections)
  * **3025**: Auth Service API
  * **3080**: Legacy Web UI / HTTP

## 1. Running the Deployment Script

1. Download or copy the `deploy.sh` script to your server.
2. Make the script executable:
   ```bash
   chmod +x deploy.sh
   ```
3. Run the script:
   ```bash
   ./deploy.sh
   ```
   *Note: If you want to specify a custom domain name for your cluster, you can prefix the command with the `CLUSTER_NAME` environment variable (e.g., `CLUSTER_NAME="teleport.mycompany.com" ./deploy.sh`).*

## 2. Initial Admin Setup

Teleport does not come with a default admin user. Once the container is running, you must create an administrative user and generate an invitation link. 

Run the following `tctl` command via Docker to create a user named `admin` (mapped to the root login):

```bash
sudo docker exec -it teleport tctl users add admin --roles=editor,access --logins=root
```

This command will output a unique URL. **Copy this URL**, as it is required to complete your account setup, set your password, and configure Two-Factor Authentication (2FA).

## 3. Accessing the Application

1. Open a web browser and navigate to the URL generated in the previous step. 
   * *Alternatively, you can access the login page directly via `https://<your-server-ip-or-domain>`.*
2. Because this is a fresh, local deployment without a configured SSL certificate, your browser will display a **Security Warning** (e.g., "Your connection is not private"). 
3. Safely bypass this warning (in Chrome: click "Advanced" -> "Proceed to [IP] (unsafe)") to access the Web UI.
4. Follow the on-screen prompts to register your `admin` user with a password and an authenticator app (like Google Authenticator or Authy).

## Useful Docker Commands

* **View Logs:** `sudo docker logs -f teleport`
* **Stop Teleport:** `sudo docker stop teleport`
* **Start Teleport:** `sudo docker start teleport`
* **Restart Teleport:** `sudo docker restart teleport`

## Next Steps
For production environments, it is highly recommended to configure a valid TLS certificate (e.g., via Let's Encrypt) and point a DNS A-record to your server's IP address. Refer to the [Official Teleport Documentation](https://goteleport.com/docs/) for advanced configuration.
