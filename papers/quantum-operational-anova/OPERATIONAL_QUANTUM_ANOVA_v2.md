# Exact Operational Quantum ANOVA and Supermodular Bayesian Observability

**NIGHTFALL, research addendum v2.0 — 11 November 2026**

**Status:** Complete mathematical argument written below; exact rational tests and independent complex-matrix tests passed. **Not** externally refereed or Lean kernel-checked. A dated preliminary prior-art review was performed; global originality has **not** been established. This document is a proposed replacement and strengthening of Parts III–IV of `QUANTUM_CLASSICAL_OBSERVABILITY_THEOREM_v1.md`, not an amendment to adaptive instruments Part V.

## Abstract

For an independent classical product prior with arbitrary local classical-to-quantum encodings, the exact optimized squared-error Bayes gain of a scalar target observed through any subset of quantum registers decomposes as a sum of nonnegative contributions indexed by the classical Hoeffding interaction supports. In particular the *operational* Bayes gain itself, not merely its geometric-chi-squared upper proxy, is monotone supermodular. The result holds for noncommuting local states, unequal priors, arbitrary finite local dimensions, and collective, subset-dependent POVMs. An equivalent proof uses commuting quantum conditional expectations under the product average state. The same product-support decomposition holds for quadratic tangent energies of every symmetric Petz monotone metric, even though only the geometric-mean eigenvalue kernel multiplicatively tensorizes. This distinction corrects a potential overclaim about uniqueness of the geometric metric.

## Model and main statement

Let independent finite-valued variables `X_1,...,X_n` have product law `p = ⊗ p_i`. At coordinate `i`, the physical encoder supplies density matrix `ρ_{i,x_i}` in finite-dimensional Hilbert space `H_i`. Let `ρ_x = ⊗_i ρ_{i,x_i}` and `b_i = E[ρ_{i,X_i}]`. All operators are restricted to the supports of `b_i`, where these are faithful. Let `f` be a real square-integrable scalar target with mean `\bar f`, variance `V`, and Hoeffding decomposition

    f(X)-\bar f = Σ_{∅ ≠ S⊆[n]} f_S(X_S),

where `E[f_S | X_T]=0` whenever `S` is not a subset of `T`.

For each nonempty S define its *signed interaction signal* and unique Hermitian Personick estimator:

    B_S := ⊗_{i∈S} b_i,
    A_S := E[f_S(X_S) ⊗_{i∈S} ρ_{i,X_i}],
    J_{B_S}(L_S) := (B_S L_S + L_S B_S)/2 = A_S,
    γ_S := Tr(A_S L_S) = Tr(B_S L_S²) ≥ 0.

For Q⊆[n] let `G*(Q)` be the squared-error reduction achieved by optimizing over *all* collective POVMs applied to quantum registers Q, estimating the single scalar f. Then

    **G*(Q) = Σ_{∅≠S⊆Q} γ_S.**                                      (1)

Each γ_S is exactly the optimal Bayes gain for estimating f_S from the registers in S alone, with the f_S prior induced by the product law. It satisfies

    0 ≤ γ_S ≤ E[f_S²],   γ_S=0 iff A_S=0.

Consequently G* is normalized, monotone, and supermodular:

    G*(A∪{i}) - G*(A) ≤ G*(B∪{i}) - G*(B)

for A⊆B and i∉B. This is a **universal mathematical theorem within this model**, not an empirical extrapolation from 2- or 3-qubit samples.

### Proof (no noncommuting matrix diagonalization needed)

The subset's centered signal is

    A_Q := E[(f-\bar f) ⊗_{i∈Q}ρ_{i,X_i}]
         = Σ_{∅≠S⊆Q} A_S ⊗ B_{Q\S},                         (2)

where products are embedded in the fixed physical register order. Indeed, for a component f_T with T not contained in Q, integrating over any missing coordinate kills that component by its Hoeffding centering. For T⊆Q, independence factors out the unused averaged local states.

The Jordan map has the extension property

    J_{B_Q}(L_S ⊗ I_{Q\S}) = J_{B_S}(L_S) ⊗ B_{Q\S}
                                 = A_S ⊗ B_{Q\S}.          (3)

Summing (3), uniqueness of the Lyapunov equation on the support gives the exact optimal estimator

    L_Q = Σ_{∅≠S⊆Q} L_S ⊗ I_{Q\S}.                         (4)

Personick's scalar optimal-measurement identity states

    G*(Q) = Tr(A_Q L_Q) = Tr(B_Q L_Q²),

attained by measuring the spectral projectors of L_Q. For S≠T contained in Q, the corresponding inner-product cross term vanishes. If S is not contained in T,

    Tr[(A_S⊗B_{Q\S})(L_T⊗I_{Q\T})]
      = E[f_S(X_S) Tr(ρ_{T,X_T} L_T)] = 0,

since the second factor depends only on X_T and `E[f_S | X_T]=0`. If S is properly contained in T, instead reverse S and T, using the symmetry of the Jordan inner product:

    Tr[(A_S⊗B_{Q\S})(L_T⊗I)]
      = <L_S⊗I,L_T⊗I>_{B_Q}
      = Tr[(A_T⊗B_{Q\T})(L_S⊗I)] = 0.

The quadratic form is therefore the orthogonal sum of precisely the diagonal terms γ_S, proving (1). Nonnegativity follows because B_S is positive and γ_S=Tr B_S L_S². The upper bound follows from Bayes risk for the target f_S: no measurement gain exceeds its variance. □

### Equivalent conditional-expectation proof, and stronger scope

On Hermitian operators on the full physical register define the real Hilbert inner product

    <U,W>_B = (1/2) Tr B(UW+WU),  B=⊗_i b_i.

The unital completely positive maps P_Q that retain register Q and state-average all other registers (replacing them by identities) are *orthogonal projections* in this Hilbert space, and obey `P_A P_B = P_{A∩B}`. The full Personick estimator L has `P_Q L=L_Q⊗I_{Q^c}`. Hence the commuting-projection Möbius decomposition `L=Σ_S L^[S]` is orthogonal and `G*(Q)=Σ_{S⊆Q}||L^[S]||_B²`.

**Extension:** This conditional-expectation proof needs only a product *average quantum state* `B=⊗ b_i`, not the pointwise tensor product of the conditional density matrices nor the independence of a hidden classical prior. Thus exact operational supermodularity extends to arbitrary finite cq ensembles on multipartite systems whenever their unconditional average quantum state factorizes. The more explicit identity γ_S = G*(f_S; S) uses the stronger independent-local-encoding assumptions.

## Cost, observation order, and localized comparison

Let `ε_S = ||B_S^{-1/4} A_S B_S^{-1/4}||_{HS}²`, the geometric metric interaction coefficient from v1.1. Then

    ε_S>0 ⇔ A_S ≠ 0 ⇔ γ_S>0,

so the smallest observable support size is unchanged. In an eigenbasis of B_S,

    γ_S = Σ_ab 2 |(A_S)_{ab}|²/(λ_a+λ_b),
    ε_S = Σ_ab   |(A_S)_{ab}|²/√(λ_aλ_b).

Consequently, for κ_S = λ_max(B_S)/λ_min(B_S),

    [2√κ_S/(1+κ_S)] ε_S ≤ γ_S ≤ ε_S.                    (5)

**Crucial:** The comparison uses κ_S for *each active interaction*, not κ_Q for the entire chosen set. There is no global κ in the exact formula. If f has degree at most d and the local κ_i≤K, one obtains `G*(Q)≥[2K^(d/2)/(1+K^d)] C_f(Q)` independent of the number |Q| observed. But equation (1) is stronger: it is exact and needs no condition-number assumption.

For scalar squared-error threshold η and nonadaptive fixed-subset acquisition,

    **N_f(η)=min{|Q| : Σ_{∅≠S⊆Q} γ_S ≥ V−η}.**          (6)

By convention an empty feasible family gives +∞. Equation (6) replaces the two-sided v1.1 sandwich exactly. It does *not* imply an exact cost formula for adaptive instruments whose measurements change residual quantum states.

## Geometric kernel uniqueness: precise claim and correction

A normalized symmetric Petz monotone metric has representation `c_f(x,y)=1/[y f(x/y)]`, where the standard operator-monotone function obeys `f(1)=1`, `f(t)=t f(1/t)`.

Suppose the *entrywise eigenvalue kernel itself* strictly tensorizes:

    c_f(x_1 x_2,y_1 y_2)=c_f(x_1,y_1)c_f(x_2,y_2)

for all strictly positive scalars. Substituting x_i/y_i=t_i yields `f(t_1 t_2)=f(t_1)f(t_2)`. Continuity gives `f(t)=t^α`; symmetry forces α=1/2. Conversely f(t)=√t is operator monotone and yields `c_f(x,y)=1/√(xy)`, which strictly tensorizes. Thus the geometric metric is the **unique normalized symmetric Petz metric with pointwise multiplicative c_f kernel**.

**However, it is NOT the only symmetric monotone metric admitting an exact product-support ANOVA.** The SLD metric already has the operational decomposition (1), despite its kernel `2/(x+y)` not being pointwise multiplicative. In fact, for *any* positive symmetric homogeneous degree-one operator mean `m(x,y)`, the induced quadratic tangent form

    F_m(Q)=Σ_ab |(A_Q)_{ab}|² / m(λ_a,λ_b)

satisfies `F_m(Q)=Σ_{S⊆Q}F_m(f_S;S)`, with nonnegative summands. The extension property (3) persists with `J_B` replaced by the inverse metric's dual covariance map: homogeneity gives `m(λ_a ν, λ_b ν)=ν m(λ_a,λ_b)`, and the same Hoeffding orthogonality completes the proof. This includes Petz SLD/arithmetic, geometric, Wigner–Yanase and Bogoliubov–Kubo–Mori metrics. **Do not confuse tensorization of an SDPI coefficient with exact subset ANOVA; they are distinct assertions.**

## Boundary and counterexample

Product average state is essential to this universal supermodularity argument. For a completely classical correlated pair X_1=X_2 of unbiased bits, both individually perfectly observed, f=X_1, we have `G*(1)=G*(2)=G*(12)=Var(f)=1`, so `G*(12)<G*(1)+G*(2)`; the unconditional joint average state is not a product. This demonstrates failure outside the assumptions, not failure of the theorem.

Limits: (i) single scalar real target and target-dependent collective POVMs; (ii) finite dimensions/support handling; (iii) fixed-subset observations; (iv) no conclusion about simultaneous optimal measurement of a vector of targets; (v) no blanket extension to sequential instruments or conditional average states losing the product structure; (vi) no claim about tensorization of general quantum SDPI constants.

## Independent audit receipts

1. `exact_audit.py`: three biased binary coordinates, noncommuting rational qubit encoders, exact rational SLD formula, eight exact subset gains, seven independently calculated direct Hoeffding gammas, Mobius inversion and all supermodular inequalities. Pass.
2. `near_degenerate_audit.py`: three full-rank, noncommuting rational qubit encoders with local κ=255, 511, 1023 and full product κ=133,302,015; same exact checks. Pass. This probes the user's suggested near-degenerate regime.
3. `metric_family_audit.py`: 200 independent random complex noncommuting, biased, 3-qubit examples across SLD, geometric, Wigner–Yanase, and Bogoliubov–Kubo–Mori metrics; 6,400 subset-gain comparisons and 5,600 component-coefficient checks; numerical error threshold reported in source. Pass.

These are computational replay certificates for finite cases, **not** a machine-checked proof of the universal theorem.

## Priority / bibliography checked November 11, 2026

- S. Personick, *Application of quantum estimation theory to analog communication over quantum channels*, IEEE Trans. Inf. Theory 17 (1971), 240–246, DOI 10.1109/TIT.1971.1054643. Prior source for optimized scalar Bayesian mean-square measurement.
- Mankei Tsang, *Generalized conditional expectations for quantum retrodiction and smoothing*, Phys. Rev. A 105, 042213 (2022), DOI 10.1103/PhysRevA.105.042213; *Operational meanings of a generalized conditional expectation in quantum metrology*, Quantum 7, 1162 (2023), DOI 10.22331/q-2023-11-03-1162. Especially close operator-projection and Bayesian-MSE antecedents.
- Yu Cao and Jianfeng Lu, *Tensorization of the strong data processing inequality for quantum chi-square divergences*, Quantum 3, 199 (2019), DOI 10.22331/q-2019-10-28-199. Relevant χ² tensor-product literature; their SDPI tensorization is not the present set-function ANOVA.
- Yu Cao, *Counterexamples to the Tensorization Property of Strong Data Processing Inequalities for Quantum Divergences*, arXiv:2608.13204v2 (October 28, 2026). Helps prevent overgeneralization of metric/SDPI tensorization claims.
- Frank Hansen, *Metric adjusted skew information*, Proc. Natl. Acad. Sci. USA 105 (2008), arXiv:math-ph/0607049. Background Petz metrics and operator means.
- Chen and Waggoner, *Informational Substitutes* (2017), arXiv:1703.08636. Classical marginal-information complementarity framework.

**Novelty status:** The exact combination `(1), (5), (6)` and full symmetric-metric extension was not identified in the searches performed in this session; this is **not a certified first publication**. A specialist should inspect Tsang (2022, 2023), noncommutative Hoeffding decomposition and quantum conditional expectations for equivalence. Public novelty requires that independent prior-art check and independent mathematical referee.

**Next independent theoretical audit:** Formalize the finite-dimensional projection commutation and Personick-to-projection identity in Lean; test singular support boundary cases; inspect prior art on product-state conditional expectations and noncommutative ANOVA. The research claim is not upgraded until that happens.
