# RYEV / Global face-deficit gate for Q7 (self-assignment #99)

**Research owner:** Devin J. Wright. **Operator:** Ryev. **Scope:** established Q6 maximum imported; independent global Q7 necessary-condition operator, **no new extremal record**.

## Exact, globally valid mathematical statement

For a C4-free edge set G contained in Q7, write m=|E(G)|. For each coordinate i and side b in {0,1}, let F(i,b) be the number of selected edges entirely contained in that Q6 half-face. Let d(i) be the number of selected edges pointing in direction i.

The following equations follow from direct incidence counting:

    m = F(i,0) + F(i,1) + d(i),  for each i;
    sum_{i,b} F(i,b) = 6m;
    sum_{i,b} (132 - F(i,b)) = 1848 - 6m.

The established external theorem ex(Q6,C4)=132 (Harborth and Nienborg, 1994) bounds each half-face. Therefore m≤308 and d(i)≥m−264 in every coordinate, with equality conditions recorded exactly.

In particular, for **any hypothetical m≥305**:

- Every direction contributes at least 41 selected edges.
- The fourteen face deficits sum to at most 18 (exactly 18 at m=305).
- At least **five** of the fourteen Q6 faces have **131 or 132** selected edges. If only four were that large, at least ten faces would have deficit ≥2, forcing total deficit≥20.
- These five near-extremal faces occur in at least three distinct coordinate directions.

This is a seed-independent necessary condition and a useful face-first branching rule. It does **not** improve the known global 304≤ex(Q7,C4)≤308 bound. The double-counting and recurrence are elementary established mathematics, *not* a newly discovered theorem.

The same exact proof gives a hierarchy for all currently possible upper-end candidates:

| Hypothetical Q7 edges | Every directional count ≥ | Sum of Q6-face deficits | At least this many Q6 faces with ≥131 edges |
|---:|---:|---:|---:|
| 305 | 41 | 18 | 5 |
| 306 | 42 | 12 | 8 |
| 307 | 43 | 6 | 11 |
| 308 | 44 | 0 | 14 |

If a 308-edge C4-free graph exists, **all fourteen Q6 half-faces must be individually extremal (132 edges)** and all seven directions must contain exactly 44 edges. This is a valid global face-structure restriction, *not* an improvement to 308.

### Actual execution, October 29, 2026

[GitHub Actions exact face audit and bounded trial](https://github.com/d3lefts/d3lefts/actions/runs/40828770774) succeeded. The archived JSON audit verified all 180 frozen masks and found the following histogram of Q6 half-faces of size ≥131 among the **304-edge input seeds**: `{2:4, 3:5, 4:29, 5:57, 6:46, 7:19, 8:20}`. The independent compact spin seed has 304 edges, degree profile `4:32,5:96`, three extremal Q6 faces and total deficit 24. Source hash matched.

The face-first MILP held a full 132-edge Q6 face fixed and tested all remaining 256 binary edge variables for a 305-edge solution with 672 square, 14 Q6 and 84 Q5 restrictions. **Result:** 20.003-second HiGHS time limit; *no feasible incumbent and no checkable infeasibility proof*. This experiment supplies a different global search representation, **no new bound**.

## Independently implemented geometry and negative controls

`face_gate.py` constructs 128 vertices, 448 edges and 672 coordinate squares in **vertex-major** ordering, independently reconstructs the Q7 graph with a distinct common-neighbour C4 check, and decodes all 180 attributed seed masks from the original direction-major ordering. It checks the frozen source SHA-256 `2c4a0bfdcbac0d2751a6d2ab3b8b345cd6d4dd2febe437d63cadc2af960168a1`.

It also generates the earlier independent odd-square spin configuration `dca10a6bb6b6b45e6b80e5e55e366b1e` (304 edges), rejects a forged count-305 witness containing a C4, and rejects a deliberately false imported Q6 bound of 131.

Run from repository root:

    python3 research/nightfall/projects/erdos/q7-global-face-20261029/face_gate.py

## Assigned #48 / global face-first candidate experiment

`face_first_milp.py` fixes an explicitly counted 132-edge Q6 half-face of the independently constructed 304-edge spin witness. It leaves **256** Q7 edge variables free and enforces all **672** Q7 square constraints, all **14** Q6 half-face upper constraints at 132, and all **84** Q5 face upper constraints at the established exact value 56. It asks for **≥305 total selected edges**, with a 20-second execution cap.

Any potential 305 witness must pass the *independent integer-set C4 and face-bound checker* before it is reported. A time limit, solver dual status, or LP bound is explicitly **not** an UNSAT certificate. No 305 candidate was found in the initial 21-second local HiGHS feasibility run; the local result was a timeout with no incumbent and thus no improvement.

    python3 -m pip install scipy==1.14.1
    python3 research/nightfall/projects/erdos/q7-global-face-20261029/face_first_milp.py 20

## Relation to prior work and review gate

The 180 canonical solutions are attributed to Minamo Minamoto (2026), [upstream release](https://github.com/minamominamoto/c4free-hypercube). See [OEIS A245762](https://oeis.org/A245762) for the classic Q6=132 theorem and the 308 upper bound derived by the same face recurrence. Our prior PR #70 established a **catalogue-local** five-deletion exclusion for these 180 seeds; this operator is different because it is valid **globally** for any prospective Q7 solution, without knowing a 304-edge seed.

**Review needed:** Axiom verify the independent face/index conventions; Lemnis challenge use of the imported Q6 bound and all-function quantifiers; Vesper verify historical priority, site and scientific scope. No automatic theorem-status change or website publication.

**Stop rule:** report one bounded face-first feasibility attempt and its full solver status. If no certified 305 appears, switch to a global proof-producing SAT/ILP architecture that can create independently checkable refutation traces rather than optimizing a fixed 304-edge seed again.
