#!/usr/bin/env bash
set -euo pipefail

# macOS static build (clang + static libmp3lame). The system frameworks/libc
# are linked dynamically because macOS has no static libSystem; libmp3lame is
# linked statically from our own deps prefix.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

export CC="${CC:-clang}"
export CXX="${CXX:-clang++}"
export STRIP="${STRIP:-strip}"

# No fully static binary on macOS: link system libs dynamically.
export STATIC_LDFLAG=""

ARCH="${ARCH:-$(uname -m)}"
case "$ARCH" in
  arm64 | aarch64)
    ARTIFACT_SLUG="${ARTIFACT_SLUG:-macos-arm64-static}"
    ;;
  x86_64)
    ARTIFACT_SLUG="${ARTIFACT_SLUG:-macos-x64-static}"
    ;;
  *)
    echo "Unsupported macOS arch: $ARCH" >&2
    exit 1
    ;;
esac

export OUTPUT_PREFIX="$ROOT_DIR/artifacts/${ARTIFACT_SLUG}"

echo "==> Genesys minimal ffmpeg — ${ARTIFACT_SLUG} (arch: ${ARCH})"
echo "    Install build deps first, e.g.:"
echo "    brew install nasm yasm pkg-config xz"

bash "$SCRIPT_DIR/build-lame.sh"
bash "$SCRIPT_DIR/build-ffmpeg.sh"
bash "$SCRIPT_DIR/package.sh" "$ARTIFACT_SLUG"
bash "$SCRIPT_DIR/smoke-test.sh" "$OUTPUT_PREFIX/bin/ffmpeg"

echo "==> Done: $ROOT_DIR/dist/${ARTIFACT_SLUG}.tar.xz"
