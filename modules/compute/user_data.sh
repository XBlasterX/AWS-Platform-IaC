#!/bin/bash

set -euo pipefail

mkdir -p /opt/platform-app && touch /opt/platform-app/index.html && echo "Production AWS Platform — Instance Running" > /opt/platform-app/index.html

cat > /etc/systemd/system/platform-app.service <<'EOF'
[Unit]
Description=Production Platform HTTP Server
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/platform-app
ExecStart=/usr/bin/python3 -m http.server 80 --bind 0.0.0.0 --directory /opt/platform-app
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now platform-app.service