# VoIPSec trunk-sim — simulated PSTN peer (Stage A4)
# SIPp-based external trunk on the edge. Answers outbound calls (UAS) and can originate
# inbound "PSTN" calls (UAC) against the SBC. Reproducible from Debian's sip-tester package.
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
      sip-tester ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY scenarios/ /scenarios/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 5060/udp
HEALTHCHECK --interval=15s --timeout=5s --retries=4 \
  CMD pidof sipp >/dev/null || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# Default role: answer inbound (act as the PSTN). Override CMD to originate (uac_inbound).
CMD ["uas"]
