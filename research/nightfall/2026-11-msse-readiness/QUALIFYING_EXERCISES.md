# Systems Engineering MSSE independent qualifying practice
**Purpose:** a difficult, reproducible *practice assessment*, not course enrollment, university credit, a faculty exam, a transcript, or evidence that the author has independently solved it. NO GRADE AWARDED.

## Examination protocol (recommended)
- Freeze this file to a git commit SHA **before** attempting.
- Respond in a separate commit/PR without reading proposed answer keys or generated solutions.
- Suggested time: two 3-hour written sittings plus a 60-minute oral defense.
- Independent assessor should choose variations and supply withheld cases; do not use the same LLM to create and certify its own solutions.
- Point allocation below is an internal study rubric, not a simulated university mark.

## Written problem set (100 practice points)
**SE500: Probability/statistics (15).** For `Theta∈{-1,+1}` with equal posterior mass, `X,X'∈{-1,+1}` independent fair signs, compute exactly (i) model influence, (ii) posterior-mean influence, (iii) mean and variance of `W=Theta1*Theta2*(X-X')²/2`, with independent posterior draws; then derive a confidence bound for estimating a bounded influence under explicitly stated sampling assumptions. **Deliverables:** full derivation, Fraction checker, sensitivity analysis if posterior weights change. (15)

**SE601: Mission/requirements (10).** Define a mission requiring correct parity for 75% of requests and the first bit for 25%; write at least 8 numbered, measurable system requirements with acceptance tests, distinguish validated mission need from the assumed workload law, and build a bidirectional traceability graph to sensors/policies/verifiers. (10)

**SE602: Risk/failure (15).** Draw a fault tree for incorrect mission action incorporating task-change notification failure, sensor corruption, source-distribution shift, checker semantic mismatch and correlated sensor failure. Derive probability formulas under explicit independence assumptions; show where common-cause failures invalidate naive products. Prepare a 5-row FMEA and a mitigation/monitoring plan. (15)

**SE603: Integration, Test & Evaluation (15).** Independently implement exhaustive task-fiber checking and a minimax adaptive decision tree for all two-bit sensor subsets, with at least one corrupted-certificate negative control. Report test inputs, oracle cost semantics, change control, exact replay command, and a coverage/limitation table. (15)

**SE606: Systems Architecture (15).** Extend the binary toy to a 4-component dependency graph with a 1-node separator and 3 candidate architectures. For a fixed mission loss, distinguish actual state read access from model posterior sampling. Show when separator conditioning gives product blocks; find an explicit counterexample where this assumption fails. (15)

**SE609: Research Methods (10).** Make a theorem-type prior-art matrix against task-conditioned active observability, controlled sensing, test cover and contract assurance. Provide one real subsumption reduction or an explicit reason the scopes differ, not merely absent keywords. Pre-register a falsifiable experimental claim and a matched comparison. (10)

**SE613: Decision Analysis (10).** Formulate a belief-state decision tree with asymmetric error costs and an abstention option. Derive an exact Bayes optimal rule, value of sample information, and an example where the highest raw-model influence is not the highest actionable information. (10)

**SE614: Lifecycle Cost Analysis (10).** For A with cost `2+T(1+p)` and B with `7+T`, find the crossover as a function of `p`, then add annual discounting and an independently priced authentic update/recheck term. Identify a regime where B's benefit reverses and prove it. (10)

## Oral defense (separate, not included in 100 points)
1. Which part of the quadratic influence theorem is not yet source-level Lean certified? Give a concrete missing lemma.
2. Why does an observation partition refinement result not establish originality?
3. Which oracle can cheaply measure the parity mission, and how is its extra power charged?
4. When does a local certificate recheck bound fail because the mission semantics changed?
5. What is the smallest genuinely original claim your proposed thesis could make after a 2026 literature comparison?
6. Explain the most threatening counterexample to your favored theorem, then design a decisive falsification experiment.
7. What practical requirement would cause you to abandon the mathematical architecture's cost optimum?

## Grading protocol for an independent assessor
- Correctness/assumptions and model preservation: 40%
- Exact reproducibility / test coverage: 20%
- System-level requirements and tradeoffs: 15%
- Scope, prior art, negative tests and auditability: 15%
- Communication and oral defense: 10%

For planning purposes only: >=90% = strong benchmark; 80-89% = ready with targeted revision; <80% = remediate. These numbers are **not** US academic grades, credit units, or evidence that any assessment was completed. The file deliberately supplies prompts and assessment gates, not invented answers or scores.

## Independent assessor checklist
All checked boxes remain blank until an actual evaluation:
- [ ] Task/version/oracle inputs frozen with SHA.
- [ ] Submission independently authored and reproducible.
- [ ] Tested against withheld perturbations.
- [ ] Counterexamples and prior-art scope attacked.
- [ ] 60-minute oral defense completed.
- [ ] Named evaluator supplied feedback.
- [ ] Research integrity and AI disclosure reviewed.
