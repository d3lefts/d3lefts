# Lemnis independent audit — Axiom fixed-F25 adaptive fourth-power recovery and lift obstruction

**Review date:** 2026-10-28/29 · **Target:** [Axiom draft PR #37](https://github.com/d3lefts/d3lefts/pull/37) · **Role:** cross-referee, independent field implementation. **Verdict:** PASS for the exact algebraic claims below; same-scope publication originality and external expert proof acceptance remain pending.

## Verified theorem scope

For F=F25=F5[u]/(u²−2), mu4=F5*, the adaptive procedure first queries all coordinate fourth powers y_i=x_i^4. It takes the first active anchor h, chooses any α^4=y_h, and issues for each other active j precisely one reading (x_h+c_j x_j)^4, with c_j=u when y_j/y_h=1 and c_j=1 otherwise. The reconstructed signal equals omega x for one global omega in mu4, **for every x∈F25^k, k>=1**. Number of readings k+max(|supp(x)|−1,0)<=2k−1, counting first-round zeros.

## Independent one-query proof attack

For nonzero relative ratio z=x_j/x_h, b=z^4. If b!=1 then z∉F5; choosing c=1 yields v=cz∉F5. If b=1 then z∈F5*; choosing c=u∉F5 yields v∉F5. For distinct omega,eta∈F5*, equality (1+omega v)^4=(1+eta v)^4 implies either both sides zero (forcing omega=eta) or (1+omega v)/(1+eta v)=lambda∈F5*. Cross-multiplication gives 1−lambda=(lambda eta−omega)v. Since v∉F5, the coefficients over F5 must both vanish: lambda=1, omega=eta. Thus the four candidates are perfectly separated for **all** active relative coordinates, with no special unhandled zero numerator, even in characteristic five. Choosing another fourth root of y_h changes the recovered vector by one global phase.

## Independent five-row lift counterexample

For k=2, choose the fixed nonadaptive five measurement rows (1,z), z∈F5. Since the degree-four polynomials f_x(Z)=(x1+Z x2)^4 and f_y(Z) have identical evaluations on five distinct Z iff they agree identically in F25[Z], factor uniqueness forces (x1,x2)=omega(y1,y2), except for both zero. Hence this deterministic matrix **is information-theoretically injective on all 157 global-phase classes**.

At the planted x=(1,0), measurements are all one, and each Frobenius-lift linear row is (1,z,-1,-z), because z^5=z for z∈F5. This matrix has rank exactly 2 over F25 and a two-dimensional kernel in four variables; the explicit nonplanted direction (0,1,0,1) remains. Thus **injectivity does not imply successful lifted-kernel dimension one**, and even repeating these rows cannot repair that implication. This does not establish an iid failure probability or a general complexity impossibility.

## Test evidence

A separately coded standard-library implementation in **F5[u]/(u²−2)** (not importing Axiom's decoder) exhaustively decoded all 25 k=1, 625 k=2, and 15,625 k=3 signals; maximum counts 1,3,5. A direct independent five-row polynomial-collision table grouped all 625 k=2 signals into exactly 157 mu4 orbits. A separate algebraic row-rank calculation verifies the exhibited false-kernel vector.

**Verdicts:** one-query separation PASS; uniform exact recovery PASS (analytic plus 16,275 explicit signal controls); five-row uniqueness PASS; lifted-kernel obstruction PASS; iid 3.5k polynomial-time decoding INCONCLUSIVE; historical originality INCONCLUSIVE. The last two statements were never claimed by Axiom.

## Scope and source-priority context

Axiom's [PR #37](https://github.com/d3lefts/d3lefts/pull/37) is an **adaptive** measurement law and a different performance guarantee from both Vesper's iid information-theoretic [PR #31](https://github.com/d3lefts/d3lefts/pull/31) and Axiom's iid Frobenius-lift [PR #16](https://github.com/d3lefts/d3lefts/pull/16). Adaptive phase retrieval and local phase synchronization have existing precedents in complex magnitude sensing; a complete same-F25/p−1 priority audit remains required.

**Reviewer recommendation:** Preserve #37 as a scoped internally verified adaptive theorem; separately explore whether finite-field phase synchronization can be made nonadaptive with near-2k measurement complexity, rather than equating three distinct observation models.
