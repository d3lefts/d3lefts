# The Convoluted Costs of Knowing — actionable influence and oracle-cost bridge

**Version:** 2026-11-13 A1. **Status:** exact posterior identities; fully quantified author-analytic observer theorem *conditional on Q2*; corrected minimax binary-oracle benchmark. No independent specialist proof/priority claim; no end-to-end Lean certification asserted or required for mathematical originality.

## I. Exact actionability decomposition

Fix evidence D, a finite independent product state X independent of the posterior model Theta, and a fresh coordinate-resampled copy X^(i). Let m_D(x)=E_Theta[f_Theta(x)|D] and I_i(g)=E(g(X)-g(X^(i)))²/2. For conditionally independent posterior draws Theta_1 and Theta_2 and one **shared** state-resampling pair,

    I_i(m_D)= (1/2) E[ Delta_i f_{Theta_1} Delta_i f_{Theta_2} | D].

By the orthogonal decomposition of resampling differences into posterior mean and mean-zero residual,

    E_{Theta|D} I_i(f_Theta)
      = I_i(m_D) + E_{Theta|D} I_i(f_Theta-m_D).

The first term is *actionable influence* (sensitivity of the current Bayes predictor); the second is *epistemic influence* (posterior variance of coordinate differences). The **cost of discovering** the actionable coordinates is a separate resource, not a third influence identity.

Example: f_Theta(x)=Theta*x_i with a uniform unknown posterior sign has each individual-model influence 1, but actionable influence 0: observing x_i cannot improve the Bayes prediction 0.

**Additional degree-two epistemic-energy law.** Let R_model(D)=E_{X}Var_{Theta|D}(f_Theta(X)). If every f_Theta has Hoeffding degree ≤2, then each residual r_Theta=f_Theta-m_D also has degree ≤2 and therefore

    sum_i E_{Theta|D} I_i(r_Theta)
      ≤ 2 E_{Theta|D} Var_X(r_Theta)
      ≤ 2 R_model(D).

Consequently the **total coordinate epistemic sensitivity** is itself quantitatively bounded by twice the irreducible model-prediction risk. This bound does not imply any particular coordinate's epistemic contribution is actionable. It is a simple exact ANOVA corollary, not an independent novelty claim.

## II. Valid four-evaluation estimator

Suppose each call U(x) independently draws an inaccessible posterior model and returns f_Theta(x), with |f_Theta|≤B. On a synthetic independent product pair x,x^(i), four independent calls yield

    W_i=(U_1(x)-U_2(x^(i)))*(U_3(x)-U_4(x^(i)))/2.

Each bracket has conditional mean m_D(x)-m_D(x^(i)), and brackets are independent conditional on the **same** pair, hence E W_i=I_i(m_D). Since W_i∈[-2B²,2B²], for s fresh copies

    Pr(|Ihat_i-I_i|>epsilon)≤2exp(-s*epsilon²/(8B⁴)).

The returned samples need not disclose Theta; each oracle call must be independent. Synthetic state generation, oracle evaluations, actual state reads, and computational time are distinct resources.

## III. Conditional finite-degree-two observation theorem, complete parameters

Hypotheses: n≥1 finite independent state coordinates, 0<eta≤B², B>0, true Theta independent of fresh X conditional on D, every posterior-supported f_Theta is degree ≤2 with global |f_Theta|≤B; independent posterior-value evaluations and conditional-product synthetic sampling are available. **Assume**, without claiming here to certify, the finite-product Q2 theorem for all degree-two bounded source sections:

    Var(g)²≤C₂ B² max_i I_i(g).

Set

    epsilon=eta²/(256*C₂*B²)
    rho=eta²/(128*C₂*B⁴)
    s=ceil[(8 B⁴/epsilon²)*log(2n/rho)]
    t=ceil[2 B²/eta]
    q=min(n,ceil[32*C₂*B²/(3eta)]).

Each of at most q stages estimates every unread coordinate influence with s independent W_i replicates under the residual conditional product law, and reads the actual coordinate maximizing the estimate. Afterward draw t fresh independent posterior model evaluations at independent synthetic completions consistent with observed coordinates and output their mean.

Then, **conditionally on Q2 and the stated interface**,

    E[(f_Theta(X)-Yhat)² | D]≤R_model(D)+eta
    R_model(D)=E_X Var_{Theta|D}(f_Theta(X)),
    N_actual_reads≤q,
    N_posterior_evaluations≤4*n*s*q+t.

Proof. At any coordinate history H, let V(H) be the residual variance of the true posterior mean and P(H) its total remaining source influence. Degree-two ANOVA gives V≤P≤2V. Q2 implies M(H)=max_i I_i≥P(H)²/(4C₂B²). A per-stage union bound gives probability ≥1-rho that all empirical influences differ by ≤epsilon. Thus conditional expected selected true influence ≥ M(H)-2epsilon-rho B² (because I_i≤B²). Exact degree-two source-energy bookkeeping gives E[P(H)-P(H,new actual coordinate)] = I_selected. Taking expectations and Jensen, with p_k=E P(H_k),

    p_k-p_{k+1}≥p_k²/(4C₂B²)-delta,
    delta=2epsilon+rho B²=eta²/(64 C₂B²).

For p_k≥eta/2, delta≤p_k²/(16C₂B²), so p_k-p_{k+1}≥3p_k²/(16C₂B²). The nonnegative p_k is nonincreasing; reciprocal telescoping implies p_q≤eta/2 by the stated q; observing all n coordinates instead gives P=0. The final t independent posterior/completion samples estimate the residual conditional predictor with variance ≤B²/t≤eta/2. Orthogonal model noise, unseen-state noise and Monte Carlo noise give the displayed risk. Per-decision (not whole-trajectory) concentration suffices for **expected risk**.

The cost is a valid, potentially very large, conditional upper bound, not a claim of optimal polynomial runtime: naive posterior-call complexity can scale as eta^{-5}. No categorical Q2 priority or novel influence-oracle lower bound is inferred.

## IV. Corrected address-model separation: logarithmic rather than reciprocal accuracy

Unknown fixed signs nu∈{±1}^m, independent fair prior; known 0<beta≤1/2. The **evaluation-only** posterior oracle, on address j, produces fresh independent sign U_j with mean beta*nu_j, not a full model sample or coefficient-vector description. Target Y=A_K*Z_K where K uniform on [m], Z_j independent fair signs, and A_K* an independent same-law posterior sign. The posterior mean is m_nu(K,Z)=beta*nu_K*Z_K; R_model=1-beta².

Read K and Z_K. Taking r oracle values at K and averaging gives exact excess risk (1-beta²)/r, but this estimator is **not minimax optimal** when beta and the ±beta structure are known. Majority-sign testing and output beta*sign(sum U)*Z_K give excess risk

    ≤4beta² exp(-r beta²/2).

Thus for 0<eta<beta²/8 the on-demand task has an upper bound O(beta^{-2} log(beta²/eta)); global mean-squared reconstruction needs O(m beta^{-2} log(beta²/eta)) by testing all m independently.

For matching lower bounds against *arbitrary randomized adaptive evaluation-only policies*, let d_beta=beta*log[(1+beta)/(1-beta)]=Theta(beta²). Under the uniform unknown-sign prior, by adaptive transcript KL and Bretagnolle–Huber binary testing, each sign's average error after expected N_j calls to its address is at least (1/4)exp(-d_beta E N_j). If a real coefficient estimate has the wrong sign, its squared error is at least beta². Jensen across m addresses gives

    E[L² reconstruction error]≥(beta²/4)exp(-d_beta E T/m).

Even revealing K and Z_K for free, the on-demand excess-risk lower bound is ≥(beta²/4)exp(-d_beta E T). Thus in the stated small-eta regime the **matched orders** are

    T_on-demand = Theta(beta^{-2} log(beta²/eta))
    T_global    = Theta(m beta^{-2} log(beta²/eta)).

These are oracle-restricted versions of classical indexed binary testing, not evidence that an influence estimator is necessary: the optimal policy reads the address directly. A full-vector posterior draw, or revealing nu through evidence D, invalidates the global lower bound. If eta≥beta², a zero posterior-mean reconstruction already meets the squared-error tolerance.

## V. Novelty and significance boundary

References checked: Rahbar et al., IJCAI 2023, DOI 10.24963/ijcai.2023/463 (posterior-sampling active feature acquisition); Bickford Smith et al., AISTATS 2023, https://proceedings.mlr.press/v206/bickfordsmith23a.html (prediction-oriented rather than parameter information gain); Aronsson et al., IJCAI 2026, DOI 10.24963/ijcai.2026/860 (AFA/POMDP survey and guaranteed-method taxonomy). Sequential KL and binary testing are classical. These do not certify original priority or exclude further theorem-type subsumption.

**Next structural target:** prove a source-interface-matched upper/lower theorem that holds against *all* adaptive acquisition algorithms and explains when actionable influence gives a genuine resource advantage over alternative policies. The core mathematical contribution must go beyond renaming conditional variance and beyond task-specific prediction being cheaper than reconstructing the complete model.

**Exact-rational replay:** companion Python checker verifies 512 four-posterior atoms and both influence decompositions plus 14 majority-vs-sample-mean risk comparisons; SHA-256 for original session checker 750ca69cfcde9789ef8ff49b00087381fad4f25651ac834920bfd414aeec2f83. Finite tests are falsification, not mathematical proof.
