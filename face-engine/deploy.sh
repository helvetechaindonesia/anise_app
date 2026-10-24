#!/bin/bash
set -e

echo "=== [1/5] Mempersiapkan Direktori Face AI Engine di VPS ==="
TARGET_DIR="/www/wwwroot/31.97.222.13/face-engine"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"

echo "=== [2/5] Memastikan Python 3 venv & Pip Terinstall ==="
apt-get update -y
apt-get install -y python3-pip python3-venv libgl1-mesa-glx libglib2.0-0

echo "=== [3/5] Membuat Virtual Environment Python ==="
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

echo "=== [4/5] Menginstall Dependencies InsightFace & FastAPI ==="
./venv/bin/pip install --upgrade pip
./venv/bin/pip install -r requirements.txt

echo "=== [5/5] Mendaftarkan & Menjalankan Systemd Service ==="
cp sipena-face-ai.service /etc/systemd/system/sipena-face-ai.service
systemctl daemon-reload
systemctl enable sipena-face-ai
systemctl restart sipena-face-ai

echo "=== Status Face AI Service: ==="
sleep 2
systemctl status sipena-face-ai --no-pager

echo "=== Test Health Endpoint: ==="
curl -s http://127.0.0.1:5000/health || echo "Menunggu service siap..."
echo "Done! Face AI Service aktif di port 5000."
