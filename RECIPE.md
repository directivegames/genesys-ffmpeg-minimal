# Genesys minimal FFmpeg recipe

Build spec for the `@gnsx/genesys.sdk` MP3 asset baker.

## Purpose

Produce a **small static `ffmpeg` CLI** that transcodes loose audio in `.dist` to
MP3. Used by Genesys at build time only (not shipped to game runtime as a general
tool).

## Inputs → output

| Input extensions | Decoder path |
| --- | --- |
| `.wav` | PCM demuxer + PCM decoders |
| `.aiff` / `.aif` | AIFF demuxer + PCM |
| `.flac` | FLAC demuxer + FLAC decoder |
| `.ogg` | OGG demuxer + Vorbis/Opus decoder |
| `.aac` / `.m4a` | MOV demuxer + AAC decoder |

| Output | Encoder |
| --- | --- |
| `.mp3` | `libmp3lame` |

Already-MP3 sources are skipped by the Genesys baker; including MP3 demux/decode
in ffmpeg is optional and omitted in v1 to save size.

## Platforms (release matrix)

| GitHub artifact slug | Genesys vendor path |
| --- | --- |
| `win64-static` | `vendor/ffmpeg/win32-x64/bin/` |
| `linux64-static` | `vendor/ffmpeg/linux-x64/bin/` |
| `linuxarm64-static` | `vendor/ffmpeg/linux-arm64/bin/` |
| `macos-arm64-static` | `vendor/ffmpeg/darwin-arm64/bin/` |
| `macos-x64-static` | `vendor/ffmpeg/darwin-x64/bin/` |

## Configure flags

Shared flags live in [`configure-flags.sh`](configure-flags.sh). When changing
them, bump the **recipe version** (second line of [`VERSION`](VERSION)) so
Genesys can invalidate its compile cache.

## Smoke test (acceptance)

From repo root after a build:

```bash
./scripts/smoke-test.sh artifacts/win64-static/bin/ffmpeg.exe
```

Checks:

1. `ffmpeg -version` succeeds
2. `libmp3lame` appears in `-encoders`
3. `fixtures/silence.wav` → temp MP3 succeeds
4. Output looks like MP3 and is smaller than WAV

## Legal

- Build scripts in this repo: **MIT**
- Published binaries: **GPL-2.0-or-later** (FFmpeg) + **LGPL-2.0-or-later** (LAME)
- Genesys `THIRD_PARTY_NOTICES.md` must cite this repo + release tag + upstream
  FFmpeg/LAME sources
