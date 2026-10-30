# AXIOM / NIGHTFALL — exact two-anchor Sidon local exclusion and valid CNF cuts

**Date:** 2026-10-29. **Owner:** Devin J. Wright. **Investigator:** Axiom (GPT-6). **Assignment:** Erdős #156, GitHub #46; continuation of self-designed difference-SAT #91, PR #55. **Status:** certified finite search of explicitly bounded neighborhoods, producing two sound global SAT inequalities. **No global 9-mark SAT/UNSAT conclusion.**

## Decision and prior evidence

Let `N=184`, `k=9`. We seek an inclusion-maximal Sidon subset `A⊂[1,N]` with `|A|=9` and distinct unordered pair sums **including diagonal pairs**. A previous proof/status gave `9≤m_sat(184)≤10`, using Huber's eight-mark exclusion beyond N=144 and two exact ten-mark witnesses:

```
S1 = {16,49,50,56,78,93,104,125,139,149}
S2 = {49,50,56,78,93,104,125,139,149,166}
```

Both ten-mark witnesses are inclusion-maximal and have 55 distinct unordered pair sums. A previous 62,552-variable, 178,278-clause difference-spectrum CNF had not yielded a nine-mark decision.

## Exact exhaustive local exclusion theorem

**Claim.** Any nine-element inclusion-maximal Sidon set `A⊂[1,184]` satisfies **both**:

```
|A ∩ S1| ≤ 6,    |A ∩ S2| ≤ 6.
```

**Finite proof contract.** If `|A∩S|≥7` for a ten-element anchor S, write `r=10−|A∩S|`. Then `r∈{1,2,3}`. Exactly `r` anchor marks must be deleted and exactly `r−1` marks from the other 174 positions added. The `C(10,r)C(174,r−1)` possibilities are all enumerated. Each candidate is tested directly for repeated unordered pair sums (or, in a separate implementation, repeated positive differences), and then for every omitted point `x` the oracle checks whether `2x=b+c` or `x+a=b+c` for some old marks. No candidate with zero uncovered positions survives. Thus the two inequalities hold, conditional only on correct exhaustive computation and its independently reconstructed oracle.

Per anchor counts (same in both source implementations):

| r deletions | k=9 assignments | Sidon S1 | Sidon S2 | Saturated |
|---|---:|---:|---:|---:|
| 1 | 10 | 10 | 10 | 0 |
| 2 | 7,830 | 2,062 | 2,036 | 0 |
| 3 | 1,806,120 | 238,215 | 234,004 | 0 |

There are **1,813,960 assignments per anchor**, 3,627,920 total evaluations. The excluded sets across two anchors overlap in exactly **1,612** nine-mark sets, giving **3,626,308 distinct excluded nine-mark subsets**. This overlap follows by writing `B=S1∩S2` (nine elements): 36 subsets with seven B points plus both exceptional points, 9×173 with eight B points and one exterior point, 18 with eight B points and one exceptional point, and B itself.

The best encountered legal Sidon candidates still have **two uncovered positions** at r=1, **six** at r=2, **five** at r=3. These bounds are local and do not imply a global lower bound beyond the already known 9≤m_sat(184).

## Valid inequalities for the *global* nine-mark decision

For each 10-mark seed S and each 7-subset T⊂S, impose the clause

```
∨_{a∈T} ¬X_a .
```

This expresses `sum_{a∈S}X_a≤6`. The two anchors share nine marks, so the 240 initially listed 7-subset clauses contain 36 duplicates, leaving **204 unique 7-literal clauses**. No new variables are required. A satisfying model to the strengthened CNF would still yield an exact nine-mark witness; UNSAT would still need a checkable proof or accepted independent certificate.

- Original difference CNF: **62,552 variables, 178,278 clauses**, SHA-256 `224fb414674d778046f91760e046b3cfb076ae19f74f53ea13850438bb9c8b80`.
- Strengthened CNF: **62,552 variables, 178,482 clauses**, SHA-256 `d4db70f5a363226a49e9549fe9cea09c5cb16128aa9bcef5d4d79df6009b8da8`.

The added clauses are a logically justified reduction of the global feasible region, not a free symmetry assumption. The weaker sum-CNF and original difference-CNF continue to define the same global decision.

## Independent verification and negative control

1. `exact_exchange.cpp`: exhaustive positive-difference Sidon oracle and difference/midpoint coverage. All six rows above produced in approximately 1.44 CPU wall seconds.
2. `verify_exchange_direct.cpp`: independently constructed candidate loops and **direct unordered sums** and insertion-obstruction checks, with matching six rows and counts. About 1.04 wall seconds.
3. `verify_and_cut.py`: third direct-sum implementation fully reruns both two-deletion neighborhoods (7,830 each), samples 10,000 candidates from each three-deletion neighborhood with seed 1729, tests best/minimum-hole specimens and both ten-mark controls, generates/validates 204 cuts, and emits the strengthened CNF. This Python program is *supplemental*; both full C++ paths are independent of each other.
4. `z3_smtlib_exact.py`: invokes installed libz3 through its C interface; independently confirms small SAT (N10 k3) and UNSAT (N11 k3) toy cases. Full strengthened N184 k9 run with a 12-second solver timeout returns **unknown** (elapsed 13.22 sec). There is **no** nine-mark witness and **no** global UNSAT proof from Z3. Earlier HiGHS run was also inconclusive.

**Falsifiers:** diagonal-pair omission (violates Sidon); omitted x with no blocking old pair; fake occupancy witnesses; failing a single exact C++ count; a found nine-mark candidate with seven anchor marks; a Z3 `unknown` misreported as UNSAT. The scripts and log outputs below allow immediate replay and adversarial mutation.

## Reproduction

```sh
g++ -std=c++17 -O3 exact_exchange.cpp -o exact_exchange
./exact_exchange
g++ -std=c++17 -O3 verify_exchange_direct.cpp -o verify_exchange_direct
./verify_exchange_direct
python3 verify_and_cut.py
python3 z3_smtlib_exact.py difference_N184_k9_with_local_cuts.cnf --timeout 12000
sha256sum *.cpp *.py *.log *.cnf
```

`verify_and_cut.py` reads the included `difference_N184_k9.cnf` by a path relative to the script, so standalone replay has no hardcoded working-directory dependency. The archive includes the baseline file. The Z3 runtime is optional, and `unknown` is an expected possible status.

**Scientific status:** exact, independently repeated bounded finite obstruction and two sound SAT cuts, with no extremal theorem or priority claim. Subsequent work should use proof-logging SAT/CP-SAT on the complete global decision and retain transparent stop rules.
