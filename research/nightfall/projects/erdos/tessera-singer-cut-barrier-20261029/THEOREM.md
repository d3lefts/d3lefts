# TESSERA #95 — cut-uniform Singer source-reuse deletion obstruction

**29 October 2026. Internally proved exact theorem; human review and dated originality assessment OPEN.** This is a source-coupled, growing-prefix no-go theorem. It does **not** settle Erdős #44/#329, nor rule out choosing a different Singer source for each prescribed prefix. The full independent archive contains this theorem, executable replay, and SHA-256 manifest.

## Theorem

Let D be a modular Sidon set of K distinct residues modulo odd v≥31 (all nonzero ordered differences have at most one representation). Set a=(v−1)/2−4. Some cyclic rotation D* has P=D*∩[0,a−1] of size m≥Ka/v, by averaging over all rotations. The **integer Sidon prefix** A={1+d : d∈P} is consequently contained in [1,a].

For EVERY cyclic cut c∈Z/v and EVERY translation T>max(A), let Q_c=(D*−c) mod v. If R⊆Q_c and A∪(T+(Q_c\R)) is Sidon, then

    |R| ≥ m−2 ≥ Ka/v−2.

In fact, the complete AB/AB collision graph on the K new source marks is **exactly the disjoint union of two cliques**, corresponding to P_−={d∈P:d<c}, P_+={d∈P:d≥c}, plus K−m isolated vertices. Its deletion-cover optimum is

    τ(c) = max(0,|P_−|−1)+max(0,|P_+|−1)∈{m−2,m−1}

when m≥2, with minimum m−2 achieved at splitting cuts. The disjoint-edge matching number of this complete AB/AB subsystem is floor(|P_−|/2)+floor(|P_+|/2); its fractional-cover optimum is half the sum of clique sizes ≥2. Thus the subsystem exhibits an integral-versus-fractional cover ratio approaching **2**, uniformly as m grows. This is a statement about the AB/AB subsystem; full repairs can also require deleting marks for AB/BB collisions.

**Singer specialization.** For every prime power q≥5, Singer's cyclic perfect difference sets have v=q²+q+1, K=q+1. The old prefixes above have m≥(1/2−o(1))q, and every cut of the SAME source forces ≥(1/2−o(1))q new-mark deletions before Sidon compatibility. The family is genuine for arbitrarily large q. It disproves any proposed **fixed-source, rotation-only** universal grafting guarantee with o(q) deletions for all growing Sidon prefixes. It leaves source-adaptive construction and all fixed-prefix questions open.

## Complete symbolic proof

(1) Average the occupancy of the length-a cyclic window over v shifts: E|D_shift∩[0,a−1]|=Ka/v. Select an above-average shift. Modularity of D implies A=1+P is Sidon as an ordinary integer set.

(2) Fix any c, T>max(A). Each d∈P has its matching new coordinate x_d=(d−c) mod v. Values d<c wrap by adding v, while d≥c stay unwrapped; thus within either class x_e−x_d=e−d. For distinct d,e in the same class:

    (1+d)+(T+x_e)=(1+e)+(T+x_d).

The two unordered representations are distinct because all translated new marks exceed all old marks. To eliminate these complete pairwise constraints, a deletion-only repair must remove all but at most one matched new mark from each class, proving ≥m−2 losses.

(3) To see these are **every** AB/AB collision: If (1+d)+(T+x_f)=(1+e)+(T+x_g) with old d,e∈P distinct, then x_g−x_f≡d−e (mod v). Since every nonzero modular difference of D is represented by at most one ordered source pair, (x_g,x_f) must be exactly the pair (x_d,x_e). Its ordinary difference equals d−e precisely when d,e have the same wrapping status. Hence the complete AB/AB conflict graph is two cliques plus isolated source marks. Vertex covers, matchings and fractional optima follow from the complete-graph formulas.

(4) Take h=1 and T=v−1 to place this instance inside the exact **near-end translation conditions** of the previously studied fixed-prefix lemma: v−h>2max(A), h<v/4, 2(h+max(A)+1)<v and T∈[v−h,v−ceil(h/2)]. They follow directly from max(A)≤a=(v−1)/2−4. In the Singer family m≥Ka/v=(1/2−O(1/v))(q+1), giving the asymptotic lower bound.

## Independent exact audit

Run:

    python3 research/nightfall/projects/erdos/tessera-singer-cut-barrier-20261029/verify.py

Python standard library only. The checker independently reconstructs two genuine Singer sources, audits ALL nonzero modular differences, computes the most populous short arc with a two-pointer method, builds a direct integer AB-sum oracle for 5 representative cuts, and checks the exact deletion formula for **every** possible cyclic cut. A corrupted source is rejected.

| Singer field | v | K | Prescribed prefix m | Max A | Min deletions (all cuts) | Source rotation |
|---|---:|---:|---:|---:|---:|---:|
| q=25 | 651 | 26 | 17 | 321 | **15** | 217 |
| q=1009 | 1,019,091 | 1,010 | 536 | 508,113 | **534** | 851,585 |

For q=1009, **508,112 cuts** give the exact AB/AB minimum 534; the other **510,979** give minimum 535. The 1,019,091-cut sweep has an independent direct-sum check at sample cuts and exact full modular-difference validation. q=1009 prefix SHA-256 `84aa198fedbcbc6e046c79b55a46f6205f059fff8469dca30c6475740ccc9027`; q=25 `c55a550b33e6e881158fefbdeb4509f001ccc3fccebf90921bfe375fbe814cbf`.

## Priority and quantifiers

This construction concerns **∀ Singer q, ∃ a specially coupled A_q for a fixed Singer D_q, ∀ cyclic rotations and allowed translations**. It makes no universal claim across different Singer difference sets, affine multipliers, Bose–Chowla sources, non-Singer Sidon families, arbitrary old fixed A, or iterative infinite constructions. The source A_q changes with q and its cardinality grows. Any proof of #44 may choose the source in response to A; such strategies survive.

Classical prior art: Singer cyclic difference sets; elementary Sidon/difference uniqueness and complete-graph covers. A separate 25 July 2026 published attempt describes a different, stronger **fixed-size-prefix** sparse-repair obstruction: https://www.erdosproblemaday.com/day/44-sidon-density-completion. This scope is growing-prefix and *all cyclic cuts* of a fixed source. Worldwide novelty is **unestablished**. Scientific review and same-scope literature search required before original-findings promotion.

Research: [TESSERA standing #95](https://github.com/d3lefts/d3lefts/issues/95) · [previous odd-cycle #102](https://github.com/d3lefts/d3lefts/pull/102) · [Erdős #44](https://www.erdosproblems.com/44) · [Erdős #329](https://www.erdosproblems.com/329).

**Next operator:** construct a recursively closed, SOURCE-ADAPTIVE Singer family with provably small total old/new collision losses, or derive a lower bound that holds across all algebraically equivalent Singer source choices. The present result rules out only a rigid source-reuse strategy.
