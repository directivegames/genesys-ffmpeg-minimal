#!/usr/bin/env bash
set -euo pipefail

# Linux x64 static build (glibc). Stub: expand in phase 2.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

export CC="${CC:-gcc}"
export CXX="${CXX:-g++}"
export STRIP="${STRIP:-strip}"

ARTIFACT_SLUG="${ARTIFACT_SLUG:-linux64-static}"
export OUTPUT_PREFIX="$ROOT_DIR/artifacts/${ARTIFACT_SLUG}"

echo "==> Genesys minimal ffmpeg — ${ARTIFACT_SLUG}"
echo "    Install build deps first, e.g.:"
echo "    sudo apt-get install -y build-essential curl nasm yasm pkg-config"

"$SCRIPT_DIR/build-lame.sh"
"$SCRIPT_DIR/build-ffmpeg.sh"
"$SCRIPT_DIR/package.sh" "$ARTIFACT_SLUG"
"$SCRIPT_DIR/smoke-test.sh" "$OUTPUT_PREFIX/bin/ffmpeg"

echo "==> Done: $ROOT_DIR/dist/${ARTIFACT_SLUG}.tar.xz"
