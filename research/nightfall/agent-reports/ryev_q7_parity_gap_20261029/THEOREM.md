# RYEV — Cubical square-syndrome gap and an all-graph necessary condition for Q7 305

**Research owner:** Devin J. Wright, NIGHTFALL. **Derivation and executable exact checks:** Ryev (GPT-6).  
**Self-directed assignment:** [#131](https://github.com/d3lefts/d3lefts/issues/131); **primary assignment:** [#48](https://github.com/d3lefts/d3lefts/issues/48).  
**Status:** full mathematical proof below; internal exact arithmetic checks pass; external mathematical/priority review outstanding. **No 305-edge construction and no global upper-bound improvement claimed.**

## Definitions and theorem

Let Q_n be the n-dimensional binary cube. Represent an edge set G by x∈F₂^{E(Q_n)} and define its *square parity syndrome* s(x) on each coordinate square S by

s_S(x)=1+Σ_{e∈∂S}x_e  (mod 2).

Thus s_S=1 precisely when S has an **even** number of selected edges. Fix the explicit odd-square reference 1-cochain

b(v,v+e_d)=Σ_{i<d}v_i (mod 2), for v_d=0.

Every square has Σb_e=1 (mod 2), hence **s(x)=δ₁(x+b)**, the usual square coboundary over F₂.

### Theorem A — sharp universal square-syndrome gap

For each n≥4, every nonzero syndrome s(x) has exactly one of these forms:

- **Minimum:** weight n−1, and its occupied squares are precisely the n−1 squares incident to **one cube edge**.
- **Otherwise:** weight at least **2(n−2)**.

Both thresholds are attained. A single edge toggle produces n−1 squares; toggling two distinct edges belonging to one square produces 2(n−1)−2=2(n−2) squares. This is a property of *all* cube edge sets; C4-freeness is unnecessary.

### Theorem B — optimal odd-square graphs are C4-saturated

Write M_n=max{|E(H)| : every Q_n square has odd edge-count in H}. If H attains M_n, then

1. Every vertex has degree at least ceil(n/2).
2. Every absent cube edge, when inserted into H, creates a complete four-cycle.

Consequently, **every C4-free G with |G|>M_n has at least 2(n−2) even-parity squares**.

### Q7 specialization

The published *odd-square / fully frustrated* subclass extremal result is M_7=304; see Minamo Minamoto, [C4-free hypercube constructions and subclass bounds](https://github.com/minamominamoto/c4free-hypercube), and [OEIS A245762](https://oeis.org/A245762) for the separate global 304≤ex(Q7,C4)≤308 window.

**Corollary:** Every 305-edge C4-free graph in Q7 must have **at least ten even-parity square faces**. Such a graph may still exist. This is a globally valid necessary restriction for exact 305 searches, beyond fixed seed and face-pair catalogues.

## Proof of Theorem A

All cube cochains below are F₂-valued. The cube has trivial H¹: any edge function with zero square coboundary is a vertex cut δ₀f. One elementary proof uses paths from 0 to each vertex. Swapping consecutive coordinate flips crosses a square, so zero square sums make the path integral independent of flip ordering; backtracking cancels mod 2.

**Edge-cut lemma.** For Q_d, d≥3, any nonzero edge cut has at least d edges; equality occurs only for the cut of a singleton vertex (or its complement). Any other nonzero cut has at least 2(d−1) edges. Indeed, with 1≤t=|U|≤2^{d−1}, the standard internal-edge inequality |E(U)|≤(t log₂t)/2 follows by cube-dimension induction, giving |∂U|≥t(d−log₂t). For t=1 this is d. For t≥2, concavity makes the bound at least min{2(d−1),2^{d−1}}=2(d−1)>d.

**Base n=4.** Slice Q₄ into two Q₃ faces. Write a syndrome as three disjoint components (B₀,B₁,γ), where B₀,B₁ are square coboundaries inside the respective Q₃ faces and γ records crossing squares, identified with edges of Q₃. The cube identity gives δγ=B₀+B₁. Every nonzero square coboundary in Q₃ has even, hence at least two, occupied faces (each edge belongs to two Q₃ squares). If γ=0, B₀=B₁ and nonzero total weight is at least four. If δγ=0 but γ≠0, γ is a nonzero Q₃ cut and has at least three edges; equality requires a singleton-vertex cut and B₀=B₁=0, which is the star of a Q₄ crossing edge. If δγ≠0 and |γ|≥2, then |δγ|≥2 and total weight≥4. Finally, if γ consists of one edge, δγ is its two-face star and B₀+B₁=δγ. Either B₀ and B₁ are both nonzero, giving total weight≥5, or one is zero and the other equals δγ, giving exactly three faces, the star of that edge in the corresponding Q₃ layer. Therefore Q₄ has only edge stars at weight three and every other nonzero syndrome has weight≥four.

**Induction n−1→n, n≥5.** Slice Q_n into Q_(n−1) faces and write s=(B₀,B₁,γ) as above. B₀,B₁ are (n−1)-cube square coboundaries, γ is an edge function on Q_(n−1), and δγ=B₀+B₁. Let w denote Hamming weight.

- If γ=0, then B₀=B₁. For nonzero s, w(s)=2w(B₀)≥2(n−2).
- If γ≠0 and δγ=0, γ is a cut. By the cut lemma it is either a singleton-vertex cut of size n−1 or has size at least 2(n−2). In the first case, any nonzero B₀=B₁ only increases the weight, so weight n−1 occurs exactly with B₀=B₁=0, the star of a *crossing* cube edge.
- If δγ≠0, the induction hypothesis says w(δγ)=n−2 and δγ is an edge star, or w(δγ)≥2(n−3). In the second case γ cannot be one edge (the coboundary of one edge is an edge star). Hence w(γ)≥2 and w(s)≥w(γ)+w(δγ)≥2(n−2).
- In the first case δγ is the star of an edge e of Q_(n−1). Since H¹(Q_(n−1))=0, γ differs from {e} by an edge cut. Either γ={e}, or the cut lemma gives w(γ)≥(n−1)−1=n−2. The latter yields w(s)≥2(n−2). If γ={e}, then either both Bᵢ are nonzero, yielding w(s)≥1+2(n−2), or exactly one is zero and the other equals δγ, giving the star of an edge located in one Q_(n−1) face, of total weight n−1.

These cases cover every nonzero syndrome. Since single-edge and shared-square double-edge toggles attain both bounds, the theorem is sharp.

## Proof of Theorem B

An odd-square H has 1 or 3 selected edges on each square; thus it is automatically C4-free. Toggle every edge incident to any vertex v. Each square meets this star in 0 or 2 edges, so square oddness is preserved. The new graph has |H|+n−2deg_H(v) edges. A maximum odd-square H therefore satisfies deg_H(v)≥ceil(n/2) at every vertex.

Suppose a cube edge e=uv is absent from H and can be added without creating a complete square. In each of the n−1 coordinate squares through e, the other three edges have odd count; avoiding a newly completed square forces that count to be exactly one. Two of those three edges touch u or v; as the coordinate direction varies, they account for *all* currently selected edges incident to u or v. Consequently deg_H(u)+deg_H(v)≤n−1. This contradicts deg_H(u)+deg_H(v)≥2ceil(n/2)>n−1. Thus every absent edge is blocked by a 3-of-4 square.

Let G be C4-free with |G|>M_n. If its syndrome were zero, it would be odd-square and have at most M_n edges. If it had minimum nonzero weight n−1, Theorem A supplies an edge e such that H=G△{e} has zero syndrome. If e∉G then |H|=|G|+1>M_n; impossible. Therefore e∈G and |H|=|G|−1≤M_n, while |G|>M_n forces |G|=M_n+1 and |H|=M_n. But H is a maximum odd-square graph, and adding its missing edge e produces G, contradicting the just-proved C4-saturation. Theorem A now forces at least 2(n−2) even squares in G. QED.

## Independent exact controls and reproducibility

Run (stdlib Python): \`python3 verify_parity_gap.py\`

- Q4: all 2¹⁷=131,072 distinct 24-square syndromes; exactly 32 nonzero weight-3 words, each the six-dimensional analogue's Q4 single-edge star; next attainable weight 4 (102 words).
- Q7: independent reconstruction of 128 vertices, 448 edges and 672 squares. All 448 one-edge syndromes are distinct of weight six. All 100,128 unordered two-edge toggles have weights 10 (4,032 cases) or 12 (96,096).
- Construct an odd-square Q7 graph directly using b(v,d), then improve it by exact vertex switching. Seed 1729 yields 299 edges, 53 switches, minimum degree four. For every 149 absent edges, adding that edge creates a complete 4-cycle; an intentional one-edge addition is rejected. This **does not** certify 304 optimality: the sharp value 304 is an explicitly imported, independently sourced theorem.
- 128 random vertex-switch subsets preserve every odd square exactly. No floating point or external optimizer is used. Failure of any invariant terminates with nonzero exit.

**Proof status discipline:** The general syndrome-gap and saturation proofs are analytic. Finite checker tests support the indexing, boundary cases and sharpness. The Q7 numerical corollary imports the externally stated odd-square M₇=304 result; it must be reviewed in its original source before publication as a novel research claim. The global problem 304≤f(7)≤308 is unchanged.
