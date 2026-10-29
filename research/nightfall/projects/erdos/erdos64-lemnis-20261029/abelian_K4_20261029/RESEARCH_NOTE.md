# NIGHTFALL / Lemnis — short power-of-two cycles in all abelian regular K4 covers

**Research owner:** Devin J. Wright · NIGHTFALL PHASESHIFT. **Mathematical development / referee:** Lemnis (GPT-6). **Date:** 29 October 2026.  
**Self-designed assignment:** [#98](https://github.com/d3lefts/d3lefts/issues/98). **Parent:** [Erdős #64 / #47](https://github.com/d3lefts/d3lefts/issues/47).  
**Status:** complete self-contained algebraic proof and independent finite verifiers PASS; worldwide mathematical priority and specialist human review OPEN. No global Erdős–Gyárfás solution is asserted.

## Main theorem

Let A be any abelian group, and let X be a regular voltage cover of the simple graph K4 with deck group A. Each lifted vertex has degree 3. **X contains a simple cycle with length 4, 8 or 16.** Connectivity and finiteness of A are not needed. In particular, no finite abelian regular K4 cover can be a counterexample to Erdős–Gyárfás #64.

### Normalization

Switch the voltages on the edges of the spanning star (0,1),(0,2),(0,3) to zero. Let the additive chord voltages on oriented (1,2),(1,3),(2,3) be a,b,c ∈ A, with the reverse voltage negated. A walk lifts from (base vertex 0, deck element 0) by adding its directed edge voltages.

### Universal length-16 word

The base walk

```
W = 01201203102102130
```

has length 16. Its chord-voltage sum is `2a-b-2a+b=0` in an abelian group; c is unrestricted. The visited lifted labels, excluding the repeated final vertex, have base-group lists

```
base 0 : 0, a, 2a, 2a-b, a-b
base 1 : 0, a, 2a-b, a-b, -b
base 2 : a, 2a, 2a-b, a-b
base 3 : 2a, 0
```

The labels on each base are pairwise distinct whenever `ord(a) >= 3` and `b ∉ {0, a, -a, 2a}`. This is checked by subtracting each same-base pair, not by assuming that a closed walk is automatically a simple cycle. Consequently this condition forces a simple C16.

### Exhaustive reduction

Choose a chord with order at least 3 and relabel it as (1,2), voltage a. Put `T={0,±a,±2a}`. If b lies outside T, W is a C16. If c lies outside T, swap the base vertices 1 and 2; the new a is -a and the new b is c, so W again is a C16.

It remains to handle **b and c in T**. Write b=ia, c=ja with i,j ∈ {-2,-1,0,1,2}. For each of the 25 pairs, the following base words give a simple cycle in the free infinite cyclic cover (a=1). The words have 4, 8 or 16 edges. Every same-base voltage difference among their visited states has absolute value at most 4. Thus, when `ord(a)>=5`, they are also simple in the quotient by the actual order of a.

| i=b/a | j=-2 | j=-1 | j=0 | j=1 | j=2 |
|---:|---|---|---|---|---|
| -2 | `01320` | `01230` | `01201203102102130` | `013203120` | `012302130` |
| -1 | `012301320` | `01230` | `012301320` | `012301320` | `012301320` |
| 0 | `012031230` | `01230` | `01320` | `013203120` | `01201203210210230` |
| 1 | `02130` | `01230` | `02130` | `01320` | `02130` |
| 2 | `012302130` | `01230` | `012031230` | `013203120` | `01320` |

For the only remaining orders `ord(a)=3` and `4`, each of the 25 words still works except these **seven cases**, replaced by the exact short witnesses:

| order(a) | (i,j) | valid word |
|---:|---|---|
| 3 | (-2,0) | `02130` |
| 3 | (-2,1) | `01320` |
| 3 | (-2,2) | `01230` |
| 3 | (-1,2) | `01230` |
| 3 | (0,2) | `01230` |
| 4 | (-2,0) | `012031230` |
| 4 | (0,2) | `012031230` |

Every word's voltage sum is zero and every visited `(base, group)` pair is distinct. The table is a **finite mathematical certificate**, not a probabilistic enumeration claim; the checkers assert both properties for all entries, and an independent literal graph implementation verifies all relevant edges.

Finally, if every chord has order at most two, the base 4-cycle `01230` has net voltage a+c of order at most two because A is abelian. It lifts to a **simple C4** when a+c=0 and a **simple C8** when a+c≠0. This exhausts all cases. QED.

## Additional nonabelian theorem (strictly conditional)

Let G be any group, using the same star-normalized K4 voltage notation, now multiplicative. Suppose two incident chord labels a,b satisfy

```
ord(a) >= 3, b not in <a>, a^2 b = b a^2.
```

Then W lifts to a **simple C16**, for arbitrary third chord voltage c.

The net voltage is `a^2 b^(-1) a^(-2) b = e` by the commutation hypothesis. Its 16 states grouped by base have the following labels:

```
base 0: e, a, a², a²b⁻¹, a²b⁻¹a⁻¹
base 1: e, a, a²b⁻¹, a²b⁻¹a⁻¹, a²b⁻¹a⁻²
base 2: a, a², a²b⁻¹, a²b⁻¹a⁻¹
base 3: a², e
```

All entries inside `<a>` are distinct, all labels containing b⁻¹ lie **outside** `<a>`, and the latter are distinct because ord(a)≥3. Hence W has no repeated lifted vertex. This criterion includes nonabelian D8 and Q8 with a of order four and b outside its cyclic subgroup (a² central), and certain groups with mixed prime factors. It is a conditional theorem, never a general nonabelian-cover theorem.

## Adversarial and reproduction evidence

- `verify_abelian_k4_certificate.py`: direct symbolic W label collision set `{0,±a,2a}`, 25 residual integer cases, seven small-order exceptions, three rejected incorrect words. PASS.
- `verify_abelian_k4_literal.py`: independently constructed 21,345 literal abelian regular K4 covers (cyclic, product and sampled mixed groups); every produced C4/C8/C16 is edge-by-edge checked, with full adjacency and degree checks on selected classes. PASS.
- `verify_k4_dfs_oracle.py`: **independent brute DFS**, without any table or W, across all 2,016 cyclic voltage triples for deck groups of orders 3 through 9. First observed cycles: 724 of length 4, 956 of length 8, 336 of length 16; no failures. PASS.
- `verify_nonabelian_commuting_square.py`: separate literal group multiplications D8/D16/Q8/C3×S3, totaling 388 simple C16 instances, with negative controls. PASS.
- `audit_ryev_optimum.py`: entirely separate exact-symbolic verification of Ryev's two-window Sidon optimizer in [PR #89](https://github.com/d3lefts/d3lefts/pull/89). Scoped PASS; the certified improvement is entirely inside an imported finite-prefix asymptotic bound.

All tests are finite support checks of a separately written all-group proof. They are not an external mathematical referee. A malformed word, insufficient phase-order premise and a false polynomial perturbation are deliberately rejected.

## Priority / scope and source relationships

This work extends Lemnis's earlier **exponent-three** nonabelian K4 obstruction ([#85](https://github.com/d3lefts/d3lefts/issues/85)) and the classical **2-primary cover** stop rule ([#80](https://github.com/d3lefts/d3lefts/issues/80)). It now handles **every abelian K4 regular voltage cover of arbitrary group order** and yields a separate nonabelian square-central criterion.

**Prior literature, important:** Conder and Ma, *Arc-transitive abelian regular covers of cubic graphs* (J. Algebra 387, 2013, DOI 10.1016/j.jalgebra.2013.02.035), classify **arc-transitive** abelian regular K4 covers, a narrower symmetry class than the present all-voltage theorem. Ghasemi and Varmazyar, *On the Erdős–Gyárfás conjecture for some Cayley graphs* (2020/21), establish adjacent 4/8/16 results for Cayley classes. These sources and classical Gross–Tucker voltage-graph theory could imply part or all of this result. **A complete same-scope global priority search has not been completed, and no world-first assertion is authorized.** The general Erdős–Gyárfás conjecture remains OPEN; this only excludes a specific cover family.

**Further search rule:** Stop all abelian K4 regular voltage searches. To seek a counterexample, explore K4 nonabelian voltages that evade the central-square C16 criterion and earlier order-three/2-group obstructions, then use an independent full 2-power-cycle oracle. Alternatively change the base graph or covering geometry. Avoid concluding that arbitrary cubic graphs satisfy the conjecture from these families.
