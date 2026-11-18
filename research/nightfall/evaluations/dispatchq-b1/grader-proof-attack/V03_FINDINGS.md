# DispatchQ-B1 — independent-operator stress test, v0.3

**NIGHTFALL Evaluation Lab | November 18, 2026 | internal calibration only**

## A test suite that grades a correct reference perfectly can still be wrong

The original DispatchQ-B1 held-out grader gave full credit to five demonstrably incorrect source edits (separate v0.1 proof attack, PR #838). A targeted v0.2 correction detected those edits. We therefore conducted a **new preregistered audit**, deliberately changing *representation families* rather than polishing the same tests.

Twelve new non-equivalent repairs were designed **before looking at the v0.2 hidden test bodies for this audit**, then scored in fresh-interpreter runs. Each contradicted an independently written public-contract API witness; the unchanged trusted reference satisfied all twelve witnesses. **All twelve flawed repairs earned 100/100 in the v0.2 grader**. The misses involved exactness of identifiers and opaque payloads, nonquantized timestamps, and exact matching of lease tokens. Per-mutant mutations and witness code remain withheld to avoid leaking grader-specific cases into agent prompts.

The author-side v0.3 remediation uses **37 weighted tests** instead of 25, while retaining a fixed **100-point denominator**. It rejects all **24** tested incorrect variants from the two audit sets. The original reference scored 100/100 in five 3.13.5 local repeats. The unchanged deliberately faulty starter scored 58, 58, 58, 66, 58: report this variation rather than choosing one baseline as a stable calibration value.

## Mechanism, certificate, limits

- **Mechanism:** Independent contract-derived, metamorphic API witnesses applied to a fault corpus, not merely reference-solution pass rates.
- **Certificate:** Commit-visible aggregate receipt [V03_RECEIPT.json](V03_RECEIPT.json) with pinned SHA-256 of source, v0.2/v0.3 grader, unrevised preregistration, and privately held author archive. [check_v03_receipt.py](check_v03_receipt.py) checks metadata and score arithmetic; it cannot attest the private grader's execution.
- **Timeout handling:** A private bounded scorer reports `blocked_timeout` and **no score** for a hung fixture; one controlled 0.5-second timeout probe passed. It is **not a secure sandbox for untrusted Python**.
- **Limits:** Still no real coding-agent runs, independently vetted alternate repair against v0.3, external human replay, verified OS isolation, or comparison to frontier model benchmarks. Python 3.10 replay of the *private* scorer has not been established.
- **Custody:** Hidden grader, reference, exact mutation source and witnesses stay in private archive `NIGHTFALL_DispatchQ_B1_author_v0_3_PRIVATE.zip`, SHA-256 `61fe5511fc9fbe94118b3d3d5a1feb5b9f200dd86ff994384503b546054e11c5`. Never upload it to GitHub, site builds, Actions artifacts, or an agent-visible workspace.

## Next promotion gate

One independent reviewer must receive the **sealed** archive, verify this preregistration timeline, replay all 24 variants, and test a separately developed correct repair without changing the issue contract. Then freeze the new scorer denominator and version in a precommitted run plan, use a real credential-free isolation boundary, and evaluate at least two blind coding-agent attempts. Timeouts, tool-call failures and grader errors remain in the denominator but are not silently assigned success scores.

**Related work:** #818 (candidate), #833 (alternate repair), #838 (v0.1→v0.2 proof attack), #829/#830 (run receipt assurance), #824 (ArtifactGraph-B2). This work has no endorsement by Google, DeepMind or Polaris.