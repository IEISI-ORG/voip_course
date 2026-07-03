# VoIPSec pbx-a — Asterisk application server (Stage A2)
# Debian bookworm ships Asterisk 20 (LTS), which keeps the lab reproducible without a
# third-party image. TLS/SRTP arrive in M10/M11; this base is chan_pjsip only, closed by default.
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
      asterisk asterisk-config gettext-base ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Overlay our security-oriented configs (overwrites the risky defaults).
COPY etc/ /etc/asterisk/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh \
    && rm -f /etc/asterisk/sip.conf   # ensure legacy chan_sip has no config to load

EXPOSE 5060/udp 5060/tcp 10000-10100/udp
HEALTHCHECK --interval=15s --timeout=5s --retries=4 \
  CMD asterisk -rx 'core show uptime' 2>/dev/null | grep -q 'System uptime' || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# Foreground, no colour, run as the asterisk user.
CMD ["asterisk", "-f", "-U", "asterisk", "-G", "asterisk"]
