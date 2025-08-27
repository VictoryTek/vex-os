#!/usr/bin/env bash
set -oue pipefail

echo "Setting up one-time Steam autostart removal..."

# Create a systemd service that runs once on first boot
cat > /etc/systemd/system/disable-steam-autostart.service <<'EOF'
[Unit]
Description=Remove Steam autostart file on first boot
After=graphical-session.target
ConditionPathExists=!/var/lib/steam-autostart-disabled

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'for user_home in /home/*; do if [ -d "$user_home" ]; then rm -f "$user_home/.config/autostart/steam.desktop"; fi; done'
ExecStartPost=/bin/touch /var/lib/steam-autostart-disabled
RemainAfterExit=yes

[Install]
WantedBy=graphical-session.target
EOF

# Enable the service
systemctl enable disable-steam-autostart.service

echo "One-time Steam autostart removal service created and enabled."