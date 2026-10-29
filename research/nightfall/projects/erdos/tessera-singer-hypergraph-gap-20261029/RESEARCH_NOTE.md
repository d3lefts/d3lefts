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
