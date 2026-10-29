# NIGHTFALL Referee — exact finite verification instrument

**Site:** https://d3lefts.github.io/d3lefts/referee.html

**Version:** 1.0.0, 28 October 2026. **Classification:** interactive research software / exact finite checks. It is **not** an external mathematical referee, global proof engine, novel theorem, or independent audit of unpublished archives.

Referee takes a finite mathematical object, validates its input contract, recomputes its result by separately written exact-arithmetic paths, probes deterministic negative controls, and exports a SHA-256-fingerprinted JSON receipt. It is local-first and requires no server for calculations.

## Domain 1 — Erdős continuous step overlap

Accepts 2 to 256 integer cell heights A_i with denominator D, each 0 <= A_i <= D, over **[0,2]**. Enforces the unit-mass condition 2*sum(A_i)=n*D. For every signed lag -(n-1) <= k <= n-1, evaluates the exact integer quantity

    C(k) = sum_{0 <= i < n, 0 <= i-k < n} A_i * (D - A_{i-k})

and returns the exact rational maximum 2 * max_k C(k) / (n * D^2). Zero extension and breakpoint extremality establish that testing these lags suffices for the continuous-shift maximum of the specified step functions. Note the direction convention i-k, not i+k.

- Path A: iterate lags, then intersecting cells.
- Path B: iterate cell pairs and accumulate by difference.
- Reject malformed inputs, false mass normalization, incorrect claimed exact score and any cross-path discrepancy.
- Negative controls: tamper the claimed score; find a one-unit, mass-preserving height transfer that changes the maximum and reject the original pinned score. An unsuccessful search is **inconclusive**.
- **Scope boundary:** The demo fixture contains 16 cells. The genuine 131,072-cell archived NIGHTFALL witness is **not** embedded and remains pending a complete external replay and public binary-mirror check.

The previously shipped Discovery Engine uses a **finite cyclic overlap proxy** for its toy optimizer. Referee implements a **zero-extended signed continuous step-overlap** model; these models must never be compared as equivalent.

## Domain 2 — finite weak Sidon (4,5)

The public [30-point witness](../projects/sidon-finite-30/witness_30.txt) and the 17-member subset from its standalone checker are preloaded.

- Path A examines all quadruples and checks at least five distinct positive pairwise differences.
- Path B independently checks the absence of a four-distinct additive collision via pair sums.
- Checks all 17*18/2 = 153 unordered pair sums of the proposed Sidon subset.
- Enumerates three-term arithmetic progressions and proves no Sidon subset of size 18 exists by exact memoized branching on deleted points, with disjoint-progression packing as a sound lower bound.
- Pinned fixture target: 27,405 quadruples, 28 progressions, 7,801 proof states and h(B)=17.
- If the search reaches its state cap, it returns **INCONCLUSIVE**.
- Negative controls: falsified upper bound and foreign-coordinate subset are rejected.

**Scope boundary:** This only proves a particular finite Sidon maximum within the weak-Sidon premise, itself checked on the same input. It gives no new asymptotic 5/9 result or external priority verdict. This browser implementation is distinct from the already published Python verifier and frozen DAG.

## Replay and continuous integration

Run from repository root:

    node research/nightfall/referee/test.cjs
    node research/nightfall/referee/check_receipt.cjs /path/to/exported-receipt.json

The CLI replays the exact input, verified arithmetic, negative controls, and SHA-256 digest, and compares them against the reported results. A forged result, digest or verdict is rejected with a nonzero exit code. CLI replay uses the *same core implementation* as the browser: it is reproducibility, **not** independent outside verification.

GitHub Actions workflow: [.github/workflows/referee.yml](../../../.github/workflows/referee.yml). The test suite checks both positive examples and adversarial alterations and is expected to fail closed on a regression.

Receipt hashes cover canonical JSON of input and claim. They do not cryptographically sign a person's identity, attest to GitHub source authenticity, or substitute for a proof-kernel check.

## Research integration

- [Claim Lab](https://d3lefts.github.io/d3lefts/claim-lab.html) tracks claim dependencies and evidence status.
- [Discovery Engine](https://d3lefts.github.io/d3lefts/discovery.html) explores representations and runs a separate bounded optimization toy.
- Referee exports inspectable finite verification artifacts for manual attachment to research dossiers; it does **not** silently promote any Claim Lab status.

Research lead: Devin J. Wright / NIGHTFALL PHASESHIFT.
