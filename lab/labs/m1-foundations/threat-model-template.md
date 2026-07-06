# Living Threat Model — <your name / cohort>

Started in M1, extended in **every** module, graded at the checkpoints and capstone. Keep it
in version control and update it as you build and attack the platform.

## 1. Assets (what we protect)
| Asset | Why it matters | Where it lives |
|-------|----------------|----------------|
| SIP credentials | account takeover → toll fraud | pbx-a/pbx-b, .env |
| Media (RTP) | call confidentiality | edge↔core path, rtpengine |
| CDRs / recordings | privacy, compliance | pbx, obs |
| Trust in caller identity | fraud/robocalls | STIR/SHAKEN, trunks |
| Platform availability | business continuity | all services |

## 2. Entry points / attack surface
| Entry point | Exposure | Notes |
|-------------|----------|-------|
| edge-sbc UDP/TCP 5060 | untrusted (edge) | scanning/flood target |
| edge-sbc TLS 5061 | untrusted | signaling security (M11) |
| media ports (rtpengine) | untrusted | RTP injection/eavesdrop |
| trunk-sim peer | edge | trunk abuse/spoofing (M9) |
| mgmt/observability | mgmt only | must not reach edge |

## 3. Trust boundaries
- edge (untrusted) → core (trusted) crossing at the **SBC** only.
- mgmt plane isolated; redteam plane isolated (A0/A6).
- Note where data/identity changes trust level (e.g., inbound PSTN identity).

## 4. Threats (grow this list per module)
| ID | Threat | Entry point | Current control | Status |
|----|--------|-------------|-----------------|--------|
| T1 | scanning / fingerprinting | edge 5060 | UA hide, pike, fail2ban | partial |
| T2 | extension enumeration | registrar/auth | uniform responses (M13) | open |
| T5 | media eavesdropping | RTP path | SRTP (M12) | open |
| T7 | caller-ID spoofing | inbound trunk | STIR/SHAKEN (M13/M19) | open |

## 5. Assumptions & open questions
- <what you are assuming is true; what you still need to verify>

> Update this file whenever you add a service, run an attack, or add a defense. The delta
> between "open" and "mitigated" here is your security progress across the course.
