#!/usr/bin/env bash
set -euo pipefail

FLAKE="flake.nix"

# Fetch latest release tag from GitHub
latest=$(curl -fsSL https://api.github.com/repos/planetscale/cli/releases/latest | jq -r '.tag_name')
latest_version="${latest#v}"

# Read current version from flake.nix
current=$(grep 'version = "' "$FLAKE" | head -1 | sed 's/.*"\(.*\)".*/\1/')

if [[ "$current" == "$latest_version" ]]; then
  echo "Already up to date: v${current}"
  exit 0
fi

echo "Updating pscale: v${current} → v${latest_version}"

# Compute new source hash
src_hash=$(nix-prefetch-url --unpack \
  "https://github.com/planetscale/cli/archive/refs/tags/v${latest_version}.tar.gz" 2>/dev/null)
src_sri=$(nix hash convert --hash-algo sha256 --to sri "$src_hash")

# Update version and source hash
sed -i "s|version = \"${current}\"|version = \"${latest_version}\"|" "$FLAKE"
sed -i "s|hash = \"sha256-[^\"]*\"|hash = \"${src_sri}\"|" "$FLAKE"

# Temporarily set vendorHash to empty to trigger the hash mismatch
sed -i 's|vendorHash = "sha256-[^"]*"|vendorHash = ""|' "$FLAKE"

# Stage so nix can see changes
git add "$FLAKE"

# Extract correct vendor hash from the build failure
vendor_hash=$(nix build .#default 2>&1 | grep 'got:' | awk '{print $2}') || true

if [[ -z "$vendor_hash" ]]; then
  echo "ERROR: failed to extract vendor hash" >&2
  exit 1
fi

sed -i "s|vendorHash = \"\"|vendorHash = \"${vendor_hash}\"|" "$FLAKE"
git add "$FLAKE"

# Verify the build succeeds
echo "Building pscale v${latest_version}..."
nix build .#default

echo "Update complete: v${latest_version}"
echo "version=${latest_version}" >>"${GITHUB_OUTPUT:-/dev/null}"
