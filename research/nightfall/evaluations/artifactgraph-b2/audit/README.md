# ArtifactGraph-B2: independent public contract audit

**Status (2026-11-18):** separate 22-case public API canary. It is not the private grader, independent human peer review, or a blind model evaluation.

Reproduce from repository root:

```bash
python research/nightfall/evaluations/artifactgraph-b2/audit/public_contract_canary.py --package-root research/nightfall/evaluations/artifactgraph-b2/candidate --require-seed-violations 11
```

Tests use fresh workspaces and compare observable invariants: byte identity despite metadata changes, dependency order, content-addressed integrity, source containment, atomic index publication, global cycle detection, deterministic clean rebuilds, and correct JSON version types. They do not depend on internal serialization details.

At the source-exact ArtifactGraph-B2 author branch head `d5158a3aa37fa0f0ac877406ec806389cc04b5b6`, a separate local audit observed 11 passes / 11 fails on the defective starter in each of 3 fresh runs. The original author reference passed 20 / 22 in 3 runs; a local private copy with explicit strict-integer version checks passed 22 / 22 in 3 runs and still passed all 25 original author-side tests.

**New defect:** JSON `true` is not numeric `1`, but Python `True == 1`. Manifest and index validators compared `version != 1` without checking `type(version) is int`, thereby accepting invalid version types. Both locations need the fix. The author-side reference source and private grader are deliberately not published.

Keep this `audit/` directory **outside the blind agent's sandbox**; hand agents only `candidate/`. Publishing the transparent canary does not convert it into a hidden holdout. All claimed results are author-side experiments, and test coverage is incomplete. No Google/DeepMind/Polaris affiliation is implied.
