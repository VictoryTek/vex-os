# Vex-OS  [![bluebuild build badge](https://github.com/VictoryTek/vex-os/actions/workflows/build.yml/badge.svg)](https://github.com/VictoryTek/vex-os/actions/workflows/build.yml)

Custom Fedora Atomic (ostree native container) image built with [BlueBuild](https://blue-build.org), based on the Bazzite GNOME variants and personalized with tooling, Flatpaks, GNOME extensions, theming, and wallpapers.

![Vex OS Screenshot](./vex-screenshot1.png)

## Variants
- `vex-os-gnome` (standard GNOME)
- `vex-os-gnome-nvidia` (includes NVIDIA stack)

## Features (short list)
- Developer + container tools (Docker, buildah, skopeo, virtualization group)
- VS Code, Ghostty, Starship
- Curated Flatpaks (Brave, LibreWolf, Bitwarden, etc.)
- GNOME extensions (Dash to Dock, Wallpaper Slideshow, more)
- Branded wallpapers with light/dark pairing & defaults
- Signed images (cosign)

## Rebase / Install
> Uses the [experimental native container](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable) flow.

Pick ONE variant (standard or NVIDIA) and substitute below.

1. Rebase first to the UNSIGNED image (installs trust policy + keys inside the image):
```
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/victorytek/vex-os-gnome:latest
```
OR (NVIDIA):
```
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/victorytek/vex-os-gnome-nvidia:latest
```
2. Reboot:
```
systemctl reboot
```
3. Rebase to the SIGNED image:
```
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/victorytek/vex-os-gnome:latest
```
OR (NVIDIA):
```
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/victorytek/vex-os-gnome-nvidia:latest
```
4. Reboot again:
```
systemctl reboot
```

The `latest` tag tracks the newest build, but the Fedora release stays fixed to what the recipe specifies until manually changed.

## Updating
Stay on the same variant:
```
sudo rpm-ostree upgrade
```
Or explicitly rebase again (helpful if you changed channels):
```
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/victorytek/vex-os-gnome:latest
```

## Verification (Supply Chain)
Images are signed with [cosign](https://github.com/sigstore/cosign). Verify (example for NVIDIA):
```
cosign verify --key cosign.pub ghcr.io/victorytek/vex-os-gnome-nvidia:latest
```
Expect a successful signature from the maintained key in `cosign.pub`.

## ISO (Optional)
If you want an installable ISO, follow the upstream guide: https://blue-build.org/learn/universal-blue/#fresh-install-from-an-iso (hosting large ISOs isn’t included here).

## Credits
Built on the BlueBuild ecosystem and ublue-os Bazzite base. 

---
Minimal README kept intentionally short; open the recipe files under `recipes/` for full details.
