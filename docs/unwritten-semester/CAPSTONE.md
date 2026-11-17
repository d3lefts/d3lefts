## The mission

**AURORA** is a fully synthetic remote environmental monitoring network. Three simulated channels observe a latent binary anomaly. A shared disturbance can disable all channels; additional independent failures and noisy readings create uncertain evidence. A decision rule raises an *advisory* alarm. Nothing is connected to infrastructure or people, and no result is calibrated for real-world use.

Your task is not to tune a threshold until the plot looks good. Your task is to produce a **decision-ready, source-traceable, adversarially testable research case** for one architecture under explicitly bounded assumptions.

## Starter laboratory

From the course root:

```bash
python3 labs/aurora.py --seed 2026 --trials 5000 --policy quorum --out labs/output.csv
python3 labs/audit.py labs/output.csv
python3 -m unittest discover -s labs -p 'test_*.py' -v
```

Run the other policies on the **same seeded world**:

```bash
python3 labs/aurora.py --seed 2026 --trials 5000 --policy any --out labs/any.csv
python3 labs/aurora.py --seed 2026 --trials 5000 --policy single --out labs/single.csv
```

### Checked reference run

With seed `2026`, `5000` simulated episodes, default event prevalence `0.15`, common-mode failure probability `0.025`, and the `quorum` policy, the archived trace yields:

| Quantity | Exact count | Simulated fraction |
|---|---:|---:|
| Misses among events | 72 / 724 | 0.09945 |
| False alarms among quiet episodes | 39 / 4276 | 0.00912 |
| Episodes with enough available channels for quorum | 4786 / 5000 | 0.95720 |
| Sensor acquisition cost | 16 units / episode | fixed by policy |

These are **real outputs from the supplied synthetic code**, not measured real-world performance or certified probabilities. The event and non-event denominators differ and must not be mixed.

The independent trace checker verifies the declared policy's arithmetic and cost convention. It does not validate random-number quality, the source generator, statistical assumptions, calibration, or field safety. The unit tests are a second useful guard, not an independently conducted scientific review.

## Four deliverables

### I. Frame the mission

Provide a context and responsibility diagram, at least six operational scenarios, five measurable requirements, a requirements-to-evidence graph, and an assumption register. Distinguish a synthetic measurement from a real-world need. State who has authority to choose the loss function and authorize action.

### II. Construct the case

Provide an architecture and common-cause failure model; a model card; a preregistered policy comparison; per-policy miss, false-alarm, operability, and cost metrics with denominators; and a declared Pareto analysis. Analyze at least one parameter shift and an observation design that could change the decision.

### III. Attack the case

Produce at least two adversarial counterexamples, a failure tree, and two different reviewer protocols: one that independently recomputes reported trace decisions and another that attacks model assumptions or prior-art comparison. Deliberately corrupt a test trace and demonstrate that the independent arithmetic checker rejects it. Record all findings, including failed attacks.

### IV. Defend the case

Release a provenance manifest with command lines, source and data hashes, model limitations, known unresolved issues, an evidence passport, a change-impact table, and a concise defense packet. A valid defense can conclude “insufficient evidence for deployment”; this is preferable to an unjustified green status.

## Assessment rubric (100 points)

| Criterion | Weight | Full-credit condition |
|---|---:|---|
| Problem formalization | 20 | Mission, boundaries, falsifiers, and comparator are all explicit |
| Modeling and architecture | 20 | Causal assumptions, interfaces, shared failures, and sensitivities are inspectable |
| Experiments and decisions | 20 | Preregistered, paired where applicable, full denominators, legitimate trade-space comparison |
| Assurance and independent criticism | 25 | Recomputable trace, scoped evidence, adversarial tests, properly separated validation |
| Research communication and transfer | 15 | Reproducible release, clear limitations, honest novelty claim, viable next experiment |

**Non-negotiable gates:** fabricated evidence, undocumented data exclusions, a claimed field safety certification, or knowingly invalid comparisons void the submission independent of numeric score. A checker pass earns no automatic doctoral credit.

## Suggested schedule

- Session A: formalize mission, scope, requirements (3–5 hours).
- Session B: model alternatives and preregister the experiment (3–5 hours).
- Session C: run tests, audit, sensitivity, and counterexamples (4–6 hours).
- Session D: version the evidence, rebut critic, write and defend (4–6 hours).

This is an educational exercise. A real thesis additionally requires original research, appropriate institutional supervision, independent scholarly review, research ethics, and the degree-granting institution's rules.

## The exit standard

You succeed when a new reader can answer **what was claimed, what would disprove it, how the result was generated, whether the checker checked the right property, what was left untested, and what should happen after a material source change**—without relying on your personal explanation.

## Executable extension: evidence that survives a critic

The [field toolkit](toolkit.html) and [quantitative bridge](math-bridge.html) make four new capstone submissions testable:

1. **Paired decision analysis:** show the synthetic policies evaluated on identical latent episodes; report the loss assumptions, conditional rate differences, percentile bootstrap interval and a prevalence-sensitivity boundary.
2. **Finite abstraction proof:** report the complete 27-state enumeration and provide a counterexample to a stronger false claim. State why the physical deployment is not covered.
3. **Change impact:** seal a SHA-256 manifest and declared dependency graph, change a tracked file, demonstrate recheck propagation, and document an unmodeled dependency.
4. **Adversarial defense:** demonstrate an invalid unpaired experiment being rejected and a mutated policy violating a formal-style invariant. Differentiate algorithmic checks from external review.

These are additional exercises; they do not change the capstone rubric weights or imply independent scientific certification.
