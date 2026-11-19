# NIGHTFALL Forrelation product-mixture obstruction — independent mathematical audit v0.1

**Date:** 2026-11-18 ET. **Status:** provisional paper proof independently rederived and finite-case checked; **not Lean-certified**, not independently human-refereed, and **not novelty-certified**. This does **not** amend the theorem classification of PR #858 or the pending Jensen PR #867.

## Objective / provenance

Assess the review-thread candidate that the **unconditioned Gaussian-sign Forrelation law** requires exponentially many independent-product components, even allowing a small total-variation approximation. The earlier exact-rank obstruction `M≥N` is valid but is superseded quantitatively by the information bound for the same distribution. This is a *different mathematical result* from the mixture simulation theorem.

Reference construction: Aaronson–Ambainis, *Forrelation: A Problem That Optimally Separates Quantum from Classical Computing*, [arXiv:1411.5729](https://arxiv.org/abs/1411.5729). The Gaussian-sign rounding and `2/π` expected Forrelation are also described in *Forrelation Is Extremally Hard* (ITCS 2026), [HTML §1.4](https://drops.dagstuhl.de/storage/00lipics/lipics-vol362-itcs2026/html/LIPIcs.ITCS.2026.72/LIPIcs.ITCS.2026.72.html). The general technique `I(F;G)≤H(Θ)` for `F⊥G|Θ` is **standard common-information theory**, not a NIGHTFALL novelty claim; see [Wyner common information background](https://arxiv.org/abs/2610.15402) and [nonnegative rank/common information prior work](https://eccc.weizmann.ac.il/report/2013/158/revision/1/download/).

## Formal setting

Let `N=2^k≥2`, and `H∈ℝ^{N×N}` be a normalized Walsh–Hadamard matrix: `HHᵀ=I`, every entry is `±1/√N`. Sample `Z∼N(0,I_N)`. Put `F_i=sgn(Z_i)` and `G_j=sgn((HZ)_j)`, each in `{-1,+1}`. Let `P` be the **unconditioned** law of `(F,G)` on `{-1,+1}^{2N}`. Let `U` be the independent uniform law on that space. Define

```
    S(f,g) := fᵀ Hᵀ g / N,         |S(f,g)|≤1.
    α_N := E_P S = (2√N/π) arcsin(1/√N) ≥ 2/π.
```

The bivariate Gaussian arcsine identity is `E[sgn X sgn Y] = (2/π)arcsin(corr(X,Y))`; its sign and normalization are checked against [standard Grothendieck lecture notes](https://www.cs.toronto.edu/~toni/Courses/Proofs-SOS-2018/Lectures/grothendieck.pdf). The marginal laws `P_F` and `P_G` separately equal independent uniform Rademacher measures because `H` is orthogonal.

A **full-coordinate product law** means the `2N) Boolean coordinates are jointly independent, including between `F` and `G`. Any mixture of `M` such laws has a latent variable `Θ` with `|supp Θ|≤M` and `F⊥G|Θ`. The bound below is a lower bound on that mixture size, *not* a characterization of minimum mixture rank.

## Theorem A — exact obstruction

**Claim:** If `P=Σ_{θ=1}^M w_θ (⊗_{i=1}^{2N}p_{θ,i})`, then

```
                   log M ≥ N α_N² / 2 ≥ 2N/π².
                   M ≥ exp(2N/π²).
```

**Paper proof.** Conditional on `F=f` under `U`, the `G_j` are independent symmetric signs. Therefore for any real `λ`,

```
E_U exp(λ S)|F=f =
    ∏_j cosh(λ (Hf)_j/N)
  ≤ exp( λ² Σ_j (Hf)_j²/(2N²) )
  = exp(λ²/(2N)),
```

using `log cosh t≤t²/2` and orthogonality `Σ_j(Hf)_j²=||f||²=N`.

Gibbs' variational inequality, with `D(P||U)` in **nats**, gives `D(P||U)≥ λ E_P S −log E_U exp(λS)`. Optimize `λ=Nα_N` to obtain `D(P||U)≥Nα_N²/2`. Since both marginals of `P` are uniform, `D(P||U)=I_P(F;G)`.

If `P` is an `M`-component product mixture, conditional independence gives `F→Θ→G` and
`I_P(F;G)≤H(Θ)≤log M`. Combine.

**The exact universal exponent** `2/π²` follows because `arcsin(t)≥t` on `[0,1]`.

## Theorem B — TV-robust obstruction

Assume `Q` is an `M`-component product mixture and `TV(P,Q)≤η` for `0≤η<min(1/2,α_N/2)`. Then

```
log M ≥ (N/2)(α_N−2η)² − 2η N log2 −2h(η)
      ≥ (N/2)(2/π−2η)² − 2η N log2 −2h(η)
```

provided also `η<1/π` for the displayed second inequality. Here `h(η)=-η logη-(1-η)log(1-η)`, `h(0)=0`.

**Proof.** As `|S|≤1`, TV closeness gives `E_Q S≥α_N−2η>0`; the same exponential-moment variational bound gives
`D(Q||U)≥(N/2)(α_N−2η)²`.

Decompose `D(Q||U)=I_Q(F;G)+D(Q_F||U_F)+D(Q_G||U_G)`.
Marginalization contracts TV. Fannes–Audenaert's finite Shannon entropy continuity bound and uniformity of `U_F,U_G`, each with alphabet size `2^N`, give
`D(Q_F||U_F)≤η N log2+h(η)`, likewise `G`. Since `Q` is an `M`-product mixture, `I_Q(F;G)≤log M`. Combine.

For `η=1/100`, this gives the explicit reproducible inequality

```
        log M ≥ 0.176247028226125 N − 0.112003068709695.
```

The exponent is positive. More generally `η` must be a fixed *sufficiently small* number; the result is **not** an exponential rank obstruction for arbitrary approximation tolerance.

## Generalization (reuse, not novelty claim)

The exact proof applies to **any** law on two uniform Rademacher vectors with an orthogonal bilinear statistic `S=fᵀHᵀg/N` and `E S≥c>0`:
`log M≥Nc²/2` for every exact product-mixture representation. The TV version follows with the same entropy penalties, replacing `α_N` by `c`. This is an instance of established information/latent-variable methods, not a new general theory of common information.

## Independent checks

Run `python3 research/nightfall/forrelation/check_forrelation_mixture_information.py`. It uses only Python's standard library and no random sampling. It:
- reconstructs the **exact N=2 Gaussian angular sign distribution** from eight equal sectors and checks both marginals uniform, `E S=1/√2`, and `I(F;G)=log2`;
- enumerates the uniform independent distributions for `N=2,4` and checks the sub-Gaussian logarithmic MGF bound at eight positive/negative test values;
- constructs an exact-rational `N=2` TV perturbation `Q=.99 P+.01 U`, verifies `TV(P,Q)=1/200` and the robust KL lower bound;
- checks the printed `1%` numerical constants.

These **finite counterexample checks cannot establish the general theorem**. The general proof relies on standard analytically established Gaussian arcsine, cosh-MGF, Gibbs/DV, data processing and finite Shannon-entropy continuity lemmas.

## Independent criticism / priority gate

- **Truth check:** no inconsistent constants, sign errors, or definition gaps found during the independent paper reconstruction. Detailed Lean certification is still absent.
- **Novelty check:** the general common-information and nonnegative-rank mechanisms are established prior art. A bounded 2026-11-18 search did not identify an identical **Forrelation-specific** exponential approximate-mixture bound; this is *not* comprehensive priority clearance.
- **Scope check:** unconditioned Gaussian-sign law only. A promise-conditioned YES/NO law, clipped/truncated Gaussian construction, thresholded promise law, arbitrary k-Forrelation, and mixtures of **block**-product (rather than coordinate-product) laws require separate arguments.
- **Minimum Lean kernel target:** first formalize the **abstract two-block information certificate**, with input `F,G,H,S`, `P_F=P_G=U_N`, `E_P S≥c`, and mixture decomposition. This should establish `log M≥Nc²/2` without Gaussian measure theory. Next prove TV-stability using a finite-entropy continuity lemma. Last formalize the Gaussian-sign law and exact expectation `α_N`. Never claim full Forrelation certification merely from the abstract certificate.
- **Status gates:** conjecture/provisional paper proof → finite reproducible sanity checker (this file) → kernel-certified abstract theorem (OPEN) → Gaussian specialization (OPEN) → non-author expert review (OPEN) → dated novelty evaluation (OPEN).

**Stop rule:** if the abstract finite entropy theorem does not compile under a source-pinned Mathlib build without new axioms, do not promote; instead preserve the first failed lemma and the exact input contract. Do not divert the established #867 Jensen track until its current CI is resolved.
