# VoIPSec pbx-b — FreeSWITCH application server (Stage A3)
#
# FreeSWITCH's own Debian packages are now token-gated, so the lab uses a community image
# for reproducibility. Pin FREESWITCH_IMAGE and verify it before a cohort runs. We keep the
# image's working default config and overlay only security-hardening files onto the standard
# include points (autoload_configs/, dialplan/, directory/default/).
ARG FREESWITCH_IMAGE=safarov/freeswitch:latest
FROM ${FREESWITCH_IMAGE}

# Overlay hardening config (uses standard FreeSWITCH X-PRE-PROCESS include dirs).
COPY conf/ /etc/freeswitch/
COPY entrypoint.sh /usr/local/bin/voipsec-entrypoint.sh
RUN chmod +x /usr/local/bin/voipsec-entrypoint.sh

EXPOSE 5060/udp 5060/tcp 16384-16484/udp
HEALTHCHECK --interval=15s --timeout=5s --retries=4 \
  CMD fs_cli -x 'status' 2>/dev/null | grep -q 'UP ' || exit 1

ENTRYPOINT ["/usr/local/bin/voipsec-entrypoint.sh"]
CMD ["freeswitch", "-nonat", "-nc", "-nf"]
