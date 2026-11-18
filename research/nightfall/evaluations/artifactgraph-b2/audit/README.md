# ArtifactGraph-B2: independent public contract audit

**NIGHTFALL internal cross-check v0.1 · 2026-11-18 · preregistered before source-exact CI**

This is a second, deliberately public, API-level tester for [ArtifactGraph-B2](../candidate/ISSUE.md), built separately from the task author's unpublished 25-case scorer. It does **not** inspect or certify the unpublished reference, grader, mutation corpus, or model attempts. It is not independent human peer review.

## Research question and strongest reference

Can we build a source-linked, implementation-independent checker that detects semantic contract violations in the intentionally defective starter, but accepts legitimate alternative serializers and correction strategies? Reference: the exact written task contract in candidate/ISSUE.md at the base of [draft PR #824](https://github.com/d3lefts/d3lefts/pull/824). Author-side 25-test, 10-mutant results are background claims, **not** checker truth labels.

## Representation

Each finite test creates a disposable on-disk workspace, source tree, JSON graph manifest and artifact cache. All decisions use only the public Builder/GraphError API and public persistent artifact data. No private implementation function, substring scorer, author reference, or hidden grader is used. The output records exact source SHA-256 fingerprints and explicit PASS, VIOLATION, ERROR outcomes. A contract violation is not counted as established if an unexpected exception occurs; that is ERROR, which fails the seed-profile CI.

## Preregistered predicted seed outcomes

Nine positive controls: initial dependency closure; cross-instance reuse; unknown-target rejection; duplicate dependency rejection; missing-object regeneration; invalid-index rejection; arbitrary binary inputs; reproducible clean outputs; rejection of absolute source paths.

Eleven expected violations on the defective seed, grouped by causal mechanism:

| Family | Predicted violation | Decisive observation |
|---|---|---|
| DAG validation | Unreachable cycle accepted | \`GraphError\` required even when target avoids cycle |
| Filesystem safety | Existing \`../\` path accepted | Read outside \`src/\` must be prohibited |
| Filesystem safety | Symlink to outside file accepted | Escape after \`resolve\` must be rejected |
| Cache identity | Different bytes + same mtime are reused | Output content digest must change |
| Cache identity | Same bytes + new mtime are rebuilt | Existing object should be reused |
| Ordered dependencies | A dependency permutation is reused | Content identity must preserve ordering |
| Object integrity | Corrupt cached object is reused | The object hash must be verified and regenerated |
| Read integrity | \`read_output\` returns corrupt bytes | Must reject with \`GraphError\` |
| Publication | Partial index persisted after a source error | Old committed index must remain byte-for-byte |
| JSON shape | Manifest \`version: true\` accepted as numeric 1 | JSON Boolean is not JSON Number 1 |
| JSON shape | Index \`version: true\` accepted as numeric 1 | Same exact-version requirement |

Expected totals: **9 contract-satisfying controls, 11 violations, 0 unexpected exceptions**, on the deliberately defective seed only. This pre-registration is falsifiable; unexpected outcomes must be investigated before changing either predictions or task contract.

## Run and checker

From the project root:

~~~sh
python audit/public_contract_probe.py --mode seed --output /tmp/artifactgraph-canary.json
# After obtaining a TRUSTED independent repair:
python audit/public_contract_probe.py --mode candidate
~~~

The checker runs on Python 3.10 and 3.13 CI, retaining immutable run logs and JSON receipts. In seed mode it requires **exactly the preregistered** result for each named test. In candidate mode each probe must satisfy the written API-level contract; this is necessary but not sufficient for a correct repair.

**Important security restriction:** importing modified candidate Python executes it inside the runner's user process. The above script is **not a sandbox**. Only the trusted author-provided seed should be tested by the CI in this branch. Untrusted agent patches require isolated disposable no-network, no-credential, bounded process environments and a separate trusted scorer outside the attackable filesystem.

## Audits, limits and promotion

A separate AI-assisted implementation can reveal specific mistakes in the author task and benchmark scorer; it is still **internal criticism**, not an external audit. The checker does not address simultaneous index writers, concurrent symlink swap, arbitrary source mutation races, all valid serializers, complexity, unbounded DAG depth, or tool-using agent competence. It does not independently verify the author's reported 25/25 grader score.

The next decisive experiment is an **independently implemented correct alternate solution**, with a preregistered oracle-equivalence test and adversarial mutations. Only after a trusted repair passes independent and author graders, and real agents are run under identical frozen budgets in OS isolation, should task difficulty or model comparisons be claimed.

**Data custody:** never include hidden grader, author solution or private mutation archive in a public site release. Use CI receipt artifacts for numeric outcomes; do not hand-transcribe unverified values into a promoted benchmark registry.

## Exact-source CI receipt — 18 November 2026

**PASS:** [run 44354996082](https://github.com/d3lefts/d3lefts/actions/runs/44354996082), including two successful \`contract-audit\` jobs with attached JSON receipt artifacts. Python 3.10.22 and 3.13.18 each reported **20/20 predicted outcomes: 9 PASS, 11 VIOLATION, 0 ERROR, 0 mismatches**. The deliberately defective starter is the object under test, not a blind AI-generated patch. No author-side hidden-grader score is reproduced by these receipts.

The source-level Python module SHA-256 identities recorded independently in **both** job logs were:

| Module | SHA-256 |
|---|---|
| \`engine.py\` | \`46182d02c68dba0a9e97454a9b9497e9d80d9651df8543383e387b00dbd83628\` |
| \`cache.py\` | \`a809ca16470dc30b99ae9f46e707dceea7b57e94b7d8375e94fc0c5a8ec8eebb\` |
| \`manifest.py\` | \`3aa3f096d914c75b33fe6cdf4319ceff068d5e4687c468d2bf2f8c4724c5ceb8\` |

The 11 failures are **semantic, finite negative controls**, not 11 agent attempts or 11 independent discovered vulnerabilities in production software. Several arise from intentionally seeded defects already known to the task author. The additional JSON Boolean version controls are independent boundary challenges. The report cannot certify completeness, long-horizon difficulty or task novelty.

### Audit priority

Prioritize a separately implemented **correct alternative repair** before improving cosmetic rubric detail. That independent repair must satisfy all 20 public probes and the unchanged private grader in an isolated environment; authors should then introduce at least one new mutation family after freezing grader version. Unexpected failures or grader disagreement block certification. Keep the public source and withheld reference strictly separated.
