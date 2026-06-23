#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

readarray -t VERSION_LINES < "$ROOT_DIR/VERSION"
export FFMPEG_VERSION="${VERSION_LINES[0]}"
export RECIPE_VERSION="${VERSION_LINES[1]:-1}"

export LAME_VERSION="${LAME_VERSION:-3.100}"

export FFMPEG_TARBALL="ffmpeg-${FFMPEG_VERSION}.tar.xz"
export FFMPEG_URL="https://ffmpeg.org/releases/${FFMPEG_TARBALL}"
export LAME_TARBALL="lame-${LAME_VERSION}.tar.gz"
export LAME_URL="https://downloads.sourceforge.net/project/lame/lame/${LAME_VERSION}/${LAME_TARBALL}"

export BUILD_ROOT="${BUILD_ROOT:-$ROOT_DIR/build}"
export SOURCES_DIR="${SOURCES_DIR:-$BUILD_ROOT/sources}"
export DEPS_PREFIX="${DEPS_PREFIX:-$BUILD_ROOT/deps}"
export FFMPEG_SRC_DIR="${FFMPEG_SRC_DIR:-$SOURCES_DIR/ffmpeg-${FFMPEG_VERSION}}"

# Set by platform scripts before calling build-ffmpeg.sh
export OUTPUT_PREFIX="${OUTPUT_PREFIX:-$ROOT_DIR/artifacts/unconfigured}"

export CC="${CC:-gcc}"
export CXX="${CXX:-g++}"
export PKG_CONFIG="${PKG_CONFIG:-pkg-config}"
export MAKE="${MAKE:-make}"
export STRIP="${STRIP:-strip}"

mkdir -p "$SOURCES_DIR" "$DEPS_PREFIX" "$(dirname "$OUTPUT_PREFIX")"
