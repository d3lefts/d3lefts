# Minimum cost of discovering, using and certifying information
**NIGHTFALL / The Convoluted Costs of Knowing — integration dispatch v1.0, 2026-11-13**

**Research lead:** Devin J. Wright. **Provenance:** synthesis of the public mainline repository and the *accessible* dated branches/PRs. AI-assisted synthesis; no independent human referee, international priority review, or terminal Q2 proof claimed. Not a census of private/unshared parallel chats. **Baseline main SHA at branch creation:** c146e42c4a076a05ad371473f8b78fff2830cdc7.

## Objective and feasible model

For an admissible system class \(\mathcal M\), task/action space \(\mathcal A\), loss \(L(\theta,a)\), permitted typed query and computation interfaces \(\mathcal Q\), trust model \(V\), accuracy \(\varepsilon\), reliability \(\delta\), and change model \(\Delta\), find the least resource expenditure among procedures that (i) choose an \(\varepsilon\)-admissible decision with failure probability at most \(\delta\), (ii) produce evidence accepted by the named verifier **with an explicit soundness guarantee**, and (iii) preserve or repair that evidence for allowed changes. The cost is a **vector** (state reads, model evaluations, samples, arithmetic, checker work, authenticated updates). Scalarize only after fixing prices. Worst-case and expected cost, average and worst-case loss, and stochastic and deterministic certificates are not interchangeable.

\[
\mathbf C^*(\varepsilon,\delta;\mathcal M,\mathcal Q,V,\Delta)
=\operatorname{ParetoMin}_{\pi\text{ satisfying the specified decision, evidence and change contract}}\mathbf C(\pi).
\]

Under fixed nonnegative resource prices, a scalar \(\inf_\pi\sup_{\theta\in\mathcal M}\mathbb E_\theta[C(\pi)]\) is meaningful **only if the feasible procedure set contains all three obligations**. The additive accounting of *discovery + use + certification + maintenance* does not imply separately minimizing each component is optimal: the same observation or authenticated proof step can serve multiple obligations.

## Seven conditions and failure modes

1. **Task/loss:** which distinctions between worlds change an admissible decision? Known-coordinate bit prediction uses one coordinate read; uniformly random parity requires every coordinate read for error <1/2 in the coordinate-only model. If a parity oracle is supplied, one query suffices. This is an exact simple observation-model comparison, not new mathematics.
2. **Interaction structure:** product Hoeffding degree, sparsity, rank, small separators and dependency supports can make useful measurements local. Algebraic degree alone does *not* imply cheap computation or fine-coordinate measurement under correlations.
3. **Observation channels:** source and simulation cost of available observations (state, model, posterior sampling, group, certificate). Information within the system cannot be assumed available through a stronger free oracle.
4. **Identifiability:** if two decision-disjoint systems induce identical transcript laws for all permitted adaptive queries, no procedure can achieve both error rates <1/2.
5. **Computational extraction:** experimental design, posterior calculations, simulation and decision optimization may dominate physical measurements.
6. **Verification and provenance:** evidence requires specified claim, authenticated premises, verifier, soundness scope, source commitments, toolchain receipt and dependency graph. A Lean-compiled *sublemma* is not a terminal certified theorem; an exact finite test is not an all-size theorem.
7. **Change stability:** what was modified, which dependencies can invalidate the result, and what authenticated evidence permits incremental reuse? Without complete authentic changes, cached proof obligations may be unsound.

## Exact established lower-bound ingredient (not an original NIGHTFALL theorem)

Let \(\theta_0,\theta_1\) require disjoint sets of correct decisions. Suppose any randomized adaptive strategy with a.s. finite stopping time \(T\), history-measurable queries \(Q_t\), and conditionally independent queried observations terminates in a decision correct with probability at least \(1-\delta\) under *both* hypotheses, \(0<\delta<1/2\). Assume common observation kernels are well defined, with suitable absolute continuity and integrability (otherwise KL may be \(+\infty\)). The chain rule for adaptive transcript likelihoods and binary data processing give

\[
\mathbb E_{\theta_0}\sum_{t=1}^{T}
D_{\rm KL}(P_{\theta_0}^{Q_t}(\cdot\mid H_{t-1})\parallel
            P_{\theta_1}^{Q_t}(\cdot\mid H_{t-1}))
\ \ge\ \operatorname{kl}(1-\delta,\delta).
\]

If the conditional KL gain of query \(q\) is bounded above by \(\kappa c(q)\) for **every reachable history**, then
\(\mathbb E_{\theta_0}[\sum_{t\le T}c(Q_t)]\ge \operatorname{kl}(1-\delta,\delta)/\kappa\).
This bounds **acquisition cost under the stated oracle**. It is *not* automatically a lower bound on computation, certification or maintenance. The deterministic non-identifiability obstruction is the zero-KL limiting case. Its precursors are Wald/sequential testing, information-based complexity, Blackwell comparison of experiments, and standard adaptive change-of-measure lemmas. This section makes no novelty claim.

## Exact posterior distinction (mainline #449)

For posterior \(\Theta\mid D\) independent of fresh state \(X\), \(m_D(x)=\mathbb E[f_\Theta(x)\mid D]\), and one shared state resampling pair \((X,X^{(i)})\), two independent posterior models give

\[
I_i(m_D)=\tfrac12\mathbb E[
(f_{\Theta_1}(X)-f_{\Theta_1}(X^{(i)}))
(f_{\Theta_2}(X)-f_{\Theta_2}(X^{(i)}))\mid D],
\]
\[
\mathbb E_{\Theta\mid D}I_i(f_\Theta)= I_i(m_D)+\mathbb E_{\Theta\mid D}I_i(f_\Theta-m_D).
\]

*Actionable* posterior-mean influence differs from model-averaged (*epistemic*) influence, and neither specifies the oracle cost of discovering a promising coordinate. Exact identities: elementary; sampled observation theorem: conditional on unresolved source-level Q2; inference costs and free prior knowledge explicitly charged.

## Cross-instance integration map (verified source locations, not general endorsements)

| Track | Reusable result/mechanism | Present status and boundary | Primary source |
| --- | --- | --- | --- |
| Heterogeneous product influence | Two-draw orientations and finite historical Lean transfer of Turturean's Aaronson–Ambainis theorem | Historical **scoped** finite Lean coefficient \(c_*=\sqrt{3/12500}/\pi^6\), external source credit; not the sharper uncompiled universal analytic extension | [finite-product sources](../../../papers/finite-product-influence/README.md), [passport](../formalization/product_space/FINITE_PRODUCT_INFLUENCE_PROOF_PASSPORT_20261110.md) |
| Arbitrary-alphabet degree-two Q2 | Source matching, greedy ownership, conditional sections, true-neighbor Hilbert fourth-moment closure | Source-only analytic candidate; individual strict-Lean declarations and exact tests, **no end-to-end source-only current-pin Lean theorem and no specialist referee**. Preserve [open stacked drafts #424–#434](https://github.com/d3lefts/d3lefts/pulls) without automatic mass merge | [Q2 source](../2026-11-quadratic-law-free-audit/), [claim ledger](CLAIM_LEDGER.md) |
| Source-preserving soft refresh | Original product-law Markov/noise operator avoiding some hard-ownership bookkeeping | Merged #452 analytic alternative; two exact scripts do not certify Q2 | [source refresh note](../2026-11-quadratic-law-free-audit/Q2_SOFT_OWNERSHIP_SOURCE_NOISE_BRIDGE_20261113.md) |
| Posterior actionable observation | Exact two-draw posterior identity, four-call estimator; conditional approximate-greedy observer | Mainline #449; exact identity unconditional, observer assumes Q2, access and sampler costs explicitly counted | [posterior bridge](../2026-11-convoluted-costs-knowing/POSTERIOR_ACTIONABLE_INFLUENCE_A1.md) |
| Oracle-matched task revelation | Early/late revelation with same independent-output group oracle and squared-loss target; fractional KL information-cover primal/dual | Mainline #450 author-analytic matching asymptotic; exact finite falsifiers, independent review and 2015/2026 same-scope subsumption **open** | [group information cover](../2026-11-convoluted-costs-knowing/ORACLE_MATCHED_GROUP_INFORMATION_COVER_A2.md) |
| Change-stable trusted evidence | Tree-convex dependency certificates, bounded exceptions, sparsification and trusted-query limits | [Draft #456](https://github.com/d3lefts/d3lefts/pull/456); finite combinatorial author arguments and branch checker files; authenticity/dependency extraction are **external assumptions** | [branch source](https://github.com/d3lefts/d3lefts/tree/research/change-stable-tree-evidence-20261113/research/nightfall/projects/change-stable-safety) |
| Correlated-product influence | Hereditary bounded-density transfer, independent singular block grouping, parity camouflage, stationary completion | [Draft #457](https://github.com/d3lefts/d3lefts/pull/457); author-analytic, branch checkers, relies on historical finite product theorem; no new correlated Lean proof | [branch source](https://github.com/d3lefts/d3lefts/tree/research/correlation-robust-aa-completion-20261113/research/nightfall/2026-11-correlation-stable-aa) |
| Small-separator dependent observability | Read cutset then independent blocks, local spectral-gap transfer, correlated-star same-oracle lower family | [Draft #458](https://github.com/d3lefts/d3lefts/pull/458); **conditional on Q2**; checker binaries described but *not committed* in that PR; not full connected-Gibbs theorem | [branch note](https://github.com/d3lefts/d3lefts/blob/nightfall-dependent-separator-observability-20261113/research/nightfall/2026-11-dependent-observability/SEPARATOR_Q2_STATE_READS_20261113.md) |
| Quantum ANOVA, extremal overlap, agent safety | Orthogonal product metric geometry; exact rational overlap witness; observational equivalence under safety abstraction | Scope-specific formal/analytic/exact/empirical claims, not transported into a universal knowledge-cost law | [quantum](../../../papers/quantum-operational-anova/README.md), [archive](../../README.md), [website evidence](../../../docs/agent-safety-under-abstraction.html) |

## Dependency graph and decisive review

- **Q2 →** rank-sensitive/adaptive bound, posterior observer, and separator transfer. Failure/demotion of the original-source Q2 theorem demotes these dependent statements, **not** the posterior decomposition identity or the oracle-matched information-cover example.
- **Historical finite Turturean transfer →** correlated bounded-density/block corollaries in draft #457, under additional dependent-law hypotheses. The historical compiler receipt does not certify those corollaries.
- **Authentic source & change report →** change-stable certificate claims; their combinatorial correctness does not authenticate real-world systems.
- **No free transitivity of oracles:** a posterior-value call, known product-law conditional sampler, reading a live coordinate, and checking a proof have different capabilities and prices.

**Independent auditor designed before advancement:** (A) reproduce a two-hypothesis adaptive KL lower bound with boundary cases \(\delta\to1/2\), zero-information observations, and variable-length stopping; (B) check the group-LP dual against adaptive correlated group output counterexamples and closest group-multicover literature; (C) inspect #456's update authenticity condition; (D) run checker sources from #457 under its workflow; (E) demand committed independent #458 checkers; (F) check original-source conditional law, neighbor distinctness and compiler pin for Q2 terminal. No self-certification.

**Next economical experiment:** choose a small genuine dependent star/factor-graph model whose observation and certificate interfaces are held fixed, then compute an exact acquisition/certification tradeoff and independently enumerate decision/certificate paths. Test whether certificate reuse yields a provable lower/upper gap beyond classical information-cover or set-cover models. If not, keep the example as a careful synthesis, not a novel general theorem.

## Prior art / novelty gate

Must compare same oracle, task, risk, costs, and update assumptions to: sequential tests/change of measure; Blackwell experiments; information-based complexity; group experiment information covering (Wu–György–Szepesvári 2015); Turturean 2026 and Huffstutler–Miloschewsky–Podder 2026; classical cutset conditioning and Poincaré comparisons; proof-carrying code and dynamic certificate/assurance maintenance. Novelty, independent review and publication remain **open**, explicitly separate from correct elementary lemmas and historical machine receipts.

**Revision/stop rule:** preserve original branch source, tests and failed paths. Do not merge open research branches merely to clear queue; no terminal Q2 promotion without named all-source theorem type, actual pinned compiler pass, axiom list, signed receipt and external review. Update the website as a **dated research dispatch**, not a verified theorem announcement.
