# External-review packet: frozen 30-integer Sidon witness

**Dossier version:** 2026-10-31, v2 (provenance and prior-art audit). **Review gate:** OPEN — no unaffiliated human has signed a verdict for this packet. **Public source of truth:** [sidon-finite-30](./README.md), including the witness and published verification methods.

## 0. Dated external priority and exact derivation

**October 31, 2026 targeted source audit.** [Ma and Tang's arXiv v2](https://arxiv.org/html/2602.23282v2) proves the existence of the limit for Erdős's (4,5)-set constant and shows that each finite example gives an upper bound. Their stated result was `9/17 ≤ c* ≤ 4/7`. An [anonymous October 17 reader submission 7bkzb8](https://www.erdosproblemaday.com/submission/7bkzb8) used the seed `O={0,49,75,83,98,101,117,119,121,159,269}` and map `φ(x)=101+18x/269` to propose and computationally support a **stronger** asymptotic `c*≤5/9`; its [October 19 writeup](https://www.erdosproblemaday.com/day/757-reader-five-ninths-refereed) discloses AI-assisted review rather than community-accepted human peer review.

The NIGHTFALL witness is **exactly** the reader's depth-two union `S₂=O∪φ(O)∪φ²(O)`, augmented by `{-269}`, and scaled by `269²=72361`:

```
A = sorted(269² × (O ∪ φ(O) ∪ φ²(O) ∪ {-269}))
```

The deterministic standard-library checker [verify_reader_origin.py](./verify_reader_origin.py) independently reconstructs this **identity** with rational fractions and compares every resulting integer to the frozen witness; it is not independent evidence of priority. The original reader family has `|S₂|=29`, `h(S₂)=17`; the added endpoint yields `|A|=30`, `h(A)=17`. The arithmetical ordering is

```
5/9 < 17/30 < 4/7.
```

**Attribution:** The 11-point seed, self-similar map and `5/9` mechanism belong to the earlier anonymous submitter. NIGHTFALL's additions comprise the explicit extra endpoint and its finite proof checks, plus a separately described 28-edge criticality calculation. No new global best bound is claimed, and neither the endpoint construction's historical originality nor the hypergraph lemma's novelty has been independently established. The publicly accessible reader submission is a documented prior source, not a claim of independent community acceptance.

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
python3 research/nightfall/projects/sidon-finite-30/verify_reader_origin.py
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

## 5. Strongest accessible external reference and next review choice

- **Ma–Tang, arXiv v2, March 6, 2026**: [theorem 1.5](https://arxiv.org/html/2602.23282v2) establishes `c*=inf_n f(n)/n` and theorem 1.6 gives `9/17≤c*≤4/7`.
- **Anonymous reader submission 7bkzb8, October 17, 2026**: [the source statement](https://www.erdosproblemaday.com/submission/7bkzb8) and [October 19 AI-assisted review](https://www.erdosproblemaday.com/day/757-reader-five-ninths-refereed) report `c*≤5/9` via exactly the seed and affine map used here. Its human mathematical peer-review status is not established by that source.
- **NIGHTFALL, October 24 onward**: one additional endpoint to depth two, a fixed-size certificate, separately executable algorithms and a 28-edge-critical progression hypergraph. These are **not** claimed to supersede the reader's asymptotic construction.

**Reviewer priority:** Establish validity and independent reproducibility of the frozen finite claim first. If interested in the most distinctive finite structural subclaim, separately audit `τ(H)=13` and `τ(H-e)=12` for all 28 progression edges; see [edge_essentiality.py](./edge_essentiality.py) and [its certificate](./edge_essentiality_certificate.json). Do not conflate correctness of this arithmetic example, its hypergraph-criticality property, and historical novelty.

For questions or counterexamples, open a GitHub issue in [the public repository](https://github.com/d3lefts/d3lefts/issues/new/choose), linking this file and the pinned commit. Invite criticism; do not imply someone has accepted an assignment until they explicitly do.
