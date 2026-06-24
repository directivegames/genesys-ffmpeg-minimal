#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <artifact-slug>" >&2
  exit 1
fi

SLUG="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=env.sh
source "$SCRIPT_DIR/env.sh"

# Bash 3.2 (macOS) lacks readarray; read VERSION lines portably.
VERSION_LINES=()
while IFS= read -r _line || [[ -n "$_line" ]]; do
  VERSION_LINES+=("$_line")
done < "$ROOT_DIR/VERSION"
FFMPEG_VERSION="${VERSION_LINES[0]}"
RECIPE_VERSION="${VERSION_LINES[1]:-1}"

STAGING="$ROOT_DIR/artifacts/${SLUG}"
DIST_DIR="$ROOT_DIR/dist"
mkdir -p "$DIST_DIR"

VERSION_FILE="$STAGING/VERSION.txt"
cat > "$VERSION_FILE" <<EOF
ffmpeg=${FFMPEG_VERSION}
lame=${LAME_VERSION}
recipe=${RECIPE_VERSION}
slug=${SLUG}
EOF

ARCHIVE_BASE="genesys-ffmpeg-minimal-${FFMPEG_VERSION}-r${RECIPE_VERSION}-${SLUG}"

case "$SLUG" in
  win*)
    ARCHIVE="$DIST_DIR/${ARCHIVE_BASE}.zip"
    rm -f "$ARCHIVE"
    (cd "$STAGING" && zip -r "$ARCHIVE" bin VERSION.txt)
    ;;
  *)
    ARCHIVE="$DIST_DIR/${ARCHIVE_BASE}.tar.xz"
    rm -f "$ARCHIVE"
    tar -cJf "$ARCHIVE" -C "$STAGING" bin VERSION.txt
    ;;
esac

if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "$ARCHIVE" | tee "$ARCHIVE.sha256"
elif command -v shasum >/dev/null 2>&1; then
  shasum -a 256 "$ARCHIVE" | tee "$ARCHIVE.sha256"
fi

echo "Packaged ${ARCHIVE}"
