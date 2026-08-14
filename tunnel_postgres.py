"""
Script de Túnel SSH para conectar o PostgreSQL local ao PostgreSQL da VPS.
Uso: python tunnel_postgres.py
"""

import subprocess
import sys
import time

VPS_IP = "195.200.1.67"
VPS_PORT = 5434
LOCAL_PORT = 5432
SSH_USER = "root"

print(f"🚀 Iniciando túnel SSH: localhost:{LOCAL_PORT} -> {VPS_IP}:{VPS_PORT}...")
print(f"📌 String de conexão local: postgres://postgres:mz079TK6@127.0.0.1:{LOCAL_PORT}/chatwoot_pratika")
print("⚡ Pressione Ctrl+C para encerrar o túnel.")

try:
    cmd = [
        "ssh",
        "-N",
        "-L", f"{LOCAL_PORT}:127.0.0.1:{VPS_PORT}",
        f"{SSH_USER}@{VPS_IP}"
    ]
    subprocess.run(cmd)
except KeyboardInterrupt:
    print("\n🛑 Túnel encerrado.")
