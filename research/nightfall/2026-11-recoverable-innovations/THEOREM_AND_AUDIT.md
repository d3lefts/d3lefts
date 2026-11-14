# Recoverable Innovations: sharp observation of correlated trees

**NIGHTFALL / 13 November 2026 / Research-directed by Devin J. Wright; AI-assisted analytical work**

**Certification:** complete author-side finite mathematical proofs, independent exact rational code, and a known failed-audit correction. This result is original *within NIGHTFALL's research programme*; global historical novelty and non-author mathematical review are NOT established. It is not a new Lean kernel-certified theorem. The unconditional sharp theorem does not use our still-uncompiled heterogeneous Q2 inequality.

## The representation transition

Let T=(V,E) be a finite rooted tree and G a finite (possibly noncommutative) group. Let Z be an arbitrary root state, independent of mutually independent edge increments U_e with known finite mass tables (zero masses allowed). Generate X_root=Z and X_child=X_parent * U_edge. Original vertex states are generally dependent, but every innovation is recoverable by reading its physical endpoints:

    U_(u,v) = X_u^(-1) X_v.

For every relative-pair observable h(X_u^(-1) X_v), the original correlated two-site interaction becomes a function of only the independent increments on path P_T(u,v), with the correct ordered product of inverses and forward increments. Path length D replaces vertex interaction degree as the useful representation parameter. No correlated-law ANOVA is presumed.

## Theorem A: unconditional sharp innovation cost

For any source with f(X)=c+sum_{e in E} h_e(U_e), |f|<=B on its physical support, and any 1<=q<=|E|, the **static, nonadaptive** policy taking the q edge terms with largest v_e=Var(h_e(U_e)) produces a conditional-mean predictor after at most 2q actual node-state reads, with EXACT residual risk sum_{e not selected} v_e and UNIVERSAL guarantee

    E[(f - fhat)^2] <= B^2 / (4q).

**Full proof.** Define sigma_e=sqrt(v_e), range_e=max_support h_e-min_support h_e. Since all edge innovations vary independently on their Cartesian product support, range(f)=sum_e range_e<=2B. Popoviciu gives sigma_e<=range_e/2, so sum sigma_e<=B. Sort sigma_1>=...>=sigma_m. If q<m let t=sigma_(q+1). The tail risk obeys

    sum_{i>q} sigma_i^2 <= t sum_{i>q} sigma_i
                           <= t (B-q t)
                           <= B^2/(4q).

All queries are fixed before seeing X. Observing edge e requires both endpoint states; repeated endpoints are read once. If q=m, risk is zero. This proves the theorem without an Aaronson-Ambainis influence premise.

## Theorem B: exact physical lower, including genuine dependence

Let G=Z/3Z, with one root Z uniform, and m=2q leaves. Each U_e is independent uniform on {0,1} (probability zero at 2), so X_leaf=Z+U_e (mod 3). Let h_e(0)=B/m, h_e(1)=-B/m, h_e(2)=0; f=sum h_e(X_leaf-Z). The source is dependent because each leaf is Haar-uniform yet P(X_i=X_j)=1/2 (not 1/3).

Even if an observer receives the root Z for FREE, each leaf reading reveals exactly one independent innovation; after r distinct leaves the conditional risk is

    (m-r) B^2/m^2.

Any adaptive randomized observer using at most q leaf reads (or expected <=q reads) therefore has risk >=B^2/(4q). Querying q leaves attains equality. The factor 1/4 is exactly sharp for the SAME physical leaf-read interface. A full-support perturbed model with pi(0)=pi(1)=(1-eps)/2 and pi(2)=eps approaches equality.

## Exact physical reconstruction frontier, and its limit

For a fixed set S of read state vertices, restrict the prediction contract to conditioning on edge increments whose BOTH endpoints lie in S. Its exact risk is

    R(S) = sum_e v_e - sum_{e={u,v} subset S} v_e.

The optimal budget-r restricted risk is

    R_r^recon = sum_e v_e - max_{|S|<=r} sum_{e={u,v} subset S} v_e.

A standard weighted tree-knapsack dynamic program with node-selected bit, vertex budget, and child-state max-plus convolution computes this frontier in O(|V| r^2) arithmetic and O(|V| r) scalar DP states (plus traceback); this is checked against exhaustive vertex subsets.

**Do not confuse this with unrestricted physical Bayes risk.** On a three-site binary path whose independent edge signs have mean 1/2, put f=(U1+U2)/2. Reading nonadjacent endpoints 0 and 2 reveals path product U1U2, reconstructing no single edge. The restricted risk remains 3/8, but unrestricted Bayes risk improves to 9/40. Our independent exact checker confirms this counterexample. Thus the DP is exact only for the DECLARED reconstruction-only observation operator.

## Theorem E: exact unrestricted nonadaptive physical Bayes optimum on an Ising path

The original three-site nonadjacent-observation counterexample is now resolved **on the binary zero-field path subclass** by an exact global physical-site optimization theorem. For any fixed observed-site set S={i1<...<ir}, full Bayes risk equals V - sum_l W(i_l,i_(l+1)), with V=sum_e a_e²(1-t_e²) and each interval gain W(i,j) computed from two scalar recurrences for interval parity mean and additive-target covariance. The strongest nonadaptive read set of size at most r is found by a longest-weight increasing vertex path dynamic program in O(r n²) arithmetic, including all degenerate edge transitions. This is *unrestricted Bayes optimality for fixed site sets*, unlike the earlier reconstruction-only tree knapsack. It makes no adaptive-optimality assertion. [Read the full theorem and proof](EXACT_PHYSICAL_PATH_FRONTIER_20261113.md) and run check_path_full.py. The independently audited source bundle records 90 exact rational models, 5,900 original physical posterior comparisons and 517 optimized budgets; the separately normalized CI checker replays 40 cases.

## General degree-D lift and exact posterior source algebra

For the more general target

    f(X) = c + sum_{j=1}^M h_j(X_{u_j}^(-1) X_{v_j}),

assume every path P(u_j,v_j) has at most D edges, |f|<=B, and source law as declared above. In independent edge innovations, the target has canonical product Hoeffding decomposition

    f(U) = sum_{A subset E, |A|<=D} F_A(U_A).

Its components are generated by exact finite Möbius inversion of the supplied local term tables. For any selected edge e with observed value u, the posterior canonical components update by the IDENTICAL source operator

    F_A^new(g_A) = F_A(g_A) + F_{A union {e}}(g_A,u).

The expression is valid including zero-mass symbols by interpreting conditional averages as product integrations. Posterior risk and source-influence scores are exact:

    V = sum_{A != empty} ||F_A||_2^2,
    I_e = sum_{A contains e} ||F_A||_2^2.

Only touched source tables are updated; building all initial tables takes at most O(M 3^D |G|^D poly(D)) arithmetic and stores O(M(1+|G|)^D) entries, not exponential in ambient tree size.

**Corollary conditional on the historical pinned product theorem.** NIGHTFALL's finite heterogeneous product theorem (Lean 4.33, PR #317 plus heterogeneous alphabet bridge #325) inherits the Turturean/Aaronson–Ambainis influence bound at c*=sqrt(3/12500)/pi^6:

    max_e I_e >= c* Var(f)^(5/2)/(B^3 D^6).

This remains true after every observed U_e. The exact total influence drift identity and D-bounded ANOVA give a deterministic adaptive policy with

    Q <= min(|E|,ceil(4 D^7 B^3/(c* eta^(3/2))))

edge innovation reveals, at most 2Q original physical site reads, and expected MSE <=eta. Proof: potential p_t=E sum I_e lies in [v_t,Dv_t] and decreases by at least a v_t^(5/2), a=c*/(B^3D^6); a dyadic level sum is <4D/(a eta^(3/2)). The composition itself is NOT newly Lean compiled.

The author's uncompiled degree-two Q2 premise, if independently established, would conditionally give q<=ceil(4 C2 B^2/eta) for D<=2; it is not needed for any unconditional theorem here.

## Strict improvement over a separator proof strategy

For a zero-field Ising path of N spins and edge correlation t=3/4, edge innovations are independent with mean t while the global fair-spin density ratio is 7^(N-1). Splitting the path into components of size<=k requires >=(N-k)/(k+1) deleted vertices. But every bounded nearest-neighbor relative-edge energy is covered by the unconditional B^2/(4q) policy, with <=2q node reads, independent of N and t. This bypasses the CUTSET proof method for this specialized source and target, NOT a generic arbitrary-correlation theorem.

## Reproduction and known adverse audit

The full source-and-audit bundle is distributed as a conversation artifact with raw SHA-256 manifest. Exact independent test reports:

- 175 randomly generated finite models, 3,243 posteriors, 6,478 source-influence checks, and 3,243 total-influence drift checks against direct brute original-spin enumeration;
- 500 additive models, 2,406 q-budget comparisons, 98 correlated-star lower cases, including zero-mass edge tables;
- 700 independent random weighted trees and 4,478 physical-budget DP comparisons against all vertex subsets;
- 211,400 ordered-path checks in the noncommutative symmetric group S_3.

**Failure preserved:** an initial independent auditor mistakenly equated E Var(f | G_-e), the heat-bath influence, with Var(E[f|G_e]), the immediate observation gain. The test exposed a counterexample on trial 3. The checker was corrected to compute conditional variance from original spin configurations, after which all recorded tests passed. This is a substantive operator distinction, not an editorial correction.

## Prior-art and novelty gate

Tree edge-noise parametrization is classical: Evans–Kenyon–Peres–Schulman, *Broadcasting on Trees and the Ising Model* (2000). Product ANOVA, additive variance selection, Popoviciu and tree DP are classical. Turturean, *A proof of the Aaronson–Ambainis conjecture* (2026), underlies the imported general D inequality. Huffstutler–Miloschewsky–Podder's completion/adversary proof (2026) concerns the broader uniform-cube AA task but does not provide this same physical read contract without additional argument.

The sharp innovation-plus-physical-observation package is an **original internal construction, fully proved on paper**, not a certified worldwide first or refereed contribution. It does not cover cycles with dependent edge constraints, noisy state reads, arbitrary magnetic fields, missing model provenance, or unbounded intrinsic path degree. An adversarial historical subsumption review and independent proof reconstruction are required before submission.

**Next structural transition:** extend the now-proved **nonadaptive binary-path full Bayes optimum** to arbitrary tree topologies or adaptive site choice, while preserving same-oracle semantics; establish whether the exact interval formula is subsumed by classical HMM/Markov bridge sensor-selection results. Preserve the three-vertex counterexample as the control fixture.
