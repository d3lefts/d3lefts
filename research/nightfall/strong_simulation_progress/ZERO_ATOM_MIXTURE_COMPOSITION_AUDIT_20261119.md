# Zero-atom bounded-round latent-mixture simulation: audited composition target

Version 0.1 — 2026-11-19. **PROVISIONAL PAPER ARGUMENT. Not Lean-certified, not independently peer-reviewed, not priority-cleared.**

## Source and scope

This note is a reviewer-facing synthesis of the 2026-11-19 frozen #893 hybrid product transfer (split #902), #894 margin-corrected counterexample, and #899 source-level zero-atom stability/disintegration. It is *not* a new exact-head kernel receipt. It deliberately uses the conservative source-derived coefficient **16D²**, rather than the sharper author-side 2D² Markov bound.

Fix a known finite mixture `nu = Σ_{j=1}^M π_j P_j` of arbitrary finite-alphabet product laws `P_j=⊗_i p_{j,i}`, allowing zero atoms and unequal or zero mixture weights. Let `f:Ω→[0,1]` be the acceptance probability of an at-most-`t`-query, `d`-round coherent finite-alphabet value-oracle algorithm. Assume its indicator interaction degree is `D≤2t`; this exact finite-alphabet circuit-to-degree bridge remains a formalization obligation.

**Theorem target (conditional on Theorem P / BDST transfer).** For any `r>0`, `δ∈(0,1)`, and `M≥1`, set

- `ρ = rδ/(8M)`; `ζ=δ/(4M)`.
- `γ=r/(16D²)` (for `D≥1`).
- `K=ceil(2 γ^(-2) ln(1/ζ)) = ceil(512 D^4 r^(-2) ln(1/ζ))`.
- `m` as in the split #902 one-sided dyadic product reduction for target accuracy `r` and failure `ρ`.

If each known component admits a deterministic `r`-accurate, `ρ`-failure product tree of depth `S(2mt,2d,r/2,ρ/2)`, there exists a deterministic mixture tree `T` of depth at most

`M*S(2mt,2d,r/2,ρ/2) + binom(M,2)*K`

such that `Pr_{X~nu}(|f(X)-T(X)| > 5r) ≤ ρ + (M-1)*(ζ+2ρ/r) < δ`.

For `D≤2t`, one may replace `K` by `ceil(8192 t^4 r^(-2) ln(1/ζ))`. Thus for any fixed quantum round count, the **candidate** cost is polynomial in `M,t,1/r,log A,log(1/δ)` with no lower bound on marginal atoms; `A` is the maximum alphabet size. No computational runtime bound is claimed, only worst-case whole-symbol query depth. Take `r=ε/5` for final tolerance `ε`.

## Composition proof, with source weights retained

1. Run all clipped-to-[0,1] per-component trees `T_j`, and freeze the entire joint queried-coordinate transcript `ell`. The unqueried coordinates remain product under every `P_j` with positive transcript mass. For zero-mass cells, use the unconditional pinned-product representation and keep transcript weights explicit. Write `a_j(ell)=T_j(ell)`; `w_j(ell)=P_j(ell)`; and `b_j(ell)=Pr_{P_j}(|f-a_j(ell)|>r | ell)` when `w_j(ell)>0`. Then `Σ_ell w_j(ell)b_j(ell)≤ρ`. No per-cell bound on `b_j(ell)` is assumed.

2. For a pair `j,k` with `|a_j(ell)-a_k(ell)|≥4r`, define `H(ell)={i unqueried: TV(p_{j,i},p_{k,i})>γ}`. Before seeing any duel outcomes, choose any `K` coordinates from `H` if `|H|≥K`; otherwise query all of `H`. Let `S` denote this set, so `|S|≤K`. Compute the deterministic weighted likelihood comparison of `w_j(ell)P_j(X_S | ell)` and `w_k(ell)P_k(X_S | ell)` with a fixed symmetric tie rule. Its *two-sided joint* error at this transcript is exactly the weighted overlap `Σ_z min(w_j P_j^S(z), w_k P_k^S(z))`.

3. **High-TV branch:** every chosen coordinate has TV `>γ`; Hellinger affinity obeys `α_i≤exp(-TV_i²/2)`. Product tensorization and the choice of `K` give overlap `≤ζ sqrt(w_jw_k)`.

4. **Low-TV branch:** all remaining free coordinates have TV `≤γ`. The pinned zero-atom expectation stability `|E_{P_j^R}f - E_{P_k^R}f| ≤16D²γ=r` is supported by the source-level Lean certificates in #898/#899. For each realization `z` of queried `S`, boundedness and `a_j,a_k∈[0,1]` imply
`|a_j-a_k| ≤2r + b_j(ell,z)+b_k(ell,z)+r`,
hence `b_j(ell,z)+b_k(ell,z)≥r`. Multiplying by the **minimum weighted mass** at `z`, then summing, gives overlap `≤[w_j(ell)b_j(ell)+w_k(ell)b_k(ell)]/r`. This avoids the false unweighted-overlap inference for unequal transcript masses.

5. Summing the high and low bounds over every preliminary transcript and using `Σ_ell sqrt(w_j(ell)w_k(ell))≤1`, and the original two global component failure budgets `≤ρ`, yields for every pair
`Pr_{P_j}(winner=k on a decisive j,k duel)+Pr_{P_k}(winner=j on that duel) ≤ ζ+2ρ/r`.
In particular the wrong-duel probability under either source alone is bounded by this sum.

6. Perform every decisive pair test from the frozen `ell`, not adaptively conditional on earlier pair results. Define a candidate undefeated if it loses no decisive duel. If component `θ` is accurate and loses none of its decisive duels, `θ` is undefeated. Every selected undefeated candidate has output distance `<4r` from `a_θ` (otherwise they would have dueled and could not both have won); its error is at most `5r`. Thus under each `P_θ` the final failure is at most `ρ+(M-1)(ζ+2ρ/r)`; averaging with `π` proves the mixture bound.

## Specific adversarial checkpoints

- **#894 does not refute the composition:** its counterexample has centers separated by only `2r+o(1)`, and no uniform excess margin. The algorithm above makes a duel only at `4r`; the positive gap is `2r`, so the counterexample's divergent identification requirement does not apply.
- **Markov factor repair:** #894's Lemma A note says each individual polynomial on `[0,1/η]` has derivative `≤d²η`. The standard Markov bound there is `2d²η`. To retain the claimed sharp **2d²η** difference bound, apply Markov directly to `h(s)=E_{P^u_s}f-E_{P^v_s}f`, which is degree `≤d`, bounded by 1 in absolute value on that interval, and has `h(0)=0`. Then `|h(1)|≤2d²η`. The proposed terminal instead uses independently source-certified **16d²η** and is insensitive to sharpening.
- **No full component identification:** only source pairs with separated predictions are distinguished. The tournament permits distinct latent components to remain observationally indistinguishable when their predictions agree.
- **Zero atoms:** no pointwise division by a source's zero transcript probability; weighted overlap and pinned laws are well-defined everywhere.
- **No circular dependency on K:** `γ` depends only on `r,D`; `K` is explicit and fixed before duel observations.
- **Correct failure unit:** `ρ` denotes *source input failure mass*, never conditional leaf failure. Avoid substituting a pointwise leaf assumption.

## External references and novelty boundary

- Blanc–Docter–Strassle–Tan, *Quantum Speedups Require Structure or Depth* (arXiv:2608.19158, 2026): uniform Boolean bounded-round strong simulator with `2^{O(d²)}(t log(1/δ)/ε)^{O(d)}`; does **not** establish this known-mixture result.
- Girish–Mittal–Nehoran–Raz, *Distributional Variants of the Aaronson–Ambainis Conjecture* (arXiv:2609.35327, 2026): fixed-bias and coordinate-varying bounded-bias reductions, but not zero-atom latent mixtures.
- Liu–Mutreja, *Parallel Quantum Advantage with Limited Adaptivity Requires Structure* (arXiv:2608.20297, 2026): uniform-oracle simulation/coupling setting.
- Escudero Gutiérrez–Palazuelos–Saucedo, *Optimal inequalities for completely bounded polynomials and the limitations of quantum query algorithms* (arXiv:2609.05201, 2026): quantum polynomial/nonadaptive direction; inspect full source before definitive priority claim.
- David Turturean, *A proof of the Aaronson–Ambainis conjecture* (arXiv:2611.09773, 2026): proves the original polynomial influence conjecture and its general weak-confidence simulation implication, **not** this strong polylog-confidence statement.

The distribution-free component-stability inequality itself and any specific claim of novelty still require a dated expert-level literature search. No publication submission or human review is claimed here.

## Formalization handoff / stop rule

**Cheapest decisive Lean target:** combine #899's `bounded_K_component_overlap` (pending exact-source CI) with its `MarginFreeLikelihoodDecision` and #893/#903's `strong_latent_mixture_terminal_tournament`; discharge `hpair` from observed transcript source masses. Separate quantum block-oracle/BDST contract remains the `hproduct` gate. Do not promote before an exact-head successful strict CI listing axioms and an independent non-author mathematical review.

Source snapshot for split: #893 head `277a5fae483bcba860020874b6961f0257aa72e8`. New synthesized claims are not attributed to existing CI receipts.
