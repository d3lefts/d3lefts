# SourceBound — claim/evidence ledger (2026-10-27)

| Research statement | Reported evidence | Scientific limit |
|---|---|---|
| Previously accepted 18 adversarial F4 unsafe cases | archived reviewer cases and pre-revision replay | these adversarial examples were known before repair |
| Revised gate rejects 18/18 F4 cases | post-fix external replay | repaired regression, not blind generalization |
| 14,000 synthetic pages, 6,000 labelled assertions | synthetic fixture evaluator | fixture-label agreement only |
| 600 altered records rejected | mutation tests | restricted grammar, no general semantic entailment |
| Browser cross-checks detect visibility/parser issues | Chromium synthetic-page suite | does not prove safe handling of every live website |
| Entity lineage/version linking | executable smoke and unit tests | small in-memory prototype |
| Generalization to new natural websites | untested | **unclaimed** |
| Improved downstream answer quality at matched recall | untested | **unclaimed** |
| Superiority to published extraction methods | untested | **unclaimed** |

The design separates extraction from a second-stage publication boundary. An independent *restricted* evidence-to-triple re-binding path catches mismatched subjects, relations, objects and qualifiers. Source digests establish identity of archived text, not factual truth.

The full tests, fixtures, manuscript and source are included in the separately prepared reproducibility archive. See [the research manuscript transcription](sourcebound-revision3-extracted.txt) for methodological details. Attribution: Devin J. Wright, with AI-assisted implementation and separate reviewer-supplied adversarial examples.
