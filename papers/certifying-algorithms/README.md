# Structure-first, checker-first methods: GSI transfer to NIGHTFALL

**Research lead:** Devin J. Wright. **External method source:** Kishan Kumar / Generalised Superintelligence (GSI), 2026-11-16. **Incorporation:** 2026-11-17. **Status:** methodological transfer and a new small formal checker theorem; **not** adoption, independent reproduction, or scientific validation of GSI's reported discoveries.

## Checked external references and scope

- [GSI approach](https://generalised.si/approach): structural detector → problem-specific compiled solver → inexpensive early experiment → independent verification → preservation of reusable tools. Their stated reported speedups depend on selected benchmarks and are **not** NIGHTFALL measurements.
- [GSI-R-0018, solver-system evaluation](https://generalised.si/research/solver-compiler-and-factory): detector scored 5/8 in-class and 0/3 out-of-class negative cases (small test); the published checker-first examples were written from a shared specification and were internally checked. Their detector/compiler source and raw timings are not released. **Do not claim independent reproduction or automatic solver generation.** Their own note describes failures on MPS renderings and unseen families.
- [GSI-R-0013, checkable SAT refutations](https://generalised.si/research/sat-competition-refutations): proof objects based on XOR parity or exact rational Farkas/cardinality contradictions can be checked against the actual input. The published Python checkers are external sources, not copied into this repository. Their SAT witnesses do **not** certify a general Lean decision procedure.

## Transferred operator and why it matters

**Operator:** certify the *negative result* using a small exact proof object rather than trusting the whole search or optimizer. For rational inequalities `A x <= b`, a witness `w >= 0`, `w^T A = 0`, and `w^T b < 0` is an exact certificate of infeasibility. A candidate can be found by an arbitrary external solver; the witness is validated by a short checker.

We implement this **standard Farkas soundness direction** independently, without importing GSI code:

1. `lean/RationalFarkasCertificate.lean` states and proves the soundness implication for arbitrary finite rational matrices. It is *not a novel Farkas theorem*. The pinned named-declaration Lean CI must pass before classifying it as kernel-checked.
2. `check_farkas.py` validates separately presented JSON witnesses with `fractions.Fraction`, checks the SHA-256 of the canonical model, and rejects eight deliberately malformed/false witnesses. This script does **not** run Lean or prove the fidelity of an external model encoding.
3. `two_source_fence.json` is a small original NIGHTFALL semantic-fencing benchmark. Two singleton unsafe-change supports require two checks, but a proposed budget permits only one. `-x_1 <= -1`, `-x_2 <= -1`, `x_1+x_2 <= 1` have the exact Farkas certificate `(1,1,1)` giving `0 <= -1`. A separate enumeration checks the four Boolean guard choices. **This certificate proves a model-specific lower bound, not global safety or an optimality theorem for arbitrary systems.**

The simple verifier is independent code written for NIGHTFALL, not a claim that a non-author audited the program. No performance speedup is asserted.

## Reproduction and promotion gates

```bash
python3 -I papers/certifying-algorithms/check_farkas.py --self-test
python3 -I papers/certifying-algorithms/check_farkas.py papers/certifying-algorithms/two_source_fence.json
```

A dedicated workflow compiles the **exact original Lean source** under the repository's pinned Lean 4.36.0-rc2 and Mathlib commit, checks two named declarations with only allowed foundation axioms, and saves SHA-256 and exact-head receipts. A Python `PASS` never implies Lean compilation. A green Lean receipt certifies precisely these implications, not their application to an arbitrary physical-world or SAT encoding.

## Where to transfer next

- `research/nightfall/assurance/semantic-fencing-v0.3/`: use exact dual witnesses to *certify a lower bound* for weighted hitting-set or recertification instances, but require a matching feasible fence and an integrality-gap check before declaring exact optimality. If a fractional LP bound differs from the integer optimum, the dual alone does **not** close the integrality gap.
- Infinite-product Q2: the structural detector should first look for genuine finite-label orthogonal projection and true-law isometry. The Farkas theorem is **not** a shortcut through the pending measure-theoretic Lean terminal. Keep the two workstreams separate.
- NIGHTFALL Proof Passports: record four independent dimensions—original model hash, proof-object hash/format, exact verifier receipt, and theorem/type scope. Explicitly distinguish a solver's finding from a verifier's acceptance and from external human scrutiny.

**Provenance/credits:** GSI's published method and its certificate-first presentation motivated this integration. Rational Farkas soundness, certifying algorithms, exact dual witnesses, and elementary finite Boolean enumeration are longstanding mathematics. NIGHTFALL's code, Lean lemma and demonstration are written independently for this repository; no GSI performance or discovery claim is reproduced here.
