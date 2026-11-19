# NIGHTFALL Executable Adversarial Review Study — preregistered pilot v0.1

**Status:** PUBLIC checker calibration only. No agent performed prose-only or executable review. No treatment effect, new theorem, or blind benchmark score is claimed.

## Objective and strongest external reference

Motivation: *A Society of AI Scientists* (Ahmad, Schmidgall et al.; alphaXiv 2026-11-19; https://www.alphaxiv.org/abs/2611.society-ai-scientists). It reports code-executed objections overturning 77/156 major reviewer objections, but does not establish a causal effect of tool access on formal mathematical review. Question: with equal model and resource budgets, does execution authority reduce false acceptance of defective mathematical certificates relative to inspecting precisely the same code and claims without execution?

The nearest audited original NIGHTFALL source is the merged shifted-c/4 Bernstein rational checker at research/nightfall/2026-11-quadratic-law-free-audit/check_shifted_owner_moment_107.py, with Lean scalar source research/nightfall/formalization/observability/ShiftedC4Bernstein.lean. Our public oracle replays the author's exact polynomial certificate (15 nodes, eight rectangles) and pins both original Git blobs. This DOES NOT independently establish the full Q2 source-to-Hilbert proof or novelty.

## Problem → representation → mechanism → certificate

Public case bank public_cases.json freezes 16 claims: four in each family, with two correct and two incorrect per family.

- P01–P04: exact shifted-c/4 polynomial positivity, sharpness and endpoint evaluations.
- S01–S04: modular information synergy under independent and diagonal laws, with exact dyadic entropy.
- D01–D04: rational diagonal X-by-Y matrix rank and minimal mixture count when **each component is a product over all 2n individual bit coordinates**. Components are NOT products over correlated pairs.
- H01–H04: source Git-blob provenance for the original Lean and polynomial checker files.

All claims, values and sources are PUBLIC. Their answers can be recovered from oracle.py. Do not use them as blinded holdouts.

## Prediction and competing explanations

Predeclared hypothesis: under blinded private evaluation, executable-review access lowers *false-acceptances among invalid claims* by >=15 percentage points compared with prose-and-source-only review, while increasing false rejections by at most 5 percentage points and costing no more than 2x. Significant transfer also requires the effect direction in at least 3 of 4 mechanism families. This is a threshold, NOT an observed finding.

Alternatives: better compute or tool budgets, different input visibility, contaminated public answers, skewed task difficulty, reviewer or model differences, an incorrect oracle, over-abstention, or untracked human assistance. Register these before seeing reviewer results.

Primary metric: false acceptances / invalid claims, with abstentions disclosed separately. Safety metric: false rejections / valid claims. Secondary: accurate decisions, abstentions, independently replayed evidence, per-family performance, reviewer variance, time/tokens/tool calls and measured monetary spend. Reviewer-cluster uncertainty and paired stratification are required before an effect claim. A two-agent pilot has insufficient statistical power.

## The two arms

P (prose/source): full claim text and identical source files; inspect text or reason manually, no code/Lean/shell execution.

E (executable): identical inputs, additionally isolated exact Python and pinned Lean execution; no internet or gold labels. Executable evidence should include command, output hash and reproducible counterexample/certificate.

Both arms must use the SAME model version, prompts except tool policy, per-reviewer **30-minute wall-clock**, **30,000 total tokens** and **$40 measured API-cost limit**, with separately metered tool runtime. Randomize case order in counterbalanced matched assignments. Keep reviewers and their outputs independent until sealed. Stop / report incomplete if resource controls cannot be enforced. Never fake parallel reviewers or substitute synthetic fixtures for agent trials.

## Unbuilt private holdout

A separate custodian should precommit 32 fresh held-out cases (8/family, 4 valid+4 invalid each), including immutable SHA-256 digests for both task input and separately controlled answer key. Ensure agents cannot search the answer key, check no leakage via cached references and verify valid certificates and invalid witnesses before release. Minimum feasibility pilot: 2 independently executed reviewers per arm with matching budgets; not a statistically meaningful benchmark. Obtain a non-author reviewer for a separate implementation audit.

## Reproduction and scoring

Run from repository root:

    python3 -m unittest discover -s research/nightfall/evals/executable-review-study -p 'test*.py' -v
    python3 research/nightfall/evals/executable-review-study/oracle.py --output oracle-receipt.json
    python3 research/nightfall/evals/executable-review-study/score.py --submission reviewer-submission.json --output score-receipt.json

The submission schema is nightfall.exec-review.submission.v1 and requires reviewer_id, condition ('prose_only' or 'executable'), case_sha256, and exactly 16 answers containing id, verdict (valid/invalid/uncertain), reasoning. Duplicates, altered hashes and missing answers are rejected. The scorer reports accuracy, false-accept, false-reject and abstention counts, and labels condition self-declared/unverified. It must NEVER count its own synthetic all-correct fixture as an agent result.

An independently assigned auditor B should reproduce the Bernstein certificate by exact arithmetic, check modular joint distributions with a distinct implementation, derive diagonal rank lower and point-mass upper bounds, inspect Git blob hashes, and attack schema/label/source-law cases before any model benchmark promotion. These audits remain open, not falsely completed.

## Stop, cost and certification

Cheapest decisive experiment: original certificate replay and a public calibration bank with 8 true/8 false outcomes; constant-valid and constant-invalid mock submissions must each score exactly 8/16 and all-uncertain 0/16. Stop before agent spending if source pins diverge, original checker fails, class balance changes, forged/malformed submissions pass, any ground truth leaks, or budget enforcement is absent.

No certification beyond public reproducible checker correctness until actual external reviewer trials and independent audit. Separate correctness, research significance, novelty, and performance status. Preserve failed attempts and dated provenance.

**Credits:** Ahmad, Schmidgall and the *A Society of AI Scientists* coauthors for experimental motivation; original NIGHTFALL Lean certificate contributors for existing mathematics. This separate NIGHTFALL design is neither endorsed nor reviewed by those authors.
