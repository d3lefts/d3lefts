# External-review packet: frozen 30-integer Sidon witness

**Dossier version:** 2026-10-31, v1. **Review gate:** OPEN — no unaffiliated human has signed a verdict for this packet. **Public source of truth:** [sidon-finite-30](./README.md), including the witness and published verification methods.

## 1. Review the exact claim, not the publicity

Let `A` be the **30 distinct integers** in [witness_30.txt](./witness_30.txt), whose exact bytes have SHA-256

`dc4697ce051a57987049199965967cc2b981433816d3daac284454262395978f`.

Define a *Sidon subset* `S ⊆ A` by requiring all sums `x+y` with `x,y ∈ S` and `x ≤ y` to be distinct. Let `h(A)` be the maximum cardinality of such a subset. Define a *(4,5)-set* by requiring that any four distinct elements generate at least five distinct positive pairwise differences.

**Claim to challenge:** `A` is a (4,5)-set and `h(A)=17`. In particular, the frozen finite construction satisfies `h(A)/|A|=17/30<4/7`. No assertion is made here about global optimality among all 30-point sets, the optimal asymptotic constant, or historical priority.

**Evidence split:** an explicit 17-element Sidon subset proves `h(A)≥17`; an exhaustive *nonexistence* check for 18-element subsets proves `h(A)≤17`, because every Sidon set larger than 18 contains an 18-element Sidon set. The (4,5) condition is logically separate.

## 2. Two different internal computations

| Route | Program | Critical method | Scope |
|---|---|---|---|
| A | [verify_sidon30_standalone.py](./verify_sidon30_standalone.py) | Enumerate 28 three-term arithmetic-progression edges; refute 12-deletion hitting sets using exact branching and a disjoint-edge bound | Internal published exact replay |
| B | [verify_sidon30_direct_sums.py](./verify_sidon30_direct_sums.py) | Lexicographically enumerate direct unordered pair-sum-compatible subsets, stopping at an explicit sum collision; exhaust the size-18 search | Different internal verification route, added 2026-10-31 |

Route B does **not** call, import, copy, or rely on the AP hitting-set search; both implementations still inspect the **same input** and were produced within the NIGHTFALL AI-assisted workflow. Route B was not created under a blinded, independent human preregistration. Repeating a fixed hash is an *identity test*, not a proof of correctness.

Reproduce after pinning a full Git commit SHA:

```sh
git clone https://github.com/d3lefts/d3lefts.git
cd d3lefts
git checkout <full-commit-SHA>
sha256sum research/nightfall/projects/sidon-finite-30/witness_30.txt
python3 research/nightfall/projects/sidon-finite-30/verify_sidon30_standalone.py
python3 research/nightfall/projects/sidon-finite-30/verify_sidon30_direct_sums.py
```

Both scripts use only Python's standard library. On the initial local Route B replay, the finite input passed all 27,405 four-point tests, a 17-element Sidon subset was constructed, and the size-18 exhaustive direct pair-sum search visited **1,583,759 recursive nodes** without finding a counterexample. These are **local/internal observations**, not a signed external receipt; re-run at the pinned commit and record the returned output and code hash independently.

### Completeness condition for Route B

The depth-first enumeration visits increasing index sequences. At each candidate addition `v`, it forms sums `v+u` for all prior selected `u` and `2v`. If any new sum repeats another new sum or an earlier unordered pair sum, that branch can never extend to a Sidon subset. If there are too few remaining positions to reach 18, the branch cannot succeed. All other extensions are tried, so absence of a size-18 result is a finite exhaustive conclusion *provided this control flow is implemented correctly*. A human audit must examine that completeness argument and its implementation, not just observe a PASS line.

## 3. Specific independent tasks

1. **Input identity and mathematical definitions:** recover all 30 integers, audit the sign of the differences, and compare the program's Sidon definition to the cited prior art.
2. **Independent check:** without copying either published algorithm, reimplement the four-point (4,5) test and the `h(A)≤17` exclusion using a logically defensible route (SAT/ILP with a proof certificate, exact cover, a third exhaustive algorithm, or a hand-auditable certificate).
3. **Adversarial controls:** corrupt a coordinate, tamper with a proposed 17-subset, test a toy instance with an explicit repeated diagonal sum, and confirm the checker rejects the defective witness or condition.
4. **Status and novelty:** distinguish finite claim validity from the literature's global and asymptotic bounds; report any matching previously published 30-point example or broader mechanism.
5. **Provenance:** record pinned commit, file hashes, commands, runtime/platform, code used, and a counterexample or exact independent proof artifact.

## 4. Blank external review verdict — not filled in by an AI assistant

- **Reviewer name / affiliation (optional):** _Unassigned_
- **Date and pinned commit:** _Pending_
- **Input hash independently recomputed:** _Pending_
- **Third-party checker repository / hash:** _Pending_
- **Review of (4,5) property:** _PASS / FAIL / INCONCLUSIVE_
- **Review of explicit 17-subset:** _PASS / FAIL / INCONCLUSIVE_
- **Review of no 18-subset / proof completeness:** _PASS / FAIL / INCONCLUSIVE_
- **Historical priority / novelty:** _Not reviewed / Reviewed; conclusion and sources_
- **Scope and limitations:** _Pending_
- **Reproduction commands and output attachments:** _Pending_
- **Signed verdict, if supplied:** _None_

A reproduced program PASS **does not** fill the human-review field. No AI persona or another instance of the same system may be recorded as an unaffiliated human referee.

## 5. Closest established external background

Jie Ma and Quanyu Tang, [*Largest Sidon subsets in weak Sidon sets*](https://arxiv.org/abs/2602.23282), 2026, study Sidon subsets, (4,5)-sets, and the bounds `9/17≤c*≤4/7`. Their theorem, not this finite construction, supplies the published broader context. The NIGHTFALL dossier separately attributes the earlier 5/9 reader construction. **The global originality of this specific 30-point configuration has not been independently established.**

For questions or counterexamples, open a GitHub issue in [the public repository](https://github.com/d3lefts/d3lefts/issues/new/choose), linking this file and the pinned commit. Invite criticism; do not imply someone has accepted an assignment until they explicitly do.
