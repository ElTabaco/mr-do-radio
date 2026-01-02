FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY start.sh generate_test_tone.py ./
RUN chmod +x ./start.sh

CMD ["./start.sh"]
