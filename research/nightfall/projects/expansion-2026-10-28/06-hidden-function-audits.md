# Dossier 06 — Hidden-function interpretability audits

**Sources:** \`Hidden_Function_Audit_Research_Note.pdf\`, \`Hidden_Polysemanticity_Frontier_Paper.pdf\`, 2026-10-16. **Status:** exact finite-field demonstrations and preregisterable methodology; **no frontier neural-model effectiveness claim**.

## Research question

An explanation that predicts a high activation on some examples need not identify *every* causal function of that unit. The research objective is to **falsify explanatory completeness** through controlled high-activation examples, competing interpretations, and matched causal interventions, with explicit abstention when structural coverage cannot be justified.

## Paired observational–causal residual

For a fixed model, unit, response functional \(F\), and declared intervention \(I\), let \(a(x)\) be signed activation and \(\Delta_I(x)=F(x)-F_I(x)\). A candidate explanation \(H\) predicts \(\hat a_H(x)\) and \(\hat\Delta_H(x)\). Its paired residual is
\[
R_H(x)=(a(x)-\hat a_H(x),\ \Delta_I(x)-\hat\Delta_H(x)).
\]
A claimed causal-completeness certificate must account for **both** channels, both activation signs, exact transformation assumptions, and the tested input family. If a model lacks a justified sparse-orbit assumption, a finite sample alone cannot certify absence of an arbitrarily rare hidden trigger.

The finite-field demonstration on a 31-state cycle reports a two-channel, three-frequency example uniquely recovered from five observations and a four-observation rank-two collision. This is a controlled algebraic case built using established sparse spectral/MMV theory, **not** a discovery of hidden goals in a trained language model. A single-state exceptional trigger escapes a sparsity-limited five-probe audit.

## Prospective adversarial protocol

The wider \`Finding Hidden Polysemanticity\` paper proposes six search arms: corpus-stratified probes, explanation-counterexample generation, structure-guided search, circuit-disagreement search, representation comparison, and blinded planted-mechanism model organisms. Freeze hypotheses, intervention definitions, budgets, validity criteria, and held-out evaluation **before** seeing final results.

Classify candidate findings separately:
1. Strong activation outside the proposed explanation.
2. Reproducible semantic difference under validated transformations.
3. Causal effect under a fixed intervention.
4. Discovery of a distinct behavioral mechanism.
5. Model-level hidden-goal identification (requires much more evidence).

Do not infer step 5 from step 1. Report abstention when held-out tests, completeness assumptions, causal control, or provenance are absent.

## Audit and public-release needs

- \`Hidden_Function_Audit_Research_Note.pdf\`
- \`Hidden_Function_Audit_Reproducibility.zip\`
- \`Hidden_Polysemanticity_Frontier_Paper.pdf\`
- \`Hidden_Polysemanticity_Research_Package.zip\`
- \`Exclusion_Aware_Interpretability_Code_Results.zip\`

These primary binaries and their immutable hashes need a public release asset. This text dossier preserves the proposal and its scope; it does not claim the complete experimental package has been independently mirrored.

**Next decisive experiment:** a preregistered blind benchmark, with native units, SAE baselines, paired interventions, rare-trigger controls, false discovery rate, recall against known planted mechanisms, and truly held-out validation.
