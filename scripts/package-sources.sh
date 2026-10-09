#!/usr/bin/env bash
set -euo pipefail

# Corresponding-source tarball for the LGPL binaries: the unmodified upstream
# FFmpeg and LAME release tarballs plus this repo's build recipe at HEAD.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

ARCHIVE_BASE="genesys-ffmpeg-minimal-${FFMPEG_VERSION}-r${RECIPE_VERSION}-sources"
DIST_DIR="$ROOT_DIR/dist"
STAGING="$BUILD_ROOT/${ARCHIVE_BASE}"

echo "==> Packaging sources: ffmpeg ${FFMPEG_VERSION}, lame ${LAME_VERSION}"

mkdir -p "$SOURCES_DIR" "$DIST_DIR"
cd "$SOURCES_DIR"

if [[ ! -f "$FFMPEG_TARBALL" ]]; then
  echo "    Downloading ${FFMPEG_URL}"
  curl -fsSL -o "$FFMPEG_TARBALL" "$FFMPEG_URL"
fi

if [[ ! -f "$LAME_TARBALL" ]]; then
  echo "    Downloading ${LAME_URL}"
  curl -fsSL -o "$LAME_TARBALL" "$LAME_URL"
fi

rm -rf "$STAGING"
mkdir -p "$STAGING"
cp "$SOURCES_DIR/$FFMPEG_TARBALL" "$SOURCES_DIR/$LAME_TARBALL" "$STAGING/"

RECIPE_TARBALL="genesys-ffmpeg-minimal-recipe.tar.gz"
git -C "$ROOT_DIR" archive --format=tar.gz --prefix=genesys-ffmpeg-minimal/ \
  -o "$STAGING/$RECIPE_TARBALL" HEAD

cat > "$STAGING/VERSION.txt" <<EOF
ffmpeg=${FFMPEG_VERSION}
ffmpeg_url=${FFMPEG_URL}
lame=${LAME_VERSION}
lame_url=${LAME_URL}
recipe=${RECIPE_VERSION}
recipe_commit=$(git -C "$ROOT_DIR" rev-parse HEAD)
EOF

ARCHIVE="$DIST_DIR/${ARCHIVE_BASE}.tar"
rm -f "$ARCHIVE"
# Members are already compressed, so the outer archive is a plain tar.
tar -cf "$ARCHIVE" -C "$BUILD_ROOT" "$ARCHIVE_BASE"

if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "$ARCHIVE" | tee "$ARCHIVE.sha256"
elif command -v shasum >/dev/null 2>&1; then
  shasum -a 256 "$ARCHIVE" | tee "$ARCHIVE.sha256"
fi

echo "Packaged ${ARCHIVE}"
