# Website-ready exhibit: why benchmark self-audit matters

**Headline:** We found five incorrect solutions that our own grader scored perfectly.

**Description (72 words):** NIGHTFALL built DispatchQ-B1, a Python/SQLite concurrency repair challenge, then attacked its private evaluator instead of assuming the reference passing meant the grader was sound. Five of twelve deliberately incorrect source-level repairs initially received 100/100. Separate contract witnesses reproduced those misses. A revised 25-test, 100-point evaluator caught all twelve mutations while the reference retained full credit across ten repeats. This is source-exact internal calibration, not independent model evaluation.

**Evidence link:** [Proof-attack PR #838](https://github.com/d3lefts/d3lefts/pull/838) · [Public receipt](RECEIPT.json)

**Required status:** *Internally calibrated prototype; independent human review and blind coding-agent scoring pending.*

**Do not claim:** Frontier-model benchmark validity, externally certified grader soundness, evidence of model superiority, production-grade race safety, or Google/DeepMind endorsement.
