# LEMNIS — Independent sumset-hole adversarial audit and complete six-hole theorem

**Date:** 2026-10-30. **Assignment:** Vesper #273; producer PR #272. **Auditor:** Lemnis (AI role; not an independent human mathematical referee). **Research lead:** Devin J. Wright. **Stage:** R1 internally proved/coded; historical priority and external review unresolved.

## Audit target and model freeze

Producer: one allowed measurement is `(a·x)^2` over a finite field `K`, coefficient row `a` may depend only on previously observed squared readings, all measurements including k coordinate squares count, recover every `x` modulo one global sign. The additive precursor concerns only `G=(Z/qZ)^2`, which has a field interpretation for the specific prime `q=p`; **the composite-q additive extension is not a field-powered oracle construction**.

### Exact finite results independently reimplemented

1. In the different GF169 representation `u=t+1`, `u^2=2u+1`, six binary generators `w=(1,t,2,2t,7+5t,12+5t)` have 64 distinct subset sums, 167/169 pair sums, missing **exactly** `(6,9),(12,4)` in the original `(1,t)` coordinates. The specified mixed row `(8+2t;7,7t,1,t,10+9t,6+9t)` yields 64 different *legal squared* readings, including all 6-sign zero-output checks.
2. Independent all-support replay reconstructs all `169^2=28,561` two-coordinate signals, **every 126** nonempty partial-block sign assignment for b=1..6, and 12,000 seeded 7-coordinate signals. It never queries an unpowered amplitude. It handles the zero signal and root representative normalization explicitly.
3. Independent literal binary tile plus full pair-sum verification at p=13,29,31,61,127; p=509 uses disjoint tile + all nine Minkowski rectangle checks to avoid 4B redundant pairs. All sumset complements equal the exact symbolic theorem below. Composite `q=63,125,253,255,511` also checked via exact nine-rectangle union. All outcomes use Python integers, no tolerances.

## New quantified strengthening: *complete* six-hole theorem

Let `D=2^d >=8`, let `s ∈ {1,3}` and **q=4D-s be any odd integer** (primality is unnecessary here). Work in `G=(Z/qZ)^2` and define

- `A={0,...,D-1}^2`;
- `v=(2D−1,D+1)`, `w=(−1,D+1)`;
- `T=A ∪(A+v)∪(A+w)∪(A+v+w)`.

Then `|T|=4D²=2^(2d+2)` and **exactly six** elements of `G` are *not* in `T+T`:
