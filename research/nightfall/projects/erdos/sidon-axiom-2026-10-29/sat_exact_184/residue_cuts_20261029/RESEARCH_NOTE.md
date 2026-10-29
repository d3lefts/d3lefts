# AXIOM — Residue-sector saturation capacities and exact Sidon SAT cuts

**Research date:** 2026-10-29. **Scientific lead:** Devin J. Wright / NIGHTFALL. **Mathematical derivation, source and internal exact tests:** Axiom (GPT-6). **Assignment:** self-designed #146, linked to Axiom #46. **Status:** R1 — general elementary necessary inequality plus independently tested fixed-instance cut; N=184 nine-mark global SAT/UNSAT remains **OPEN**. No new record, original-publication novelty clearance, external mathematical referee, or solver-speed improvement claimed.

## Theorem (all N,k,m; exact algebraic scope)

Let A⊂{1,…,N} be an inclusion-maximal *Sidon set*, meaning all unordered sums a+b (a≤b) are distinct and every integer in [1,N]\A is blocked from insertion. Write k=|A|, m≥2 and n_r=|{a∈A:a≡r mod m}|. Let H_r=|{1≤x≤N:x≡r mod m}|.

For each t in Z/mZ define

- `T_t = sum_{u,v,w mod m;u+v−w=t} n_u n_v n_w`, the ordered residue triple convolution.
- `D_t = sum_{u,w mod m;2u−w=t} n_u (n_w−1_{u=w})`, the ordered diagonal-sum correction.
- `F_t = (T_t−(2k−1)n_t+D_t)/2`, a nonnegative integer.
- `P_t = sum_{u<v residues;u+v=2t} n_u n_v + sum_{u residue;2u=2t} binom(n_u,2)`, where all congruences are modulo m. **For even m**, P_t deliberately overcounts integer midpoints; it remains a valid upper bound.

Then every saturated Sidon A satisfies, simultaneously for all t,

```
H_t−n_t ≤ F_t+P_t.                                       (1)
```

**Proof.** Sidon uniqueness implies that for every old a∈A, the ordered equation x+y−z=a has exactly 2k−1 solutions: (a,b,b),(b,a,b) for b≠a, plus (a,a,a). Accordingly, the ordered triple convolution T_t contains exactly (2k−1)n_t trivial triples which evaluate inside A. Every other triple evaluates outside A. Ordered solutions with x≠y occur in symmetric pairs and supply at most one distinct external insertion target per pair; those with x=y occur once. Adding D_t back before halving gives exactly F_t *formal* unordered triple/blocker incidences by residue. Each additional blocked x can arise from an integer midpoint 2x=a+b with a<b in A, counted among P_t (the necessary congruence holds even when m is even). Since A is saturated, its H_t−n_t omitted points must all be covered by these candidates. Multiple representations can only reduce the number of **distinct** blocked points, proving (1). No probabilistic independence assumption enters.

The inequality is a necessary condition, never a sufficient test for maximality. It applies to all N,k,m, independently of how the Sidon marks are found.

## Certified fixed instance: N=184, k=9

Enumerate **all** weak compositions n_0+...+n_(m−1)=9 using exact Python integers; reject a profile if any inequality (1) fails. The strongest per-sector necessary quota from each listed census is:

| Modulus m | Total profiles | Rejected | Each residue cap |
|--:|--:|--:|--:|
| 3 | 55 | 9 | 7 |
| 7 | 5005 | 1048 | 6 |
| 9 | 24310 | 4816 | **5** |
| 10 | 48620 | 10622 | **5** |

The rejected percentages are proportions of *residue-composition profiles*, **not** candidate nine-element sets, solver search nodes or solution probability. No SAT or UNSAT global conclusion follows from them.

**Adversarial difference:** `A=[1,2,4,10,14,37,91,109,154]` has nine marks and **all 45 unordered pair sums distinct**, yet is unsaturated with **51 addable points**. Six marks are congruent to 1 modulo 9, violating the proved sector cap 5. Thus the quota is a maximality restriction stronger than the Sidon condition alone. The new formula's failed sector is residue 8 modulo 9.

## Exact SAT consequence and proof of equivalence

Add to Axiom's already independent **positive-difference CNF** in draft PR #55 the 29 upper-cardinality constraints `sum_{a≡r mod m} X_a ≤ bound(m,r)` for (m,bound)=(3,7),(7,6),(9,5),(10,5). Implement each via the standard one-way Sinz sequential counter: unary prefix-at-least variables propagate forward; every `(k+1)`-st true input triggers a conflict. This is an *existentially equisatisfiable* representation of the at-most predicate. There is no symmetry-breaking assumption or implication from the original SAT to a new theorem.

**Frozen target, original difference CNF:** 62,552 variables / 178,278 clauses.

**Augmented CNF:** 66,268 variables / 186,130 clauses; **3,716 new variables / 7,852 new clauses / 29 residue quotas**. Full deterministic DIMACS SHA-256: `b3c1054e1bcbe3eaa8b26ebbb367a1b98d223f833d02bc8b04bf5230dedfe9af`. The new constraints add solver overhead; speedups remain *unmeasured*. The original nine-mark decision remains unresolved.

## Independent verification contract

1. `residue_bounds.py`: analytic T,D,F,P formula and exact 9-mark histogram census moduli 2–10. `residue_census.log` is the complete output.
2. `independent_oracle.py`: **independent literal integer unordered-pair-sum and insertion-blocker arithmetic**, with no import from the prior builder. Checked 2,784 Sidon subsets of [1,N], N=3..14, k=2..4; 22,272 exact modular comparisons; **every** saturated set satisfies all capacities. Separately reconstructs the nine-mark negative fixture. Output `oracle.log`.
3. `verify_counter.py`: independently written propositional sequential-counter generator and unit-propagation checker, exhaustive **36,868** Boolean masks across 2≤n≤11 and all 1≤k<n. `counter.log` records results. Correctness for all n follows by induction on prefix counts, not from finite testing.
4. `augment_difference_cnf.py`: imports the original positive-difference source from `../difference_sat_20261029/build_difference_sat.py`, and emits the augmented exact DIMACS. Standalone `--output` option and reported SHA. The original build is preserved unchanged. `augmented.log` contains counts and frozen digest.

Regenerate from the directory `sat_exact_184/residue_cuts_20261029` of PR #55:

```bash
python3 residue_bounds.py
python3 independent_oracle.py
python3 verify_counter.py
python3 augment_difference_cnf.py --output sidon_N184_k9_residue.cnf
sha256sum sidon_N184_k9_residue.cnf
```

The complete DIMACS is supplied in the accompanying frozen ZIP; it is regenerated by GitHub text sources and is not necessary as a source-controlled binary.

## Publication contract and remaining proof

**Proposed future paper:** *Residue-Sector Blocker Capacity and Exact Saturation Constraints for Sidon Sets.* Closest published foundations: Erdős–Sárközy–Sós (1994) Sidon sumsets; Ruzsa (1998) `O((N log N)^(1/3))` saturated construction; Huber (2026) exact difference/midpoint saturation criterion. Our counting argument is elementary, and same-scope independent novelty is **unestablished**.

**R-stage:** R1 exact internal proof/checker for a new fixed finite constraint layer. Missing R2/R3 gate: a quantitative asymptotic improvement, novel certified obstruction, **or** a verified SAT witness/UNSAT proof for a mathematically significant new finite threshold, followed by adversarial Lemnis proof audit, Ryev independent replay, dated literature review, and owner approval.

The primary Erdős #156 conjecture remains open. This finite quotient-capacity method supplies safe preprocessing for the unresolved N184 nine-mark instance; neither a source-general O(N^(1/3)) construction nor a 9-mark UNSAT certificate has been obtained.
