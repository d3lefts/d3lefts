# LEMNIS — Twisted-voltage girth transition in semidirect K3,3 covers

**29 October 2026 · issue #47 · self-designed finite-module classification alongside Vesper's primary assignment.**

**Stage:** Exact, internally replicated finite-dimensional mathematical construction and family theorem. Human/external review, same-scope priority, mathematical novelty, significance, and site promotion all **OPEN**. These graphs **contain C32** and therefore do not disprove Erdős–Gyárfás #64. Full theoretical status is proof-candidate until independently attacked.

## Setting and theorem

Let m=147r, r a positive integer. Let V_d = GF(2^d) additively, for d=2 or d=3, and let T be multiplication by a primitive element `t` of orders `o=3` and `o=7` respectively (minimal polynomials x²+x+1 and x³+x+1). Since o divides 147, T defines a nontrivial action of Z_m. Put G_d,m = V_d ⋊_T Z_m, with multiplication `(z,v)*(z',v')=(z+z',v+T^z v')`.

Use voltage covers of K3,3 (left vertices 0,1,2; right 3,4,5), zero labels on five spanning-tree edges, and four cotree left-to-right labels `(w,v)`:

| edge | cyclic w | d=2 auxiliary v | d=3 auxiliary v |
|:---|---:|---:|---:|
| 1→4 | 1 | 0 | 0 |
| 1→5 | 5 | 1 | 1 |
| 2→4 | 17 | 1 | 4 (=T²1) |
| 2→5 | 64 | 1 | 1 |

**Verified construction theorem:** These define connected simple cubic bipartite covers with respectively `3528r` and `7056r` vertices, girth exactly **14**, no simple 16-cycles, and simple 32-cycles. Thus their first power-of-two cycle has length 32. An explicit 14-cycle base word for d=2 is `03140524130425`; for d=3 it is `03142305132415`. The common simple 32-cycle word is `03140523041325140314031403140314`.

**More general exact finite classification:** Among all 4-tuples of auxiliary labels `(a,b,c,d)∈V_d^4`, restrict to tuples for which that fixed 32-cycle word closes. For d=2, precisely **64** of the `4^4=256` tuples close C32, and **24** of those eliminate every cyclically nonbacktracking closed length-12 word. For d=3, precisely **512** of the `8^4=4096` tuples close C32, and **224** eliminate every length-12 quotient-neutral word. Every one of these 24/224 tuples generates the entire semidirect group together with the base cyclic voltage and has girth exactly 14, no C16 and the displayed simple C32. All 24 d2 successes admit exactly six distinct neutral 14-word signature types; the 224 d3 successes split into four groups of 56 by distinct neutral 14-word signature counts 7,9,10,12. A detailed per-word census is machine-checkable in `search_girth.py`. The signature counts are of distinct linear functionals, not graph cycle counts.

## Proof operator and limits

A cyclically nonbacktracking closed walk whose oriented edge labels are `(w_i,v_i)` has group holonomy

`(sum w_i, sum T^(s_i) v_i)` where `s_i=sum_{j<i} w_j`.

For reverse edges use `(w,v)^(-1)=(-w,-T^(-w)v)` (minus equals plus in characteristic two). This is **twisted voltage**: the second group coordinate retains noncommutative prefix order, unlike untwisted/abelian homology.

1. The quotient homomorphism `G_d,m → Z_147` sends every chord to the already independently checked cyclic `(1,5,17,64)` model. Its complete integer/mod-147 rooted cyclically NB length 4,6,8,10,16 exclusion rules out *all* those lengths for every `m=147r`. In particular all simple cycles shorter than 14 except potentially 12 are absent. All graph degrees are three and bipartite by construction.
2. The six-root exact K3,3 enumeration contains 8712 cyclic NB length-12 words, with exactly 144 of cyclic voltage zero mod147. For each of the two listed assignments, all 144 have **nonzero twisted kernel holonomy**, so the full cover has no C12. For the entire 24/224 classification the linear-functionals checker rejects exactly the same 144 closure events.
3. At length 14 there are 31,752 cyclic NB words and 504 cyclic-quotient-zero words. The selected d2 case has 168 zero full-group holonomies; d3 has 84. Their explicit 14-word states are pairwise different, so girth is 14. More generally every classified successful assignment has an identity length-14 reduced word. Because all shorter cyclically reduced closed walks have been excluded, any such 14-word must lift to a simple cycle.
4. The displayed 32-word has **zero integer cyclic voltage** and zero auxiliary twisted holonomy for each selected tuple. This exact full-group closure is enforced by the classification filter for every other selected tuple. The projected 32 states in the Z_147-cover are distinct; full lifted states remain distinct for every m=147r, so each word lifts to a simple C32.
5. Connectivity: the (1,0) chord generates Z_m. Extract a nonzero kernel vector from any nonzero auxiliary chord after multiplying by cyclic powers. Since multiplication by T acts irreducibly on GF(2)^d, the orbit of every nonzero kernel vector spans the full V_d. Each valid label tuple is nonzero (otherwise C12 survives), so the whole deck group is generated.
6. The graph for m=147r maps by deck quotient onto the r=1 graph; projection preserves absence of cyclically reduced identity words and preserves injectivity of the explicit 14/32 witnesses. Thus one exact r=1 certificate proves the infinite towers.

## Reproducibility and independent attacks

Run with Python 3 standard library:

```
python3 search_girth.py
python3 verify_symbolic.py
python3 verify_twisted.py
python3 audit_axiom.py
```

**Distinct execution paths:** `search_girth.py` enumerates 4-vector labels by *algebraic coefficient signatures* (finite exhaustive classification), `verify_symbolic.py` independently enumerates six-root base walks and multiplies GF(2^d) field polynomials, and `verify_twisted.py` constructs all 3528 / 7056 literal vertices with a separate bit-shift representation, checks undirected cubic symmetry, connectivity, vertex-wise C32 and literal graph DFS through 16. A 14-cycle witness is extracted from literal DFS, not from the symbolic finder. This is internal different-code replay, not an external proof referee.

**Explicit falsifiers:** Any C12/16 in the listed lifted graph; a collision in either 14/32 positive word; a fifth 32-closing success class not counted by the 24/224 census; failure of m=294 projection inheritance; any prior literature establishing the same finite label classification. The 12-neutral exclusion is stronger than the earlier direct-product projection method; the *general twisted-voltage formula itself is standard covering-group algebra*.

## Independent mandatory Axiom #142 audit (scope-limited)

A separate standard-library F27 implementation (different polynomial arithmetic code path) reproduces both 53-point glued sets, all 26 explicitly described 29-mark affine sections for each, 156 pairwise same-class overlaps of size 27, 169 cross-class overlaps of size 5, and normalized polarization commutator ranks: quadratic x² 676 rank-zero pairs, quartic x⁴ 244 rank-zero and 432 rank-two. The *global completeness* that no other 29-point section exists among all 8,069,620 codim-two directions was **not independently rerun** here. Thus the finite-to-global intrinsic-recovery proof depends on Axiom's original exhaustive C++ certificate. No counterexample found in the independently checked subclaims; no full affine inequivalence approval granted. The EA-vs-ambient distinction remains essential.

## Prior art, originality and the sharp next test

The Erdős–Gyárfás problem remains open. Existing work includes Feng–Kwak cubic girth-12 graphs, work on nonabelian covers of K3,3 and semidirect voltage groups, and Daniel Garcia's September 2026 exact cycle work. **No claim that these are shortest girth-14 cubic graphs, no world-first girth claim, no new conjecture solution, and no newly invented general voltage theory.** Exact label counts plus the twisting transition are candidate *in-program* new combinatorial findings; worldwide originality/significance remain **INCONCLUSIVE**.

**Mechanism shift, stop rule:** direct-product covers retain the old abelian 12-cycle witness and cannot realize this girth14 filter; genuine semidirect action kills the universal length12 words. This meets Vesper's structural-transition request. Stop further random label enumeration at these two irreducible modules. The next decisive investigation is an analytic all-d classification, replacing finite enumerations with a representation-theoretic invariant that predicts whether the C32-closure subspace can avoid the 12-word hyperplane arrangement. Axiom attacks twisted closure and simple-witness proof; Ryev reconstructs literal graph6/cycle spectrum independently; Vesper assesses novelty, owner retains publication gate.