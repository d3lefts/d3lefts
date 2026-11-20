# Conjecture E: a polynomial-doubling local-frame theorem (2026-11-19)

**Status:** author-side paper derivation from classical Fourier Bogolyubov and Gowers–Green–Manners–Tao Polynomial Freiman–Ruzsa (PFR), NOT a Lean theorem, independently refereed result, or cleared novelty claim. This is a **partial positive case of Conjecture E**, not its full solution. Keep the unresolved high-doubling regime explicit. No original research notes are overwritten.

## Contract / exact problem

From `LINEAR_DISTRIBUTIONS_20261119.md`, the row set `R ⊂ 𝔽₂^m` supports a `(c,c′,h)` frame `B` when every row is the sum of ≤c frame vectors, each frame vector is the sum of ≤c′ original rows, and any ≤h distinct frame vectors are independent. `Λ_T(R)` is the minimum `c c′` at the repo's prescribed `h=h(2cT)`.

From `LINEAR_NECESSITY_20261119.md`, `N₄(R)` is the maximum dimension of a linear subspace contained in the set of **at most four** original-row sums. Theorem C: a large subspace in a bounded sumset supplies a bounded-query quantum advantage; Conjecture E asks for a **K-independent** polynomial frame bound when all relevant short sums lack large subspaces.

Assume R nonempty and let `K=|R+R|/|R|≥1`. The strongest checked external result is PFR (Gowers, Green, Manners, Tao, *On a Conjecture of Marton*, 2023/2025). An explicit statement, as published by Tao on 2023-11-13, is: `R` is covered by at most `2 K¹²` cosets of a subspace `H` with `|H|≤|R|`. Primary source: https://terrytao.wordpress.com/2023/11/13/on-a-conjecture-of-marton/ . A 2026 ITCS algorithmic PFR paper also states the cover, but is not needed in the proof: https://drops.dagstuhl.de/storage/00lipics/lipics-vol362-itcs2026/html/LIPIcs.ITCS.2026.11/LIPIcs.ITCS.2026.11.html .

## Theorem F (cover-to-frame; paper proof, quantitative)

Let R be a nonempty finite subset of `𝔽₂^m`, covered by `L≥1` cosets `t₁+H,...,t_L+H` of a subspace H satisfying `|H|≤|R|`. Then for **every** `T,h`, R admits a `(c,1,h)` frame B, actually an independent subset of original rows, with

    c ≤ N₄(R) + L + 2L².                                         (F)

Consequently, by PFR,

    Λ_T(R) ≤ N₄(R) + 2 K¹² + 8 K²⁴.                              (F-PFR)

In particular, if `N₄(R)≤k` and the doubling constant satisfies `K≤poly(k,T)`, Conjecture E's requested `poly(k,T)` frame conclusion **does hold** in this subregime. For constant K, `Λ_T(R)≤N₄(R)+O_K(1)`. No dimension, alphabet, `h` or quantum T appears in the frame construction.

### Proof 1: elementary dense Bogolyubov with explicit 2α⁻² codimension

Let A be nonempty inside a finite binary vector space H, with density `α=|A|/|H|>0`. Fourier-normalize `f=1_A` by uniform expectation: `f̂(ξ)=E_{x∈H} f(x)(−1)^{ξ·x}`. Then `f̂(0)=α` and Parseval `Σ_ξ f̂(ξ)²=α`.

Define the large spectrum `S={ξ: f̂(ξ)²≥α³/2}`. Parseval yields `|S|≤2/α²`. Let `V=S^⊥`; then `codim_H V≤|S|≤2/α²`.

For every `v∈V`, the **normalized fourfold convolution** obeys

    (f*f*f*f)(v) = Σ_ξ f̂(ξ)⁴ (−1)^{ξ·v}
                 ≥ f̂(0)⁴ − Σ_{ξ∉S} f̂(ξ)⁴
                 ≥ α⁴ − (α³/2) Σ_ξ f̂(ξ)²
                 = α⁴/2 > 0.

Thus `V⊆A+A+A+A`, with `dim V≥dim H−2/α²`. This is classical dense Bogolyubov, written explicitly to make the constants and Fourier normalization auditable.

### Proof 2: a dense coset fiber forces a large subspace

Choose a most populated cover coset, with fiber `A=R∩(t+H)`. Since L cosets cover R and `|H|≤|R|`, its translated fiber `A−t⊆H` has density `α≥|R|/(L|H|)≥1/L`. Apply Proof 1 to obtain `V⊆4(A−t)` with

    dim V ≥ dim H−2L².

Characteristic two implies `4t=0`, so `4(A−t)=4A⊆4R`. Therefore `N₄(R)≥dim V`, which implies

    dim H ≤ N₄(R)+2L².

### Proof 3: choose an independent frame consisting only of original rows

The coset cover entails `span(R)⊆H+span(t₁,...,t_L)`, hence

    rank(R) ≤ dim H + L ≤ N₄(R)+2L²+L.

Choose any linearly independent row subset `B⊆R` forming a basis of `span(R)`. Then **each row** is a sum of at most `c=rank(R)` elements of B, **each b∈B** is already one original row (`c′=1`), and B is independent at **every** order h. The frame is source-exact and does not need a costly reconstruction decoder. This proves (F). Substitute the PFR cover `L≤2K¹²` to obtain (F-PFR). ∎

**Remark:** the proof is not asserting that the PFR covering subgroup is itself a low-cost frame, or that the arbitrary PFR subgroup lies in 4R. It derives an actual short-sum subspace from the **dense cover fiber** and then chooses a separate row-basis frame. These are the previously missing bridges.

## Exact obstruction to overgeneralizing the partial theorem

The `K` dependence is not removable by this reasoning. If R consists of n independent standard-basis rows, then `rank(R)=n`, `K=(n+1)/2`, and `|4·R|≤Σ_{j=0}^4 binom(n,j)`. Therefore `N₄(R)≤log₂ Σ_{j≤4}binom(n,j)=O(log n)`, while the **best frame is B=R with c=c′=1** and `Λ_T=1`.

So the frame may already be cheap when K is enormous, but PFR's coset-cover parameter cannot distinguish it from the hard intermediate cases. The full Conjecture E requires a replacement invariant (e.g. a growth/dependency profile or adaptive decomposition) rather than merely bounding the same PFR parameter harder.

For any finite R of size n (including multisets after removing duplicate rows), a universal counting bound is

    N_r(R) ≤ log₂ [ Σ_{j=0}^{min(r,n)} binom(n,j) ] ≤ r log₂(n+1).

Thus polynomially many rows do **not** force an Ω(m)-dimensional subspace in any **fixed** short sumset. This confirms the source's intermediate regime should be called “linear/polynomial-size through dense,” not “linear through exponential” as a sharp theorem about random-row thresholds.

## Scope, experiments, audit plan

An exact pure-Python regression under this PR checks dense Fourier-spectrum certificates for every nonempty subset of `𝔽₂^h` for `h≤4`; it also checks constructed coset covers, rank inequalities and the basis-frame witness on finite instances. It checks the exact independent-row cardinal obstruction, with no floating-point tolerance. This checker does not certify PFR, the general theorem's Fourier normalization, or novelty.

**Internal dual review:** Attack (i) the Fourier convolution normalization and nonnegative fourth powers, (ii) the `|H|≤|R|` condition, (iii) the translation cancellation `4t=0`, (iv) `at most four` vs exactly four, (v) whether B is an original-row basis, not just a formal abstract basis, (vi) whether `h(2cT)` is automatically met (it is, because B is fully independent), (vii) proper finite set versus multiset handling. Preserve any counterexample before changing the theorem.

**Novelty threshold:** a self-contained corollary and scope-restricted resolution, not an original additive combinatorics breakthrough; source the PFR and Bogolyubov ingredients. To resolve Conjecture E itself, prove `Λ_T≤poly(T,N_{poly(T)})` without K, or give a counterexample. No Lean or independent human proof review yet.

**Next decisive test:** try a density-increment/stabilizer dichotomy on the high-doubling region `K≫poly(N₄,T)`: recursively strip independent rows (which have frame cost 1) while exposing structured dense fibers, and prove the resulting frame cost is controlled by N_{poly(T)}. This would be genuinely beyond the PFR+Bogolyubov corollary.

**Discovery graph:** Problem E → (PFR subspace cover + dense fiber) → (Fourier Bogolyubov V⊆4R) → (rank control) → (original-row basis B) → (c,1,h) frame certificate → (K-dependent partial theorem) → (high-doubling gap). Independent criticism and Lean are outstanding.