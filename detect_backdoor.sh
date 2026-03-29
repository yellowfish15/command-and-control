#!/bin/bash
echo "Starting Backdoor Audit and Cleanup..."

SERVICE_NAME="sys-log-update"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
BACKDOOR_FILE="/usr/local/bin/.${SERVICE_NAME}.py"
PORT="4242"

FOUND=0

if [ -f "$SERVICE_FILE" ]; then
    echo "ALERT: Malicious Systemd service found: $SERVICE_FILE"
    FOUND=1
    systemctl stop "$SERVICE_NAME" 2>/dev/null
    systemctl disable "$SERVICE_NAME" 2>/dev/null
    rm -f "$SERVICE_FILE"
fi

if [ -f "$BACKDOOR_FILE" ]; then
    echo "ALERT: Hidden backdoor file found: $BACKDOOR_FILE"
    FOUND=1
    pkill -f "$BACKDOOR_FILE" 2>/dev/null
    rm -f "$BACKDOOR_FILE"
fi

if ss -antp 2>/dev/null | grep ":${PORT}" | grep ESTAB > /dev/null; then
    echo "ALERT: Active connection detected on port ${PORT}"
    FOUND=1
    pids=$(ss -antp 2>/dev/null | awk -v port=":${PORT}" '
        $0 ~ port && $0 ~ /ESTAB/ {
            if (match($0,/pid=[0-9]+/)) {
                print substr($0,RSTART+4,RLENGTH-4)
            }
        }' | sort -u)
    for pid in $pids; do
        kill -9 "$pid" 2>/dev/null
    done
fi

systemctl daemon-reload
systemctl reset-failed 2>/dev/null

if [ "$FOUND" -eq 0 ]; then
    echo "No backdoor artifacts found."
else
    echo "Cleanup complete."
fi