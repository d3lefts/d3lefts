# Theorem H: grid rows refute the original frame dichotomy (2026-11-19)

**Status:** Complete author-side paper argument plus an independently implemented exact finite chain replay. Not Lean-certified, independently human-refereed, or novelty-cleared. Supersedes the earlier restricted c'=1 result in GRID_CYCLE_FRAME_RIGIDITY_20261119.md, which remains archived. Does not refute frame *sufficiency*, show grid quantum advantage, or contradict Claude's balanced direct-sum theorem.

## Exact negative theorem

Let G_L=P_L×P_L be the L×L vertex grid, with rows R_L={e_u+e_v:uv edge of G_L} in F₂^(L²). They span the even-parity subspace of dimension L²−1. To meet any ambient-full-span hypothesis, delete one vertex coordinate: the rows then span F₂^(L²−1), retain Hamming weight at most two, and have identical linear dependencies.

For every r≥0, N_r(R_L)≤2r: each sum of ≤r edges has weight ≤2r, and every k-dimensional binary subspace contains a vector of weight at least k (set all coordinates in a full-rank k-column information set to one).

**Theorem H.** Every (c,c',h)-frame B for these rows with h≥4c satisfies, writing q=cc' and N=L−1,

    2L(L−1)(q+1)² ≥ 16 D_N,
    D_N = Σ_{t=0}^{floor((N−1)/2)} (N−2t)² ≥ N³/6,

and hence

    cc' + 1 ≥ (2/√3) (L−1)/√L.

The conclusion holds for arbitrary B consisting of short original-row sums (c'>1 permitted). There is **no** additional assumption h≥cc'+1.

**Conjecture E is false under its existing quantifiers.** Its source smoothing scale is h(Q)=2k_phi max(2Q,D_product) with integer k_phi≥1. Therefore h(2cT)≥8k_phi cT≥4c whenever T≥1. Fix T=1 and constant accuracy parameters. For the hypothetical universal polynomial a, set r=a(1), k=2r, independent of L. The antecedent N_r≤k holds for every grid, while Theorem H makes the promised cost cc'≤b(k,1) impossible for arbitrarily large L. No universal a,b as specified can exist.

## Complete proof

All chain spaces are over F₂. Let C0=F₂^V, C1=F₂^E, and C2=F₂^F, with |F|=(L−1)² elementary square faces. Let ∂1:C1→C0 map an edge uv to e_u+e_v; ∂2:C2→C1 maps a face to its four boundary edges. The connected rectangular grid has exact chain complex

    ∂1∂2=0,    ker ∂1 = im ∂2,    ∂2 injective.

Proof: rank ∂1=L²−1. The (L−1)² square boundaries are independent by peeling an outermost occupied square, and their number equals |E|−rank ∂1, so they span the entire cycle kernel.

**Step 1 (sparse chain map).** Let β:F₂^B→C0 evaluate the frame rows. Choose forward representations to define A:C1→F₂^B, with βA=∂1 and every A column of weight ≤c. Choose reverse representations to define D:F₂^B→C1, with ∂1D=β and every D column of weight ≤c'. Put P=DA. Then

    ∂1P=∂1,     weight(Pe)≤q=cc'.

For each face f, A∂2 f has weight ≤4c and βA∂2 f=∂1∂2 f=0. The frame's h-wise independence with h≥4c forces A∂2f=0. Hence A∂2=P∂2=0. Importantly, P need **not** be idempotent and B need not be a basis.

**Step 2 (face-chain section).** For each edge e, ∂1(e+Pe)=0. Exactness and injectivity supply a unique face chain S(e) satisfying ∂2 S(e)=e+Pe. Extend S:C1→C2 linearly. Then

    ∂2 S∂2=(I+P)∂2=∂2,

so injectivity gives **S∂2=I_C2**. Each column S(e) has edge-boundary weight at most q+1.

**Step 3 (column bound by isoperimetry).** For any subset U of unit faces occupying r rows and s columns, its mod-two edge perimeter is ≥2r+2s≥4√(rs)≥4√|U|: each occupied row and column supplies two distinct boundary edges of the appropriate orientation. Thus for every edge e,

    |S(e)| ≤ (q+1)²/16.

Summing over |E|=2L(L−1) edges,

    Σ_e |S(e)| ≤ 2L(L−1)(q+1)²/16.   [UPPER]

**Step 4 (dual-flow lower bound).** Fix a face f. Consider the row z_f(e) of S (the coefficient of f in S(e)) as a selected edge set in the planar dual graph, whose vertices are all elementary faces plus the exterior. The identity S∂2=I gives, for each face g, Σ_{e in ∂2g} z_f(e)=[g=f] modulo two. Therefore its dual degree is odd at f and even at every other interior face, so it is odd at the exterior as well. The selected edges contain a path from f to the exterior, requiring at least

    d_dual(f,exterior)=1+min(i,j,L−2−i,L−2−j)

edges for face (i,j). Counting the 1s in S by rows instead of columns gives

    Σ_e |S(e)| = Σ_f |z_f| ≥ Σ_f d_dual(f,exterior)
              = D_{L−1}
              = Σ_{t=0}^{floor((L−2)/2)} (L−1−2t)².   [LOWER]

The last sum is ≥(L−1)³/6, by elementary sums of even and odd squares (or a decreasing-square Riemann lower sum). Combining [UPPER] with [LOWER] proves the stated bound. QED.

## Meaning and required audit

- **Invalidated:** the reverse Conjecture E claim that bounded N_{poly(T)} always forces a high-girth low-cost linear frame.
- **Not invalidated:** Theorems A/B/C as scoped, Claude's direct-sum balanced-block sufficiency, the product-space AA certificates, or a potential broader characterization of quantum query advantage. We have **not** constructed a grid quantum speedup.
- **Research transition:** replace globally high-girth scalar linear frames with multiscale block-symbol / gauge-aware representations or a different necessary invariant. Simply increasing the permitted reverse locality c' cannot bypass this grid obstruction.
- **Prior art:** binary cycle spaces, planar duality, lattice edge-isoperimetry and parity paths are classical. This particular quantitative frame obstruction and its application to the new Conjecture E are not yet novelty-cleared. Related sparse chain-homotopy and coding literature requires dated review.
- **Independent replay:** run python3 -I research/nightfall/structural_information/dichotomy_tests/check_grid_frame_dual_nogo.py. It tests 160 sparse reciprocal maps across grid sides 2,3,4,5,6,8,12, including 8,460 exact chain lifts, 8,460 edge-isoperimetry checks, 3,580 dual-distance checks and 160 exact quantitative bounds. Prior check_grid_cycle_rigidity.py independently tested 1,659 candidate frames and both girth-gate negative controls. These finite tests **do not** prove a universal theorem; there is no named Lean kernel certificate yet.

**Next formal gate:** independently verify all chain boundary maps and the dual-flow parity argument, then formalize the finite theorem under the pinned Lean compiler. Until independent review, preserve the status as an author-side **counterexample proof claim**, not an externally certified theorem.
