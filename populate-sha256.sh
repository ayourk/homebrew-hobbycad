#!/usr/bin/env bash
# =====================================================================
#  HobbyCAD-homebrew — populate-sha256.sh — Formula hash population
# =====================================================================
#
#  Compute and insert SHA256 hashes for pinned formulas.
#
#  Run from the homebrew-hobbycad repository root:
#    ./populate-sha256.sh
#
#  Requires: curl, sha256sum (or shasum on macOS)
#
#  SPDX-License-Identifier: GPL-3.0-only
#
# =====================================================================

set -euo pipefail
cd "$(dirname "$0")"

FORMULA_DIR="Formula"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

sha256_cmd() {
    if command -v sha256sum &>/dev/null; then
        sha256sum "$1" | awk '{print $1}'
    else
        shasum -a 256 "$1" | awk '{print $1}'
    fi
}

populate() {
    local formula="$1" url="$2" filename="$3"
    local filepath="$FORMULA_DIR/$formula"

    if ! grep -q "REPLACE_WITH_SHA256" "$filepath"; then
        echo "  ✓ $formula — hash already populated, skipping"
        return
    fi

    echo "  ↓ Downloading $filename ..."
    curl -sL -o "$TMPDIR/$filename" "$url"

    local hash
    hash=$(sha256_cmd "$TMPDIR/$filename")
    echo "    sha256: $hash"

    if [[ "$(uname)" == "Darwin" ]]; then
        sed -i '' "s/REPLACE_WITH_SHA256/$hash/" "$filepath"
    else
        sed -i "s/REPLACE_WITH_SHA256/$hash/" "$filepath"
    fi

    echo "  ✓ $formula — hash inserted"
}

echo "Populating SHA256 hashes for pinned formulas..."
echo ""

populate "opencascade@7.6.3.rb" \
    "https://github.com/Open-Cascade-SAS/OCCT/archive/refs/tags/V7_6_3.tar.gz" \
    "V7_6_3.tar.gz"

populate "libzip@1.7.3.rb" \
    "https://github.com/nih-at/libzip/releases/download/v1.7.3/libzip-1.7.3.tar.gz" \
    "libzip-1.7.3.tar.gz"

populate "libgit2@1.7.2.rb" \
    "https://github.com/libgit2/libgit2/archive/refs/tags/v1.7.2.tar.gz" \
    "v1.7.2.tar.gz"

echo ""
echo "Done. Verify with: grep sha256 $FORMULA_DIR/*@*.rb"
