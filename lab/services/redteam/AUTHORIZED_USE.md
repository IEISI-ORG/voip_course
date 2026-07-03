# AUTHORIZED USE ONLY — VoIPSec redteam container

This container holds offensive VoIP tools (SIPVicious, SIPp fuzzers). It exists to teach
**defense** by demonstrating attacks against a system you are explicitly authorized to test:
the VoIPSec lab.

## Rules of engagement
1. **Targets:** only the VoIPSec lab on the `edge` (172.28.10.0/24) and `redteam`
   (172.28.40.0/24) networks. The container is not attached to `core`/`mgmt` and cannot reach
   production-style services by design.
2. **No external targets.** Running these tools against any host you do not own or have
   **written permission** to test is illegal in most jurisdictions (e.g. US CFAA, UK Computer
   Misuse Act) and violates this course's terms.
3. **Scope guard.** The wrapper scripts in `/opt/redteam/scripts` refuse targets outside the
   lab subnets. Do not remove the guard to "test something real."
4. **Data handling.** Any credentials or data recovered during a lab stay in the lab.

By using this container you confirm you are operating within an authorized training
environment. If you are unsure whether you are authorized, you are not — stop.
