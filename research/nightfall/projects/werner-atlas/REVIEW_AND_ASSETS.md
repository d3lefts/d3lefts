# Werner atlas — exact assets, reviewer contract and public accessibility

**Last reconciled:** October 28, 2026 · **Public state:** tables and source-contract documents now mirrored; original exact coefficient certificates, upstream archives, private PDF manuscripts and independent Python checkers from the October 28 sessions have **not** been copied into this repository. The website never presents a named local file as a downloadable public asset.

## Artifact inventory

| Artifact group | Source checkpoint / original name | Public GitHub bytes | What can currently be examined |
|---|---|---|---|
| 1–24 qutrit threshold table | `NIGHTFALL_WERNER_ALL_BOUNDS_20261028.xlsx` merged with stronger Oct 27 direct-margin and spectator bounds | **Yes: [copy-by-copy CSV](bounds_1_to_24.csv)** | Table arithmetic and attribution; not primary proof certificates |
| 6–8 direct-margin method | `werner-direct-margin/README.md` | **Yes: [source and derivation](../werner-direct-margin/README.md)** | Published description of source assumptions, row family and independent checker protocol |
| 6–9 correlated method | `werner-correlated-6-9/RESEARCH_NOTE.md` | **Yes: [source note](../werner-correlated-6-9/RESEARCH_NOTE.md)** | Source-dependent dual method; missing full original JSON |
| 8–16 dimension-uniform exact results | `RESEARCH_NOTE(20261028-061347).md`, accompanying `verify_B.py` and JSON | **Summary reproduced [in atlas](README.md)** | Corrected coefficient contract; original JSON/checker unavailable here |
| 15–18 optimization refinements | `RESEARCH_NOTE(20261028-074050).md`, `refined_k*.json` | **Numerical ledger mirrored** | Gains and source dependence; missing JSON |
| 19–24 theorem-only exact results | `NIGHTFALL_WERNER_COMPLETE_ITERATION_20261028.pdf`; `refined_k22–24.json`, `verify_B.py` | **Numerical ledger mirrored** | Claimed margins and derivations; missing exact JSON |
| Full 1–100 ledger | `NIGHTFALL_WERNER_ALL_BOUNDS_20261028.xlsx` | **1–24 CSV + [symbolic formula](ANALYTIC_CONTINUATION.md)** | 25–100 are analytic expressions, not 76 finite LP certificates |
| Sharpened 24-seeded continuation | `B24_exact.txt`, `verify_transfer.py` | **Proof note only** | Algebraic explanation; original seed and checker pending |
| Restricted witness sector | `NIGHTFALL_WERNER_LEVERAGE_MANUSCRIPT_20261028.pdf` | **Abstracted scope in atlas** | Restricted 13.3× support-size claim; full paper pending |

**Important reconciliation:** the October 28 all-bounds spreadsheet retained weaker prior numbers at k=6–9. The atlas selects the stronger compatible Oct 27 direct-margin/correlated certificates there. It also replaces Oct 28 preliminary 22–24 values `0.36110/0.35100/0.34000` by the final checkpoint `0.36119/0.35151/0.34001`. No open-access GitHub JSON was independently rerun in this update.

## Reviewer tasks — ranked

1. **Upstream premise:** retrieve Tomar's complete posted primary sources and independently reproduce the quantitative `Q_4(4979/10000)≥229/10^7‖C‖_F²` and `Q_5(47/100)≥401/10^5‖C‖_F²` inputs as actually applied to physical, complex rank-two qutrit matrices. Report exact origin, normalization, rounded-error interpretation and independently regenerated SDP data. Treat margins as *premises* until this passes.
2. **Theorem-only certificates:** audit the published three-, four-, five-copy source inequalities and the 19–24 archive's exact independent checker. Confirm every source row, group dimensionality, spectator separability, positive rational weight, strict residual and complete coefficient identity. Separate valid theorem-only transfer from margin-dependent improvements.
3. **Dimension-uniform case:** reread the Costa Rico theorem using trace-difference coefficient `−1/2` rather than the rejected `−1`. Re-run the corrected 8–16 verifier with complex matrices, rank ≤2, all d≥3, and physical copy budget.
4. **Analytic finite-k:** independently rederive the trace-zero projection coercivity lemma, reconstruct `B24_exact.txt`, replay `verify_transfer.py` and test the exact 25-copy symbolic positivity. Establish the precise prior-art boundary.
5. **Restricted compression:** verify `K_j−a_jI∈Sep(A:B)` for the encoded subspace blocks. Keep the 21-copy 13.319× support ratio explicitly distinguished from unrestricted Werner k-copy thresholds.

**Adversarial checks:** reject an entangled maximally-entangled projector used as a *spectator* of a mere rank-two-positive source; reject missing copy-budget accounting, negative exact rational multipliers, falsely rounded SDP slacks, falsely inferred general-dimensional conclusions from qutrit rows, and failed 25-copy floating-point feasibility.

**Publication release gate:** when original JSON/checkers/manuscript archive bytes can be uploaded, record their SHA-256 checksums, publish a GitHub Release or content-addressed assets, independently run the source and downstream verification, and link **only confirmed** public URLs. The repository currently supplies a readable claim ledger, **not** a complete public proof replay. Mathematical novelty and original source inequalities require external specialist scrutiny.

**External work:** [review issue #2](https://github.com/d3lefts/d3lefts/issues/2) · [site reviewer guide](https://d3lefts.github.io/d3lefts/review.html#werner).
