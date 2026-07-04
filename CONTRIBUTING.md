# Contributing to VoIPSec

Thanks for helping improve VoIPSec. Community contributions are welcome under the project's
license — please read this before opening an issue or pull request.

## License agreement (required)
By contributing you agree that your contribution is licensed under **CC BY-NC-SA 4.0** (see
[`LICENSE`](LICENSE)), that you have the right to license it, and that you will be listed in
[`CONTRIBUTORS.md`](CONTRIBUTORS.md). Contributions that don't match the license can't be merged.

## How changes are decided (issue-first, approval-gated)
1. **Open a GitHub issue first** describing the problem or proposed change — a bug in a lab, a
   factual correction, a new lab/module idea, etc. Use a clear title and include evidence (RFC
   section, command output, capture, failing `verify.sh`).
2. **Wait for maintainer approval in the issue.** Work is only acted on after the maintainer
   approves the direction in the issue thread. This keeps scope and the security posture controlled.
3. **Then open a pull request** referencing the approved issue (`Fixes #NN`).

Please don't send large unsolicited PRs — get the issue approved first, or the work may not be
mergeable.

## Pull request checklist
- [ ] Linked to an **approved** issue.
- [ ] You added yourself to [`CONTRIBUTORS.md`](CONTRIBUTORS.md).
- [ ] Matches the project conventions:
  - Module docs follow the 5-beat shape (concept → packet → build → attack/defend → lab).
  - Every lab ships a **fail-closed** `verify.sh` (a broken probe must FAIL, never false-pass);
    policy/config labs are self-validating.
  - Rubrics sum to 100, pass ≥ 70.
- [ ] No secrets committed (`.env`, keys, tokens). Offensive tooling stays scoped to the lab
  `edge`/`redteam` networks — never third parties.
- [ ] Ran the relevant checks: the lab's `verify.sh`, `make verify-all` where applicable, and
  `bash -n` on shell scripts. CI (lint + offline graders) must pass.
- [ ] Accuracy over trend: cite an authority (RFC/standard/vendor KB); don't present correlation as
  causation. See the bibliography in `course/references/`.

## Security issues
Do **not** file a public issue for a security vulnerability. Email **contact@ieisi.org** with details.

## Commercial use
This is non-commercial licensed material. For for-profit use, see the "Commercial use" section of
[`LICENSE`](LICENSE) — contact **contact@ieisi.org**, <https://www.ieisi.org/contact>, or see
training at <https://www.ieisi.org/training>.
