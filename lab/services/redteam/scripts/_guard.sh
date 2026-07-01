#!/bin/sh
# SOVOC redteam — shared scope guard. Sourced by every helper. Refuses any target outside the
# authorized lab subnets. Do not remove this to "test something real" (see AUTHORIZED_USE.md).
sovoc_guard() {
  _t="$1"
  case "$_t" in
    172.28.10.*|172.28.40.*) return 0 ;;
    *)
      echo "REFUSED: '$_t' is outside the authorized lab range (172.28.10.0/24, 172.28.40.0/24)." >&2
      echo "This tooling is for the SOVOC lab only. See /opt/redteam/AUTHORIZED_USE.md" >&2
      exit 2 ;;
  esac
}
