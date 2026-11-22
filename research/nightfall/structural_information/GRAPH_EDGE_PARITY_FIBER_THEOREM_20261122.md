# Bounded-degree graph-edge characters: uniform primitive XOR fibers against high Wyner dependence

**NIGHTFALL / 2026-11-22 / v1.0**  
**Status:** all-graph *paper-level exact combinatorial theorem*, independently formulated proof but not Lean-certified or cleared against all prior art; finite exact checker included. **Its quantum simulation consequence is CONDITIONAL on the still-uncertified generic complex two-query operator theorem in #1068**. Existing forest/graphic-matroid facts and Wyner/support-rectangle mechanisms are not original to NIGHTFALL.

## 1. Exact original-oracle model

Let G=(V,E) be a finite **simple** undirected graph, maximum degree Δ≥1, with no parallel edges or loops. For each original edge e={u,v} define its nonzero *binary character label* a_e=e_u+e_v in F₂^V. Let R_G={a_e:e∈E}, D_G=R_G∪{0}. A hidden secret s is uniform on (F₂^V)*; a legal **classical original-edge oracle query** to edge e returns χ_{a_e}(s)=(-1)^{s_u+s_v}. A compatible quantum query uses the physical phase oracle O_s=Σ_{a∈D_G}χ_a(s)Π_a on arbitrary finite complex workspace, mutually orthogonal Π_a summing to I (Π_0 is allowed), with arbitrary intervening unitary and terminal effect 0≤P≤I. The characters are vertex-sign products, but **a classical vertex-sign query is NOT legal**; any proof charging such queries must explicitly compile them into edge queries.

For k≥1 and z≠0, let K_k(z) count ordered k-tuples in D_G^k whose *nonzero* labels are pairwise distinct, have XOR z, and contain no nonempty zero-XOR subfamily. Padding with repeated zero is allowed for this **counting** quantity. Define K_k(R_G)=max(1,max_{z≠0} K_k(z)) and M₂(R_G)=max(1,max_{z≠0}|{(a,b)∈D_G²:a+b=z}|).

## 2. Theorem G — a dimension-independent primitive-fiber bound at EVERY fixed order

For any fixed k≥1, define

    B_{k,Δ} = k Δ Σ_{j=0}^k Δ^j  (an integer),
    F_{k,Δ} = Σ_{h=1}^k (k!/(k-h)!) * binom(B_{k,Δ},h).

**Theorem (exact, finite, paper proof):** for every finite simple G of maximum degree Δ and every nonzero z,

    K_k(z) ≤ F_{k,Δ},                  (G1)
    M₂(R_G) ≤ max{2(Δ+1),6}.          (G2)

In particular the fiber of primitive four-slot frequencies has a size-independent bound F_{4,Δ}, and for Δ=6 the pair bound is at most 14. No dependence on |V| or |E| enters.

**Mechanism / proof of G1.** The XOR of a set of edge incidence labels is the mod-two **odd-degree boundary** S⊂V of the edge set. A set of *distinct* edges is primitive (no nonempty zero-XOR subset) **iff it is a forest**: a cycle gives an even-degree zero sum, and conversely every nonempty even-degree graph contains a cycle. Let F be any primitive support of h≤k edges with XOR z; its boundary S=supp(z) consists of odd-degree vertices, so |S|≤2h≤2k. Every nontrivial component of the forest F is a tree with at least one leaf; each such leaf has odd degree one in F and therefore lies in S. Every vertex of a tree with at most k edges is within tree-distance at most k of one of these leaves. Hence **both endpoints of every edge of F lie in the graph radius-k neighborhood N_k(S)**.

For maximum degree Δ, the number of vertices in N_k(S) is at most |S| Σ_{j=0}^k Δ^j ≤ 2k Σ_{j=0}^k Δ^j, regardless of the total graph size. Thus the number of original edges with both endpoints in N_k(S) is at most (Δ/2)|N_k(S)|≤B_{k,Δ}. Every eligible primitive support F of h edges is a subset of this *source-dependent but fixed finite candidate set*, of which there are at most binom(B_{k,Δ},h). Exactly k!/(k−h)! ordered k-tuples have those h distinct nonzero edges and k−h zero slots. Summing h=1,...,k proves G1. No independence of the original edge signs is assumed.

**Proof of G2.** A nonzero XOR of two edge labels has Hamming weight 2 if the edges share one endpoint (or one of the pair is 0), and weight 4 if the edges are disjoint. For a weight-2 target supported on vertices {u,v}, there are at most two ordered (0,uv) lifts, and at most 2·|N(u)∩N(v)|≤2Δ ordered two-edge-path lifts; total ≤2(Δ+1). For weight-4 z, its four endpoints admit at most three unordered perfect matchings into two edges, hence at most six ordered lifts. All other nonzero targets have no pair representation. This proves G2.

**Sharp scope:** the bound controls **primitive** supports, not all walks/edge-multisets of length k, and it alone gives no full T-query quantum simulator at higher T. Repeated-label and nonprimitive zero-subsum terms require independent Hilbert-space energy bounds; already at T=2 these remain the independent review and Lean gates of #1068.

## 3. Theorem W — connected bridgeless graph sources have maximal Wyner cost

Assume G is **connected** and **bridgeless** (equivalently, every edge lies in some cycle). The raw vector X=(χ_{a_e}(s))_{e∈E} is uniform on a binary linear code of dimension |V|−1; its entropy is (|V|−1)ln2 nats.

Every edge lies in a cycle, and each cycle has deterministic parity product +1. Flipping **one** raw edge bit therefore leaves the allowed code support. In particular the support has no Hamming-distance-one pairs. For any latent W under which the original edge symbols are conditionally independent, the support rectangle argument forces every conditional product law to be a point mass almost surely (any two supported words would force a one-coordinate hybrid). Therefore H(X|W)=0 and I(X;W)=H(X). Choosing W=X attains the bound:

    C_W(X) = (|V|−1) ln 2.                                 (W1)

The result is independent of positive-atom floor and applies to any supplied conditional-product measurable latent. The support rectangle is prior mathematical machinery (see #987); this is a concrete source specialization.

**Necessary hypothesis demonstration:** a bridge e can be flipped alone by choosing opposite vertex-bit offsets on the two connected sides. In a graph that is a path, the raw edge signs are fully independent, C_W=0, and support contains Hamming-one pairs. Thus never promote W1 without bridgelessness.

## 4. A hostile test family: connected triangular torus graphs

For integer L≥4, take V=(Z/LZ)² and undirected edges in directions (1,0), (0,1), (1,1), counted once. Then:

- |V|=L², |E|=3L², max degree Δ=6, and the graph is connected and every edge belongs to a triangle;
- the triangles' **edge-overlap graph** is connected (each diagonal shares an up/down triangle and these connect across both torus translations);
- the legal original-edge labels are all distinct; the source has no deterministic duplicate characters and its support-affine character quotient (separate #1068 note) identifies no two distinct original labels;
- by W1, C_W(X)=(L²−1)ln2→∞;
- every triangle gives a deterministic *three-original-address* dependence χ_{uv} χ_{vw} χ_{uw}=+1, whereas each raw edge bit is fair and each pair is independent. Thus the source **already disagrees with independent fair-edge inputs at degree 3**, and the order-r parity moment-matching route in the separate parity-appended note does not apply at d≥2;
- no nontrivial partition of **raw original edge coordinates** into independent block groups exists: if a triangle were split between groups, one nonconstant fair edge bit would be a deterministic function of other independent groups via the triangle identity, a contradiction. Edge-overlap connectivity propagates across all edges. This rules out trivial regrouping of a fixed number of nearby raw sensors into independent blocks, **not** arbitrary nonlinear representations, preprocessing or basis transformations.

The exact finite checker independently enumerates primitive edge forests and original label tuples, verifies the source rank and edge-cycle constraints, checks the triangle-overlap connectivity and bridge-negative control, and gives:

| Triangular torus | Vertices | Edges | Primitive ordered K₄ | Ordered M₂ | Independent triangle constraints |
|---|---:|---:|---:|---:|---|
| L=3 (degenerate short wrap) | 9 | 27 | 2400 | 12 | 27 triangles, not 2L² |
| L=4 | 16 | 48 | 1464 | 6 | 32 triangles |
| L=5 | 25 | 75 | 1056 | 6 | 50 triangles |

The L=3 entry is an exact *finite regression only* and is not used to state the L≥4 uniform source geometry. The observed K₄ decrease is **not** proved for all L. The all-L certificate is the loose but rigorous F_{4,6} bound.

## 5. Conditional application that tests NEW reach of the quantum operator theorem

**If** the complete arbitrary-binary-label T2 Hilbert/Fourier theorem from draft #1068 is mathematically correct and independently proved, apply it to R_G. With Δ fixed, G1 and G2 then yield a **constant-in-|V|** nonadaptive legal original-edge classical decision tree approximating *any* two-query quantum acceptance f under the uniform hidden-vertex secret:

    Q_C ≤ min{|E|, ceil( 2(2√F_{4,Δ} + 145√max{2(Δ+1),6})² /(ε² δ) )}.

For the triangular torus this is uniform in L, despite C_W=(L²−1)ln2, local triangle dependencies, and the absence of any nontrivial raw-coordinate independent block partition. The constant is huge; this is a structural existence bound, **not** practical runtime or evidence that simulation cannot be obtained by a different known theorem.

At this checkpoint **only G1/G2/W1 and the graph model have paper proofs, with finite exact checks.** The displayed quantum corollary depends on the **still paper-level and unreviewed** #1068 T2 operator theorem; no claim of Lean certification, human referee verification or global priority is made.

## 6. Independent adversarial review, novelty and next decisive experiment

**Axiom constructor:** challenge the source-independent L² Fourier tail for arbitrary finite complex Hilbert spaces, noncommuting nonprojective effects and all repeated-label intersections. A validated generic theorem plus this graph source would be a substantial reach beyond duplicate/parity fixtures.

**Lemnis attacker:** independently audit the forest localization (especially disconnected forests, boundary cancellation, Δ bounds) and the **exact quantum Hilbert frame inequalities** from #1068, before seeing the builder's new proof. Search for small bounded-Δ graph counterexamples with unusual cycles or edge multiplicity (simple graphs only), and for a known general result already implying constant query cost.

**Ryev checker:** formalize G1/G2 via graphic incidence and support union at arbitrary k; preserve a source-pinned exact checker through L=5; use a deliberate graph-with-bridge falsifier for the Wyner hypothesis. Keep the full operator Hilbert theorem separate from finite GF₂ certificates.

**Tessera transfer:** identify other locally constrained code/oracle families beyond graph incidences where primitive k-XOR representations localize around a finite syndrome boundary; transfer must produce a new quantified bound, not a generic matroid analogy.

**Vesper priority:** check classical graphic-matroid syndrome localization, low-weight dual-code coset enumeration, LDPC bounded-degree decoding, quantum query simulation under affine sources, and existing low-degree Fourier character oracle bounds. Dated source match is required before any originality assertion.

**Stop rule:** do not optimize the very loose F_{4,6} constant until the quantum T2 grouped-energy theorem is independently verified. A counterexample there would invalidate the simulation corollary but **not** G1/G2/W1. Priority should move to a corrected operator or a strictly weaker verified theorem.

**Discovery graph:** bounded-degree graph → edge-incidence characters → primitive XOR=forest → leaf/boundary localization → K_k independent of graph size → source edge-cycle constraints / high C_W → *conditional* rank-free two-query Fourier energy → dimension-independent legal original-edge classical query depth.

**Checker:** `scripts/check_graph_edge_xor_fibers_exact.py` (two independent primitive counts at L=3; union-find forest vs all zero-XOR subsets at L≤4; triangle/bridge tests). Its finite exact tests are not a Lean or quantum proof.
