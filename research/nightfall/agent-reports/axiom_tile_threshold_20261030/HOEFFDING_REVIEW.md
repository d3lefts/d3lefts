# Hoeffding audit of PR #279: statistical QA, not theorem certification

**Status:** R1 companion review artifact; PR #279 remains an open internal proof candidate. This is an independent AI-authored arithmetic implementation, not a non-author human mathematical review.

## Objective and hypotheses

Test a decoder implementation, not whether the diamond theorem is universally true. Freeze the sensing model: GF(53²)=F53[t]/(t²−2), H={±1}, coordinate squares followed by a legal square of a K-linear form, k=11 and b=10. Sample all support sizes s=0,...,11 separately; for each s choose 2,000 support subsets and uniform nonzero field values under the ideal sampling model. Fixed Python random.Random(27920261031) is used for deterministic replay, so formal coverage statements conditional on ideal independent sampling do **not** attach to this specific pseudorandom sequence without an additional randomness assumption.

## Checks and observed outcome

Run: python research/nightfall/agent-reports/axiom_tile_threshold_20261030/audit_hoeffding_decoder.py

Exact, exhaustive finite checks:
- 1,024 of 1,024 anchored relative-sign outputs distinct in actual GF(53²) squared arithmetic.
- 10 distinct lookup tables for every shorter block size b=1..10.
- Explicit diamond subset sums: 1,024 distinct, and the proposed missing sum absent from the full T+T.
- Canonical root normalization and finite-field inverses verified before sampling.

Fixed-seed regression: 12 support strata × 2,000 = 24,000 k=11 signals. Observed decoder errors: **zero**. SHA256 of the s,failures,n transcript: 3b2f6ade646c8c6595b6cfcc0c689648014f7eeabcd143d3580bcaa3b497bfc2.

## Concentration statements — conditional on independent uniform draws

For stratum s let Z_i∈{0,1} indicate decoder failure on sample i, and θ_s=E[Z_i]. Under independent identical draws within that stratum, Hoeffding's one-sided bound and a union bound over S=12 strata yield

    Pr[exists s: θ_s > Zbar_s + sqrt(log(S/α)/(2N))] ≤ α.

With N=2000 and α=.01, all observed Zbar_s=0, so the conditional familywise 99% upper bound is **0.042101297 (4.210%) per stratum**.

For zero observed failures, exact binomial inversion and Bonferroni give the tighter bound

    θ_s ≤ 1-(α/S)^(1/N) = 0.003538762 (0.354%) for every s,

with joint coverage ≥99%, under the same ideal IID model. These are error-rate bounds for the particular support-conditioned input distribution, not worst-case guarantees.

**Critical limitation:** Because the published run is fixed-seed pseudorandom, these are hypothetical model-based confidence bounds rather than unconditional mathematical probability guarantees about the actual deterministic transcript. Exact exhaustive finite checks do not need this assumption.

## Why Hoeffding cannot replace the proof

A code with exactly one colliding pair among 1,024 sign words fails on just one of C(1024,2)=523,776 unordered distinct input pairs. A uniformly sampled-pair audit would need **2,412,076 independent pairs** for a 99% chance of seeing that specific collision. Direct enumeration of all 1,024 outputs is dramatically cheaper and conclusive. The cheapest decisive experiment is exact arithmetic, not more random sampling.

Hoeffding is appropriate for software regressions, noisy empirical evaluations, or future large-support audits where exact enumeration is infeasible. It does not certify prime-uniform tile geometry, one-query capacity, or historical originality.

## Review checklist and stop rule

- Retain PR #279 at R1. Do not claim that 24,000 pseudorandom examples prove the theorem.
- Separately repair the y-band proof for the (a,b)=(0,2) rectangle; its vertical band can intersect the chosen y slice for some p. The horizontal shift remains 2D, which appears to preserve the hole argument.
- Seek non-author human proof review and same-model prior art.
- Stop additional stochastic trials unless a concrete new implementation risk or distribution shift is identified. More samples cannot improve the exact finite 1,024-word certificate.
