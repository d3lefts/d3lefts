# Causal feedback simulation with one shared-information charge
## Proof candidate v0.1 — 2026-11-25

Status: author-side mathematical derivation, exact finite falsification tests, no independent reviewer or Lean terminal. This extends #1206's causal-release statement using the stronger Paper VI observable-energy dichotomy. No global originality or publication claim.

### Frozen model and review contract

Objective: improve the causal-release private query exponent and extend fixed-target simulation to feedback-selected tasks without paying a latent-information budget at each time. Source X has a known finite-alphabet law and legal queries return only one released original coordinate. Nested deterministic release sets J_t for t=1,...,h; selection at stage t of a globally [0,1]-valued function f_{t,H} depending only on J_t is a deterministic function of paid history H at entry. Uniform interaction degree at most d_t >= 1 over every feasible selection. No hidden task index, future coordinate, latent query, free physical dynamics evaluation, or runtime guarantee.

Strongest checked internal sources: merged #1197 (latent projection and two-potential bounds), general-latent #970/#976, shared target #1036, archived #1206 at c5a1c98ce3bcea4cd689aba131442ad69885fc71. Paper VI's analytic Theorem 3.4 and Section 4 drift are the exact invoked source; its pending terminal CI #1201 is not silently assumed green. External comparison search on 2026-11-25: Pola, Girard and Tabuada, Approximately bisimilar symbolic models for nonlinear control systems (https://arxiv.org/abs/0706.0246); Pacheco et al., Variational Information Planning for Sequential Decision Making (https://sli.csail.mit.edu/pdfs/publications/pacheco2019aistats.pdf); Conditional and Relevant Common Information (https://doi.org/10.1093/imaiai/iaab021). These establish antecedents in approximate simulation, information acquisition and common-information notions. Search snippets/abstracts, not a complete full-text priority audit. Novelty threshold: actual causal legal-query bound with a single shared information charge, not merely standard Lipschitz error propagation. Significance threshold: improved tolerance exponent compared with the earlier causal scalar good-query route, with explicit assumptions.

### Theorem A. Causal staged stopping with a single global Wyner charge

Let a_t,p_t,b_t be any valid uniform constants in the source-level posterior dichotomy from Paper VI: at any positive-variance posterior and actual current target section, one released unread original j satisfies E_Theta I_j(g) >= a_t v^p_t or I(Theta;X_j | H) >= b_t v^3. The energy exponent is p_t>1. For general degree use the published source constants (p=5/2, a=2^(-5/2)c_0 d^(-6)); for degree at most two take p=2 and a=1/106. The written switching coefficient is b=(2916 K_d d^4)^(-1), K_d=pi^2 d^2/2; a weaker certified coefficient can be substituted without changing the following derivation. Private potential P=sum conditional product influences <= d_t v, and its exact expected drop is the queried influence.

Fix 0<tau_t<=1/4. Define r_{t,0}=1/4 and r_{t,j}=max(2^(-j)/4,tau_t), stopping at the first index N_t with r_{t,N_t}=tau_t. Define

E_* = sum_t (d_t/a_t) sum_{j=1}^{N_t} r_{t,j-1}/r_{t,j}^{p_t},
B_* = min_t b_t tau_t^3,
Q_* = E_* + C_W(X)/B_*.

There is a deterministic causal policy that never repeats a paid coordinate, outputs each selected target's conditional mean at its deadline, and uses total random query count N<=|X coordinates|. Each deadline posterior variance is at most tau_t almost surely, and E[N]<=Q_*.

For any nonnegative integer m, a capped deterministic policy uses <=min(m,|X coordinates|) queries, never queries future coordinates, and at each deadline has MSE <= tau_t+(1/4-tau_t) min(1,Q_* /(m+1)). Its probability of any local target error >eps_t is <= min(1, Q_* /(m+1)+sum_t tau_t/eps_t^2).

In particular,
E_* <= sum_t [2 d_t/a_t (1+1/(1-2^{-(p_t-1)})) tau_t^{1-p_t}],
so the general-degree private cost is O(sum_t d_t^7 tau_t^(-3/2)) using the stated written coefficient, and quadratic private cost is O(sum_t tau_t^-1). The information term is at most O(C_W max_t d_t^6 tau_t^-3) and is paid ONCE across the horizon, including adaptive task selections. The general private exponent may be sharpened by substituting a stronger valid a_t. Do not infer a stronger degree exponent from this argument alone.

### Proof

Use the finite minimizing product mixture for the actual multivariate Wyner definition, as in #970/#976 and #1197 Section 2. Given a paid history, the event of reaching it is a cylinder: task choices, releases, stops, actions and query choices are deterministic functions of previous observed values; none is an additional observation. Conditional on the latent label, unread coordinates remain product. Released marginal components remain product as well. Freeze the chosen target at stage entry; subsequent query selection uses that fixed target until its deadline. All target sections remain globally bounded and of the specified degree. The posterior dichotomy applies to the released marginal only, so no future coordinate can be selected.

At stage t, process thresholds r_{t,j} in order. At a positive-mass history with variance v>r_{t,j}, choose a released unread coordinate from the dichotomy, labeling the query energy-type if the energy alternative is used and information-type otherwise. Continue until the variance first falls to <=r_{t,j}; this may occur at phase entry. Fully reading the released coordinates gives zero variance, so every phase terminates. Variance need not be pathwise monotone during a phase; a later upward jump does not restart previous phases. Only the stopping value bounds the next phase's initial potential.

For a fixed starting history of phase j, P starts at <=d_t r_{t,j-1}. This includes phase 1 since every [0,1] posterior has variance <=1/4. Every energy-type query before threshold crossing has conditional expected P-drop at least a_t r_{t,j}^{p_t}. All other queries have nonnegative expected P-drop by the exact source identity. Finite-tree telescoping to the random phase terminal, with P>=0, gives expected energy-type count <=d_t r_{t,j-1}/(a_t r_{t,j}^{p_t}), conditionally on the phase entry. Integrate entry histories and sum. This argument is independent of the number and distribution of branches.

For the shared term use the GLOBAL residual potential J(H)=I(Theta; X_unread | H), including unreleased coordinates. Its expected drop on any query j is exactly I(Theta;X_j | H) by the chain rule. Task change, deadline prediction and release of permission to query do not reveal values and do not change J. Each information-type query satisfies I(Theta;X_j | H)>=b_t v^3>b_t tau_t^3>=B_*. The global potential is nonnegative, starts at C_W, and telescopes over all stages. Hence E[number of information-type queries]<=C_W/B_*. Adding private and shared counts proves E[N]<=Q_*. This proof never substitutes a latent query or charges a separate information budget at a deadline.

At the stage deadline, conditional mean has conditional squared risk <=tau_t. For the cap, run exactly the same policy until the next paid query would exceed m, then make no further queries and output each selected target's posterior mean. Both policies have the same histories up to that abort event. Integer Markov gives P(abort)=P(N>m)<=E[N]/(m+1). Before abort the deadline variance cap holds; after abort all actual selected [0,1] targets have variance <=1/4, also when target selection and controls differ from the untruncated policy. Abort-before-deadline is measurable from its actual transcript. This proves the stated MSE bound. For the simultaneous probability bound, couple both policies until abort and use conditional Markov plus the union bound on the untruncated policy, not conditioning on future no-abort.

Finally r_{j-1}<=2 r_j. Every r_j except possibly the final target threshold is dyadic, so for p>1 the sum of inverse powers is bounded by tau^{1-p} (1+1/(1-2^{-(p-1)})), using the backwards geometric series. If tau=1/4 there are no phases. This yields the explicit private estimate. End proof.

### Theorem B. Tracking an actual feedback-controlled dynamical trajectory

Take scalar state s_t in [0,1], controls in a compact interval, finite innovation coordinates released no later than their use, and a known discrete-time controlled system
s_{t+1}=F_t(s_t,u_t,xi_{t+1}), u_t=pi_t(s_t).
Assume the true and simulated-control trajectories stay in [0,1] for every innovation and admissible control. Assume F_t is Lipschitz in state and control uniformly in the innovation, with nonnegative constants L_s,t and L_u,t, and pi_t is L_pi,t-Lipschitz. For every fixed possible past control sequence, require the state pullback to the original initial/innovation coordinates to be globally [0,1]-valued and of degree <=d_t, and to depend only on J_t. The law may correlate all coordinates; this is not an independent-noise assumption.

Construct a query policy by Theorem A. At stage t select the target z_t(X) obtained by rolling out the system under the simulation policy's already selected controls (which are known from the paid history). Output its posterior mean hat{s}_t, then set hat{u}_t=pi_t(hat{s}_t). The actual approximate-control trajectory z starts at the same initial state as the true full-state-feedback trajectory s and uses the same innovations. The task choice is a deterministic history function, so Theorem A applies. In particular with probability at least 1 - min(1,Q_* /(m+1)+sum_t tau_t/eps_t^2), every |hat{s}_t-z_t|<=eps_t.

On that event let rho_t=L_s,t+L_u,t L_pi,t and c_t=L_u,t L_pi,t. Then
|z_{t+1}-s_{t+1}|<=rho_t |z_t-s_t|+c_t eps_t.
This follows by applying the two Lipschitz bounds and |hat{u}_t-u_t|<=L_pi,t (|hat{s}_t-z_t|+|z_t-s_t|).
Since z_1=s_1, iteration gives
|hat{s}_t-s_t|<=eps_t+sum_{j<t} c_j eps_j product_{j<l<t} rho_l.
If rho_t<=rho<1, c_t<=c and eps_t<=eps, this is uniformly <=eps(1+c/(1-rho)). No extra shared-information charge is incurred by feedback selection. This is true closed-loop tracking of the reference controller, not merely prediction of the approximate-control rollout.

Concrete nonempty family: s_{t+1}=alpha_t s_t+beta_t u_t+gamma_t (mean of a released block of binary innovations), with nonnegative coefficients whose sum is <=1, initial state an affine bounded function of released initial coordinates, and Lipschitz controls in [0,1]. With fixed controls every pullback is degree 1 regardless of block lengths or horizon. Theorem A's query bound is independent of those lengths; if rho<1 then Theorem B supplies a horizon-uniform tracking multiplier. This is a sufficient query-complexity result, not a polynomial-time controller implementation or general stochastic bisimulation theorem.

### Verification and review

Executed on 2026-11-25 using Python standard library: check_causal_feedback.py. Output:
{'models': 49, 'energy': 41, 'nodes': 42, 'information': 1, 'feedback_steps': 139968}
SHA256 fc259760a5496cd5c62a8ffe502d8d8e7340afb2d8dc7c86bc136bca3c677ac2; Git blob fcbc23b654ab5463e3c6a8800079b783162fbba8.
The exact rational checker separately constructs binary mixture laws, posterior variance, resampling energy, and information via formal prime-log coefficient vectors. It checks actual global information chain identities (no floating-point entropy), actual energy drop, threshold stopping, release legality, adaptive second target, truncation Markov, and signed local-error feedback recurrence. Includes deterministic labels, zero weights and a pure common-label source where the information branch is necessary. Counts are finite sanity tests only; the exact checker does not establish the general theorem or global priority.

Independent audit plan: non-author rederive phase entrance bound and stopped drift; attack whether selected targets remain fixed within stages, whether release decisions accidentally disclose data, future conditioning at the cap, zero Wyner and exhausted coordinates. Check every Lipschitz application and same-innovation coupling; compare actual-control and reference-control trajectories. Re-run checker independently; construct discontinuous feedback or high-degree counterexamples to overbroad claims. Formal target: source-defined arbitrary finite legal policy with dynamic target family and global potential; separate exact named recurrence and contraction lemmas, then compose with actual Paper VI dichotomy. Strongest external search result above is adjacent approximate-bisimulation work, not matched query theorem; full priority clearance and independent human review remain open.

Budget and stop rule: current finite tests are 49 small mixture models plus 139968 signed-error steps. If any exact replay fails, demote the corresponding claim. Do not promote this candidate until independent mathematical attack and source-exact formal proof have passed. Broader integrating observation characterization, matching lower bounds for general dynamical systems and non-Lipschitz feedback remain unresolved.
