# genesys-ffmpeg-minimal

Minimal **static `ffmpeg`** builds for the [Genesys](https://github.com/directivegames/genesys-monorepo) SDK
MP3 asset baker. Produces a small CLI that transcodes loose audio in `.dist` to MP3
(WAV / FLAC / AIFF / OGG / AAC / M4A → MP3 via `libmp3lame`).

Build scripts in this repo are **MIT**. Published binaries are **GPL-2.0-or-later**
(FFmpeg) and **LGPL-2.0-or-later** (LAME). See [RECIPE.md](RECIPE.md).

## Why a separate repo?

- Full BtbN ffmpeg builds are ~130 MB; this recipe targets ~5–15 MB.
- GPL/LAME native builds are slow and platform-specific — keep them out of the monorepo.
- Genesys pins a release tag + SHA256 from here in `vendor:ffmpeg`.

## Layout

```
configure-flags.sh     # shared ./configure recipe (Genesys scope)
VERSION                # line 1: ffmpeg version, line 2: recipe revision
scripts/
  build-windows-mingw.sh   # MSYS2 MinGW64 — primary path
  build-linux-gnu.sh       # glibc static
  build-macos.sh             # stub (phase 2)
  build-lame.sh / build-ffmpeg.sh
  package.sh / smoke-test.sh
fixtures/                # WAV fixture + generator
.github/workflows/       # CI + release
```

Inspired by [wo80/ffmpeg-audio-only](https://github.com/wo80/ffmpeg-audio-only) configure
patterns and [BtbN/FFmpeg-Builds](https://github.com/BtbN/FFmpeg-Builds) LAME linkage —
**not** a fork; recipe is trimmed to Genesys inputs only.

## Local build (Windows + MSYS2 MinGW64)

1. Open **MSYS2 MinGW 64-bit**.
2. Install toolchain:

   ```bash
   pacman -S --needed mingw-w64-x86_64-{gcc,make,pkg-config,nasm,yasm} zip curl python
   ```

3. From repo root:

   ```bash
   bash ./scripts/build-windows-mingw.sh
   ```

4. Output: `dist/genesys-ffmpeg-minimal-<ffmpeg>-r<recipe>-win64-static.zip`
   containing `bin/ffmpeg.exe` and `VERSION.txt`.

## CI

- **CI** (push/PR): builds `win64-static` + `linux64-static`, runs smoke test.
- **Release** (tag `v*` or manual): uploads both archives to GitHub Releases.

## Smoke test

```bash
bash ./scripts/smoke-test.sh artifacts/win64-static/bin/ffmpeg.exe
```

## Genesys integration (monorepo)

After a release is published:

1. Pin tag + checksum in `packages/sdk/scripts/vendor-ffmpeg.ts`.
2. Download `genesys-ffmpeg-minimal-*-win64-static.zip` → `vendor/ffmpeg/win32-x64/bin/`.
3. Run `pnpm --filter @gnsx/genesys.sdk test -- test/mp3-audio-compiler.integration.test.ts`.

## Roadmap

- [ ] First green CI on `main`
- [ ] Tag `v0.1.0` with measured binary sizes in release notes
- [ ] macOS arm64/x64 jobs
- [ ] linux-arm64
- [ ] Wire Genesys `vendor-ffmpeg.ts` to this repo (replace BtbN)

## Bump checklist

When changing `configure-flags.sh`:

1. Increment **recipe version** (line 2 of `VERSION`).
2. Re-run smoke tests on all platforms.
3. Tag a new release; bump pin in Genesys monorepo.
