# NIGHTFALL — Lifecycle-optimal authority research contract v0.1

**Date:** November 15, 2026 UTC. **Research direction:** Devin J. Wright; AI-assisted mathematics and Lean formalization. Status: exact-current-head Lean CI is the authority; never infer proof from a submitted source file.

## Formal objective

Finite-horizon source-bound lifecycle authorization with arbitrary belief spaces, adversarial finite-alphabet observations, authenticated current certificate/source epochs for effects, explicit mission goal and safety invariant, and a cost sum covering evidence acquisition, verification, certificate repair and effect-time enforcement.

Policies are contingent functions of observation history, not static evidence certificates. Feasibility (a policy completing the mission for every admissible observation) is explicit. The exact objective is the WORST-CASE sum of stage costs. Unbounded lifetime and noisy probability-risk objectives are excluded.

## Named theorem and certificate requirements

1. admitted_effect_current: protected effects require current source/certificate version equality.
2. operational_step_safe: a valid plan plus a declared forward simulation transfers modeled safety to one actual operational step.
3. execution_all_safe: inductive safety along ALL states of a finite actual execution trace.
4. globally_optimal_lifecycle_policy_exists / min_cost_attained: exact least-cost policy existence for the full contingent feasible class, with matching lower bound over all competitors, using Nat well ordering.
5. fixed_first_action_bellman: for any feasible first action, replacing every possible observation continuation with an optimal feasible continuation cannot increase worst-case cost.
6. reusable_after_irrelevant_change / changed_dependency_invalidates / reusable_union_iff: exact dependency-local version-based certificate reuse and compositionality.

Kernel certificate: pinned Lean 4.36.0-rc2 / Mathlib, strict direct source build, named theorem statements, standard axiom list, source SHA-256. No sorry, no custom axioms or hidden probabilistic premises. CI is the source of proof status.

## Criticism and limits

The operational forward-simulation relation is itself an ASSUMPTION; it is not constructed for the real NIGHTFALL source-binding service, AWS, an industrial plant, or arbitrary agents. This assumption includes a complete observation model and faithful actual-to-belief transitions. Source/version equality does not imply truthful external attestation. Validity of a certificate after unchanged dependency versions also requires the dependency list to be complete, which is not guaranteed by this theorem. Global minimum existence does not supply an efficient implementation, and a feasible completion policy need not exist. A finite result for EVERY natural horizon is not the same as infinite-horizon optimality.

This is a rigorous conditional theorem with classical mechanisms (safety-game induction, minimum-of-natural-numbers principle, branchwise Bellman optimization, source version dependency logic). It is NOT certification of worldwide originality or unrestricted universal superintelligence safety.

## Independent audit plan and cheapest decisive test

First, falsify any missing-source/version coverage premise using paired indistinguishable actual worlds with different effect safety. Second, enumerate every finite trace of a tiny version-advance, recertify, revoke, promote service and compare source/version validity to actual code in draft PR #579. Third, obtain an independently authenticated source snapshot and independently synthesized baseline to discharge source authenticity, and test a deliberately false attestation. Fourth, compare the certified optimal cost to exhaustive history-policy enumeration using independently authored code. Finally, compare against identical-interface incremental-analysis and task-conditioned observability baselines.

Budget/stop rule: do not claim operational refinement, physical system soundness, implementation optimality or global historical novelty unless each supporting source-to-deployment lemma has separately verified evidence and independent scholarly review. Do not merge or publicly publish without human authorization.

## Discovery graph

Problem → lifecycle evidence and justified action.
Representation → finite belief, source-epoch custody, adversarial policy tree.
Mechanism → validity under all possible branches, exact worst-case cost, per-dependency reuse.
Operator → global minimality, Bellman optimal-continuation substitution, forward-simulation safety.
Construction → attained least-cost policy and conditional certified step execution.
Certificate → pinned Lean compile, named axiom receipt and immutable artifact.
Limitation → actual-to-model mapping and authenticated source provenance remain external.
Transfer → scoped local artifact service, then external effects only after complete mediation is evidenced.
