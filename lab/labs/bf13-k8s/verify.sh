#!/usr/bin/env bash
# VoIPSec BF13 acceptance test — PSS auditor + manifests (offline, deterministic, fail-closed &
# self-validating). Run from lab/:  bash labs/bf13-k8s/verify.sh
set -u
cd "$(dirname "$0")/../.." || exit 3
DIR=labs/bf13-k8s

pass=0; fail=0
ok()  { echo "  PASS: $1"; pass=$((pass+1)); }
bad() { echo "  FAIL: $1"; fail=$((fail+1)); }

echo "== 1. manifests are valid YAML =="
for m in media-pod-secure media-pod-insecure; do
  python3 -c "import yaml,sys; list(yaml.safe_load_all(open('$DIR/$m.yaml')))" 2>/dev/null \
    && ok "$m.yaml valid" || bad "$m.yaml invalid YAML"
done

echo "== 2. PSS auditor accepts the hardened manifest =="
bash "$DIR/pss-audit.sh" "$DIR/media-pod-secure.yaml" 2>/dev/null | grep -q 'PSS restricted: PASS' \
  && ok "hardened media pod passes restricted PSS" || bad "hardened manifest wrongly failed"

echo "== 3. self-validation: PSS auditor rejects the anti-pattern =="
out=$(bash "$DIR/pss-audit.sh" "$DIR/media-pod-insecure.yaml" 2>/dev/null)
echo "$out" | grep -q 'PSS restricted: FAIL' && ok "hostNetwork/privileged/root pod rejected" || bad "insecure pod NOT rejected (fail-open!)"
echo "$out" | grep -q 'hostNetwork=true' && ok "flags hostNetwork (container-escape surface)" || bad "did not flag hostNetwork"
echo "$out" | grep -q 'privileged=true' && ok "flags privileged" || bad "did not flag privileged"

echo "== 4. hardened manifest uses Multus (no hostNetwork) =="
grep -q 'k8s.v1.cni.cncf.io/networks' "$DIR/media-pod-secure.yaml" && ok "Multus dedicated media interface" || bad "no Multus annotation"
grep -q 'hostNetwork: false' "$DIR/media-pod-secure.yaml" && ok "hostNetwork disabled" || bad "hostNetwork not disabled"

echo
echo "== result: $pass passed, $fail failed =="
[ "$fail" -eq 0 ] && { echo "BF13 ACCEPTANCE: PASS"; exit 0; } || { echo "BF13 ACCEPTANCE: FAIL"; exit 1; }
