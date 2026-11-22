# Task-equivalent measurement-effect simulation certificate

**NIGHTFALL Proof Passport supplement — 2026-11-22.** Source tier: `analytic`; Merged / paper candidate + exact finite. This is a claim-specific evidence sheet, not an automatic proof or originality promotion.

## Exact claim

For two-query parity circuits with ordered nonzero pair-fiber cap M, an author-side simulator pays O(M Θ_task/(ε²δ)), where Θ_task minimizes centered trace norm over behaviorally equivalent terminal effects.

## Hypotheses and scope

Uniform linear-parity source, nonuniform deterministic classical row queries, fixed quantum state family; low task-visible trace is an explicit sufficient condition.

## Mechanism / operator

Conditioned vector amplitude, trace/Bessel light-sector bounds, signed spectral truncation, equivalent-effect SDP.

## Evidence and reproducible certificate

Merged archival #1002; exact-rational source CI #45050473197, including full-span examples and a ≥19× certificate-compression witness.

- Source pull request: https://github.com/d3lefts/d3lefts/pull/1002
- Historical source head: `75e7cba9907baad4345322a69d49eb881fa74d05`
- Finite/evidence CI (not named Lean theorem): https://github.com/d3lefts/d3lefts/actions/runs/45050473197
- Named declaration or research object: `Author-side operator inequality and finite SDP formulation; not Lean certified`
- Supporting source or archival note: https://github.com/d3lefts/d3lefts/pull/1002

## Precise limitation and negative controls

All-circuit proof not independently reviewed or Lean-certified; no general polynomial Θ_task bound or quantum advantage established.

The effective trace parameter is optimized over effects with equal probabilities on all reachable states. The >=19× separation concerns a sufficient-bound coefficient, not actual classical query cost. The all-circuit rank-free case is a distinct, unreviewed proof candidate #1016 and is not imported as a theorem.

## Novelty, prior art and credit

NIGHTFALL research, standard trace ideals, Bessel, quantum query polynomial antecedents.

**Status gate:** historical priority is unresolved without source-level comparison and specialist independent criticism. Paper/finite results are not automatically promoted to a general theorem or named Lean certificate.

## Next cheapest decisive experiment or adversarial audit

Independent adversarial proof and literature review; investigate whether Θ_task can be uniformly polynomial in L.

**Certificate discipline:** preserve the input source, exact branch/head, checker and run identity, statement, hypotheses, negative tests and unproved dependencies with any downstream quotation. A new mathematical assertion requires a separately reviewed proof passport.
