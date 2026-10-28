# NIGHTFALL — A continuous-shift, reciprocal-semigroup positivity theorem for the genuine Riemann Xi function
**26 October 2026.** New mathematical strengthening relative to the supplied NIGHTFALL rank-22 certificate. Exact arithmetic independently checked in two implementations. The theorem relies on published rigorous low-zero enclosures and finite-height RH verification; no external referee or formalization, and **worldwide novelty not established**.

## Abstract
Three previously conflated notions are strictly separated: (1) theta-moment Hankel positivity at every order and every forward heat time; (2) reciprocal-zero Hankel positivity for verified finite orders and shifts; (3) zero-hyperbolicity of the de Bruijn–Newman heat deformation. At the actual unsmoothed Xi boundary we extend the rank-22 reciprocal-zero positivity from *integer shifts at least 1* to **every real exponent at least 199/200** and to a continuous, independent **positive reciprocal-semigroup** parameter. The theorem has an explicit >1/100 reference Gram lower bound uniform in these parameters. We also deduce an Xi-specific, nonlinear strict cubic inequality in its first four theta moments. This latter inequality is false for general positive even Fourier kernels and thus captures additional information beyond theta-side positive-measure positivity.

## Definitions and theorem
Let `Xi(z)=xi(1/2+iz)`, and index nontrivial zeta zeros `rho=beta+i gamma` with `gamma>0`, including multiplicity. Define

`r_rho=(gamma - i(beta-1/2))^{-2}`.

Every such r has strictly positive real part and |r|<=gamma^{-2}; zero symmetry makes conjugate pairs. For real alpha>=199/200 use the **principal complex power** `r^alpha=exp(alpha Log r)`. For `tau>=0`, put

`P_{alpha,tau}(h)=sum_{gamma>0} r_rho^alpha exp(tau r_rho) h(r_rho)^2`, for real polynomials h of degree<=21.

This sum is absolutely convergent and real. Select 22 critical-line zeros with heights in the rational intervals in `certificate.json` (ten certified intervals at heights 14–50 and twelve existence-certified bands above 1000). Put `x_j=gamma_j^{-2}>0`.

**THEOREM (Continuous-shift positive reciprocal semigroup).** For all real `alpha>=199/200`, `tau>=0`, and nonzero real h of degree <=21,

`P_{alpha,tau}(h) > (1/100) sum_{j=1}^{22} x_j^alpha exp(tau x_j) h(x_j)^2 >0`.

Equivalently, the genuine Xi zero-power matrix

`R_22(alpha,tau)=[ sum_{gamma>0} r_rho^(alpha+i+j) exp(tau r_rho) ]_(0<=i,j<22)`

is strictly positive definite, and satisfies the corresponding strict Loewner lower bound by the 22-node positive Gram matrix. In fact the exact checker proves a global tail/reference ratio less than **0.980413072259**, leaving a stronger numerical bound than 1/100.

Furthermore, for every nonnegative integer m,

`d^m/dtau^m R_22(alpha,tau)=R_22(alpha+m,tau) >> 0`.

Thus this is an **all-derivative, all-positive-reciprocal-semigroup-time, continuous-shift positivity theorem**, at the fixed genuine Xi boundary. It is **not** a claim of Xi forward-heat reciprocal positivity for arbitrary positive times; the time tau here multiplies reciprocals of the **unsmoothed** zeros, whereas forward Xi heat deforms the zeros themselves.

## Proof and exact certificate
**1. Verified real anchors.** Platt–Trudgian (2021) prove that all zeta zeros of ordinate gamma<=T=3*10^12 are on the critical line. The ten low rational brackets in the accompanying prior rank-22 certificate are corroborated by NumberDB/Arb certified zeta-zero enclosures. Existence of at least one zero in the other twelve intervals follows rigorously from Ramaré–Saouter (2003), Lemma 1:

`|N(t)-F(t)-7/8| <= 0.67 log(t/(2pi))`, t>=1000,

`F(t)=t/(2pi) log(t/(2pi e))`.

Hence `|N(t)-F(t)| <= (67/100)log t+1`. For t>=1000, using 2pi<7, log 7<2, and 1.03 log 1.03-0.03>0,

`F(1.03t)-F(t) > (3t/700)(log t-2)`.

Subtracting both counting errors, and using `log 1.03 < 1/10` and `log t > 6`, gives

`N(1.03t)-N(t) > 12t/700-1011/100 >0`.

If an endpoint is a zero, the strict lower bound is >7 at t=1000 and increasing, so at least one zero is in the open interval. This establishes the existence of the twelve anchors. Their heights are <T, and thus real in the Xi coordinate.

**2. Global high-tail domination.** The same 2003 zero-count estimate yields `N(t)<t log t/5` for all t>=T. The tail of reciprocal powers satisfies, for alpha>1/2,

`S_alpha=sum_(gamma>T) |r_rho|^alpha <= sum gamma^(-2alpha) <= (2alpha/5) T^(1-2alpha) (log T/(2alpha-1)+1/(2alpha-1)^2)`.

For alpha>=1, use `S_alpha <= E epsilon^(alpha-1)`, with `epsilon=T^-2` and `E=62/(5T)` as in the earlier rank-22 theorem. Note that all anchors satisfy x_j>epsilon.

**3. Polynomial interpolation.** Let each anchor interval be `(a_j,b_j)`, with `ell_j=b_j^-2 < x_j < u_j=a_j^-2`. Denote

`C_j=prod_(i != j) (u_i+epsilon)/d_ij`, where `d_ij=ell_min(i,j)-u_max(i,j)>0`.

Lagrange interpolation gives `|h(z)| <= sum_j C_j |h(x_j)|` for `|z|<=epsilon`. Apply weighted Cauchy–Schwarz with weights `x_j^alpha exp(tau x_j)`. For each high zero `|r|<=epsilon`, `|exp(tau r)|<=exp(tau epsilon)`; since x_j>epsilon, its tail/reference ratio is at most

`S_alpha * sum_j C_j^2 /ell_j^alpha`.

This bound is uniform in tau>=0.

**4. Exact bound for all fractional exponents.** For alpha in `[a,1]`, `a=199/200`, the right side of the previous display decreases as alpha increases: the factors `T^(1-2alpha)/ell_j^alpha` decrease because `T^2 ell_j>1`; and the prefactor `2alpha*(log T/(2alpha-1)+1/(2alpha-1)^2)` decreases for alpha>1/2. Thus it is enough to bound alpha=a.

We make every transcendental comparison one-sided using rational certificates:

- `log T<29` (positive Taylor truncation for exp 29),
- `T^(1/100)<4/3` (exact integer inequality `T*3^100<4^100`),
- `ell_j^(1/200)<=q_j`, with q_j the rational 200th-root upper enclosures in `certificate.json`, each checked by integer powers.

It follows that

`S_alpha sum_j C_j²/ell_j^alpha < eta_a`,

where the **exact rational number**

`eta_a = (2/(5T))*(4/3)*(29/(2a-1)+1/(2a-1)^2) * sum_j (C_j²/ell_j)q_j`

satisfies `eta_a<99/100`. The *display-only decimal* is `0.980413072258813`.

For alpha>=1, the existing exact-rational certificate gives

`E sum_j C_j²/ell_j = 0.827967775222555... < 9/10`.

Combining these cases bounds every high-zero contribution in absolute value by `(99/100)` times the strictly positive 22-anchor reference quadratic form. Every zero with gamma<=T contributes nonnegatively; the 22 anchors give the displayed strict >1/100 lower bound. QED.

**5. Loewner derivative hierarchy.** Absolute convergence permits termwise differentiation in tau, and differentiation introduces one additional r power. As alpha+m>=a for all m>=0, the same strict inequality applies. QED.

## Exact nonlinear bridge to the theta moments
Let the *genuine* theta moments be `m_k=int_R u^(2k) Phi(u) du`, with positive even kernel Phi and `Xi(z)=int Phi(u)e^(izu)du`. Set `f(w)=Xi(sqrt w)`. Then

`f(w)=sum_(n>=0) (-1)^n m_n w^n/(2n)!`, and `-f'(w)/f(w)=sum_(n>=1) p_n w^(n-1)`.

Newton identities, independently checked symbolically, give

`p_1=m_1/(2m_0)`,

`p_2=m_1²/(4m_0²)-m_2/(12m_0)`,

`p_3=m_1³/(8m_0³)-m_1 m_2/(16m_0²)+m_3/(240m_0)`.

The rank-two principal minor, a genuine consequence of the stronger rank-22 theorem, therefore gives the **strict Xi-specific cubic theta inequality**

`3m_0 m_1 m_3 -10 m_0 m_2² +15 m_1² m_2 >0`.

Indeed this left side equals `1440 m_0³ (p_1p_3-p_2²)`. This is not implied by theta-side Gram positivity for arbitrary positive even measures: the positive even measure `3/4 delta_0 +1/8 delta_1+1/8 delta_{-1}` has `m_0=1`, `m_1=m_2=m_3=1/4` and produces `-13/64<0` (exact). Thus this is a nontrivial arithmetic-specific inequality, not a generic positive-measure form. Direct high-precision theta integration corroborates the positive value `0.00000034485366310187562...` for the true Xi kernel, but the proof rests on the 22-node certificate.

## The three-regime atlas and the boundary obstruction
1. **Theta Hankel**: `[m_{i+j}(t)]` is positive definite for every n>=1, forward Xi heat time t>=0, by positive theta measure. This is classical positive-measure theory.
2. **Unsmoothed zero-reciprocal Hankel**: at t=0, every rank <=22, every **real exponent alpha>=199/200**, and every reciprocal-semigroup tau>=0 satisfy the exact strict reference bound above. The previously reported 12.363-trillion *eventual-exponent* rank is a separate regime whose underlying full proof is not part of this package and is not promoted here.
3. **Forward Xi heat zero-reciprocal Hankel**: the de Bruijn–Newman parameter is negative for positive forward heat times; Rodgers–Tao's Lambda>=0 implies nonreal zeros at every positive forward-heat time, so at least one finite-rank Stieltjes reciprocal-zero positivity test must fail there. This is a known-theorem consequence, not a contradictory statement about the new reciprocal-semigroup tau.

The zero-reciprocal and theta moment systems are linked exactly **nonlinearly** by Newton identities; there is no generic positivity-preserving linear map between them. The new strict cubic inequality exhibits a concrete positive arithmetic sign that is not implied merely by the theta measure.

## Checks, provenance and novelty status
Run `python build_certificate.py` once to regenerate rational node data, then `python check_A.py` and `python check_B.py`. Both exact verifiers use different rational representations (Python Fraction versus SymPy Rational), independently reconstruct the Lagrange products and verify the 200th-root bounds. Numeric decimals are presentation only. See `CHECKS.txt` and `SHA256SUMS`.

External rigorous inputs: Ramaré–Saouter 2003, Lemma 1 (https://ramare-olivier.github.io/Maths/gap.pdf); Platt–Trudgian 2021 (https://doi.org/10.1112/blms.12460); certified low-zero enclosures in NumberDB (https://numberdb.org/Zeros_of_the_Riemann_zeta_function?entry=1). De Bruijn–Newman and Rodgers–Tao are used solely for context and the separate negative-time obstruction. Sra 2026 PF10 studies a different reciprocal transform (1/Xi). These sources were checked on 26 October 2026. No matching **all-real-alpha rank-22 with a positive reciprocal-semigroup inequality** was located by targeted searches, but an exhaustive prior-art survey or external mathematical review was not performed; **do not claim established world originality**.

## Handoff
**New internally exact-checked quantitative result:** rank 22 for real alpha>=199/200 and tau>=0 with strict universal >1/100 reference Gram margin. **Further Xi-specific consequence:** strict cubic theta inequality above. **Operator:** rationally enclosed Lagrange anchors + fractional zero tail + positive reciprocal-semigroup exponential comparison; **failure mode:** this does not establish global all-rank positivity, and fractional alpha near 0.994 is not covered by this particular certificate. **Next decisive experiment:** optimize the degree-21 interpolation norm / anchor geometry to push the fractional exponent lower, or use a different interpolation family to raise rank. **Novelty label:** candidate new contribution; exact internal certificate, external priority unverified.