# Full fractional-row direct-sum coupling and the remaining real-row gate

2026-11-18 • NIGHTFALL structural research v1.0 • **Author-side mathematical theorem, exact rational replay; not a new universal exponent-two theorem, not independently refereed or novel-priority cleared.**

## Problem and source

Turturean, *A proof of the Aaronson–Ambainis conjecture* (arXiv:2611.09773v1), §9.5, asks whether for any real f on a fair Boolean cube admitting a **full pairwise fractional row** of cost at most K at every point, original fair max influence M obeys \`V²<=C K²M\` for some absolute C. His degree-to-full-row bound K=O(d² B) would imply all-degree variance exponent 2 with polynomial d^4 loss. **This remains OPEN.** We do not promote a true representation or subfamily theorem into a claim that this gate is solved.

Our previous #814 records the threshold-Gram representation and a coupled conic inequality still missing; #823 provides an exact dual row LP and invalidates the attempted singleton R replacement on biased AND.

## Theorem A: true full-row cost tensorizes EXACTLY

Let the independent coordinate space split into disjoint finite blocks A and B, each under its own positive-support original product law. Let \`f(a,b)=g(a)+h(b)\` for real arbitrary-output g,h, with no degree bound and no restriction on number or spacing of output values. For each supported point x define the actual full fractional row LP

  K_f(x) = min_{w_i>=0} sum_i w_i,
    subject to |f(x)-f(y)| <= sum_(i:x_i!=y_i) w_i
    for EVERY supported y.

Then for EVERY supported pair (a,b),

  **K_f(a,b)=K_g(a)+K_h(b).**

Proof, direction ≥: restrict any feasible row of f at (a,b) to the coordinates in A and compare only to (a',b). The restricted row is feasible for g at a. Ditto B. Since the coordinates are disjoint, total row cost >=K_g(a)+K_h(b). This works for arbitrary heterogeneous alphabets and zero-probability letters by restricting to the positive support.

Proof, direction ≤: concatenate optimal rows for g at a and h at b. Triangle inequality gives
  |g(a)+h(b)-g(a')-h(b')|
  <=|g(a)-g(a')|+|h(b)-h(b')|
  <=sum_(i in D_A) w_i^g+sum_(i in D_B) w_i^h.
Thus the concatenated row is feasible at cost K_g(a)+K_h(b).

Taking maxima across the Cartesian supported product gives

  **K(f)=K(g)+K(h).**

Under the genuine original independent law, the orthogonal variance and true-law original resampling influences satisfy

  V(f)=V(g)+V(h),
  I_i(f)=I_i(g) (i in A); I_i(f)=I_i(h) (i in B),
  M(f)=max(M(g),M(h)).

## Theorem B: coefficient-preserving real-row tensorization

For any absolute constant C>=0, if both components satisfy
  V(g)^2<=C K(g)^2 M(g),
  V(h)^2<=C K(h)^2 M(h),
then f satisfies **the SAME coefficient C**:
  V(f) <= sqrt(C) [K(g)sqrt(M(g))+K(h)sqrt(M(h))]
       <= sqrt(C) (K(g)+K(h)) sqrt(M(f)).
The result iterates over any finite disjoint family. In particular the *optimal* universal constant is the supremum over indecomposable/connected product-interaction components, not over direct sums.

When a finite independent product f has a canonical original-source Hoeffding/ANOVA decomposition \`f=E f + sum_{S≠∅} f_S\`, partition the nonzero support hypergraph into connected components. Distinct components use independent disjoint coordinate blocks. Apply Theorems A and B to obtain:

  **Any strict counterexample to \`V²<=C K² M\` has a strict counterexample in ONE connected canonical ANOVA component.**

This reduction does not require a degree bound, variance threshold, fair input laws, or a fractional-cover cap. It does not say that such a connected counterexample exists. The connected high-overlap case remains exactly the difficult frontier.

**Equality control:** f=sum_(i=1)^n X_i, Xi independent fair Bernoulli(1/2), has V=n/4, K=n, M=1/4, and \`4V²/(K²M)=1\` for every n. Therefore any sharp coefficient for the full-row conjecture is at least 1/4 under the original-law resampling convention. The direct-sum bound is sharp under this control and produces arbitrarily many output levels, avoiding any m^4 output-level loss on this structured family. This is a classical additive calculation, not a world-priority claim.

## Theorem C: exact two-threshold coupling, and its non-diagonal obstruction

Let the supported real values be \`v_0<...<v_m\`, with positive gaps \`δ_k=v_{k+1}-v_k\`. Define nested thresholds \`g_k(x)=1_{f(x)>v_k}\`; for any two supported worlds x,y put \`h_k(x,y)=|g_k(x)-g_k(y)|\`. All h_k are 0 or 1, and the nonzero ones form an interval of levels. Hence, EXACTLY,

  |f(x)-f(y)| = sum_k δ_k h_k(x,y),
  (f(x)-f(y))² = sum_{k,l} δ_k δ_l h_k(x,y)h_l(x,y).

This retains both threshold indices, rather than choosing a best single cut. For **any genuine feasible full rows** \`a^x,a^y\`, multiply their two independent same-pair constraints to get the unconditional quadratic *cross-coordinate* coupling

  **sum_{k,l} δ_k δ_l h_kh_l
    <= [sum_(i in D(x,y)) a_i^x][sum_(j in D(x,y)) a_j^y]
    =sum_(i,j in D(x,y)) a_i^x a_j^y.**

No degree, Boolean range, or input-law restriction is needed. This is a valid universal deterministic inequality, but NOT the desired max original-coordinate influence bound: the RHS couples **different** coordinates i and j. It is not sufficient for Turturean §9.5.

**Exact off-diagonal impossibility:** For f=sum_i X_i on {0,1}^n, take x=all ones and y=all zeros, with minimal feasible endpoint rows a_i^x=a_i^y=1. The squared difference is n², the total double-row energy is n², but the same-coordinate diagonal \`sum_i a_i^x a_i^y=n\`. Thus NO dimension-free pointwise inequality can replace the double sum by C times its diagonal. An all-degree solution necessarily needs a non-pointwise matching/routing/averaging operator that charges i≠j terms to genuine original-law coordinate resampling influences. Turturean's Boolean determinant routing is relevant prior machinery; a real-valued, cross-level squared-energy version remains OPEN.

**Negative cut-separability control:** For one three-letter categorical coordinate with real values -1,0,+1 and base x at 0, the genuine full row cost K_x is 1. Independent per-threshold envelope maximization costs 2: one other letter crosses the lower threshold and a different letter crosses the upper threshold. Their separate maxima cannot be simultaneously charged to one adversarial y. The correct mask-coupled row LP keeps the max over y **outside** the sum of level gaps:
  b_x(S)=max_{y:D(x,y)=S} sum_k δ_k h_k(x,y),
NOT \`sum_k δ_k max_y h_k(x,y)\`.
This confirms why #814's single-threshold m^4 shortcut must not be presumed sharp.

## Exact standalone checker and reproducibility

\`research/nightfall/flagship-influence/check_full_row_tensorization_exact.py\` independently computes TRUE product-state resampling influences from physical conditional and independent two-replica formulas, exact full fractional row costs by an enumerated PRIMAL linear program and a separately implemented DUAL packing polytope. The checker verifies 20 heterogeneous and zero-mass categorical direct sums with up to 3 coordinates, all per-state K identities and coupled real threshold moments; fair additive equality controls; and the one-coordinate three-output level-separability falsifier. Exact rational arithmetic only.

**Certification levels:** Theorems A/B/C have complete elementary author-side proofs above and exact finite regression. Their full generality is NOT yet a named integrated Lean theorem or independent non-author review. A conditional scalar Lean tensorization gate may be added, explicitly retaining its component hypotheses. The **global** real-row constant is unproved, and no \`N-UE2(6)\` or \`N-UE2(2)\` claim is certified by this PR.

## Discovery graph / next decisive operator

Turturean real full-row K gate → actual supported-pair constraints → exact row/direct-sum tensorization → connected component localization → nested two-threshold squared difference → cross-coordinate row-pair coupling → **missing routing of off-diagonal i≠j energy into original source I_i(f)** → original-product and all-degree exponent-two problem.

The next constructive proof experiment should target a **global coupled flow/kernel**, not a pointwise diagonal replacement. Pre-register: Given actual full rows, find a nonnegative source-preserving routing of the i,j row-pair terms to physical edges with total per-coordinate energy ≤ const*K²*I_i; reject any formulation which fails on additive fair n→∞, biased AND, or source-coupled selectors. Use #814's positive-semidefinite threshold Gram and #823's exact row dual as separate independent primal/dual checks. Do not label a new theorem until this routing inequality is independently proved and Lean checked.
