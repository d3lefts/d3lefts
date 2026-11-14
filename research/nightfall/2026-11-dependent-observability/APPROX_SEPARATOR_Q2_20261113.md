# Approximate-separator quadratic observability on connected finite sources

**NIGHTFALL research note — 2026-11-13.** Status: self-contained author-analytic transfer conditional on the repository's finite arbitrary-product Q2 theorem; independently falsified on finite exact-rational examples. Not a new theorem of high-temperature mixing, a terminal Q2 Lean proof, a globally novel cutset-conditioning method, or independent specialist referee approval. AI-assisted mathematical research and computational checks.

## Problem and exact source/oracle contract

Let the actual finite factor-graph law be mu and let S be a supplied s-site cutset. Partition the other coordinates into m blocks of size at most k. After seeing a feasible S=z, absorb factors meeting at most one residual block to obtain a **reference** law nu_z=product_b nu_{b,z}. Put the remaining strictly positive cross-block factors in L_z(x)=product_{F cross} psi_F(z,x). The **actual** source is

    mu_z(dx) = [L_z(x) / E_{nu_z} L_z] nu_z(dx).

Every cross factor has a source-certified local table range 0<ell_F<=psi_F<=u_F. Define

    R = product_F (u_F/ell_F),    Lambda=log R,
    delta=(sqrt(R)-1)/(sqrt(R)+1)=tanh(Lambda/4).

The factor bounds must hold uniformly over feasible z and reference-supported configurations. Local factors may contain zeros. The observer reads actual source coordinates. The separator is **supplied rather than discovered for free**; reference block conditional distributions and exact block influence scores are part of a separately priced implementation oracle. The site-level bounded observable f is an algebraic sum of terms on <=2 distinct coordinates; ||f||<=B.

## Lemma: sharp likelihood-ratio / total-variation transfer

For probability nu, positive L in [a,b], and mu=(L/E_nu L) nu,

    TV(mu,nu) <= (sqrt(b/a)-1)/(sqrt(b/a)+1).

Proof: if h=E L, endpoint convexity gives E|L-h|<=2(b-h)(h-a)/(b-a), so TV <=(b-h)(h-a)/[h(b-a)]. This is maximized at h=sqrt(ab). Equality is obtained by a two-point reference law with weights chosen to give that mean. Applied to source L_z, TV(mu_z,nu_z)<=delta.

This is a classical sensitivity/oscillation mechanism, with a sharp elementary constant; do not treat its discovery as a priority claim.

## Theorem A: dimension-free approximate-separator observation

**Q2 premise:** original-law, finite heterogeneous-product quadratic influence inequality, with constant C2=(10+2sqrt(2))^2(1+sqrt(3))^2. This premise is analytic and is not yet a terminal same-source Lean theorem. For any eta in (0,B^2], read S and greedily read reference-max-influence full blocks. The resulting reference conditional-mean predictor has, under the **actual** connected source,

    E_mu (f - fhat)^2 <= eta + 4 B^2 tanh(Lambda/4),

while requiring at most

    N_actual_site_reads <= s + k min{m,ceil(4 C2 B^2/eta)}.

For Hilbert-valued output dimension r, replace C2 by C2/c_r^2, with c_r=Gamma(r/2)/(sqrt(pi)Gamma((r+1)/2)), and use squared Hilbert loss.

**Proof.** Under nu_z the macroblocks are independent, the site-degree-two f is also macroblock degree<=2, and its source bound remains B. Original-law degree-two ANOVA gives remaining variance V<=potential P<=2V. Q2 gives max macroblock influence >=P^2/(4C2 B^2). The genuine product potential drops in expectation by the selected macroblock influence. Jensen/reciprocal telescoping gives E P_q<=4C2 B^2/q. If q=m no variance remains. Since f and the reference conditional mean fhat lie in the B-ball, the squared error is at most 4 B^2 pointwise. Coupling the **same actual-read policy** under mu_z and nu_z changes expected loss by at most 4 B^2 TV<=4 B^2 delta. Average over the *actual* separator law mu_S. No exponential likelihood ratio appears in the final risk.

For two distinct approximation interfaces, a bounded posterior P replaced with an independent approximate posterior Q of TV error epsilon (requiring both posterior means to have quadratic degree) gives true-model excess risk <=(sqrt(eta)+2 B epsilon)^2+4 B^2 delta; model-noise variance is separated by conditional orthogonality. Synthetic source samples and model evaluations are **not** free in this corollary.

## Theorem B: robust same-interface connected-graph lower bound

Let m>=1, fixed 0<t<1 and v=1-t^4. Give the observer a fair hub Z for free. Reference leaves X_1,...,X_{2m} are independent conditional on Z=z, each with mean tz. Give the **actual** law additional positive Ising-path factors

    L(x)=product_{i=1}^{2m-1}(1+eps x_i x_{i+1}),
    eps=v/(128 m^2).

Then the residual graph **after the hub is observed is connected**, every configuration is positive, and the actual and reference conditionals differ by TV at most delta<=v/(64m). Let f_m(x)=m^{-1} sum_{j=1}^m x_{2j-1}x_{2j}; it is bounded by 1 and has site-degree 2.

Any randomized adaptive policy using the same actual-coordinate read oracle with true squared risk <=eta=v/(2m) must read at least m/4=v/(8eta) distinct leaves in expectation, even with the hub free.

**Proof.** Under the reference law any pair with neither leaf read retains variance v/m^2. Adaptive stopping cannot reveal untouched independent pairs; if r distinct leaves are read then at least m-r pairs are untouched. Therefore reference Bayes risk >=v(m-E_nu r)/m^2. Clipping the prediction to [-1,1] permits |risk_mu-risk_nu|<=4delta, and the read-count bound r in [0,2m] gives |E_mu r-E_nu r|<=2m delta. Since log[(1+eps)/(1-eps)]<=4eps for eps<=1/2 and tanh a<=a, delta<=v/(64m). Risk_mu<=v/(2m) therefore forces

    E_mu r >= m/2 - 4m^2 delta/v -2m delta
           >= 7m/16 -1/32 >=m/4.

This is a matching-order Omega(1/eta) lower bound for **actual state reads**, not posterior-model evaluations or verification operations. It is a fixed-t, accuracy-dependent family with eps=Theta(m^-2).

## Source, novelty, and resource boundaries

- Locally checkable factor ranges cost one scan of each relevant finite factor table; verifying the partition and completeness of the factor list is essential. The hard tasks of choosing an optimal separator and building a trusted factor graph are not included free.
- For a change affecting **only one cross factor**, source certificates for unaffected factors remain valid. Recomputing the modified factor range and the aggregate R gives a change-stable **error guarantee**, provided the underlying factorization and reference law have not changed. This does not certify originality or automatically reverify the policy implementation.
- Classical predecessors: Mateescu–Dechter (IJCAI 2005), AND/OR Cutset Conditioning, https://ijcai.org/proceedings/2005/220 ; Bidyuk–Dechter, Cutset Sampling for Bayesian Networks, https://arxiv.org/abs/1110.2740 ; Doucet, A Note on the Sensitivity of the Posterior Distribution to the Likelihood Function, https://www.stats.ox.ac.uk/~doucet/doucet_notesensitivityposteriortolikelihood.pdf .
- The generic Q2 theorem is the **imported NIGHTFALL analytic premise**, not a new independently compiled endpoint of this PR. Existing source proof: research/nightfall/2026-11-quadratic-law-free-audit/Q2_SOFT_OWNERSHIP_SOURCE_NOISE_BRIDGE_20261113.md .
- The connected high-temperature problem with a nonvanishing local coupling strength and a full same-oracle posterior-evaluation lower bound remain open. This source is not evidence for those broader claims.

## Independent falsification, exact source artifacts

Two independently programmed Fraction scripts in the associated downloadable research package:
1. check_approx_separator_exact.py: **2,365** assertions across 36 connected finite source models, all fixed-read subsets for up to six leaves, sharp likelihood ratio TV, conditional expected loss and untouched pair risk.
2. check_adaptive_weak_star_exact.py: **13,170** exact assertions across 48 fully adaptive read-or-stop Bellman problems, using the **true connected source** rather than the reference law.

Original local SHA-256:
- First checker 0c4bac9b7baeea6133421cc7271ff83e454264f3500b540ad7f32333b9b6769c
- Second checker 15eec406bc3c8bd147550fb78532ac60364e1e877bd62e492636048d5e940ac1
- Manuscript TeX 9c092c0056fdea64ab1b9cda61184a35e3bc419500e8afe1371410de1c017191
- Manuscript PDF 592c4a9fb2466a93dbf3a1bc703b983b671e65742ceea7039268d2e6bd8270be

**Custody rule:** The PDF, LaTeX and exact original checkers are preserved in the conversation artifact ZIP. Unless these exact binary/text bytes are explicitly uploaded in this PR, do not assert GitHub source identity. CI should check only the scripts actually committed, not the off-repo archive.

### Next decisive research question

Can we weaken the total oscillation budget Lambda (which can scale with the number of cross links) to a **locally summable susceptibility norm** or certified low-rank residual interaction, while keeping a dimension-free accuracy guarantee and a same-primitive lower bound? Such a result would go materially beyond a standard TV stability corollary.