# Q2 source-law soft-noise compiler checkpoint · November 13, 2026

**Status: SEVEN SCOPED LEAN THEOREMS CERTIFIED. FULL SOURCE-LEVEL Q2 NOT CERTIFIED.**

Research led by Devin J. Wright; AI-assisted proof construction. This record is the certificate passport for the active-pin real-source refresh operator, not a terminal Q2 or novelty claim.

## Exact pin and receipt

- Strict success: [GitHub Actions 43544378752](https://github.com/d3lefts/d3lefts/actions/runs/43544378752), after [initial four-declaration run 43544137817](https://github.com/d3lefts/d3lefts/actions/runs/43544137817).
- Source module: [ActualProductSoftNoise.lean](../formalization/observability/ActualProductSoftNoise.lean), SHA-256 **3112bfeadd226027eeb853c5ec98c0ac0cceb0e198c794475d0db9a4bddfaf58**.
- Compiler: Lean **4.36.0-rc2**, commit **b35cb10cf2ced51a2fd1880cfdbf75c71ab7a35a**.
- Mathlib: **9d581dfff2e41de989072ea63abf3daf69311520**.
- Strict allowed axioms only: **Classical.choice, Quot.sound, propext**. No sorryAx or added Q2 assumption.
- Exact original-source prerequisites recompiled in the same workspace: [merge tower](../formalization/observability/ActualProductMergeTower.lean), [Hilbert Jensen](../formalization/observability/ActualProductHilbertJensen.lean). The CI artifact includes pin/source hash/declaration reports.

## Seven exact new Lean declarations

1. **actual_source_conditional_mixture_L1** — any finite normalized nonnegative mixture of real-product conditional refreshes is an expected norm contraction for arbitrary real normed vector-valued source functions, with zero-mass states permitted.
2. **maskWeight_nonneg** — valid coordinatewise retention rates give nonnegative Boolean-mask probabilities.
3. **maskWeight_total_one** — independent mask weights normalize *exactly* by the finite product-of-sums identity, rather than an externally supplied sampling oracle.
4. **actual_soft_source_noise_L1** — true-coordinate, Bernoulli keep-or-refresh noise is contractive in original-product expected norm for any retention rates between zero and one.
5. **actual_source_conditional_stationary** — a source conditional refresh preserves the exact original-product mean.
6. **actual_source_conditional_mixture_stationary** — normalized mixtures of true-source conditionings preserve the exact scalar source mean.
7. **actual_soft_source_noise_stationary** — full coordinatewise soft noise is stationary under the *original* product law.

The last three make the operator genuinely source-preserving instead of merely an auxiliary probability-space estimate.

## Terminal target and missing gates

The desired theorem is, for an arbitrary finite normalized independent product source and bounded genuine source observable f of Efron–Stein degree at most two,

\[
\operatorname{Var}_p(f)^2
\le (10+2\sqrt 2)^2(1+\sqrt3)^2\, B^2\,\max_i I_i^p(f).
\]

All alphabet types and zero-probability masses must be handled without a lower atom-size assumption, and empty coordinate sets require separate treatment. **This inequality is NOT a compiled declaration.**

The next necessary source-dependent bridges, which this certificate does **not** establish, are:

1. Show that soft noise acts on a genuine centered Efron–Stein singleton or pair sector by its correct retention factor *derived from actual source marginalization*, not by assuming the eigenrelation.
2. Derive per-owner soft rates from the **actual source's** greedy matching amplitude cover; prove the soft second-moment exact energy partition, maximum-influence control, and genuine Hilbert fourth-moment bound.
3. Recompile the original-source section 8B estimate, the additive budget, Parseval and influence identities and the matching cover together under the active 4.36 pin.
4. Assemble a terminal all-source theorem with only normalization, nonnegativity, boundedness and degree-two source hypotheses, print axiom dependencies and run strict source-hashed verification.

The historic 4.33 modules and mathematical paper proof do not automatically port to active 4.36 or imply this terminal statement. The operator's classical Markov-mixture ancestry is acknowledged; priority and external human review of a composed theorem remain open.

## Reproducible failure history

- [43543775763](https://github.com/d3lefts/d3lefts/actions/runs/43543775763): reserved Lean binder character in retention-rate variable, fixed syntactically.
- [43543972889](https://github.com/d3lefts/d3lefts/actions/runs/43543972889): higher-order rewrite could not expose Boolean-coordinate product-of-sums. Explicitly exposed the coordinate Bool weight function; no extra assumption.
- [43544137817](https://github.com/d3lefts/d3lefts/actions/runs/43544137817): four original-law conditional-mixture and mask claims compiled with standard axioms only.
- [43544378752](https://github.com/d3lefts/d3lefts/actions/runs/43544378752): all seven current claims compiled with standard axioms only.

**Cheapest next decisive test:** independently reconstruct the actual one-coordinate source marginal / canonical centered component noise-eigenaction, then the true separately centered pair-component action. Test skew and zero-atom finite laws exactly as adversarial falsifiers, and compile the same statement without additional source-energy hypotheses. If the source transport fails, stop before fourth-moment assembly. No autonomous promotion to terminal Q2 or publication.
