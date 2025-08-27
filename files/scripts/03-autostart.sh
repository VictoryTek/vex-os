#!/usr/bin/env bash
set -oue pipefail

echo "Disabling Steam autostart..."

# Create system-wide autostart override
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

# Also disable any potential Steam autostart desktop files
for steam_autostart in /usr/share/applications/steam.desktop /usr/local/share/applications/steam.desktop /var/lib/flatpak/exports/share/applications/*steam*.desktop; do
    if [[ -f "$steam_autostart" ]]; then
        echo "Found Steam desktop file: $steam_autostart"
        # Create an override in autostart directory
        basename_file=$(basename "$steam_autostart")
        cat > "/etc/xdg/autostart/$basename_file" <<EOF
[Desktop Entry]
Type=Application
Name=Steam
Exec=steam
X-GNOME-Autostart-enabled=false
Hidden=true
NoDisplay=true
EOF
    fi
done

# Disable Steam service if it exists
if systemctl list-unit-files | grep -q steam; then
    echo "Disabling Steam systemd services..."
    systemctl disable steam.service 2>/dev/null || true
    systemctl disable steam-gamescope.service 2>/dev/null || true
fi

echo "Steam autostart disabled."