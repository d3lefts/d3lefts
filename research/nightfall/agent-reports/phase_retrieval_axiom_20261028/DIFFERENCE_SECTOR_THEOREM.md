# AXIOM cross-audit — graded Werner coupling and strict certificate enlargement

**Date:** 2026-10-28. **Research owner:** Devin J. Wright. **Independent audit / theorem refinement:** Axiom (GPT-6). **Source:** Lemnis `research/nightfall/agent-reports/lemnis_assignment13_20261028/RESEARCH_NOTE.md` (GitHub blob `1c157f272e31364381e293a71ad1425964e8410c`). **Status:** exact finite check PASS; proof manuscript with a conditional input theorem; independent expert proof and priority reviews open. No unrestricted four-copy endpoint implication.

## Frozen scope

The Hilbert--Schmidt space is `M_(3^4)(C)`, represented by words a,b in F3^4. The four-copy endpoint operator K acts as `(I-|Omega_3><Omega_3|/2)^tensor4`. Put `Q(C)=<C,KC>`; its minimum eigenvalue is `-1/2`. The old rank-two-positive rectangle is `U=P_S M_(3^4) P_T` with `S=F3 x {0}`, `T={0} x F3`, using `H(a)=(a3-a1-a2,a4-a1-2a2)`. **Imported source premise:** `Q(X)>=0` for every X in U of matrix rank at most two, supported by the nine-word proof and exact internal arithmetic. Let `W0=E0 intersect U^perp`, `W2=E2 intersect U^perp` be the orthogonal positive-eigenspace extensions, `L=U direct_sum W0 direct_sum W2`.

For rank-at-most-two C write `C=C0+D0+D2+R` by orthogonal projection onto the four subspaces, and set `w=||D0||² + ||D2||²/4`, `r²=||R||²`. The old Lemnis input-sensitive lower bound was `Q(C)>=w-2h(C0)r-r²/2`, where `h(C0)=||(I-P_U)K C0||`.

## Theorem: exact difference-sector refinement

For `d in F3^4` let `Pi_d` project onto matrix units `E_ab` satisfying `a-b=d` componentwise mod 3. Define `C0_d=Pi_d C0`, `R_d=Pi_d R`, `h_d=||(I-P_U)K C0_d||` and `r_d=||R_d||`. Then

`Q(C) >= w - (1/2) sum_d r_d² - 2 sum_d h_d r_d.`

Hence a sufficient positivity test for the **original rank-two C** is

`w >= (1/2) sum_d r_d² + 2 sum_d h_d r_d.`

The new certificate is at least as strong as Lemnis's input-sensitive one, because `sum_d h_d*r_d <= (sum_d h_d²)^(1/2)*(sum_d r_d²)^(1/2)=h(C0)*r`. No rank assumption is placed on individual C0_d, R_d, or D_i.

**Proof:** The local kernel maps E_ab either to itself or (when a=b) to a linear combination of E_zz. Both transformations preserve the difference a-b mod 3, so K commutes with every Pi_d. The rectangle U is a coordinate subspace, hence P_U also commutes with Pi_d. Each local scalar/traceless orthogonal projector preserves the local difference, so E0 and E2, and thus W0, W2, L and L^perp, are direct sums of difference grades. Therefore C0, D0, D2, R and `(I-P_U)K C0` decompose orthogonally by d. The D_i are K-eigenvectors and orthogonal to C0,R, giving `Q(C)=Q(C0)+w+Q(R)+2Re<C0,KR>`. Since C0=P_S C P_T, `rank(C0)<=rank(C)<=2`, so the archived base theorem gives `Q(C0)>=0`. The minimum eigenvalue of K gives `Q(R)>=-sum r_d²/2`. The mixed term splits exactly as `sum_d <(I-P_U)K C0_d,R_d>`, and Cauchy--Schwarz grade by grade gives its lower bound `-sum_d h_d r_d`. Combine the inequalities. QED conditional on the base theorem.

**Crucial scope guard:** The individual grade projection Pi_d can increase matrix rank. It is invalid to infer `Q(C0_d)>=0` from rank(C)<=2. We apply the original positivity premise only to the *whole rank-two C0*.

## Strict new class: infinitely many exact rank-two witnesses

With `E_ab=|a><b|` and `0<t<2 sqrt(6)/5`, set

`C(t)=4 E_(0000,0000) + t[E_(0000,1111)+E_(1000,2121)+E_(0000,0121)]`.

All t>0 give matrix rank exactly 2. The source component `C0=4 E_(0000,0000)` belongs to grade 0000. The residual is

`R=t/3 * sum_(z=0)^2 E_(z000,z121)`, in grade 0212, with rank 3 and `r²=t²/3`; the other two matrix units and the traceless part of the third contribute `w=8t²/3`. Thus the only source/residual cross-grade terms are zero, and the new lower bound is exactly

`w-r²/2=5t²/2 >0`.

The old input-sensitive condition requires `(5/2)t² >= sqrt(6)*t`, i.e. `t >= 2sqrt(6)/5`, and therefore **fails for every t in the displayed open interval**. The new sufficient class strictly contains the old one even at fixed rank two. Physical partial-trace evaluation gives `Q(C(t))=1+(5/2)t²` exactly. At t=1/2: Q=13/8, new lower bound 5/8, old certificate fails; t=1/4: Q=37/32, new lower bound 5/32. This is a strict enlargement of the _certified class_, never an improved unrestricted Werner threshold.

The grade-zero base direction and residual 0212 have disjoint support; that is the specific geometric mechanism. A negative control with two distinct same-grade diagonals gives a nonzero cross term 1/8. Another negative control shows rank-one matrix `J_3` embedded into 4 sites can project under Pi_0000 to a rank-three diagonal, so the rank-preserving premise must remain on P_U C as a whole.

## Verification and reproducibility

- `check_difference_sectors.py`: separate sparse-K tensor implementation using `Fraction`; exactly checks all 6561 basis difference-grade invariances, the rank 2/3 distinction, the C(t) identities, h²=9/2, and new/old sufficient inequalities. Locally PASSED.
- `check_partial_traces.py`: independently enumerates 16 physical partial traces for each exact specimen, checks Q=13/8 and 37/32, plus both adversarial negative controls. Locally PASSED. No imported kernel code.
- Both tests verify concrete finite claims; the universal theorem is additionally justified by the explicit proof above. Human external peer-review and dated priority audit remain OPEN.

## Research significance

The operator transition is **refinement by conserved interaction sector**, not a cosmetic numerical retuning. It identifies exactly when a conservative global coupling norm gives a false negative. Applicability: finite Hermitian operators with a conserved orthogonal grading, rank-preserving source projection and spectral decoupling. Failure modes: broken grade invariance, projected rank inflation when trying to split the base positivity premise, and unverified imported source positivity. Novelty against general graded block inequalities is not claimed.

**Next decisive experiment:** compare grade-specific coupled candidate pairs in the 72 collision witness table; isolate a quantified condition beyond mere zero coupling, with finite exact coefficients, and test whether the same mechanism certifies one genuine colliding-sector rank-two family. Independently revisit primary prior art before public theorem promotion.