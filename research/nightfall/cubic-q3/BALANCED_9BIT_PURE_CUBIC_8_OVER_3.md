# Balanced 3×3×3 pure-cubic proof attack: exact ratio 8/3

**Checkpoint:** 2026-11-17 Eastern. Research direction Devin J. Wright / NIGHTFALL; AI-assisted optimization, rationalization, and exact independent replay. **Status:** finite certified construction and author-side elementary proof. **NOT** unrestricted cubic exponent-two, not a Lean theorem, not an independently refereed result, and no established world-wide novelty/priority.

## Exact tensor

Let \(A_0,A_1,A_2,B_0,B_1,B_2,C_0,C_1,C_2\) be nine independent fair signs, and set
\[
f(A,B,C)=\sum_{i,j,k=0}^2 T_{ijk}A_iB_jC_k,
\quad
T_0=\begin{pmatrix}0&-1&-1\\1&1&0\\-1&0&1\end{pmatrix},\
T_1=\begin{pmatrix}1&-1&0\\0&1&-1\\1&0&-1\end{pmatrix},\
T_2=\begin{pmatrix}1&0&1\\1&0&1\\0&0&0\end{pmatrix}.
\]
All **16** nonzero Walsh coefficients are exactly \(\pm1\), every term has **exactly one coordinate from each block**, and the function has zero mean and pure ANOVA/Fourier degree three. Direct independent enumeration of the 512 sign assignments yields exactly \(\min f=-4,\max f=4\); hence centered radius \(B=4\). Parseval, independently confirmed by the full table, yields \(\operatorname{Var}(f)=16\).

The source-resampling influences are **exactly**
\[
(I_{A_0},I_{A_1},I_{A_2})=(6,6,4),\quad
(I_{B_0},I_{B_1},I_{B_2})=(6,6,4),\quad
(I_{C_0},I_{C_1},I_{C_2})=(6,4,6).
\]
Thus \(M=6\), and
\[
\boxed{\frac{\operatorname{Var}(f)^2}{B^2\,\max_iI_i(f)}
=\frac{16^2}{4^2\cdot6}=\frac83.}
\]
This exceeds the prior *pure three-partite* exact fair-routing checkpoint ratio \(2\) in archived PR #797 by precisely **one third**. It falsifies any proposed pure-tripartite coefficient \(C<8/3\), including the tempting \(C=2\), but it does **not** refute a dimension-free constant \(C\ge8/3\). The anchored all-degree fair-control theorem in draft PR #804 gives \(C\le4\) for pure tripartite fair signs, so **within that class** the author-side bound on the optimal coefficient is \(8/3\le C^*_{\mathrm{trip}}\le4\). That upper is not independently Lean or human-referee certified.

**Critical global distinction:** The unrestricted *nonhomogeneous* degree-≤3 coefficient already has lower bound \(9\) in the \(n\to\infty\) biased-Chebyshev family of merged PR #805. Therefore this 8/3 witness is a sharper **pure-cubic stress test**, **not** an improvement to the all-cubic coefficient floor \(9\), and certainly not a falsification of N-UE2(2,1).

## Mechanism: balance source influence without increasing amplitude

The previous 8-bit routing example had 16 cubic Walsh monomials, \(B=4\) after clearing denominators, and maximal influence \(8\), giving ratio 2. The new tensor retains the same 16 \(\pm1\) coefficients and \(B=4\), but spreads their incidences among nine coordinates so the largest coordinate participates in only **six**, not eight, nonzero triples. All 512 function values remain within \([-4,4]\) because of signed cancellations. This *balanced overlap with preserved cancellation* is a structural operator that a universal cubic proof must handle, not just rare-atom selector spikes.

A single-coordinate ±1/0 coefficient substitution in the 27-entry tensor was independently exhaustively checked; none improved the exact ratio 8/3. This is **local discrete stability only**, not global optimality.

## Exact unbounded cover family

Let \(f^{(1)},\dots,f^{(m)}\) be independent disjoint copies, and set \(F_m=m^{-1}\sum_{r=1}^m f^{(r)}\). Then \(\|F_m\|_\infty\) has centered radius \(4\), \(\operatorname{Var}(F_m)=16/m\), and \(\max_i I_i(F_m)=6/m^2\), so the normalized ratio remains **8/3 for all m**. The support of one gadget consists of triples meeting all three blocks; its minimum vertex cover has size exactly three (the full coordinates of any one block, with no smaller cover). Thus the m-fold family has top-degree cover number \(3m\to\infty\).

**Limitation:** The copies are independent blocks and so the earlier independent-block cubic theorem already applies. Unbounded cover size alone is not an obstruction to the existence of exponent two. The new hard case is *within each 3×3×3 connected overlap gadget*: balancing all nine original influences while retaining signed amplitude cancellation.

## Validation and next gate

\`python3 -I research/nightfall/cubic-q3/check_balanced_tripartite_9bit.py\`:
- exhaustively enumerates 512 full input states;
- independently computes true resampling influences by flipping every source sign at every input;
- verifies the full 512-coefficient Walsh transform and exactly sixteen pure degree-three coefficients;
- computes exact vertex-cover minimum by exhaustive subsets;
- reconstructs and checks the disjoint-gadget scaling formulas for multiple m without using approximate floating-point tolerances;
- checks all 54 single-entry tensor mutations in \(\{-1,0,1\}\) and records no improvement.

Source and CI SHA-256 are part of the PR. This exact finite replay does NOT establish any universal upper inequality.

**Discovery graph:** unrestricted cubic → pure three-partite stress gate → balanced 16-edge incidence tensor → exact amplitude-4 cancellation → influence max 6 → rational ratio 8/3 → no C=2 shortcut → continue source-consistent mean-coupled two-replica quadratic gate (#799/#803). Competing prior art in multilinear Littlewood/Varopoulos and three-way tensor norms must be reviewed before any originality claim.


## Stronger mechanism discovered after exact replay: perfect three-way routing

Define three row coefficients \(H_i(B,C)=\sum_{j,k}T_{ijk}B_jC_k\). The independent 64-state control enumeration shows that **for every** \((B,C)\in\{\pm1\}^{3+3}\), the vector
\[
(H_0,H_1,H_2)\in\{(\pm4,0,0),(0,\pm4,0),(0,0,\pm4)\}.
\]
It follows that \(f(A,B,C)=\pm4\) at **every** one of the 512 full assignments; after scaling by four, \(f/4\) is a *balanced sign-valued pure Fourier cubic*. Thus the amplitude bound is an exact pointwise **identity**, not merely a maximal-value check.

Equivalently, \(f/4\) defines a perfect two-coloring of the nine-dimensional Boolean cube with exactly **three pivotal coordinates at every input** (its Fourier spectrum is entirely on level three). Its coordinate *average* sensitivities vary: \((3/8,3/8,1/4;3/8,3/8,1/4;3/8,1/4,3/8)\). The mechanism is a three-way router with exactly one active A-leaf and selector influence more evenly distributed than binary-address routing.

**Priority caution:** Pure-degree Boolean functions are classical equitable partitions/perfect colorings; the 2024 classification literature and Tarannikov–Carlet/Chiarelli–Hatami–Saks constructions are relevant. An explicit nine-bit table must **not** be called a new worldwide Boolean perfect coloring until compared to those classifications.

## General theorem transferred from classical junta bounds: sign-valued homogeneous degree three

This is a **mathematical upper bound for a restricted class**, unlike the exact lower construction. Let \(g:\{\pm1\}^n\to\{\pm1\}\) have Fourier support **only on subsets of size 3** (uniform independent fair signs). Then
\[
\boxed{\max_i I_i(g)\ge\frac5{16},\quad
\frac{\operatorname{Var}(g)^2}{\|g\|_\infty^2\max_iI_i(g)}
\le\frac{16}{5}=3.2.}
\tag{BQ3}
\]
This uses a classical, **externally imported** sharp bound: every real-Fourier-degree-three Boolean function has at most ten relevant variables \(r(g)\le10\). This was established in the Boolean relevant-variable literature (Tarannikov–Kirienko/Zverev; recorded by Chiarelli–Hatami–Saks and Ferdinand Ihringer's historical survey, https://blog.ihringer.org/2021/11/01/a-boolean-function-with-small-degree-and-many-variables/). No originality is claimed for that imported bound.

**Proof.** For a set \(S\) of three coordinates and any fixed settings of the others, degree three implies the coefficient \(\widehat g(S)\) equals the eight-point signed average \((1/8)\sum_{u\in\{\pm1\}^S}g(u,x_{-S})\prod_{i\in S}u_i\). Every summand is ±1, so this eight-term sum is even; hence every degree-three Fourier coefficient lies in \((1/4)\mathbb Z\). Pure homogeneity implies \(E g=0\) and \(\operatorname{Var}(g)=E g^2=1\). By Parseval,
\[
I_i(g)=\sum_{S\ni i}\widehat g(S)^2 \in (1/16)\mathbb Z_{\ge0},
\quad \sum_i I_i(g)=3.
\]
If \(M<5/16\), integrality gives \(M\le4/16=1/4\), whence \(3=\sum_i I_i\le r(g)M\le10/4=5/2\), contradiction. Therefore \(M\ge5/16\). Since \(\|g\|_\infty=1\), (BQ3) follows.

**All-degree transfer operator.** For a pure degree-d Boolean sign function \(g\), the same \(2^d\)-corner argument gives \(\widehat g(S)\in2^{1-d}\mathbb Z\) for \(|S|=d\), so \(I_i\in4^{1-d}\mathbb Z\), while \(\sum_iI_i=d\). If the established maximum-relevant-variable bound is \(r(g)\le R_d\), then
\[
\boxed{\max_iI_i(g)\ge
4^{1-d}\left\lceil\frac{d\,4^{d-1}}{R_d}\right\rceil.}
\tag{JIT}
\]
This *junta-to-influence quantization operator* transforms a structural variable-count theorem into a numerical influence theorem. At degree 2, the classical exact \(R_2=4\) gives \(M\ge1/2\), sharp for the four-bit bilinear selector. At degree 3, exact \(R_3=10\) gives \(M\ge5/16\). The new nine-bit router gives \(M=3/8\), so within **uniform-cube, ±1-valued homogeneous cubic functions** the valid bracket is
\[
\boxed{\frac83\le C^*_{\rm Boolean,pure,3}\le\frac{16}{5}.}
\]
This is **not** an inequality for arbitrary real-valued cubics, biased signs, arbitrary categorical alphabets, or nonhomogeneous degree≤3 functions. N-UE2(2,1) and the unrestricted cubic theorem remain OPEN.

**Adversarial comparator:** The classical ten-variable Chiarelli–Hatami–Saks recursive Boolean function \(G_3(s,t,y,z)=(s+t)G_2(y)/2+(s-t)G_2(z)/2\), \(G_2(s,t,u,v)=(s+t)u/2+(s-t)v/2\), is pure degree-three and depends on all ten variables, but its two selector influences are \(1/2\) and its eight descendants each have influence \(1/4\). Its normalized ratio is only 2. Thus a larger relevant-variable count by itself does not yield a harder influence example. The checker adds an independent 1,024-state replay of this comparator, and of the router's exact one-active-leaf identity.

**Certification:** The displayed deduction imports the classical \(R_3=10\) classification and otherwise uses elementary exact Fourier/Parseval arithmetic. This is **author-side analytic**, with finite negative controls, and is not an independent proof or Lean verification of the historical classification. The tensor itself remains a finite exact checked witness. Publication originality review is still required.


## Source-consistent annealed-Q2 gate stress: K ≥ 64/49 exactly

Unlike the earlier counterexample to the *unstructured* annealed quadratic inequality, this test is an actual source-consistent two-replica image of the 9-bit pure cubic above.

For independent original uniform source draws \(X,Z\) and independent fair selector signs \(\varepsilon_i\), define \(F_{X,Z}(\varepsilon)=f(Y)\), where \(Y_i=X_i\) for \(\varepsilon_i=+1\) and \(Z_i\) otherwise. Let \(Q_{X,Z}=\Pi_{\le2}^{\varepsilon}F_{X,Z}\). Use precisely the #799 definitions
\[
A=\operatorname{ess\,sup}_{X,Z,\varepsilon}|Q_{X,Z}(\varepsilon)|,\quad
U=\mathbb E_{X,Z}\operatorname{Var}_\varepsilon(Q_{X,Z}),\quad
J=\max_i\mathbb E_{X,Z}I_i^\varepsilon(Q_{X,Z}).
\]
The exact values are
\[
\boxed{A=7,\qquad U=12,\qquad J=9/4,\qquad
\frac{U^2}{A^2J}=\frac{64}{49}>1.}
\]
**Therefore the coefficient-one source-consistent annealed-Q2 gate \(U^2\le A^2J\) is FALSE.** The genuine open question in #799/#803 remains whether a finite **universal** coefficient \(K\ge64/49\) exists; no such upper bound is proved here.

**Exact mechanism / efficient full enumeration.** Let \(D=\{i:X_i\ne Z_i\}\). Every original cubic Walsh term \(T_e\chi_e\) becomes a fair Walsh character with selector support \(e\cap D\). The projected \(Q\) removes exactly those original terms for which the full cubic support \(e\subset D\), leaving
\[
Q_{D,X}(\varepsilon)=\sum_{e:\,|e\cap D|\le2}T_e\chi_e(X)\chi_{e\cap D}(\varepsilon).
\]
For any fixed \(D\), varying \(X\) and \(\varepsilon\) is equivalent for the amplitude maximum to varying \(X\) at \(\varepsilon=+\mathbf1\). The checker enumerates **all \(2^9\) disagreement masks and all \(2^9\) original \(X\)-states**, collecting the exact fair Walsh coefficients by selector support. It computes \(A=7\) without invoking the spectral transport identity, and the exact separate fair variance/influence squares directly: \(U=12\), \(J_i=(9/4,9/4,3/2;\ 9/4,9/4,3/2;\ 9/4,3/2,9/4)\). The maximum possible amplitude over 512 disagreement masks has frequency distribution \(A_D=0:1,\ 4:223,\ 5:76,\ 6:160,\ 7:52\).

The analytic spectral identities #799 give an independent cross-check: pure cubic \(U=3V/4=12\) and \(J_i=3I_i/8\), hence \(J_{\max}=9/4\). The full exact enumeration goes beyond simply assuming those identities.

**Under disjoint m-block replication** with \(f_m=m^{-1}\sum_r f^{(r)}\), the source-consistent projection remains block-additive, its essential amplitude remains \(A=7\), \(U=12/m\), and \(J=9/(4m^2)\). Thus the gate ratio \(64/49\) persists with growing support and cubic-cover size. This is not a counterexample to dimension-freeness, only to the specific coefficient-one shortcut.

**Checker:** \`python3 -I research/nightfall/cubic-q3/check_replica_balanced_9bit.py\`, independently replayed alongside the cubic truth/Walsh checker in the same fail-closed GitHub CI action. This is an exact finite lower certificate; neither the universal annealed-Q2 bound nor unrestricted Q3 exponent two has been proved.
