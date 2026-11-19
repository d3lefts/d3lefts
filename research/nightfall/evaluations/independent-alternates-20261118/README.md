# NIGHTFALL SWE: two source-frozen alternate repairs (2026-11-18)

**Publication tier:** author-directed, AI-implemented, independent-of-reference *alternate constructions* with a bounded internal scorer replay and supplementary public-contract property tests. NOT independent human peer review, NOT a blind model benchmark, NOT a code-proof certificate, NOT externally authenticated execution.

## Why this matters for Polaris

The hardest part of a meaningful SWE task is not a convincing story or green author reference; it is whether the grader accepts independently designed legitimate solutions and distinguishes plausible but wrong repairs. These two alternate implementations were constructed from **only each public ISSUE.md and defective agent-visible starter**. Before either private held-out suite or original author reference was read, the constructed source was frozen by SHA-256 and public smoke checked. The grader was used **after** the freeze as an acceptance test, never as a development oracle. No hidden test cases or original reference source were consulted during construction.

## Results and exact scope

| Task | Independent alternate | Private suite | Separate public stress |
| --- | --- | --- | --- |
| DispatchQ-B1 | `queue.py` SHA `086a3fa9cb22fe3c8a8a693b11c04ca89ec660e673db13d339eef755b89e7f39` | Author v0.3 37/37, reported 100/100 points, Python 3.13.5 | Six public-contract groups; 32 deterministic state-machine histories with 3,840 operations; 10 rounds × six independent OS processes, no observed duplicate lease |
| ArtifactGraph-B2 | `manifest.py`, `cache.py`, `engine.py` source SHA values in [PUBLIC_EVIDENCE.json](PUBLIC_EVIDENCE.json) | Author v0.1 25/25 `unittest` methods, Python 3.13.5 | 16 public-contract/metamorphic groups, including 80 randomized dependency DAGs, independent source bytes vs timestamps, corruption, atomic index, cycles, traversal, and Boolean-as-number rejection |

The B1 v0.3 grader archive SHA is `61fe5511fc9fbe94118b3d3d5a1feb5b9f200dd86ff994384503b546054e11c5` and scorer module SHA is `9cd1b34e8c347acf88d86e96a5d9dd553378a60951d79a6c409b3423a8f94abc`. The B2 v0.1 private archive SHA is `6814e96544d330ff8f1d6320bf74e15194e0835b1a692996f9a11fd87acfb3d0`. These hashes bind source identities but do not grant third parties access to the held-out code or allow current public CI to reexecute it. The private packet SHA is `325845324f999320c9112cc062282d1ab68b6f17a75bfeb197a50ff260800f1b`; packet contains alternate source, audit scripts, results, not hidden grader or original reference.

### B1 grader history — distinct from this alternate check

Earlier B1 v0.1 private grading gave five wrong reference mutations full marks. V0.2 addressed them, but **a newly preregistered second set of twelve separate faulty implementations also scored 100/100 on v0.2**, as documented in [author-side draft #842](https://github.com/d3lefts/d3lefts/pull/842). The private v0.3 revision has 37 tests and retains 100-point scale; author claims it detects 24 targeted mutants, and records nonconstant defective-starter calibration 58, 58, 58, 66, 58. Our **separate** accomplishment is the now-frozen alternate valid implementation being accepted by this later private v0.3 grader. Do **not** treat the author-side 24-mutant detection claim as independent CI-certified by the new metadata-only workflow.

The independent Qwen2.5-Coder-3B attempts in [real local-model PR #845](https://github.com/d3lefts/d3lefts/pull/845) and publicly described [run #44391208580](https://github.com/d3lefts/d3lefts/actions/runs/44391208580) did **not** produce either of these alternative correct implementations. They remain separate, unscored model experiments, with B1 8/13 public violations and B2 11/20.

### Unsafe generic scorer — explicit stop-ship

The separately developed generic same-process Docker grader capture in [#841](https://github.com/d3lefts/d3lefts/pull/841) is **NOT approved to score untrusted model patches**. An independent audit [#843](https://github.com/d3lefts/d3lefts/pull/843), actual-Docker [run #44388473844](https://github.com/d3lefts/d3lefts/actions/runs/44388473844), reproduced **two false-perfect 100/100 passes** by corrupting the grader process's authoritative stdout and by looking for a mounted grader file. [Draft #846](https://github.com/d3lefts/d3lefts/pull/846) provides a synthetic-only stop-ship guard, not a security fix. Our alternate-source private scorer tests were run on **trusted internally authored code** under process timeouts / a stripped environment and nonroot UID; they do not repair that generic score-origin vulnerability or establish OS security.

## Independent replay, custody and next decisive experiment

The complete private packet includes:

- Frozen source and source-bytes manifest for both alternate solutions;
- Public-contract property tests and exact output logs, not derived from hidden test bodies;
- B1 private v0.3 score receipt and B2 private v0.1 unittest output;
- SHA-256 manifest and explicit nonpromotion rules.

**No private implementation, hidden test, mutation, grader, reference or raw agent patch should be committed to the public Git history**. The public `PUBLIC_EVIDENCE.json` is intentionally inspectable but contains no source sufficient to replay the withheld computation. Its CI contract checks metadata integrity and nonpromotion only; green CI is not a private-grader execution receipt.

For a promoted benchmark: have a nonauthor human independently review the public contract and both alternate sources under controlled access, test that the private rubric passes both and fails independent fault variants, certify that the grader executes **outside the candidate's process** and inaccessible to it, freeze the source+prompt+grader+model+budget+attempt denominator in independently controlled custody, then run multiple genuine tool-using coding agents with raw private trace availability and immutable execution-capture evidence. Only then attach a comparable numerical benchmark score. The strongest public record now is **internal legitimate-alternate acceptance**, not externally established difficulty.

No patent, external publication, OpenAI/Google sponsorship, worldwide novelty, or human external validation is claimed.
