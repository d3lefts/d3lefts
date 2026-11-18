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
