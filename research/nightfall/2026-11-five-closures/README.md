# Five-priority observability closure audit (v1.2 integrity-repaired addendum)

Research lead: Devin J. Wright / NIGHTFALL Constellation. **Scope:** research checkpoint; no externally reviewed novelty and no publication clearance.

- [Exact global nonadaptive allocation and its closed-form risk curve](EXACT_GLOBAL_QUERY_ALLOCATION.md).\n- [Exact nested-address budget optimum and universal-degree LP sandwich](EXACT_BUDGET_AND_GENERAL_LP_20261111.md), with standalone proofs.\n- [Manifest repair and reproducibility erratum](INTEGRITY_ERRATUM_20261111.md).\n- [Full analytic claim/source note](FIVE_CLOSURES_V11.md), with precise conditionality and original reference attributions.
- [Independent exact finite checker](checks/independent_five_audit.py), run with `python3 -I research/nightfall/2026-11-five-closures/checks/independent_five_audit.py`.
- [CI workflow](../../../.github/workflows/nightfall-five-closures.yml). A green run verifies the stated finite cases only.
- [Claim registry](PROOF_PASSPORTS.json) preserving dependencies, certification status, limitations and next independent gate.

The **original** local source archive `NIGHTFALL_Five_Closure_Audits_v11_20261111.zip`, SHA-256 `0d9f2b9bc6c4183394173987c30b225ca1c4675f7307efa05c563e531a096bd4`, **does not pass full fresh-extraction manifest replay** (six missing render files). The repaired `NIGHTFALL_Five_Closure_Audits_v12_INTEGRITY_REPAIRED_20261111.zip`, SHA-256 `28e61af840605eb3b652cdb52bfeaa3a154f9d966b43ce69128c616b6ba30123`, passes 21 included file hashes, preserving PDF/TeX bytes. See the [erratum](INTEGRITY_ERRATUM_20261111.md). Both binary archives are conversation artifacts **not included in the GitHub PR**.

**Status ledger:** P1 rank-linear disjoint-output allocation is conditional on the scalar arbitrary-product observer; P2 bounded-cover cubic interpolation is conditional on unrefereed quadratic theorem, and its fractional LP tautology shows dense cubic exponent-two remains open; P3 infinitary finite-palette exact recovery is a written analytic proof candidate, not independently measure-theory reviewed; P4 nested-address fixed-set risk is an elementary closed-form lower-bound construction; P5 local reproducibility is complete, GitHub full binary archival and review remain open.

**Conflict to reconcile separately:** older observability README reports AQ(3) refuted, while the later quartic audit leaves universal AQ(3) open; obtain the exact alleged counterexample before changing either mathematical status. No code in this PR depends on AQ(3).

**No automatic scientific status promotion.** Scoped audit/checker documentation may merge after source-hash and CI validation; external referee/novelty and full source-binary publication remain separate human gates.
