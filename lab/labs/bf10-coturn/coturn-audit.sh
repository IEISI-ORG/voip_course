#!/usr/bin/env bash
# VoIPSec BF10 — audit a coturn config for the key hardening controls. Deterministic.
# Usage: coturn-audit.sh <turnserver.conf>
set -u
F="${1:?usage: coturn-audit.sh <turnserver.conf>}"
[ -f "$F" ] || { echo "no such file: $F"; exit 3; }

miss=0
need() { grep -qiE "$1" "$F" && echo "  ok: $2" || { echo "  MISSING: $2"; miss=$((miss+1)); }; }
warn() { grep -qiE "$1" "$F" && { echo "  WARN: $2"; miss=$((miss+1)); }; }

echo "coturn hardening audit: $F"
need '^use-auth-secret'                 "short-term REST credentials (use-auth-secret)"
need '^static-auth-secret='             "auth secret configured"
need '^denied-peer-ip=10\.'             "denies relay to 10.0.0.0/8 (SSRF fence)"
need '^denied-peer-ip=192\.168\.'       "denies relay to 192.168/16"
need '^denied-peer-ip=169\.254\.'       "denies relay to link-local (169.254/16)"
need '^denied-peer-ip=127\.'            "denies relay to loopback"
need '^total-quota='                    "total-quota (amplification cap)"
need '^user-quota='                     "user-quota"
need '^tls-listening-port=|^cert='      "TLS listener / cert"
need '^no-cli|^cli-password='           "control CLI locked down"
# anti-patterns
warn '^lt-cred-mech'                    "long-term static creds enabled (prefer use-auth-secret)"
warn '^user=[A-Za-z]'                   "static user:password present (leak risk)"

echo
if [ "$miss" -eq 0 ]; then echo "COTURN AUDIT: PASS"; exit 0; else echo "COTURN AUDIT: $miss issue(s)"; exit 1; fi
