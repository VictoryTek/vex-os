#!/usr/bin/env bash
set -euo pipefail

echo "::group:: Validate Nix installation (non-fatal)"

warn() { echo "[WARN] $1" >&2; }
pass=true

# 1. Symlink check
if [ -L /nix ]; then
  TARGET=$(readlink -f /nix || true)
  if [[ "$TARGET" != /var/nix* ]]; then
    warn "/nix symlink target unexpected: $TARGET"; pass=false
  fi
else
  warn "/nix is not a symlink"; pass=false
fi

# 2. Store presence
if [ ! -d /nix/store ]; then
  warn "/nix/store missing (will be populated after first successful Nix use)"; pass=false
fi

# 3. Daemon binary (informational)
if [ -x /nix/var/nix/profiles/default/bin/nix-daemon ]; then
  echo "Found nix-daemon binary"
else
  warn "nix-daemon binary not present yet"
fi

# 4. Version (optional)
if /nix/var/nix/profiles/default/bin/nix --version >/dev/null 2>&1; then
  echo "Nix version: $(/nix/var/nix/profiles/default/bin/nix --version)"
else
  warn "nix --version not available"
fi

# 5. SELinux advisory
if command -v getenforce >/dev/null 2>&1 && [ "$(getenforce)" = "Enforcing" ]; then
  if command -v semanage >/dev/null 2>&1; then
    BIN_SAMPLE=$(find /nix/store -maxdepth 3 -type f -path '*/bin/*' | head -n1 || true)
    [ -n "$BIN_SAMPLE" ] && echo "Sample binary context: $(ls -Z "$BIN_SAMPLE" | awk '{print $1}')"
  else
    warn "SELinux Enforcing but semanage not present"
  fi
fi

if [ "$pass" = true ]; then
  echo "Nix validation: PASS"
else
  echo "Nix validation: WARN (non-blocking)"
fi
echo "::endgroup::"
