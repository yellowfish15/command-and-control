# Lab: Reverse Shell Persistence & Detection

By: Alex Lee, Yu Lim, Ethan Zhang

This proof-of-concept demonstrates a Linux persistence mechanism using a **systemd service** and a **Python reverse shell** secured with HMAC authentication.

---

## Components
* init.sh: The dropper (run on victim). Sets up the service and hidden payload.
* client.py: The attacker listener. Handles the HMAC handshake and command I/O.
* detect_backdoor.sh: The defense script. Audits and removes the backdoor.

---

## Setup & Execution

### 1. Attacker (10.0.2.3)
Start the listener to wait for the incoming connection:
```bash
python3 client.py
```

### 2. Victim (Week 4 VM)
Run the dropper with root privileges to establish persistence:

```bash
chmod +x init.sh
sudo ./init.sh
```

### 3. Interaction
Once the HMAC handshake completes, the attacker gains a root shell. The service will automatically restart the shell if the process is killed or the system reboots.

## Detection & Remediation
To audit the system and remove all traces of this backdoor, run the detection script:

```bash
chmod +x detect_backdoor.sh
sudo ./detect_backdoor.sh
```

### Indicators of Compromise (IoCs)
* Service: /etc/systemd/system/sys-log-update.service
* Binary: /usr/local/bin/.sys-log-update.py
* Network: Active TCP traffic on port 4242.
