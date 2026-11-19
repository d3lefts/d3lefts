# NIGHTFALL structural observability of quantum-query sources — factor/quotient test v0.1

**Date:** 2026-11-19 UTC. **Status:** mathematical reduction checked on paper; diagonal exact product-mixture rank separately targeted by `DiagonalMixtureRank.lean`; **not** a complete new necessary-and-sufficient characterization or a claim of novelty.

## Target / distinction

The Jensen mixture theorem is a **sufficient** condition for distributional classical query simulation. It cannot be necessary if its `M` parameter measures mixtures of fully independent distributions in the *original, unreduced* input coordinates. The explicit diagonal source below can have exponential exact and robust mixture rank while still admitting the single-product query simulation after a trivial query-local quotient.

The correct unit of comparison is a source representation **together with the cost of lifting and recovering input queries**, plus the degree of pulled-back acceptance functions. A representation with few components but very expensive encodings/decoders is not a query-complexity theorem.

## I. Exact adversarial source: duplicate bits

Let `Z∈{0,1}^N` be uniform, and set `X=(Z,Z)∈{0,1}^{2N}`. Its law `P` is uniform over the diagonal graph `{(z,z)}` of size `K=2^N`.

**Exact mixture-rank theorem.** If `P=Σ_{θ=1}^M wθ (⊗_{i=1}^{2N}p_{θ,i})` is a mixture of full-coordinate product laws, with nonnegative weights, then `M≥K=2^N`; equality is attained by the K point masses. Even *block-product* mixtures `Σwθ aθ(z)bθ(z')` require M≥K. Proof: every positive-weight product component must vanish off the diagonal. If one component assigns positive mass to two distinct diagonal points `(z,z)` and `(z',z')`, conditional block independence implies positive mass to forbidden cross-pair `(z,z')`. So each component covers at most one diagonal point.

The Lean declaration `DiagonalMixtureRank.diagonal_requires_components` formalizes this finite rectangle obstruction with no Gaussian or entropy premises; `boolean_diagonal_exponential` substitutes `K=2^N`. Do not claim kernel certification before exact-head CI passes.

**Query simplification.** Restrict any bounded indicator-degree-`d` function `f:{0,1}^{2N}→[0,1]` to `g(z)=f(z,z)`. Each original indicator becomes a latent indicator in `z`, and a product of at most `d` indicators reduces either to 0 (conflicting requirements on the same latent coordinate) or to a cylinder of support size at most `d`. Thus `deg(g)≤d`. A query to `z_i` costs **one** query to the original input `X_i`. The already certified independent-product simulator therefore approximates `f(X)` under `P` with
`O(d^6 ε^-3 δ^-5/2)` original input queries. No dependence on N and **no dependence on its exponential mixture rank M**. This is an elementary paper-level reduction; its query-tree transformation is not in the attached Lean module.

## II. Robust counterpart (paper theorem, standard Fannes/Fano)

Suppose `Q` is a mixture of M full-coordinate product laws, or even block-product laws across `(Z,Z')`, and `TV(P,Q)≤η≤1/2`. Because `P(Z=Z')=1`, under Q the obvious decoder `\hat Z:=Z'` fails with probability at most η. Also `TV(Q_Z,Unif(K))≤η`.

- Fannes–Audenaert continuity: `H_Q(Z)≥log K−η log(K−1)−h(η)`.
- Fano: `H_Q(Z|Z')≤h(η)+η log(K−1)`.
- Since block-product mixtures give `Z ⫫ Z'|Θ`, `I_Q(Z;Z')≤H(Θ)≤log M`.

Therefore

```
  log M ≥ log K − 2η log(K−1) − 2h(η)
        ≥ (1−2η)N log 2 − 2h(η),   K=2^N,
  M ≥ exp(−2h(η)) 2^((1−2η)N).
```

All logarithms are natural. For any **fixed η<1/2**, approximate product-mixture rank remains exponential, while every low-degree acceptance function on the *exact* diagonal source is classically approximable in `poly(d,1/ε,1/δ)` queries. This rules out exact **or small-TV approximate mixture count alone** as a necessary hardness criterion. The entropy inequality is standard, checked algebraically on paper, but **not Lean-certified in this PR**.

## III. Query-local factor / pullback operator (paper theorem)

Let `Z` range over finite latent coordinates `J` with source law `μ` equal to a mixture of `M` product laws, and let `X=Φ(Z)` be an observed input indexed by `I`. Assume:

1. (**Encoding locality**) Each observed symbol `X_i=Φ_i(Z)` depends on at most `b` latent coordinates; each input alphabet is finite.
2. (**Query recovery**) For each latent coordinate `j∈J`, `Z_j` can be recovered **on the support** of `Φ_*μ` by querying at most `r` observed symbols of `X`. The decoder and queried index set for j are known to the classical procedure. This excludes non-recoverable latent encodings.
3. (**Source law**) `X∼ν:=Φ_*μ` exactly, or `TV(ν,Φ_*μ)≤η` for the robust variant.
4. (**Observable**) `f` is bounded in [0,1] and has indicator degree at most `d` in the observed input coordinates.

**Then** `g=f∘Φ` has indicator degree `≤bd` on the latent coordinates. Apply the certified mixture Jensen tree to `g`: for `τ∈(0,1/2]` and latent depth `n`, its error on `μ` is at most

```
 [3√2 π⁶ (bd)^6 M/(τ√τ) + 512 (bd)^4 M⁴/τ³]/n + τ/ε².
```

Replace each latent query in the tree with its at-most-r-query observed decoder. This gives a deterministic tree of **worst-case observed depth ≤rn** with the identical error under `Φ_*μ`. For a target `ν` within TV `η`, add exactly **+η** to the final event probability. If `bd=0`, use a constant-depth tree or replace `bd` by `max(1,bd)` to match the theorem's `d≥1` side condition.

**Proof of degree transfer:** each indicator `1[X_i=a]` is a finite linear combination of cylinders on the `≤b` latent coordinates controlling `Φ_i`. A product of `≤d` observed indicators therefore depends on at most `bd` latent coordinates. Linear combinations preserve the bound. The query lift is an exact deterministic tree substitution; its output on `Φ(z)` agrees with the latent tree on `z`.

For `X=(Z,Z)`, `b=r=1, M=1`, which recovers the sharp independent-input simulation despite observed-mixture rank `2^N`. For a dense latent encoding with no low-cost decoder, or degree blowup `b=Ω(N)`, this theorem does **not** imply an advantage. Both `b` and `r` are structural costs, not arbitrary distribution-only labels. This is a **one-directional closure property**, not a full characterization of which distributions admit quantum speedups; the task/promise and oracle model also matter. No formal Lean proof of the general quotient-transfer operator is claimed.

## IV. Why a universal classical polynomial-time corollary is not available

Fix **any** point-mass input law and a one-query circuit whose oracle is ignored (or acts as the identity). A uniform procedure that, given an arbitrary succinct normalized quantum circuit, **constructs and evaluates** a constant-accuracy probability approximation in `poly(circuit size,1/ε,log(1/δ))` classical time would solve arbitrary BQP language circuits classically, implying `BQP⊆BPP` (or `BQP⊆P` if the procedure is deterministic). This is an unresolved complexity-class containment, not a theorem that NIGHTFALL can currently claim. The query theorem's tree may require exponential classical preprocessing to construct.

A valid tractable subclass is any explicitly supplied degree-d indicator polynomial with `s` monomials: query the union of at most `sd` appearing coordinates, and evaluate every monomial directly in polynomial arithmetic time (accounting for coefficient bit length). This gives **zero approximation error** with `≤sd` queries and polynomial runtime in the *explicit sparse representation size*. It is elementary and does **not** imply efficient arbitrary quantum-circuit simulation.

## V. Certification and prior art

- **Certified baseline:** finite product AA and Jensen mixture simulator in merged PRs #858 and #867.
- **TV transfer:** separately in PR #880, exact-head Lean check pending; do not duplicate.
- **End-to-end circuit-to-mixture:** separately in #875/#877; do not duplicate.
- **Exact diagonal obstruction:** pending pinned Lean CI for this PR, no `sorry` intended; check output.
- **General factor-transfer:** paper proof above; formal degree-pullback lemma and query-tree substitution still open.
- **Forrelation robust obstruction:** Gaussian-sign candidate in #868/#869; its full analytic specialization is not formal. Mathlib [issue #42600](https://github.com/leanprover-community/mathlib4/issues/42600) explicitly tracks the missing Gaussian arcsine/Sheppard formula `E[sign X sign Y]=(2/π)arcsin corr`. Therefore do not describe the Gaussian-specialized constant as currently Lean-certified.
- **Prior-art warning:** source composition in distributional quantum query complexity (arXiv:2610.06835), d-local source generation in quantum sampling (ITCS 2026), classic Fano/nonnegative rank/common information, and trivial query reductions are relevant. Neither the diagonal example nor this transfer theorem has been priority-cleared for novelty.

**Next independent check:** prove the `degree(f∘Φ)≤bd` lemma in the source's finite-indicator API and a bounded-cost decision-tree query substitution; do not optimize constants until these mechanisms are certified.
