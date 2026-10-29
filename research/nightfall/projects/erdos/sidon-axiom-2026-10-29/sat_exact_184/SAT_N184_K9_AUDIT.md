# AXIOM / NIGHTFALL — exact maximal-Sidon SAT transition and independent cross-audits

**Checkpoint:** 29 October 2026. **Research lead:** Devin J. Wright. **Implementation and mathematical analysis:** Axiom (GPT-6). **Assignments:** GitHub #46 (primary), #49 (secondary), #60 (team handoff), and Lemnis PR #57 (independent review). **Status:** an exact *reduction to SAT* and bounded finite checks. **The N=184, k=9 decision is unresolved.** No Erdős problem or record is claimed solved.

## The exact decision problem

Given integers `1 <= k <= N`, find `A subset {1,...,N}` of size exactly `k` such that:

1. All unordered pair sums `a+b` for `a<=b` in `A` are distinct (repeated-element pairs included).
2. Every `x` outside `A` is blocked: either an old pair has sum `2x`, or an old pair has sum `x+a` for some chosen old mark `a`.

The second condition exactly characterizes inclusion maximality; it is not implied by the Sidon property. The accepted 2026 reference is Huber's N=144 eight-mark saturated example; Huber excludes any eight-mark saturated example for N>=145. OEIS A382397 reports minimum nine marks for 145<=N<=183. The asymptotic Ruzsa upper bound remains O((N log N)^(1/3)); Erdős #156 asks for O(N^(1/3)). The finite SAT task neither resolves the asymptotic question nor proves the N=184 minimum.

## Equisatisfiable SAT construction (soundness and completeness)

`build_sat.py` produces deterministic DIMACS CNF. Its primitive Boolean marks are `X_i` for membership `i in A`.

- A dynamic threshold circuit enforces `sum_i X_i = k` exactly, with *equivalences* for every auxiliary gate.
- `P_ij` is equivalent to `X_i AND X_j` when `i<j`; `P_ii=X_i` (so diagonal sums count). At each sum `s`, a linear-size sequential at-most-one encoding enforces that at most one selected unordered pair has sum `s`.
- `S_s` is equivalent to the disjunction of selected pair variables having sum `s`. Equivalences, including the reverse implication, prevent invented occupied sums.
- For each point `x`, one clause requires `X_x OR S_(2x) OR OR_(a != x) W_(x,a)`. A witness `W_(x,a)` implies **both** `X_a` and `S_(x+a)`. The blocker implication is intentionally one-way: existential witnesses are chosen when needed. Because the sum occupancy is constrained exactly, a spurious blocker cannot satisfy this clause.

**Forward direction:** Any satisfying assignment selects exactly k marks; the pair-at-most-one constraints make them Sidon. For each omitted x, its saturation clause supplies a genuine old-sum collision on inserting x, proving maximality. **Reverse direction:** Given a saturated Sidon set of k marks, set all pair/occupancy/cardinality auxiliary variables to their exact meanings, set each `W_(x,a)` to the truth of `X_a AND S_(x+a)`, and satisfy every saturation clause. Thus the CNF is satisfiable *iff* such a maximal Sidon set exists.

The generated N184 k9 formula has **71,108 variables**, **195,209 clauses**, and a 3.0 MiB deterministic DIMACS file, with SHA-256 `787d297bf108d1947bdd7eebc610400840322dfb7eff3625caf8886af14a6901`.

## Independent results and falsifiers

1. `independent_oracle.py` uses direct unordered pair-sum enumeration and tests *each omitted x* explicitly. It validates Huber's published N144 k8 witness `{8,48,68,69,71,75,104,120}`; canonical auxiliary assignments satisfy **all 120,222 CNF clauses** (43,839 variables). The previous N184 nine-mark near-candidate `{49,50,56,78,93,104,125,139,149}` remains unsaturated at **exactly x=16 and x=166**. Removing one mark from Huber's example violates its exact-cardinality CNF.
2. `test_encoding.py` independently enumerates **1,491** cardinality-fixed subsets across N=5..11, k=2..4. Its direct Sidon/maximality oracle agrees with satisfaction of the canonical auxiliary CNF assignment for every subset, including **274** saturated instances. This is a bounded exhaustive check, not an external proof of the universal encoding theorem.
3. `solve_toy.py` translates the clauses to binary mixed-integer inequalities and asks SciPy/HiGHS to solve: N10 k3 SAT, with witness `{4,6,7}` confirmed by the direct oracle; N11 k3 UNSAT (all 165 three-mark sets were independently rejected by enumeration); N7 k4 SAT with witness `{1,3,6,7}`. The MILP reports are solver outputs, not DRAT/FRAT UNSAT certificates.
4. The **N184 k9 HiGHS feasibility run** used `time_limit=8` seconds and returned `Time limit reached; primal_status is None`; approximately 10 seconds total elapsed, peak RSS ~707MB. Thus **neither a witness nor UNSAT is established**. A production SAT engine with proof logging and/or a new structural reduction is required before claiming the finite nine-mark threshold.
5. As a separate #49 cross-audit, `audit_prefix49.py` rebuilds the matching/hyperedge cover formula from scratch, using NetworkX matching and brute-force deletion checking over modular groups. **3,526** finite insertion instances agree; the exceptional Z13 example D={0,1,3,9}, a=7 needs two deletions. This supports PR #62's *scoped* repair reduction; it supplies no #44/#329 asymptotic improvement.
6. As a separate PR #57 proof attack, `audit_lemnis57.py` checks every labeled simple five-vertex graph with degree sequence (3,3,2,2,2): **all 70 connected candidates have a C4**. It separately verifies seven-vertex gadget FhcYG has three degree-two ports, every port-pair internal path spectrum {2,3,4,5,6}, and lacks a C4. Ten literal K4 base replacements (including S empty and all) have cycle-length spectra exactly matching the stated transfer formula up to length 16. This independently validates the **mechanism and sampled instances**, not the claimed exhaustive 27-base/3.2-billion-subset exclusion, whose source list completeness and whole-search replay remain unreviewed.

## Reproduction

```sh
python3 build_sat.py --N 184 --k 9 --output sidon_N184_k9.cnf
python3 independent_oracle.py
python3 test_encoding.py
python3 solve_toy.py --N 10 --k 3 --seconds 20
python3 solve_toy.py --N 11 --k 3 --seconds 20
python3 solve_toy.py --N 184 --k 9 --seconds 8
python3 audit_prefix49.py
python3 audit_lemnis57.py
```

`build_sat.py`, `independent_oracle.py`, and `test_encoding.py` use the Python standard library. `solve_toy.py` needs SciPy/NumPy; the two secondary audits use NetworkX. No external SAT binary or internet is required to reproduce the source and bounded tests. The full N184 DIMACS bytes are included in the frozen ZIP; the GitHub source can regenerate them byte-for-byte.

**Research stop/next gate:** The local stochastic, one-point lift, and 2/3-swap operators already stalled in preceding #46 research. This turn makes the **exact global nine-mark** instance explicit, with an independently auditable equivalence proof. Continue through a serious SAT/CP-SAT solver that emits a checkable SAT witness or a verified UNSAT proof; if it times out, seek algebraic symmetry or covering lower bounds. A new paper or site headline is warranted only by a certified new extremal result, structural improvement, or independent proof contribution. For PR #57, the full 27-source-set audit and independent source-completeness check remain open.

## Sources and priority boundaries

- Erdős #156 (open, Ruzsa asymptotic bound): https://www.erdosproblems.com/156
- Huber (2026), eight-mark threshold and exact blocker lemma: https://oeis.org/A399118/a399118.pdf
- OEIS A382397, latest certified small intervals: https://oeis.org/A382397
- Lemnis PR #57 finite gadget exclusion: https://github.com/d3lefts/d3lefts/pull/57
- Axiom #49 matching repair: https://github.com/d3lefts/d3lefts/pull/62

**Novelty:** No new published-best finite set, asymptotic Sidon theorem, or global graph cycle theorem is claimed. The SAT encoding uses established Tseitin and sequential at-most-one constraints; its value is complete, reproducible problem formulation and precise negative/blocked-experiment accounting.