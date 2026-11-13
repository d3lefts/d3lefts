# The Information-Cover Law — A2
## Matching oracle complexity under early/late task revelation and overlapping group measurements

**13 November 2026.** Status: complete *author-analytic* derivation and independent exact finite falsification; priority vs 2015 group multi-cover and 2026 KL-conversion research **UNRESOLVED**. No Lean, independent referee, publication approval or landmark claim.

### Objective and audited comparator

Generalize the A1 singleton-coordinate task revelation theorem to **group experiments that share costs**. Keep the same prediction target, acquisition oracle, squared loss and expected-cost metric; only reveal the task before or after querying. Obtain a matching lower bound against every adaptive querying and stopping strategy.

Strongest checked prior art: Wald–Wolfowitz sequential optimal testing; Wu–György–Szepesvári (ICML 2015) on [noisy group-probe set multi-cover](https://proceedings.mlr.press/v37/wub15.html); Suruga (2025 revision), [general oracle direct sums](https://arxiv.org/abs/2408.15570); Li–Liu (November 2026 revision) [sharp sequential KL-conversion](https://arxiv.org/abs/2608.19897); and Chen et al. (2023), [task-aware representation learning](https://arxiv.org/abs/2306.08942). Set-cover and sequential KL techniques are pre-existing; the same-loss exact task-revelation coefficient must survive subsumption audit before it is claimed novel.

### Source model and theorem

I finite coordinates, latent independent fair signs nu_i, 0<beta_i<1, positive group costs c_q. Fresh target A_i* has E(A_i*|nu)=beta_i nu_i and is conditionally independent across i. Independent fair visible state Z_i, independent task t with probability pi_t>0, known real w_ti. Target Y=Σ_i w_{T i} A_i* Z_i, model-noise floor R_model=Σ_t pi_t Σ_i w_ti²(1-beta_i²). A query of group q gives a **new conditionally independent vector of component signs** U_i, i∈G_q, with P(U_i=nu_i)=(1+beta_i)/2 at shared cost c_q. No arbitrary linear-combination f-evaluation or full-model disclosure. Any adaptive randomized group-querying and integrable stopping strategy is permitted. Both regimes get Z free and task before predicting; early sees T before experiments, late only after all experiments.

S_t={i:w_ti !=0}, U=∪S_t, d_i=beta_i log[(1+beta_i)/(1-beta_i)]. Every i∈U has at least one covering group. The **fractional information-cover LP** is

    kappa(S)= min_{x_q>=0} Σ_q c_q x_q
              s.t. Σ_{q: i∈G_q}x_q >=1/d_i (all i∈S).

Exact dual certificate:

    kappa(S)= max_{y_i>=0} Σ_{i∈S}y_i/d_i
              s.t. Σ_{i∈G_q∩S}y_i <= c_q (all groups q).

Let C_early(eta), C_late(eta) be minimum expected group-oracle expenditure to achieve total squared risk ≤R_model+eta. Then with each finite problem instance fixed, as eta↓0,

    C_early(eta)=[Σ_t pi_t kappa(S_t)]log(1/eta)+o(log(1/eta)),
    C_late(eta)=kappa(U)log(1/eta)+o(log(1/eta)).

The constructive upper remainder is O(log(1/eta)^(2/3)), lower remainder -O(1). Universal adaptive lower and matching constructive upper are proved under this **independent-output grouped oracle**. Leading late/early ratio=kappa(U)/Σ_t pi_t kappa(S_t)≥1.

### Actual-source proof: each dependency is explicit

1. **Posterior factorization and exact risk.** Group transcript likelihood is product over queries q, then i∈G_q, of P(U_i|nu_i). Adaptive selection/stopping are transcript-measurable and not new hidden-sign-dependent factors. The fair product prior remains posterior independent across ν_i. With M_i=E(nu_i|transcript), Bayes excess squared risk is E[Σ_i a_Ti(1-M_i²)], a_ti=w_ti² beta_i².
2. **Adaptively valid group KL.** Flip only ν_i. Each group containing i supplies transcript KL d_i; other group components are the same under both hypotheses. The adaptive chain rule yields directed KL d_i E_±N_i, N_i=Σ_{q:i∈G_q}N_q. Two-way Bretagnolle–Huber implies E(1-M_i²)≥(1/2)exp(-d_i E N_i). The inequality also holds conditional on T=t in the early regime.
3. **Lower cover.** For early, each positive (t,i) term of eta≥(1/2)Σ_t pi_t Σ_i a_ti exp[-d_i Σ_{q∋i}E(N_q|t)] forces Σ_{q∋i}E(N_q|t)≥(L-K)/d_i with L=log(1/eta), fixed finite K. Rescaling into the LP gives expected cost ≥(L-K)Σ_t pi_t kappa(S_t). In late, transcript and counts are independent of T, and average weights bar_a_i=Σ_t pi_t a_ti yield ≥(L-K')kappa(U). Both lower bounds hold for all adaptive randomized policies.
4. **Concurrent sequential completion.** Fix support S, positive a_i, optimum fractional cover x*, L=log(1/eta), SPRT signed log-likelihood boundaries h_i=log(4|S|a_i/eta)=L+O(1). Schedule each group q exactly ceil[x*_q(L+L^(2/3))] times. Every i∈S receives deterministic n_i=O(L) samples with expected correct-signed log-likelihood n_i d_i≥L+L^(2/3), so P(i unfinished after schedule)≤exp[-Ω(L^(1/3))] by independent bounded-increment concentration.
5. **Recovery and correct predictions.** If i unfinished, repeatedly query any group containing i and ignore other outputs until its likelihood hits ±h_i. Expected additional component observations from any unfinished state ≤(2h_i+ell_i)/d_i=O(L), with ell_i=log[(1+beta_i)/(1-beta_i)]. Recovery cost O(L)exp[-Ω(L^(1/3))]=o(1); scheduled cost kappa(S)(L+L^(2/3))+O(1). Wrong-sign risk ≤exp(-h_i), so the weighted squared target prediction excess ≤Σ_i 4a_i exp(-h_i)≤eta. Apply per task for early, to U with bar_a_i for late.

### Exact structural example, Q2 link and limits

Cycle group experiments G_01={0,1}, G_12={1,2}, G_02={0,2} with unit costs and d_i=d. Three uniform singleton tasks: kappa({i})=1/d, union kappa(U)=3/(2d). Primal schedule x_q=1/(2d) and dual y_i=1/2 are exact matching certificates, giving late/early ratio 3/2. Singleton-only oracles give ratio 3; one cost-1 joint all-coordinate group collapses it to 1.

For any fixed fresh A*, f_A*(t,z)=Σ_i w_ti A_i* z_i is globally bounded by max_t Σ_i|w_ti| and genuinely Hoeffding degree ≤2 on product coordinates (T,Z_1,...,Z_m). This gives a **Q2-independent** informational-conversion benchmark in bounded quadratic product spaces. Initially the ν-averaged state-coordinate actionable influence may vanish, while model-coordinate probes still matter. The latter is a distinct resource.

Do NOT extend theorem to full f posterior evaluations, arbitrary mixed group signals, dependent group outputs, correlated latent priors, hard worst-case query caps, task-dependent oracle laws, or growing m jointly with 1/eta. The theorem is author-analytic and has not received independent specialist refereeing or priority clearance.

### Independent audit / provenance / next decisive experiment

The independent exact Fraction checker in the A2 user-facing reproducibility bundle passed a matching 3-cycle LP primal and dual, 512 adaptive group-transcript posterior-factorization atoms, 128 exact conditional squared-risk comparisons, and 12 finite random-walk survival checks. It is a falsifier, not a quantified proof. The PDF and editable LaTeX are in that separate bundle (SHA-256 59662244a977c2fcd7529af9cab33a9b6a4d0825d173cb636ffcf962bd112001); this repository note does not claim those exact binary bytes are checked into the PR.

The next actual novelty test is a **nonseparable arbitrary mixed-evaluation oracle with constructively achievable information-cover dual**, while maintaining exact oracle and task matching. Independent reviewer must test 2015/2025/2026 theorem-type subsumption before promotion.
