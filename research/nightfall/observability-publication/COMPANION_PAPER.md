# Certificate Geometry and Influence Transfer on Product Spaces

**Devin J. Wright — NIGHTFALL research program**  
**Consolidated companion research manuscript — 10 November 2026**

## Abstract

We describe a distribution-independent mechanism transferring weighted antipodal certificate inequalities from the uniform Boolean cube to heterogeneous product probability spaces. Two independent samples, conditioned on their unordered coordinate pairs, induce independent fair orientations on a random subcube. This supports an all-pairs reciprocal certificate inequality, localized two-sided influence bounds, and a finite-product Aaronson–Ambainis-type influence theorem with no dependence on atom masses or alphabet sizes. The finite theorem and localized inequality are reported as Lean-kernel-checked in the supplied frontier package; extensions to arbitrary measurable products, improved constants, and quantum query consequences are distinct written claims requiring separate verification.

## 1. Two-draw orientation transfer

For independent X,Y under a product law, condition on the unordered pair {X_i,Y_i} for each coordinate. When X_i≠Y_i, the orientation is a fair sign, independently across coordinates, because p_i(a)p_i(b)=p_i(b)p_i(a). Restricting any Boolean observable to these orientations produces a Boolean-cube problem. Import Turturean's weighted antipodal inequality to obtain an all-pairs reciprocal estimate for rows/fractional certificates on the original product. This is the mechanism, not a claim that the imported antipodal inequality is original to NIGHTFALL.

## 2. Localized certificate-overlap theorem

For Boolean g with fractional certificate rows λ^x, define V_b=E[1{g(X)=b}/||λ^X||_1], and P_j=E[1{g=1}λ_j^X/||λ^X||_1²], Q_j analogously for g=0. Let I_j(g) be the directed resampling crossing probability. The source states

    V_1 V_0 ≤ Σ_j sqrt(I_j(g) P_j Q_j).

Writing p=P/V_1 and q=Q/V_0 and BC=Σ_j sqrt(p_j q_j), this implies

    max_{j:P_j Q_j>0} I_j(g) ≥ V_1 V_0 / BC².

This identifies influential coordinates in the overlap of the two certificate-load profiles and can strengthen the unlocalized bound. The finite statement is reported Lean-checked in the source checkpoint.

## 3. Finite-product influence theorem

For |f|≤1 of Efron–Stein degree ≤d and V=Var(f)>0 on finite heterogeneous product alphabets (zero-mass symbols allowed), the supplied Lean checkpoint reports the explicit guarantee

    max_j I_j(f) ≥ [sqrt(3/12500)/π^6] · V^(5/2)/d^6.

The imported Turturean cube theorem and formalization must be credited. The source claims kernel compilation with standard axioms and pinned dependencies; exact source SHA, CI job and proof receipts should accompany the eventual full LaTeX release.

## 4. Boundary between checked and written claims

The separate Frontier v1.0 manuscript gives a stronger constant near 1.20×10⁻³ and extends the claim to arbitrary measurable products, quantum query simulation, degree-one and biased-bit degree-two exponent-two results, and adaptive prediction. Those are not all part of the same Lean-kernel-checked declaration. Preserve the status ledger rather than conflating them.

The source's averaged quartic antipodal route was proposed as a path to general exponents (2,4), but the subsequent quadratic package reports a 17-bit counterexample to universal AQ(3). Do not publish AQ(3) as an open positive conjecture. General-degree exponent-two influence remains unresolved.

## 5. Relationship to principal paper

This companion supplies a **general-degree distribution-independent certificate engine**, while the principal quadratic manuscript supplies a **stronger degree-two observability theorem and matching adaptive/nonadaptive lower bounds**. Neither should be represented as a proof of the other's strongest unverified extensions.

## Source checkpoint

`NIGHTFALL_Frontier_v1(1).zip`, `Wright_Frontier_Product_Space_Influence(1).pdf`, and `frontier(1).pdf`; see their original theorem declarations, status ledger, and receipts. Publication requires preserving complete proof text and exact pinned verification provenance.
