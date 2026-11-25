# Paper VI publication certification record — 25 November 2026

The manuscript remains version 1.4 (the supplied preprint label); the frozen doctoral prospectus remains v0.7. Only Section 10.2 of the publication PDF was revised; all other pages render identically. SHA-256 of the revised PDF: `155e1d8d7c317928738e533bffcff1e79bdaaeb5a7d27fa4055e1b0edc54a7d7`. The PDF itself was generated locally, not uploaded to GitHub by this record.

## Section 10.2 — Formalization status, November 25, 2026

The repository uses pinned Lean 4.36.0-rc2 and Mathlib, exact-source custody, kernel replay and named axiom audits. The headline tensor obstruction and staged mean-square bounds now have end-to-end certificates at the scopes below; the latter were also replayed locally. Secondary compositions and written arguments remain distinct from certified statements.

| Result or dependency | Evidence status |
|---|---|
| Product influence, quadratic and original Wyner simulation | Prior source-exact and scoped receipts as described in [2, 1]; inherited, not newly certified here. |
| Tensor representation obstruction (Theorem 1.3) | [PR #1212](https://github.com/d3lefts/d3lefts/pull/1212), head f7bdd571; [run 45644811376](https://github.com/d3lefts/d3lefts/actions/runs/45644811376) passed compilation, kernel replay and named axiom audit of code_exact_parameters, tensor_entropy and tensor_representation_score, using the actual general-latent definition. |
| Staged general-degree and quadratic MSE (Theorem 1.4) | [PR #1201](https://github.com/d3lefts/d3lefts/pull/1201), head 41fb1cc5; [run 45652533477](https://github.com/d3lefts/d3lefts/actions/runs/45652533477) passed both actual-law Wyner endpoints. The certified explicit constants and tolerance-dependent strict slack give the stated orders; not verbatim certification of every written proof step. |
| Local fresh-kernel replay of staged endpoints | [Run 45653852704](https://github.com/d3lefts/d3lefts/actions/runs/45653852704) exported closed dependencies; artifact 15041568364 replayed locally using leanchecker --from-export, exit 0, on 25 November 2026. Only propext, Classical.choice and Quot.sound. |
| Earlier entropy and QW+ stopping | PR #1200, head b623f79f; run 45626765856 passed. QW+ is distinct from the stronger staged MSE theorem. |
| PPZ locality, mixture cardinality and dominated-product simulation | Prior scoped named gates: runs 45482284099 and 45485183075; not certificates of new staged compositions. |
| Direct cover transfer, robust support, block syndrome, shared staging and measurable lift | Written proofs and selected finite or component checks; full end-to-end receipts not asserted for these secondary compositions. |
| Two-query additive-fiber result | Inherited written proof from Paper V; full terminal certification not asserted. |

## Reproduction

See CERTIFICATE.json for immutable heads, source custody, theorem names, exact export digest and local replay receipt. Retrieve the compressed export from the linked export run, verify the uncompressed NDJSON SHA-256 and run pinned `leanchecker --from-export pvi.ndjson`. The local run accepted the solution in 122.18 seconds, peak RSS 928468 KiB. Source elaboration occurred in CI; the local independent kernel replay checked the exported theorem terms. Tensor terminal was checked in CI, not locally. The metadata-reconciled staged head 9cfec81f passed run 45654629250. These records do not claim all secondary compositions or all paper variants are formally covered. Source branch integration remains separate. No external publication, DOI or priority promotion recorded.
