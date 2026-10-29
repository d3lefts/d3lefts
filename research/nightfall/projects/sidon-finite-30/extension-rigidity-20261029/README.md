# NIGHTFALL: one- and two-point extension rigidity of the 30-point Sidon witness

**Research date:** 2026-10-29  
**Research owner:** Devin J. Wright / NIGHTFALL PHASESHIFT  
**Status:** Exact finite, internally independently replayed; mathematical novelty and external specialist review pending.  
**Subject:** Erdős (4,5)-set / Sidon subset problem (often catalogued as #757); **this is separate from Erdős #156**, which asks about maximal Sidon subsets of integer intervals.

## The result

Let `B` denote exactly the sorted 30-integer set in [`witness_30.txt`](witness_30.txt), SHA-256 `dc4697ce051a57987049199965967cc2b981433816d3daac284454262395978f`. Its (4,5) property and Sidon number `h(B)=17` have an earlier published exact finite checker.

**Theorem (specific-witness, universal integer extension rigidity).** For *every* integer `x∉B`, if `B∪{x}` is a (4,5)-set, then

`h(B∪{x}) = 18`.

For *every* pair of distinct integers `x,y∉B`, if `B∪{x,y}` is a (4,5)-set, then

`h(B∪{x,y}) = 19`.

Thus any attempt to improve the ratio `h(A)/|A|` by simply adjoining one or two integer points to **this particular** 30-point construction cannot work. These statements have *unbounded* integer quantifiers; their verification reduces those quantifiers to finite, exact cases with a complete affine case split. They do **not** say all 30-point constructions have this property, exclude replacement of old points, prove a new global bound, or improve the known asymptotic `5/9` upper construction.

## Why the infinite integer search reduces to finite checks

Let `H` be the 3-uniform hypergraph whose edges are the 3-term arithmetic progressions of `B`. Because every four-point subset of `B` has at least five different positive distances, any additive collision within a (4,5) superextension involves a repeated mark, hence corresponds to a 3-term progression. A Sidon subset is exactly an independent set of this progression hypergraph.

The 30-point set has exactly 28 progression edges, and exhaustive arithmetic shows its minimum progression transversal is 13, hence `h(B)=17`.

For a new mark `x`, an old-old-new progression occurs only for

`x = 2a-b`, `x = 2b-a`, or `x=(a+b)/2` (the last expression integral), with distinct `a,b∈B`.

This yields **1,132** distinct candidates outside `B`. Adding `x` violates the four-point condition iff `x=b+c-a` for three distinct marks `a,b,c∈B`. **827** of the 1,132 are ruled out this way. Every one of the remaining **305** creates exactly one old-old-new progression. Other integers create none.

For two marks `x,y`, any *additional* progression must have the form `x+y=2b`, `2x-y=b`, or `2y-x=b` for some `b∈B`. Their joint (4,5) admissibility is exactly the pair of extra checks that `x+y` is absent from old distinct-pair sums and `|x-y|` is absent from old positive differences, in addition to individual admissibility.

The only potentially obstructing cases are exhaustive:

1. Both `x,y` individually create old-old-new progressions: **44,255** admissible pairs.
2. Exactly one does, and the pair participates in at least one new-new-old progression: **7,174** admissible pairs.
3. Neither does, and the pair participates in at least two new-new-old progressions: **23** admissible pairs. Two such equations have distinct types, so their affine intersections are generated directly from pairs of old integers.

All remaining cases are either unconstrained, have just one old-old-new progression, or have just one new-new-old progression. These are discharged by the same explicit portfolio's singleton checks.

## Compact witness certificate

[`portfolio_certificate.json`](portfolio_certificate.json) contains **11 explicit old 17-point Sidon subsets** `S_1,…,S_11 ⊆ B`. The verifier independently checks every pair sum (including doubled marks), then checks that **every admissible exception above** has at least one `i` for which both new marks can be appended while preserving the Sidon property. It likewise checks every one-point case and all 30 generic single-old-mark exclusions.

For each admissible one- or two-point extension there is therefore an explicit Sidon subset containing all new points of size `18` or `19`. The reverse inequalities are immediate by deleting the new points from any Sidon subset and using `h(B)=17`. This completes the proof.

## Exact independent reproduction

Only Python 3 standard library is required. From this directory:

```sh
python3 verify_independent.py
```

Expected status: `PASS — bounded exact theorem`; source SHA-256 above; portfolio SHA-256 `fd0fc220e4b2ef5e458c5a5ef21a0baacb2cfdb226b14b503959b3c1a4dd782a`. The independent checker re-enumerates all 27,405 four-mark tests, the 28 original progression constraints, the entire 12-deletion proof search (7,801 states), the affine exception families and the 11-set portfolio, with three adversarial mutation checks. It imports **no exploratory builder, optimizer, Numba dependency, reference verifier, or precomputed solver verdict**. Average run on the research container: approximately 3 seconds.

To replay the preexisting baseline independently in the source repository:

```sh
python3 research/nightfall/projects/sidon-finite-30/verify_sidon30_standalone.py
```

See [`validation_receipt.json`](validation_receipt.json) for exact counts and digests. The source and verifier are attached to a new research pull request and **should remain a draft** until a separate reviewer examines the exhaustive case split, the independence boundary, and comparison with existing literature. The results should be catalogued as a *specific-witness structural obstruction*, never promoted to a new world record or an additional homepage Original Finding without dated priority review.

## Research-tool process validation

- **Orchestrator:** freeze the exact `B` source hash and theorem scope; separate construction, reproduction, adversarial, formalization, integration lanes; see `orchestrator_contract.json`.
- **Discovery Engine:** the tested operators were direct one-point insertion and two-point insertion. The first target—retaining Sidon number `17` at 31 points—failed; instead of increasing search intensity, the representation changed to a finite algebraic exception classifier and an eleven-witness portfolio.
- **Referee / exact arithmetic:** the preexisting independent B30 arithmetic and the new standalone full-integer checker establish bounded finite facts; neither tool supplies outside mathematical peer review.
- **Claim Lab / Evidence Bridge:** the signed-scope status and hashes are represented in the portable `validation_receipt.json`. Importing a record into a browser ledger must never promote mathematical status. This research file does not claim to have operated a remote agent, passed a reviewer's credentials, or produced a trusted cryptographic signature.
- **Adversary:** deliberately invalid arithmetic progressions and a corrupted Sidon subset are rejected by the checker.

**Falsification target:** produce an integer `x` (or distinct `x,y`) such that the enlarged set is (4,5) and has `h` less than `18` (respectively `19`); alternatively exhibit an omitted affine exception class, a false portfolio subset, or an incorrect 12-cover exclusion.

## Prior art and attribution

- Jie Ma and Quanyu Tang, *Largest Sidon subsets in weak Sidon sets*, arXiv:2602.23282 (2026). These authors established the earlier `4/7` upper bound for the asymptotic (4,5)-set constant.
- The anonymously submitted self-similar `5/9` construction (October 17–19, 2026) has priority for that asymptotic bound; its base set `O`, affine map, and all-depth mechanism are fully credited by NIGHTFALL's original `sidon-finite-30/README.md`.
- NIGHTFALL's October 24 distinct finite 30-point endpoint construction and October 28 exact 28-edge criticality certificate supply the fixed source witness used here.
- This research note reports a new **internally derived finite structural statement** about that exact witness. Comprehensive mathematical novelty review is incomplete. A direct search of the named literature found no prior statement of this particular one-/two-point rigidity, which is insufficient for priority certification.