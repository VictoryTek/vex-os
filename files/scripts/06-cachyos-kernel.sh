#!/usr/bin/env bash

set -euo pipefail

echo "Installing CachyOS kernel..."

# Remove stock kernel packages
dnf -y remove \
    kernel \
    kernel-core \
    kernel-modules \
    kernel-modules-core \
    kernel-modules-extra \
    kernel-devel \
    kernel-devel-matched

# Clean up kernel modules directory
rm -rf /usr/lib/modules/*

# Enable CachyOS kernel repository with explicit chroot
dnf -y copr enable bieszczaders/kernel-cachyos fedora-43-x86_64

# Install CachyOS kernel with weak dependencies disabled
dnf -y install --setopt=install_weak_deps=False \
    kernel-cachyos \
    kernel-cachyos-devel-matched

# Enable SELinux policy for kernel module loading (required for CachyOS)
setsebool -P domain_kernel_load_modules on

# Clean up COPR repos (optional - comment out if you want to keep the repo)
rm -f /etc/yum.repos.d/*bieszczaders-kernel-cachyos*.repo

echo "CachyOS kernel installation complete!"
