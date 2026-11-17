## A quantitative bridge for terminal-degree research

The Unwritten Semester is a short *research-methods supplement*, not the complete mathematical content of a PhD or EngD. A terminal-level systems engineer needs deep competence in multiple technical families. This bridge identifies a rigorous minimal path and makes the math connect to the AURORA laboratory. It is a **study map**, not an accreditation claim or a full treatment of these subjects.

## 1. Probability, stochastic processes and reliability

AURORA generates independent synthetic *episodes*, but readings within an episode are correlated because a common outage can disable every channel. Unconditional channel independence is therefore false.

Let `G` indicate a common outage with probability `q`. If `G = 1` forces every sensor unavailable, then

<div class="equation">P(A = B = C = NA) ≥ P(G = 1) = q</div>

This inequality needs no independence assumption. Replacing the right-hand side by a product of individual outage probabilities without conditional justification would be incorrect. **Exercise:** show how mission failure probabilities change when `q` varies, and calculate an interval for an observed binomial failure count under the explicitly assumed independent-episode model. Explain why no finite sample rules out an unmodeled failure mode.

**Beyond this course:** measure-theoretic probability, Markov chains, renewal processes, Bayesian estimation, survival analysis, fault trees, and dependent reliability models.

## 2. Dynamic systems, control, and observability

AURORA currently has no physical plant dynamics. To study feedback, introduce a separate model

<div class="equation">x<sub>t+1</sub> = Ax<sub>t</sub> + Bu<sub>t</sub> + Ew<sub>t</sub> &emsp; y<sub>t</sub> = Cx<sub>t</sub> + v<sub>t</sub></div>

For a noiseless, time-invariant, two-state system, the observability matrix is `O = [C; CA]`. Take

<div class="equation">A = [[1, 1], [0, 1]] &emsp; C₁ = [1, 0] &emsp; C₂ = [0, 1]</div>

Then `O₁ = [[1, 0], [1, 1]]` has rank 2 while `O₂ = [[0, 1], [0, 1]]` has rank 1. Thus the first sensor configuration can reconstruct the initial state in the idealized noiseless model; the second cannot. **Exercise:** write both matrices exactly, compute ranks by elimination, and exhibit two different initial states with identical measurements under `C₂`.

For a separate scalar system `xₜ₊₁ = a xₜ + wₜ` with `|a| < 1` and `|wₜ| ≤ W`, iterating the recursion gives

<div class="equation">|x<sub>t</sub>| ≤ |a|<sup>t</sup>|x₀| + W(1 − |a|<sup>t</sup>)/(1 − |a|)</div>
<div class="equation">lim sup<sub>t→∞</sub> |x<sub>t</sub>| ≤ W/(1 − |a|)</div>

This is an exact bounded-disturbance result under its hypotheses, not a claim about AURORA. **Exercise:** derive it by induction and identify the failure when `|a| ≥ 1`.

**Beyond this course:** state estimation, Kalman filtering, robust and optimal control, Lyapunov theory, hybrid systems, decentralized control, and partial observability.

## 3. Decision theory, optimization, and operations research

A design is optimal only relative to a feasible set, objective, and uncertainty model. Given event probability `p`, false-alarm cost `C_FP`, miss cost `C_FN`, and policy-specific conditional rates `f, m`, one stipulated loss is

<div class="equation">R = p C<sub>FN</sub>m + (1 − p) C<sub>FP</sub>f + λc</div>

This is the same model implemented by `labs/compare.py`. The accompanying `labs/exact_switch.py` computes the observed decision-switching prevalence using exact rational arithmetic. If two policies have identical acquisition costs, their preference changes when

<div class="equation">p C<sub>FN</sub>(m<sub>A</sub> − m<sub>B</sub>) + (1 − p) C<sub>FP</sub>(f<sub>A</sub> − f<sub>B</sub>) = 0</div>

Solve this equation symbolically for a decision-switching prevalence, then check whether the solution lies in `[0,1]`. **Exercise:** perform a sensitivity sweep and formulate a minimax choice when `p` belongs to an interval rather than being known exactly.

**Beyond this course:** convex analysis, linear/integer programming, stochastic programming, duality, multiobjective optimization, and game theory.

## 4. Experiments, uncertainty quantification, and causal inference

A fixed seed supports *replay*, not empirical *replication*. A bootstrap on synthetic episodes can assess Monte Carlo variability given the generator but cannot rescue an incorrectly specified model. Paired experiments control for common random conditions: policy A and policy B should be compared on the same latent states when the estimator assumes pairing.

Causal claims require an intervention or a justified identification strategy. A model that reproduces correlations does not by itself show how a new sensor or control policy would alter outcomes. **Exercise:** draw a directed graph with common outage, local sensor failure, event state, readings, and alarm decision. Identify which edges are assumptions and which can be tested in the simulator.

**Beyond this course:** design of experiments, randomization, robust confidence sets, sensitivity analysis, causal identification, nonparametric inference, and model discrepancy.

## 5. Formal methods, software verification, and assurance

Finite-state model checking evaluates an explicitly represented transition or decision model. The supplied `labs/modelcheck.py` enumerates all 27 observable readings in a **memoryless** sensor abstraction. Adding timing, network partitions, stale data, human authority, or a dynamic plant changes the state space and the meaning of the claims.

A valid formal theorem has the form `A ⇒ P`, where assumptions `A` match the actual system being reasoned about. A kernel checker confirms a derivation from stated hypotheses; separately establish that the hypotheses are discharged and that the theorem is relevant to the operating world.

**Exercise:** specify an invariant for freshness of actionable sensor readings. Add `STALE` to the abstraction, test it exhaustively, and distinguish an implementation counterexample from a specification counterexample.

**Beyond this course:** temporal logic, automata, model checking, refinement, proof assistants, compositional verification, and formally specified runtime enforcement.

## 6. Human, organizational, and systems-of-systems decisions

A technically optimal detector may be institutionally illegitimate. Operational authority, accountability, interfaces, privacy, and the cost of inappropriate action enter the model before its objective function can be defended. A systems-of-systems design must also account for independently governed components whose behavior or availability can change.

**Exercise:** assign a distinct party to define mission loss, authorize deployment, validate evidence, and audit the result. State which decisions cannot be delegated to code or inferred from synthetic data.

**Beyond this course:** socio-technical systems, engineering ethics, governance, mission engineering, procurement, lifecycle economics, and institutional assurance.

## Oral-qualifying examination challenge

Without running code: (1) prove the common-outage lower bound; (2) compute the two observability ranks; (3) derive the scalar disturbance bound; (4) solve the two-policy decision-switch equation; (5) give one exact statement that the finite checker establishes and one that it does not; (6) identify a real-world observation that would invalidate using AURORA to recommend a field policy.

A credible response states all assumptions and the limits of each conclusion. A written solution without those limits is incomplete.

## Recommended source texts

- [SEBoK](https://sebokwiki.org/wiki/Main_Page) — disciplinary breadth, lifecycle processes, and systems engineering practice.
- [NASA Systems Engineering Handbook](https://ntrs.nasa.gov/citations/20170001761) — engineering processes, reviews, risk, technical baselines, and V&V.
- [INCOSE Systems Engineering Handbook, 5th edition](https://www.incose.org/resources-publications/technical-publications/se-handbook/) — detailed systems engineering lifecycle practice.
- [NIST/SEMATECH e-Handbook of Statistical Methods](https://www.itl.nist.gov/div898/handbook/) — experimental design and statistical analysis.
- [NASEM: Reproducibility and Replicability in Science](https://nap.nationalacademies.org/catalog/25303/reproducibility-and-replicability-in-science) — scientific evidence and replication.
