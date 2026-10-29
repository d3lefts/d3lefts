# AXIOM / NIGHTFALL — difference-spectrum SAT operator for maximal Sidon sets

**Date:** 2026-10-29 (America/New_York). **Research lead:** Devin J. Wright. **Derivation, implementation, and local verifier:** Axiom (GPT-6). **Primary assignment:** [Erdős #156, issue #46](https://github.com/d3lefts/d3lefts/issues/46). **Self-designed assignment:** [issue #91](https://github.com/d3lefts/d3lefts/issues/91). **Status:** proved equisatisfiable encoding with reproducible exact checks. **NOT:** a nine-mark SAT/UNSAT decision, extremal improvement, or novel mathematical theorem.

## The mathematical decision

For a subset A of [1,N] with |A|=k, require every unordered sum a+b, a<=b, to be distinct, and require every x outside A to destroy this property upon insertion. Huber (2026) proves that eight marks stop at N=144, while the published OEIS ledger gives nine as a minimum through N=183. Two independently checked ten-mark maximal Sidon sets at N=184 establish the conditional **interval 9<=m_sat(184)<=10**; the nine-mark decision remains open.

### Exact difference equivalence

Define Δ(A)={b−a: a,b∈A, a<b}. A is Sidon iff each d>0 occurs among these pairs at most once: b−a=d−c gives b+c=a+d, and any nontrivial old repeated unordered sum rearranges to a repeated positive difference (including the diagonal case a+a=b+c).

If A is Sidon and x is outside A, adjoining x breaks Sidon iff one of:

1. An **old/new difference** collision: there exist a∈A and d∈Δ(A) such that |x−a|=d, equivalently x=a±d.
2. A **new/new difference** collision: there exist distinct b,c∈A equidistant from x, equivalently 2x=b+c.

This is the exact difference/midpoint blocker criterion, also established in Huber (2026); its mathematical identity is **prior art**. It supplies a different, compact logical representation.

### Equisatisfiable Boolean encoding

- X_a states a is selected, with exactly k marks via equivalence-based threshold cardinality gates.
- P_{a,b} <=> X_a AND X_b, for 1<=a<b<=N.
- D_d <=> OR_{b−a=d} P_{a,b}, d=1,...,N−1. A sequential at-most-one condition on the P terms for each d enforces the Sidon property.
- W_{a,d} implies both X_a and D_d; a single such witness can cover both candidate locations a+d and a−d when in [1,N]. Auxiliary W values are **existential witnesses**; no reverse implication is required.
- For each x in [1,N] include the clause

  `X_x OR (OR_{a!=x} W_{a,abs(x−a)}) OR (OR_{b<c, b+c=2x} P_{b,c}).`

**Soundness:** any satisfying assignment has k selected marks, distinct old differences, and for every excluded x a genuine blocker of one of the two proven types; hence A is saturated Sidon. D_d equivalences prevent fake occupied differences. **Completeness:** from any saturated Sidon A assign X,P,D by their exact meanings, set appropriate W witnesses for every blocked x, and assign the sequential/cardinality auxiliaries to their actual partial truths. All clauses hold.

**Mutation controls:** removing the midpoint term rejects the valid saturated set A={1,3} at N=3 because x=2 has only blocker 2x=1+3. Allowing D_d to be true without any existing difference fakes blocking of x=2 for A={1,4} at N=5. Both controls are explicit.

## Exact baseline vs independent model

| Model | Variables | Clauses | Frozen deterministic CNF SHA-256 |
|---|---:|---:|---|
| Axiom sum-occupancy PR #55 | 71,108 | 195,209 | `787d297bf108d1947bdd7eebc610400840322dfb7eff3625caf8886af14a6901` |
| Axiom #91 difference-spectrum | **62,552** | **178,278** | `224fb414674d778046f91760e046b3cfb076ae19f74f53ea13850438bb9c8b80` |

The alternative uses **8,556 fewer variables (12.0324%)** and **16,931 fewer clauses (8.6733%)**. This is a structural compression of the same exact problem, rather than a scientific solution. The new DIMACS file is 2.8 MB and both files are included in the standalone ZIP.

## Independent verifier results

1. **2,272** exhaustive cardinality-fixed subsets over N=5,...,12 and k=2,...,4 (as applicable) passed the direct *original unordered-sum* oracle against the difference-CNF canonical satisfying assignment; **446** were saturated.
2. A separate **three-way comparison on 566 instances** agrees among the independent original-sum oracle, original sum-CNF, and difference-CNF. Midpoint-only and false-occupied-difference mutation fixtures pass.
3. Huber's published eight-mark witness `{8,48,68,69,71,75,104,120}` passes both the direct oracle and 144-point difference-CNF.
4. Independently reconfirmed the two existing ten-mark N=184 maximal Sidon sets `{16,49,50,56,78,93,104,125,139,149}` and `{49,50,56,78,93,104,125,139,149,166}`. Each has 55 distinct pair sums and all 174 omitted integers blocked. Deleting any one mark from either set gives an **unsaturated** nine-mark Sidon set. Minimum number of unblocked positions after a single deletion: two; the two-hole predecessor is `{49,50,56,78,93,104,125,139,149}`, with holes exactly `{16,166}`. This is a **neighborhood-local** exclusion, not a global nine-mark theorem.
5. Independently translated the CNF into SciPy/HiGHS mixed-integer constraints. N=10,k=3: feasible, direct verified witness `{5,6,9}`. N=11,k=3: solver infeasible, also directly exhaustively ruled out. **N=184,k=9:** 8-second time limit, 9.67 seconds wall including model preparation, peak 647,420 KB RSS, **no feasible witness and no UNSAT proof**. Solver statuses do not justify a nine-mark lower bound.

## Reproduce

From the `difference_sat_20261029` directory in the repo:

```bash
python3 build_difference_sat.py --N 184 --k 9 --output difference_N184_k9.cnf
python3 ../build_sat.py --N 184 --k 9 --output baseline_N184_k9.cnf
python3 verify_cnf.py
python3 verify_mutations.py
python3 solve_cnf_milp.py --N 10 --k 3 --seconds 5
python3 solve_cnf_milp.py --N 11 --k 3 --seconds 5
python3 solve_cnf_milp.py --N 184 --k 9 --seconds 8
sha256sum difference_N184_k9.cnf baseline_N184_k9.cnf
```

Generator and exhaustive verifiers use Python 3 standard library. The MILP harness depends on NumPy and SciPy. A full SAT engine with verifiable SAT/UNSAT proof output remains needed for N=184,k=9; a MILP time limit is a **negative computational outcome**, not impossibility.

## Dated scientific and attribution scope

The goal is Erdős Problem #156, still open as of 29 Oct 2026: https://www.erdosproblems.com/156. The asymptotic Ruzsa O((N log N)^(1/3)) upper bound remains the comparison. Huber's eight-mark cutoff and exact blocker lemma: https://oeis.org/A399118/a399118.pdf; OEIS A382397: https://oeis.org/A382397. The difference criterion and SAT encoding primitives are established. A custom compression is a useful reproducible research operator **without a world-first mathematical novelty claim**. Cross-review: Lemnis examine midpoint/difference equivalence and adversarial torsion differences; Ryev rerun deterministic CNF hashes and oracle. Neither earlier #46 annealing nor local ten-mark deletion has resolved the nine-mark decision.

## Next test and stop rule

Run a proof-logging SAT solver on the **exact** frozen difference-CNF; if SAT, verify the **nine sorted coordinates** against the direct oracle before any claim. If UNSAT, archive a validated proof trace and cross-check the absence against the original formulation. If timeout or contradictory claims arise, stop and record the result. Distinct structural next option: quotient end-point reflections and interval-safe translations, ensuring no symmetry is falsely assumed.
