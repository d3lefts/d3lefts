# NIGHTFALL Proof Passport — Constructive Dyadic Fixed Point

**Date:** 2026-11-19  
**Version:** 1.0  
**Repository:** `d3lefts/d3lefts`  
**PR:** #897 (stacked on #893; draft, unmerged)  
**Verified source commit:** `6285341ab1dce087704ed1432b2182726947ef3b`  
**Lean CI run:** https://github.com/d3lefts/d3lefts/actions/runs/44547819191  
**CI job:** `135643061137` (success, including compilation and axiom print)  
**Lean pin:** `leanprover/lean4:v4.36.0-rc2` / `b35cb10cf2ced51a2fd1880cfdbf75c71ab7a35a`  
**Mathlib pin:** `v4.36.0-rc2` / `9d581dfff2e41de989072ea63abf3daf69311520`

## Scope of certificate

The file `research/nightfall/formalization/product_space/StrongFixedPoint.lean`
defines and proves four named declarations, printed by the CI job:

- `Nightfall.StrongSimulation.FixedPoint.two_mul_le_two_pow`
- `Nightfall.StrongSimulation.FixedPoint.quadratic_nat_growth`
- `Nightfall.StrongSimulation.FixedPoint.explicit_dyadic_fixed_point`
- `Nightfall.StrongSimulation.FixedPoint.explicit_rounding_condition`

Each reports only `propext`, `Classical.choice`, and `Quot.sound`.
None depends on `sorryAx` or on any user-defined global axiom.

## Claim and exact assumptions

For integer `N ≥ 1`, real `H ≥ 0` and `h > 0`, assume:

1. `h ≤ H * (4*N*N)^N` — a polynomial domination hypothesis;
2. `H ≤ c * η * 2^(2*N*N)` — an explicit budget hypothesis.

Then setting `m=4*N*N` proves

```
h ≤ c * η * 2^m
1 / 2^m ≤ c * η / h.
```

The proof is **not** a proof of assumption (1) from BDST. It is also not a
formal derivation of assumption (2) from the logarithmic parameter choice.
The certificate states both as Lean parameters, not hidden axioms.

## Mechanism

1. Induction proves `2*N ≤ 2^N` for `N ≥ 1`.
2. Raising both sides to `2*N` gives
   `(4*N^2)^N ≤ 2^(2*N^2)`.
3. Multiply by `H`, insert the explicit budget hypothesis, and use
   `2^(2*N^2)*2^(2*N^2)=2^(4*N^2)`.
4. Clear strictly positive denominators to obtain the rounding condition.

This is a conservative explicit selection. Compared with the prior
paper-level logarithmic selection in #893, it uses a quadratic size in
the auxiliary exponent/budget parameter. Both are polylogarithmic in
`1/η` for fixed round count once concrete BDST parameters are supplied.

## What remains open

- Turn the specific BDST theorem into `h(m) ≤ H*m^N` with justified,
  traceable constants and a choice of `N`, independently audit their
  dependence on `d`, `t`, `ε`, and `η`.
- Formalize the binomial smoothing polynomial and its Hoeffding bounds.
- Formalize the Bernstein (or bias-free Markov) derivative bound and its
  product-expectation application.
- Prove product-affinity tensorization and the actual finite product
  likelihood-ratio construction; existing weighted-duel Lean lemmas
  prove conditional arithmetic but not these interfaces.
- Prove the finite-alphabet coherent query encoding, randomized
  decoding/seed fixing, and end-to-end simulator theorem.
- Obtain non-author review and a dated novelty search before promotion.

## Source notes and adversarial status

The correct external BDST source is Blanc, Docter, Strassle, Tan,
*Quantum Speedups Require Structure or Depth*,
https://arxiv.org/html/2608.19158v1.
Its abstract gives the coarse `t^{O(d²)}` bound while the paper's
refined query-weight regularity statement has a
`2^{O(d²)} (t log(1/δ)/ε)^{O(d)}` structure.
These are not interchangeable without checking the simulator
reduction and constants. No novelty or independent human review
is claimed by this certificate.

**Promotion status:** Certified arithmetic sublemma; provisional strong
mixture theorem. Existing poly(1/δ) Lean-certified baseline remains
the manuscript headline.
