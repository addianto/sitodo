#!/bin/bash

#####################################################################
# Test script for deploy.sh validation
# This tests the deployment script logic without requiring root
#####################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPLOY_SCRIPT="${SCRIPT_DIR}/deploy.sh"

echo "========================================="
echo "Testing deploy.sh script"
echo "========================================="
echo ""

# Test 1: Check script exists and is executable
echo "Test 1: Script exists and is executable"
if [ -x "$DEPLOY_SCRIPT" ]; then
    echo "✓ deploy.sh is executable"
else
    echo "✗ deploy.sh is not executable or not found"
    exit 1
fi
echo ""

# Test 2: Verify bash syntax
echo "Test 2: Bash syntax validation"
if bash -n "$DEPLOY_SCRIPT"; then
    echo "✓ Script syntax is valid"
else
    echo "✗ Script has syntax errors"
    exit 1
fi
echo ""

# Test 3: Check for shellcheck (if available)
echo "Test 3: Shellcheck linting"
if command -v shellcheck &> /dev/null; then
    if shellcheck "$DEPLOY_SCRIPT"; then
        echo "✓ Script passes shellcheck"
    else
        echo "✗ Script has shellcheck warnings"
        exit 1
    fi
else
    echo "⊘ shellcheck not available (skipping)"
fi
echo ""

# Test 4: Verify required files exist
echo "Test 4: Check required files"
REQUIRED_FILES=("deploy.sh" "sitodo.service" "app.env.example" "DEPLOYMENT.md")
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "${SCRIPT_DIR}/${file}" ]; then
        echo "✓ ${file} exists"
    else
        echo "✗ ${file} not found"
        exit 1
    fi
done
echo ""

# Test 5: Test error handling - no arguments
echo "Test 5: Error handling - no arguments"
if bash "$DEPLOY_SCRIPT" 2>&1 | grep -q "This script must be run as root"; then
    echo "✓ Root check works correctly"
else
    echo "✗ Root check failed"
    exit 1
fi
echo ""

# Test 6: Test error handling - non-existent JAR
echo "Test 6: Error handling - non-existent JAR file"
# We can't test with sudo, but we can verify the script structure
if grep -q "JAR file not found" "$DEPLOY_SCRIPT"; then
    echo "✓ JAR file validation code present"
else
    echo "✗ JAR file validation code missing"
    exit 1
fi
echo ""

# Test 7: Verify systemd service file content
echo "Test 7: Systemd service file validation"
SERVICE_FILE="${SCRIPT_DIR}/sitodo.service"
REQUIRED_DIRECTIVES=("User=app" "ExecStart=" "SuccessExitStatus=143" "Restart=always" "EnvironmentFile=")
for directive in "${REQUIRED_DIRECTIVES[@]}"; do
    if grep -q "$directive" "$SERVICE_FILE"; then
        echo "✓ Service file contains: ${directive}"
    else
        echo "✗ Service file missing: ${directive}"
        exit 1
    fi
done
echo ""

# Test 8: Verify environment file example
echo "Test 8: Environment file example validation"
ENV_FILE="${SCRIPT_DIR}/app.env.example"
REQUIRED_VARS=("SERVER_PORT" "SPRING_DATASOURCE_URL" "LOGGING_FILE_NAME")
for var in "${REQUIRED_VARS[@]}"; do
    if grep -q "$var" "$ENV_FILE"; then
        echo "✓ Environment file contains: ${var}"
    else
        echo "✗ Environment file missing: ${var}"
        exit 1
    fi
done
echo ""

# Test 9: Verify deployment script has all required steps
echo "Test 9: Deployment script completeness"
REQUIRED_STEPS=(
    "Create service user"
    "directory structure"
    "Stop the service"
    "Backup current JAR"
    "Deploy new JAR"
    "systemd service"
    "daemon-reload"
    "Start the service"
    "Verify"
)
for step in "${REQUIRED_STEPS[@]}"; do
    if grep -qi "$step" "$DEPLOY_SCRIPT"; then
        echo "✓ Script includes: ${step}"
    else
        echo "✗ Script missing step: ${step}"
        exit 1
    fi
done
echo ""

# Test 10: Verify documentation
echo "Test 10: Documentation completeness"
DOC_FILE="${SCRIPT_DIR}/DEPLOYMENT.md"
REQUIRED_SECTIONS=("Prerequisites" "Quick Start" "Configuration" "Managing the Service" "Troubleshooting")
for section in "${REQUIRED_SECTIONS[@]}"; do
    if grep -qi "$section" "$DOC_FILE"; then
        echo "✓ Documentation includes: ${section}"
    else
        echo "✗ Documentation missing: ${section}"
        exit 1
    fi
done
echo ""

echo "========================================="
echo "All tests passed! ✓"
echo "========================================="
echo ""
echo "Note: Full integration testing requires:"
echo "  - Root/sudo access"
echo "  - systemd-based Linux system"
echo "  - Built JAR file"
echo ""
echo "To test the deployment in a real environment:"
echo "  1. Build: mvn clean package -DskipTests"
echo "  2. Deploy: sudo ./deploy.sh target/sitodo-*.jar"
