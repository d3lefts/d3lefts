# Dimension-Free Classical Simulation Under Correlated Inputs

**A Sharp, Representation-Sensitive Wyner Common-Information Bound**

NIGHTFALL flagship paper · outline v0.1 · 24 November 2026 · Devin J. Wright, human-directed and AI-assisted

## Headline

A dimension-free classical query guarantee for bounded low-degree functions under arbitrary correlated finite-alphabet laws is controlled by how information is shared across coordinates. It is worst-case sharp in Wyner common information at fixed degree and error, and query-recoverable representations can reduce the guarantee without bound. This does not characterize every task's optimum, establish uniqueness of Wyner's measure, or imply efficient classical runtime. For normalized quantum algorithms in the matching coordinate-query model, acceptance estimation is a corollary.

## Main theorem

Let `ν` be any probability law on a finite product alphabet `α^ι`, and let `f : α^ι → [0,1]` have interaction degree at most `d≥1`. In the matching original-coordinate query model, for `0<ε,δ≤1`:

**Part I — Simulation (PR #970).** There is a deterministic coordinate-query decision tree `t` of depth

```text
O(d^8 ε^-5 δ^-7/2 + d^24 C_W(ν) ε^-15 δ^-17/2)
```

with `Pr_ν[|f − t| > ε] ≤ δ`. The depth does not depend on `|ι|`, `|α|`, or `H(ν)`. The exponents follow by substituting τ=δε²/2, taking n>2[K/(2γ)+C_W/(η²w₀)]/δ, and choosing sufficiently small positive slack in s>C_W. They are not optimized.

Exact Lean statement: `Nightfall.Route1Polylog.route1_wyner_general` in [`Route1WynerGeneral.lean`](../../research/nightfall/formalization/product_space/Route1WynerGeneral.lean). For every `s > C_W(ν)` and depth `n` it gives

```text
Pr_ν[|f − t| > ε] ≤ ( K/(2γ) + s/(η² w₀) )/n + τ/ε²,
K = π²d²/2,  γ = sqrt(3τ⁵ / (12500 (π²(d+1)²)⁶)),  η = γ/(512 d²),  w₀ = γ/(16K).
```

**Part II — Representation sensitivity (PR #1150).** Suppose `ν` is within total variation `ζ` of `Φ_*μ`, where each observed coordinate of `Φ(z)` depends on at most `b` latent coordinates and every latent coordinate can be recovered on the positive-mass latent support by a deterministic decoder costing at most `r` observed queries on every word. Then the same guarantee holds with `C_W(μ)` in place of `C_W(ν)`, degree `max(1,bd)`, depth multiplied by `r`, and failure increased by `ζ`. The improvement is unbounded: the diagonal source `X = (Z, Z)` has `C_W(X) = N ln 2`, for N independent fair bits, while the latent has `C_W(Z) = 0` with `b = r = 1` and `ζ = 0`.

**Part III — Worst-case optimality (PR #1182).** There are finite Boolean laws `ν_m` and fixed-query quantum acceptance functions `f_m` (degree ≤ 2 in the combined one-query convention; ≤4 if counted as two phase queries) such that, at `ε = δ = 1/4`,

```text
Q_classical(ν_m, f_m) = Θ(C_W(ν_m)) → ∞,
H(ν_m)/C_W(ν_m) → ∞,   ln|supp ν_m| / C_W(ν_m) → ∞.
```

Linear dependence on common information is therefore the true worst-case cost, and linear total-entropy or log-support bounds can be arbitrarily looser on this family; other dependence-sensitive measures are not excluded. Sharpness carries over to the Part II bound: the identity representation (`b = r = 1`, `ζ = 0`) is admissible, and every valid upper bound dominates the actual query complexity.

**Quantum corollary.** The acceptance probability of a normalized `T`-query quantum algorithm in the matching standard coordinate-oracle model is a bounded function of degree at most `2T` (Beals–Buhrman–Cleve–Mosca–de Wolf). Part I therefore gives classical query simulation on any input law, by substituting d=max(1,2T) in Part I. This is scalar acceptance estimation, not runtime or state simulation.

## Evidence

| Part | Result | Evidence | Source |
| --- | --- | --- | --- |
| I | Wyner simulation bound, general latents | End-to-end Lean proof, standard axioms | [#970](https://github.com/d3lefts/d3lefts/pull/970), [`Route1WynerGeneral.lean`](../../research/nightfall/formalization/product_space/Route1WynerGeneral.lean) |
| II | Query-local representation transfer, unbounded gap | Full finite transfer and diagonal identities kernel-verified on open #1183/#1184; exact finite checker | [#1150](https://github.com/d3lefts/d3lefts/pull/1150), [transfer note](../../research/nightfall/formalization/product_space/ROUTE1_QUERY_LOCAL_WYNER_TRANSFER_20261122.md) |
| III | Worst-case Θ(C_W) with entropy padding | Reviewed paper proof; finite-test sampling kernel-verified on open #1183 | [#1182](https://github.com/d3lefts/d3lefts/pull/1182), [converse memo](../../research/nightfall/structural_information/ROUTE1_CONVERSE_EXACT_FORRELATION_20261121.md) |

### Exact new receipts (24 November)

- [#1183 run 45330144365](https://github.com/d3lefts/d3lefts/actions/runs/45330144365), head `98f53f6abe2142dc97b74fcd97d683d2c3484096`: `Nightfall.QueryLocalWyner.query_local_wyner_blocal` and `Nightfall.Route1Sampling.finite_test_sample`; compilation, leanchecker and standard-axiom gates passed.
- [#1184 run 45330640932](https://github.com/d3lefts/d3lefts/actions/runs/45330640932), head `a3a113c4c3d1b42a82d895df8293d8b7a0eeaf35`: `Nightfall.Route1Polylog.fair_bit_diagonal_wyner`, `fair_bit_product_wyner` and support/infimum lemmas passed the same gates.
- These are branch receipts, not yet merged source. All use only propext, Classical.choice, Quot.sound. Full Part III minimax, tree count, entropy/support and padding composition remain outside the new Lean receipt.

## Credit

- **David Turturean** ([arXiv:2611.09773](https://arxiv.org/abs/2611.09773)) is the source of the influence mechanism at the foundation of Part I: level integration, third moment, median/doubling and light-coordinate averaging. NIGHTFALL ports it to arbitrary finite product laws ([#317](https://github.com/d3lefts/d3lefts/pull/317)). #970 extends it to correlated inputs with latent switching and a residual conditional-information potential.
- **Girish–Servedio**, *Forrelation Is Extremally Hard* (ITCS 2026, [arXiv:2508.02514](https://arxiv.org/abs/2508.02514)), supply the quantum/classical separation imported in Part III.
- **Wyner** (1975) introduced common information. **Aaronson–Ambainis** ([arXiv:0911.0996](https://arxiv.org/abs/0911.0996)) posed the simulation question for uniform inputs.

## Related work to compare in the paper

Girish–Mittal–Nehoran–Raz ([arXiv:2609.35327](https://arxiv.org/abs/2609.35327)), fixed-bias products and slices; Ben-David et al. ([arXiv:2610.06835](https://arxiv.org/abs/2610.06835)), distributional quantum query complexity; Blanc–Docter–Strassle–Tan ([arXiv:2608.19158](https://arxiv.org/abs/2608.19158)), simulation of parallel quantum algorithms under the uniform distribution; Ambainis–de Wolf ([quant-ph/9904079](https://arxiv.org/abs/quant-ph/9904079)), average-case quantum query complexity; Bruno–Vaccaro ([arXiv:2610.15402](https://arxiv.org/abs/2610.15402)), support-rectangle geometry of common information.

## Paper plan

1. **Introduction:** the principle, the three parts, the quantum corollary, and Turturean's uniform case as `C_W = 0`.
2. **Preliminaries:** product laws, interaction degree, coordinate-query trees, Wyner common information with general latents.
3. **Part I:** latent switching, the key lemma, the two-potential tree, and the conditional-information chain rule, keyed to the Lean declarations.
4. **Part II:** pullback of indicator cylinders, query substitution, TV transfer, and the diagonal and graph-cut examples (#1095).
5. **Part III:** Yao minimax, sparsification of the hard law, the entropy bound, independent-product padding, and transfer to Part II.
6. **Examples:** product laws, Forrelation mixtures (`C_W = Θ(N)`), affine codes and graph sensors.
7. **Open directions:** optimal dependence on degree and error, task-relative necessity, and runtime.

## Next steps

1. A specialist reader in query complexity, plus a full prior-art search on simulation under mixtures of product laws.
2. Integrate verified Part II and sampling sources after custody reconciliation; finish the full Part III composition.
3. Complete manuscript, specialist review and obtain explicit publication authorization.
