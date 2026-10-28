# PAS public metadata freeze v0.1 — evidence status

**Historical locally recorded freeze:** 2026-10-06 20:23:39 EDT (2026-10-07 00:23:39 UTC). **First publication in this GitHub repository:** 2026-10-28. The original freeze date has no independently secured timestamp in the available record. Public release today cannot establish that the ranking was sealed on October 6.

Source: [openai/math commit adc7f1241b42e322a6451854ab7e4b4c146bf78a](https://github.com/openai/math/tree/adc7f1241b42e322a6451854ab7e4b4c146bf78a), `CONTENTS.md`. Unit: 372 result families within a 722-manuscript release. This is a **metadata ranking**, separate from the 620-unit manuscript-citation graph. Sort: Lean-formalization absent first, manuscript count descending, description words descending, family ID ascending.

- [All 372 ranked families, CSV](openai_math_priority_ranking_2026-10-06.csv)
- [Recovered original ranking generator](openai_math_priority_freeze_v0_1.py)
- Complete ordered ID sequence FNV-1a-64: `c429732aac46eae9`, reproduced exactly from the immutable source snapshot.
- **Public CSV SHA-256:** `3e303b69ef8e530b5c618e61f9cb5c4527ea717b0588c59f2fb75b4afd5924e7`. The CSV has CRLF record endings, with fields `rank,id,lean_formalized,manuscript_count,description_words,title`. [SHA256SUMS.txt](SHA256SUMS.txt) supports `sha256sum -c SHA256SUMS.txt` inside this folder.

**Metadata-only test:** Prospectively track substantive revisions (theorem change, necessary hypothesis, withdrawal, logical repair, formalization mismatch, dependency correction), report rank-based precision and recall and compare with random, Lean-only, manuscript-count-only and description-length-only rankings. Original local freeze requires that revisions predate neither the freeze nor any rank-dependent adjudication. It is a baseline awaiting empirical scoring, not evidence of predictive superiority.

**Separate October 7 manuscript-graph preregistration:** Locally recorded time `2026-10-07T00:05:14Z`; historically recorded SHA-256 of `MANIFEST.sha256`: `b0b439e0e44a4ea06f87297c9479063ae8aa26f7be731912d39ed6a1870ab697`. The original graph, full ranking, `PREREGISTRATION.md`, manifest, model, corpus-derived files and independent Zenodo/OpenTimestamps receipt are still missing from public hosting. This recorded digest has **not been rehashed from the original bytes in this publication**. The main graph H1 is *not yet a publicly checkable preregistration*.

**Main graph H1:** Compare unit-level exposure `x₀N` with the unit's own `x₀` for later substantive corrections; one-sided permutation test within equal-`x₀` strata with 10,000 draws; minimum 20 corrected manuscripts and `p < 0.05` for support. Decisive score scheduled for **2027-04-06**. Publication of the frozen primary bytes and a third-party timestamp is required before upgrading the evidentiary status.

**Independent publication-time witness (limited scope):** GitHub's server recorded [site verification run #40659651949](https://github.com/d3lefts/d3lefts/actions/runs/40659651949) at **2026-10-28 08:50:11 UTC** for [commit c4b8713](https://github.com/d3lefts/d3lefts/commit/c4b87130827a687932301635a5126fe17443f707), which contained the full ranking and SHA-256. That GitHub-controlled event time establishes a publicly inspectable *October 28* publication boundary; it cannot establish the private October 6 freeze. A long-lived Zenodo/OpenTimestamps commitment for the original freeze remains outstanding.
