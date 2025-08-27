# Test this Just file: /usr/bin/just --justfile files/justfiles/generate_iso.just --choose

# Generate ISO for VexOS
[group('Apps')]
generate-iso-vex-os:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Creating ISO directory..."
    mkdir -p ~/iso
    echo "Changing to ISO directory..."
    cd ~/iso
    echo "Generating ISO..."
    bluebuild generate-iso --iso-name vex-os-42.iso image ghcr.io/victorytek/vex-os:latest
    echo "ISO generated successfully in ~/iso/"

# Generate ISO for VexOS Nvidia
[group('Apps')]
generate-iso-vex-os-nvidia:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Creating ISO directory..."
    mkdir -p ~/iso
    echo "Changing to ISO directory..."
    cd ~/iso
    echo "Generating ISO..."
    bluebuild generate-iso --iso-name vex-os-42-nvidia.iso image ghcr.io/victorytek/vex-os-nvidia:latest
    echo "ISO generated successfully in ~/iso/"