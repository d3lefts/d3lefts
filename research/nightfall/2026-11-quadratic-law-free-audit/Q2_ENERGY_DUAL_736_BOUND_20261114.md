# Q2 energy-dual: exact candidate 736.67319775828688

**2026-11-14. Status:** exact analytic sum-of-squares proof and independent finite-product rational checks; **new coefficient NOT yet Lean-certified**. Input: PR #494 strictly certified source-only coefficient 1064.958449026294 at head c47fafe94b521fff20ec3276e59dd69d23bfb28b. Research directed by Devin J. Wright; AI-assisted proof construction.

## Target theorem, finite original source product

For the same original assumptions (finite coordinate set, common finite nonempty alphabet, coordinate-dependent nonnegative normalized marginals including zeros, Efron–Stein degree <=2, |f(x)|<=B globally), M>=0 bounding all source resampling influences:

  Var_p(f)^2 <= K B^2 M,

  K = [257/20 +(9/4)sqrt(2)+5sqrt(3)+sqrt(6)]^2
    = 102499/400 +(3513/40)sqrt(2)
      +(275/2)sqrt(3) +(241/5)sqrt(6)
    = 736.67319775828688485414...

That is 30.8261089029% below the 1064.958449 coefficient.

## Missing source bridge (indispensable)

Write a_i^2 = E_p[h_i^2], where h_i is the genuine degree-one ANOVA component, and s_i = sum over the actual greedily OWNED distinct neighbors j of E_p[h_ij^2], which equals the already certified original-source Hilbert second moment.

The actual original coordinate influence has exact degree-two decomposition

  I_i(f) = a_i^2 + sum_{j != i} E_p[h_ij^2].

Hence, because each owned neighbor is distinct and all pair energies are nonnegative,

  **a_i^2 + s_i <= I_i(f) <= M.**

This is stronger than the separately used a_i^2<=M and z_i<=sqrt(M). Existing source ANOVA, owned-neighbor moment-energy identity, and subset-nonnegativity proofs cover its ingredients, but a named Lean receipt combining them is STILL required. Never include this combined bound as an extra caller premise in the final theorem.

## Exact free-parameter site certificate

Let a,u,c,z,s,T,rho be real, beta>0, rho>=0, a>=0, c>=0, T>=0, with

  a<=u, z<=u+a, s<=z(c+rho*T), a^2+s<=T^2.

Set W=u+a, so 2a<=W, and p=(1+beta*rho)^2/(4beta), q=p+beta/2.

Then

  **a^2+s <= p*T*u + q*T*a + beta*T*c.**

Proof: for T=0 it follows from a^2+s<=0. For T>0 define x=a/T, w=W/T, d=c/T, v=(a^2+s)/T^2. Then

  0<=x<=w/2, d>=0, v<=1, v<=x^2+w(d+rho).

Note p-rho=(1-beta*rho)^2/(4beta)>=0.

* If w<=beta, x^2<=beta*x/2, w*d<=beta*d, rho<=p. Hence v<=p*w+beta*x/2+beta*d.
* If w>=beta, take the valid convex combination
    v <= (1-beta/w)*1 + (beta/w)*(x^2+w(d+rho)).
  The claimed RHS minus this expression equals
    [((1+beta*rho)*w-2beta)^2 + 2beta^2*x*(w-2x)]/(4beta*w) >=0.

The nonnegative quadratic is a full exact SOS certificate. No numerical approximation, fourth-moment change, or additional source assumption occurs.

## Source sum and chosen exact constant

Put rho=sqrt(3), beta=2/5. Then

  p=37/40+sqrt(3)/2,
  q=9/8+sqrt(3)/2.

Existing strict-certification budgets:
  sum u_i<=8B; sum a_i<=A B with A=2(1+sqrt(2));
  sum c_i<=8B; V=sum(a_i^2+s_i).

Therefore V<=[8p+Aq+8beta] B sqrt(M) with

  8p+Aq+8beta = 257/20+(9/4)sqrt(2)+5sqrt(3)+sqrt(6).

Since V,B,M>=0, square to obtain K above.

## Best parameter within this specific SOS family

  L(beta)=rho*(8+A)/2 +(8+A)/(4beta)+(14+5A/4)*beta.

  beta*=sqrt((8+A)/(56+5A))≈0.400088667385064.
  K*= [rho*(8+A)/2+sqrt((8+A)*(14+5A/4))]^2
     ≈736.673176381809.

This is only 0.00002138 below the rational beta=2/5 certificate. Preserve it as a mathematical refinement, but DO NOT waste proof effort on a sub-threshold constant gain. Target the rational certificate first.

## Independent exact audit and certification gate

SymPy algebra independently checks
  4beta(p-rho)=(1-beta*rho)^2
and
  4beta*[p*W^2-(1+beta*rho)*W*T+beta*T^2+
         (beta/2)*W*a-beta*a^2]
    = ((1+beta*rho)*W-2beta*T)^2+2beta^2*a*(W-2a).

12 independently reconstructed finite source examples checked with exact Fraction arithmetic, including zero-probability atoms: direct Efron–Stein influence equals singleton-plus-pair ANOVA energy, with owned pair energies a nonnegative subset. Finite checks are NOT a universal theorem proof.

**Strict Lean gate:** compile named source-derived joint influence cap, SOS scalar closure, and unconditional source-only terminal under Lean 4.36.0-rc2, only Classical.choice/Quot.sound/propext. An isolated scalar theorem with a supplied energy cap does not count as a source-level certificate. Novelty and independent human review unresolved. Do not merge/publish until all gates pass.
