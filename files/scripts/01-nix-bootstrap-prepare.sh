#!/usr/bin/env bash
set -euo pipefail

echo "::group:: Prepare Nix first-boot bootstrap"

# Ensure writable target for the future store
install -d -m 0755 /var/nix

# Create /nix symlink (idempotent)
if [ -e /nix ] && [ ! -L /nix ]; then
  rm -rf /nix
fi
ln -snf /var/nix /nix

# Provide profile hook (sourced on login shells)
install -d /etc/profile.d
cat > /etc/profile.d/nix.sh <<'EOF'
# Nix activation (first boot will populate /nix)
if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
EOF
chmod 0644 /etc/profile.d/nix.sh

# Install bootstrap helper & units into image filesystem
install -d -m 0755 /usr/local/sbin
cat > /usr/local/sbin/nix-bootstrap.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
echo "[nix-bootstrap] Starting"

if [ -d /nix/store ]; then
  echo "[nix-bootstrap] Store already exists; exiting"
  systemctl disable nix-bootstrap.service || true
  exit 0
fi

INSTALLER_URL="https://install.determinate.systems/nix"
if ! curl -fsSL "$INSTALLER_URL" -o /tmp/nix-installer.sh; then
  echo "[nix-bootstrap] Determinate installer fetch failed; falling back" >&2
  curl -fsSL https://nixos.org/nix/install -o /tmp/nix-installer.sh
fi
chmod +x /tmp/nix-installer.sh

export NIX_INSTALLER_NO_MODIFY_PROFILE=1
export NIX_INSTALLER_CONFIRM=1

if /tmp/nix-installer.sh install; then
  echo "[nix-bootstrap] Installer completed"
else
  echo "[nix-bootstrap] Installer FAILED" >&2
  exit 1
fi

if [ ! -d /nix/store ]; then
  echo "[nix-bootstrap] ERROR: /nix/store missing post-install" >&2
  exit 2
fi

# SELinux relabel best-effort
if command -v restorecon >/dev/null 2>&1; then
  restorecon -RF /var/nix || true
fi

# Enable daemon if present (Determinate/official installer places units)
systemctl list-unit-files | grep -q '^nix-daemon\.service' && systemctl enable --now nix-daemon.service || true

# Trigger validation
systemctl enable nix-bootstrap-validate.service || true
systemctl start nix-bootstrap-validate.service || true

systemctl disable nix-bootstrap.service || true
echo "[nix-bootstrap] Done"
EOF
chmod 0755 /usr/local/sbin/nix-bootstrap.sh

# systemd unit: bootstrap
install -d -m 0755 /usr/lib/systemd/system
cat > /usr/lib/systemd/system/nix-bootstrap.service <<'EOF'
[Unit]
Description=First-boot Nix bootstrap
ConditionPathExists=!/nix/store
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/nix-bootstrap.sh
TimeoutStartSec=600

[Install]
WantedBy=multi-user.target
EOF

# systemd unit: validation
cat > /usr/lib/systemd/system/nix-bootstrap-validate.service <<'EOF'
[Unit]
Description=Validate Nix installation
After=nix-bootstrap.service
ConditionPathExists=/nix/store

[Service]
Type=oneshot
ExecStart=/usr/bin/bash -c '\
  echo "[nix-validate] nix --version"; \
  if ! command -v nix >/dev/null; then echo "[nix-validate] FAIL: nix missing" >&2; exit 1; fi; \
  nix --version || exit 1; \
  nix store ping || true; \
  echo "[nix-validate] OK" \
'

[Install]
WantedBy=multi-user.target
EOF

# Enable bootstrap for first boot
ln -sf /usr/lib/systemd/system/nix-bootstrap.service /etc/systemd/system/multi-user.target.wants/nix-bootstrap.service

echo "::endgroup::"
