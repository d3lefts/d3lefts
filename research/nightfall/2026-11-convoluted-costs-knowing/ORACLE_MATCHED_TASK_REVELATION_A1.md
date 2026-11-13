# Task Revelation and the Price of Justification
## An oracle-matched weighted support-overlap theorem — A1, 2026-11-13

**Status:** self-contained author-analytic proof, independently implemented exact finite audits; no non-author referee, complete historical priority clearance, Lean certificate, or claim of a new landmark theorem.

### Contract and source constraints

Objective: derive a matching information-theoretic **lower** and constructive **upper** against *every* adaptive algorithm using an identical noisy evaluation oracle and solving the identical prediction problem. Compare only when task information arrives.

Feasible set: finite tasks t with positive pi_t, finite independent hidden fair signs nu_i, costs c_i>0, noise 0<beta_i<1, real weights w_{ti}; independent fair Z_i available gratis in both protocols; one query at i reveals only a fresh binary sign U_i with E(U_i | nu)=beta_i nu_i and charges c_i. New target A_i* are fresh independent conditional on nu, E(A_i*|nu)=beta_i nu_i. Predict Y=sum_i w_{Ti} A_i* Z_i under squared loss. No complete posterior draw, full f-evaluation, free shared observations, or arbitrary linear mixtures in this oracle. Task T~pi independent of the hidden signs. Only difference: T is shown before querying (early) or after all querying (late), before prediction. Both allow randomized fully adaptive querying and stopping with **expected** cost.

Strongest external references checked this session: Wald–Wolfowitz sequential probability ratio testing (1948), https://encyclopediaofmath.org/wiki/Sequential_probability_ratio_test; Chen et al. (2023) task-aware active representation learning, https://arxiv.org/abs/2306.08942; Daiki Suruga (2025 revision) direct-sum framework, https://arxiv.org/abs/2408.15570; sequential experimental-design KL bounds and optimal-design theory. These are major novelty challenges; no world-first status claimed.

Novelty/significance threshold: a demonstrably non-subsumed theorem under precisely the same oracle and loss, plus an information-theoretic advantage resistant to alternative acquisition strategies. Independent referee and detailed Suruga/Chernoff/Wald theorem-type subsumption audit remain essential. Stop generalizing to stronger full-model oracles if the proof relies on separable component-only likelihood.

### Main finite-instance asymptotic theorem

Let S_t={i:w_{ti} !=0}, U=union S_t and d_i=beta_i log((1+beta_i)/(1-beta_i)). Let C_E(eta), C_L(eta) be the least **expected oracle costs** to achieve squared prediction error at most

    R_model+eta,
    R_model=sum_t pi_t sum_i w_{ti}^2 (1-beta_i^2).

Then, with every problem parameter held fixed as eta goes to zero,

    C_E(eta) = (sum_t pi_t sum_{i in S_t} c_i/d_i) log(1/eta)+O(1)
    C_L(eta) = (sum_{i in U} c_i/d_i) log(1/eta)+O(1).

Hence the asymptotic late/early cost ratio (if U nonempty) is

    G = [sum_{i in U} c_i/d_i] /
        [sum_t pi_t sum_{i in S_t} c_i/d_i] >=1.

Disjoint uniformly distributed singleton tasks give G=m. Identical nonempty task supports give G=1. The coefficients are exact to leading order and apply against **every adaptive randomized policy** for this specified oracle. The O(1) remainder is instance-dependent; growing m jointly with eta is not covered.

### Original-source proof: five load-bearing steps

1. **Adaptive posterior factorization.** A fully adaptive transcript contributes likelihood product_i prod_{queries i} P(U|nu_i). Query/stop policy factors are independent of hidden nu conditional on history. Independent prior bits remain posterior independent. For posterior bit means M_i=E[nu_i|transcript], Bayes excess squared risk equals E sum_i a_{Ti}(1-M_i^2), a_{ti}=w_{ti}^2 beta_i^2. This includes random stopping and the same target in both regimes. A non-Bayes output incurs larger risk.
2. **Universal adaptive testing converse.** Let N_i be the number of queries to i. Between models nu_i=+ and nu_i=-, the transcript relative entropy in each direction is exactly d_i E_±N_i; queries to other j contribute zero because their conditional posteriors are unchanged. Bretagnolle–Huber in both directions gives minimum mean sign classification error e_i >=(1/4) exp(-d_i E N_i). Since E(1-M_i^2)>=2e_i, E(1-M_i^2)>=(1/2) exp(-d_i E N_i). This holds conditional on task t for early revelation.
3. **Task-by-task cost lower.** With n_{ti}=E(N_i|T=t), eta >= (1/2) sum_t pi_t sum_i a_{ti} exp(-d_i n_{ti}). Each active term gives n_{ti} >= d_i^{-1}[log(pi_t a_{ti}/(2eta))]_+. Expected cost lower coefficient is sum_t pi_t sum_{i in S_t} c_i/d_i.
4. **Late cost lower.** Task T is independent of the acquisition transcript when disclosed after querying. Put bar_a_i=sum_t pi_t a_{ti}. Then eta >=(1/2) sum_{i in U} bar_a_i exp(-d_i E N_i), yielding the union-support coefficient sum_{i in U}c_i/d_i.
5. **Matching sequential construction, exact cost and error.** Independently query each needed coordinate until the signed sum of responses reaches +/-k. Let r_i=(1-beta_i)/(1+beta_i). Exact gambler's-ruin gives error r_i^k/(1+r_i^k), expected calls (k/beta_i)(1-r_i^k)/(1+r_i^k) <= k/beta_i. For each task with s=|S_t|, k_{ti}=max(1,ceil(log(4s a_{ti}/eta)/log((1+beta_i)/(1-beta_i)))); late regime analog replaces a_{ti} with bar_a_i and s with |U|. Estimated signs inserted into sum_i w_{ti} beta_i sign_i Z_i give excess risk <=eta and cost equal to the respective KL lower coefficient times log(1/eta)+O(1).

**Exactness mechanism:** for sequential expected-cost testing, the KL d_i, not the fixed-sample Chernoff rate, controls the leading log coefficient. The sign walk hits exactly the boundaries and has no likelihood overshoot beyond discrete threshold. This is a classical sequential-testing mechanism; the task-support composition is the proposed theorem.

### General adaptive information-cover converse (separate stronger risk assumption)

For arbitrary finite parameter theta, task t and experiment q with conditional response law P_theta^q and cost c_q, assume pointwise-in-(theta,t) squared prediction risk <=eta for scalar target g_t(theta). For any task-separating alternative theta' with Delta=|g_t(theta)-g_t(theta')|>sqrt(8eta), every randomized adaptive policy satisfies

    sum_q E_theta[N_q] KL(P_theta^q || P_theta'^q)
      >= kl(1-4eta/Delta^2, 4eta/Delta^2).

Proof: threshold the predicted scalar at the midpoint; Markov bounds each testing error by 4eta/Delta^2, data processing gives binary relative entropy, adaptive likelihood chain gives the left side. Under late disclosure, the **same acquisition counts** must satisfy constraints for all task alternatives; early disclosure permits separate counts per task.

Any nonnegative dual multipliers lambda_{theta'} with sum_alt lambda_alt KL(P_theta^q||P_theta'^q) <=c_q for every q produce a lower certificate

    E_theta total_cost >=sum_alt lambda_alt kl(1-4eta/Delta_alt^2,4eta/Delta_alt^2).

This general converse is standard change-of-measure under a task-indexed information-cover representation; it is **not** a matched upper theorem for arbitrary oracles, and uses pointwise-in-model risk rather than the Bayes-risk criterion of the main theorem.

### Q2 dissertation connection and warning

For each fixed target model draw A*, f_{A*}(t,z)=sum_i w_{ti} A_i* z_i is bounded by max_t sum_i|w_{ti}| and has genuine Hoeffding degree <=2 in the independent product-state coordinates (T,Z_1,...,Z_m). Thus this is a complete **Q2-independent** oracle benchmark *inside* bounded quadratic product-space function classes. Before oracle learning, averaging nu yields zero posterior mean and zero **state-coordinate actionable influences**. Successful acquisition instead targets task-relevant *model* coordinates. Hence "the cost of discovering actionability" is not the same as a static posterior-mean influence score.

**Do not promote to full-value posterior oracle:** the paid interface returns one requested component sign only; a full posterior-model draw or arbitrary f-evaluation that mixes model components can shortcut the direct-sum lower bound. State observations Z are free in both regimes, and changes to their cost require a new theorem.

### Verification and provenance

An independently written exact Fraction checker in the working container passed:
- 18 exact absorbing-Markov-chain Gaussian-elimination replays of stopping error and mean cost, three rational noise strengths and six thresholds;
- 64 exact posterior-factorization atoms under a data-dependent, three-query index policy;
- 128 exact conditional squared-risk identities;
- six finite-eta risk policies across three overlapping/disjoint/same-support task families;
- seven exact Bellman-optimal fixed-query-budget early-versus-late comparisons (0..6).

Contact: the complete six-page self-contained LaTeX/PDF paper and full standalone Python checker are preserved in the conversation artifact bundle, **not represented as blobs committed by this text-only PR**. Final local bundle SHA-256 60cc78e7fe660009fa703e08917225d2e0b4d6ae995b068b887ebf47354e13b6. A focused CI mini-checker may be added separately.

**Graph:** task support -> conditional likelihood factorization -> per-coordinate KL -> adaptive testing converse -> sequential-test construction -> exact leading coefficient -> overlap geometry -> optional information-cover generalization.

Next decisive research: extend to unrestricted *full-function posterior evaluation*, correlated model coordinates, and nonseparable experiment matrices, with a constructively achievable information-cover dual certificate and the *same* oracle, cost, and loss on both sides. This is the substantive novelty gate.
