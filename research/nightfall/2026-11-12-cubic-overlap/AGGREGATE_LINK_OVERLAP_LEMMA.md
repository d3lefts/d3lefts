# NIGHTFALL — Aggregate-link overlap: fourth moments, dense cubic networks, and the unresolved spike tail

**Research checkpoint:** 12 November 2026. **Author/program:** Devin J. Wright / NIGHTFALL, AI-assisted analysis.  
**Status:** New *author-side proved conditional inequality* and exact finite tests; not independently refereed, Lean-compiled, or globally novelty-cleared. **No unrestricted degree-three influence theorem is claimed.**

## 1. Objective, scope, and checked antecedents

Objective: control influence of bounded degree-three observables on arbitrary independent product spaces without a bounded cubic vertex cover, independent blocks, or a degree/atom-size penalty. The sharply identified missing step in the repository is the 3-partite link-energy inequality `LE(C)` (`research/new-moon/spectral-observability/homogeneous-cubic-v8/TRIPARTITE_LINK_OPERATOR.md`, merged PR #349), not the previously proved quadratic theorem.

Source constraints: (i) a Hadamard cubic has `n^2` interlocking supports, unbounded pair-codegrees and minimum cover `n`, while `V=1/n`, `M=1/n^2` and `||f||∞=1` (`HADAMARD_CUBIC_LINKS.md`); (ii) edge weights and matching budgets alone cannot imply a small covering decomposition (`PROOF_ATTACK.md`); (iii) Turturean's theorem is all-degree on the uniform Boolean cube with exponent 5/2 (arXiv:2611.09773), not this target. Older product-space reverse-moment, hypercontractive, and Banach-cotype techniques may contain pieces of the proof below. No global originality claim.

### 3-partite representation

Let independent coordinates on arbitrary probability spaces be partitioned into three **finite** disjoint index sets `A,B,C`. Let `f` be a bounded, **pure homogeneous 3-partite Hoeffding-degree-three** real observable with `|f|<=B0`, every nonzero support meeting each block exactly once. Write

`f = sum_{a in A} q_a(X_a;X_B,X_C)`

and let `H_a=L²_0(mu_a)` and `Q_a(X_B,X_C)=q_a(·;X_B,X_C) in H_a`. Its exact normalized energy is

`V = sum_a v_a`, where `v_a = E_BC ||Q_a||²_Ha = I_a(f)`.

Let `M=max_i I_i(f)`, so `0 <= v_a <= M`. Independent centered A fibers and global boundedness imply the **pointwise aggregate link constraint**

`sum_a ||Q_a(x_B,x_C)||_Ha <= B0`  for almost every `(x_B,x_C)`.

Reason: at fixed `(x_B,x_C)`, the A fiber sum has essential range equal to the sum of the individual fiber ranges, and the sum range is at most `2B0`; each centered fiber's L² norm is at most half its range (Popoviciu). This crucially groups all overlapping `B×C` interactions *before* taking absolute values.

## 2. Proved conditional aggregate-link overlap lemma

**Proposition (moment-regular links, no overlap restriction).** For each `a` with `v_a>0`, define the rowwise aggregate kurtosis

`kappa_a = E_BC ||Q_a||⁴_Ha / v_a² >= 1`.

For every threshold `K >= 1`, put

`W_spike(K) = sum_{a : kappa_a>K} v_a`.

Then

`boxed: V <= sqrt(K) B0 sqrt(M) + W_spike(K).`   (OL)

In particular, if `sup_a kappa_a <= K`, then

`boxed: V² <= K B0² M`.

An **unconditional, sharper data-dependent invariant** is also available. When `V>0`, define the energy-weighted inverse-kurtosis average

`Lambda(f) = (1/V) sum_{a:v_a>0} v_a / sqrt(kappa_a)`.

Then

`boxed: V Lambda(f) <= B0 sqrt(M),`  equivalently  `V² <= B0² M / Lambda(f)²`.  (OL*)

Indeed, `sum_a v_a/sqrt(kappa_a) <= sqrt(M) sum_a sqrt(v_a)/sqrt(kappa_a) <= sqrt(M)B0` by the same interpolation. Uniform kurtosis `kappa_a<=K` gives `Lambda>=1/sqrt(K)`. This invariant is **not** an absolute constant: the rare-address stress test below has `Lambda -> 0`.

This has **no dependence on the number of A/B/C coordinates, contrast dimension, alphabet masses, pair-codegree, maximum hypergraph degree, or number of overlapping supports**. The condition is on the fourth moment of each *aggregate link*, not on its individual cubic coefficients.

**Proof.** For `Z_a=||Q_a||>=0`, Hölder interpolation yields

`(E Z_a²)^(3/2) <= (E Z_a) (E Z_a⁴)^(1/2)`.

If `kappa_a<=K`, then `E Z_a >= sqrt(v_a/K)`. Hence, using the pointwise aggregate constraint,

`sum_{a: kappa_a<=K} sqrt(v_a) <= sqrt(K) sum_a E Z_a <= sqrt(K) B0`.

Since every `v_a<=M`, the regular energy obeys

`sum_regular v_a <= sqrt(M) sum_regular sqrt(v_a) <= sqrt(K) B0 sqrt(M)`.

Add `W_spike(K)` exactly. No independence is needed *between* the B/C links themselves. This completes the proof. □

### Why this is an overlap mechanism rather than edgewise matching

Individual `B-C` links can have unbounded total `ell_1` coefficient amplitude. The lemma first forms the full quadratic field `Q_a=sum_{b,c}f_{abc}`, preserving signed cancellation *inside each overlapping row*. It then replaces the impossible edgewise matching estimate by a reverse-moment inequality for each aggregate row. This certifies dense-overlap families for which the classical matching budget fails.

The mathematics of Hölder interpolation is standard; the proposed research contribution is this operator, criterion and stress-tested placement within the cubic obstruction graph. Novelty awaits a dated prior-art audit.

## 3. Independent exact stress tests

A companion Python 3 standard-library script independently computes exact rational kurtoses and checks `(OL)` on:

- **Hadamard interlocking cubic family**, `n=4,16,64,256`: each link row has `v_a=1/n²`, `kappa_a=3-2/n`, while `V=1/n`, `M=1/n²`, `B0=1`. Hence the moment-regular overlap theorem applies to a connected, densely interlocking example with `n²` cubic supports, pair-codegree `n` and cover size `n`. It gives `V²<= (3-2/n)B0² M`; the actual source family has the sharper equality `V²=B0² M`.
- **Rare categorical address links**, `m=2,3,5,10,25`: output row indexed by `(a,b)` and `Q_ab(x,y)=(1_{x=a}-1/m)(1_{y=b}-1/m)`, with `B0=4(1-1/m)²`, `V=M=(1-1/m)²`, and `kappa_ab=[((1-1/m)^3+(1/m)^3)/( (1/m)(1-1/m) )]^2 ~ m²`. Thus no universal `K` is available. This is the exact *large-atom / spike-tail obstruction*; the full influence inequality remains true because the two categorical input coordinates each have influence `V`.
- **120 random densely overlapping signed 3-partite fair-sign cubics**, exact coefficients and full truth-table `B0`, row moments, and all coordinate influences, for all thresholds `K=1,2,3,5,9,81`. All arithmetic passed.
- **1,600 skew-alphabet link searches**, 2 fair-sign A fibers, 2 binary B coordinates and 2 binary C coordinates with biases from `{1/2,1/3,1/8,1/32}`; maximum observed squared ratio `[W_spike(3)/(B0 sqrt(M))]² = 45369/95000`, with its six influences rederived independently from a 64-state conditional-expectation enumeration. This is a falsification search, not a lower bound on any universal theorem constant.

The tests certify only enumerated arithmetic; the universal conditional proposition is proved above by Hölder, not by sampling.

## 4. Remaining missing lemma and falsification target

**Explicit open gate (spike-tail absorption):** Find absolute `K0,C0` such that for *every* bounded pure 3-partite cubic, the high-kurtosis aggregate rows satisfy

`W_spike(K0) <= C0 B0 sqrt(M)`.

Combined with (OL), this proves the previously open `LE(C)` with `C = sqrt(K0)+C0`. Unlike the regular-link part, the spike-tail assertion is **unproved**, and is essentially as difficult as the original unrestricted cubic problem. Do not describe this rearrangement as a solution. It must use **B/C coordinate influence and overlap of concentrated row events**, not merely `v_a` and `kappa_a` separately.

Suggested decisive experiment: build the smallest skew finite product with 2–3 A fibers and at least two B and C coordinates, tune rare-atom probabilities by rational grid and optimize `W_spike(K)/(B0 sqrt(M))` for fixed `K` (start `K=3`). Independently verify any witness by exact conditional expectations and direct fourth moments; compare against Hadamard and categorical addresses. A diverging ratio would refute this candidate and force a more sophisticated, scale-dependent moment decomposition. No finite success is proof.

## 5. Gate classification and handoff

- `PROVED` (self-contained author-side): conditional overlap inequality (OL), independently replayable finite formulas.
- `EXACT TESTED`: Hadamard `n=4,16,64,256`; rare categorical address `m=2,3,5,10,25`; 120 random complete small cubic models.
- `OPEN`: high-kurtosis spike-tail absorption; unrestricted LE(C); full exponent-two arbitrary-alphabet cubic influence.
- `NOT ESTABLISHED`: worldwide priority, external independent referee review, Lean kernel certificate, publication authorization.

**Discovery path:** full 3-partite cubic → aggregate Hilbert link fields → pointwise `ell_1(H)` constraint → moment-regular overlap operator → exact dense-overlap witness → spike-tail barrier. 

**Research stop rule:** do not keep optimizing constants in (OL). Move directly to the tail bound; after one directed 2–3–3-skew search and one independent replay, if unsuccessful switch to conditional-event overlap / link-covariance machinery.
