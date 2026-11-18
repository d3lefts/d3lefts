# Poly-d exponent-two (fair cube): dyadic two-replica quadratic proxy, v0.1

2026-11-18. **Status: author-side analytic reduction plus an exact counterexample to a stronger intermediate inequality; not a proof of exponent two, not Lean-checked or independently refereed.** Research direction NIGHTFALL / Devin J. Wright; AI-assisted mathematical derivation. No priority claim.

## Objective and checked external reference

Target: for every n,d>=1 and real degree<=d function f on independent fair signs, with centered essential radius B=(max f-min f)/2, variance V and genuine fair resampling influence M=max_i sum_{S containing i} fhat(S)^2, prove V^2 <= C d^beta B^2 M with polynomial d and alpha=2. In particular beta<=6 would strengthen the variance exponent of Turturean (arXiv:2611.09773, section 9.5), whose theorem has alpha=5/2, beta=6. Defant--Mastylo--Perez (Math. Ann. 2019; cited in Turturean section 1.4) already established alpha=2 with d^4 exp(4d). This note claims no novel fixed-d exponent-two result. Consult merged flagship PR #805 and cubic draft #807. This is **the uniform-cube branch, not the arbitrary-product Q3 branch**.

## Exact construction

Let f be a Walsh polynomial of degree<=d and let h=f-c, where c is the midpoint of its range, so |h|<=B. For d>=2 let m=ceil(log2 d). Independently sample K uniformly from {1,...,m}; put t=2^(-K). Sample X uniformly on {-1,1}^n, and independently flip every site of X with probability t to obtain Y. (This is exactly a *fair original-law refresh* of probability 2t, not an arbitrary biased auxiliary source.) For selector sigma in {-1,1}^n independently uniform, set W_i(sigma)=X_i if sigma_i=+1 and Y_i if sigma_i=-1. Define g_{X,Y}(sigma)=h(W(sigma)) and Q_{X,Y}=Pi_{sigma,levels 1 and 2}g_{X,Y}. All Q are fair-cube quadratic polynomials in selector sigma.

For a Walsh support S of size s>=1, write

w_s(t)=s t (1-t)^(s-1) + binom(s,2) t^2(1-t)^(s-2), with the second term zero for s=1;

v_s(t)=t (1-t)^(s-1) + (s-1)t^2(1-t)^(s-2), with the second term zero for s=1.

Set U=E_{K,X,Y} Var_sigma(Q), J_i=E_{K,X,Y} Inf_i^sigma(Q), and A=esssup_{K,X,Y,sigma}|Q|.

**Proposition A (author-side derivation, exact spectral identities).**

(1) U=sum_{nonempty S} fhat(S)^2 E_K[w_|S|(t)].

(2) J_i=sum_{S containing i} fhat(S)^2 E_K[v_|S|(t)].

(3) V/(6m) <= U <= V, J_i <= (1/m) Inf_i(f), and A <= d(d+2) B/2.

Proof of (1),(2): If D={i:X_i != Y_i}, then W_i(sigma)=X_i sigma_i on D and X_i otherwise. Thus each chi_S(W(sigma)) equals chi_S(X)chi_{S intersect D}(sigma). When averaging over uniform X, distinct S Fourier cross terms vanish. |S intersect D| is Binomial(s,t), giving w_s and v_s exactly. The identity concerns genuine source-coupled replicas; no artificial independent site coefficients.

For (3), for each 1<=s<=d select k=max(1,ceil(log2 s))<=m, so st is in [1/2,1] and (1-t)^(s-1)>1/3 (for s=1 this is 1). Hence w_s(t)>=1/6, and the uniform mixture supplies at least 1/(6m). For each i, v_s(t)<=t by the event interpretation: i lies in D and |S intersect D|<=2. Since sum_{k=1}^m 2^(-k)<1, J_i <= Inf_i(f)/m. For amplitude: for fixed sigma, P(rho)=T_rho g(sigma) is a polynomial in rho of degree<=d, bounded by B on [-1,1]. The trigonometric polynomial P(cos theta) has sup<=B, hence classical trig Bernstein at theta=pi/2 gives |P'(0)|<=dB and |P''(0)|<=d^2 B. Since Q=P'(0)+P''(0)/2 at sigma, A<=d(d+2)B/2. All inequalities are exact, with no n in the bound.

## Conditional exponent-two reduction, one remaining gate

**Proposition B (conditional, NOT a theorem about all f).** If a universal constant C exists such that **every source-coupled dyadic Q from this construction** satisfies

    (DYADIC-ANNEALED-Q2-d): U^2 <= C*d*A^2*max_i J_i,

then the full degree-d uniform-cube polynomial exponent-two bound follows:

    V^2 <= 36*C*d^6*B^2*M   (d>=2).

Indeed V<=6mU and max J_i<=M/m imply
V^2<=36 C m d A^2 M<=9 C m d^3(d+2)^2 B^2 M<=36 C d^6 B^2 M, using m<=d, d+2<=2d. Degree 1 already has V^2<=B^2 M exactly. Thus the **unproved** problem is a *source-coupled annealed quadratic energy inequality with linear degree loss*, not a naive unconditional annealed Q2 inequality.

## Exact falsifier for the too-strong degree-free gate

**Proposition C (analytic counterexample, exact).** For every d>=2, take h(x)=prod_{i=1}^d x_i (pure parity, B=V=M=1), with a single refresh-disagreement probability t=1/d rather than the dyadic mixture. For any (X,Y), g(sigma) is exactly a character on D={i:X_i!=Y_i}; Q is that character iff |D|=1 or 2, and is 0 otherwise. Hence A=1 and

    U=(3/2)(1-1/d)^(d-1),
    J_i=(2/d)(1-1/d)^(d-1),
    U^2/(A^2 max_i J_i)=(9d/8)(1-1/d)^(d-1) ~ 9d/(8e).

So no universal dimension-free C can satisfy U^2<=C*A^2*Jmax, **even for authentic source-coupled families**. On the actual dyadic mixture, J_i<=2U/d and U>=1/(6m), so U^2/Jmax >= d/(12m), which diverges at least as d/log d. The linear-degree gate in Proposition B is therefore appropriately relaxed; the present counterexample does NOT refute it or the underlying UE2 conjectures. This also does not refute the specialized cubic source-coupled gate in PR #803, where d is fixed to 3.

## Reproducible exact finite certificate and limitations

Run `python3 -I research/nightfall/flagship-influence/check_poly_d_dyadic_proxy.py`. The checker constructs selector tables independently from the original Walsh support-binomial formulas and compares exact Fraction U/J for d=1,3,5 on fair cubes n<=5, including pure parity, and checks rational-safe amplitude and energy bounds. It also computes the parity no-go ratio exactly through d=128. A green arithmetic replay verifies finite fixtures, not Proposition A for every n or the missing Proposition B. No independent proof auditor or Lean formalization has been run.

**Adversarial next experiment (pre-registered):** attempt to refute the linear-degree gate by evaluating exact U^2/(d A^2 Jmax) on coherent address/leaf selectors, tribes, pure parity, Chebyshev, and dense overlapping random Walsh supports, first n<=7. If a counterexample grows with n or d, abandon the gate and seek a variance-conditioned or block-congestion replacement; if finite tests pass, prove the source-coupled routing inequality before any formalization. Stop after these five adversarial families without a structural mechanism. No publish/merge until independent math audit and prior-art screening.

**Discovery graph:** fair Walsh representation -> random paired flip/selector -> dyadic spectral filter -> finite spectral certificate -> parity no-go for degree-free annealing -> open linear-d source-coupled quadratic gate -> potential transfer to N-UE2(6).
