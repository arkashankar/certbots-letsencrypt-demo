FROM debian:bookworm-slim

RUN apt-get update -y && \
    apt-get install -y certbot && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
