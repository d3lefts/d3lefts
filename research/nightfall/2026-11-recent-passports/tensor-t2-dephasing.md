# Two-query same-stage interference reduction and exact obstruction

**NIGHTFALL Proof Passport supplement — 2026-11-22.** Source tier: `analytic`; Merged / exact finite, paper candidate. This is a claim-specific evidence sheet, not an automatic proof or originality promotion.

## Exact claim

Same-stage terms of every two-query acceptance expression reduce to one-query acceptance functions; a coherent remainder survives and can have depth-independent nonzero norm.

## Hypotheses and scope

Uniform binary linear parity oracle; distributional original-row approximation of same-stage terms only.

## Mechanism / operator

Stage-index inclusion-exclusion, pinching and quantum PSD one-query simulation.

## Evidence and reproducible certificate

Merged #996; source-hashed exact rational circuit and tensor enumeration CI #45047595645.

- Source pull request: https://github.com/d3lefts/d3lefts/pull/996
- Historical source head: `9205fd89797a416053d90a16e170923db7333aaa`
- Finite/evidence CI (not named Lean theorem): https://github.com/d3lefts/d3lefts/actions/runs/45047595645
- Named declaration or research object: `Paper-level dephasing/pinching argument; no named Lean terminal`
- Supporting source or archival note: https://github.com/d3lefts/d3lefts/pull/996

## Precise limitation and negative controls

Does not control full two-query acceptance, prove separation, or provide independent theorem review.

The same-stage dephasing theorem does not bound the crossed-stage coherent remainder. Exact finite circuit checks of nonzero remainder constitute an obstruction to a naive full simulator, not a quantum speedup or proof of impossibility.

## Novelty, prior art and credit

NIGHTFALL parallel instances; one-query source theorem from prior structural-information work.

**Status gate:** historical priority is unresolved without source-level comparison and specialist independent criticism. Paper/finite results are not automatically promoted to a general theorem or named Lean certificate.

## Next cheapest decisive experiment or adversarial audit

Attack high-rank coherent residual or a valid quantum-hard family.

**Certificate discipline:** preserve the input source, exact branch/head, checker and run identity, statement, hypotheses, negative tests and unproved dependencies with any downstream quotation. A new mathematical assertion requires a separately reviewed proof passport.
