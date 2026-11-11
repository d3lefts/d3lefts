# NIGHTFALL — Two exact information-geometry refinements (11 November 2026)

**Research lead:** Devin J. Wright. **Certification:** elementary finite theorems with complete written proofs and separately implemented exact arithmetic checks. **Not** a novelty-cleared or externally refereed claim; no Lean declaration for the combined statements. The unrestricted cubic exponent-two influence law and the infinite-product exact-recovery measure theory remain open.

## Theorem A: exact fixed-budget phase transition for a nested-address replica

Let A_1,...,A_s be independent uniform symbols in [m], m>=2, and let (Z_u)_{u in [m]^s} be independent fair signs, independent of the addresses. Write f=Z_A and K=m^s. A *fixed*, nonadaptive query set reveals h of the s address coordinates and q of the K leaf bits. Its conditional-mean predictor has **exact explained variance**

    G(h,q)=Var(E[f|queries]) = q / m^(2s-h),   0<=h<=s, 0<=q<=K,

and its Bayes risk is 1-G(h,q). The value is independent of which h address positions and which q leaves are selected.

Let c>=0 be the total number of available whole-coordinate queries. The optimal explained variance over *every fixed set with at most c queries* is

    g_m,s(c) =
       0                              if c=0;
       m^(c-1-2s)                    if 1<=c<=s+1;
       min{1, (c-s)/m^s}             if c>=s+1.

Thus the regimes join exactly at c=s+1 with gain 1/m^s: query gain increases geometrically while paying for address information, then increases linearly with leaf count after all addresses have been read. This is a finite, complete result, not a general fixed-query theorem for arbitrary low-degree functions.

**Proof.** Given the observed addresses A_H, the posterior A is uniform over the m^(s-h) compatible leaves. The conditional mean is the sum of observed leaf bits in that fiber divided by m^(s-h). Conditional on A_H, the squared mean has expectation equal to the number of observed leaves in that fiber divided by m^(2(s-h)). A random A_H makes each fixed observed leaf compatible with probability m^-h, giving G(h,q)=q/m^(2s-h). For cost c, choose q=min{K,c-h}. If q<K and q>=2, replacing one leaf query by one additional address query changes the numerator from q to q-1 while multiplying the denominator advantage by m: the gain ratio is m(q-1)/q>=1, with equality only m=q=2. When q=K, increasing h also cannot decrease the gain (until the leaf cap ceases to bind). Hence for 1<=c<=s+1 an optimum reads h=c-1 addresses and one leaf; for c>=s+1 an optimum reads all s addresses and min{K,c-s} leaves. This yields the formula. QED.

**All replicas, exact nonadaptive optimum.** In the NIGHTFALL construction with r output components and k independent replicas per component, each contributes variance 1/(rk²) times one unscaled f. If c_(j,t) queries are allocated to replica (j,t), the optimal risk at fixed total budget Q is exactly

    R*_Q = 1/k - 1/(r k²) max_{sum_(j,t)c_(j,t)<=Q} sum_(j,t) g_m,s(c_(j,t)).

A direct dynamic program computes this global construction-specific optimum. It is *not* a universal complexity bound. In particular it refines the already proved Omega(r m^s / eta) fixed-set lower construction by identifying the finite-budget transition.

## Theorem B: general-degree fractional-transversal sandwich

Let f have Hoeffding decomposition f=Ef+sum_(nonempty S, |S|<=d) f_S on a finite independent product. Let v_S=E[f_S²]>=0, V=sum_S v_S, I_i=sum_(S∋i)v_S and T=sum_i I_i=sum_S |S|v_S.

Define the support hypergraph of its nonzero f_S and the **influence-weighted fractional hitting-set LP**

    tau*_I = min sum_i I_i x_i subject to x_i>=0 and sum_(i∈S)x_i>=1 for each active S.

Then

    V <= tau*_I <= T <= d V.

If f is homogeneous of any positive interaction order k (only |S|=k occur), the stronger exact identity holds:

    tau*_I = V.

**Proof.** The packing dual maximizes sum_S y_S subject to y_S>=0 and sum_(S∋i)y_S<=I_i. Choose y_S=v_S. Each capacity saturates, so weak duality gives tau*_I>=sum_S v_S=V. The primal x_i=1 on every active vertex is feasible and costs sum_i I_i=T<=dV. If all supports have size k, primal x_i=1/k is feasible and costs T/k=V. Together with the dual this proves equality. QED.

**Strict mixed-degree example.** Let the active supports be {1}, {2}, {1,2}, each with energy 1. Then V=3, I_1=I_2=2 and the singleton constraints force x_1,x_2>=1, so tau*_I=4>V. Thus the homogeneous equality does not extend blindly to mixed degree.

**Structural consequence (no-go, not a cubic proof).** For *any fixed d*, tau*_I and V differ by at most d. Hence a bound tau*_I<=C_d B sqrt(max I_i) is equivalent up to a degree factor to the original variance-squared influence target. The weighted fractional-transversal program alone does not eliminate the difficult analytic step—even beyond cubics. This generalizes the pure-cubic tau*_I=V observation in the five-closures v1.1 audit.

## Reproduction and boundary

- Run \`python3 -I research/nightfall/2026-11-five-closures/checks/check_exact_budget_phase.py\` for 645 exact all-budget optimizations plus 88 independent conditional-table enumeration patterns.
- Run \`python3 -I research/nightfall/2026-11-five-closures/checks/check_fractional_lp_general.py\` for 1,050 rational nonhomogeneous energy-table certificates, 1,050 homogeneous identities, and the strict mixed example.
- Neither finite checker establishes originality or replaces the algebraic proofs above.
- These are elementary deductions from classical ANOVA and finite conditional expectations; external prior-art comparisons remain open.
