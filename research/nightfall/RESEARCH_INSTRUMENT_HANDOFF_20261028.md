# NIGHTFALL — Research Instrument Handoff Contract
**Version:** 2026-10-28 / 1.1 (scoped browser integration; not a signed attestation)  
**Status:** a direct Referee → Claim Lab → Discovery finite-input handoff is implemented and browser-tested; cross-tool theorem promotion and the Observatory remain deliberately disconnected.

## Purpose

A reader should be able to trace one finite result through **source → deliberate test → exact scoped calculation → adversarial negative controls → exported receipt → separate replay → scientific adjudication** without confusing a self-reported claim, a browser result, an independently run check, and an accepted theorem.

The first public walkthrough uses the 30-point finite Sidon construction. The researcher reads [its source dossier](projects/sidon-finite-30/README.md), opens Referee in the supported `sidon` mode, runs its exact exclusion search and deliberate corruptions, exports a receipt, and follows [the Referee Python cross-language replay](referee/README.md). The finite claim is distinct from the previously known 5/9 asymptotic result. Source files and reviewer decisions are separate artifacts.

## Existing systems (current contracts)

| System | Input | Trust boundary | Export |
|---|---|---|---|
| **Claim Lab** | Browser-authored claims, dependency IDs, evidence references | User-controlled labels and manually entered hashes; completeness is not verification; user data stay in local browser storage until export | `nightfall-claim-lab-v1` JSON workspace |
| **Referee** | Finite integer overlap and Sidon witnesses | Exact BigInt calculations, same-package dual paths and mutations; export digest is an input fingerprint, not a signature or external endorsement | `nightfall-referee-receipt-v1` with domain, source input, claimed value, result, negative controls, input SHA-256 and scope notes |
| **Exact Research Tools** | Bounded sparse four-qutrit coefficient entries or small F25 sensing rows | Exact single-instance arithmetic; restricted to rank and finite enumeration scopes, no global theorem proof | `nightfall-exact-local-receipt-v1` with original input, exact output, local-calculation label |
| **Discovery Engine** | Research contracts, selection operators, toy-experiment parameters | Synthetic/local experiments are not proof of research improvement; reporting remains separate | Versioned experiment handoff; validate against the actual engine |
| **Observatory (draft)** | Frozen identifiers and independently reviewed evidence edges | Gate C matched-budget evaluation and Gate D editorial authorization still outstanding | No public claim-promotion workflow |


## Implemented same-origin finite evidence path (v1.1)

1. Referee performs its bounded integer check and negative controls. After a SHA-256 input digest is available, **Send to Claim Lab** writes the complete receipt to ephemeral same-tab `sessionStorage` key `nightfall.referee.pending.v1` and navigates locally to `claim-lab.html?referee_handoff=1`. The standard JSON export remains supported.
2. Claim Lab consumes and deletes that pending payload, independently recomputes its canonical input fingerprint, enforces the domain/version/size contract and asks the user for confirmation. It records **TESTED / UNAUDITED METADATA ONLY**; existing claim statuses are unchanged. The *Discovery replay* button is enabled only when a valid receipt has been imported.
3. With separate user action, Claim Lab transfers the raw source/result/attacks to `nightfall.discovery.pending.v1`. Discovery consumes this one-shot payload, independently computes the input SHA-256 and **reruns the exact finite arithmetic and adversarial mutation tests** using the existing `RefereeCore` library. Bit-for-bit serialized finite-result and attack results must match the imported receipt. A forged digest or modified result is rejected without a research-run insertion.
4. Discovery files the original source, domain, SHA-256, local replay outcome and negative-control results in its Sidon or minimum-overlap project. The run is explicitly tagged **LOCAL FINITE REPLAY · REVIEW OPEN**, has no prospective preregistration, and does not become a global theorem, external audit, priority claim, or verified continuous-overlap record. The package exporter retains the source and the handoff metadata.
5. Discovery’s evidence ledger links to the associated Proof Passport, where the mathematical scope and independently open obligations remain visible. Primary finite source for a newly established 28-edge Sidon essentiality property is independently available at [certificate JSON](projects/sidon-finite-30/edge_essentiality_certificate.json) and [exact generator](projects/sidon-finite-30/edge_essentiality.py), with [passing CI reproduction](https://github.com/d3lefts/d3lefts/actions/runs/40814933934).

The UI implementation deliberately uses browser same-code replay, **not a cryptographically signed result, off-device independent checker, or publication authority**. The separate published Python source checker establishes finite facts for a frozen source witness without relying on the browser receipt. The original master archive ZIPs remain behind publication-scope approval.

## Proposed general evidence exchange envelope (future; the implemented finite adapter is narrower)

Any future adapter should require, at minimum, a versioned `record_type`, `producer` plus exact version/commit, a domain-specific statement with quantifiers and assumptions, canonical input and a digest, the exact scoped result, negative-control outcome, the checker source or immutable reference, explicit provenance, and reviewer adjudication as an **independent field**. A scientific status must be imported as **unreviewed** even when the receipt says `FINITE_CHECK_PASSED` or has a valid SHA-256 hash.

Acceptance rules: reject malformed/unbounded payloads, unknown version without an explicit converter, conflicting input digests, missing domain/scope, and accidental cross-domain claims. Maintain records of rejected inputs. Never execute imported commands or HTML. Imported data shall never overwrite the browser's current Claim Lab workspace without explicit user approval and a recoverable backup. Never automatically promote to "theorem", "original contribution", "peer reviewed", or "competitive record".

### Extended evaluation contract (pilot partially executed)

1. Round-trip a genuine Sidon receipt through a new **preview-only adapter**, never through automatic claim promotion.
2. Reject a one-character changed input with the original digest; reject a spoofed `independently_checked` label; reject a receipt claiming asymptotic significance from a 30-point finite check.
3. Validate preserved domain, quantifier scope and exact source bytes. Independently replay the finite integer result using the existing Python checker.
4. Compare six preregistered graph-guided and flat-source tasks under equal budgets and shared source bytes. Report measured outcomes, including null results.

## Publication policy

The [owner-curated 32-source library](SITE_CURATED_32_20261028.json) is a **research inventory**, distinct from the three-item Original Findings list. Every mathematical theorem requires a proof audit within its own scope. Passing CI tests proves only the tested repository/build invariants. The two original frozen reproducibility archives remain an external replay dependency until publicly mirrored. The public Observatory remains unlinked pending Gate C/D.

**Owner of the research archive:** Devin J. Wright.  
**Instrument integration and scoped review:** NIGHTFALL research team.


## 2026-10-29 addendum — Imaginary Adversary / Referee finite *input* companion

The separate user-triggered `nightfall-companion-input-handoff-v1` adapter stages input in same-origin same-tab `sessionStorage` under `nightfall.companion.input.v1` and consumes/removes it once on navigation. It accepts exact integer-mark sets (up to 30 when the destination is Referee; up to 40 when the destination is Imaginary Adversary), or 2–64 rational equal-width overlap cells for the Adversary and 2–256 for Referee, with exact mass and range checks. It rejects unknown versions, status upgrades, added fields, unsupported domains, and invalid caps.

**Status invariant:** only the source input moves. Scientific verdicts, full Referee receipts, Adversary counterexample conclusions, Claim Lab approval, independent replay grades and publication status remain in their original systems. Imports are visibly labeled `INPUT ONLY · UNREVIEWED` and require the destination's own explicit Run action.

The Sidon bridge carries the **four-point (4,5) predicate** only. Referee additionally requires a classical Sidon subset and claimed maximum size; these are deliberately cleared after an Adversary → Referee transfer. A weak/classical Sidon adversarial predicate cannot be passed as a (4,5) claim. For larger instances, export the original bytes; do not silently truncate a witness.

**Two visitor routes:** the open-problem route uses Frontier → optional Orchestrator → Discovery → Imaginary Adversary/Referee as appropriate → consented record. The already published finite Sidon *replay* route begins at the source dossier, follows Referee and bounded adversarial inputs, inspects the independent Python checker, then requests a separate Claim Lab recording. The two routes share the evidence/status rules, not a fabricated universal automatic transfer.

Regression commands: `node scripts/test_companion_handoff.cjs`, `node scripts/test_adversary.cjs`, `node scripts/site_browser_smoke.mjs` (with local Playwright/Chromium). The website CI calls these through its normal gates.
