#!/bin/bash

# Check if a movie file will require transcoding when played via Plex on Apple TV.
# Usage: plex_appletv_check.sh <filepath>

if [ $# -ne 1 ]; then
    echo "Usage: $0 <movie_file>" >&2
    exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo "File not found: $FILE" >&2
    exit 1
fi

if ! command -v ffprobe &>/dev/null; then
    echo "ffprobe not found. Install ffmpeg." >&2
    exit 1
fi

# Extract stream info
INFO=$(ffprobe -v quiet -print_format json -show_streams "$FILE" 2>/dev/null)

if [ -z "$INFO" ]; then
    echo "Could not read file: $FILE" >&2
    exit 1
fi

VIDEO_CODEC=$(echo "$INFO" | python3 -c "import json,sys; s=[s for s in json.load(sys.stdin)['streams'] if s['codec_type']=='video']; print(s[0]['codec_name'] if s else '')")
VIDEO_PROFILE=$(echo "$INFO" | python3 -c "import json,sys; s=[s for s in json.load(sys.stdin)['streams'] if s['codec_type']=='video']; print(s[0].get('profile','') if s else '')")
VIDEO_LEVEL=$(echo "$INFO" | python3 -c "import json,sys; s=[s for s in json.load(sys.stdin)['streams'] if s['codec_type']=='video']; print(s[0].get('level','') if s else '')")
AUDIO_CODEC=$(echo "$INFO" | python3 -c "import json,sys; s=[s for s in json.load(sys.stdin)['streams'] if s['codec_type']=='audio']; print(s[0]['codec_name'] if s else '')")
CONTAINER=$(echo "$FILE" | sed 's/.*\.//' | tr '[:upper:]' '[:lower:]')

needs_transcode=0
reasons=()

# --- Container check ---
case "$CONTAINER" in
    mp4|mov|m4v|mkv) ;;
    *)
        needs_transcode=1
        reasons+=("Container '$CONTAINER' is not supported by Apple TV (use MP4/MKV/MOV)")
        ;;
esac

# --- Video codec check ---
case "$VIDEO_CODEC" in
    h264)
        # H.264 is fine up to High Profile Level 5.1
        if [[ "$VIDEO_PROFILE" == *"High 10"* ]]; then
            needs_transcode=1
            reasons+=("Video: H.264 High 10-bit profile requires transcoding")
        elif [ -n "$VIDEO_LEVEL" ] && [ "$VIDEO_LEVEL" -gt 51 ] 2>/dev/null; then
            needs_transcode=1
            reasons+=("Video: H.264 level $VIDEO_LEVEL exceeds Apple TV max (5.1)")
        fi
        ;;
    hevc|h265)
        # HEVC supported on Apple TV 4K; not on older Apple TV HD
        ;;
    mpeg4|xvid|divx|msmpeg4v3|msmpeg4v2|msmpeg4v1)
        needs_transcode=1
        reasons+=("Video: '$VIDEO_CODEC' is not supported by Apple TV — full video transcode required")
        ;;
    mpeg2video|mpeg1video)
        needs_transcode=1
        reasons+=("Video: MPEG-2/1 is not supported by Apple TV — full video transcode required")
        ;;
    vp8)
        needs_transcode=1
        reasons+=("Video: VP8 is not supported by Apple TV — full video transcode required")
        ;;
    wmv2|wmv3|vc1)
        needs_transcode=1
        reasons+=("Video: WMV/VC-1 is not supported by Apple TV — full video transcode required")
        ;;
    *)
        needs_transcode=1
        reasons+=("Video: Unknown codec '$VIDEO_CODEC' — likely requires transcoding")
        ;;
esac

# --- Audio codec check ---
# AC3/EAC3/DTS require passthrough; if Apple TV audio output is not configured for
# passthrough (e.g. plugged directly into a TV), Plex will transcode audio.
case "$AUDIO_CODEC" in
    aac|alac)
        # Native Apple TV support — no transcode needed
        ;;
    ac3|eac3|dts|truehd|mlp)
        reasons+=("Audio: '$AUDIO_CODEC' requires Dolby/DTS passthrough on your Apple TV audio output. If not configured, Plex will transcode audio (video may still direct play)")
        ;;
    mp3)
        needs_transcode=1
        reasons+=("Audio: MP3 requires audio transcoding on Apple TV")
        ;;
    vorbis|opus|flac|pcm_*)
        needs_transcode=1
        reasons+=("Audio: '$AUDIO_CODEC' requires audio transcoding on Apple TV")
        ;;
    wmav2|wmav1)
        needs_transcode=1
        reasons+=("Audio: WMA requires audio transcoding on Apple TV")
        ;;
    *)
        reasons+=("Audio: Unknown codec '$AUDIO_CODEC' — may require transcoding")
        ;;
esac

# --- Report ---
echo "File:      $FILE"
echo "Container: $CONTAINER"
echo "Video:     $VIDEO_CODEC ($VIDEO_PROFILE, level $VIDEO_LEVEL)"
echo "Audio:     $AUDIO_CODEC"
echo ""

if [ $needs_transcode -eq 1 ]; then
    echo "RESULT: WILL REQUIRE TRANSCODING"
    echo ""
    for r in "${reasons[@]}"; do
        echo "  - $r"
    done
    echo ""
    echo "Suggested fix:"
    if [[ "$VIDEO_CODEC" != "h264" && "$VIDEO_CODEC" != "hevc" ]]; then
        echo "  ffmpeg -i \"$FILE\" -c:v libx264 -preset slow -crf 18 -c:a copy \"${FILE%.*}.mp4\""
    else
        echo "  ffmpeg -i \"$FILE\" -c:v copy -c:a aac -b:a 320k \"${FILE%.*}_aac.mp4\""
    fi
    exit 1
else
    echo "RESULT: OK — should direct play on Apple TV"
    if [ ${#reasons[@]} -gt 0 ]; then
        echo ""
        echo "Notes:"
        for r in "${reasons[@]}"; do
            echo "  - $r"
        done
    fi
    exit 0
fi
