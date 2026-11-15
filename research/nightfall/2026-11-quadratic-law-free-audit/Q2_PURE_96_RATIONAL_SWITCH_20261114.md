# NIGHTFALL Q2: C < 96 in the pure degree-two sector (14 Nov 2026)

**Status:** new complete **analytic** reduction to existing original-source owner and cubic theorems, plus an exact algebra certificate. No new current-head kernel receipt, no unrestricted Q2 theorem, no novelty or publication certification.

## The theorem, and its precise restriction

For a bounded real function |f| <= B of **pointwise** Hoeffding degree <= 2 on a finite independent arbitrary-alphabet original product law (heterogeneous biases, zero atoms permitted), with every canonical singleton h_i = 0 on the support, let V = Var(f) and M = max_i I_i(f) under the repository's resampling-influence normalization. Then

    V^2 <= [29 sqrt(3)/6 + 8 gamma]^2 B^2 M
         = 95.228852330715585... B^2 M
         < 96 B^2 M,

where tau = (sqrt(5)-1)/2 and gamma = sqrt((5sqrt(5)-11)/6) = 0.173368532...

This legitimately beats 99.262985 in the **pure-sector subclass**, not in full arbitrary-singleton Q2. In particular, PR #539's general shifted c/5 lemma remains unproved and its old quartic envelope is falsified. Under the still-unproved sharp original-source section budget 2(1+sqrt(2)) B, the pure-sector coefficient would be 95.06307246948477; no such assumption is needed for the 95.228852 result.

## New rational source operator: the 29B/6 section budget

Fix a configuration x in the support and coordinatewise replacements y,z in the support, and let P_y(t) be E f(x with each coordinate independently replaced by y_i with Bernoulli(t)); define P_z similarly. Pointwise degree <=2 implies P_y(t)=A+D_y t+Q_y t^2, with the **same** A=f(x) for P_z. Since every switched x is a source configuration and |f|<=B, we have |P_y(t)|,|P_z(t)|<=B for t in [0,1].

At rational t=2/5, the exact algebraic identity is

    D_y-D_z = [P_y(t)-P_z(t)]/[t(1-t)]
              - [t/(1-t)] [P_y(1)-P_z(1)].

Choose each y_i to maximize and z_i to minimize the genuine x-fixed coordinate section. D_y-D_z is the sum of its coordinate ranges. Bounding both differences by 2B gives

    sum_i range_i <= 2B (25/6 + 2/3) = 29B/3.

The weighted Popoviciu inequality for each actual p_i gives source section standard deviation <=range_i/2. Integrate over the genuine original product law to obtain

    sum_i sourceMeanSectionNorm(p,f,i) <= 29B/6.

This improves the merged source-derived 5B result; unlike the sharper 2(1+sqrt(2))B target, it uses only a rational Bernoulli selector. Requires a new source-level Lean bridge/receipt; the identity and scalar bound are checked by an exact checker.

## Golden-ratio dual: pure owner local moment

The existing source-owner construction supplies c_i>=0, sum_i c_i<=8B, e_i<=I_i<=M, V=sum_i e_i. In the zero-singleton sector, the source Hilbert owner sum has only independent centered neighbor increments. The existing certified source cubic (ActualSourceQ2625Cubic.actual_source_owned_cubic) says, with z_i=E||sum_owned Y_ij||,

    e_i^3 <= z_i^2[(c_i)^2 e_i + 3(e_i)^2].

Source conditional projection/Jensen gives z_i<=u_i, the original L1 section norm. Set t=sqrt(e_i), c=c_i, u=u_i. For t>0 obtain t^4<=u^2(3t^2+c^2).

The algebraic operator is already in Q2625Golden.homogeneous_golden_dual. Let X=sqrt(3t^2+c^2), Y=sqrt(3)t, so X>=Y>=0 and X^2-Y^2=c^2. Then

    3 gamma^2 X^2(X+Y)-Y^2(X-Y)
      = (Y-tau X)^2 (Y+tau^3 X) >=0.

Multiply by X-Y and divide by 3X^2 (positive) to get [t(X-Y)/X]^2<=gamma^2 c^2. Also u>=t^2/X. Therefore

    sqrt(e_i) <= sqrt(3) u_i + gamma c_i.

Summing e_i<=sqrt(M)sqrt(e_i) and the source budgets gives the stated 95.2288523 coefficient. For e_i=0 use 0<=sqrt(3)u_i+gamma c_i directly.

**Exact rational envelope:** sqrt(5)<161/72 (since 25921>25920) gives gamma^2<13/432<(7/40)^2. sqrt(3)<26/15. Hence
    sqrt(3)*(29/6)+8 gamma < (26/15)*(29/6)+8*(7/40)=88/9,
and (88/9)^2=7744/81<96.

## Audit and transfer

Independent-check the rational quadratic-switch identity, the existing source owned cubic and conditional Jensen, and the exact owner's 8B amplitude budget. Zero-mass alphabets require choosing y,z on the support (or proving the pointwise polynomial identity globally). Do not claim independence among different owners. Other random-source models with nonpositive *shifted third moment* also admit the golden scalar, but this file claims only canonical zero-singleton functions. The numeric inequality is not proof of the unrestricted 99.263 theorem.

**Next Lean declarations:**
1. rational t=2/5 Bernoulli quadratic switching on the genuine original-source quadratic polynomial;
2. actual_source_integrated_29_over_6_budget;
3. source-owned pure local golden site and original-source C=96 terminal, with no external moment/section premises;
4. exact-head Lean 4.36.0-rc2 compile and standard-axiom receipts, independent proof and prior-art review.

Historical antecedents: degree-2 switching/Markov methods, Popoviciu variance, Rosenthal/Hilbert fourth moments and the prior repository's golden-ratio dual. This is a new *composition and scoped endpoint candidate*, not a priority claim.
