#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <path/to/ffmpeg[.exe]>" >&2
  exit 1
fi

FFMPEG="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FIXTURES="$ROOT_DIR/fixtures"

if [[ ! -x "$FFMPEG" ]] && [[ ! -f "$FFMPEG" ]]; then
  echo "ffmpeg not found: $FFMPEG" >&2
  exit 1
fi

if [[ ! -f "$FIXTURES/silence.wav" ]]; then
  "$FIXTURES/generate-silence-wav.sh"
fi

echo "==> Smoke test: $FFMPEG"
"$FFMPEG" -hide_banner -version | head -n 1

ENCODERS="$("$FFMPEG" -hide_banner -encoders 2>&1)"
if ! grep -qi libmp3lame <<< "$ENCODERS"; then
  echo "libmp3lame encoder missing" >&2
  exit 1
fi

OUT="$(mktemp "${TMPDIR:-/tmp}/genesys-smoke-XXXXXX.mp3")"
trap 'rm -f "$OUT"' EXIT

"$FFMPEG" -hide_banner -loglevel error -y -i "$FIXTURES/silence.wav" -codec:a libmp3lame -b:a 128k "$OUT"

BYTES="$(wc -c < "$OUT" | tr -d ' ')"
if [[ "$BYTES" -lt 100 ]]; then
  echo "MP3 output too small (${BYTES} bytes)" >&2
  exit 1
fi

WAV_BYTES="$(wc -c < "$FIXTURES/silence.wav" | tr -d ' ')"
if [[ "$BYTES" -ge "$WAV_BYTES" ]]; then
  echo "MP3 should be smaller than WAV (${BYTES} vs ${WAV_BYTES})" >&2
  exit 1
fi

echo "    libmp3lame OK, encoded ${WAV_BYTES} B WAV -> ${BYTES} B MP3"
echo "==> Smoke test passed"
