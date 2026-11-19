# Frontier-agent evaluation protocol

**Status:** public evaluation harness; no baseline-model results yet.

## Leakage boundary
The public repository includes a reference construction and its family-specific audit. Therefore the public task is a **development benchmark**, not a secure hidden frontier evaluation. A real scored run must put the candidate agent in a separate checkout containing only the task prompt and a grader API, with the reference family, generator, independent audit, private seeds, and tests inaccessible. A deterministic family with public source is not genuinely hidden simply because the seed is secret.

## Reproducible local checks
From this directory:

```sh
python3 -m unittest discover -p 'test*.py' -v
python3 grade_correlated_influence.py examples/correlated_influence_witness.json
python3 audit_frontier.py examples/correlated_influence_witness.json
python3 generate_frontier_cases.py --seed 17 --n 9 --output /tmp/nightfall-frontier-case.json
python3 grade_correlated_influence.py /tmp/nightfall-frontier-case.json
```

## Scoring gates
1. Exact grader accepts the witness; no partial correctness points for invalid witnesses.
2. Independent oracle agrees on known-family examples; for arbitrary witnesses require a second independent enumerator.
3. Blind review evaluates explanation of independence versus correlation and proposed repair.
4. Measure baseline agents with fixed time/token/tool budgets, no reference-witness access, and record attempts, model identifiers, prompts, outputs, grader version, and hashes.
5. Hold out a *different counterexample family*, not merely a different random seed, before claiming out-of-distribution research ability.

## Known limitations
- n <= 12 allows exact enumeration but is not a computational scaling benchmark.
- Generator varies dimension, noise, and projection coordinate within one known family; it is unsuitable as an adversarial hidden split by itself.
- Reference construction's special form makes it easy to memorize.
- No frontier-model performance measurements have been conducted.
- The false claim is deliberately distribution-free. No contradiction of product-law AA or correlated Poincare-qualified statements is implied.
