#!/bin/bash

####################################################
# Self-Healing Monitoring - Main Script
####################################################

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/monitor.conf"
source "$SCRIPT_DIR/logger.sh"

REPORT_FILE="$REPORT_DIR/report_$(date +%F_%H-%M-%S).log"

mkdir -p "$REPORT_DIR"
touch "$REPORT_FILE"

log_info "========================================"
log_info "Self-Healing Monitoring Started"
log_info "Hostname : $(hostname)"
log_info "Time     : $(date)"
log_info "========================================"

####################################################
# Process Detection
####################################################

PID=$(pgrep -x "$SERVICE_NAME")

if [ -n "$PID" ]; then
    log_info "Service is running."
    log_info "PID : $PID"
else
    log_warn "$SERVICE_NAME is NOT running."
    log_info "Starting service..."

    sudo systemctl start "$SERVICE_NAME"

    log_info "Waiting ${WAIT_TIME}s..."
    sleep "$WAIT_TIME"

    PID=$(pgrep -x "$SERVICE_NAME")

    if [ -z "$PID" ]; then
        log_error "Failed to start $SERVICE_NAME."

        "$SCRIPT_DIR/diagnostics.sh"

        exit 1
    fi

    log_info "Service started successfully."
    log_info "PID : $PID"
fi

####################################################
# Health Check
####################################################

log_info "Performing HTTP health check..."

HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}" "$HEALTH_URL")

log_info "HTTP Status : $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then

    log_info "Application is healthy."

    exit 0

fi

####################################################
# Health Failed
####################################################

log_warn "Health check failed."

"$SCRIPT_DIR/diagnostics.sh"

####################################################
# Restart Service
####################################################

log_info "Restarting $SERVICE_NAME..."

sudo systemctl restart "$SERVICE_NAME"

log_info "Waiting ${WAIT_TIME}s..."

sleep "$WAIT_TIME"

####################################################
# Health Check Again
####################################################

log_info "Running health check again..."

HTTP_CODE=$(curl -o /dev/null -s -w "%{http_code}" "$HEALTH_URL")

log_info "HTTP Status : $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then

    log_info "Recovery successful."

    exit 0

fi

####################################################
# Critical Failure
####################################################

log_error "Critical Failure."

"$SCRIPT_DIR/diagnostics.sh"

exit 1