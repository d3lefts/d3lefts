# NIGHTFALL — Five-priority mathematical closure audit v1.1 (11 November 2026 UTC)

**Research lead:** Devin J. Wright / NIGHTFALL Constellation. **Status:** written derived theorems, exact finite audits, and open conjecture gates. **Not** an independent human referee report, global originality clearance, or end-to-end Lean certificate. This record is designed for adversarial review; do not merge it as a declaration that all five open problems are solved.

## Frozen external source and scope

- Finite-product scalar influence (5/2,6): compiled Lean declaration \`Nightfall.ProductSpace.Influence.product_influence\`, PR #317, pinned head \`e67990dfc252b6ef9446c7b7c1a9ebf06e5c58eb\`, Actions \`42929857470\`. It imports David Turturean's method (arXiv:2611.09773). Its finite-to-arbitrary-measurable-product extension is **not** Lean-compiled.
- Scalar quadratic product bound: source v5 manuscript, \`V(g)<=D B sqrt(M)\` for \`deg(g)<=2\`, \`D=16(1+sqrt(3))\`. This is a written proof candidate; no independent external referee.
- Finite-cube \`bs<=deg^2\`: Tal (existing result), and classical Markov derivative. The exact recovery argument uses these as imported external theorems.
- Adjacent: OSSS (2005), Soltani Moakhar et al., ICML 2026. Historical priority remains unverified.

## P1 — Rank-linear disjoint-output subclass (proved conditional on scalar observer)

Let \`F=(f_1(X_{J_1}),...,f_r(X_{J_r}))\` with pairwise disjoint independent input groups, Hoeffding degrees ≤d, and norm ≤B. Define \`b_j=ess sup |f_j|\` and \`c_*=sqrt(3/12500)/pi^6\`.

The scalar posterior-potential argument, conditional on the scalar all-product influence inequality, gives risk ≤η_j in at most \`1+(5d^7/(3c_*))b_j^3 η_j^-3/2\` queries. Independence of groups implies \`sum_j b_j^2<=B^2\` (simultaneously near-attain each essential supremum). Choose \`η_j=η b_j^(6/5)/S\`, \`S=sum b_j^(6/5)\`. Hölder yields \`S^(5/2)<=r(sum b_j^2)^(3/2)<=r B^3\`. Hence

    N <= r + (5d^7/(3c_* η^(3/2))) S^(5/2)
      <= r + 5d^7 B^3 r/(3c_* η^(3/2)).

For a covariance-diagonal output tail, error beyond top r components adds ≤τ_r. No such rank-linear claim is made for overlapping output groups.

## P2 — Cubic top-cover interpolation, with a decisive fractional-LP barrier

Let f have degree ≤3, |f|≤B, M=sup_i I_i(f), and C be a t-coordinate set hitting every nonzero order-three Hoeffding support. Put g=E_C f. Then g has degree ≤2, |g|≤B, and I_i(g)≤I_i(f). By Hoeffding orthogonality,

    V(f)-V(g) = sum_{S:S∩C≠∅} ||f_S||_2^2
              ≤ sum_{i∈C} I_i(f) ≤ t M,     and V(f)-V(g)≤B².

Thus, conditional on the quadratic theorem,

    V(f) ≤ D B sqrt(M)+min(tM,B²) ≤ (D+sqrt(t))B sqrt(M).

The same D+sqrt(t) coefficient holds for independent sums of covered blocks: the block essential oscillation widths sum to ≤2B, and the block variances add.

**New exact obstruction to a proposed shortcut.** Define \`τ*_I\` as the fractional minimum-weight transversal of the *top cubic support hypergraph* with vertex costs I_i, equivalently its LP packing dual. For a homogeneous order-three Hoeffding observable \`f=Ef+sum_|S|=3 f_S\`, put \`v_S=||f_S||_2²\`. Then \`I_i=sum_{S∋i}v_S\`. The primal cover \`x_i=1/3\` has objective \`(1/3)sum_i I_i=sum_S v_S=V(f)\`; the dual assignment \`y_S=v_S\` meets every vertex capacity exactly and has objective V(f). Therefore

    τ*_I(f) = V(f)   [exactly, every product law].

Any conjectured universal \`τ*_I≤C B sqrt(M)\` is **equivalent to the original cubic exponent-two inequality** for homogeneous cubics; the fractional LP alone does not simplify dense overlaps. The separate exact 9-sign cubic counterexample has integer-cover \`τ_I=1060,B=61,M=201\`, so \`τ_I≤B sqrt(M)\` is false. It does NOT refute fractional cover or the cubic influence conjecture.

## P3 — Almost-sure infinitary finite-palette recovery (analytic candidate)

For a finite real palette of size q and gaps Δ>0, range R, and Hoeffding degree ≤d, the proposed **almost-sure** (not pointwise or efficient) result is

    D_mu(f) ≤ d floor[d² min{(q-1)², 2R/Δ}].

Proof checklist: (a) every real product-measurable function has an a.s. representative using a countable set of coordinates, including after completion; (b) finite conditioning sections have degree ≤d for almost every prefix, by L²-cylinder approximation/subsequence; (c) choose the first maximal-cardinality nonzero Hoeffding projection from countably many finite supports using its measurable squared energy; (d) for a maximal-order nonzero S, D_S g=Π_S g in L² and the S-section is nonconstant for a.e. complementary input, yielding **positive-measure** resampling sensitivity at the original input; (e) for every countably enumerable finite sequence of blocks and prefixes, intersect the corresponding Fubini full-measure events; (f) the independent replacement hybrid cube has degree ≤d for almost every joint replacement (L² limit of finite cylinders). At its base, m switch coordinates all change the output by at least Δ. Split positive and negative changes; apply the Markov endpoint derivative inequality to each associated polynomial on [0,1], obtaining mΔ≤2d²R. Alternatively, interpolate the q-valued cube to a Boolean polynomial of degree ≤(q-1)d and use Tal's bs≤deg², obtaining m≤d²(q-1)². Hence the selected disjoint blocks terminate in the stated number of rounds, each reading ≤d inputs.

This is a **written analytic proof candidate** with explicit null-set protocol, not specialist-refereed, not an end-to-end Lean theorem. Countable output palettes cannot replace finite palettes even at arbitrarily low Shannon entropy (independent rare Bernoulli base-3 encoding).

## P4 — Exact fixed-set nested-address risk and matching lower construction

For r outputs, k independent replicas per output, d−1 independent uniform m-ary addresses per replica, and m^(d−1) independent fair-sign leaves per replica, define

    F_j=(1/(k sqrt(r))) sum_{t=1}^k Z_{jt,(A_{jt,1},...,A_{jt,d-1})}.

Then ||F||≤1, degree ≤d, covariance I_r/(rk), and V(F)=1/k. For a fixed set of input coordinates reading h_jt address symbols and q_jt leaves within replica (j,t), an exact direct conditional expectation calculation gives

    MSE = 1/k - (1/(r k²)) sum_jt q_jt / m^(2(d-1)-h_jt).

If all addresses are given for free, the risk is no less than \`1/k - q/(rk² m^(d-1))\` for any q fixed queried leaves (thus also for q total fixed queries). Taking k=floor(1/(2η)), 0<η≤1/4, proves q≥r m^(d−1)/(8η) for risk≤η. Adaptive evaluation reads each address tuple and selected leaf, using ≤drk=O(dr/η) queries. This lower bound does **not** verify the separate categorical manuscript's universal upper bound.

## P5 — Reproducibility and priority

The local source-complete v1.1 ZIP includes the six-page LaTeX/PDF, exact checkers, two independent mathematical audit implementations, proof-passport JSON, review scope, outputs, and checked SHA-256 manifest. The independent checker passed: P1 1,253 rank profiles; P2 900 primal-dual energy tests; P3 13,954 finite input paths; P4 88 exhaustive Bayes-risk observation patterns. These are finite falsification and arithmetic checks, not global theorem proof.

The **unpacked v6 working PDF** does not match its on-disk SHA manifest; the PDF in the previously supplied v6 source ZIP **does** match its archived manifest. Distinguish those byte versions; do not silently overwrite original provenance. Separate local ZIP SHA-256: \`0d9f2b9bc6c4183394173987c30b225ca1c4675f7307efa05c563e531a096bd4\`.

The source-complete binary PDF and ZIP are provided as conversation artifacts, **not stored in this PR**. This PR stores self-contained scoped proof arguments and CI-ready exact code. Full original publication/source deposition is a separate authorized step.

**Gates still OPEN:** independent external proof review of scalar arbitrary-product and Hilbert transfer, quadratic general-product proof, infinitary common-good-set construction, general cubic exponent-two inequality, categorical matching upper bound, full dated novelty and end-to-end Lean. No new original-finding or competitive-record promotion.
