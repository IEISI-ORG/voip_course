# SOVOC edge-sbc — Kamailio border SBC (Stage A1)
# Pin KAMAILIO_TAG in .env; verify the tag exists on the official image before a cohort runs.
ARG KAMAILIO_TAG=5.8-alpine
FROM kamailio/kamailio:${KAMAILIO_TAG}

# Config is bind-friendly but baked for reproducibility.
COPY kamailio.cfg /etc/kamailio/kamailio.cfg
COPY tls.cfg      /etc/kamailio/tls.cfg
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# entrypoint substitutes the topoh mask secret from the environment (never committed)
# and generates a self-signed cert on first boot if none is mounted (real CA in M10).
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 5060/udp 5060/tcp 5061/tcp

# Liveness: kamailio answers its own OPTIONS ping locally.
HEALTHCHECK --interval=15s --timeout=5s --retries=4 \
  CMD kamcmd core.uptime >/dev/null 2>&1 || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["kamailio", "-DD", "-E", "-m", "64", "-M", "8"]
