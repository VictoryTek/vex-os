#!/usr/bin/env bash
set -oue pipefail

mkdir -p /etc/xdg/autostart
cat > /etc/xdg/autostart/steam.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Steam
Exec=steam
X-GNOME-Autostart-enabled=false
Hidden=true
NoDisplay=true
EOF