#!/bin/bash

#####################################################################
# Sitodo Deployment Script
# 
# This script deploys the Sitodo application as a systemd service
# on a Linux VM.
#
# Usage: sudo ./deploy.sh /path/to/sitodo.jar
#####################################################################

set -e  # Exit on error

# Configuration
APP_NAME="sitodo"
APP_USER="app"
APP_GROUP="app"
APP_HOME="/opt/${APP_NAME}"
APP_BIN_DIR="${APP_HOME}/bin"
APP_CONFIG_DIR="${APP_HOME}/config"
APP_DATA_DIR="${APP_HOME}/data"
APP_LOG_DIR="/var/log/${APP_NAME}"
SERVICE_FILE="/etc/systemd/system/${APP_NAME}.service"
JAR_NAME="${APP_NAME}.jar"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    log_error "This script must be run as root (use sudo)"
    exit 1
fi

# Check if JAR file argument is provided
if [ $# -lt 1 ]; then
    log_error "Usage: $0 /path/to/${APP_NAME}.jar"
    exit 1
fi

NEW_JAR_PATH="$1"

# Verify JAR file exists
if [ ! -f "$NEW_JAR_PATH" ]; then
    log_error "JAR file not found: $NEW_JAR_PATH"
    exit 1
fi

log_info "Starting deployment of ${APP_NAME}..."

#####################################################################
# Step 1: Create service user if not exists
#####################################################################
log_info "Step 1: Checking/creating service user..."

if id "$APP_USER" &>/dev/null; then
    log_info "User '$APP_USER' already exists"
else
    log_info "Creating user '$APP_USER'..."
    useradd --system \
            --shell /sbin/nologin \
            --home-dir "$APP_HOME" \
            --create-home \
            --user-group \
            "$APP_USER"
    log_info "User '$APP_USER' created successfully"
fi

#####################################################################
# Step 2: Create directory structure with proper permissions
#####################################################################
log_info "Step 2: Setting up directory structure..."

# Create directories
mkdir -p "$APP_BIN_DIR"
mkdir -p "$APP_CONFIG_DIR"
mkdir -p "$APP_DATA_DIR"
mkdir -p "$APP_LOG_DIR"

# Set ownership
chown -R ${APP_USER}:${APP_GROUP} "$APP_HOME"
chown -R ${APP_USER}:${APP_GROUP} "$APP_LOG_DIR"

# Set permissions (750 = rwxr-x---)
chmod 750 "$APP_HOME"
chmod 750 "$APP_BIN_DIR"
chmod 750 "$APP_CONFIG_DIR"
chmod 750 "$APP_DATA_DIR"
chmod 750 "$APP_LOG_DIR"

log_info "Directory structure created with proper permissions"

#####################################################################
# Step 3: Create/update environment configuration file if needed
#####################################################################
log_info "Step 3: Checking environment configuration..."

ENV_FILE="${APP_CONFIG_DIR}/app.env"
if [ ! -f "$ENV_FILE" ]; then
    log_warn "Environment file not found at $ENV_FILE"
    log_info "Creating default environment file..."
    
    cat > "$ENV_FILE" << 'EOF'
# Sitodo Application Environment Configuration
SERVER_PORT=8080
SPRING_DATASOURCE_URL=jdbc:h2:file:/opt/sitodo/data/sitodo
SPRING_DATASOURCE_USERNAME=sa
SPRING_DATASOURCE_PASSWORD=
SPRING_JPA_HIBERNATE_DDL_AUTO=update
SPRING_JPA_SHOW_SQL=false
LOGGING_LEVEL_ROOT=INFO
LOGGING_LEVEL_COM_EXAMPLE_SITODO=INFO
LOGGING_FILE_NAME=/var/log/sitodo/application.log
SPRING_PROFILES_ACTIVE=production
EOF
    
    chown ${APP_USER}:${APP_GROUP} "$ENV_FILE"
    chmod 640 "$ENV_FILE"
    log_info "Default environment file created at $ENV_FILE"
else
    log_info "Environment file already exists at $ENV_FILE"
fi

#####################################################################
# Step 4: Stop the service if running
#####################################################################
log_info "Step 4: Stopping service if running..."

if systemctl is-active --quiet "$APP_NAME"; then
    log_info "Stopping ${APP_NAME} service..."
    systemctl stop "$APP_NAME"
    log_info "Service stopped"
else
    log_info "Service is not currently running"
fi

#####################################################################
# Step 5: Backup current JAR if exists
#####################################################################
log_info "Step 5: Backing up current JAR file..."

TARGET_JAR="${APP_BIN_DIR}/${JAR_NAME}"
if [ -f "$TARGET_JAR" ]; then
    BACKUP_NAME="${JAR_NAME}.$(date +%Y%m%d_%H%M%S).bak"
    BACKUP_PATH="${APP_BIN_DIR}/${BACKUP_NAME}"
    log_info "Creating backup: $BACKUP_NAME"
    cp "$TARGET_JAR" "$BACKUP_PATH"
    log_info "Backup created at $BACKUP_PATH"
else
    log_info "No existing JAR file to backup (first deployment)"
fi

#####################################################################
# Step 6: Deploy new JAR file
#####################################################################
log_info "Step 6: Deploying new JAR file..."

cp "$NEW_JAR_PATH" "$TARGET_JAR"
chown ${APP_USER}:${APP_GROUP} "$TARGET_JAR"
chmod 750 "$TARGET_JAR"

log_info "JAR file deployed successfully"

#####################################################################
# Step 7: Create/update systemd service file
#####################################################################
log_info "Step 7: Setting up systemd service..."

cat > "$SERVICE_FILE" << EOF
[Unit]
Description=Sitodo - Simple Todo Application
After=network.target

[Service]
Type=simple
User=${APP_USER}
Group=${APP_GROUP}
WorkingDirectory=${APP_HOME}
ExecStart=/usr/bin/java -jar ${TARGET_JAR}
SuccessExitStatus=143
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=${APP_NAME}

# Environment configuration
EnvironmentFile=${ENV_FILE}

# Security hardening
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

log_info "Systemd service file created at $SERVICE_FILE"

#####################################################################
# Step 8: Reload systemd and enable service
#####################################################################
log_info "Step 8: Reloading systemd daemon..."

systemctl daemon-reload
log_info "Systemd daemon reloaded"

# Enable service to start on boot
if ! systemctl is-enabled --quiet "$APP_NAME"; then
    log_info "Enabling ${APP_NAME} service to start on boot..."
    systemctl enable "$APP_NAME"
fi

#####################################################################
# Step 9: Start the service
#####################################################################
log_info "Step 9: Starting ${APP_NAME} service..."

systemctl start "$APP_NAME"
log_info "Service started"

#####################################################################
# Step 10: Verify deployment
#####################################################################
log_info "Step 10: Verifying deployment..."

# Wait a few seconds for the service to start
sleep 5

if systemctl is-active --quiet "$APP_NAME"; then
    log_info "${GREEN}✓ Service is running${NC}"
else
    log_error "Service failed to start"
    log_error "Check logs with: journalctl -u ${APP_NAME} -n 50"
    exit 1
fi

# Check service status
log_info "Service status:"
systemctl status "$APP_NAME" --no-pager || true

# Try to check health endpoint if available
log_info "Checking application health..."
sleep 5  # Give app more time to fully start

if command -v curl &> /dev/null; then
    if curl -f -s -o /dev/null http://localhost:8080/; then
        log_info "${GREEN}✓ Application is responding to HTTP requests${NC}"
    else
        log_warn "Application may not be fully started yet. Check with: curl http://localhost:8080/"
    fi
else
    log_warn "curl not found. Manual health check recommended."
fi

#####################################################################
# Deployment complete
#####################################################################
echo ""
log_info "${GREEN}========================================${NC}"
log_info "${GREEN}Deployment completed successfully!${NC}"
log_info "${GREEN}========================================${NC}"
echo ""
log_info "Useful commands:"
log_info "  - View logs: journalctl -u ${APP_NAME} -f"
log_info "  - Check status: systemctl status ${APP_NAME}"
log_info "  - Restart: systemctl restart ${APP_NAME}"
log_info "  - Stop: systemctl stop ${APP_NAME}"
log_info "  - View environment: cat ${ENV_FILE}"
echo ""
