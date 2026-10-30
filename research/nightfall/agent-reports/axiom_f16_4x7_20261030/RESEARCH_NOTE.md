# AXIOM / F16 full-subfield cubic phase compression — exact two-query obstruction

**Checkpoint:** 2026-10-30. **Vesper assignment:** [#249](https://github.com/d3lefts/d3lefts/issues/249); umbrella [#248](https://github.com/d3lefts/d3lefts/issues/248). **Source 3×5 gadget:** draft [PR #243](https://github.com/d3lefts/d3lefts/pull/243) (its claims remain under [#247](https://github.com/d3lefts/d3lefts/issues/247) independent audit). **Research status:** R1 / internally exact exhaustive restricted obstruction and failed 4×7 candidate; no world-priority, new global theorem, k7 optimality or public site promotion.

## Objective, oracle, and exact input model

K = F₂[z]/(z⁴+z+1) = F₁₆, L = F₄, H=L×={1,6,7}, f(z)=z³. An anchored phase input is `(1,η₁,…,η_b)` with every ηᵢ∈H. Each measurement is `f(a·v)` for an arbitrary K-row a, with no restrictions on coefficients. These are the **full-subfield powered oracle and all 0/nonnull outputs**, without support known free or extra feedback.

The desired, still **OPEN**, result is a 4×7 matrix separating 3⁶=729 anchored words using four cubes. Such a certified code would produce an 11-query, k=7 full-support recovery step conditional on the global transfer proof, matching the counting lower bound. The previously recorded failed heuristic checkpoint was **174 colliding unordered pairs**.

## New finite no-go: two cubes cannot separate three anchored relative phases

**Theorem (finite complete search with independent exact implementations).** For **every** pair of arbitrary F₁₆ coefficient rows a,b∈K⁴, the map

`(η₁,η₂,η₃) ↦ ((a·(1,η₁,η₂,η₃))³,(b·(1,η₁,η₂,η₃))³)`

has at least **four colliding unordered pairs** among its 27 distinct inputs. This bound **4 is attained** by a=(0,1,2,3), b=(1,2,3,9). Consequently, no two-query gadget for three relative phases exists in the stated nonadaptive anchored K-linear powered setting, and no **separable 3+3** combination of two such gadgets can produce an injective four-query / six-phase code. The result says **nothing** about more general coupled 4×7 codes.

**Exact exhaustive reduction/proof.** If c∈K×, the powered output for a scaled row ca is `(c(a·v))³=c³(a·v)³`. Multiplication by c³ is a bijection on the cube outputs, so it preserves **the entire pairwise equality relation**. Every nonzero row is therefore equivalent, for collision purposes, to the unique row whose **first nonzero coefficient equals one**. Of the 16⁴−1 nonzero rows this leaves `(16⁴−1)/15=4,369` representatives. If a row is zero, pairing it with any other row can only distinguish inputs as well as a single row; the exhaustive single-row minimum is 51 collisions, strictly larger than four. Thus normalized nonzero rows suffice.

Enumerate the 27 input vectors in lexicographic order on (1,6,7)³. Give every unordered pair a unique index 0..350. Associate each canonical coefficient row with its **351-bit collision mask**: a bit is on exactly when that row gives the same cube output on the indexed input pair. The pair `(a,b)` has exactly popcount(mask(a) & mask(b)) collisions. Check all `4,369×4,370/2 = 9,546,265` unordered pairs of representatives. **Minimum = four**, with the explicit pair above. No probabilistic approximation, 4×7 generality assumption, SAT timeout, floating-point tolerance, or unsound normalization is involved.

**Independent replay:** [audit_two_query.cpp](audit_two_query.cpp) computes GF16 products using polynomial convolution, stores 6×64-bit collision words, and exhausts the row pair space. [audit_two_query.py](audit_two_query.py) implements field multiplication by shift/reduction and stores collision masks as Python arbitrary-precision integers. Both implementations independently report 4,369 normal rows, 9,546,265 pairs, min single-row 51 and min pair 4; the Python negative control explicitly detects four collisions in the best pair. Dedicated CI compiles C++17 and runs both.

## Coupled 4×7 trial: improvement within failures, still invalid

A bounded deterministic-seed (17030) simulated-annealing experiment with 1,200,000 one-coefficient proposals across 24 fresh starts reduced the prior **invalid** 174-pair checkpoint to **163 exact colliding unordered pairs**. This is an **11-pair reduction in a failure metric**, not a valid solution or competitive mathematical record. The coefficient matrix (four rows, seven entries including anchored column) is:

```
0, 8,15,4, 0,15, 1
12,10,5,8,12,14,12
5, 6,14,0, 6,15,10
6, 5, 1,1, 4, 0, 6
```

The [full 729-line source table](F16_4x7_invalid_163.csv) is pinned by exact SHA-256 `472fc358afd0e9477c493dc47c75bbb6aecce79f09df2f7851d625ae22fd8397`. [verify_trial_and_source.py](verify_trial_and_source.py) independently checks all 729 F₁₆ input/output rows with another field multiplication implementation, confirms exactly **579 distinct codewords**, output multiplicities **442 singleton, 124 doubleton, 13 tripleton**, hence `124+3·13=163` collision pairs, and requires a genuine collision and a stale-hash tamper negative control. It also reconstructs PR #243's existing 3×5 matrix and confirms its original **81 distinct words**. Three input states could share an output: the maximal observed class size is three.

The C++ stochastic-search code/seed was locally executed, yet the **search trajectory was not independently reproduced**; only the pinned matrix and full code table have separate exact replay. Treat search provenance as partial. No random-search nonexistence claim is authorized.

## Next structural transition and falsifier

The complete two-query subgadget obstruction prevents any clean 3+3 block tensoring. A future 4×7 candidate must **couple** variables across the four rows, or rely on a different algebraic representation. Suggested next mechanism: formulate explicit finite-field projective-pencils and their pairwise collision hypergraph, then use SAT/SMT / exact cover with symmetry-preserving normalization and independent conflict checking. The decisive favorable test is a zero-collision 729-word table; the decisive negative test is a full-orbit (not just separable block) proof certificate showing no 4×7 exists. **Stop** stochastic hillclimbing at this checkpoint unless a mechanism change predicts a qualitative gain; another 5–10 failed-pair improvement is not sufficient.

## Sources, roles, certification and limits

- Primary mathematical baseline: NIGHTFALL [PR #243](https://github.com/d3lefts/d3lefts/pull/243) and Vesper [#248](https://github.com/d3lefts/d3lefts/issues/248). Same powered oracle and H quotient throughout.
- Contextual prior-art descriptions checked 2026-10-30: Charikar–Wu–Ye, *Adaptive Discrete Phase Retrieval*, SOSA 2020, studies a different complex/bit-precision oracle; Bartusel–Führ–Oussa, *Phase retrieval for affine groups over prime fields*, Linear Algebra Appl. 2023, uses complex group-frame measurements, also different. A same-model literature and finite-geometry code search remains **open**. Neither source proves novelty of this restricted obstruction.
- **Axiom:** constructed exact exhaustive restricted no-go, wrote two separately structured finite checkers, produced a failed coupled candidate. **Vesper:** assignment, source baseline, and earlier failed heuristic; **Lemnis:** independent mathematical attack requested; **Ryev:** separate arithmetic/checker and Lean obligations requested; **Devin J. Wright:** research direction and authority over publication.
- **Certificate:** exact source hashes + GitHub CI stdout, full trial-table SHA, explicit failure example, and the row-normalization argument above. Two programming implementations by the same AI session count as algorithmic cross-checks, **not independent human peer review**.
- **Status:** verified internal finite exhaustive obstruction; general four-query/six-phase existence unresolved; numerical 4×7 trial rejected; worldwide originality unresolved; no production/paper promotion.

### Reproduce

```sh
python3 research/nightfall/agent-reports/axiom_f16_4x7_20261030/audit_two_query.py
g++ -std=c++17 -O3 -Wall -Wextra -o /tmp/axiom_f16_rows research/nightfall/agent-reports/axiom_f16_4x7_20261030/audit_two_query.cpp
/tmp/axiom_f16_rows
python3 research/nightfall/agent-reports/axiom_f16_4x7_20261030/verify_trial_and_source.py
sha256sum research/nightfall/agent-reports/axiom_f16_4x7_20261030/F16_4x7_invalid_163.csv
```
