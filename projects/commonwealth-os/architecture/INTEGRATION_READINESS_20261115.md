# Browser / server workbench integration — evidence and limits

**Date:** 2026-11-15, publication status: internal experimental source archive.

## Integration source
- Original browser and demo server proposal: PR #610, head `d41599d445969835abfd3399bd4f11faf5e8d458`.
- Additive transactional evidence, authority epoch and reference-model improvement: PR #615, head `693430e864d378bbfff2e164193d8eaf4d045c1a`, stacked on #610.
- This integration copies the **exact Git blob SHA** of each selected file from #615 into a new tree based on `main`, preserving all other Commonwealth OS subprojects, the separately merged #609 design addendum, #613 conditional Lean passport, and UX v0.2.
- This is a source merger, not a theorem/general-purpose security certification.

## Evidence observed
- #610 on its exact head: Commonwealth OS synthetic browser workflow #43777953385 SUCCESS; NIGHTFALL Lean pin audit #43777953373 SUCCESS.
- #615 on its exact head: synthetic browser #43780066606 SUCCESS; Lean refinement #43780066596 SUCCESS; active Lean pin audit #43780066633 SUCCESS.
- Earlier local server test receipt (author reported): 8/8 integration/security-boundary tests on Node 22.16; separate from independent audit.
- #613 conditional assurance proof exists independently; no JavaScript/SQLite-to-Lean refinement theorem follows automatically.

## Threat boundary and go/no-go
- The server binds to localhost only and supports only synthetic decisions. Its signed evidence and `verify.mjs` establish in-model record coherence with declared key trust, **not** external identity, legal eligibility, secret ballot secrecy, public suffrage, production robustness or democratic legitimacy.
- No cloud deployments, live voter records, real municipal ingestion, external effect sinks, real official votes or pseudonymous political profiling are authorized by this merge.
- Never treat an API response as official certification; all actions are DEMO/ADVISORY.
- Further gates: independent threat review, full source-bound authorization proof, privacy and accessibility evaluation, legally competent institution approval, adversarial test matrix, and repository-level release sign-off.
- Figma design and browser UX v0.2 are distinct and cannot silently mutate the state-machine authority boundary.

## Reproduction
```sh
cd projects/commonwealth-os/apps/browser && npm test
cd ../server && npm test
```
Node >=22.13 is required for the server; no external service or real data needed.
