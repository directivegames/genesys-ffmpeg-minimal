#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

echo "==> Building LAME ${LAME_VERSION} into ${DEPS_PREFIX}"

if [[ -f "$DEPS_PREFIX/lib/libmp3lame.a" ]] || [[ -f "$DEPS_PREFIX/lib/libmp3lame.dll.a" ]]; then
  echo "    LAME already present, skipping"
  exit 0
fi

mkdir -p "$SOURCES_DIR"
cd "$SOURCES_DIR"

if [[ ! -d "lame-${LAME_VERSION}" ]]; then
  echo "    Downloading ${LAME_URL}"
  curl -fsSL -o "$LAME_TARBALL" "$LAME_URL"
  tar xf "$LAME_TARBALL"
fi

cd "lame-${LAME_VERSION}"

./configure \
  --prefix="$DEPS_PREFIX" \
  --enable-static \
  --disable-shared \
  --disable-frontend \
  CC="$CC" \
  CXX="$CXX" \
  MAKE="$MAKE"

"$MAKE" -j"$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)"
"$MAKE" install

echo "    LAME installed to ${DEPS_PREFIX}"
