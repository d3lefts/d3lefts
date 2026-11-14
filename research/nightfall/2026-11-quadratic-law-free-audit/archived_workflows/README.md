# Archived Q2 proof-stage workflows (November 14, 2026)

These 15 GitHub Actions workflow definitions are preserved byte-for-byte from the proof integration branch as **historical diagnostic sources**, not active CI jobs.

The canonical proof is compiled by [the consolidated Q2 certification workflow](https://github.com/d3lefts/d3lefts/actions/workflows/nightfall-q2-consolidated-lean.yml). Re-enabling any of these overlapping workflows as automatic `push` or `pull_request` triggers would reintroduce redundant pinned-Lean builds.

Their former paths under `.github/workflows/` were archived because they were absent from `main`, not required as repository status checks, and individually run the same modules as the eight-stage dependency-ordered certificate. All YAML blobs in this directory are unchanged from their source branch; no proofs, source-code modules, or receipt files were deleted.

The strict terminal proof receipt remains [run #43611982294](https://github.com/d3lefts/d3lefts/actions/runs/43611982294), with the exact source hash/certificate in [Q2 source certificate](../../../Q2_SOURCE_LEAN_CERTIFICATION_20261114.md). Archival is an infrastructure action, not independent proof review or a novelty claim.

Archived workflow files:

- `nightfall-q2-full-terminal-v436.yml` — Git blob `2088dc8a2db8ab74590ef103563ac09c9e4f1cd9`
- `nightfall-q2-owned-projected-moment-v436.yml` — Git blob `1e9ba54e2fe307ad6a4d0586e751dd181836f97c`
- `nightfall-q2-owned-section-norm-v436.yml` — Git blob `e8d6041a280fcbd30b433aa936cf2c9fd165006f`
- `nightfall-q2-owned-source-composition-v436.yml` — Git blob `acecb2acbc94ed3920260cd0f904758f055710e9`
- `nightfall-q2-projected-jensen-v436.yml` — Git blob `ac8bf77ea345e179b09147a697d3cd8a2f13f1f5`
- `nightfall-q2-projected-pair-jensen-v436.yml` — Git blob `46ac28ee8a568607a6cc1422efc52781a7c94b1f`
- `nightfall-q2-quadratic-support-v436.yml` — Git blob `a69363034718036465de3adde57b8a862f93ed69`
- `nightfall-q2-singleton-jensen-v436.yml` — Git blob `b2abe01a18b1b3dbdd2491ec970ea03035bb05c6`
- `nightfall-q2-source-conditional-projection-v436.yml` — Git blob `3219f47651b1df09bf2fab5825f0efb9ffa2dc79`
- `nightfall-q2-source-first-norm-cap-v436.yml` — Git blob `731351c2e04969915cb49f028c7d35b10810311e`
- `nightfall-q2-source-owned-fourth-v436.yml` — Git blob `dde27438240659e1ac98ad2f50c5c31e94f3f00e`
- `nightfall-q2-source-sector-split-v436.yml` — Git blob `a31f39e51942d06c72d6dd0b1fb0e395d267f7f9`
- `nightfall-q2-source-variance-owned-v436.yml` — Git blob `20779c4d8a7e98e72300e198dc3ea8a4414c28c3`
- `nightfall-q2-terminal-owner-v436.yml` — Git blob `5c4d4535530c4d72902ffb30bf12fbcc6e5c9ff3`
- `nightfall-q2-terminal-source-only-v436.yml` — Git blob `c4b7800b769773775593cc365d3180cf16088355`
