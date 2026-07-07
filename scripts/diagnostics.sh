#!/bin/bash

####################################################
# Diagnostics Collection
####################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../config/monitor.conf"

echo "" >> "$REPORT_FILE"
echo "==========================================" >> "$REPORT_FILE"
echo "        DIAGNOSTICS COLLECTION" >> "$REPORT_FILE"
echo "==========================================" >> "$REPORT_FILE"

####################################################
# Systemctl Status
####################################################

echo "" >> "$REPORT_FILE"
echo "===== systemctl status =====" >> "$REPORT_FILE"

systemctl status "$SERVICE_NAME" --no-pager >> "$REPORT_FILE" 2>&1

####################################################
# Journal Logs
####################################################

echo "" >> "$REPORT_FILE"
echo "===== journalctl =====" >> "$REPORT_FILE"

journalctl -u "$SERVICE_NAME" -n 100 --no-pager >> "$REPORT_FILE" 2>&1

####################################################
# Nginx Error Log
####################################################

echo "" >> "$REPORT_FILE"
echo "===== nginx error.log =====" >> "$REPORT_FILE"

if [ -f "$NGINX_ERROR_LOG" ]; then
    tail -100 "$NGINX_ERROR_LOG" >> "$REPORT_FILE"
else
    echo "Error log not found." >> "$REPORT_FILE"
fi

####################################################
# Disk Usage
####################################################

echo "" >> "$REPORT_FILE"
echo "===== Disk Usage =====" >> "$REPORT_FILE"

df -h >> "$REPORT_FILE"

####################################################
# Memory Usage
####################################################

echo "" >> "$REPORT_FILE"
echo "===== Memory Usage =====" >> "$REPORT_FILE"

free -m >> "$REPORT_FILE"

####################################################
# CPU Load
####################################################

echo "" >> "$REPORT_FILE"
echo "===== CPU Load =====" >> "$REPORT_FILE"

uptime >> "$REPORT_FILE"

####################################################
# Port 80
####################################################

echo "" >> "$REPORT_FILE"
echo "===== Port 80 =====" >> "$REPORT_FILE"

ss -tulpn | grep ":80" >> "$REPORT_FILE" 2>&1

echo "" >> "$REPORT_FILE"
echo "Diagnostics collection completed." >> "$REPORT_FILE"