# Prebuilt dedicated Linux server: avoids a resource-intensive Rust build on a small VPS.
# Binary and licence are from the official openOMSI release, SHA256 verified before extraction.
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates libasound2 libudev1 curl \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /opt/openomsi
COPY bin/openomsi bin/libsteam_api.so bin/LICENSE ./
RUN chmod 0755 /opt/openomsi/openomsi && chmod 0644 /opt/openomsi/libsteam_api.so
ENV LD_LIBRARY_PATH=/opt/openomsi
EXPOSE 27015/udp 27015/tcp 27025/tcp
HEALTHCHECK --interval=30s --timeout=5s --start-period=10m CMD curl -fsS http://127.0.0.1:27025/status >/dev/null || exit 1
ENTRYPOINT ["/opt/openomsi/openomsi"]
CMD ["--root", "/omsi", "--server", "/server/server.cfg"]
