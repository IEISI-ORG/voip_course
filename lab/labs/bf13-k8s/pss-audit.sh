#!/usr/bin/env bash
# VoIPSec BF13 — audit a K8s manifest against Pod Security Standards "restricted". Flags the
# container-escape footguns: hostNetwork/PID/IPC, privileged, privilege escalation, root, missing
# capability drop / seccomp. Deterministic. Usage: pss-audit.sh <manifest.yaml>
set -u
F="${1:?usage: pss-audit.sh <manifest.yaml>}"
[ -f "$F" ] || { echo "no such file: $F"; exit 3; }
command -v python3 >/dev/null 2>&1 || { echo "needs python3"; exit 3; }

python3 - "$F" <<'PY'
import sys, yaml
issues = []
for doc in yaml.safe_load_all(open(sys.argv[1])):
    if not doc: continue
    kind = doc.get("kind","")
    spec = doc.get("spec",{})
    pod = spec.get("template",{}).get("spec", spec) if kind in ("Deployment","StatefulSet","DaemonSet","ReplicaSet") else spec
    name = doc.get("metadata",{}).get("name","?")

    if pod.get("hostNetwork"): issues.append(f"{name}: hostNetwork=true (use Multus instead)")
    if pod.get("hostPID"):     issues.append(f"{name}: hostPID=true")
    if pod.get("hostIPC"):     issues.append(f"{name}: hostIPC=true")

    psc = pod.get("securityContext",{}) or {}
    for c in pod.get("containers",[]) or []:
        sc = c.get("securityContext",{}) or {}
        cn = c.get("name","?")
        if sc.get("privileged"): issues.append(f"{name}/{cn}: privileged=true")
        # allowPrivilegeEscalation must be explicitly false
        if sc.get("allowPrivilegeEscalation", True) is not False:
            issues.append(f"{name}/{cn}: allowPrivilegeEscalation not false")
        # must run as non-root (container or pod level)
        if not (sc.get("runAsNonRoot") or psc.get("runAsNonRoot")):
            issues.append(f"{name}/{cn}: runAsNonRoot not set")
        if sc.get("runAsUser")==0 or psc.get("runAsUser")==0:
            issues.append(f"{name}/{cn}: runAsUser=0 (root)")
        # capabilities: must drop ALL
        drop = (sc.get("capabilities",{}) or {}).get("drop",[])
        if "ALL" not in drop:
            issues.append(f"{name}/{cn}: capabilities.drop must include ALL")
        # seccomp RuntimeDefault (container or pod)
        st = (sc.get("seccompProfile",{}) or {}).get("type") or (psc.get("seccompProfile",{}) or {}).get("type")
        if st not in ("RuntimeDefault","Localhost"):
            issues.append(f"{name}/{cn}: seccompProfile not RuntimeDefault/Localhost")

if issues:
    print("PSS restricted: FAIL")
    for i in issues: print("  -", i)
    sys.exit(1)
print("PSS restricted: PASS")
PY
