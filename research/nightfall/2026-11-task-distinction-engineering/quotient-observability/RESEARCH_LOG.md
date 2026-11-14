# NIGHTFALL / Task-relevant quotient observability / 2026-11-13 / v0.1

## Objective
Determine exact decision-relevant information, source reads, verification effort and certificate-update work for evolving noisy systems under a clearly defined oracle. This is an **exact finite-field pilot**, not a general systems assurance theory.

## Feasible interface
- Latent X uniform independent on F_q^n; N arbitrary jointly correlated, independent of X; coordinate oracle returns persistent Y_i=X_i+N_i (no resampled reads); task K=AX.
- Finite distribution of N is trusted, version-committed, and exogenous signed state deltas are complete and authenticate raw changes to Y.
- Upper/lower computational comparisons use the **same raw-word / fan-in-two gate** interface; no free signed aggregate, no free task oracle, no unpriced model validation.
- Task decision output is maximum-posterior identification or an explicitly precomputed posterior risk table. Genuine physical safety and model calibration are outside the claim.

## Proven on paper (author-side algebraic proofs)
1. Posterior (Theorem 1): condition on Y_Q, the task K is uniform within cosets of im A_{\bar Q}; distribution of cosets is shifted projected noise. I(K;Y_Q)=(d-r)log_2 q - H(pi A_Q N_Q).
2. Exact full-noise posterior and all-or-nothing complementarity for a scalar sum. For P already read, m remaining relevant coordinates, target success s, nonuniform aggregate noise: minimum expected new reads m (s-1/q)/(p*-1/q).
3. For r×r row-column task reveal and pathwise worst-case prep budget b, exact post-reveal latency r-floor(b/r).
4. Version-committed exogenous delta gives exact aggregate transport B'=B+sum delta, and raw-word/fan-in2 update cost k, checker delta reads k (under declared interface).
5. Noise-law nonidentifiability: pairwise-canceling vs independent fair noise yields same full Y law and differing posterior MAP success 1 vs 1/2. Model attestation must be separately trusted.

## Independent finite-model reproducibility (not independent referee)
`python3 exact_audit.py` regenerates `audit_results.json` with exact rational arithmetic and fixed seed 20261113.
- 240 seeded random correlated-noise models, 1,860 observed-index subsets, 41,706 exact conditional-posterior entries.
- 600 random two-source noise models and 5,400 deterministic adaptive policies.
- 4,000 random exact signed-delta models.
- All 66,064 preparation subsets across grid sizes 2,3,4.
- Two noise laws that are observationally indistinguishable but have exact task certainty 1 vs 1/2.

## Strongest externally checked references this session
- G. Ramalingam, *Bounded incremental computation* (1993), https://www.microsoft.com/en-us/research/publication/bounded-incremental-computation/
- U. Acar et al., *A Library for Self-Adjusting Computation* (2006), https://www.cs.cmu.edu/~guyb/papers/ABBHT06.pdf
- A. Mukhopadhyay and S. R. Nalla, *Reusing Assurance Evidence in AI Pipelines* (Oct 2026), https://arxiv.org/abs/2610.27672
- Y. K. Ko, *Amortized Cell-Probe Lower Bounds for Dynamic Boolean Problems* (Nov 2026), https://arxiv.org/abs/2611.11508

## Prior-art / novelty gate
**No confirmed novelty**. Algebraic core closely relates to one-time-pad secrecy, linear codes and additive-noise channels; update core relates to established incremental computation. The 2026 assurance reuse paper overlaps signed dependency reuse directly. Cannot claim a landmark theorem, Lean-certified theorem, empirical system-safety validation, matched general computational lower bound, or original TCS contribution without a deeper type-level/subsumption search.

## Independent attack plan
- Challenge the uniform X, N independent X, fixed N across edits, complete manifests and support model. Indistinguishable-noise counterexample already proves no universal model-free extension.
- Ask nonauthor referee to check conditional independence under arbitrary joint N, equality of adaptive success with random stopping, proof of gate lower bound, and task pathwise/oblivious adversary distinction.
- Attempt to break the result with hidden change to N, altered task-support matrix A, or unexpected extra model attestation and aggregate oracles. If these are allowed, **change the model and re-prove**, rather than re-label the result universal.

## Cheapest decisive next experiment
1. Extend observation model to a two-state hidden Markov noise process with a new task revealed after an update; explicitly bill calibration and model-checking queries.
2. Find two models indistinguishable under every permitted cheap query but with different risk decisions, to quantify the minimum *extra oracle* required to requalify the certificate.
3. Seek a same-oracle minimax lower bound that scales with task-specific latent rank and model-change locality rather than n. Test tiny exact Bayesian decision trees before any Lean or large simulation.
4. Stop and demote if the resulting proof is simply standard additive-channel capacity, linear secret-sharing, or classic dynamic sum maintenance.

## Repository reproducibility command

```sh
python3 -I research/nightfall/2026-11-task-distinction-engineering/quotient-observability/exact_audit.py
git diff --exit-code -- research/nightfall/2026-11-task-distinction-engineering/quotient-observability/audit_results.json
```

The editable LaTeX manuscript `Task_Relevant_Quotient_Observability.tex` is committed, along with the mathematical proof transcript `THEOREM_AND_PROOFS.md`, original exact audit code, frozen audit output, and scoped certification passport. The original PDF is in the standalone research bundle, not checked into GitHub; repository CI tests exact code and status rather than a PDF build.
