# Media transcoding. Inline ffmpeg/imagemagick (portable) rather than
# Omarchy's `omarchy-transcode` binary, which only exists on Omarchy boxes.

if command -v ffmpeg &>/dev/null; then
  transcode-video-1080p() {
    ffmpeg -i "$1" -vf scale=1920:1080 -c:v libx264 -preset fast -crf 23 -c:a copy "${1%.*}-1080p.mp4"
  }
  transcode-video-4K() {
    ffmpeg -i "$1" -c:v libx265 -preset slow -crf 24 -c:a aac -b:a 192k "${1%.*}-optimized.mp4"
  }
  gif2mp4() {
    ffmpeg -i "$1" -vf "fps=15,scale=trunc(iw/2)*2:trunc(ih/2)*2" \
      -c:v libx264 -pix_fmt yuv420p -movflags faststart "${1%.*}.mp4"
  }
fi

if command -v magick &>/dev/null; then
  img2jpg()        { local img="$1"; shift; magick "$img" "$@" -quality 95 -strip "${img%.*}-converted.jpg"; }
  img2jpg-small()  { local img="$1"; shift; magick "$img" "$@" -resize 1080x\> -quality 95 -strip "${img%.*}-small.jpg"; }
  img2jpg-medium() { local img="$1"; shift; magick "$img" "$@" -resize 1800x\> -quality 95 -strip "${img%.*}-medium.jpg"; }
  img2png()        {
    local img="$1"; shift
    magick "$img" "$@" -strip \
      -define png:compression-filter=5 \
      -define png:compression-level=9 \
      -define png:compression-strategy=1 \
      -define png:exclude-chunk=all \
      "${img%.*}-optimized.png"
  }
fi
