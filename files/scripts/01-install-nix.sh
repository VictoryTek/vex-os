#!/usr/bin/env bash

# Nix multi-user install for atomic system using /var/nix as writable store
# with /nix -> /var/nix symlink (simpler than bind mount unit).

set -oue pipefail

echo "::group:: Install Nix (symlink /nix -> /var/nix)"

NIX_VERSION="2.21.2"
ARCH="x86_64-linux" # adjust if building another arch
BASE_URL="https://releases.nixos.org/nix/nix-${NIX_VERSION}"
TARBALL="nix-${NIX_VERSION}-${ARCH}.tar.xz"

# Prepare writable location inside /var (persisting across deployments)
install -d -m 0755 /var/nix

# Ensure /nix symlink (idempotent)
if [ -e /nix ] && [ ! -L /nix ]; then
	rm -rf /nix
fi
ln -snf /var/nix /nix

# Pre-create subdirs the installer expects
install -d -m 0755 /var/nix/var/nix

curl -L "${BASE_URL}/${TARBALL}" -o /tmp/nix.tar.xz
tar -xJf /tmp/nix.tar.xz -C /tmp

/tmp/nix-*/install \
	--daemon \
	--no-channel-add \
	--no-modify-profile \
	--systemd-units no

# Stable profile symlink (inside symlinked tree)
ln -snf /nix/var/nix/profiles/default /nix/profile

# Shell profile hook
install -d /etc/profile.d
cat > /etc/profile.d/nix.sh <<'EOF'
[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] && \
	. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
EOF
chmod 0644 /etc/profile.d/nix.sh

rm -rf /tmp/nix-* /tmp/nix.tar.xz

# SELinux context labeling (best effort) for Nix store & daemon socket when policy tools available
if command -v semanage >/dev/null 2>&1; then
	echo "Labeling Nix store paths with SELinux contexts"
	# Core directories
	semanage fcontext -a -t bin_t       '/var/nix/store/[^/]+/bin(/.*)?' || true
	semanage fcontext -a -t bin_t       '/var/nix/store/[^/]+/sbin(/.*)?' || true
	semanage fcontext -a -t lib_t       '/var/nix/store/[^/]+/lib(/.*)?' || true
	semanage fcontext -a -t lib_t       '/var/nix/store/[^/]+/lib64(/.*)?' || true
	semanage fcontext -a -t etc_t       '/var/nix/store/[^/]+/etc(/.*)?' || true
	semanage fcontext -a -t usr_t       '/var/nix/store/[^/]+/share(/.*)?' || true
	semanage fcontext -a -t man_t       '/var/nix/store/[^/]+/man(/.*)?' || true
	semanage fcontext -a -t var_run_t   '/var/nix/var/nix/daemon-socket(/.*)?' || true
	# Apply labels
	restorecon -RF /var/nix || true
else
	echo "semanage not available; skipping SELinux fcontext configuration"
fi

echo "::endgroup::"