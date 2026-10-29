# VESPER — exact 5-coordinate-first obstruction, F25 fourth-power sensing

**Date:** 2026-10-29 UTC. **Research lead:** Devin J. Wright. **Proof discovery / verifier implementations:** Vesper (GPT-6). **Parent theorem:** Axiom's two-round adaptive `<=2k-1` decoder, PR #37. **Status:** internally certified finite exhaustion under stated sensing architecture; same-model publication priority and external human refereeing OPEN.

## Research contract (frozen at experiment)

**Objective.** Decide whether Axiom's k=5 protocol can be reduced from nine to eight fourth-power readings by taking the five coordinate fourth powers first and using only three further adaptive F25-linear readings. This is an architecture-specific question, not the general minimum for all 8-query adaptive protocols.

**Feasible set.** All signals in `F25^5`, equivalence by global multiplication with `F5*`; each measurement is `(a dot x)^4` with arbitrary `a in F25^5`, and the last three coefficient rows may depend on earlier powered observations. After five coordinate readings, consider the full-support branch `x_i != 0` for all i. Using arbitrary chosen fourth roots of the coordinate readings, reduce to the 256 projective phase vectors `(1,z1,z2,z3,z4)` with `z_i in F5*`.

**Baseline.** Axiom's adaptive nine-reading reconstruction for k=5, `m(x)=k+max(|supp x|-1,0)`. The coarse seven-symbol decision-tree lower bound is eight for k=5: there are `1+(25^5-1)/4=2,441,407` signal classes. The precise gap is eight versus nine for unrestricted adaptive designs; the restricted coordinate-first route is attacked here.

**New result criterion.** An exact exclusion of all three-query adaptive phase decision trees after coordinate sensing, using a finite symmetry-reduced complete witness and two independent arithmetic implementations. An improved eight-query algorithm would also count if a complete exact decoder checked all 256 phase states. Operator families: projective symmetry reduction, bounded decision-tree branch attack, incidence/collinearity obstruction, and independent exact replay. We halt the coordinate-first family upon exhaustive elimination, transferring the broader question to general interleaved sensing.

## Theorem — exact coordinate-first limit

Over `F25 = F5[u]/(u^2-2)`, any adaptive protocol that first queries the five individual coordinate fourth powers requires **at least four additional fourth-power linear measurements in the worst case** to recover *all* signals in `F25^5 / F5*`. Thus Axiom's nine-query construction is optimal **within the coordinate-first architecture**.

No assertion is made that nine is the unrestricted optimal adaptive count. The unrestricted eight-reading question remains OPEN.

## Proof structure

1. **Phase reduction.** Once five nonzero coordinate fourth powers are known, choose one fourth root `alpha_i` of each. The hidden signal has the form `x_i=alpha_i z_i`, with `z_i in F5*`, unique modulo simultaneous multiplication by `F5*`. Every additional F25-linear powered reading becomes `(sum b_i z_i)^4` for arbitrary `b_i in F25`. Normalize the global phase to `z_0=1`, giving 4^4=256 possible hidden phase vectors. A three-reading phase decoder must separate all 256 under every adaptive branch.

2. **First query symmetry: 19 classes.** As an F5-vector space, F25 has dimension two. A fourth-power value encodes exactly which of the six F5-projective directions contains a nonzero linear form, plus the special zero symbol. Each coefficient `b_i` is therefore one of six projective directions, plus zero, for purposes of partitioning the phase torus. Permuting the five coordinates, multiplying any coordinate by `F5*`, and applying any invertible F5-linear map to all five coefficient vectors preserve the phase-identification decision-tree problem: the last operation merely permutes the seven output symbols. `PGL_2(F5)` has 120 projective transformations on the six directions. Its action on the 462 multisets of five directions/zeros has precisely **19 orbits**, exhaustively enumerated by the C++ verifier. This reduction includes every possible first powered-linear query.

3. **First-branch counting.** Thirteen of the 19 classes have a first-query output bucket containing at least 50 possible phase states. There are only two readings left, which offer at most `7^2=49` transcripts, so these 13 classes fail immediately.

4. **Second-query enumeration.** For each of the six residual classes, fix one adversarial first-output bucket of sizes 43, 48, 41, 41, 44, 48, respectively. Any second row can be multiplied by an arbitrary F25* scalar without changing its answer partition; normalize the first nonzero coefficient to 1. This yields exactly `(25^5-1)/24=406,901` distinct normalized row options. Every one is checked. If any second answer bucket has at least eight candidate phase states, the final seven-symbol reading cannot distinguish them.

5. **Seven-point projective-incidence obstruction.** A seven-state second bucket can be separated by a final reading only if the seven outputs are all seven distinct possibilities. Thus exactly one candidate `p` must give powered output zero; the other six must occupy the six different nonzero projective directions. If `p,q,r` are collinear over F5, then any F5-linear map vanishing at `p` maps `q,r` onto the same projective direction. Hence the necessary condition for a seven-state bucket is: **some candidate p has six distinct projective directions towards the other six candidates.** The verifier checks this necessary condition exactly. In each of the six first-query classes, every normalized second row either leaves an eight-state bucket or a seven-state bucket that fails the incidence test.

## Exact counts (each C++ and Python replay)

| First-row multiset orbit (slope labels; 6=zero) | Adversarial first-output fiber | Second rows with all answer buckets <=7 | Of these, obstructed by seven-point collinearity | Unexcluded |
|---|---:|---:|---:|---:|
| `00112` | 43 | 18,000 | 18,000 | **0** |
| `00116` | 48 | 0 | 0 | **0** |
| `00123` | 41 | 9,000 | 9,000 | **0** |
| `01234` | 41 | 9,000 | 9,000 | **0** |
| `01236` | 44 | 0 | 0 | **0** |
| `01266` | 48 | 0 | 0 | **0** |

**Note:** The count for `00123` depends on choosing an adversarial *41-point* first-output branch (symbol `2` in these implementations). Several 42-point branches admit some second rows without this particular collinearity obstruction; that does not rescue the decoder because it must work on the 41-point branch too. This distinction was discovered by an initial attempted constructive search, then corrected explicitly.

## Independent validation and attack

- **Engine A:** Python/NumPy with exact modular F5 arithmetic and vectorized enumeration of all normalized second rows and all six decisive first branches.
- **Engine B:** independently implemented ISO C++17, direct F25 field arithmetic, fresh construction of `PGL_2(F5)` (120 transformations), 462 slope multisets, 19 orbits, 406,901 normalized second rows, and exact affine-collinearity tests; no shared code path.
- **Negative control:** replace the seven-point collinearity rejection with `return false`. The C++ audit then fails its final assertion with nonzero exit status 134. This confirms the verdict depends on the geometric obstruction rather than counting alone.
- **Exactness:** no rounding, sampling, probability, floating-point tolerance, or discretization; all operations are finite integers mod five. The full finite enumeration is small enough for independent reproduction.
- **C++ source SHA-256:** `037cb0d787f8a9ecd2adc782a3f9767504127bedf52850d1b2c201aaaab695f3`.
- **Python source SHA-256:** `bd80148a6059a88d5593c38078c269481241cef40675779c05f2c7e7ea7d23b0`.
- **C++ exact run log SHA-256:** `2338a505ed0bde679f139b6af8b86b890a4b5054cd58fb0c7d65567270fbea51`.

### Replay commands

```bash
g++ -O3 -std=c++17 -Wall -Wextra f25_k5_coordinate_first_independent.cpp -o /tmp/f25_k5_audit
/tmp/f25_k5_audit
OPENBLAS_NUM_THREADS=1 python3 f25_k5_orbit_obstruction.py
```

Both must report six hard classes fully eliminated with zero remaining unexcluded second rows. Mutation test is archived in the investigation log; the shipped canonical C++ verifier is unmutated.

## Interpretation and handoff

This closes the first, cheapest path to eight queries: coordinate powers followed by three adaptive mixing queries. It **does not** exclude an interleaved or structurally different eight-query protocol, which may extract phase information before all magnitudes are measured. Axiom's next appropriate experiment is a preregistered search over *interleaved* designs, with an exact verifier of every branch and a same-sensing-law literature review. Lemnis should independently audit the PGL2 symmetry and seven-point-incidence reasoning before any stronger scientific label. Same-model historical priority remains unestablished. No scientific publication claim follows from the internal exhaustions alone.