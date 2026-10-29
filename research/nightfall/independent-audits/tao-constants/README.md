# NIGHTFALL / Independent External Witness Audits — Exact Replays & Correction Ledger

**Checkpoint:** 2026-10-29. **Scientific lead:** Devin J. Wright. **Independent arithmetic implementation:** Axiom. **Role:** independent exact numerical verification of a *third-party* research witness. The claim and construction belong to the original contributors; NIGHTFALL receives credit only for this independently written finite checker. **Status:** three of the ten original intake candidates now have exact replays (C1d 600, C1d 300, C1c 6144), plus a historical C1c 3072 companion check. This is one cross-claim verification program, not four independent discoveries.

## Completed: C1d, 600-cell signed autoconvolution

Upstream: [steps-re/c1d-certificate @ 9a091494](https://github.com/steps-re/c1d-certificate/tree/9a091494facc801eaf6b92b175b63c58b7c3b30b) and [optimization constant 1d](https://teorth.github.io/optimizationproblems/constants/1d.html) (maintained by Davis, Ivanisvili and Tao). Credit the source authors and project maintainers; this is their witness and numerical bound.

The published source consists of **600 signed IEEE-754 binary64 cell values**. Their autoconvolution has **1,199 exact piecewise-linear knot values** on the grid. The verifier reconstructs each double directly from its sign, exponent, and mantissa via Python's struct module, embeds all cell values into a shared power-of-two integer lattice, and computes the complete convolution by **unordered pair-first accumulation** with diagonal coefficient 1 and off-diagonal coefficient 2. This is deliberately algorithmically separate from the source's lag-first Fraction implementation.

**Exact replay result:**

- Peak zero-based knot index: **631**
- Exact ratio numerator: **698746209786798359455483373677229695641600**
- Exact denominator: **478522078482569620433992386249161163190849**
- Ratio (decimal display): **1.460217284022874**
- Exact rational equality with published certificate: **PASS in independent in-session JavaScript BigInt audit**; Python CI replay pending.
- Original file SHA-256 expected: **3dd39fae744555179b0356b84e752db724e892bd23dda51403976edfb5b3a28c**
- Exact upstream commit: **9a091494facc801eaf6b92b175b63c58b7c3b30b**.

Reproducer [c1d_600_exact.py](c1d_600_exact.py) requires only Python's standard library. It rejects a wrong source hash, zero integral, non-finite values, incorrect cell count, wrong rational result, and a deliberate mutation that swaps two unequal weights.

    python3 research/nightfall/independent-audits/tao-constants/c1d_600_exact.py --fetch

Optionally save the original source bytes and rerun with --file. A dedicated GitHub Actions workflow runs the exact checker. A successful certificate replay confirms the **ratio computed from this concrete source**, not the truth of a universal lower bound, peer review, global optimality, or mathematical priority. The source itself reports earlier independent replay of the 300-cell C1d certificate by Carlos Toledo; this 600-cell check is a different source witness.

## Completed: C1d, 300-cell signed autoconvolution

The earlier 300-cell certificate is independently replayed from [Extremal Values Registry @ 50520b9](https://github.com/extremal-values-registry/extremal-values-registry/tree/50520b971e5d234bc9c4ccbdcd5a5107d5bb8791/certificates/third_autocorrelation_abs_inside), with an exact expected file SHA-256 of `51f864ee95205f06b98923c382d23cb3dfde5f0d4208a4c591bad015e5908a0e`. Original artifact and prior independent replay by Carlos Toledo are credited.

The independent in-session BigInt auditor covered **all 599** knots, maximum zero-based lag **414**, and obtained precisely

`2039224160683882663565441886346340189798400 / 1393796574908163689489385839036226787118881`,

which matches the published 300-cell fraction (decimal 1.4630715826075593…). An independently authored dependency-free Python checker [c1d_300_exact.py](c1d_300_exact.py) repeats the pinned-hash and symmetric-pair exact arithmetic, with a deliberate input-swap negative control. GitHub CI replay is required separately. This is a **recheck of an already independently replayed numerical witness**, not a new record or originality claim.

Run: `python3 research/nightfall/independent-audits/tao-constants/c1d_300_exact.py --fetch`.

## Completed: C1c, 6144-grid lower-bound certificate — correct arithmetic, inaccurate decimal in prose

Source: [rozetyp / Barnard–Steinerberger lower bound @ 19f3971](https://github.com/rozetyp/barnard-steinerberger-lower-bound/tree/19f397152222caaef2c838bdd9c41295adb94310), original authors credited. Frozen source JSON SHA-256: `62ac49ddbbfc9aa1053406363d9df9c912022ab85b72a447cf73c94bb9c1fd0e`.

**Exact replay result:** K = **6144**, N = **6148** nonnegative integer cell weights, **6145** tested integer shift knots (0 through K), exact lower-bound ratio:

`21072342208353792 / 51354782902387969 = 0.4103287175491874...`

Minimizing zero-based shift: **4665**. The independent [C1c exact checker](c1c_6144_exact.py) uses **pair-first integer accumulation** instead of claimant's lag-first source checker, verifies all shift knots, confirms the JSON's exact rational claim, and runs a deliberate weight perturbation. The continuous shift domain is covered since the overlap integral of any two equal-width grid indicator cells is piecewise linear between those knots. The independent in-session BigInt computation agrees. Python GitHub Actions replay is the release gate.

**Correction found, limited to prose:** the source README currently states that this same **correct exact fraction** equals `0.41030287175...`; the corresponding [C1c optimization-constants page](https://teorth.github.io/optimizationproblems/constants/1c.html) repeats the incorrect decimal, while elsewhere on the same page the rounded bound `0.4103287` is consistent with the fraction. The difference is ~**0.0000258458** in decimal presentation only. Do **not** call this an invalid witness, improved record, independently established global optimum, or researcher miscalculation. The JSON's own `score_float` value `0.4103287175491874` is correct. Upstream notification remains a separate step, after the checker receipt is public.

Reproduce: `python3 research/nightfall/independent-audits/tao-constants/c1c_6144_exact.py --fetch`.

## Historical cross-check: C1c, 3072-grid prior certificate

The same upstream repository preserves [its earlier 3072-grid construction](https://github.com/rozetyp/barnard-steinerberger-lower-bound/blob/19f397152222caaef2c838bdd9c41295adb94310/previous/certificate_K3072.json) (3,584 nonnegative integer weights; SHA-256 `788527a6237837e8d5d441cfab3f8b39080165fc207ae6a69678cc5f3a0fdf58`). The independent checker [c1c_3072_exact.py](c1c_3072_exact.py) checks all **3073** knots by pair-first integer correlation and finds minimum at lag **497**:

`92043155785589760 / 224330199426578281 = 0.41030211723996995...`.

This historical witness is **distinct** from the incorrectly printed `0.41030287175` decimal above. A numerical resemblance does not justify conflation. It is a baseline recheck, outside the primary ten-claim intake.

Reproduce: `python3 research/nightfall/independent-audits/tao-constants/c1c_3072_exact.py --fetch`.

## Ten-witness intake, no retrospective outcome invention

This is a **candidate register**, sourced to [Optimization Constants in Mathematics](https://github.com/teorth/optimizationproblems/blob/main/README.md), retrieved 2026-10-29. Entries #1, #2 and #4 now have source-pinned arithmetic replays. #3 and #5–#10 remain **not tested**; the historical C1c 3072 companion is counted separately.

| # | Source claim / specific artifact | Status |
|---:|---|---|
| 1 | C1d signed autoconvolution, 600-cell steps-re certificate (21 Oct) | **Exact replayed in session** |
| 2 | C1d 300-cell CERT2026 (12 Oct) | **Exact replayed in session**; independent earlier work credited to Toledo |
| 3 | C1d 800-cell SCiEL2026 (21 Oct) | Source access restrictions flagged; no byte-level check |
| 4 | C1c rozetyp step-function construction | **Exact arithmetic reproduced**, README decimal typo documented; 3072-grid historical baseline also independently replayed |
| 5 | C1a Atris 2026 bound | Queued; first obtain primary construction |
| 6 | C1b Atris 2026 bound | Queued; first obtain primary construction and signed-lag convention |
| 7 | C4b Naslund 2026 lower rational construction | Queued; verify formal source and mathematical scope |
| 8 | C49 Koshta 2026 set-family lower construction | Queued; request primary certificate |
| 9 | C82 Pinho 2026 measure upper certificate | Queued; requires Arb/interval-aware replay |
| 10 | C86 Koshta 2026 auxiliary-polynomial upper certificate | Queued; requires exact / ball arithmetic |

**No hit-rate calculation:** a selected ten-item intake with three primary candidate checks has no meaningful success-rate inference. Upstream asterisk labels reflect upstream status, not our grading. Prior-art priority and scientific validity require separate evaluation. Never count a source's existing checker as independent replication by NIGHTFALL.

## Reusable audit contract

1. Freeze upstream version, exact artifact bytes, SHA-256 and precise claimed value/inequality.
2. Specify assertion being checked and excluded stronger interpretation.
3. Reimplement in distinct arithmetic representation and iteration structure; exact integer/rational first.
4. Check every relevant case/lag, all sign conventions, repeated-summand and boundary terms.
5. Include a negative perturbation and check the verifier fails.
6. Compare exact fractions (rounded display never substitutes).
7. Publish full input provenance, checker hash, command, output and a reviewer invitation.
8. Separate source computation, independent replay, external theorem audit and novelty.

**Stop rule:** after two independent source failures, pause the intake, reproduce counterexample, and report to the original authors without claiming a math record. Source access blockers remain visible.
