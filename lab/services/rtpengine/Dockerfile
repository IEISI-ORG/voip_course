# SOVOC rtpengine — media relay / SRTP bridge (Stage A1)
#
# No official rtpengine image exists, so we build the daemon from source in USERSPACE
# mode (no kernel module — correct for a container lab; kernel forwarding is a prod topic
# covered in M16). Pin RTPENGINE_REF to a release tag.
#
# NOTE: rtpengine's build dependencies change across versions. This dep set targets the
# mr12.x series on Debian bookworm; if you bump RTPENGINE_REF, reconcile against the
# upstream `debian/control` / README for that tag.
FROM debian:bookworm-slim AS build
ARG RTPENGINE_REF=mr12.5.1.1
RUN apt-get update && apt-get install -y --no-install-recommends \
      git ca-certificates build-essential pkg-config \
      libglib2.0-dev libssl-dev libavcodec-dev libavformat-dev libavutil-dev \
      libswresample-dev libavfilter-dev libpcre2-dev libhiredis-dev libjson-glib-dev \
      libcurl4-openssl-dev libpcap-dev libmnl-dev libnftnl-dev libmosquitto-dev \
      libwebsockets-dev libspandsp-dev zlib1g-dev libncurses-dev libbcg729-dev \
    && rm -rf /var/lib/apt/lists/*
RUN git clone --depth 1 --branch ${RTPENGINE_REF} https://github.com/sipwise/rtpengine.git /src \
    && make -C /src/daemon

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
      libglib2.0-0 libssl3 libavcodec59 libavformat59 libavutil57 libswresample4 \
      libavfilter8 libpcre2-8-0 libhiredis0.14 libjson-glib-1.0-0 libcurl4 libpcap0.8 \
      libmnl0 libnftnl11 libmosquitto1 libwebsockets17 libspandsp2 libncurses6 libbcg729-0 \
    && rm -rf /var/lib/apt/lists/*
COPY --from=build /src/daemon/rtpengine /usr/local/bin/rtpengine
COPY rtpengine.conf /etc/rtpengine/rtpengine.conf

# Media port range kept small for the lab (see rtpengine.conf).
EXPOSE 2223/udp 30000-30100/udp
HEALTHCHECK --interval=15s --timeout=5s --retries=4 \
  CMD sh -c 'pidof rtpengine >/dev/null' || exit 1

CMD ["rtpengine", "--config-file=/etc/rtpengine/rtpengine.conf"]
