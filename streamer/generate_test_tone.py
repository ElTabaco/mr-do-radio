#!/usr/bin/env python3
"""Generate test sine wave (440Hz) to FIFO for testing without real audio source."""
import math
import struct
import time

FIFO = '/tmp/music/radiofifo'
SAMPLE_RATE = 48000
FREQUENCY = 440.0
AMPLITUDE = 0.3

def main():
    """Write continuous sine wave to FIFO."""
    while True:
        try:
            with open(FIFO, 'wb') as f:
                t = 0.0
                dt = 1.0 / SAMPLE_RATE
                while True:
                    sample = AMPLITUDE * math.sin(2 * math.pi * FREQUENCY * t)
                    sample = int(max(-1.0, min(1.0, sample)) * 32767)
                    frame = struct.pack('<hh', sample, sample)  # stereo: same sample twice
                    f.write(frame)
                    t += dt
                    if int(t * SAMPLE_RATE) % 1024 == 0:
                        f.flush()
        except FileNotFoundError:
            time.sleep(0.5)
        except BrokenPipeError:
            time.sleep(0.5)

if __name__ == '__main__':
    main()
