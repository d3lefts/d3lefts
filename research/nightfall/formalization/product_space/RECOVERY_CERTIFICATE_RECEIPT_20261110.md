# NIGHTFALL recovery: finite theorem and exact audit certification receipt

2026-11-10 · Research lead Devin J. Wright · AI-assisted proofs and checks
**Status: 13 scoped Lean declarations PASS, exact finite audit 952/952 PASS; infinite-product exact recovery NOT Lean-certified.**

## Frozen verification chain

| Component | Compiled/tested claim | Exact source / manifest | CI result |
| --- | --- | --- | --- |
| Finite switching core, 7 named declarations | Explicit low-support finite degree survives disjoint Boolean-block switching; sensitivity mapping | FiniteSwitchingCore.lean, SHA256 5cd35e8c14078c993dd71dfb39d97a34fd4955b72b8c497495940a7df46b675c | [run 42916562788](https://github.com/d3lefts/d3lefts/actions/runs/42916562788) PASS; merged via PR #301 |
| Finite sections + positive atoms, 5 named declarations | Prefix section of explicit low-support sum retains degree; nonconstant finite section has positive-mass changing resampling | FiniteSectionSensitivity.lean, SHA256 5f8592b0de6bbf47e8c182c7918501768b096e409357962817fec486488d4595 | [run 42920126907](https://github.com/d3lefts/d3lefts/actions/runs/42920126907) PASS; draft PR #306 |
| Weighted energy/Cauchy, 1 named declaration | Given explicit zero-mean witness, cross inner product and positive energy e, and squared range R2, prove e <= R2 * mass of changing atoms | FiniteEnergyCauchy.lean, SHA256 ebca758a57e50a5d7b3a8ae0834a8006fcea9f0698abe57ab52fcc93451c45a5 | [run 42920968888](https://github.com/d3lefts/d3lefts/actions/runs/42920968888) PASS; draft PR #306 |
| Exact-rational finite ANOVA checker | Reconstruction, component centering, conditional section degree, max-order conditional variance and quantitative block sensitivity | check_finite_anova_recovery.py; SHA256 output archived in GitHub Actions artifact | [run 42921346171](https://github.com/d3lefts/d3lefts/actions/runs/42921346171) PASS, 952 cases |

Pinned proof assistant: Lean 4.35.0, Mathlib v4.35.0. Declared and audited accepted axioms were **Classical.choice**, **Quot.sound**, **propext**, and no custom axioms / sorryAx. The theorem statuses are limited to their stated, finite and conditional hypotheses.

## Corrected failures (not suppressed)

- [run #42916194182](https://github.com/d3lefts/d3lefts/actions/runs/42916194182): missing DecidableEq Query in an earlier switching-support declaration; compiler produced sorryAx dependencies; fixed at 6c8da9d, followed by successful full rebuild.
- [run #42920379985](https://github.com/d3lefts/d3lefts/actions/runs/42920379985): an incorrect *use of a Lean multiplication-order lemma* in energy cancellation; compiler rejected the declaration. Replaced with a strict inequality contradiction at commit 42629e6. The repaired module then compiled with standard axioms only at run 42920968888.

Neither compile error is evidence of a false mathematical inequality. They are preserved as failed proof artifacts.

## Mathematical consequence (written proof, not fully kernel checked)

For finite/countably many independent coordinates, a bounded f of Hoeffding degree k>=1 and a top-order nonzero interaction f_S with |S|=k and energy e_S=||f_S||²>0, the ANOVA-centered structure gives for almost every complement z:

    Var_U f(z,U_S) >= e_S,
    P_U[f(z,U_S) != f(z,v)] >= e_S/R²

for almost every original value v on S, with R>0 its output range.

The proof is written in MAXIMAL_INTERACTION_QUANTITATIVE_SENSITIVITY_20261110.md. The *last algebraic implication* from weighted orthogonality/centering to resampling mass is now kernel checked, but deriving its premises from weighted Hoeffding conditional projections remains an explicit unformalized dependency. This energy lemma is a natural classical orthogonality consequence and is **not claimed original**.

## Adversarial counterexamples

1. f(x,y)=1{x=y} under independent Lebesgue law has degree zero in L² yet arbitrary measure-zero changing replacements create a degree-two hybrid Boolean cube. Therefore positive-measure sensitivity and Fubini are essential; pointwise arbitrary witnesses are invalid.
2. A source bit controlled by XOR of two Boolean switches increases degree from one to two; only disjoint switching assignments are legitimate.

## Checkpoint, boundary, next decisive proof obligation

The underlying arbitrary-product exact-recovery manuscript v0.2 proposes d³ min{(q−1)²,R/Delta} adaptive coordinate observations (q finite) and its Boolean d³ corollary. The present certificates do **not** prove the whole theorem, the countable/completed-product measurable-selection bridge, the maximal-order Hoeffding orthogonality derivation, the finite-palette polynomial/block-sensitivity conclusion, or historical priority.

Next cheapest decisive formalization: build finite normalized positive-atom product conditional expectations, the actual weighted Hoeffding f_S components and orthogonality identity, then apply the already certified FiniteEnergyCauchy theorem. Only after that is complete attack countable L² section approximation, measurable energy/selection, Fubini orientation, and a.s. decision-tree correctness. Independent human proof review and source-to-source novelty search remain separate.

**No external submission or scientific claim-status promotion. PR #301 merged the original switching core; follow-on PR #306 remains DRAFT and UNMERGED.**
