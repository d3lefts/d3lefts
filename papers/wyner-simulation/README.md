# Dimension-Free Classical Simulation Under Correlated Inputs

**A Sharp, Representation-Sensitive Wyner Common-Information Bound**

NIGHTFALL flagship paper · outline v0.1 · 24 November 2026 · Devin J. Wright, human-directed and AI-assisted

## Headline

For bounded low-degree functions, the cost of classical simulation is governed by **how the information in the input is shared across coordinates**. It does not depend on the number of coordinates, the alphabet size, or the entropy of the input. The governing quantity is the Wyner common information `C_W(ν)` of the input law. It is optimal in the worst case, and it improves under locally recoverable changes of representation.

Applied to quantum query algorithms, this turns "quantum advantage requires structure" into an exact, computable quantity: on any input law with low common information, a quantum query algorithm's acceptance probability admits efficient classical simulation. Turturean's uniform-cube theorem is the case `C_W = 0`.

## Main theorem

Let `ν` be any probability law on a finite product alphabet `α^ι`, and let `f : α^ι → [0,1]` have interaction degree at most `d`. For accuracy `ε` and failure probability `δ`:

**Part I — Simulation (PR #970).** There is a deterministic coordinate-query decision tree `t` of depth

```text
O( d^24 · ε^-15 · δ^-17/2 · (1 + C_W(ν)) )
```

with `Pr_ν[|f − t| > ε] ≤ δ`. The depth does not depend on `|ι|`, `|α|`, or `H(ν)`. The exponents come from the constants of the Lean statement with `τ = δε²/2` and are not optimized.

Exact Lean statement: `Nightfall.Route1Polylog.route1_wyner_general` in [`Route1WynerGeneral.lean`](../../research/nightfall/formalization/product_space/Route1WynerGeneral.lean). For every `s > C_W(ν)` and depth `n` it gives

```text
Pr_ν[|f − t| > ε] ≤ ( K/(2γ) + s/(η² w₀) )/n + τ/ε²,
K = π²d²/2,  γ = sqrt(3τ⁵ / (12500 (π²(d+1)²)⁶)),  η = γ/(512 d²),  w₀ = γ/(16K).
```

**Part II — Representation sensitivity (PR #1150).** Suppose `ν` is within total variation `ζ` of `Φ_*μ`, where each observed coordinate of `Φ(z)` depends on at most `b` latent coordinates and every latent coordinate can be recovered from at most `r` observed queries. Then the same guarantee holds with `C_W(μ)` in place of `C_W(ν)`, degree `bd`, depth multiplied by `r`, and failure increased by `ζ`. The improvement is unbounded: the diagonal source `X = (Z, Z)` has `C_W(X) = N ln 2`, and it simulates at `C_W(Z) = 0` with `b = r = 1` and `ζ = 0`.

**Part III — Worst-case optimality (PR #1182).** There are finite Boolean laws `ν_m` and one-query quantum acceptance functions `f_m` (degree ≤ 2) such that, at `ε = δ = 1/4`,

```text
Q_classical(ν_m, f_m) = Θ(C_W(ν_m)) → ∞,
H(ν_m)/C_W(ν_m) → ∞,   ln|supp ν_m| / C_W(ν_m) → ∞.
```

Linear dependence on common information is therefore the true worst-case cost, and no entropy- or support-size-based bound can match it. Sharpness carries over to the Part II bound: the identity representation (`b = r = 1`, `ζ = 0`) is admissible, and every valid upper bound dominates the actual query complexity.

**Quantum corollary.** The acceptance probability of a `T`-query quantum algorithm is a bounded function of degree at most `2T` (Beals–Buhrman–Cleve–Mosca–de Wolf). Part I therefore gives classical query simulation on any input law, at cost `poly(T, 1/ε, 1/δ) · (1 + C_W(ν))`.

## Evidence

| Part | Result | Evidence | Source |
| --- | --- | --- | --- |
| I | Wyner simulation bound, general latents | End-to-end Lean proof, standard axioms | [#970](https://github.com/d3lefts/d3lefts/pull/970), [`Route1WynerGeneral.lean`](../../research/nightfall/formalization/product_space/Route1WynerGeneral.lean) |
| II | Query-local representation transfer, unbounded gap | Paper proof plus exact finite checker | [#1150](https://github.com/d3lefts/d3lefts/pull/1150), [transfer note](../../research/nightfall/formalization/product_space/ROUTE1_QUERY_LOCAL_WYNER_TRANSFER_20261122.md) |
| III | Worst-case Θ(C_W) with entropy padding | Paper proof, AI-checked | [#1182](https://github.com/d3lefts/d3lefts/pull/1182), [converse memo](../../research/nightfall/structural_information/ROUTE1_CONVERSE_EXACT_FORRELATION_20261121.md) |

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
2. Lean proofs of Part II (pullback and query substitution) and of the finite sampling lemma in Part III.
3. Manuscript and submission.
