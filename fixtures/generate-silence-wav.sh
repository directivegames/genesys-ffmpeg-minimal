#!/usr/bin/env bash
# Writes fixtures/silence.wav — 0.1s mono 16-bit PCM @ 44100 Hz.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$ROOT_DIR/fixtures/silence.wav"
mkdir -p "$(dirname "$OUT")"

python3 - <<'PY' "$OUT"
import struct
import sys

out = sys.argv[1]
sample_rate = 44100
channels = 1
bits = 16
duration = 0.1
num_samples = int(sample_rate * duration)
data_size = num_samples * channels * (bits // 8)
byte_rate = sample_rate * channels * bits // 8
block_align = channels * bits // 8

with open(out, "wb") as f:
    f.write(b"RIFF")
    f.write(struct.pack("<I", 36 + data_size))
    f.write(b"WAVEfmt ")
    f.write(struct.pack("<IHHIIHH", 16, 1, channels, sample_rate, byte_rate, block_align, bits))
    f.write(b"data")
    f.write(struct.pack("<I", data_size))
    f.write(b"\x00" * data_size)
PY

echo "Wrote $OUT"
