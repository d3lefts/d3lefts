# NIGHTFALL / UE2 — fixed-block mean-field non-counterexample theorem

**Checkpoint:** 2026-11-17 US Eastern. **Status:** author-side analytic theorem, independently checkable exact-rational two-block models; **not** a universal exponent-two proof, not a Lean theorem, not independently reviewed, and no global priority claim. Classical input: univariate trigonometric Bernstein inequality.

## Theorem: all fixed-block polynomial mean-field constructions obey the extremal UE2 bound asymptotically

Fix integers `r >= 1`, `d >= 1`, a real polynomial `P(t_1,...,t_r)` of total degree `<= d` that is nonconstant on `[-1,1]^r`, and interior means `m_b in (-1,1)`. For each large N let `n_b(N)/N -> w_b > 0` and let the `n_b(N)` signs in block b be iid with mean `m_b`, all coordinates mutually independent. Set

`T_b = (1/n_b) sum_{j=1}^{n_b} X_{b,j}`, `f_N = P(T_1,...,T_r)`.

Then `f_N` has Efron–Stein degree at most d. Its centered essential radius `B_N = (max f_N - min f_N)/2` tends to `B = (max_{[-1,1]^r} P - min_{[-1,1]^r} P)/2 > 0`. Let `V_N = Var(f_N)` and `M_N = max_{b,j} E Var(f_N | all other coordinates)`. **Then**

`limsup_{N->infty} V_N^2/(B_N^2 M_N) <= d^2`.

If some partial derivative of P at m is nonzero, the limit **exists** and equals

```
L(P,m,w) = [sum_b a_b^2/w_b]^2 / [B^2 max_b a_b^2/w_b^2],
a_b = sqrt(1-m_b^2)*abs((partial_b P)(m)).
```

This is bounded above by `(sum_b a_b)^2/B^2 <= d^2`. The first inequality can be tight when the relative block sizes are proportional to `a_b`. If all partials vanish at m, the ratio tends to 0 (for a nonconstant P).

No positive atom floor beyond fixed interior means is required; biases and block proportions can differ. The number r, degree d and polynomial P must be **fixed** as N increases. This does not handle r growing with N, non-polynomial dependence, input-dependent partitions, rare-mass sequences tending to zero, or arbitrary interlocking ANOVA components. For the global UE2 conjecture, the theorem rules out **every fixed-dimensional smooth polynomial empirical-mean test**, not general degree-d functions.

## Proof (independent parts)

1. **Law and finite degree.** Every monomial of total degree <=d in the empirical means expands into a multilinear function on individual signs of degree <=d, because `X_i^2=1`. Full-support Bernoulli measures preserve this canonical degree bound. The grids of possible `(T_b)` become dense in the cube, giving `B_N -> B`.

2. **First-order source-law asymptotics.** Write `sigma_b^2=1-m_b^2`. For nonzero gradient at m, bounded-polynomial Taylor expansion and independent bounded-coordinate moments give
   `N V_N -> sum_b sigma_b^2 (partial_b P(m))^2/w_b`.
   For any coordinate i in block b, the genuine resampling influence is `(sigma_b^2/4) E[(P(T^{i,+})-P(T^{i,-}))^2]`. Its finite difference is `(2/n_b) partial_b P(m) + o_{L²}(1/n_b)` and hence
   `N² I_{b,i}(f_N) -> sigma_b²(partial_b P(m))²/w_b²`.
   Symmetry makes all within-block influences equal. The limit for `V_N²/M_N` follows.

3. **Finite-dimensional angular Bernstein.** Put `m_b = cos(theta_b)`, `theta_b in (0,pi)` and choose signs `s_b=sign(partial_b P(m))` (arbitrary at zero derivative). Define
   `q(t)=P(cos(theta_1-s_1*t),...,cos(theta_r-s_r*t))`.
   Expanding each monomial into products of cosines shows `q` is a real trigonometric polynomial of frequency at most d. Since `B` is the centered range radius of P over the cube, `||q-c||_infty <= B` for the midpoint c of that range. Classical sharp trigonometric Bernstein gives `|q'(0)| <= d B`. The chain rule yields
   `q'(0)=sum_b sqrt(1-m_b²)*abs(partial_b P(m)) = sum_b a_b`.
   Finally `sum_b a_b²/w_b <= (max_b a_b/w_b)*sum_b a_b`, giving `L <= d²`. **Bernstein is prior art, not a new standalone theorem.**

4. **Stationary means.** If all derivatives vanish, let `q>=2` be the first nonzero homogeneous Taylor order of P at m (q<=d). The multivariate central limit theorem plus bounded moments gives `N^q V_N -> Var(P_q(Z))>0`, where Z is a nondegenerate diagonal Gaussian and P_q is the first nonzero Taylor form. The coordinate finite difference similarly yields `N^(q+1) I_{b,i} -> sigma_b²/w_b² E[(partial_b P_q(Z))²]` for any b with nonzero derivative polynomial. At least one such b exists. Consequently `V_N²/M_N = Theta(N^{-(q-1)}) ->0`. For q=1, Step 2 applies.

## Nontrivial two-block quadratic saturator

Take two independent blocks of n even biased signs each, with means `m_A=+1/sqrt(2)`, `m_C=-1/sqrt(2)` (genuinely different biases). Let `T_A` and `T_C` be their empirical means and

`f_n = (T_A² - T_C²)/2`.

It has algebraic/canonical degree exactly 2, actual centered radius `B=1/2` (both even-n block grids contain 0 and +/-1), and original law moments

```
V_n = (n-1)*(n-1/2)/(2*n^3),
M_n = (n-1)/(4*n^3),
V_n²/(B² M_n) = 4*(n-1)*(n-1/2)²/n³ -> 4.
```

This exhibits **multiblock, opposite-bias, non-one-statistic** saturation of the sharp degree-2 coefficient 1 conjecture. It is **not** a counterexample; it reinforces that mixed bias alone does not break the extremal form. The same moment formulas apply to equal-sign biases because P is even in each block.

For rational mean `m=7/10` in each block, the exact asymptotic ratio is `16*m²*(1-m²) = 2499/625 = 3.9984`; independent Fraction enumeration (two binomial blocks and full 2^(2n) states for n<=4) validates all finite formulas. The asymptotic saturation at irrational means is mathematical, not based on rounding.

## Source, checker, claims and next test

- Exact standard-library checker: `research/nightfall/flagship-influence/check_fixed_block_meanfield_no_go.py`, run `python3 -I research/nightfall/flagship-influence/check_fixed_block_meanfield_no_go.py`.
- No numerical search or finite checker certifies the generic asymptotic theorem. The written proof is an author-side argument with classical Bernstein and CLT inputs; independent review of the stationary-gradient q>=2 case is still required.
- **Transfer:** This excludes *all fixed-r polynomial empirical-mean constructions* as sources of asymptotic violations. Do not repeat random mixed-bias mean-field screens merely by adding finitely many blocks. A decisive falsifier now needs growing-dimensional blocks, source-coupled selectors/cancellation, rare-atom scaling, or a genuinely non-mean-field ANOVA geometry.
- **Stop rule:** If any example with `limsup R > d²` is found under the stated fixed-r/positive-variance hypotheses, rerun the independently coded source-influence checker, identify failure in finite-difference or angular step, and retract. Never confuse this restricted theorem with N-UE2(2,1), N-UE2(2), N-UE2(6), or unrestricted cubic exponent two.

**Discovery graph:** conjecture -> fixed-r polynomial block means -> Gaussian first chaos -> coordinate-resampling delta method -> ℓ¹ weighted gradient -> torus-direction Bernstein -> asymptotic no-go -> growing-dimensional selector frontier.
