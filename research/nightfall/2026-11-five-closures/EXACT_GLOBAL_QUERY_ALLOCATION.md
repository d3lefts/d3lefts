# Exact global nonadaptive allocation for nested-address systems

**Checkpoint 2026-11-11. Research lead Devin J. Wright.** Elementary theorem and exact finite audit, **not** originality-cleared or externally refereed. Restricted to the stated nested-address construction, not a universal decision-tree lower/upper bound.

For m>=2 and s>=0 let one replica be the sign selected by s independent uniform m-ary address symbols from K=m^s independent fair-sign leaves. A fixed set of c whole-coordinate queries explains optimally a variance of

    g(c)=0                              for c=0,
        m^(c-1-2s)                    for 1<=c<=s+1,
        (c-s)/K                       for s+1<=c<=L=s+K.

The function saturates at 1 for c>=L. This exact single-replica result is proved separately in [the detailed addendum](EXACT_BUDGET_AND_GENERAL_LP_20261111.md).

## Theorem: concentration is exactly optimal

For each c=1,...,L put delta(c)=g(c)-g(c-1). These increments are **nondecreasing**.

Proof: delta(1)=m^(-2s). For 2<=c<=s+1,

    delta(c)=(m-1)m^(c-2-2s),

which is nondecreasing and delta(2)>=(delta(1)). At c=s+2, delta(c)=1/K; compare with delta(s+1)=(m-1)/(mK), so it does not decrease. All later increments until L equal 1/K. Thus g is discretely convex on {0,...,L}.

By transferring one query from the less-filled of any two replicas to the more-filled whenever both are nonempty and neither is full, sum g(c_j) cannot decrease. Repeating produces an extreme allocation with as many replicas as possible filled to L, at most one partially filled, and the rest empty. (Ties are allowed.)

Now take r outputs, k replicas per output, each scaled by 1/(k sqrt(r)), as in the prior paper. Set n=rk and cap the total nonadaptive query budget Q by nL. Write

    Q'=min(Q,nL), a=floor(Q'/L), b=Q' mod L.

The **exact globally optimal nonadaptive conditional-mean Bayes risk** over *all fixed whole-coordinate query sets of total size at most Q* is

    R*_Q = 1/k - (a + g(b))/(r k²).

The optimal set queries every address and leaf coordinate in each of a replicas, selects a fixed g(b)-optimal set in one more replica if b>0, and reads nothing else. The conditional table result and independence give the additive explained variance, so the convexity argument proves optimality globally. QED.

## Implications and limits

- The exact risk curve has an address-acquisition threshold at s+1 queries per replica and a saturation threshold L=s+m^s. The fact that a first query can be weak or useless does not justify spreading queries across replicas.
- The \`Omega(r m^s/eta)\` lower-bound family is a consequence for k≈1/(2 eta), not a claim of any universal nonadaptive theorem.
- This proof assumes each leaf is a fair sign, address symbols are independent uniform m-ary values, replicas are independent, and queries are **nonadaptive**. Weighted addresses, dependent inputs, and adaptive query allocation have different optimization problems.
- Independent standard-library exact checker tests discrete convexity and 1,945 dynamic-programming global budget optima. Finite testing is not the proof and does not establish historical originality.

Run: \`python3 -I research/nightfall/2026-11-five-closures/checks/check_global_fixed_allocation.py\`.
