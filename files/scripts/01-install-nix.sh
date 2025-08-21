#!/usr/bin/env bash

# Minimal Nix install (multi-user) for an atomic base. Assumes /nix is writable.

set -oue pipefail

echo "::group:: Install Nix (pinned)"

NIX_VERSION="2.21.2"
ARCH="x86_64-linux"  # Adjust if you build for another arch
BASE_URL="https://releases.nixos.org/nix/nix-${NIX_VERSION}"
TARBALL="nix-${NIX_VERSION}-${ARCH}.tar.xz"

# Create store root (image build layer). If a bind mount will mask /nix at
# runtime this still succeeds (masked later by systemd mount).
install -d -m 0755 /nix

# Pre-create minimal structure (installer will refine /nix/var/nix/* as needed).
install -d -m 0755 /nix/var/nix

curl -L "${BASE_URL}/${TARBALL}" -o /tmp/nix.tar.xz
tar -xJf /tmp/nix.tar.xz -C /tmp

# Run upstream installer in daemon mode, without mutating user profiles.
/tmp/nix-*/install \
	--daemon \
	--no-channel-add \
	--no-modify-profile \
	--systemd-units no

# Stable profile symlink.
ln -snf /nix/var/nix/profiles/default /nix/profile

# Profile hook for shells (system-wide).
install -d /etc/profile.d
cat >/etc/profile.d/nix.sh <<'EOF'
[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] && \
	. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
EOF
chmod 0644 /etc/profile.d/nix.sh

rm -rf /tmp/nix-* /tmp/nix.tar.xz

echo "::endgroup::"