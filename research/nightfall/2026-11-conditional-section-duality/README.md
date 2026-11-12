# Conditional-section duality: when low-degree observation needs feedback

NIGHTFALL Constellation | 12 November 2026 | research working proof v0.1.

**Status:** self-contained finite-product analytic derivation, plus finite falsification. NOT end-to-end Lean-checked, non-author refereed, globally priority-cleared, or approved as an Original Finding. The mechanism overlaps with classical low-degree influence and junta literature; all references in AUDIT_AND_PRIOR_ART.md must be consulted before public originality claims.

## 1. Model and representation

Let X_1,...,X_n be independent variables on arbitrary probability spaces, with any laws and alphabets. Let f be real, |f|<=B a.s., B>0, with Hoeffding/Efron--Stein interaction degree <=d, d>=1. Denote the coordinate-averaging operator by P_i f=E[f|X_{-i}] and D_i=Id-P_i. Set

* s_i(X_{-i})=sqrt(Var_{X_i}(f|X_{-i})) = ||D_i f(X_{-i},.)||_{L2(mu_i)};
* I_i=E s_i^2;
* beta(f)=inf_{i:I_i>0} (E s_i)/sqrt(I_i), with beta in (0,1] for a nonconstant finite-coordinate f.

This beta is a function-dependent conditional-section L1/L2 ratio, not a minimum atom-mass assumption. It tests whether coordinate sensitivity concentrates on rare configurations of other coordinates.

## 2. Degree-d L1 section budget (analytic lemma)

For every such f on any finite independent product,

    SUM_i E s_i <= 2 d^2 B.                                           (A)

Proof: For each full-support finite state x, choose a maximizing replacement in every coordinate. Independently switch from x_i to that replacement with probability t. The resulting mean q_x(t) is a polynomial of degree <=d because each ANOVA component depends on <=d coordinates, and |q_x(t)|<=B for 0<=t<=1. Markov's endpoint derivative bound gives SUM_i [max_z f(x_{-i},z)-f(x)]<=2d^2B. Repeat with minimizing replacements: SUM_i [f(x)-min_z f(x_{-i},z)]<=2d^2B. Summing yields total coordinate range SUM_i R_i(x_{-i})<=4d^2B. Popoviciu's inequality says s_i<=R_i/2. Average over x to get (A).

For general measurable alphabets on a finite product, approximate f in L2 by bounded finite-rectangular conditional expectations. The projections commute with coordinate averages and preserve degree and bound B. The conditional section L2 norms converge in L1 by the reverse triangle inequality. Thus the finite-alphabet proof passes to arbitrary measurable factors without measurable maxima. No result for arbitrary uncountable input-index sets is asserted by this note.

## 3. Fixed-coordinate observation theorem

For beta(f)>0 and integer q>=1 there exists a FIXED set S of at most q coordinates such that its conditional-mean Bayes risk obeys

    R(S) = E (f-E[f|X_S])^2 <= d^4 B^2/(beta(f)^2 q).                (B)

Proof: Sort a_i=sqrt(I_i) decreasing. From (A), L=SUM_i a_i <=2d^2B/beta. Choose the first q coordinates. Writing f as an orthogonal sum of Hoeffding components f_T with energies w_T=||f_T||_2^2, the *exact* unobserved risk is SUM_{T not subset S} w_T, bounded above by SUM_{i not in S} I_i = SUM_{i>q} a_i^2. Since a_{q+1}=t, the first q terms contribute at least qt to L, while the tail sum of squares is at most t(L-qt) <= L^2/(4q). Substitute L. If q>=n, observe every coordinate for zero risk. This is an existence/query-count result; no efficient coordinate selection or computational runtime is claimed.

Consequences:
* Quadratic arbitrary-law: R(S) <=16B^2/(beta^2 q).
* Fair independent signs and degree <=2: the coordinate derivative is an affine Rademacher sum; sharp real Khintchine gives E|D_i f| >= sqrt(I_i)/sqrt(2), hence beta>=1/sqrt(2) and R(S)<=32B^2/q.
* Fair independent signs and degree <=d: degree-(d-1) hypercontractivity (L4 <= 3^((d-1)/2)L2) and interpolation imply beta>=3^(-(d-1)). Therefore R(S)<=d^4 9^(d-1)B^2/q. This is exponential in degree and is NOT a substitute for polynomial-in-degree results under different hypotheses.

## 4. Address-block lower bound and necessity of beta

Take b>=1 independent address blocks. Each has K_j uniform on [k], k>=2, and k independent fair signs Z_{j,ell}; all blocks independent. Define

    f_(b,k) = (1/b) SUM_(j=1)^b Z_(j,K_j).

Then |f|<=1, Hoeffding degree exactly two, V=Var(f)=1/b. For a leaf, its conditional section standard deviation is (1/b)1[K_j=ell], so I_leaf=1/(kb^2), E s_leaf=1/(kb), and leaf ratio 1/sqrt(k). For an address coordinate, s_gate^2=(1/b^2)(1-Zbar_j^2); since sqrt(v)>=v on [0,1], its ratio is at least sqrt(1-1/k)>=1/sqrt(k). Thus beta(f)=1/sqrt(k) exactly.

For a fixed query set, in block j let t_j be the number of observed signs. Conditional-mean variance explained by block j equals t_j/(b^2 k) if the address is queried, and t_j/(b^2 k^2) otherwise. In particular any fixed set of q whole-coordinate observations has squared risk

    R_nonadapt(q) >= 1/b - q/(b^2 k).                               (C)

At target eta=1/(2b), fixed observation requires q>=bk/2=beta^(-2)/(4eta). An adaptive observer recovers f exactly by reading each address and then its selected sign: 2b queries. The example certifies worst-case joint necessity of the beta^(-2)*eta^(-1) scaling in (B), up to constants, without claiming pointwise sharpness for every f.

## 5. Connections to existing NIGHTFALL work (not duplicate the proofs)

* [Scalar all-law quadratic influence](../2026-11-quadratic-law-free-audit/QUADRATIC_LAW_FREE_ANALYTIC_AUDIT.md): V <=15(1+sqrt(3))B sqrt(max I_i). Uses matching/parity coupling, greedy ownership, fourth moments; full end-to-end Lean proof not yet established. Its adaptive observation guarantee works without beta.
* [Rank-optimal Hilbert quadratic adaptive observation](../2026-11-quadratic-rank-optimal/UNIVERSAL_THEOREM.md): O(rB^2/eta) adaptive coordinate count, covariance tail and matching rank lower bound, analytically composed but not fully kernel-compiled.
* [Quadratic-backdoor and approximate cubic transfer](../2026-11-quadratic-backdoor-transfer/QUADRATIC_BACKDOOR_TRANSFER_v1.md): a small cubic hitting core reduces to quadratic prediction. This new beta-based fixed-query theorem can be applied to the residual function only if its *conditional* beta is appropriately bounded; no automatic posterior inheritance is asserted.
* [Cubic generalized-selector and spectral frontier](../2026-11-leaf-spectral-transfer/LEAF_SPECTRAL_REDUCTION.md): missing general arbitrary-law selector estimate and potentially unstable spectral tails. New beta is scalar and initial-distribution-specific; it does not prove unrestricted cubic exponent two.
* [Dense Hadamard benchmark](../2026-11-heterogeneous-graph-overlap/HADAMARD_DENSE_NO_GO.md): support-graph coloring is too crude even in degree two. Signed cancellation/operator geometry matter.
* [Fair-sign and mixed-law operator comparisons](../2026-11-fair-sign-quadratic/PROOF_NOTE.md): pre-existing restricted Littlewood/Khintchine mechanisms; this note does not claim invention of those tools.

Interpretation: the upper bound (B) is a criterion for making prediction NONADAPTIVE. Its failure for address systems does not invalidate the earlier universal ADAPTIVE quadratic theorem. Neither theorem implies an exact safety certificate from finite behavioral observations.

## 6. Reproducibility and review gates

Run from repository root:

    python3 research/nightfall/2026-11-conditional-section-duality/check_conditional_sections.py

A separate independently implemented checker passed 60 heterogeneous and 120 fair-sign finite products, then all 352 coordinate subsets over three address-block models, with exact rational Bayes-risk/ANOVA calculations and high-precision decimal square roots. These checks are falsification screens, not universal mathematical certificates. The initial 12 November proof bundle, including PDF, TeX, and its own distinct exact checker, has SHA-256 digest 02236687cece107747b84112d6bc4fc30c174381d1262f9e8b7997cb9effc379. The original bundle is a conversation artifact, not silently represented as a committed repository release.

**Remaining gates:** non-author proof review; source-level prior-art/reduction audit, especially classical FHKL and September 2026 completely bounded root-influence/junta results; full Lean composition; test operator-valued beta against overlapping cubic sections; no promotional status or publication without human authorization.
