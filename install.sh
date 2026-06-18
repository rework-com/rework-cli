#!/usr/bin/env bash
# Install the Rework CLI from GitHub Releases (Linux / macOS).
#   curl -fsSL https://github.com/rework-com/rework-cli/releases/latest/download/install.sh | bash
set -euo pipefail
REPO="rework-com/rework-cli"
os="$(uname -s)"; arch="$(uname -m)"
case "$os" in
  Linux)  os=linux ;;
  Darwin) os=darwin ;;
  *) echo "Unsupported OS: $os"; exit 1 ;;
esac
case "$arch" in
  x86_64|amd64)  arch=x64 ;;
  aarch64|arm64) arch=arm64 ;;
  *) echo "Unsupported arch: $arch"; exit 1 ;;
esac
asset="rework-$os-$arch"
url="https://github.com/$REPO/releases/latest/download/$asset"
dest="${REWORK_BIN:-$HOME/.local/bin}"
mkdir -p "$dest"
echo "Downloading $asset ..."
curl -fSL "$url" -o "$dest/rework"
chmod +x "$dest/rework"
echo "Installed -> $dest/rework"
case ":$PATH:" in
  *":$dest:"*) ;;
  *) echo; echo "Add to PATH (then re-open your shell):"; echo "  echo 'export PATH=\"\$PATH:$dest\"' >> ~/.bashrc && source ~/.bashrc" ;;
esac
echo; echo "Done. Run:  rework auth login"
