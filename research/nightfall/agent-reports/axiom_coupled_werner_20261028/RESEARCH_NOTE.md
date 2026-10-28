# AXIOM / NIGHTFALL — Sharp coordinate-support positivity for finite-copy Werner forms

**Dated research checkpoint:** 2026-10-28. **Human research lead:** Devin J. Wright. **Mathematical derivation and executable audit:** Axiom (GPT-6). **Task:** NIGHTFALL Issue #15, independent coupled-sector theorem; Axiom Issue #12. **Claim status:** Self-contained elementary proof, local exact-arithmetic checks; **independent external proof review and publication-priority audit are open**. No unrestricted rank-two positivity statement is made.

## 1. Contract and exact model

Let local dimension `d >= 2`, integer `r >= 2`, copy number `n >= 1`, and let `Omega_d = sum_{j=0}^{d-1} |jj>` be the **unnormalized** maximally entangled vector. Write

`K_(n,d,r) = (I_(d^2) - (1/r) |Omega_d><Omega_d|)^(tensor n)`

and `Q_(n,d,r)(C)=<vec C,K vec C> = sum_(J subset [n]) (-1/r)^|J| ||Tr_J C||_F^2`. The current four-qutrit Werner endpoint is `n=4,d=3,r=2`.

For a matrix-unit coordinate `(a,b)` with words `a,b in {0,...,d-1}^n`, define its additive difference label `delta=a-b mod d`. These labels are **bookkeeping coordinates** even when `d` is composite; no field operations are required.

## 2. Exact fiber kernel (proved)

The operator conserves each difference grade. Fix a grade `delta`; let `Z={i:delta_i=0}` and `z=|Z|`. Matrix units `E_(a,a-delta)` and `E_(c,c-delta)` have coupling

`<E_(a,a-delta), K E_(c,c-delta)> = [prod_(i not in Z) 1_(a_i=c_i)] * prod_(i in Z) [1_(a_i=c_i)-1/r]`.

**Proof:** For each local matrix unit, the single-site operator sends `E_ab` to `E_ab` if `a!=b`, and sends `E_aa` to `E_aa-(1/r) sum_j E_jj` if `a=b`. The tensor product gives the formula, and no term changes `a-b`.

For each grade, group together the rows `a` sharing their symbols at all nonzero coordinates of `delta`; different groups are orthogonal for Q.

## 3. General all-copy, all-dimension coordinate-sparsity theorem (proved)

**Theorem A.** Let `C` be any complex matrix. Suppose in every conserved difference grade the matrix has **at most r nonzero matrix-unit coordinates**. Then `Q_(n,d,r)(C)>=0`. More generally it suffices that each independent group described above has at most `r` supported entries.

**Proof:** On a group of `s<=r` row coordinates `a^(1),...,a^(s)`, the Gram matrix for each zero-difference site `i` is `G_i[j,k]=1_(a_i^(j)=a_i^(k))-1/r`. For any complex `v`, collect values `y_t=sum_(j:a_i^(j)=t) v_j` over the `m<=s<=r` distinct symbols present. Then

`v* G_i v = sum_t |y_t|² -(1/r)|sum_t y_t|² >= (1-m/r)sum_t |y_t|² >=0`

by Cauchy–Schwarz. For nonzero-difference sites, the local matrix is the identity on a group. The full grade Gram is the entrywise product of these sitewise PSD matrices. The **Schur product theorem** makes it PSD. Sum over the orthogonal groups and grades. QED.

**Corollary (all copies, arbitrary columns):** Every matrix supported in at most `r` computational-basis **rows**, with no restriction on its columns, satisfies `Q_(n,d,r)>=0` for every `n` and `d`. Likewise with rows and columns interchanged. Such matrices automatically have rank at most `r`.

**Sharp row threshold:** If `d>=r+1`, take `r+1` distinct diagonal matrix units whose row and column labels differ only in the first site. Their sum has matrix rank `r+1` and gives

`Q = -((r+1)/r) * (1-1/r)^(n-1) < 0`.

Consequently **r is the largest universally safe number of arbitrary computational-basis rows** for this theorem (with `d>=r+1`). This sharpness claim concerns coordinate-row support, not arbitrary matrix rank.

## 4. Exact iff criterion for qutrit rank-two endpoint (proved)

Specialize to `r=2,d=3`, any `n>=1`. Inside a fixed grade and a fixed group of nonzero-coordinate symbols, the Gram is

`G[u,v]=2^(-z) (-1)^H(u,v)`, where H is Hamming distance over the `z` zero-difference sites.

**Theorem B (sharp support classifier).** The compression onto **all** matrix units of a supported set `S` is positive semidefinite **if and only if** every triple `(u,v,w)` of different supported words has an *even* number of zero-difference coordinates in which all three symbols `0,1,2` appear. The criterion applies group by group; groups and grades are mutually orthogonal.

**Proof:** Set `sigma(u,v)=(-1)^H(u,v)`. If every triangle has `sigma(u,v)sigma(v,w)sigma(w,u)=1`, fixing a root `u0` and writing `epsilon(u)=sigma(u,u0)` gives `sigma(u,v)=epsilon(u)epsilon(v)`. The compressed Gram is the nonnegative rank-one outer product `2^(-z) epsilon epsilon*`. Conversely, if a triangle product is `-1`, select coefficients `(1,-sigma(u,v),-sigma(u,w))` on its three matrix units; the three pair contributions are all `-2^(1-z)`, and the total quadratic value is `-3*2^(-z)<0`. The triangle sign is `(-1)^R`, where `R` is the number of sites showing all three symbols: at each site the three pairwise Hamming indicators sum to 0, 2, or 3, with odd parity exactly when the three symbols are all distinct. QED.

This is the classical **signed-graph balance/switching criterion** applied to an exact Werner-operator fiber. The general signed-graph mechanism is established prior art. Any novelty would have to concern the specific Werner application, sharp witness-family comparison, or algorithmic use.

## 5. Strict coupled-sector gain against the previous graded sufficient certificate

In the original `n=4,d=3,r=2` model define

`C(t) = E_(0000,0000) + t E_(1000,1000)` for real `t>0`.

It has rank exactly 2; both entries occupy difference grade `0000`. Their mixed kernel coefficient is `-1/16`, so

`Q(C(t))=(1-t)^2/16 >=0`, including the exact zero at `t=1`.

Relative to the archived `U` rectangle, `C0=E_(0000,0000)`, `P_U E_(1000,1000)=0`, and the previous grade-sensitive certificate requires `w >= 2h r_R + r_R²/2` within that grade. Here `h²=9/32`. The negative spectral E1/E3 components of `E_(1000,1000)` give `r_R² >= (40/81)t²`, while the positive spectral contribution obeys `w<=t²`. Hence the older required RHS is at least `(sqrt(5)/3)t`, which exceeds the allowed `w<=t²` whenever `0<t<sqrt(5)/3`. Thus the older graded certificate fails throughout that open interval, while the new *coupled* fiber theorem certifies every point.

The rank-three sharp obstruction is `E_(0000,0000)+E_(1000,1000)+E_(2000,2000)`, with exact `Q=-3/16`. A three-supported *balanced* example is `E_(0000,0000)+u E_(1000,1000)+v E_(1100,1100)`; for arbitrary complex `u,v`, `Q=|1-u+v|²/16>=0`, with nonzero pairwise couplings.

## 6. Independent audit and failure controls

- `check_signed_grade.py`: exact matrix-unit tensor K path, all **531,441** within-grade ordered entry comparisons, all `C(81,3)=85,320` grade-zero triangle parity conditions, direct rank-two/three and balanced three-support controls.
- `check_physical_traces.py`: fully separate sixteen-partial-trace path, **432** different-grade and same-grade coupling checks, exact rank-two and rank-three forms, and a rational failure certificate for the earlier graded test.
- `check_general_row_sparsity.py`: independently recomputed physical traces for `r=3,d=4` and `r=2,d=3`, **560** exact three-coordinate principal-minor checks, **54** random sparse-row full-column forms, and sharp `r+1`-row negative examples across four `(n,d,r)` configurations.

All executed in Python with `fractions.Fraction`, without floating-point tolerances; output, source SHA-256 and commands are in `MANIFEST.json`. Passing finite tests validate their stated scope. The written universal proofs rely additionally on elementary Cauchy–Schwarz, Schur products and exact fiber identities, and await a non-author review.

## 7. Prior art, significance, and limits

Relevant prior mathematics: balanced signed-graph switching (classical, see Harary's criterion); positive Schur/Hadamard products (classical); Werner partial-trace inequalities including Costa Rico (Letters in Mathematical Physics 2025, DOI `10.1007/s11005-025-01935-y`) and earlier Werner papers. The cited literature studies broader arbitrary rank-constrained positivity, which the present coordinate-sparsity theorem **does not establish**. The elementary signed-graph and Schur-product ingredients preexist, and a same-scope all-n result may already appear elsewhere. **Publication priority is INCONCLUSIVE**. This proof does not settle any unrestricted finite-copy Werner-distillability endpoint and makes no new parameter-threshold claim.

**Next decisive task:** compare existing all-copy row-support/coordinate-sparse lemmas in published Werner proofs under the identical unnormalized-Omega convention, and test whether the grade/fiber support classifier can yield a nontrivial cone enlargement beyond known subspace-preserving symmetries.

**Assignment-loop handoff:** Issue #15 Werner coupled sectors addressed with a new exact coordinate-support classifier and negative threshold witnesses. Issue #12 field reconstruction remains a separate proof and same-scope-priority audit. Recheck shared task queue and latest issue comments after submitting these results.
