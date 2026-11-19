# Proof Passport — Gaussian-sign Forrelation product-mixture obstruction

**Claim ID:** `forrelation-mixture`  
**Snapshot:** 2026-11-19  
**Evidence tier:** Paper or exact-test candidate  
**PR:** https://github.com/d3lefts/d3lefts/pull/868  
**Exact PR source head:** `5ff3a75ab640a22c2820472aaf8792b480115789`  
**Named theorem:** None claimed  
**Pinned CI run:** Not confirmed for this composite claim

## Formal claim and domain

Paper-level derivation for N×N Walsh–Hadamard Forrelation: any exact fully coordinate-product mixture needs log M≥2N/π², with a restricted small-TV variant.

**Feasible set / hypotheses.** Unconditioned Gaussian-sign construction, exact source correlation and MGF calculations; TV form stated for fixed sufficiently small η.

## Representation and mechanism

Mutual-information / common-randomness capacity and sub-Gaussian first-block statistic; exact finite falsifier checks small N only.

## Certificate and current validation

PR #868 paper-level independent derivation and finite checks; #869 only certifies an abstract MGF implication under explicit hypotheses.

**Checker/replay.** No independent exact-head Lean verification supplied for this full claim. Inspect PR source, checker(s) and unresolved proof obligations.

## Boundary, novelty and review

No complete Gaussian-sign Lean specialization, no priority clearance; antecedents and information inequalities are classical.

**Attribution / prior art.** Aaronson–Ambainis Forrelation; Wyner/common-information antecedents; NIGHTFALL scoped mathematical synthesis.

**Audit status.** No independent human mathematical referee sign-off or novelty priority clearance asserted by this passport.

## Cheapest decisive next step

Check full source identity, prior art, and independently reproduce the Gaussian sign expectation and MGF.

## Provenance and version policy

- Source: https://github.com/d3lefts/d3lefts/pull/868
- Source-head custody: `5ff3a75ab640a22c2820472aaf8792b480115789`
- If theorem statement, input distribution, source bytes, toolchain or dependency changes, revalidate this passport; do not silently promote evidence tiers.
- No independent exact/interval checker was executed by this website-update operation. The source PR's cited evidence remains authoritative within its stated scope.
