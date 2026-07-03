# VoIPSec client — softphone + load-test toolbox (Stage A4)
# Baresip (scriptable softphone) + SIPp (load/conformance) on the edge, acting as external
# users registering through the SBC. Interactive by default: exec in to drive calls.
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
      baresip sip-tester gettext-base ca-certificates iputils-ping ncat \
    && rm -rf /var/lib/apt/lists/*

COPY baresip/ /etc/voipsec/baresip/
COPY scenarios/ /scenarios/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Idle by default; learners `docker compose exec client ...` to run baresip/sipp.
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
