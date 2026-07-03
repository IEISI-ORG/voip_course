# Questions / Decisions Needed (for the consistency audit)

Per your feedback (iter 40), I'm running a 3-iteration consistency pass across the content base.
Below are decisions I need from you. Turn any of these into a `feedback*.txt` and I'll apply it.

## Pass plan
- **Pass 1 (done, iter 40):** standards/RFC citation consistency.
- **Pass 2 (next):** terminology + cross-reference consistency (defer detail lists to the
  bibliography; standardize first-use of acronyms).
- **Pass 3:** prose flow / anti-AI-slop line edit (light touch — see Q3).

## What I already fixed in Pass 1 (no decision needed)
- **`div` PASSporT was mis-attributed.** RFC **8588** is the SHAKEN PASSporT (`attest`/`origid`);
  `div` (diverted calls) is RFC **8946**. Fixed in M12 and the bibliography.
- Added cited-but-missing RFCs to the bibliography so it is the single source of truth
  (3312, 3581, 3856, 4787, 5853, 6913, 8946, 1918; noted 2617→7616).

## Q1 — Rich Call Data (RCD) PASSporT RFC number  *(verification needed)*
M12 cites "Rich Call Data (RFC 8946/9118)". RFC 8946 is **diverted calls**, not RCD — so RCD is
mis-paired. I believe RCD is **not** RFC 9118 either, but I'm not certain of the correct number.
**Decision:** (a) you confirm the RCD RFC, or (b) I verify it against the RFC index next pass and
correct it. Until resolved I've left the RCD mention but corrected `div`→8946.

## Q2 — Citation style: single source of truth vs repetition
Each module repeats a `## References` list AND the bibliography holds the master list. This drifts.
**Decision — pick one:**
- (A) Keep per-module reference lists but they must be a **subset** of the bibliography (I audit).
- (B) Slim per-module lists to "see bibliography" + only the 2–3 RFCs central to that module.
- (C) Leave as-is (I only fix outright errors).
Default if you don't answer: **(A)**.

## Q3 — How aggressive should the anti-slop prose pass be?
Scan result: the content is already clean (crucial/delve/vibrant/leverage/"in order to" = 0
occurrences; only "landscape" ×1, "robust" ×2). So heavy rewriting risks introducing errors into
technical text for little gain.
**Decision — pick one:**
- (A) **Light touch:** fix only clear AI-isms + awkward flow, preserve technical wording. *(Recommended)*
- (B) Deeper voice pass (more rewriting, higher risk on technical accuracy).
Default: **(A)**.

## Q4 — Terminology standardization (minor)
- "red-team" (prose) vs "redteam" (the container/network name). Keep `redteam` for the literal
  service/network, "red team" in prose? (Default: yes.)
- Spell out acronyms on first use per module (SBC, PSTN, PBX, SRTP…)? (Default: spell out the
  first time each appears in a module, then abbreviate.)

## Q5 — Anything else you want checked
- Cross-module claim contradictions? Number/threat-ID (T1–T15) consistency? Rubric point-total
  consistency (all should sum to 100)? Tell me if any of these matter and I'll add them to Pass 2.
