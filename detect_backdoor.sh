#!/bin/bash
echo "Starting Backdoor Audit..."

# check for Systemd Service
if [ -f "/etc/systemd/system/sys-log-update.service" ]; then
    echo "ALERT: Malicious Systemd service found: sys-log-update.service"
fi

# check for hidden agent file
if [ -f "/usr/local/bin/.sys-log-update.py" ]; then
    echo "ALERT: Hidden backdoor binary found in /usr/local/bin/"
fi

# check for network connections to known port
if netstat -antp | grep ":4242" | grep "ESTABLISHED" > /dev/null; then
    echo "ALERT: Active connection to C2 Controller detected on port 4242!"
fi

echo "Audit Complete."
