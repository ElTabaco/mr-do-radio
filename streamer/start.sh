#!/bin/bash
set -euo pipefail

# Configuration
FIFO_DIR=/tmp/music
FIFO_PATH="$FIFO_DIR/radiofifo"
ICECAST_URL="icecast:8000"
ICECAST_MOUNT="/mystream.mp3"
ICECAST_USER="source"
ICECAST_PASS="hackme"

mkdir -p "$FIFO_DIR"

echo "Waiting for FIFO writer at $FIFO_PATH..."
while [ ! -p "$FIFO_PATH" ]; do
  sleep 1
done

# Stream from FIFO to Icecast
# Reads raw S16_LE 48kHz stereo audio from the FIFO
FFMPEG_CMD=(
  ffmpeg -re -f s16le -ar 48000 -ac 2 -i "$FIFO_PATH"
  -c:a libmp3lame -b:a 192k -f mp3
  "icecast://${ICECAST_USER}:${ICECAST_PASS}@${ICECAST_URL}${ICECAST_MOUNT}"
)

echo "Starting ffmpeg to stream from FIFO to Icecast..."
exec "${FFMPEG_CMD[@]}"
