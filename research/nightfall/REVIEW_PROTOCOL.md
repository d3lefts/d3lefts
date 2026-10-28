# External-review protocol — NIGHTFALL PHASESHIFT

**Release date:** 2026-10-28. **Human research lead:** Devin J. Wright.

The website at `docs/index.html` runs an **agent-first independent verification program**. The authoritative [agent protocol](AGENT_VERIFICATION_PROTOCOL.md) specifies independent reproducer, adversarial and formalization roles; this document supplies the public reporting format. A model consensus is not a certificate. Mathematical claims advance only through the particular checkable evidence stated for each assertion.

## Four active review dossiers

1. [Exact Erdős overlap witness](projects/erdos-overlap-paper.md) — verify normalized rational heights, both signed lags, real-shift breakpoint reduction, exact convolution and CRT uniqueness. Contest submission eligibility is a separate question.
2. [Werner-state certificates](projects/werner-direct-margin/README.md) — independently rederive dual identities, spectator separability and original source SDP inequalities; downstream certificates are conditional until the imported premises pass.
3. [Finite-field phase retrieval](projects/finite-field-retrieval-handoff-excerpt.txt) — audit the all-signals probability guarantee, finite-field roots, the LLL parameter proof, complexity, and list of exceptional cases.
4. [AI safety and authorization theory](projects/agent-safety-under-abstraction/README.md) — attack theorem quantifiers and protocol-class assumptions, reconstruct Horn complexity reductions, and distinguish synthetic checks from empirical system behavior.

## Submission standards

Every agent-generated verification report must specify:

- Agent role, model and tool version, source and checker commits, claim ID, date, and public run identifier. The human research lead is credited separately from the tool that executes a checker.
- Exact base source commit, proof dependency statement, and list of actual source files inspected.
- A concise scoped verdict: **PASS**, **FAIL**, or **INCONCLUSIVE**. PASS means the specified assertion survived its deterministic check; further analytic premises remain separately open.
- Exact commands, runtime environment, source-input and output SHA-256 hashes, integer/rational/interval tolerances.
- Concrete counterexample if the claim fails, including minimal data and a standalone reproducer.
- Missing source inputs, differences in conventions, and any prerequisite source theorem that has not received independent proof review.
- Original author/source credit and reviewer credit (opt in; no automatic attribution without consent).

## How to contribute

GitHub Issues are enabled, and the four open review assignments are [#1 Erdős](https://github.com/d3lefts/d3lefts/issues/1), [#2 Werner](https://github.com/d3lefts/d3lefts/issues/2), [#3 finite-field](https://github.com/d3lefts/d3lefts/issues/3), and [#4 AI safety](https://github.com/d3lefts/d3lefts/issues/4). Agents submit evidence directly to the relevant issue. Store machine-readable run receipts under `research/nightfall/agent-reports/` with source files and command logs. The [machine-readable task queue](AGENT_TASKS.json) freezes task IDs and scope. For substantial reports, open a pull request adding the receipt and standalone checker code, using [the report template](reviews/REVIEW_TEMPLATE.md). Reports should link to the smallest reproducible source objects; binary bundles belong in a public immutable release where possible.

We welcome negative findings, corrections, and alternative interpretations. A reviewer can inspect only the material actually provided; an incomplete public binary mirror must be marked as an input limitation. Internal test logs establish only their executed scope. A separate agent implementation improves methodological independence; it still differs from an external human peer-review endorsement.

## Claim classification

1. **Conjecture** — a statement and reasoning, without a reproducible proof artifact.
2. **Numerical candidate** — a computation that is reproducible with its source inputs.
3. **Certified finite construction** — an exact or outward-interval independent checker supports the stated finite object.
4. **Theorem manuscript** — full proof written and internally audited; remains pending expert checking.
5. **Machine-checked theorem** — the complete formal statement is verified by a proof-assistant kernel with all premises exposed, no hidden axioms or unclosed proof obligations.
6. **Novel result** — additionally requires dated prior-art checks at equivalent assumptions.
7. **Competitive record** — additionally requires an official platform result tied to the exact accepted submission bytes and eligibility.

These are separate statuses; a successful test cannot skip the missing gates. A source-dependent exact identity is labeled **conditional** until its external premises are reproduced independently.

## Correction policy

Substantive errors will be posted with a dated correction note identifying the false statement, minimal counterexample or failed test, affected dependent claims, and the corrected version. A withdrawn result remains visible in the historical record; silent status promotion is prohibited.

## Citation and licenses

Manuscript authors, published-source contributors, agent implementations, and any independent reviewers are identified in their corresponding primary records. A reviewer should request explicit licensing or permission before reusing substantial code or figures. Published GitHub presence alone is not a blanket content license.
