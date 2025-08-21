#!/usr/bin/env bash
set -euo pipefail

echo "::group:: Validate Nix installation"

fail() { echo "[FAIL] $1" >&2; exit 1; }

# 1. Symlink check
[ -L /nix ] || fail "/nix is not a symlink"
TARGET=$(readlink -f /nix || true)
[[ "$TARGET" == /var/nix* ]] || fail "/nix does not point into /var/nix (points to $TARGET)"

# 2. Store presence
[ -d /nix/store ] || fail "/nix/store missing"

# 3. Daemon binary
[ -x /nix/var/nix/profiles/default/bin/nix-daemon ] || fail "nix-daemon binary not found"

# 4. Basic version command
if /nix/var/nix/profiles/default/bin/nix --version >/dev/null 2>&1; then
  echo "Nix version: $(/nix/var/nix/profiles/default/bin/nix --version)"
else
  fail "nix --version failed"
fi

# 5. SELinux labeling (non-fatal advisory)
if command -v getenforce >/dev/null 2>&1 && [ "$(getenforce)" = "Enforcing" ]; then
  if command -v semanage >/dev/null 2>&1; then
    BIN_SAMPLE=$(find /nix/store -maxdepth 3 -type f -path '*/bin/*' | head -n1 || true)
    if [ -n "$BIN_SAMPLE" ]; then
      CTX=$(ls -Z "$BIN_SAMPLE" | awk '{print $1}')
      echo "Sample binary context: $CTX"
    else
      echo "No sample binary found for SELinux context check"
    fi
  else
    echo "SELinux Enforcing but semanage not present (labels may be generic)"
  fi
fi

echo "All Nix validation checks passed."
echo "::endgroup::"
