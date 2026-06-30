#!/usr/bin/env bash
# Shared ./configure flags for Genesys minimal ffmpeg (source: RECIPE.md).
# shellcheck disable=SC2034

GENESYS_FFMPEG_CONFIGURE_FLAGS=(
  --enable-gpl
  --enable-version3
  --enable-libmp3lame

  --enable-small
  --enable-pic
  --enable-asm

  --disable-debug
  --disable-doc
  --disable-avdevice
  --disable-swscale
  --disable-postproc
  --disable-network

  # The ffmpeg CLI hard-depends on libavfilter (and swresample for audio
  # format conversion). Keep avfilter enabled but strip it down to the audio
  # filters the transcode path actually needs (abuffer/abuffersink sources and
  # sinks are always built in).
  --enable-avfilter
  --disable-filters
  --enable-filter=aresample
  --enable-filter=aformat
  --enable-filter=anull
  --enable-filter=acopy
  --enable-filter=atrim

  --disable-hwaccels
  --disable-vulkan
  --disable-videotoolbox
  --disable-audiotoolbox
  --disable-libopenjpeg

  --disable-protocols
  --enable-protocol=file
  --enable-protocol=pipe

  --disable-indevs
  --disable-outdevs

  # No video/display stack — avoid autodetecting Homebrew X11 on macOS CI.
  --disable-xlib
  --disable-libxcb
  --disable-libxcb-shm
  --disable-libxcb-xfixes
  --disable-libxcb-shape
  --disable-sdl2

  --disable-ffprobe
  --disable-ffplay
  --enable-ffmpeg

  --disable-muxers
  --enable-muxer=mp3

  --disable-demuxers
  --enable-demuxer=wav
  --enable-demuxer=aiff
  --enable-demuxer=flac
  --enable-demuxer=ogg
  --enable-demuxer=mov

  --disable-parsers
  --enable-parser=flac
  --enable-parser=vorbis
  --enable-parser=opus
  --enable-parser=aac
  --enable-parser=aac_latm
  --enable-parser=mpegaudio

  --disable-decoders
  --enable-decoder=pcm_s16le
  --enable-decoder=pcm_s24le
  --enable-decoder=pcm_s32le
  --enable-decoder=pcm_f32le
  --enable-decoder=pcm_s16be
  --enable-decoder=pcm_s24be
  --enable-decoder=pcm_s32be
  --enable-decoder=pcm_f32be
  --enable-decoder=flac
  --enable-decoder=vorbis
  --enable-decoder=opus
  --enable-decoder=aac
  --enable-decoder=aac_latm

  --disable-encoders
  --enable-encoder=libmp3lame
)
