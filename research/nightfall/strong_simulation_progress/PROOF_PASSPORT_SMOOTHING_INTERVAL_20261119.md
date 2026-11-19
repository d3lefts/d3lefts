# NIGHTFALL Proof Passport — Binomial Smoothing Interval

**Date:** 2026-11-19  
**Version:** 1.0  
**Status:** Lean kernel-certified algebraic subresult (NOT the full event smoother)  
**Draft PR:** https://github.com/d3lefts/d3lefts/pull/897, stacked on #893  
**Certified commit:** `058fc6940481ea5f25089be0d3f1dc97c8555335`  
**Lean run:** https://github.com/d3lefts/d3lefts/actions/runs/44549364918  
**Job:** `135648584896` (success)  
**Toolchain:** Lean `v4.36.0-rc2`; Mathlib pinned to `9d581dfff2e41de989072ea63abf3daf69311520`.

## Object and certified claim

The concrete finite-sum smoother is

```
tail k r z = Σ_(j∈Ico (r+1) (k+1))
  (z^2)^j * (1-z^2)^(k-j) * (k.choose j : ℝ)
```

For every `k,r : ℕ` and real `z` with `|z| ≤ 1`, the file
`research/nightfall/formalization/product_space/StrongSmoothing.lean`
proves:

```
0 ≤ tail k r z ∧ tail k r z ≤ 1.
```

The exact full-binomial normalization is proved using Mathlib's
`add_pow`, with `z² + (1-z²) = 1`, and the tail is shown to be a
sum of nonnegative terms from a subset of the full binomial range.

**Named statements with axiom receipts:**
- `Nightfall.StrongSimulation.Smoothing.tail_nonneg`
- `Nightfall.StrongSimulation.Smoothing.total_mass_eq_one`
- `Nightfall.StrongSimulation.Smoothing.tail_le_one`
- `Nightfall.StrongSimulation.Smoothing.tail_mem_unit_interval`

The CI log reports only `propext`, `Classical.choice`, `Quot.sound`
for all four; no `sorryAx` or user-defined axiom.

## Strict certification boundary

The file does **not** yet prove the event threshold-tail requirements:

```
tail k r z ≤ η        when |z| ≤ ε
tail k r z ≥ 1 - η    when |z| ≥ 2ε
```

for `k=ceil(2 log(1/η)/(9 ε⁴))` and `r=floor(5kε²/2)`.
A binomial Hoeffding/Chernoff bridge, including exact threshold
rounding and `k` conversion, is needed.

It also does **not** yet prove the polynomial degree bound `≤2k`
inside Lean. The definition is explicitly a finite sum of polynomial
expressions, but that is not a degree certificate.

This passport cannot be used to promote any mixture theorem. The
strong transfer still needs source-product interpolation (Bernstein
or margin-free Markov), coherent-oracle encoding, quantitative BDST
parameters and the actual mixture test assembly.

## Independent numerical adversarial check (not a theorem)

Using Python's exact `fractions.Fraction` for the binomial sums at
`p=ε²` and `p=4ε²`, the threshold was tested at:

| ε | η | k | r | Both endpoint failures ≤η |
|---|---|---:|---:|---|
| 1/2 | 1/4 | 7 | 4 | Yes |
| 1/3 | 1/4 | 27 | 7 | Yes |
| 1/4 | 1/8 | 121 | 18 | Yes |
| 1/5 | 1/8 | 291 | 29 | Yes |
| 1/6 | 1/4 | 402 | 27 | Yes |

These `k` values conservatively exceed the displayed logarithmic
threshold. These finite tests do not establish the universal
Hoeffding bounds. No external human review is represented.

## Remaining decisive next gate

Formalize the weighted binomial tail/Chernoff inequality or instantiate
Mathlib's sub-Gaussian concentration result for independent Bernoulli
variables, and connect it to the *exact finite sum above*, including
the floor/ceil boundary cases. Then prove `natDegree≤2k` for the
explicit polynomial realization.

Retain the established Lean-certified poly(1/δ) theorem as the
preprint headline.
