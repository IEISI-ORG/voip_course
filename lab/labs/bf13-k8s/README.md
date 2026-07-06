# Lab BF13 — Cloud-Native VoIP: K8s Media Networking & Pod Security

**Module:** [M18](../../../course/modules/18-testing-interop-automation-cloud.md). Feedback-derived
(gemini_feedback1). Threat: container escape / node pivot via over-privileged media pods.

Goal: run RTP media in Kubernetes without the `hostNetwork` shortcut, and enforce Pod Security
Standards **restricted** so a compromised media pod can't escalate.

## Auto-graded core
```bash
bash labs/bf13-k8s/verify.sh
bash labs/bf13-k8s/pss-audit.sh labs/bf13-k8s/media-pod-secure.yaml     # PASS
bash labs/bf13-k8s/pss-audit.sh labs/bf13-k8s/media-pod-insecure.yaml   # FAIL (7 violations)
```
Self-validating: the auditor accepts the hardened manifest and rejects the `hostNetwork` +
privileged + root anti-pattern.

## The media-networking trade-off
| Option | RTP port range | Security cost |
|--------|----------------|---------------|
| **NodePort** | limited (default 30000–32767) | ok, but a narrow range for lots of calls |
| **`hostNetwork: true`** | full host range | **collapses pod↔node isolation** — big escape blast radius |
| **Multus (dedicated NIC)** | full, on a secondary interface | best isolation; the recommended pattern |

## Build
1. **Multus** — annotate the pod with a dedicated media network
   (`k8s.v1.cni.cncf.io/networks`), so RTP gets its ports without `hostNetwork`
   ([`media-pod-secure.yaml`](media-pod-secure.yaml)).
2. **PSS restricted** — non-root, `allowPrivilegeEscalation: false`, drop `ALL` capabilities,
   `seccompProfile: RuntimeDefault`, read-only root fs. Enforce via namespace PSA labels
   (`pod-security.kubernetes.io/enforce: restricted`).
3. Show admission **denies** the insecure pod ([`media-pod-insecure.yaml`](media-pod-insecure.yaml)).

## Rubric (100 pts, pass ≥ 70)
| Item | Pts | Grading |
|------|-----|---------|
| `verify.sh` PSS audit PASS | — | required |
| media pod runs via Multus (no hostNetwork) | 35 | working RTP |
| PSS restricted enforced (admission denies bad pod) | 40 | denial event |
| trade-off analysis (NodePort/hostNetwork/Multus) | 25 | write-up |
