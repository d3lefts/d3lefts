# NIGHTFALL / External Mathematical Witness Audits — First Independent Replay

**Checkpoint:** 2026-10-29. **Scientific lead:** Devin J. Wright. **Independent arithmetic implementation:** Axiom. **Role:** independent exact numerical verification of a *third-party* research witness. The claim and construction belong to the original contributors; NIGHTFALL receives credit only for this independently written finite checker. **Status:** one completed exact replay; a ten-claim intake remains pending, not ten verified claims.

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

## Ten-witness intake, no retrospective outcome invention

This is a **candidate register**, sourced to [Optimization Constants in Mathematics](https://github.com/teorth/optimizationproblems/blob/main/README.md), retrieved 2026-10-29. All candidates after #1 are **not tested in this session**.

| # | Source claim / specific artifact | Status |
|---:|---|---|
| 1 | C1d signed autoconvolution, 600-cell steps-re certificate (21 Oct) | **Exact replayed in session** |
| 2 | C1d 300-cell CERT2026 (12 Oct) | Queued; independently replayed elsewhere already, credit Toledo |
| 3 | C1d 800-cell SCiEL2026 (21 Oct) | Source access restrictions flagged; no byte-level check |
| 4 | C1c rozetyp step-function construction | Queued; first obtain primary weights |
| 5 | C1a Atris 2026 bound | Queued; first obtain primary construction |
| 6 | C1b Atris 2026 bound | Queued; first obtain primary construction and signed-lag convention |
| 7 | C4b Naslund 2026 lower rational construction | Queued; verify formal source and mathematical scope |
| 8 | C49 Koshta 2026 set-family lower construction | Queued; request primary certificate |
| 9 | C82 Pinho 2026 measure upper certificate | Queued; requires Arb/interval-aware replay |
| 10 | C86 Koshta 2026 auxiliary-polynomial upper certificate | Queued; requires exact / ball arithmetic |

**No hit-rate calculation:** a selected ten-item intake with one executed check has no meaningful success-rate inference. Upstream asterisk labels reflect upstream status, not our grading. Prior-art priority and scientific validity require separate evaluation. Never count a source's existing checker as independent replication by NIGHTFALL.

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
