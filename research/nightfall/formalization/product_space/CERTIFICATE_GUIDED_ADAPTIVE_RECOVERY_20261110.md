# NIGHTFALL: certificate-guided adaptive observation (research note)

**Date:** 2026-11-10. **Status:** derived proposition; generic Lean sublemmas in stacked draft PR #300, probabilistic end-to-end theorem NOT yet Lean-compiled or externally reviewed. **Primary parent:** #298 (`localized_two_sided_product`, pinned Lean 4.33.0, Turturean's determinant/antipodal inequality), via #295 and #293.

## 1. Definitions and assumptions

Let `X=(X_i)_{i∈J}` be a finite product of independent finite alphabet random variables with strictly positive atom masses. Let `g:X→{0,1}` have Hoeffding interaction degree at most `d≥1`. Suppose for each point `x` there is a fractional-certificate row `λ^x_i≥0` satisfying

`sum_{i:x_i≠y_i} λ^x_i ≥ 1` whenever `g(x)≠g(y)`, and `sum_i λ^x_i≤K` for some `K≥1`.

Define the **directed resampling influence**

`I_i(g) = Pr[g(X)=1, g(X^{i←Y_i})=0]`,

where `Y_i` is an independent marginal resample. This equals `E[Var(g|X_{-i})]`, not the full probability of disagreement. Define

`V_1=E[1_{g=1}/||λ^X||_1]`, `V_0=E[1_{g=0}/||λ^X||_1]`,

`P_i=E[1_{g=1} λ^X_i/||λ^X||_1²]`, `Q_i=E[1_{g=0} λ^X_i/||λ^X||_1²]`.

When `g` is nonconstant, `V_1,V_0>0`, `sum_iP_i=V_1`, `sum_iQ_i=V_0`. Put

`S=sum_i sqrt(P_i Q_i)>0`, `B=S/sqrt(V_1V_0)∈(0,1]`, `π_i=sqrt(P_iQ_i)/S`.

## 2. The certificate-overlap sampling theorem

The Lean-verified localized inequality from #298 states

`V_1V_0 ≤ sum_i sqrt(I_i(g) P_i Q_i)`.

Weighted Cauchy--Schwarz, with `q_i=sqrt(P_iQ_i)`, yields

`(V_1V_0)² ≤ (sum_i q_i) (sum_i q_i I_i(g)) = S² E_{i~π} I_i(g)`.

Therefore

`E_{i~π} I_i(g) ≥ (V_1V_0)²/S² = V_1V_0/B² ≥ V_1V_0 ≥ Var(g)/K².`

The `B^{-2}` improvement is geometric and is **relative to the selected certificate rows**, not an automatic improvement over independently optimizing the rows or other algorithms. Evaluating `π` may require costly exact averages over the entire input distribution. The result is an existence/query-complexity theorem, not a polynomial-time implementation claim.

## 3. Exact posterior descent

Let `g=Σ_{S⊆J}g_S` be its orthogonal Hoeffding decomposition; `e_S=E[g_S²]`. Put `T(g)=Σ_i I_i(g)=Σ_{S≠∅}|S|e_S`. For degree `d`:

`Var(g)=Σ_{S≠∅}e_S ≤ T(g) ≤ d Var(g)`.

For any unobserved coordinate `j`, conditioning on `X_j` and averaging over its realized value gives the **identity**

`E_{X_j}[T(g|X_j)] = T(g)-I_j(g)`.

One proof: components not containing `j` retain their energy in expectation and cardinality; components containing `j` retain their energy after conditioning, but lose exactly one active coordinate. The direct conditional-expectation / Möbius decomposition supplies a second finite check. This identity does NOT claim that posterior total influence is pointwise reduced for every realization.

## 4. Adaptive prediction theorem (derived; proof still needs a single Lean bridge)

At any nonconstant conditional state, restrict the rows to remaining coordinates (their validity and cost `≤K` are preserved); compute `π` from that state's two class-load profiles; sample an unobserved coordinate according to `π` and reveal it. Stop at constant states.

The sampler and posterior identity imply

`E[T_next | state] = T - E_{j~π}I_j ≤ T - Var(g)/K² ≤ (1-1/(dK²))T.`

Thus with `T_t` the random total influence after `t` observations,

`E T_t ≤ (1-1/(dK²))^t T_0 ≤ d Var(g) exp(-t/(dK²)).`

The conditional-mean predictor has expected MSE

`E[Var(g|observations)] ≤ E T_t`,

so `MSE_t ≤ d Var(g) exp(-t/(dK²))`. In particular `t ≥ dK² log(d Var(g)/η)` suffices when the logarithm is positive; otherwise the trivial predictor already meets the stated upper bound. If the number of coordinates is smaller, observing all of them yields zero error. All counts are numbers of queried **whole coordinates**, not runtime or bit complexity.

This is a concrete quantitative theorem conditioned on bounded fractional-certificate cost and bounded interaction degree. It is **not** a proof of an unconditional alphabet-independent row bound `K=O(d²)`, nor of the real-valued Aaronson--Ambainis `(2,4)` exponent upgrade.

## 5. Verification / proof obligations

- **Certified parent:** #298 Lean 4.33.0, same-toolchain `localized_two_sided_product` and `two_sided_product`, CI https://github.com/d3lefts/d3lefts/actions/runs/42903333354.
- **This draft:** weighted Cauchy; normalized overlap sampler; potential descent; geometric recurrence. Their exact kernel status is given by CI on PR #300, not by this document.
- **Independent exact counterexample search:** `check_certificate_guided_descent.py` independently enumerates 522 nonconstant Boolean truth tables with deliberately unequal, valid class-specific certificate rows. It verifies the sharper `B^{-2}` bound, expected posterior total-influence decrement, and full Hoeffding energy/degree identities with `fractions.Fraction`. Passing finite tests is not a universal proof.
- **Remaining formal gates:** (i) derive class masses/loads as definitions and discharge the abstract sampler's hypotheses automatically using #298; (ii) kernel-compile the posterior ANOVA identity and row-restriction invariant; (iii) construct the adaptive policy and its expectation recurrence; (iv) review complexity and measure-normalization conventions; (v) dated independent originality assessment.

## 6. Attribution and prior art

The determinant/antipodal theorem belongs to David Turturean (2026, arXiv:2611.09773). The preceding fractional-certificate method and cost program includes Lovett--Zhang (ITCS 2023). Influential-variable and decision-tree inequalities under arbitrary product measures were established by O'Donnell--Saks--Schramm--Servedio (FOCS 2005). The Hoeffding--Efron--Stein decomposition and influence identities are classical. This research note derives a certificate-overlap sampler from #298; **no world-first priority claim is made**. Distinguish law-independent query bounds, algorithmic runtime, and strong prior art.

**Operator transfer:** certificate geometry → coordinate sampling law → exact posterior potential identity → geometric prediction-error reduction. The proof obligations that connect the abstract sampler to posterior information remain explicit.
