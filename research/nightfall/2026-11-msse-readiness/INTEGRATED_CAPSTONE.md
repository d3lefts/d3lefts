# Integrated synthetic systems-engineering capstone (SE500 / 601 / 602 / 603 / 606 / 613 / 614 / 609)
**Research status:** A complete *finite illustrative engineering study* with exact arithmetic. It is not calibrated to real equipment, not a novel information-theory theorem, not validated against production data, not a thesis defense and not graded coursework. Running the companion checker certifies only the enumerated model.

## Mission and system model
A three-component public synthetic monitoring system has binary states `x=(power,branch1,branch2)`, where 1 means a hypothesized fault. Define two repair queries and one mission alert:
- `alarm(x)=power AND (branch1 OR branch2)`;
- `repair_branch1(x)=branch1`, `repair_branch2(x)=branch2`.
Base state law: each bit independently fair, and tasks arrive with probabilities alarm `3/4`, each repair query `1/8`. In operation, this law **must** be measured rather than asserted; it is chosen here for a mathematical benchmark.

The observer may make adaptive perfect reads at one unit of recurring cost each, choosing installed sensors. Mission identity is revealed before reading. This is a state-observation problem, not full model identification or human command safety approval.

### Requirements and traceability
| ID | Mission-derived or analytical requirement | Acceptance evidence |
|---|---|---|
| R1 | Exact correct alarm and repair outputs if installed sensing primitives satisfy their contracts | Exhaustive truth-table check of all 8 states |
| R2 | Minimize expected number of reads under a *declared* state and mission distribution | Rational Bellman decision-tree DP and algebra |
| R3 | Charge every installed aggregate sensor and audit fee in lifecycle comparison | Parameter table and exact totals |
| R4 | Conditional alarm error probability at most 1% in a designated fault model | Enumerated false-negative probability; demonstrate violation |
| R5 | Recovery policy returns the correct alarm under known stuck-at-zero faults | Enumerate all 8 states x two fault modes |
| R6 | Mission or sensor-semantic changes require verifier-aware revalidation | Counterexample and change-control statement |
| R7 | Every reported result must be reproducible with no external packages | `python3 research/nightfall/2026-11-msse-readiness/capstone_exact.py` |
| R8 | Distinguish finite technical tests from scholarly theorem novelty | Status and prior-art disclosures |

These are **synthetic study requirements**, not verified customer requirements.

## Architecture alternatives and initial charges
| Design | Installed sensors | Install | Additional semantic audit | Total initial |
|---|---|---:|---:|---:|
| A (raw) | power, branch1, branch2 | 3 | 0 | 3 |
| B (augmented) | A plus a sensor giving branch1 OR branch2 | 5 | 1 | 6 |

All queries have one unit of per-use cost. The augmented sensor is not a free oracles: two installation units plus one semantic audit unit are paid before operations.

## Exact decision-tree results
The Bellman recursion finds minimum expected reads in every reachable consistent-state partition; the test enumerates all 8 source states. It is exact in this **deterministic noiseless** sensor model.

| Mission | A optimal reads | B optimal reads |
|---|---:|---:|
| Alarm | 7/4 | 3/2 |
| Repair branch 1 | 1 | 1 |
| Repair branch 2 | 1 | 1 |
| Mission-weighted mean | 25/16 | 11/8 |

Therefore for `T` operations, under this distribution and with no updates,
`C_A(T)=3+(25/16)T` and `C_B(T)=6+(11/8)T`.
The enhanced architecture becomes cheaper when `T>16`. At 24 missions, A costs `81/2=40.5` units and B costs `39`. This is an elementary, transparently model-dependent architecture trade study, not a world-first algorithm.

For a uniform prior, the optimal raw architecture reads `power` first. If it is zero, the alarm is zero. If it is one, the observer can read one branch, stopping early if faulty; otherwise it reads the other. The augmented architecture reads `power` and then the OR sensor only when power is one. Those policies yield 7/4 and 3/2 reads respectively. An exact dynamic program verifies their optimality among the installed deterministic sensors. As a sensitivity test, the program checks that adding the aggregate sensor never increases optimum expected query count at all 27 product priors with component fault probabilities in `{1/4,1/2,3/4}`.

## Fault and risk analysis: aggregate sensor stuck at zero
Suppose the added OR sensor can silently return zero on a mission with independent probability `q=1/20`, while raw component sensors remain correct. The aggressive B policy of reading power then trusting the aggregate reports a false negative whenever `power=1`, at least one branch is faulty and the aggregate is stuck. Conditional on the *alarm task*, this is exactly
`P(false negative)= (1/2)*(3/4)*q = 3/160 = 1.875%`.
It violates synthetic R4's 1% risk threshold. A fault-tolerant policy can recover exact correctness by reading both raw branch sensors as needed whenever the aggregate says zero, but it can forfeit the observation-cost improvement. This illustrates that architecture choice must optimize reliability and verification together, not only expected query count.

### Mini failure-mode analysis (qualitative, not production FMEA scoring)
| Failure mode | System effect | Detection / mitigation |
|---|---|---|
| Aggregate sensor stuck zero | Missed alarm | Check raw branch values before concluding safe; self-test and monitor discrepancy |
| Component power sensor wrong | Both raw and augmented decisions misled | Redundant independent confirmation for consequential decisions |
| Mission rule changes silently | Previously valid output interpretation false | Authenticated mission-version handshake and scoped certificate |
| Common-cause sensor failure | Independence assumptions invalid | Explicit common-cause fault injection; diverse sensors |
| State-prior shift | Expected cost forecast invalid | Update prior estimates; re-run exact policy optimization |
| Incorrect source-to-proof bridge | Formal proof certifies wrong system semantics | Verify typed source, sensor meaning and signed configuration |

## Audit protocol
Run `python3 research/nightfall/2026-11-msse-readiness/capstone_exact.py`. It uses the Python standard library and Fraction arithmetic. Reported output includes 218 assertion groups. **Those are assertions, not independent blind trials.** A separate reviewer should reimplement the Bellman recursion, attack independence and fault-state assumptions, and check whether the aggregate could be cheaper/equivalent in competing architectures.

### Next thesis-level step
Replace this toy model with a public or adviser-approved modular system with **documented** state priors, sensor-error estimates, unit costs, and a real mission loss. Compare architectures under a fixed reliability threshold, test prior mismatch, add authenticated local updates, and establish a new theorem or impossibility result beyond classical test cover and optimal decision trees.

**Literature scope:** This illustration is consistent with known test-cover, decision-tree optimization, active sensing, fault-tree, and engineering lifecycle-cost analysis. It cannot serve as original-thesis novelty without a new theorem or study, independent comparison and supervision.
