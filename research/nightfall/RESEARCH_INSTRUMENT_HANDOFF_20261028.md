# NIGHTFALL — Research Instrument Handoff Contract
**Version:** 2026-10-28 / 1.0 (integration requirements; not a signed attestation)  
**Status:** design contract for independent review; the tools remain separately implemented.

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

## Proposed evidence exchange envelope (future; no existing tool guarantees this schema)

Any future adapter should require, at minimum, a versioned `record_type`, `producer` plus exact version/commit, a domain-specific statement with quantifiers and assumptions, canonical input and a digest, the exact scoped result, negative-control outcome, the checker source or immutable reference, explicit provenance, and reviewer adjudication as an **independent field**. A scientific status must be imported as **unreviewed** even when the receipt says `FINITE_CHECK_PASSED` or has a valid SHA-256 hash.

Acceptance rules: reject malformed/unbounded payloads, unknown version without an explicit converter, conflicting input digests, missing domain/scope, and accidental cross-domain claims. Maintain records of rejected inputs. Never execute imported commands or HTML. Imported data shall never overwrite the browser's current Claim Lab workspace without explicit user approval and a recoverable backup. Never automatically promote to "theorem", "original contribution", "peer reviewed", or "competitive record".

### Pilot test (assigned to Ryev)

1. Round-trip a genuine Sidon receipt through a new **preview-only adapter**, never through automatic claim promotion.
2. Reject a one-character changed input with the original digest; reject a spoofed `independently_checked` label; reject a receipt claiming asymptotic significance from a 30-point finite check.
3. Validate preserved domain, quantifier scope and exact source bytes. Independently replay the finite integer result using the existing Python checker.
4. Compare six preregistered graph-guided and flat-source tasks under equal budgets and shared source bytes. Report measured outcomes, including null results.

## Publication policy

The [owner-curated 30-source library](SITE_CURATED_30_20261028.json) is a **research inventory**, distinct from the three-item Original Findings list. Every mathematical theorem requires a proof audit within its own scope. Passing CI tests proves only the tested repository/build invariants. The two original frozen reproducibility archives remain an external replay dependency until publicly mirrored. The public Observatory remains unlinked pending Gate C/D.

**Owner of the research archive:** Devin J. Wright.  
**Instrument integration and scoped review:** NIGHTFALL research team.
