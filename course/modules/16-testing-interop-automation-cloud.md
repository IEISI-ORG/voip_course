# Module 16 — Testing, Interop, Automation & Cloud Deployment

**One-liner:** Validate at scale, prove interoperability, and deploy the whole platform as code.
**Est. time:** 5h · **Prereqs:** Modules 6–15.

## Learning Objectives
- Write SIPp scenarios for load, regression, and conformance testing.
- Diagnose interoperability failures and apply SBC message manipulation to fix them.
- Deploy the platform reproducibly with containers + IaC and a secure CI pipeline.

## 1. Concept
- **Testing types:** functional/regression, load/capacity (CPS, concurrent calls), soak, chaos
  (kill a PBX), conformance; where synthetic tests live in the pipeline.
- **SIPp deeply:** XML scenarios (UAC/UAS), variables, RTP echo/playback, CSV injection, TLS/SRTP
  scenarios, rate control (`-r`,`-rp`), assertions on responses; using SIPp as `trunk-sim`.
- **Interoperability:** RFC 3261 interpretation differences, header/behavior mismatches; SBC
  message manipulation/normalization (Kamailio `textops`/`sipdump`, OpenSIPS, rtpengine) to
  bridge quirks; SIPconnect; capturing and comparing vendor traces.
- **Automation / IaC:** Docker/compose (lab), Kubernetes (scale/HA), Ansible (config mgmt),
  Terraform (cloud infra); the parity principle (same topology dev→prod).
- **Cloud/containers for VoIP:** networking pitfalls (NAT, host networking for RTP, port ranges),
  stateful media, autoscaling limits, SBC-as-a-service pattern; virtualization/VNF context.
- **Secure pipelines:** secrets in CI, image scanning, config linting, no creds in git, signed
  artifacts, config-drift detection.

## 2. Packet Reality
- Run a SIPp load test; watch KPIs (M15) under CPS ramp; find the break point.
- Capture an interop mismatch (e.g., a required header a peer rejects) and the post-manipulation fix.

## 3. Build (OSS)
- Author 3 SIPp scenarios: register storm, INVITE load with RTP, and a malformed-message regression.
- Fix a simulated interop bug via Kamailio header manipulation; prove with before/after captures.
- Convert the lab to: (a) a `docker compose` prod-like stack, (b) an Ansible-provisioned VM set,
  (c) a Terraform cloud skeleton; run a CI job that lints configs + runs SIPp smoke tests.

## 4. Attack / Defend
- **Fuzz/conformance as security testing (T10):** malformed-message SIPp scenarios in CI to catch
  parser regressions before prod.
- **Pipeline security:** secret leakage in CI, unsigned images, drift → scanning, signing,
  drift alerts; least-privilege deploy credentials.
- **Cloud media exposure:** wide RTP port ranges + public IPs → tight ranges, security groups,
  rtpengine binding, SBC in front.

## 5. Labs / Deliverable
- **Lab 16.1:** SIPp scenarios for load + regression; report capacity and the failure mode.
- **Lab 16.2 (interop):** Diagnose and fix an interop failure with SBC message manipulation.
- **Lab 16.3 (IaC):** One-command deploy of the platform via compose + Ansible/Terraform; CI runs
  config lint + SIPp smoke + image scan on every change.
- *Rubric:* working scenarios + capacity numbers; interop fix proven; reproducible secure deploy.

## Assessment (sample)
- Design a SIPp test that measures max sustainable CPS without media starvation.
- Why is host/RTP networking the classic container-VoIP pitfall, and how do you solve it?
- Name three controls that make a VoIP CI/CD pipeline "secure by default."

## References
- SIPp docs & scenario reference; Kamailio/OpenSIPS textops; Docker/K8s networking for RTP;
  Ansible/Terraform docs; SIPconnect 2.0; supply-chain security (SLSA) concepts.
