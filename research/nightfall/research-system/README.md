# NIGHTFALL Research System — Proof Passports and Mechanism Atlas

**Editorial snapshot:** 2026-10-28. **Research lead:** Devin J. Wright.

NIGHTFALL offers three connected research environments:

- **Reading Room:** source-grounded findings, a case-first homepage and a 32-document research library.
- **Workbench:** Referee, Claim Lab, Discovery Engine, and bounded exact quantum and finite-field calculators.
- **Observatory:** source-linked Proof Passports, a Mechanism Atlas and dated research evidence history.

## One source for five curated claims

The source file is docs/research-registry.js. Five claim-level records are defined: sidon30, erdos36, phase, werner, and pas. The five mechanisms and thirteen source-linked relationships also live there. This is a curated claim layer, **not a lossless replacement for all 32 research dossiers**.

Each record contains an exact statement, quantified scope, assumptions, source references, open review gates, dated correction events, and **four independent evidence dimensions**:

1. Mathematical validity
2. Reproducibility
3. Originality
4. Significance

No numerical proof score is computed by averaging these dimensions.

The registry powers the three homepage flagship cards, three original-findings links, the Sidon case, each Proof Passport, the Mechanism Atlas and the compact evidence-history preview. Five corresponding research-library documents link to their claim passports. Other research documents retain their individual source-led editorial descriptions.

## Public experiences

- Proof Passports: https://d3lefts.github.io/d3lefts/passport.html
- Sidon Passport: https://d3lefts.github.io/d3lefts/passport.html?claim=sidon30
- Mechanism Atlas: https://d3lefts.github.io/d3lefts/atlas.html
- Research Tools hub: https://d3lefts.github.io/d3lefts/exact-research.html
- Sidon Referee experiment: https://d3lefts.github.io/d3lefts/referee.html?domain=sidon

The Atlas is a **curated graph of documented relationships**, not a causal theorem or automated discovery claim. A method edge is an evidence-qualified technique. An analogy edge is an untested conceptual parallel. An open-premise edge stays unresolved regardless of visual proximity to established finite results.

## Instrument handoff

Claim Lab can explicitly import a local Referee JSON receipt. The import checks the declared format, version, domain and SHA-256 digest of the submitted input and claim; it **does not replay the computation or authenticate a verdict**. Imported records receive a TESTED / UNAUDITED label and preserve the importing user's source file reference. No claim status is upgraded automatically.

The full original receipt must be kept separately, followed by independent checker reproduction before scientific reliance.

## Maintenance contract

1. Update the canonical registry whenever a featured claim changes; carry its proof status, source premises, dates and unresolved tasks together.
2. Preserve the underlying manuscript and witness. A Passport cannot replace its source dossier.
3. An unproved source lemma or cross-domain analogy is never silently promoted into an established theorem.
4. Distinguish the internal 131,072-cell Erdős mathematical witness from the accepted Arena leaderboard input. Issue #5 (missing public archive) and issue #6 (accepted-input identity) remain separately open until documentary evidence closes them.
5. Preserve negative results and dated corrections. A source snapshot is **not** a full automatic GitHub changelog.
6. Run the research-system tests and the separate Referee mathematical tests. Static checks ensure website coherence; mathematical correctness needs domain checkers and outside review.

## Regression commands

    node research/nightfall/research-system/test.cjs
    node research/nightfall/referee/test.cjs

The dedicated research-system GitHub Actions workflow checks JavaScript syntax, canonical registry integrity, internal routes and explicit evidence boundaries.
