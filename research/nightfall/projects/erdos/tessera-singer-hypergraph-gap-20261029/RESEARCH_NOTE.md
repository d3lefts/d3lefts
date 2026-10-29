# TESSERA — Singer repair-hypergraph matching/cover counterexample
**2026-10-29 · Self-designed research Issue #100 · Standing Issue #95**

**Status:** exact finite obstruction with proof and an independent brute-force checker. This is a structural caution, **not** an infinite Sidon improvement, a solution of Erdős #44/#329, or a claimed globally novel graph theorem. The classical general possibility that hypergraph matching and covering differ is established prior art.

## Theorem

For genuine Singer-parameter cyclic perfect difference sets, with an integer Sidon prefix and a legal near-boundary translation of the form used in Axiom/Ryev/Tessera Sidon grafting proofs, the collision-repair hypergraph **need not satisfy matching number ν = minimum vertex-cover number τ**. In fact, the following exact example has **ν=2, τ=3**.

Take v=31, D={0,1,3,8,12,18} (all 30 nonzero modular differences appear exactly once), old Sidon prefix A={1,2,4}, cyclic cut c=8, and translation T=24. Then

- rotated source Q=sort((D−8) mod 31)={0,4,10,23,24,26};
- translated new marks B={24,28,34,47,48,50};
- window parameter h=7, maximum old mark N=4 and L=h+N+1=12;
- legal boundary conditions **h<31/4**, **31−h=24>2N=8**, **2L=24<31** and **24≤T≤27**.

The **complete** list of repeated unordered integer pair sums in A∪B is:

| Sum | Repeated representations |
| ---: | --- |
| 48 | 1+47 = 24+24 |
| 49 | 1+48 = 2+47 |
| 51 | 1+50 = 4+47 |
| 52 | 2+50 = 4+48 = 24+28 |

Index the six new marks B as 0,…,5. To eliminate every repeated sum by deleting new marks while preserving A, we must hit **each** of the six collision supports:

`{0,3}, {3,4}, {3,5}, {4,5}, {0,1,4}, {0,1,5}`.

### Human-checkable proof

The three supports {3,4}, {3,5}, {4,5} form a triangle: any two-point cover must select two among vertices 3,4,5. Selecting {3,4}, {3,5}, {4,5} leaves respectively {0,1,5}, {0,1,4}, {0,3} uncovered. Thus **τ≥3**. Deleting vertices {0,3,4} covers all six supports; remaining marks {1,2,4,28,34,50} form a Sidon set, hence **τ=3**.

Hyperedges {0,3} and {4,5} are disjoint, giving **ν≥2**. A disjoint triple of hyperedges would require three two-element edges on six vertices. The only two-element supports are {0,3}, {3,4}, {3,5}, {4,5}; no three are pairwise disjoint. Hence **ν=2**.

This is an explicit **3/2 packing-cover gap** from a real Singer repair template. An independent second example, at v=57, q=7, D={0,1,3,13,32,36,43,52}, A={1,6}, cut=1, T=43, h=14, satisfies the same exact window assumptions and has collision supports {0,5}, {6,7}, {1,2,6}, {1,2,7} with ν=2, τ=3.

## Reproduction and acceptance

`python3 research/nightfall/projects/erdos/tessera-singer-hypergraph-gap-20261029/verify_integrality.py`

The standard-library checker independently enumerates **all nonzero modular differences** for both sources, every unordered pair sum in the unpruned source, all collision supports, every possible candidate-mark deletion subset up through cover size 3, and every disjoint hyperedge subfamily. Every zero-, one- and two-deletion repaired candidate is separately rejected by a *fresh sum table*. It accepts the 3-deletion Sidon sets and records the complete sum representations.

**Scientific scope and consequence:** The exact equality ν=τ=40 in Tessera's q=1009 975-mark certificate, PR #82, remains a valid **template-specific** dual certificate. The observed 3/2 gap makes it mathematically invalid to extrapolate ν=τ to arbitrary Singer templates, even in the same near-boundary geometry. This local obstruction alone cannot imply any asymptotic lower bound on τ/q, so standing #95's uniform-in-scale question remains open. A next-step research goal is to test whether such motifs persist inside genuine unbounded-q Singer sources, quantifying all prefix and window parameters.

Prior art: Singer's classical perfect difference-set theorem; elementary general hypergraph matching and vertex-cover nonintegrality. Problem status: [Erdős #44](https://www.erdosproblems.com/44), [#329](https://www.erdosproblems.com/329); research assignments [#95](https://github.com/d3lefts/d3lefts/issues/95), [#100](https://github.com/d3lefts/d3lefts/issues/100). **External theorem priority and non-author review have not been completed.**


## Uniform-in-field-size strengthening: an odd collision cycle for unbounded Singer q

**Proposition (internally proved).** For every integer t≥1 with 3 not dividing t, let q=5^t, v=q²+q+1 and s=v/31. There is a cyclic Singer (v,q+1,1) perfect difference set D and an admissible prefix/cut/translation instance with **A={s,2s,4s}**, cut=8s, h=7s, T=24s whose complete repair-incidence matrix contains a 3×3 submatrix with determinant 2. Consequently **the repair-incidence matrix is not totally unimodular for arbitrarily large genuine Singer sources**.

**Algebraic proof.** Identify the Singer group G with the quotient F_(q³)^× / F_q^×, a cyclic group of order v. Set E=F_(5³)⊂F_(q³). Since gcd(t,3)=1, E∩F_q=F_5, so the image H of E^× in G has order (5³−1)/(5−1)=31. Under G≅Z/v, H is the subgroup s(Z/31). Choose a Singer difference set D from the trace-zero plane Tr_(F_(q³)/F_q)(x)=0. For x∈E, its trace is x+x^(5^t)+x^(5^(2t))=x+x^5+x^25, since t and 2t modulo 3 permute 1 and 2. Thus **D∩H** is precisely the order-5 Singer difference set from the trace-zero projective subplane PG(2,5).

A suitable generator/translation of H identifies this intersection with s*{0,1,3,8,12,18}: for example in F_125=F_5[x]/(x³+x+1), the primitive element 4x+x² has trace-zero exponent set {3,4,7,13,15,20}; multiplication by 8 and translation by 7 modulo 31 yield {0,1,3,8,12,18}. The automorphism on H extends to a unit multiplier on cyclic G (reduction (Z/v)^×→(Z/31)^× is surjective). Translation by a member of H finishes the normalization, preserving the full Singer difference-set property.

Apply the cut 8s. The rotated full source necessarily contains the six marks s*{0,4,10,23,24,26}. With old prefix A={s,2s,4s} and new translation T=24s, the three collision equations

- s+48s = 2s+47s,
- s+50s = 4s+47s,
- 2s+50s = 4s+48s

produce precisely the three 2-vertex hyperedges joining the source marks at 23s, 24s and 26s in a triangle. Take those three hyperedge rows and three vertex columns: their incidence matrix, in a suitable ordering, is [[1,1,0],[0,1,1],[1,0,1]], determinant **2**. This is a submatrix of the **full** (q+1)-source repair matrix: extra source marks cannot erase these exact equalities.

The near-boundary conditions hold for every s≥1: h=7s<31s/4, v−h=24s>8s=2max(A), L=h+max(A)+1=11s+1 has 2L=22s+2<31s=v, and T=v−h belongs to [v−h,v−ceil(h/2)]. Therefore the construction is in the exact parameter regime used by the fixed-prefix boundary lemma, at unbounded q.

**Limitation:** Non-total-unimodularity does *not* prove that the optimum integral vertex cover exceeds the optimum fractional cover, nor that ν<τ for the **whole** large-q hypergraph. It rules out an automatic TU/network-matrix proof for this entire Singer-template regime. The preserved prefix here changes with q; this does not produce a fixed-prefix asymptotic lower bound.

**Independent q=25 field check:** `python3 verify_q25_subfield.py`. In F_(5^6)=F_5[x]/(x^6+x²+x+1), the primitive element 1+3x generates 15,624 nonzero elements. The trace-zero Singer source for q=25 gives 26 exponents modulo v=651 with all 650 nonzero differences unique. Its order-31 subgroup intersection is {1,5,17,22,23,25}; multiplying by 11 and translating by 7 sends these residues to the small q=5 source. The full source after cut/shift gives a collision triangle on source indices (21,22,25). The direct sum checker extracts the exact 3×3 determinant **2** from the complete q=25 repair hypergraph.

**Novelty boundary:** This is a projective-subfield embedding plus an elementary odd-cycle incidence obstruction; Singer planes, traces and total-unimodularity are established concepts. Whether this exact application has prior art is unresolved. The proposition is a structural no-go for a class of *proof strategies*, not a solution of either Erdős conjecture.
