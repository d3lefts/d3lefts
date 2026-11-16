# Commonwealth OS — archival source and prepilot handoff (2026-11-15)

This directory consolidates source-level outputs from parallel Commonwealth/NIGHTFALL work without modifying the already implemented `app/`, `apps/`, `assurance/`, `workflow/` and design v1.0 baselines.

## Canonical progression
- Research: `research/democratic-assurance/v0.1` through `v0.3`, finite models, receipts, scope limitations, reproducible checkers.
- Architecture: `architecture/v1.1`, full design blueprint, typed schema, guard reference and 19 synthetic tests. Not deployed.
- Prepilot: `prepilot/v1.2` initial instrument and historical rollcall demo, `v1.3` mobile source/tests, `v1.3.1` fixed HTML with no-JavaScript fallback.
- Figma transfer: `product-design/figma-import-v1.2`, six editable SVG wireframes and one overview; Figma tool quota prevented direct import.

## Status and authority
Every prepilot personal vote is *retrospective simulated*, never a real historical ballot or official binding vote. Survey answers, simulated choices and official congressional member positions must remain distinct. Named rollcalls are exact-question records; voice votes, procedural votes, `Not Voting`, and missing coverage cannot be imputed. The three 2026 sample rollcalls are a bounded fixture, not complete source ingestion or actual live-data API.

DAP statements are finite-model conditional guarantees; human agency, political equality, legal validity, real ballot secrecy, complete mediation, and national assurance remain independent research/deployment gates. Do not upload real citizen records, personal ideology profiles, credentials or live elections. No hosting/deployment is authorized by this archive.

## Reproduce
- `python -m unittest discover -s architecture/v1.1/tests -p 'test*.py'` (19 local tests passed on 2026-11-15).
- `python research/democratic-assurance/v0.3/audit_semantic_reuse_independent.py` (finite independent enumeration passed).
- `python research/democratic-assurance/v0.3/validate_passport_schema.py` (schema fixture passed).
- `python -m unittest discover -s prepilot/v1.2/tests -p 'test*.py'` (rerun after dependency setup; browser tests require Playwright).
- Browser assets are static and should be reviewed and hosted only in later explicit release work; no website or Figma canvas update is implied.

## Provenance
Written and coded through AI-assisted NIGHTFALL sessions under Devin J. Wright's project direction. External political and computer-science sources cited by the original reports should retain their attribution. All generated source bytes are listed with SHA-256 in the archive's MANIFEST.json; source files are not independent human peer review.
