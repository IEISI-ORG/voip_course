# SOVOC redteam — authorized offensive-testing toolbox (Stage A6)
#
# AUTHORIZED LAB USE ONLY. This container attaches to the `edge`/`redteam` networks only
# (enforced in docker-compose.yml) and ships with a scope guard. Scanning or testing any
# system without written authorization is illegal. See AUTHORIZED_USE.md.
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
      python3 python3-pip sip-tester ncat iproute2 iputils-ping bash ca-certificates \
    && pip3 install --break-system-packages sipvicious \
    && rm -rf /var/lib/apt/lists/*

COPY AUTHORIZED_USE.md /opt/redteam/AUTHORIZED_USE.md
COPY scripts/ /opt/redteam/scripts/
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh /opt/redteam/scripts/*.sh \
    && ln -s /opt/redteam/scripts/*.sh /usr/local/bin/ 2>/dev/null || true

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
# Idle by default; `docker compose exec -it redteam bash` to work interactively.
CMD ["sleep", "infinity"]
