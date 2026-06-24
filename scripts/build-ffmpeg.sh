#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"
# shellcheck source=/dev/null
source "$ROOT_DIR/configure-flags.sh"

if [[ -z "${OUTPUT_PREFIX:-}" ]] || [[ "$OUTPUT_PREFIX" == "$ROOT_DIR/artifacts/unconfigured" ]]; then
  echo "OUTPUT_PREFIX must be set by the platform build script" >&2
  exit 1
fi

echo "==> Building FFmpeg ${FFMPEG_VERSION} (recipe v${RECIPE_VERSION})"
echo "    Output: ${OUTPUT_PREFIX}"

mkdir -p "$SOURCES_DIR"
cd "$SOURCES_DIR"

if [[ ! -d "$FFMPEG_SRC_DIR" ]]; then
  echo "    Downloading ${FFMPEG_URL}"
  curl -fsSL -o "$FFMPEG_TARBALL" "$FFMPEG_URL"
  tar xf "$FFMPEG_TARBALL"
fi

cd "$FFMPEG_SRC_DIR"

# FFmpeg ships a stub Makefile before configure; distclean needs ffbuild/config.mak.
if [[ -f ffbuild/config.mak ]]; then
  "$MAKE" distclean || true
fi

export CC CXX
export PKG_CONFIG_PATH="$DEPS_PREFIX/lib/pkgconfig:${PKG_CONFIG_PATH:-}"

# macOS has no static libSystem, so a fully static link (-static) only works on
# glibc/MinGW. Platform scripts set STATIC_LDFLAG="" to opt out; everywhere else
# we default to a fully static binary.
STATIC_LDFLAG="${STATIC_LDFLAG:--static}"

./configure \
  --prefix="$OUTPUT_PREFIX" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I${DEPS_PREFIX}/include" \
  --extra-ldflags="-L${DEPS_PREFIX}/lib ${STATIC_LDFLAG}" \
  --enable-static \
  --disable-shared \
  "${GENESYS_FFMPEG_CONFIGURE_FLAGS[@]}"

"$MAKE" -j"$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)"
"$MAKE" install

FFMPEG_BIN="$OUTPUT_PREFIX/bin/ffmpeg"
if [[ -f "${FFMPEG_BIN}.exe" ]]; then
  FFMPEG_BIN="${FFMPEG_BIN}.exe"
fi

if command -v "$STRIP" >/dev/null 2>&1; then
  "$STRIP" "$FFMPEG_BIN" || true
fi

echo "    Built $(du -h "$FFMPEG_BIN" 2>/dev/null | cut -f1 || stat -c%s "$FFMPEG_BIN" 2>/dev/null || echo '?') binary at ${FFMPEG_BIN}"
