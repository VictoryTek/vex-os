#!/usr/bin/env bash
set -oue pipefail

echo "Installing PhotoGIMP..."

# Create temporary directory for download
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download PhotoGIMP from the official repository
echo "Downloading PhotoGIMP..."
curl -L -o photogimp.zip "https://github.com/Diolinux/PhotoGIMP/archive/refs/heads/master.zip"

# Extract the archive
echo "Extracting PhotoGIMP..."
unzip -q photogimp.zip

# Install PhotoGIMP files to system-wide GIMP configuration
echo "Installing PhotoGIMP files..."

# Create GIMP system config directories
mkdir -p /etc/gimp/2.0

# Copy PhotoGIMP files to system GIMP directory
if [ -d "PhotoGIMP-master/.var/app/org.gimp.GIMP/config/GIMP/2.10" ]; then
    cp -r PhotoGIMP-master/.var/app/org.gimp.GIMP/config/GIMP/2.10/* /etc/gimp/2.0/
elif [ -d "PhotoGIMP-master" ]; then
    # Find GIMP config in the archive and copy
    find PhotoGIMP-master -name "*.xcf" -o -name "*.pat" -o -name "*.gih" -o -name "*.abr" | while read file; do
        # Copy brushes, patterns, etc.
        if [[ "$file" == *".pat"* ]]; then
            mkdir -p /usr/share/gimp/2.0/patterns
            cp "$file" /usr/share/gimp/2.0/patterns/
        elif [[ "$file" == *".gih"* ]] || [[ "$file" == *".abr"* ]]; then
            mkdir -p /usr/share/gimp/2.0/brushes
            cp "$file" /usr/share/gimp/2.0/brushes/
        fi
    done
fi

# Create a script to set up PhotoGIMP for users on first GIMP launch
mkdir -p /etc/profile.d
cat > /etc/profile.d/photogimp-setup.sh <<'EOF'
#!/bin/bash
# Set up PhotoGIMP for user on first GIMP launch
if [ ! -f "$HOME/.config/GIMP/photogimp-installed" ] && [ -d "/etc/gimp/2.0" ]; then
    mkdir -p "$HOME/.config/GIMP/2.10"
    cp -r /etc/gimp/2.0/* "$HOME/.config/GIMP/2.10/" 2>/dev/null || true
    touch "$HOME/.config/GIMP/photogimp-installed"
fi
EOF

chmod +x /etc/profile.d/photogimp-setup.sh

# Clean up
cd /
rm -rf "$TEMP_DIR"

echo "PhotoGIMP installation completed!"
