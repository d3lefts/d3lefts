# Adaptive Observability of Low-Interaction Product Systems

**Devin J. Wright — NIGHTFALL research program**  
**Consolidated research manuscript / publication candidate — 10 November 2026**

## Abstract

We study prediction of bounded observables on independent product probability spaces when each observation reveals one whole input coordinate. The proposed main theorem establishes a variance-squared resampling-influence lower bound for interaction degree at most two, with constants independent of alphabet size and coordinate bias. For Hilbert-valued outputs of covariance rank at most r, it yields worst-case adaptive observation complexity Θ(r/η) at squared-error tolerance 0<η≤1/4. With coordinate alphabet size at most m, the proposed nonadaptive minimax rate is Θ(rm/η) in degree two, and Θ_d(rm^{d−1}/η) at each fixed degree d. The proofs combine disjoint-edge interaction matching, bounded signed sums, conditional variance descent, categorical moment representations, and replicated address lower constructions. These claims are supplied paper proofs, not independently peer-reviewed or Lean-certified.

## 1. Observation model

Let X=(X_i) have an arbitrary independent product law. A query reveals one complete coordinate X_i. For a transcript A, the squared-error Bayes risk is E||F−E[F|A]||². A nonadaptive observer chooses all coordinates before seeing their values; adaptive choices may depend on the transcript. Degree refers to the largest nonzero Hoeffding/Efron–Stein interaction support. Define I_i(F)=E||F−E_iF||², V=E||F−EF||², and B=||F||∞. Effective rank r refers to the rank of output covariance; spectral-tail extensions require an explicit residual covariance term.

## 2. Proposed quadratic influence theorem

For a bounded scalar F with interaction degree at most two on arbitrary independent alphabets, the supplied proof package states

    max_i I_i(F) ≥ V² / [256(1+√3)² B²].

The constant is an explicit sufficient bound, not asserted optimal. The construction uses a matching in the pair-interaction graph to isolate independent signed contributions while retaining all off-matching terms in the boundedness argument. No quartic antipodal conjecture is needed.

For finite-rank Hilbert outputs, a spherical-direction lift controls the dependence on output rank. The supplied source contains the precise rank-sensitive constants and the posterior-descent proof; do not replace them with unverified scalar-to-vector shortcuts.

## 3. Adaptivity separation and sharp scaling

For unit-ball outputs, covariance rank ≤r, and 0<η≤1/4, the supplied manuscript claims worst-case query budgets:

| Interaction degree | Observation design | Minimax order |
| --- | --- | --- |
| ≤2 | adaptive, arbitrary alphabets | Θ(r/η) |
| ≤2 | nonadaptive, alphabet size ≤m | Θ(rm/η) |
| ≤d (fixed d) | nonadaptive, alphabet size ≤m | Θ_d(rm^{d−1}/η) |

The upper bounds are deterministic query strategies in the source. The lower bounds are witnessed on independent uniform finite alphabets. An address variable selects one of m signs: adaptation reads the address then the selected sign, whereas a fixed query set must cover alternatives. Replication and output-direction packing yield the r/η factor. Preserve the source's precise quantifiers and constants when typesetting.

## 4. Mechanism and dependencies

1. **Interaction matching:** isolate disjoint degree-two supports; use mixed differences and parity couplings to bound the sum of interaction amplitudes.
2. **Moment control:** independent matching increments admit a fourth-moment estimate; the full graph is handled without discarding off-matching couplings.
3. **Influence-to-observation:** posterior conditional variance is a supermartingale potential; choose influential coordinates and telescope its decrease.
4. **Categorical reduction:** a signed representation of categorical inputs preserves the required moments and incurs m-dependent nonadaptive costs.
5. **Lower construction:** replicated address families separate adaptive and nonadaptive information requirements.

## 5. Scope, limitations, and priority

Independence, bounded output, finite interaction degree, and controlled covariance rank are essential hypotheses. The Θ rates refer to the specified minimax regimes, not every individual function. No unconditional general-degree adaptive Θ(r/η) statement follows. The matching argument extends formally to disjoint d-uniform supports, but the quadratic fourth-moment step does not transfer to overlapping triples.

The source archive reports exact finite checks and internal model reviews; these are not independent external refereeing. Prior art requiring close comparison includes Turturean's 2026 cube result, Filmus–Hatami–Keller–Lifshitz, Dinur–Friedgut–Kindler–O'Donnell, Efron–Stein/ANOVA theory, bounded signed sums, categorical Fourier analysis, and order-two Hilbert-valued U-statistics. Global priority is **unresolved**.

## Source of full proofs

`NIGHTFALL_Quadratic_Product_Observability_Proofs(1).zip`: `main.tex`, `matching-core.tex`, `queries.tex`, `categorical.tex`, `nightfall-rank-appendix.md`, `matching-audit.py`, `finitealphabet-audit.py`, `exact_replay.txt`, and `SHA256SUMS`. This editorial manuscript intentionally does not claim to reproduce the full source proofs.
