# NIGHTFALL — The Price of Permission: observation-cost floor and epoch-bound authority

**v0.1, 2026-11-15.** Mathematical status: exact finite deterministic-oracle theorems, independent exact-rational code replay; no independent human review, no Lean proof of these new finite search/guard statements, no novelty certification, and **no live ControlArena or cloud monitor measurement**. Research direction: Devin J. Wright; AI-assisted proofs and auditing.

## Contract and certified upstream dependency

The goal is to quantify the least cost of identifying which source is relevant to a consequential action, while preventing use of stale certificates when the action actually executes.

The upstream observed-variance theorem is the source-level Lean-certified Q2 bound from stacked [PR #587](https://github.com/d3lefts/d3lefts/pull/587), with exact coefficient

\[
K = [2(1+\sqrt2)\sqrt3+11901/6250]^2 \approx 105.41623982.
\]

Proof receipts: scalar [43724546633](https://github.com/d3lefts/d3lefts/actions/runs/43724546633); unrestricted source [43724546464](https://github.com/d3lefts/d3lefts/actions/runs/43724546464). **The upstream PR is draft/unmerged. This is a stacked research branch.**

This theorem guarantees existence of a coordinate with influence at least \(\operatorname{Var}(f)^2/(K B^2)\) for a bounded degree-two score on a finite product law. **It does not price access to that coordinate, establish the score is a truthful safety predicate, or establish complete mediation.**

## Theorem 1 — matching pathwise evidence-acquisition limit

For \(n\ge2\), let inputs \(X_i\) be independent fair signs and let the unknown risk model be \(f_j(x)=B x_j\), \(B>0\), \(j\in[n]\). Every model has \(\operatorname{Var}(f_j)=B^2\), and original heat-bath influence \(I_i(f_j)= B^2{\bf1}[i=j]\). Thus all members already satisfy Q2 (even at degree one).

**Oracle:** an authenticated and *exact* query \(O_i\) returns \({\bf1}[i=j]\) at strictly positive cost \(c_i\). The procedure may adapt, but has no batch, full-score, group, or index-revealing oracle. It must output \(j\) correctly on **every** admissible model. A final unqueried singleton may be inferred by elimination.

Then the optimal **deterministic, pathwise worst-case** source-inspection cost is

\[
\boxed{\sum_i c_i-\max_i c_i.}
\]

**Upper:** test all coordinates other than one having maximum cost, stopping at a positive answer; infer the final one if all are negative. **Lower:** all-negative evidence from fewer than \(n-1\) distinct tests is compatible with at least two different models requiring different answers. Therefore at least \(n-1\) distinct inspections appear on some path; every such set costs at least \(\sum c_i-\max c_i\). This is not a minimax **expected** lower bound for randomized policies.

**Scope:** ideal exact-influence source oracle is much stronger than noisy physical inference, but narrower than arbitrary full-input model evaluations. The theorem refutes *a cost-independent observability-to-monitoring inference* under its declared query interface. It does not refute the underlying Q2 theorem.

## Theorem 2 — exact expected-cost optimal acquisition rule

With prior \(\pi_i>0\), \(\sum_i\pi_i=1\), and the same perfect-inspection oracle, all deterministic zero-error adaptive policies are equivalent to an inspection permutation \(\sigma\) (its final element is never inspected), with cost

\[
C(\sigma)=\sum_{k=1}^{n-1}c_{\sigma(k)}\left(1-\sum_{\ell<k}\pi_{\sigma(\ell)}\right).
\]

**Algorithm:** for each choice of final omitted coordinate \(j\), order the other coordinates by nondecreasing \(c_i/\pi_i\); calculate \(C\); choose the best of the \(n\) candidates. Complexity \(O(n^2\log n)\).

**Proof:** for any fixed final \(j\), swapping adjacent inspected \(a,b\) changes the expected cost by \(c_a\pi_b-c_b\pi_a\). Inversions relative to increasing \(c_i/\pi_i\) cannot improve cost; exhaustive selection of the final index completes optimality. The result is a specialization of classical search ordering, not a novel search theorem.

## Theorem 3 — necessity of effect-time version mediation

An action is permitted exactly when the **current** model satisfies \(f_j(x)\le0\). Evidence was acquired at a signed epoch \(e\); an authenticated effect-time guard compares \(e\) to the currently committed epoch atomically with the effect. A valid safe decision is available under the current epoch, and unsafe actions must be blocked. Requested state \(x\) is immutable during the atomic decision/effect.

If an adversary can change \(j\) without an effect-time check, consider \(x_0=-1,x_1=+1\), \(j=0\) at inspection and \(j=1\) at effect. The old certificate grants the action, but the effect is unsafe. Same prior transcript, opposite present truth. No decision based solely on the old transcript can satisfy both universal safety and legitimate-action availability. A trusted atomic guard rejects the stale version; restoring availability for safe changed actions requires re-certification.

This is a concrete classical complete-mediation impossibility, **not** a proof that a cloud deployment has complete mediation. The guard's unbypassability, change-source authenticity, key custody, and atomic linearization remain trusted assumptions.

## Theorem 4 — exact cost of version-stable evidence reuse (restricted reset model)

Assume \(T\) consecutive actions, authenticated independent epoch resets with probability \(q\) between consecutive actions, and a new independent \(j\sim\pi\) at each reset. There is no unobserved change during an atomic effect; the guard costs \(g>0\) per action; evidence from different epochs cannot be reused but can be reused within an epoch; inspection and guard costs are additive. Then

\[
\boxed{\mathbb E C^* = [1+(T-1)q]C^*_{\rm Bayes}+Tg.}
\]

**Upper:** run the optimal inspection policy once per epoch, reusing its authenticated evidence until the next change, and charge every effect guard. **Lower:** conditional on each new epoch, \(j\) is again an independent draw with prior \(\pi\), so every zero-error policy must pay at least the Bayesian minimum per epoch. Every effect requires a guard; expectation and linearity give equality. This does **not** hold for an adversarial reset process without a specified budget on changes.

## Source-matched synthetic benchmark and exact replay

Costs \(c=(1,2,4,9,20)\), prior weights \((1,1,1,12,1)\).

| Quantity | Exact result |
|---|---:|
| Always inspect all 5 | 36 |
| Pathwise worst-case optimum | 16 |
| Cheapest-first expected inspection | 219/16 = 13.6875 |
| Optimal Bayes order (zero-indexed) | 3,0,1,2,4 |
| Optimal Bayes expected inspection | 81/8 = 10.125 |
| Saving over cheapest-first | 19/73 = 26.0274% |
| T=10, q=1/4, g=3, renew on authentic change | 2013/32 = 62.90625 |
| Same model, inspect before every action | 525/4 = 131.25 |

The source-local exact Python checker is:

\`\`\`sh
python3 research/nightfall/price_permission/check_guarded_monitor_cost_v01.py
\`\`\`

It runs two *different* exact solution methods (full permutation enumeration and Bellman recursion) against the exchange-order construction on **450 rational instances (n=2..7)**; additionally checks the genuine original-product Q2 source influence for each of five hidden-coordinate models, enumerates all **512** length-9 change histories, and exhibits **160** distinct stale-effect false-permit scenarios. Exact receipt SHA-256 for the ordered 450-case stream: \`a326e7685a36c30e1fb3bd03baeeb9521e0d71c8cf8c69ce3f4c33f9b3430078\`.

The complete independent-code reproducibility bundle, including a separate two-script implementation and hash manifest, was also produced in the same research session. This tests a **synthetic** interface, not AI model inference quality, production costs, or a ControlArena deployment. No external measurements are claimed.

## Prior art, significance, and next structural experiment

**Checked external literature:** Hua et al., [*Combining Cost-Constrained Runtime Monitors for AI Safety*](https://proceedings.neurips.cc/paper_files/paper/2025/hash/ed56a654ddb681841fdb2184463c253e-Abstract-Conference.html), NeurIPS 2025 (multiple monitors/average-case cost); Sheldon Ross, [*A Problem in Optimal Search and Stop*](https://pubsonline.informs.org/doi/10.1287/opre.17.6.984), 1969; Wegener, [*Discrete Sequential Search...*](https://pubsonline.informs.org/doi/10.1287/moor.5.3.373), 1980; [NIST reference monitor definition](https://csrc.nist.gov/glossary/term/reference_monitor). Standard priced search and effect-time complete mediation are not novel.

**Mechanism graph:** Q2 influence existence \(\to\) priced oracle model \(\to\) all-negative indistinguishability \(\to\) exact acquisition floor / optimal order \(\to\) attested epoch \(\to\) atomic effect-time guard \(\to\) renewal-cost formula \(\to\) explicit deployment limits.

**Novelty bar (not reached):** a tight cost bound with *noisy, strategically manipulated, correlated* cheap/expensive monitors and a **matched** ControlArena honest/attack benchmark, preserving legitimate-action availability and source/epoch fidelity. A genuine published advance must outperform the 2025 monitor-cost optimizer under the same access model and objective, or produce a distinct lower bound/transfer theorem it does not imply.

**Decisive next test:** change the exact \(O_i\) to actual stochastic monitor outcome kernels calibrated from ControlArena honest/attack logs, define missed-unsafe and blocked-legitimate constraints, and optimize the full evidence/guard policy with authenticated change events. Preserve explicit evidence acquisition + computation + effect-time guard + recertification costs. Counterexamples to model assumptions must demote any claimed transfer.

**Certificate status:** mathematical derivation + exact replay; no Lean for Theorems 1–4; no independent human proof review; no novelty or real safety certification. This is a substantive *engineering lower-bound benchmark and deployment-boundary isolation*, not a universal economical-oversight theorem.
