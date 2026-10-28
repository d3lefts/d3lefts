# NIGHTFALL / PHASESHIFT — public mathematical research archive

**Research lead:** Devin J. Wright  
**Research window:** 2026, primarily October  
**Release:** 2026-10-28  
**Status:** Public technical working archive, incorporating exact constructions, conditional certificates, reproducible software, and unresolved conjectures. Independent academic review remains outstanding.

The research program uses representation changes, independent verification, proof-carrying artifacts, and a strict distinction between finite results and global theorems. Competition rankings, mathematical validity, and publication priority are tracked separately.

## Principal findings

| Research area | Strongest documented result | Validation and limits |
| --- | --- | --- |
| Erdős minimum overlap | Exact 131,072-cell continuous-translation upper bound **0.380856370118029325246278763656…** | Archived six-prime NTT/CRT proof and independent checks reported passing; the 131,072-value Arena submission was rejected for exceeding the 100,000-value limit. Earlier accepted first-place score **0.3808564043546676** is separate. No new universal lower bound is claimed. |
| Werner-state distillation | Qutrit finite-copy conditional exact-rational thresholds **six: 0.448760; seven: 0.432280; eight: 0.419900; nine: 0.409600** | Certificate identities and rational margin checks passed; quantitative external four-/five-copy source inequalities remain imported premises whose primary SDP witnesses require independent replay. |
| Fourth-power finite-field retrieval | A systematic random sensing construction using certified ordinary LLL, with **at most 1,024** candidate checks on a high-probability good-design event, recovers every signal up to fourth-root phase. | Manuscript proof/AI audit and computational tests; external expert review outstanding. Arbitrary-design full-preimage enumeration can be exponential. |
| Finite Sidon (4,5) structures | Explicit 30-element set with maximum Sidon subset **17**, ratio **17/30**; finite-depth extensions analyzed. | Exact C++ subset audit and independent Python/transfer checks. Asymptotic 5/9 is established background, not claimed as a new record. |
| Exact SAT tensor network | Degree-three bipartite encoding with **s=3L−2v≤9m**, **#SAT(F)=2^(n−v)Z(G(F))**; a separate explicit mode-count bound. | 1,050 finite CNF cases plus 496 mode-count tests passed. A faster complexity corollary depends on an external published contraction theorem; no new unconditional P=NP proof. |
| Proof After Scarcity | Finite dependency-DAG causal verification framework and evidence tracking; reproducible manuscript citation triage and negative stress tests. | Mathematical and software-model results, not measured superiority of deployed search/knowledge graph systems. |
| SourceBound | Auditable source-assertion publication gate with independent source-to-triple rebinding and browser-visible checks. | Engineering prototype with synthetic and adversarial tests; independently annotated natural-web evaluation remains open. |
| Xi geometry | Fixed rank-22 continuous-shift reciprocal-semigroup positivity proof dossier and an isolated height-4-trillion zero certificate, across distinct analytic regimes. | Source-reported exact/interval certificates; no general all-rank positivity theorem or global critical-line proof. Primary source replay and mathematical refereeing remain outstanding. |
| Research methodology and contests | Human/AI collaboration with cross-verification, basin changes, exact witness audits and dated contest results. | Observational case study. Contest outcome does not establish global optimality. |

## Source manuscripts and reproduction notes

- [Erdős overlap construction](projects/erdos-overlap-paper.md)
- [Werner finite-copy source-dependent rational certificates](projects/werner-direct-margin/README.md)
- [Werner six–nine copy construction](projects/werner-correlated-6-9/RESEARCH_NOTE.md)
- [SIDON finite witness](projects/sidon-finite-30/README.md)
- [SAT-to-network theorem](projects/sat-network-compression.md)
- [Proof After Scarcity overview](projects/pas-overview.md)
- [SourceBound source audit](projects/sourcebound/CLAIM_EVIDENCE_LEDGER.md)
- [Continuous-shift rank-22 Xi theorem dossier](projects/xi-continuous-shift-rank22.md)
- [Xi program's evidence/regime distinctions](projects/xi-dossier.md)
- [Archive verification notes](AUDIT.md)

**Document-status policy:** An exact-arithmetic verifier checks an identity under its stated hypotheses. Conditional imported inequalities remain conditional. A reported certificate whose full primary objects have not been replayed is explicitly labeled source-reported. Novelty and universal theorems need separate external checks. A rejected platform submission is never called a competition advance.

## Attribution

Human research leadership: **Devin J. Wright**. Mathematical/engineering assistance across project files: GPT-6, ChatGPT Work, Claude and other credited collaborators. External authors' published theorems and foundational methods are credited in the respective manuscripts. Formal external peer-review and source-priority checks are pending.

**Publication note:** Source documents are being populated into this GitHub tree. The master reproducibility ZIP is preserved separately; a complete byte-for-byte mirror of every binary artifact should be checked against the original SHA-256 inventory before being declared complete.
