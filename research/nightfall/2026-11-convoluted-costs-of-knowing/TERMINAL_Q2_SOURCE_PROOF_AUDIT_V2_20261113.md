# Terminal degree-two Q2 — source-proof audit v2

**Date:** November 13, 2026 (EST). **Parent:** [#468](https://github.com/d3lefts/d3lefts/pull/468), original source branch at `24e21be237e0`. **Toolchain:** Lean `4.36.0-rc2`, Mathlib `9d581dfff2e41de989072ea63abf3daf69311520`.

**Target, NOT YET a kernel theorem:** For the original finite independent categorical product law, with normalized nonnegative coordinate masses, a bounded real observable `|f(x)| ≤ B` and canonical Efron–Stein degree at most two,

```text
  (Var_p f)² ≤ 256 (1 + sqrt(3))² B² · max_i I_i(f),
```

where `I_i` is the actual squared-resampling influence. The empty-coordinate case requires separate treatment, and all quantities must be defined from *the same* f and p.

## What is verified

At parent commit `65faa846d606`, strict current-pin GitHub workflows [canonical](https://github.com/d3lefts/d3lefts/actions/runs/43555451646) and [quantitative](https://github.com/d3lefts/d3lefts/actions/runs/43555451484) passed. That source chain contains exact original-law degree-two Möbius decomposition, real quadratic representation without a free `hpoly`, the `8B` pointwise section budget (including 0/1-coordinate cases), a source-derived pair amplitude maximum, an original-coordinate injective-prefix sample law, matching/switching arithmetic, fourth moments, and a **conditional** final scalar endpoint.

Newer parent commits `d3ec68c…`, `ee8bb10…`, `b819741…` port actual-source canonical centering, off-diagonal orthogonality and variance Parseval from legacy source proofs; their *new* current-pin CI must be read before claiming certificate. Do not duplicate these same ports under competing module names.

## Narrow new proof gate

`ActualSourceInfluenceEnergy.lean` ports legacy `ActualESSourceEnergy` without its old Lean 4.33/Turturean import graph. For `q_i(a) = p_i(a)` and each original source section `g_x(a)=f(x_{i←a})`, the exact weighted identity is

```text
sum_a q_i(a) · (g_x(a) - E_q g_x)^2
 = (1/2) sum_a sum_b q_i(a) q_i(b) · (g_x(a)-g_x(b))^2.
```

Integrating over the original product law, using coordinate resampling invariance, yields the literal source equality

```text
sourceSectionEnergy(p,f,i) = actualSourceInfluence(p,f,i).
```

No degree-two hypothesis, atom floor, synthetic independent-neighbor source, or supplied moment certificate is involved. The **strict current-pin compiler and axiom audit is the certificate gate**, not the statement in this document. This source theorem bridges the analytic `M` budget to a source-only definition.

## Residual terminal source obligations

1. **Global matched amplitude.** Establish `sum_{e in any genuine disjoint matching} max |h_e| ≤ 4B` directly from original f, including unmatched original sites, and feed that into the generated max-first greedy owned `8B` cover. The parent #468 now contains a candidate source-specific rectangle port requiring its own strict CI receipt.
2. **Actual finite ownership and distinct neighbors.** For each owner, enumerate *exactly* the distinct original neighbor coordinates as an injective finite prefix. The historical Hilbert moment lemma asks `i ≠ j(k)` for all natural indices, while the source-law transfer requires injectivity only on the used prefix. Extend any nonempty prefix by repeating a valid other site; treat an empty-neighbor owner as a zero-energy case.
3. **Same-source Hilbert section identity.** Identify the vector-valued owner pair sum as the original-law conditional-coordinate section, not an independently resampled duplicate; use the exact original-coordinate sample law to transfer its first norm, second and fourth moments.
4. **Source energetic control.** Prove `s_i ≤ I_i(f)`, `a_i² ≤ I_i(f)`, and `z_i² ≤ s_i`, using canonical original-law ANOVA and true-source conditional projection. Supply `T=√M` and derive all owner-wise scalar bounds.
5. **Budget composition.** Combine source pointwise `sum_i u_i(x) ≤ 8B` and literal source expectation with singleton Jensen to get `sum_i a_i ≤ 8B` and `sum_i z_i ≤ 16B`. Derive `Var(f)=sum_i a_i²+sum_i s_i` from exact true-source Parseval plus ownership partition.
6. **Final theorem.** Discharge *all* assumptions of `ActualSourceQ2WeakScalarClosure.q2_scalar_squared_from_single_source_section_budget` from the original `p,f,B,degree≤2`, with actual influence maximum, zero-mass atoms, and dimensional edge cases handled explicitly.

## Certification, independent criticism and stopping rule

**Checker:** `.github/workflows/nightfall-q2-original-influence-v436.yml`, strict declarations `weighted_centered_eq_pair`, `actual_source_section_energy_eq_influence`. Allowed Lean axioms: `propext`, `Classical.choice`, `Quot.sound`; all `sorryAx` is disallowed. Workflow receipts record code SHA, compiler and Mathlib pins.

**Adversarial scope:** Do not promote a scalar endpoint with supplied global budgets to a terminal Q2 theorem. Do not import the legacy 4.33 `ProductInfluence` theorem as if it were a native 4.36 certificate. Zero-atom cases require pointwise control of f if the switching proof evaluates unsupported states. A successful Lean port does not prove a novel contribution; originality and external proof review are separate.

**Cheapest decisive next test:** strict compile the source influence equality and parent variance Parseval; then focus on the *same-source owner-to-Hilbert* and actual matching-mass interfaces, not on constants. Switch operator family after repeated tactic-level stalls.
