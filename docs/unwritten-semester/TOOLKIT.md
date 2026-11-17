## The reproducible toolchain

The 14 sessions teach research judgment; this toolkit supplies executable instruments for some of those judgments. Everything in this section uses **Python 3.11+ and the standard library only**. It makes claims about a synthetic instructional model, never about deployed monitoring infrastructure.

The reference problem is AURORA: three binary/absent sensors, a shared-outage variable, three acquisition policies, and a choice between detecting anomalies and avoiding false alarms. The code is deliberately small enough to read line by line.

| Tool | Question answered | What it does **not** establish |
|---|---|---|
| `labs/aurora.py` | What does this assumed generator produce? | A physically valid sensor model |
| `labs/audit.py` | Are policy decisions and reported totals consistent with trace bytes? | Correctness of data-generation assumptions |
| `labs/compare.py` | Under stated costs and prevalence, which observed policy has lower expected loss? | A valid deployment prevalence, costs, or robust superiority |
| `labs/modelcheck.py` | Do four safety-style invariants hold in all 27 abstract sensor states? | Physical-system safety or equivalence to the simulator implementation |
| `labs/passport.py` | Have named files changed; which declared dependent claims must be revisited? | Genuine provenance, complete dependency coverage, or permission to act |

## Lab A — Paired experiments and decisions

Generate exactly the same latent episodes for `any` and `quorum` by holding the seed and generator parameters fixed:

```bash
python3 labs/aurora.py --policy any --seed 2026 --trials 5000 --out labs/any.csv
python3 labs/aurora.py --policy quorum --seed 2026 --trials 5000 --out labs/quorum.csv
python3 labs/audit.py labs/any.csv
python3 labs/audit.py labs/quorum.csv
python3 labs/compare.py labs/any.csv labs/quorum.csv --prevalence .15 --false-alarm-cost 2 --miss-cost 12 --acquisition-weight .05 --bootstrap 800
```

With `left=any` and `right=quorum`, the comparator reports a **left-minus-right loss difference**. Negative means `any` is better for the stipulated loss function; positive means `quorum` is better. A negative difference in miss rate can coexist with a positive overall loss difference because false alarms and misses are different errors.

For an exact rational crossing of the two *observed* loss curves, run:

```bash
python3 labs/exact_switch.py labs/any.csv labs/quorum.csv
```

The output reports an exact fraction (for the provided run and costs, `19910/80843`, about 24.63% event prevalence). That boundary is exact **conditional on the observed trace counts and stipulated losses**, not an exact environmental prevalence or population-optimal decision.

The estimand, for target event probability `p`, is

<div class="equation">ΔR = p C<sub>FN</sub>(m̂<sub>A</sub> − m̂<sub>B</sub>) + (1 − p) C<sub>FP</sub>(f̂<sub>A</sub> − f̂<sub>B</sub>) + λ(c̄<sub>A</sub> − c̄<sub>B</sub>)</div>

Here `m` is the conditional miss rate, `f` the conditional false-alarm rate, `c` acquisition cost, and `C` and `λ` are stipulated loss parameters. The implementation pairs **identical episodes** and resamples event and quiet strata separately. The percentile bootstrap interval represents finite synthetic-sample variability under an independent-episode approximation; it does not quantify uncertainty in the assumed physical model, costs, or target prevalence.

**Experiment:** vary `--prevalence` to `.02` and `.40`, holding *both traces* fixed. Record whether the decision changes. Then deliberately compare against a second trace with seed `2027` and verify that the checker rejects the mismatched worlds rather than presenting an invalid paired comparison.

**Acceptance:** a table of risk differences, units, interval bounds, experimental conditions, and the first prevalence at which the preferred policy flips. Mark any extrapolation beyond the model explicitly.

## Lab B — Finite-state adversarial model checking

```bash
python3 labs/modelcheck.py
```

The checker enumerates all `3³ = 27` observable triples over `{NA, 0, 1}` and tests four properties: every alarm requires enough observations for its policy, quorum alarm implies any alarm, full absence of observations produces no alarm, and a quorum alarm requires at least two positive observations.

A 27-state exhaustive check is a proof by enumeration **for the named finite abstraction**, assuming the enumerator is correctly implemented. It is not a mechanized kernel proof, nor does it establish whether physical sensors implement the abstraction. A test also injects a defective quorum implementation and confirms that the checker detects it.

**Experiment:** add a fourth state `STALE` to the model. Define which policy, if any, may use stale data. State an authorization/freshness invariant before editing code. Run exhaustive checking again, find a counterexample if the invariant fails, and keep both the counterexample and corrected statement.

**Acceptance:** a state-space definition, invariant list, exhaustive-state count, one genuine counterexample to a false stronger claim, and an explanation of the abstraction-to-implementation gap.

## Lab C — Evidence passport and change-impact gate

The manifest records SHA-256 content hashes. It is intentionally labeled an **unreviewed byte-identity manifest**: a digest alone cannot establish who generated data, what the algorithm means, or whether a reviewer is independent.

```bash
python3 labs/passport.py create --root . --claim 'AURORA synthetic trace arithmetic only' --out evidence/passport.json labs/aurora.py labs/audit.py labs/modelcheck.py labs/output.csv README.md TOOLKIT.md MATH_BRIDGE.md build.py assets/site.css labs/compare.py labs/exact_switch.py labs/passport.py labs/any.csv labs/quorum.csv evidence/dependency-graph.json
python3 labs/passport.py verify --root . --manifest evidence/passport.json --graph evidence/dependency-graph.json
```

The dependency graph connects claims to named inputs and to each other. If a byte changes, its dependent claims are marked for recheck via transitive reachability. This **cannot** prove that declared dependencies are complete. After a policy change, manually challenge whether additional assumptions, environment variables, and source authorities are missing from the graph.

**Experiment:** change one nonsemantic CSS comment and recheck; then restore and change a simulator constant. Record which claims are touched. If a file is not in the manifest, the toy gate cannot see it; this is an expected, documented limitation, not a passing assurance result.

**Acceptance:** original manifest, modified-file report, a trace of graph reachability, explicit unmodeled dependencies, and a justified recertification plan.

## Lab D — Research defense, including negative evidence

```bash
python3 -m unittest discover -s labs -p 'test_*.py' -v
```

Prepare a four-part evidence packet: a claim contract, method and generator versions, the exact commands and audit outputs, and a defect/limitations register. The strongest scientific criticism should be about **whether AURORA's synthetic model is appropriate to the question**, not whether a CSV addition was implemented correctly.

A second reviewer should independently specify what would refute the system claim before seeing the conclusion. Keep the review plan and the findings separate; an independent source-code file does not, by itself, constitute independent scholarly review.

**Acceptance:** the examiner can reproduce a positive result, reproduce a deliberately rejected corrupted input, show a finite counterexample to a too-strong theorem, and identify one condition under which the whole exercise would be decision-irrelevant.

## Recommended completion standard

| Level | Minimum evidence |
|---|---|
| Practiced | Commands run; result files and assumptions preserved |
| Reproducible candidate | A fresh environment reproduces reported counts and hashes |
| Verified computation | A named checker recomputes a clearly stated property from the trace |
| Independently criticized | A separately specified adversarial protocol tests model and proof dependencies |
| Research contribution | Relevant dated prior art and independent scholarly scrutiny support originality and usefulness |

No local script automatically promotes a result between levels. See the [quantitative foundations bridge](math-bridge.html) for technical coursework that a terminal-degree researcher should command alongside these labs.
