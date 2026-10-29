# NIGHTFALL / CONSTELLATION — Sidon insertion arity transition

**Checkpoint:** October 29, 2026 (Eastern). **Scientific lead:** Devin J. Wright. **Cross-agent synthesis and independent finite audit:** Axiom (GPT-6). **Contributing investigators:** Tessera, Vesper, Ryev, Axiom. **Status:** finite check newly replayed; component theorems are internally supported drafts, external proof review and worldwide novelty open. **Editorial:** Mechanism Atlas case study, outside the existing Original Findings and 33-dossier library.

## Core mechanism

Three independent investigations concern the **same old-mark collision-support hypergraph** arising when prescribed new marks are inserted into an existing Sidon set.

1. **Single insertion (Tessera [draft PR #136](https://github.com/d3lefts/d3lefts/pull/136), issue #130).** For any finite abelian Sidon set of K old marks, unique differences partition ordinary one-point collisions into 1- or 2-point orbits, with an injective third-point map. Contraction gives a functional pseudoforest. The draft proves exact optimal repair in O(K) operations *after* O(K²) difference preprocessing, with a separate forced-deletion branch for 2a=x+y. Algorithmic priority and independent human proof review remain open.
2. **Batch insertion (Vesper [merged PR #110](https://github.com/d3lefts/d3lefts/pull/110), Ryev [draft PR #120](https://github.com/d3lefts/d3lefts/pull/120)).** Exact classification of (1,0), (1,1), (2,0), (2,1) and (2,2) unordered-sum collision classes, with protected marks, gives a minimum deletion-cover formulation. Branch on exceptional supports and c old marks in at least three ordinary supports; match the residual degree-at-most-two incidence graph. The parameterized running time is 2^[c+O(k³)] poly(K+k), where k is the insertion batch size. Ryev sharpens the exceptional-mark bound to (k³+3k²)/2. There is no claimed uniform polynomial bound.
3. **Two-insertion core (Axiom [draft PR #135](https://github.com/d3lefts/d3lefts/pull/135), issue #132).** For a cyclic (v,q,1) perfect difference set with v=q(q−1)+1 and every distinct outside pair, the ordinary support high-degree core satisfies c ≥ max(0,ceil((q−5)/2)) when gcd(v,3)=1, and c ≥ max(0,ceil((q−13)/2)) when 3 divides v. The proof uses exact triple counts, unique differences, bounded overlap and careful 3-torsion treatment. It yields an infinite family with c=Omega(q) for fixed insertion batch size k=2.

**Synthesis / precise corollary of those drafts:** the natural degree-2 collision representation gives a fast one-point solver; two prescribed insertions can force a high-incidence core linear in source size, so **batch size alone does not bound the c parameter of Vesper's present branching algorithm**. This is a structural transition, NOT a hardness theorem, universal algorithm lower bound, Sidon-density improvement, or resolution of Erdős #44/#156/#329. A better algorithm might exploit algebraic coupling without branching on every core mark.

## New independent numerical certificate

The accompanying [audit.py](audit.py) was written independently of the original agents' code. It uses Python standard library and exact modular integers with no tolerance.

Fixed source: Z/91Z, D={0,1,3,9,27,49,56,61,77,81}. All 90 nonzero ordered differences occur exactly once. There are 81 outside points.

- **All 81 individual insertion points:** direct whole-union pair-sum brute force and separately constructed collision-support hitting-set optimization agree on exact minimum deletion cost. Histogram: 54 points need 3 deletions; 27 need 4. All ordinary-support vertex degrees are at most 2. This checks finite optimality, not Tessera's asymptotic runtime.
- **All 3,240 unordered outside-point pairs:** literal unordered-triple support enumeration agrees exactly with a unique-ordered-difference reconstruction. The exact high-degree-core census follows.

| Core size | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---:|---:|---:|---:|---:|---:|
| Pairs | 42 | 198 | 798 | 1,332 | 792 | 78 |

For this **one exact source**, every two-point pair has c≥5; this improves on the general c≥3 lower bound when q=10 only at this finite scope. The pair {4,67} attains c=5 with core {0,3,9,27,61}; all 3,240 pairs were checked. This is a new finite census, not a new universal inequality.

Run from repository root:

    python3 research/nightfall/syntheses/sidon_arity_20261029/audit.py

Exact JSON receipt SHA-256: **2d8a02aa7d95116350fb47879524bab73baeb3922074bc6dd5538e6878cb868d**. Independently executed source SHA-256: **d6e3880a1ae426609964ad554c80cae78644d0cd2bb4f8e639e8edf79c250c0d**. The script prints reproducible output and hash. GitHub Actions replay is a separate remaining gate.

## Completed second experiment: exact repair-cost census

The independent [audit_pair_cost.cpp](audit_pair_cost.cpp) checks the actual optimum number of old marks to delete for **every one of the same 3,240 two-insertion pairs**. Its algorithm enumerates all 1,024 old-mark subsets, evaluates all unordered pair sums in the entire surviving union, and minimizes deletion cost without importing the Python collision-cover solver. It also rebuilds the ordinary collision core to correlate it with cost.

Build and run with any standard C++17 compiler:

    c++ -std=c++17 -O3 research/nightfall/syntheses/sidon_arity_20261029/audit_pair_cost.cpp -o sidon_cost_audit
    ./sidon_cost_audit

**Exact joint distribution:** columns are optimal numbers of old marks deleted.

| Core size c | Cost 3 | Cost 4 | Cost 5 | Cost 6 | Total |
|---:|---:|---:|---:|---:|---:|
| 5 | 0 | 6 | 36 | 0 | 42 |
| 6 | 3 | 75 | 120 | 0 | 198 |
| 7 | 0 | 327 | 459 | 12 | 798 |
| 8 | 0 | 540 | 765 | 27 | 1,332 |
| 9 | 0 | 234 | 546 | 12 | 792 |
| 10 | 0 | 6 | 72 | 0 | 78 |
| **Total** | **3** | **1,188** | **1,998** | **51** | **3,240** |

**Exact nonmonotonicity counterexample for this same source:**
- New pair {4,67}: core c=5; **minimum deletions = 5**, 15 minimum deletion sets. One optimum deletes {0,9,27,49,81}, leaving Sidon union {1,3,4,56,61,67,77}.
- New pair {8,34}: **larger core c=6**, yet **minimum deletions = 3**, with unique optimum deleting {1,27,56}, leaving Sidon union {0,3,8,9,34,49,61,77,81}.

A separately written Python direct-sum subset enumerator recomputed both optima and proved no smaller deletion count works by exhaustive finite enumeration; {23,86} (c=5, cost 4) was an additional independent control.

**New scoped conclusion:** even on a fixed perfect difference set, **high-incidence core size is not a monotone predictor of optimal repair cost**. It measures one branch-complexity parameter of Vesper's algorithm, not the optimum cover value. Optimizing c alone therefore cannot be treated as optimizing deletion cost. This is a finite exact counterexample, not a complexity-class theorem or a claim of worldwide new priority.

The two-insertion exact-cost problem from the first checkpoint is now completed for this source. The next falsifiable operator is a *two-involution quotient* that matches the entire frozen joint distribution and gives a family-level proof.

## What other agents' work says about transfer

- Tessera's [same-source barrier #115](https://github.com/d3lefts/d3lefts/pull/115), [source-switching counterexample #118](https://github.com/d3lefts/d3lefts/pull/118), [collision conservation #128](https://github.com/d3lefts/d3lefts/pull/128) show why raw collision counts fail to determine minimum deletions. The [non-TU triangle #102](https://github.com/d3lefts/d3lefts/pull/102) prevents assuming integral matching-cover duality for every Singer repair; [coset rigidity #143](https://github.com/d3lefts/d3lefts/pull/143) blocks only one subfield-motif amplification route.
- Axiom's [planar-function gluing #144](https://github.com/d3lefts/d3lefts/pull/144) concerns maximal strong Sidon sets in finite abelian groups, with a known quadratic predecessor. The unproved affine-inequivalence/priority gate and missing carry-safe integer transfer make it a **separate theorem family**, not proof of recursive Sidon nesting.
- Ryev's [Q7 parity-syndrome gate #148](https://github.com/d3lefts/d3lefts/pull/148) gives a proposed necessary 12-even-square condition for a hypothetical 305-edge construction, reliant on a published odd-square subclass bound. It is an independent cochain obstruction, not a Sidon collision-core corollary.
- Lemnis's [finite cycle-gadget exclusion #57](https://github.com/d3lefts/d3lefts/pull/57) is a source-scoped negative result; the graph problem remains open. Tessara's [continuum-overlap assignment #76](https://github.com/d3lefts/d3lefts/issues/76) has no newly independently certified lower-bound gain in the material inspected. Vesper's [proof-audit shields #133](https://github.com/d3lefts/d3lefts/pull/133) apply a standard minimum-cut theorem to reviewer planning, not a new mathematical theorem.

**Conclusion:** A coherent site package exists in *exact Sidon insertion/repair*. Fold in the collision conservation and source-switching results as limits and experiments. Keep the phase-decoder, Q7, power-of-two cycles, continuum-overlap, Werner and PAS programs in their own scientific claim lanes. A conceptual shared theme is insufficient for a new theorem.

## Next decisive representation experiment

**Hypothesis A:** two single-insertion involution systems possess an exact polynomial-size quotient for simultaneous repair on Singer sets. **Alternative:** crossing cycles or exceptional (1,1)/(2,0)/(2,1) collisions obstruct that quotient.

The direct two-point minimum deletion costs and full joint core/cost table have now been exhaustively computed. Construct an explicit two-orbit quotient using these frozen data, then require it to reproduce exact optima for all 3,240 batches, with the 42 c=5 and 78 c=10 cases serving as adversarial controls. Include diagonal/repeated-summand cases, infeasibility/protected-mark controls, source and output hashes. A finite clean sweep gives a candidate; **an all-q algorithm needs a proof**. Two genuine counterexamples to the same proposed quotient should force an operator change.

## Evidence gates

**Verified locally this session:** exact independent 91-element finite census and single-insertion optimum checks.  
**Component proof candidates, human review open:** Tessera #136 O(K) postprocessing; Axiom #135 infinite-family core bound; Vesper #110/Ryev #120 batch parameterization.  
**Novelty open:** international same-scope literature audit and non-author mathematical review.  
**Global open:** polynomial two-point algorithm, recursion with growing integer prefixes, Sidon asymptotic or maximality record.  
**Review assignment:** Lemnis attacks proofs and torsion; Ryev replicates independently; Tessera tests quotient repair; Vesper verifies provenance, quantifiers, priority. Human owner alone approves any Original Finding or publication-status promotion.
