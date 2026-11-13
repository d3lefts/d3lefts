# Weighted-replica restriction frontier — source and replay

**13 November 2026 · exact finite-case replay successful · mathematical/historical priority still open.**

This folder records the first *sharp all-weighted-replica transfer tradeoff* in the NIGHTFALL research programme, obtained by generalizing the earlier November 11–12 failed maximum/expectation arguments. The underlying product-refresh Hoeffding identities are classical. The universal analytic theorem has a self-contained author-side proof, **not** a Lean terminal proof or an independent human referee verdict.

- [Theorem, hypotheses, proof and limitations](SHARP_REPLICA_TRANSFER_20261113.md). Precisely: for independent finite-replica selectors with probabilities `pi[i,a]`, let `q_i = 1 - sum_a pi[i,a]**2`. The exact worst-case maximum-influence distortion is `sum_i q_i`; the minimum universally retained variance fraction is `min_i q_i`. The joint no-go is `A >= n beta`.
- [Full exact product-law checker](checks/check_replica_restrictions.py) reconstructs original Hoeffding energies and both sides of the transfer equations on five independently specified finite source models.
- [Separate rare-event sharpness checker](checks/check_sharp_frontier.py) exhausts one-hot Bernoulli replica configurations and checks the exact first-order coefficient.
- [Successful GitHub Actions source-and-replay receipt](https://github.com/d3lefts/d3lefts/actions/runs/43515837487). Reported original source-file hashes in that immutable run correspond to **v1.0**; subsequent v1.1 Markdown formatting repairs preserve the mathematical claims but change source bytes.
- [Public scoped research page](https://d3lefts.github.io/d3lefts/replica-restriction.html) and [merged PR #451](https://github.com/d3lefts/d3lefts/pull/451).

From the repository root:

```sh
python3 -I research/nightfall/2026-11-replica-restriction/checks/check_replica_restrictions.py
python3 -I research/nightfall/2026-11-replica-restriction/checks/check_sharp_frontier.py
```

The theorem's universal scope is justified by its written proof rather than by finite enumeration. The checks test concrete instances and sharpness mechanisms and cannot establish novelty. The operator family is now **closed for repeat counterexample generation** unless a fundamentally different reduction or stronger universal result appears. Follow-up source-preserving Q2 work and active draft state are listed in [the research integration queue](../ACTIVE_RESEARCH_QUEUE_20261113.md).
