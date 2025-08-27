# Vex-OS  [![bluebuild build badge](https://github.com/VictoryTek/vex-os/actions/workflows/build.yml/badge.svg)](https://github.com/VictoryTek/vex-os/actions/workflows/build.yml)

Custom Fedora Atomic (ostree native container) image built with [BlueBuild](https://blue-build.org), based on the Bazzite GNOME variants and personalized with tooling, Flatpaks, GNOME extensions, theming, and wallpapers.

## Screenshots
<p align="center">
	<a href="./vex-screenshot1.jpg" title="Desktop Light"><img src="./vex-screenshot1.jpg" alt="Vex OS desktop screenshot (light)" width="48%"/></a>
	<a href="./vex-screenshot2.jpg" title="Desktop Dark"><img src="./vex-screenshot2.jpg" alt="Vex OS desktop screenshot (dark)" width="48%"/></a>
</p>

## Variants
- `vex-os` (standard GNOME)
- `vex-os-nvidia` (standard GNOME includes NVIDIA stack)

## Features (short list)
- Gnome DE (I dont like KDE) (maybe Cosmic in the future)
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
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/victorytek/vex-os:latest
```
OR (NVIDIA):
```
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/victorytek/vex-os-nvidia:latest
```
2. Reboot:
```
systemctl reboot
```
3. Rebase to the SIGNED image:
```
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/victorytek/vex-os:latest
```
OR (NVIDIA):
```
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/victorytek/vex-os-nvidia:latest
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
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/victorytek/vex-os:latest
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
