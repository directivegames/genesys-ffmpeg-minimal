#!/usr/bin/env bash
set -euo pipefail

# Windows x64 static build via MSYS2 MinGW64 (GitHub Actions + local MSYS2).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

export CC="gcc"
export CXX="g++"
export STRIP="strip"

ARTIFACT_SLUG="${ARTIFACT_SLUG:-win64-static}"
export OUTPUT_PREFIX="$ROOT_DIR/artifacts/${ARTIFACT_SLUG}"

echo "==> Genesys minimal ffmpeg — ${ARTIFACT_SLUG}"

"$SCRIPT_DIR/build-lame.sh"
"$SCRIPT_DIR/build-ffmpeg.sh"
"$SCRIPT_DIR/package.sh" "$ARTIFACT_SLUG"
"$SCRIPT_DIR/smoke-test.sh" "$OUTPUT_PREFIX/bin/ffmpeg.exe"

echo "==> Done: $ROOT_DIR/dist/${ARTIFACT_SLUG}.zip"
