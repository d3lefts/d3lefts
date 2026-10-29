# RYEV — second cubical square-syndrome shell and the Q7 twelve-face gate

**Research owner:** Devin J. Wright / NIGHTFALL. **Derivation:** Ryev (GPT-6). **Parent:** #48, #131; **self-designed:** #140. **Status:** internally analytic proof and finite exact check; independent human proof and same-scope priority reviews OPEN. No 305-edge construction, no global C4-free upper bound.

## Statements

For edge set E in the binary hypercube Q_n, write dE for the set (mod two) of coordinate squares containing an odd number of E-edges. An odd-square graph H has exactly 1 or 3 selected edges on every square; M_n is the maximum cardinality of such a graph. For a C4-free G, its even-square syndrome T(G) is the set of squares containing 0 or 2 selected edges, namely dG plus the all-squares vector.

**A. Sharp second-weight classification.** For every n>=5, any nonzero dE has weight n-1 or weight >=2(n-2). The first class is exactly the n-1 incident squares of a single edge. **Every syndrome of weight exactly 2(n-2) equals d{e,f} for two distinct edges in one coordinate square.** Conversely such pairs attain the weight. The two-edge representative is unique: if two different pairs had the same syndrome, their symmetric difference would be a nonempty cut supported on at most four edges, impossible since every nonempty Q_n cut has >=n>=5 edges. General E representatives can differ by vertex cuts.

**B. Near-optimal stability.** For odd n>=5, if H is odd-square with |H|=M_n-1, it cannot have two missing edges belonging to one square such that adding either one individually preserves C4-freeness.

**C. Global necessary bound.** For odd n>=5, every C4-free graph with M_n+1 edges has **at least 2n-2 even squares**. Using the published odd-square optimum M_7=304, a hypothetical **305-edge C4-free graph in Q7 must contain >=12 even squares**, strictly improving our earlier >=10 gate in PR #134. This is a search obstruction, not an upper bound on ex(Q7,C4).

## Proof A: cut lemma and cubical induction

**Cut lemma.** For d>=4, every nonzero vertex cut delta(U) in Q_d has size d (isolation of one vertex or its complement) or at least 2(d-1). Equality in the latter case isolates precisely two adjacent vertices or their complement. Indeed split Q_d into two Q_(d-1) halves: the cut size equals the two within-half cut sizes plus |U_0 symmetric-difference U_1|. Both half cuts nonzero give >=2(d-1), equality only for equal singleton halves. Exactly one nonzero half-cut gives d for a singleton. A co-singleton half-set paired with an empty half has 2^(d-1)-1 crossing edges, exceeding 2d-2. Every remaining nontrivial, non-co-singleton half-set has at least two vertices and at least two missing vertices, so by induction its internal cut is >=2(d-2) and it contributes at least two crossing edges; equality gives an adjacent pair in one half. Two trivial, unequal half-sets give 2^(d-1)>2d-2. The d=4 base follows directly from Q3 cuts. The independent checker exhausts Q4's 32768 vertex cuts modulo complement and finds exactly 16 singleton cuts of weight4, 32 adjacent-pair cuts of weight6, and none at weight5.

An edge set has zero square syndrome exactly when it is a cut. Assign one vertex a potential and propagate through chosen edges. The parity on every elementary coordinate square makes the potential independent of the choice of path, since every cube path can be reduced by cancelling backtracks and commuting coordinate moves.

**Syndrome splitting.** Split Q_n along one coordinate, with d=n-1, two horizontal edge sets A_0,A_1 and vertical edges indexed by a vertex set B of Q_d. Put X=A_0 symmetric-difference A_1 symmetric-difference delta(B). Its syndrome decomposes across three disjoint face families as

    dE = ( dA_0 , dA_1 , X ),        dX = dA_0 symmetric-difference dA_1.

**Base n=4.** Every Q3 edge belongs to two squares, so nonzero Q3 syndromes have weight at least two. Q4 syndromes with both horizontal components zero are Q3 cuts in the vertical component, giving weight at least three. With exactly one nonzero horizontal component the total weight is at least three; with both nonzero, at least four. At weight three, the only possibilities are a singleton vertical cut or a horizontal Q3 two-square edge star plus its uniquely matching one-edge vertical component. Both represent a single Q4 edge. Thus Q4 has minimum weight three and precisely the 32 edge stars. At weight four, this classification already fails: Q4 has 102 such syndromes, six beyond the 96 cofacial two-edge classes; a concrete exceptional representative is the four parallel edges (0,1),(2,3),(4,5),(6,7).

**Induction n>=5.** Assume the gap and unique minimum edge-star representation in dimension d=n-1>=4. Let a=|dA_0|, b=|dA_1|, c=|X| and consider a+b+c.

- If a=b=0, X is a cut. Its nonzero weight is d (one vertical edge star) or >=2d-2; equality 2d-2 gives the syndrome of two cofacial vertical edges at adjacent Q_d vertices.
- If a,b>0, both are >=d-1. Equality in the second-shell bound 2d-2 forces a=b=d-1 and c=0. Because dX=0, the two horizontal minimum syndromes coincide; they are the same single edge in parallel halves, hence a cofacial pair.
- If a>0,b=0, then c>0. When a=d-1, some Q_d edge e has dA_0=d{e} and X={e} symmetric-difference a cut. This gives c=1 (a single horizontal edge star) or c>=d-1 by the cut lemma. Equality c=d-1 means a singleton cut at an endpoint of e, hence the syndrome of that horizontal edge and an incident vertical edge.
- In the remaining case a>=2(d-2), a one-edge X would give a=d-1, contradiction. Thus c>=2, and total >=2d-2. At equality c=2, and dX=dA_0 has weight 2(d-2), so the two edges of X share one Q_d square. Those two cofacial horizontal edges represent the full syndrome.

This also excludes all syndrome weights strictly between d and 2d-2 and proves the equality classification. Two edge stars share at most one square; cofacial pairs share exactly one, yielding 2(n-1)-2=2(n-2). QED.

## Proof B: saturation and two-safe-edge contradiction

For odd n, switching all n edges incident to a vertex preserves every square parity and changes |H| by n-2deg_H(v). Since |H|=M_n-1, maximality implies deg_H(v)>=(n-1)/2 for every vertex.

If e=uv is absent and C4-safe, every one of its n-1 squares contains exactly one H-edge. On each such square at most one selected edge is incident to u or v, so deg_H(u)+deg_H(v)<=n-1. Therefore both endpoints have degree exactly (n-1)/2 and **the opposite edge on every e-square is absent**.

Every maximum odd-square graph K (size M_n) is C4-saturated: vertex switching forces all degrees >=(n+1)/2, yet a safe missing edge would force endpoint-degree sum <=n-1, contradicting the lower bound n+1.

Suppose H had two cofacial safe missing edges e,f. If they were adjacent, their individual safe-edge endpoint equalities would force both other edges of their shared square absent, leaving an even zero-edge square, impossible.

If they were opposite, their shared square (with e,f absent) has exactly one selected perpendicular edge g. Switch the vertex at the endpoint of e incident to g. Its degree is (n-1)/2, so the switch increases |H| to M_n; it toggles e and g, keeping the common square's edge count at one. Every other square incident to f is unchanged (only the shared square contains this vertex). Hence f remains safe in a maximum odd-square graph, contradicting saturation. QED.

## Proof C: the 12-square gate

Suppose G is C4-free and has |G|=M_n+1. If its even-square syndrome is empty, G is odd-square and contradicts M_n.

If T(G)=d{e}, then H=G symmetric-difference {e} is odd-square and must satisfy |H|<=M_n. Therefore e belongs to G and |H|=M_n. Adding the safe missing edge e to the optimum odd-square H would create G, contradicting saturation.

If T(G)=d{e,f} for two cofacial edges, then H=G symmetric-difference {e,f} is odd-square. Its size bound forces both e,f to belong to G, and |H|=M_n-1. Because H is a subgraph of G, both missing e,f are individually C4-safe for H. This contradicts Proof B.

By Proof A, the even-square syndrome therefore weighs **strictly more than 2(n-2)**. As n is odd, each edge contributes to an even number n-1 of coordinate squares; the all-squares set has even cardinality. Thus syndrome weight is even, at least 2n-2. For n=7 this gives **12**. QED.

## Reproduction, provenance, and status

Run Python 3 (standard library): python3 research/nightfall/agent-reports/ryev_q7_second_shell_20261029/verify_second_shell.py

The fresh checker reconstructs and exhausts all 131072 Q4 syndromes, classifies six weight4 exceptions, enumerates all Q4 vertex cuts, constructs Q7's 128 vertices, 448 edges, and 672 squares **by two different algorithms**, verifies all 4032 distinct cofacial pair syndromes (2688 adjacent, 1344 opposite), every Q7 edge pair (100128 total), and 128 vertex-star gauge switches. A fully exhaustive Q3 odd-square-control family (128 graphs) independently tests maximum saturation and the near-max cofacial safe-pair exclusion. The analytic induction—not finite Q7 enumeration—establishes general completeness.

**Imported external premise:** Minamo Minamoto's revised 2026 report, C4-Free Subgraphs of the Hypercubes Q6, Q7, and Q8: Odd Squares, Fully Frustrated Models, and Computational Structure, at https://github.com/minamominamoto/c4free-hypercube ; its odd-square M_7=304 is established from earlier fully frustrated physics results. The present cut/syndrome mechanisms may overlap existing coding-theoretic prior art. No first-ever novelty claim, external referee acceptance, solver UNSAT certificate, website promotion, or 305 witness is asserted. Request Lemnis proof attack, Axiom separate parity derivation, Vesper priority audit and final owner publication gate.
