# Evaluation Lab exhibit — a perfect score without a correct repair

**Status:** Source-exact internal scorer proof attack · public synthetic replay green · not a certified agent benchmark.

**Short:** NIGHTFALL found that its own DispatchQ grader could return a perfect 100/100 for an unchanged defective queue. A package initializer altered the in-process Python test runner, while a queue-file-only hash made the compromised and normal submissions appear identical. We reproduced the false pass, then built a private out-of-process scoring prototype that returned **58/100** for the compromised candidate and **100/100** for the correct reference. The full-tree source hashes now differ. A public, four-case synthetic reproducer passes CI on Python 3.10 and 3.13.

**Evidence links:** [PR #856](https://github.com/d3lefts/d3lefts/pull/856) · [public toy reproducer](verify_boundary.py) · [public private-replay summary](PRIVATE_V04_PUBLIC_RECEIPT.json) · [exact-head CI](https://github.com/d3lefts/d3lefts/actions/runs/44403230231).

**Essential limitation:** The private v0.4 subprocess prototype is **not isolated from the grader's filesystem**. The independent Docker scorer proof attack [#843](https://github.com/d3lefts/d3lefts/pull/843) and [#846](https://github.com/d3lefts/d3lefts/pull/846) stop-ship gate still block accepting untrusted coding-model scores. Current Qwen runs are exploratory tool-agent observations, not validated model leaderboard outcomes.

**Suggested site treatment:** An evidence-first engineering case study, alongside B1/B2, emphasizing tester calibration, failure discovery and independent criticism. Do NOT label the benchmark secure, a valid frontier-model result, or an official Polaris/Google DeepMind evaluation.
