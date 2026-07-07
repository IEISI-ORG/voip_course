---
marp: true
theme: default
paginate: true
title: Module 0 — Orientation & Lab Setup
---
<!-- deck-status: authored -->
<!-- Authored full deck. build-slides.sh will NOT overwrite this file (it skips authored decks). -->

# Module 0 — Orientation & Lab Setup

**Get the reproducible, segmented lab running before you touch SIP.**

`Est. 2h` · Prereqs: Linux CLI, Docker basics

<!--
Speaker: This is a setup module — no protocol theory yet. The goal by the end of the hour is a
running lab where every learner can capture a live call. If the lab isn't up, nothing else in the
course works, so we spend the time here and get it right. Set expectations: they will run ONE
`docker compose up` and end with a call visible in sngrep.
-->

---

## What you'll leave with

- The full VoIPSec Docker topology **up and healthy**.
- A mental model of the **four lab networks** and why they're separated.
- The **authorized-use rules** for the offensive tooling — non-negotiable.
- Knowing where captures, logs, configs, and secrets live — and how to reset cleanly.

<!--
Speaker: Frame these as the four things they must be able to do unaided by the next session:
bring the lab up, explain the segmentation, recite the rules of engagement, and reset. Everything
else builds on this.
-->

---

## One lab, grown across the whole course

- You don't build 20 throwaway labs — you grow **one platform** across 20 modules.
- The **capstone is this same lab** in its hardened, defensible final form.
- **Reproducibility contract:** infrastructure-as-code, no snowflake hosts.
  `docker compose down -v` returns you to a known-clean state, every time.

<!--
Speaker: Emphasise the through-line. Decisions they make in Module 6 (secret hygiene) still matter
in the capstone. "No snowflake hosts" = if it isn't in the repo, it doesn't exist. This is also the
first security lesson: reproducible infra is auditable infra.
-->

---

## The four networks (this is a security control)

| Network | Trust | What lives there |
|---|---|---|
| `edge` | untrusted | SBC, public-facing SIP |
| `core` | trusted / mTLS | PBXs, registrar, media |
| `mgmt` | observability | HOMER, Prometheus, Grafana, Loki, Wazuh |
| `redteam` | **isolated** | SIPVicious, SIPp, nmap |

- Mirrors real **DMZ design**: the attacker net can reach `edge`, **never `core`**.

<!--
Speaker: This table is the spine of the whole lab's threat model. Ask the room: why can redteam
reach edge but not core? Because that models an internet-facing attacker who has to get THROUGH the
SBC. The segmentation is enforced in docker-compose networks — it's not a diagram, it's config we
verify later.
-->

---

## Packet reality: prove the tooling sees traffic

- Run `sngrep` on the **edge**.
- Place a call between two softphones.
- Watch the **SIP ladder** appear in real time.

> No theory yet — the only goal is: *the capture tooling works.*

<!--
Speaker: This is a confidence check, not a lesson in SIP. If they see the INVITE / 100 / 180 / 200
ladder, their lab is wired correctly. If sngrep is empty, troubleshoot networking now — don't move
on. This is the single best early smoke test.
-->

---

## Build: bring up the topology

```bash
git clone <lab-repo> && cd lab
docker compose up -d
docker compose ps          # every service healthy?
```

- `edge-sbc` (Kamailio + rtpengine) · `pbx-a` (Asterisk) · `pbx-b` (FreeSWITCH)
- `trunk-sim` (SIPp) · `obs` (HOMER/Prometheus/Grafana/Loki/Wazuh) · `clients` · `redteam`

<!--
Speaker: One command brings up the whole stack. Walk the service list and name the role of each —
they'll meet all of these again. Common failure: ports already bound, or insufficient Docker memory
for the obs stack. Have them run `docker compose ps` and read the health column, not just "it's up".
-->

---

## Build: verify it's actually working

- `docker compose ps` — health, not just running.
- Service logs; **Grafana** reachable; **HOMER** receiving HEP.
- Register two softphones (**Linphone**, **Baresip**) against `pbx-a`; place a test call.

<!--
Speaker: "Healthy" is a claim you verify, not assume — this habit carries through the whole course
(every lab ships a fail-closed verify.sh). If HOMER isn't receiving HEP, captures won't correlate
later, so fix it here.
-->

---

## Attack / Defend — orientation only

- Tour the `redteam` container: SIPVicious, SIPp, nmap. **Do not run anything yet.**
- **Rules of engagement (restated in every offensive lab):**
  - Offensive tooling targets **only** lab hosts on `edge` / `redteam`.
  - **Never** against third parties or systems you don't own.

<!--
Speaker: This is the ethics gate. Say it plainly: pointing these tools at anything outside the lab
is illegal and gets you removed from the course. We restate it every single offensive module on
purpose. The redteam net being isolated is the technical backstop for the human rule.
-->

---

## Labs

- **Lab 0.1** — Bring up the topology; submit `docker compose ps` + a Grafana screenshot.
- **Lab 0.2** — Capture a call in `sngrep`, export the pcap, open it in Wireshark.
- **Lab 0.3** — Break & reset: `down -v`, back `up`, prove idempotency.

*Rubric:* all services healthy · one call captured end-to-end · clean reset demonstrated.

<!--
Speaker: 0.3 is the one people skip and regret. Proving `down -v` → `up` returns a clean, working
lab is what lets them experiment fearlessly for the rest of the course. Reward the reset.
-->

---

## Takeaways & quick check

- One reproducible lab; **segmentation is a security control**, not decoration.
- Verify health — don't assume it.
- Rules of engagement are absolute.

**Check:** Which network may attacker containers reach, and why is `core` excluded?
What command fully resets state *including volumes*? Where are captures aggregated?

<!--
Speaker: Answers — redteam reaches edge only, modelling an internet attacker who must pass the SBC;
`docker compose down -v` (the -v drops volumes); captures aggregate in HOMER for cross-hop
correlation. If they can answer these three, they're ready for Module 1.
-->
