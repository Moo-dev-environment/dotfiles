# mpv

**mpv** is a minimal, scriptable, GPU-accelerated media player — plays basically
any video/audio file (and streams, via yt-dlp). It's keyboard-driven and
configured with two plain-text files:

- `mpv.conf` — playback **settings** (video output, scaling, audio, subtitles,
  screenshots, caching, window behaviour).
- `input.conf` — **keybindings**.

Files:

- **Live path:** `~/.config/mpv` → symlink → `mpv/` (this dir)
- **Editing here edits the live config.** Changes apply on the **next** mpv
  launch (mpv reads its config at startup; there's no live reload).
- Open something: `mpv video.mkv`, `mpv https://youtu.be/…`, or open files with
  mpv from your file manager.

## Custom speed controls (the headline feature)

mpv's stock `[` / `]` change speed by ±10% *multiplicatively*. This config
overrides them to clean **additive 0.25× steps**, which is far more predictable:

| Key | Action |
|---|---|
| `]` | speed **+0.25×** (faster) |
| `[` | speed **−0.25×** (slower) |
| `Backspace` | reset to **1.0×** (normal) |

So tapping `]` three times from normal → 1.75×; `[` from there → 1.5×.
Pitch stays natural (no chipmunk voices) because `audio-pitch-correction=yes` is
set in `mpv.conf`.

## What `mpv.conf` does (highlights)

It's fully commented — open it to read each line. The important choices:

- **`vo=gpu-next` + high-quality scalers** (`ewa_lanczossharp`, sigmoid
  upscaling, debanding, dithering) → sharp, clean video with no colour banding.
- **`hwdec=auto-safe`** → uses the GPU to decode when safe, saving battery/CPU.
- **`save-position-on-quit=yes`** → reopen a file and it resumes where you left
  off.
- **`keep-open=yes`** → the window pauses on the last frame instead of closing.
- **Subtitles** auto-load (`sub-auto=fuzzy`), with a readable white-on-black
  outline.
- **Screenshots** save lossless PNGs to `~/Pictures/mpv` (default key `s`).
- **`ytdl-format=…1080p…`** → streaming sites play at up to 1080p via yt-dlp.

## Handy default keys (not overridden here)

| Key | Action |
|---|---|
| `Space` | play / pause |
| `←` / `→` | seek ∓5s · `↑`/`↓` seek ∓1min |
| `9` / `0` | volume down / up |
| `m` | mute |
| `f` | fullscreen toggle |
| `s` | screenshot (with subtitles) · `S` without |
| `,` / `.` | step back / forward one frame |
| `<` / `>` | previous / next file in playlist |
| `q` | quit (saves position) · `Q` quit without saving |

Full list: `mpv --input-keylist` or <https://mpv.io/manual/stable/#interactive-control>.

## Customising

- **Change the speed step:** edit the `0.25` values in `input.conf`.
- **Add a binding:** append `KEY command args` to `input.conf` (see the keylist
  for command names).
- **Lower GPU load** (older hardware): set `scale=bilinear` and `deband=no` in
  `mpv.conf`, or `vo=gpu` instead of `gpu-next`.

## Validate after editing

```bash
# Load this config against a 1-frame synthetic clip with null output;
# any bad option in mpv.conf/input.conf prints an error at startup:
mpv --config-dir=$HOME/.config/mpv --vo=null --ao=null --frames=1 \
    av://lavfi:testsrc 2>&1 | grep -iE 'error|not found|invalid' \
    || echo "config OK"
```

## Reference

- Options (mpv.conf): <https://mpv.io/manual/stable/#options>
- Commands & keys (input.conf): <https://mpv.io/manual/stable/#command-interface>
