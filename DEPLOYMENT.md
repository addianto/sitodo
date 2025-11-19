# Sitodo Deployment Guide

This guide explains how to deploy the Sitodo application as a systemd service on a Linux VM.

## Prerequisites

- A Linux VM (Ubuntu, Debian, CentOS, RHEL, etc.)
- Root/sudo access
- Java 17 or later installed
- systemd (standard on modern Linux distributions)

## Quick Start

1. Build the application:
   ```bash
   mvn clean package -DskipTests
   ```

2. Transfer the JAR file and deployment script to your VM:
   ```bash
   scp target/sitodo-*.jar deploy.sh user@your-vm:/tmp/
   ```

3. On the VM, run the deployment script:
   ```bash
   sudo ./deploy.sh /tmp/sitodo-*.jar
   ```

That's it! The application will be installed and running as a systemd service.

## What the Deployment Script Does

The `deploy.sh` script automates the entire deployment process:

### 1. Service User Creation
- Creates a dedicated `app` user and group if they don't exist
- User is configured with:
  - Shell: `/sbin/nologin` (no interactive login)
  - Home directory: `/opt/sitodo`
  - System account (for security)

### 2. Directory Structure
Creates and configures the following directories:

```
/opt/sitodo/
├── bin/           # Application JAR file
├── config/        # Configuration files (app.env)
└── data/          # Application data (H2 database by default)

/var/log/sitodo/   # Application logs
```

All directories are owned by `app:app` with `750` permissions (rwxr-x---).

### 3. Environment Configuration
- Creates a default `app.env` file at `/opt/sitodo/config/app.env` if it doesn't exist
- This file contains environment variables for:
  - Server port
  - Database configuration
  - Logging settings
  - Spring profiles

### 4. Deployment Process
The script follows these steps:
1. **Stop** the existing service (if running)
2. **Backup** the current JAR file with timestamp
3. **Copy** the new JAR file to `/opt/sitodo/bin/`
4. **Update** file permissions and ownership
5. **Generate** systemd service unit file
6. **Reload** systemd daemon
7. **Enable** service to start on boot
8. **Start** the service
9. **Verify** the service is running and responding

### 5. Systemd Service Configuration

The service is configured with:
- **User/Group**: `app:app`
- **ExecStart**: `/usr/bin/java -jar /opt/sitodo/bin/sitodo.jar`
- **SuccessExitStatus**: `143` (handles Java SIGTERM gracefully)
- **Restart**: `always` (automatic restart on failure)
- **RestartSec**: `10` seconds between restart attempts
- **Environment**: Loads from `/opt/sitodo/config/app.env`
- **Security**: `NoNewPrivileges=true`, `PrivateTmp=true`

## Configuration

### Environment Variables

Edit `/opt/sitodo/config/app.env` to customize the application:

```bash
# Server configuration
SERVER_PORT=8080

# Database (example for PostgreSQL)
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/sitodo
SPRING_DATASOURCE_USERNAME=sitodo_user
SPRING_DATASOURCE_PASSWORD=secure_password

# Logging
LOGGING_LEVEL_ROOT=INFO
LOGGING_FILE_NAME=/var/log/sitodo/application.log

# Profile
SPRING_PROFILES_ACTIVE=production
```

After editing, restart the service:
```bash
sudo systemctl restart sitodo
```

### Java Options

To customize JVM options (memory, GC, etc.), edit the service file:
```bash
sudo nano /etc/systemd/system/sitodo.service
```

Modify the `ExecStart` line, for example:
```ini
ExecStart=/usr/bin/java -Xmx512m -Xms256m -jar /opt/sitodo/bin/sitodo.jar
```

Then reload and restart:
```bash
sudo systemctl daemon-reload
sudo systemctl restart sitodo
```

## Managing the Service

### Check Service Status
```bash
sudo systemctl status sitodo
```

### Start the Service
```bash
sudo systemctl start sitodo
```

### Stop the Service
```bash
sudo systemctl stop sitodo
```

### Restart the Service
```bash
sudo systemctl restart sitodo
```

### Enable/Disable Auto-start on Boot
```bash
sudo systemctl enable sitodo   # Enable
sudo systemctl disable sitodo  # Disable
```

### View Logs

**Real-time logs:**
```bash
sudo journalctl -u sitodo -f
```

**Last 100 lines:**
```bash
sudo journalctl -u sitodo -n 100
```

**Logs since today:**
```bash
sudo journalctl -u sitodo --since today
```

**Application log file:**
```bash
sudo tail -f /var/log/sitodo/application.log
```

## Redeployment

To deploy a new version of the application:

1. Build the new version:
   ```bash
   mvn clean package -DskipTests
   ```

2. Transfer to the VM:
   ```bash
   scp target/sitodo-*.jar user@your-vm:/tmp/
   ```

3. Run the deployment script again:
   ```bash
   sudo ./deploy.sh /tmp/sitodo-*.jar
   ```

The script will:
- Stop the service
- Back up the old JAR
- Deploy the new JAR
- Restart the service

Old versions are backed up in `/opt/sitodo/bin/` with timestamp suffixes (e.g., `sitodo.jar.20240101_120000.bak`).

## Rollback

If you need to rollback to a previous version:

1. Stop the service:
   ```bash
   sudo systemctl stop sitodo
   ```

2. Restore the backup:
   ```bash
   cd /opt/sitodo/bin
   sudo cp sitodo.jar.YYYYMMDD_HHMMSS.bak sitodo.jar
   sudo chown app:app sitodo.jar
   ```

3. Start the service:
   ```bash
   sudo systemctl start sitodo
   ```

## Troubleshooting

### Service won't start

Check the logs:
```bash
sudo journalctl -u sitodo -n 100
```

Common issues:
- Port 8080 already in use: Change `SERVER_PORT` in `app.env`
- Database connection failed: Check database settings in `app.env`
- Insufficient memory: Adjust JVM memory settings in service file

### Permission errors

Ensure proper ownership:
```bash
sudo chown -R app:app /opt/sitodo
sudo chown -R app:app /var/log/sitodo
```

### Application not responding

Check if the service is running:
```bash
sudo systemctl status sitodo
```

Check if the port is listening:
```bash
sudo netstat -tlnp | grep 8080
# or
sudo ss -tlnp | grep 8080
```

Test the application:
```bash
curl http://localhost:8080/
```

## Security Considerations

1. **Service User**: The application runs as a non-privileged `app` user with no shell access
2. **File Permissions**: Application directories use `750` permissions (owner and group only)
3. **Secrets Management**: Database credentials and sensitive data go in `/opt/sitodo/config/app.env` with `640` permissions
4. **Systemd Security**: Service uses `NoNewPrivileges` and `PrivateTmp` for additional hardening
5. **Firewall**: Configure your firewall to restrict access:
   ```bash
   sudo ufw allow 8080/tcp  # Ubuntu/Debian
   sudo firewall-cmd --add-port=8080/tcp --permanent  # CentOS/RHEL
   ```

## Uninstallation

To completely remove the application:

```bash
# Stop and disable the service
sudo systemctl stop sitodo
sudo systemctl disable sitodo

# Remove service file
sudo rm /etc/systemd/system/sitodo.service
sudo systemctl daemon-reload

# Remove application files
sudo rm -rf /opt/sitodo
sudo rm -rf /var/log/sitodo

# Optionally remove the service user
sudo userdel app
```

## Advanced Configuration

### Using PostgreSQL Database

1. Install PostgreSQL:
   ```bash
   sudo apt install postgresql postgresql-contrib  # Ubuntu/Debian
   ```

2. Create database and user:
   ```bash
   sudo -u postgres psql
   CREATE DATABASE sitodo;
   CREATE USER sitodo_user WITH PASSWORD 'secure_password';
   GRANT ALL PRIVILEGES ON DATABASE sitodo TO sitodo_user;
   \q
   ```

3. Update `/opt/sitodo/config/app.env`:
   ```bash
   SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/sitodo
   SPRING_DATASOURCE_USERNAME=sitodo_user
   SPRING_DATASOURCE_PASSWORD=secure_password
   ```

4. Restart the service:
   ```bash
   sudo systemctl restart sitodo
   ```

### Reverse Proxy with Nginx

To serve the application through Nginx:

1. Install Nginx:
   ```bash
   sudo apt install nginx
   ```

2. Create Nginx configuration:
   ```bash
   sudo nano /etc/nginx/sites-available/sitodo
   ```

3. Add configuration:
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;

       location / {
           proxy_pass http://localhost:8080;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   }
   ```

4. Enable and reload:
   ```bash
   sudo ln -s /etc/nginx/sites-available/sitodo /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl reload nginx
   ```

## Support

For issues or questions:
- Check the logs: `sudo journalctl -u sitodo -f`
- Review the [main README](README.md)
- Open an issue on the GitHub repository
