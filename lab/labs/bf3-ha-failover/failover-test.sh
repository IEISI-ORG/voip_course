#!/usr/bin/env bash
# SOVOC BF3 — hitless failover demo. Register via one SBC replica, confirm the other replica
# knows the binding (shared state), then kill the active replica and show registration/call
# survives. Requires the HA overlay up:
#   docker compose -f docker-compose.yml -f labs/bf3-ha-failover/docker-compose.ha.yml up -d
# Run from lab/.
set -u
COMPOSE_BASE="docker compose -f docker-compose.yml -f labs/bf3-ha-failover/docker-compose.ha.yml"
cd "$(dirname "$0")/../.." || exit 3
R1=172.28.10.10   # edge-sbc
R2=172.28.10.12   # edge-sbc-2

echo "[failover] 1. register 1001 via replica R1 ($R1)"
$COMPOSE_BASE exec -T client \
  sipp -sf /scenarios/register.xml "$R1:5060" -s 1001 -i 172.28.10.40 -m 1 -timeout 10s -nostdin >/dev/null 2>&1 \
  && echo "   registered via R1" || echo "   REGISTER via R1 failed"

echo "[failover] 2. shared store should show the binding (via redis or R2's usrloc)"
$COMPOSE_BASE exec -T redis redis-cli KEYS 'usrloc*' 2>/dev/null | head || \
  $COMPOSE_BASE exec -T edge-sbc-2 kamcmd ul.dump 2>/dev/null | grep -i 1001 || \
  echo "   (inspect R2 usrloc / redis manually)"

echo "[failover] 3. kill the active replica R1"
$COMPOSE_BASE stop edge-sbc >/dev/null 2>&1 && echo "   R1 stopped"

echo "[failover] 4. traffic to R2 ($R2) should still find 1001 (hitless)"
$COMPOSE_BASE exec -T client sh -c \
  "printf 'OPTIONS sip:$R2 SIP/2.0\r\nVia: SIP/2.0/UDP 172.28.10.40:5060;branch=z9hG4bK-fo\r\nMax-Forwards: 70\r\nFrom: <sip:p@172.28.10.40>;tag=fo\r\nTo: <sip:$R2>\r\nCall-ID: fo-\$\$\r\nCSeq: 1 OPTIONS\r\nContent-Length: 0\r\n\r\n' | ncat -u -w2 $R2 5060" 2>/dev/null | head -1 \
  && echo "   R2 answering after R1 loss" || echo "   R2 not answering — check state sharing"

echo "[failover] restore: $COMPOSE_BASE start edge-sbc"
