# NIGHTFALL — first-chaos budget: full symmetric-law theorem

**Research date:** 2026-11-15 UTC. **Status:** complete analytical argument, *not* Lean-checked or independently human-refereed. **Originality:** not established. This is a domain-restricted result, **not** a proof of the unrestricted asymmetric-law (C_{96.57352}) coefficient.

## Precise theorem

Let (H) be a real Hilbert space, and let (Y_1,\ldots,Y_n) be independent random vectors satisfying (Y_i\overset d=-Y_i) and \(\|Y_i\|\le c\) almost surely; laws may be heterogeneous and put mass on zero. For any deterministic (h\in H), write
\[
F=\left\|h+\sum_iY_i\right\|,\quad u=\mathbb EF,\quad
W_1=\sum_i\operatorname{Var}(\mathbb E[F\mid Y_i]).
\]
Then \(W_1\le\|h\|^2+c u\), for arbitrary finite \(n\) and Hilbert dimension.

## Independent sign/amplitude representation

Independently sample \(V_i\sim Y_i\) and fair \(\varepsilon_i\in\{-1,1\}\). By marginal symmetry the family \((\varepsilon_i V_i)_i\) has precisely the original product law. Define
\[
Q_h(v,\varepsilon)=\|h+\sum_i\varepsilon_i v_i\|,\quad
R(v)=\mathbb E_\varepsilon Q_h(v,\varepsilon),\quad
t_i(v)=\mathbb E_\varepsilon[\varepsilon_iQ_h(v,\varepsilon)].
\]
Let \(g_i(v_i,\varepsilon_i)=\mathbb E[F\mid V_i=v_i,\varepsilon_i]\). The exact sign decomposition is
\[
g_i(v_i,\varepsilon_i)=q_i(v_i)+\varepsilon_i b_i(v_i),\quad
q_i(v_i)=\mathbb E_{V_{-i}}R(v),\quad
b_i(v_i)=\mathbb E_{V_{-i}}t_i(v).
\]
Since \(g_i(V_i,\varepsilon_i)\) is a function only of \(\varepsilon_iV_i\), the exact first-level energy equals
\[
W_1=\sum_i\operatorname{Var}_{V_i}(q_i(V_i))
 +\sum_i\mathbb E_{V_i}b_i(V_i)^2.
\]
No extra conditional-information relaxation is being charged.

## Sign part: \(\sum_i\mathbb E b_i^2\le\|h\|^2\)

For every fixed \(v\), \(Q_0(v,\varepsilon)=\|\sum_i\varepsilon_i v_i\|\) is invariant under simultaneous sign reversal; hence \(\mathbb E_\varepsilon\varepsilon_iQ_0=0\). Bessel orthogonality of the degree-one sign functions, followed by the reverse triangle inequality, yields
\[
\sum_it_i(v)^2
 =\sum_i(\mathbb E_\varepsilon\varepsilon_i[Q_h-Q_0])^2
 \le\mathbb E_\varepsilon(Q_h-Q_0)^2
 \le\|h\|^2.
\]
Apply conditional Jensen for \(b_i=\mathbb E_{V_{-i}}t_i\) and average over \(V\).

## Amplitude part: \(\sum_i\operatorname{Var}(q_i)\le c u\)

The (q_i-\mathbb ER\) form the first Hoeffding projections of \(R(V)\) on independent coordinates. Orthogonality gives \(\sum_i\operatorname{Var}(q_i)\le\operatorname{Var}(R)\).

For fixed \(v\), let \(R_{-i}(v_{-i})=\mathbb E_\varepsilon\|h+\sum_{j\ne i}\varepsilon_jv_j\|\) and \(\Delta_i(v)=R(v)-R_{-i}(v_{-i})\). Jensen and the triangle inequality give \(0\le\Delta_i\le\|v_i\|\le c\).

**Pointwise deletion mass:** \(\sum_i\Delta_i(v)\le R(v)\). Proof: for each sign vector put \(X=h+\sum_i\varepsilon_iv_i\) and choose a supporting unit-ball vector \(s(X)\) such that \(\langle s(X),X\rangle=\|X\|\) (choose (s(0)=0)). The norm subgradient inequality gives
\[
\|X\|-\|X-\varepsilon_iv_i\|
 \le\langle s(X),\varepsilon_iv_i\rangle.
\]
Averaging and summing gives \(\sum_i\Delta_i\le R-\langle \mathbb E_\varepsilon s(X),h\rangle\). The map \(h\mapsto R(v;h)\) is even and convex, and the averaged supporting vector is a subgradient; hence \(\langle\mathbb E s(X),h\rangle\ge R(v;h)-R(v;0)\ge0\). Thus \(\sum_i\Delta_i\le R\).

The Efron–Stein inequality and deletion surrogates (which depend only on \(V_{-i}\)) give
\[
\operatorname{Var}(R)
\le\sum_i\mathbb E[(R-\mathbb E[R\mid V_{-i}])^2]
\le\sum_i\mathbb E(R-R_{-i})^2
=\sum_i\mathbb E\Delta_i^2
\le c\,\mathbb E\sum_i\Delta_i
\le c\,\mathbb ER=c u.
\]
Adding sign and amplitude parts proves the theorem.

## Sharpness and boundary

For \(n=1\), \(h=0\), \(P(Y=0)=1-p\) and \(P(Y=\pm c)=p/2\), one has \(W_1=c^2p(1-p)\), \(cu=c^2p\). The coefficient of \(cu\) cannot be uniformly lowered below one as \(p\downarrow0\) even for symmetric laws.

**Asymmetric-law gap:** The step \(R(v)\ge R_{-i}(v_{-i})\) holds because of *conditional fair-sign symmetry*. For an arbitrary observed centered but asymmetric \(Y_i\), the corresponding pointwise deletion gain can have either sign. Arbitrary-law transfer requires a different operator or a quantitative repair; do not present this proof as the requested universal first-level budget.

## Independent bounded check

Run `python3 research/nightfall/2026-11-quadratic-law-free-audit/check_symmetric_first_chaos_exact.py`. Exact `fractions.Fraction` enumeration tests 25,305 scalar heterogeneous product instances with \(n\le3\), independent three-point symmetric marginals including zero mass, and rational shifts. Expected SHA-256 over the full ordered receipt stream:
`03240bfab53d9853b2a50da36187da2fcc19dbf458a7bef3e3bd375310b8d8e0`.
The finite checker is corroboration **not** an all-n theorem certificate. No Lean receipt exists for this theorem yet.

## External antecedents to compare

- Efron–Stein (1981), orthogonal product/ANOVA projections.
- Latała–Oleszkiewicz (1994), sharp symmetric Rademacher \(L_1/L_2\) inequality; see [IMRN 2020 symmetric-vector summary](https://doi.org/10.1093/imrn/rny249).
- Convex self-bounding and coordinate deletion variance methods.
- The repository's exact one-increment Lean theorem PR #571; symmetric *all-length* extension here has a separate proof scope.

**Next task:** derive a law-level asymmetric replacement for the pointwise sign-deletion mass inequality, or construct a counterexample to the full claimed \(W_1\le\|h\|^2+cu\), then compile the proven subcase and the unrestricted bridge with exact pinned source/axiom receipts.