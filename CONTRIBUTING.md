# NIGHTFALL contributing and release policy

Keep main as the published state. Every parallel AI instance should use a distinct topic branch, batch coherent changes, and open a pull request. Verify the pull request against fresh main before merging. Run the static gate, browser smoke, and the CI verify job. A failed gate needs a reproduced cause and a narrow repair.

Original findings require distinct primary artifacts, independently reproduced verification, and dated prior-art comparison. The Research Agenda contains ten explicitly untested proposals on a separate page. The originality whitelist remains exactly three entries unless a dated audit and human sign-off justify a change.

## Scientific review queue

The dated [product-owner triage](research/nightfall/REVIEW_TRIAGE_20261029.md) names the current three independent-review priorities, their falsifiers, and their unresolved proof/novelty gates. Public [review navigation](https://d3lefts.github.io/d3lefts/review.html#priority) must link to each primary PR and present its status as *candidate* unless a supported publication decision has been recorded. A green software job certifies only the checks it ran.

Consolidate overlapping draft branches before merging. Do not promote a theorem, novelty claim, or competitive result in a presentation-only PR. When a test or proof fails, keep its smallest counterexample and repair the original claim's dependencies.

## GitHub administrator action

The documented branch policy cannot block direct pushes on its own. Enable Settings > Rules > Rulesets > New branch ruleset for main, require pull requests, require the Verify research website / verify check to pass, and restrict bypass if supported. Confirm the rule is active. GitHub Pages should deploy main /docs.

After a green merge, check the main workflow and Pages deployment. Cancelled superseded runs reflect rapid commits, not necessarily broken live pages.

## Completed public evidence release

Issue #5's approved binaries are available at [the curated release](https://github.com/d3lefts/d3lefts/releases/tag/nightfall-research-2026-10-28). Do not restart disclosure approval or request the private master archives. Use `python3 scripts/download_nightfall_curated_assets.py public-assets` and the receipt linked from `docs/evidence.html`. Keep issue #6 separate: accepted Arena input identity remains unresolved.

## Efficient CI

Batch coherent changes on a topic branch. Relevant PR checks run before merge; main pushes verify the published state. Superseded runs on the same ref are cancelled. Evidence Bridge now checks main instead of a retired feature branch. The release workflow downloads only the two public curated assets, checks all manifests, and replays exact GMP arithmetic without a private source or download credential. Never mark an old failed run successful; follow the new run on the corrected commit.
