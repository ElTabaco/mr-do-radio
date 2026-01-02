# mr-do-radio

Local internet radio streaming stack. Audio from snapclient flows to a shared FIFO (`/tmp/music/radiofifo`), which the streamer encodes as MP3 and pushes to Icecast.

## Architecture

```
snapclient → /dev/snd (loopback audio) → /tmp/music/radiofifo → streamer (ffmpeg) → Icecast → HTTP stream
```

- **snapclient**: Listens to Snapcast audio output, writes raw PCM to FIFO
- **streamer**: Reads FIFO, encodes to MP3, streams to Icecast
- **icecast**: HTTP streaming server (port 8000)

## Quick Start

```bash
# Start all services
docker compose up -d --build

# View Icecast status
open http://localhost:8000/

# Watch logs
docker compose logs -f streamer
docker compose logs -f snapclient
```

## Configuration

### asound.conf (Host)

The `asound.conf` file in this repo configures ALSA to route audio to `/tmp/music/radiofifo`. Copy it to your host:

```bash
sudo cp asound.conf /etc/asound.conf
# or for user-only config:
cp asound.conf ~/.asoundrc
```

### Icecast Credentials

Default: `source` / `hackme` (change in `docker-compose.yml` for production)

Mount point: `/mystream.mp3` at `http://localhost:8000/mystream.mp3`

## Testing Without Real Audio

Generate a test 440Hz sine wave:

```bash
docker compose exec streamer python3 /app/generate_test_tone.py &
```

This writes to the FIFO so ffmpeg can stream it to Icecast immediately.

## Files

- **docker-compose.yml**: Service definitions (icecast, streamer, snapclient)
- **streamer/start.sh**: Reads FIFO, streams to Icecast via ffmpeg
- **streamer/Dockerfile**: Ubuntu + ffmpeg + python3
- **streamer/generate_test_tone.py**: Test tone utility (440Hz sine)
- **asound.conf**: ALSA configuration example (writes to `/tmp/music/radiofifo`)
- **icecast/config/icecast.xml**: Icecast server config

## Notes

- FIFO path: `/tmp/music/radiofifo` (shared Docker volume `music`)
- Audio format: raw PCM S16_LE, 48kHz, stereo
- Encoding: MP3 192kbps
- snapclient needs `/dev/snd` device access for audio output
- Docker volume `music` is created automatically by `docker compose up`
