# Causal observation closure sprint — 2026-11-25, v0.1

Status: author-side composed proof candidate and exact finite experiments; no independent review, priority claim, or full Lean terminal. Objective: close the representation-to-query transport and extend offline shared observation to actual causal deadlines. Base: f1ebd11810e9604137f0cdebfe1131f0d178d624. Strongest local predecessor: Route 1 general-latent #970/#976 and shared multi-target budget #1036 (research/nightfall/structural_information/ROUTE1_SHARED_WYNER_BUDGET_20261122.md). Related external state-reduction literature: https://arxiv.org/abs/2403.07618 (distinct Markov reduction problem; not a global priority search).

## 1. Rank–phase transport

The Paper IV target is A(K,d,k)=k+S(K,d,k-1) for finite K, k>=1 and d|(|K|-1), d>=2. The new RankPhaseTransport module isolates the calibration identity (including zero coordinates), legal dependent-row power reading, normalized-anchor orbit uniqueness, and rank-deficiency collision from a nonzero null vector. The source is a candidate pending compilation; not the full theorem.

Upper reduction: read k coordinate powers; if all vanish output zero. Choose a nonzero anchor root u0, roots u_i, and dummy phases s_i=1 for zero coordinates. A hidden common root of unity lam gives x_i=lam*u_i*s_i. Implement the affine phase query using row anchor (c+sum_{u_i=0} a_i)/u0 and row a_i/u_i on nonzero coordinates, zero otherwise. The common factor lam disappears under the power. Recover the orbit.

Lower reduction: simulate any correct depth-D tree on an unknown tuple of k-1 phases. On rank increases append the new independent row and return 1 without querying the phase oracle; prescribe unsquared coordinates w_1=1 and w_j=s_{j-1}. On dependent rows query the powered affine combination of the prescribed values; zero rows are free. Every simulated prefix is feasible since an independent row map of rank r is surjective onto K^r. At a nonzero deficient rank, shift by a nonzero null vector; both signals have anchor reading 1 and cannot share a scalar orbit. At rank zero all signals have the same zero readings, impossible for k>=1. Thus every terminal has exactly k rank increases; at most D-k actual phase queries. The output orbit uniquely normalizes at the anchor, giving the phase tuple. The resulting phase tree is legal even for variable-depth branches. This proves the written reduction subject to independent review. Missing Lean: row-map surjectivity and rank/nullity, virtual-prefix induction on the actual arbitrary tree, extraction of the legal phase tree and both optimal minima. Do not replace these with assumed terminal facts.

Exact finite audit: check_rank_phase.py enumerates every prime-field linear row and every orbit including zero; separately every affine phase row; optimal worst-case depth via exact partition DP, rejecting only non-splitting rows and impossible leaf counts. All 13 models passed. Columns p,d,k,orbits,phases,A,S:
```
3 2 1 2 1 1 0
3 2 2 5 2 3 1
3 2 3 14 4 5 2
5 2 1 3 1 1 0
5 2 2 13 2 3 1
5 2 3 63 4 5 2
5 4 2 7 4 5 3
5 4 3 32 16 9 6
7 2 2 25 2 3 1
7 3 2 17 3 3 1
7 6 2 9 6 7 5
11 2 2 61 2 3 1
11 5 2 25 5 4 2
```
SHA256 325a0b542fc9ef288f75ebe32f23cf5cef52970e686b1981b1fa221571bca089; expected Git blob c51dfed1932fe8fb48d1a471cc0ecfcc94d7483f. Local replay on November 25; same-author computational cross-check, not an independent reviewer.

## 2. Structural observation identity (classical, not a novelty claim)

For a finite law mu and scalar task f, a deterministic transcript partitions signals into cells C. Optimal squared-error decoding on each positive-mass cell is its conditional mean, and the minimum Bayes risk is
R(P)=sum_C [1/(2 mu(C)) sum_{x,y in C} mu(x)mu(y)(f(x)-f(y))^2].
Expand the square to get sum_C sum_{x in C} mu(x)(f(x)-mean_C)^2. A refinement into children D improves risk by sum_D mu(D)(mean_D-mean_C)^2 by conditional variance decomposition. Ignore zero-mass cells. Exact recovery almost surely iff f is constant on each positive-support fiber; all-signal recovery requires all points, not just support. This is a common representation of observable task quotients, separation, prediction, and query progress, but alone is not the proposed general integrating theorem.

## 3. Causal-release shared-information simulation (new composed candidate)

Let X have a finite-alphabet law admitting a finite latent product mixture, with Wyner infimum C_W as in #970/#976. At each deterministic stage t=1,...,h, a nested set J_t of original coordinates has been released. Task f_t is globally [0,1]-valued, depends only on J_t, and has interaction degree <=d_t (d_t>=1). Outputs at each deadline are irrevocable. A query reads a released coordinate, not a latent or future coordinate. Fix scalar Route 1 thresholds tau_t, error eps_t>0, constants K_t, a_t, b_t exactly as in #1036, and b=min b_t>0. For s>C_W and positive integer m there exists a deterministic causal policy of total worst-case query depth <=m such that

P(any |output_t-f_t(X)|>eps_t) <= (sum_t K_t/a_t+s/b)/m + sum_t tau_t/eps_t^2.

Proof candidate. Choose a finite product mixture with I(Theta;X)<s via the finite-latent reduction. Conditional on every paid transcript of positive mass, latent-conditioned unread coordinates remain product. No new values are revealed merely by releasing coordinates. At stage t, use the #970 scalar good-query rule on the released marginal, restricting already observed coordinates. Stop at conditional variance <=tau_t; fully revealing released coordinates must stop. At an active node the normalized private potential drop divided by a_t plus the released-marginal information drop divided by b_t is >=1, using the same scalar premises and constants as #1036. Each private potential starts at most K_t and is nonnegative at its terminal, so the expected private contribution is at most K_t/a_t. The global potential I(Theta;X_unread | transcript) loses exactly I(Theta;X_j | transcript) in conditional expectation when j is read: this is the chain rule. The released-marginal potential loses exactly that same quantity. Replace b_t by b since all information drops are nonnegative. Summing the drift inequalities over nodes and stages yields E[N]<=sum_t K_t/a_t+I(Theta;X)/b. Releasing coordinates, switching tasks, and computing earlier outputs do not change the global potential. Truncate only when the next query would exceed m; on the abort event give arbitrary remaining outputs. Markov bounds abort by E[N]/m. On untruncated runs, each conditional posterior mean incurs squared risk <=tau_t at its deadline; conditional Chebyshev and a union bound give the remaining sum. Equivalently apply the tail bounds to the original untruncated policy and couple the truncated policy until abort. This avoids conditioning on a future no-abort event. All choices are deterministic on each finite history. No repeated reads, no future look-ahead, no repeated latent charge.

Scope: this is a causal-release extension of #1036, not a substitute for Paper VI's stronger staged MSE terminal. It is a task-output guarantee, not a runtime, full-state, feedback-controller, or transition-law guarantee. Corollary: in a finite-horizon deterministic dynamical system driven by initial and innovation coordinates and a fixed known control policy, apply the theorem when the scalar task pullbacks through the actual dynamics obey the stated causal release, boundedness and degree restrictions. Degree may grow with time; do not assume dynamical low degree. An unrestricted dynamical theorem and matching lower bounds remain research objectives. Prior-art clearance requires a separate targeted search of sequential simulation, causal information and query complexity; no priority asserted.

## 4. Falsification and exact replay

check_causal_observation.py: independent formulas for risk and pairwise risk, refinement gain, exact causal decision DP. Executed locally: 103680 exact rational cases, including zero masses. Packed future sensor has causal cost 2 versus all-released cost 1; five identical binary targets cost 1 with shared history versus 5 for reset policies. The first is an arbitrary-sensor negative control, not a low-degree Wyner theorem witness. Neither proves the general bound. SHA256 7dec30bc6d22c1c406147d1185f24c7615725aff3439cf8712c3afaba10ca5e9; Git blob 859f75609e6307151e44c4300734c9ad3f8f3cbf. Run both Python scripts directly, no third-party packages. Next independent review: test local potential transfer on released marginals, zero Wyner, non-full-support mixtures, threshold equality, deadlines, adaptive stop, and exact source-to-paper dependencies. Reject any future-coordinate query or separate latent charge. Stop gate: named Lean compilation/kernel receipt and independent proof attack before promotion. Budget for the present finite experiment is the 13 explicit models and 103680 rational cases; no claim of exhaustive general verification.

## 5. Real continuous feedback and remaining obligations

#1017 named conditional Lean lower bound, run 45051389069, assumes ProductSphereZero. #1147 provides an unconditional written product-sphere obstruction via Sard/interval-orbit argument, not a full Lean certificate. Archived #1106 global smooth boundary assembly remains the bottleneck; #1142/#1144 scoped local halfspace charts do not supply all global C-infinity transitions or identify the actual boundary. Preserve existing #995/#1000 review and #695 upper construction. Closure requires the actual smooth manifold and boundary equality, then instantiate the conditional theorem, not merely restate ProductSphereZero as a premise.

Paper V #1204 preserves archived exact chain and repairs phase expansion and clipped estimator. It still needs grouped equality/triple terms, actual Walsh/Parseval estimates, heterogeneous sectors and named unrestricted 31 terminal. Paper VI #1201 repair 688baa4; named staged general/quadratic MSE terminals pending. Parent #1200 run 45556375625 passed its named kernel gate. Do not promote manuscripts based on this sprint alone.

Credits: original NIGHTFALL authors and prior Route 1 / rank-phase / product-sphere contributors retain attribution. This note and the new tests are assistant-authored work in the owner's repository; independent review remains required.
