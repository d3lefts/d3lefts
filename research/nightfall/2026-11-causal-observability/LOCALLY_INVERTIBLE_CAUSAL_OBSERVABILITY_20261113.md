# Locally certified causal observability: inverse-noise DAG theorem and change-stable scores

**NIGHTFALL research handoff — 2026-11-13.** Authorship: research directed by Devin J. Wright, AI-assisted derivation and computation. **Status:** complete source-level author-analytic implications with exact finite falsification, NOT global historical novelty, peer review, or terminal same-source Lean certification of Q2. The linear-rank extension also remains author-analytic. The original independent-product Q2 premise is in \`research/nightfall/2026-11-quadratic-law-free-audit/Q2_SOFT_OWNERSHIP_SOURCE_NOISE_BRIDGE_20261113.md\`.

## 1. Locally checkable dependence certificate (unconditional)

A finite Bayesian-network source law factorizes on a supplied directed acyclic graph \`D\` with maximum indegree \`d\`. Each node \`v\` has a finite alphabet \`A_v\` of size <=\`a\` and conditional law \`K_v(x_v|x_pa(v))\`. The following are equivalent:

(i) All rows of the CPT at v have identical multisets of probabilities (including zeros);
(ii) There exist a fixed distribution p_v on A_v and a parent-context-dependent permutation phi_v,z on A_v with
    K_v(x|z)=p_v(phi_v,z^{-1}(x)).

Pick and commit a deterministic tie-breaking rule for repeated equal masses. With independent noises U_v~p_v, physical states are X_v=phi_v,X_pa(v)(U_v). The triangular change of variables is bijective; source probability is exactly product_v p_v(U_v). Read X_v and its <=d parents to recover U_v. CPT verification scans O(sum_v |A_v|^{|pa(v)|+1} log |A_v|) entries, plus a DAG and full-model-factorization check. There is no global total-variation/density ratio assumption.

This iff is for exactly invertible local noise **of the same alphabet cardinality**. General noninvertible structural equation models can exist even when rows are not permutations. A pair of Bernoulli conditional rows (0.9,0.1) and (0.8,0.2) is a local certificate rejection, not an impossibility theorem for other observability representations.

## 2. Q2 and site observation (conditional on author-analytic product Q2)

A task has a supplied, exact source identity in the fixed innovation variables
    f(X(U))=c+sum_v g_v(U_v)+sum_{v<w in H} g_vw(U_v,U_w)
and a **full-domain** |f|<=B certificate. H has max task interaction degree Delta.

The product Q2 premise has
    C2=(10+2sqrt(2))^2(1+sqrt(3))^2,
    Var_nu(f)^2<=C2 B^2 max_v I_v^U(f).

Every history consisting only of selected innovations leaves the others independent, so exact greedy innovation-score observation has conditional remaining variance <=eta with
    q <= min{n,ceil(4 C2 B^2/eta)}
innovation reveals, or <=(d+1)q **actual physical node reads**. Influence here is an *innovation resampling influence*, NOT the physical heat-bath influence of one X_v. Other physical readings used to recover U may reveal additional information; the policy ignores that surplus for the upper bound. No global mixing/likelihood penalty appears. For rank-r Hilbert output, the already author-analytic rank-sensitive constant Cr=C2/c_r^2=O(r) replaces C2.

**Unconditional counterpart (no Q2 needed):** if f=c+sum_v g_v(U_v), observing q largest-variance innovations achieves exactly the residual variance sum of unselected terms, <=B^2/(4q), with <=(d+1)q node reads; the sharp additive proof uses sum_v sqrt(Var g_v)<=B. This extends the previously proved tree-innovation additive mechanism to certified multiparent DAGs.

## 3. Exact and local score-maintenance theorem

For each edge {i,j} of the task interaction graph H, define original-product double-centered b_ij=g_ij-E_i g_ij-E_j g_ij+E_ij g_ij. Define
    r_i(u_i)=g_i(u_i)+sum_{j in N_H(i)} E_{p_j}g_ij(u_i,U_j);
    a_i=r_i-E_{p_i}r_i.
Then the true source innovation influence is
    I_i=E_{p_i} a_i^2 + sum_{j in N_H(i)} E_{p_i p_j} b_ij^2.
This is exact, no supplied influence oracle.

When a SINGLE innovation law p_k changes, but decoder permutations phi and the task program/certified H are frozen, ONLY scores for {k}∪N_H(k) can change. Recompute them and the expected task value in O((Delta+1) a^2) arithmetic and O((Delta+1) log n) indexed-priority-queue updates after O((n+|H|)a^2) preprocessing. Observing U_k=u uses the same update with p_k replaced by a point mass.

If externally supplied CPT tables change with fixed phi, validate the changed row table in O(a^{d+1}) entries; retaining the global certificate requires authenticated immutable identities for the rest of the source (e.g. Merkle authentication O(log n)), a complete factor list, an unmodified task representation and one frozen source version per observation episode. Such source authenticity is a **trust premise**. Global dependent physical marginals may change without requiring global score recomputation because the score coordinates are the independent U.

## 4. Model uncertainty and explicit oracle charges

In the separate sample-only posterior setting, assume P(Theta|D) independent of fresh state U, each bounded model f_Theta of innovation degree <=2 with the same decoders, and independent posterior samples. For a state U and independent one-site replacement U^i, two independent posterior models define
    Z_i = [f_{Theta1}(U)-f_{Theta1}(U^i)] [f_{Theta2}(U)-f_{Theta2}(U^i)]/2.
Then EZ_i=I_i(m_D) for m_D=E_Theta f_Theta and |Z_i|<=2 B^2. Each trial costs 2 posterior draws, 4 model evaluations, 1 full synthetic conditional innovation state and 1 refreshed noise coordinate.

With K=4 C2 B^2, target eta in (0,B^2], use:
    q=min(n,ceil(4K/eta)),
    eps=eta^2/(256K), zeta=eta^2/(128 K B^2),
    N=ceil[(8B^4/eps^2)log(2n/zeta)], L=ceil(2B^2/eta).
Estimate all remaining scores by N independent cross-model trials each round, select empirical max, then estimate the remaining conditional mean with L independent model/state pairs. Hoeffding + approximate greedy potential give risk <= R_model+eta. Explicit charges:
    actual node reads <=(d+1)q;
    posterior draws <=2 n q N+L;
    model evaluations <=4 n q N+L;
    synthetic individual innovation draws <=(n+1)n q N+nL;
    initial model source/table/degree/decoder certificates separately charged.
This is a conservative ~eta^-5 value-evaluation upper bound (for fixed B,C2,n), not a matched model-evaluation theorem. The previously recorded vector Bernstein-batching method in PR #463 improves it under extra batching, but is not smuggled into the present proof.

## 5. Matching same-interface obstructions

**Genuinely dependent physical star:** root Z uniform in Z_3, independent leaves U∈{0,1} fair, physical X_leaf=Z+U mod3. The leaves are dependent: P(X_1=X_2)=1/2, not 1/3. For rank r and m pairs of innovations, task
    f(U) = B/(m sqrt r) sum_{ell=1}^r e_ell sum_{j=1}^m (-1)^{U_ell,j,1+U_ell,j,2}
satisfies ||f||<=B, variance B²/m and innovation degree 2. Even revealing the root for free, after R adaptively selected leaf reads, at most R/2 independent pairs are complete. Residual Bayes risk >=B²/m-B² E[R]/(2 r m²). Achieving eta=B²/(2m) requires E[R]>=rm=rB²/(2eta). This is the matching order for **actual physical coordinate reads** with other posterior/model/synthetic oracles independent of the actual hidden realization.

**Posterior sample-only subproblem:** unknown posterior probabilities p_±=1/2±sqrt(eta)/B on Theta∈{-1,1} and constant task f_Theta=B Theta, eta<=B²/16. Achieving excess MSE <=eta on both posteriors requires distinguishing the posterior-mean signs, which by Bernoulli KL/Pinsker requires Omega(B²/eta) independent posterior draws. This is a distinct lower bound for final mean estimation, NOT a joint posterior-score or model-evaluation optimum. If posterior probabilities are explicitly given, it does not apply.

**Decoder update no-go:** in a binary chain with X_1=U_1, X_j=X_{j-1}U_j for j<n, innovations fair for j<n and P(U_n=1)=3/4, initially X_n=U_n; changing only the last decoder to X_n=X_{n-1}U_n keeps every local conditional row a permutation but changes the fixed physical task X_n from innovation degree 1 to degree n. No source-local certificate update can preserve *task degree* across arbitrary decoder edits.

**Noisy-read corollary:** independent repeated categorical reports correct with probability >=1/2+kappa; repeat each physical read ceil[(1/(2kappa²))log(8B²(d+1)q/eta)] times and majority decode. With exact observer at eta/2 and a failure union bound, total expected error <=eta, under frozen hidden state and independent sensor noise.

## Audits, scope and provenance

- check_local_innovations_exact.py — separate original physical source vs latent law, 48 3-state multiparent DAGs, 576 conditional histories, exact ANOVA influences and local update locality: **14,977 Fraction assertions PASS**. Local SHA256: b2b175c861f124dc70979a6145af0e1bc3024ef62ce30349739253ac7d006a9d.
- check_lower_posterior_exact.py — separate direct physical-history exact Bayes risk, every 356 tested observation subsets across five rank/pair models, two-posterior cross-replica estimator including the zero-influence noise floor and a dependent Z3 star: **817 Fraction assertions PASS**. Local SHA256: d21c85f09eba882a63f67f7321c58a848ebcd09341d24d5697bd80ccfd6fb569.
- Paper Local_Causal_Observability.tex source SHA256 24e2dd0accccbedff779d6c716cc160a8043de42ffd57756a011bcdacee6ff74; PDF SHA256 769276256816522a7b7494ee4c28a09dff8bd81e2c4376f6277dc24b65acd28e. Full LaTeX, PDF, exact original scripts and source manifest are in the conversation's downloadable archive.
- **GitHub custody:** do not claim the full original files or PDF are GitHub-committed unless the exact bytes are uploaded here and source SHA matches; this Markdown proof passport is the repository-scoped mathematical statement.

Prior art: Pearl's Markovian invertible causal mechanisms; Evans--Kenyon--Peres--Schulman tree broadcasting (2000); Koehler--Lifshitz--Minzer--Mossel mixing-measure influences (STOC 2024); classical incremental Bayesian inference and dynamic model counting (Li--Chavira--Darwiche 2007). The exact representation equivalence is elementary/classical. The operational composition is **original within the NIGHTFALL programme**, not cleared as worldwide novelty.

**Decisive next research question:** Is there a quantitatively stable, *approximately locally invertible* latent model in which some innovation information is irretrievably lost through each physical read, with a certificate of the resulting observability/error loss that does not accumulate exponentially or linearly in total system size? This is stronger than restating a product lift.
**Current PR exact check receipts:** The two committed checker files exactly match the local input SHA256 values above; GitHub Actions run https://github.com/d3lefts/d3lefts/actions/runs/43551919499 passed both (14,977 and 817 assertions). These checks do not certify Q2 analytically or under Lean.
