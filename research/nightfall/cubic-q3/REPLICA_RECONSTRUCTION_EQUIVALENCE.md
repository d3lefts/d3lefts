# Q3 two-replica reconstruction: a bidirectional cubic reduction

**Checkpoint, 2026-11-17.** This is an author-side analytic theorem, supported by finite exact-rational checks. It is **not** an unrestricted cubic exponent-two proof, a Lean certificate, an external peer review, or a novelty/priority determination. This note is stacked on the independently provisional two-replica reduction in PR #799.

## Setup and claim

Let \(\mu=\bigotimes_{i=1}^n\mu_i\) be an arbitrary **finite-coordinate** product probability law; factors need not be binary or atomically bounded. Let \(f\in L^\infty(\mu)\) have canonical Efron--Stein degree at most three. Set \(B=\|f\|_\infty\), \(V=\operatorname{Var}_\mu(f)\), \(M=\max_i I_i^\mu(f)\).

For two independent draws \(X,Z\sim\mu\), define a fair sign-cube restriction \(F_{X,Z}(\varepsilon)=f((X_i\text{ if }\varepsilon_i=+1\text{ else }Z_i)_i)\), and its fair Walsh projection \(Q_{X,Z}=\Pi_{\le2}^{\varepsilon}F_{X,Z}\). Define

\[
 A=\mathop{\rm ess\,sup}_{X,Z,\varepsilon}|Q_{X,Z}(\varepsilon)|,\quad
 U=\mathbb E_{X,Z}\operatorname{Var}_\varepsilon(Q_{X,Z}),\quad
 J=\max_i\mathbb E_{X,Z} I_i^\varepsilon(Q_{X,Z}).
\]

Then, with every influence normalized as \(\mathbb E[(f-\mathbb E_i f)^2]\),

\[
 \boxed{\tfrac12 V\le U\le\tfrac34 V,\quad
 \tfrac38 M\le J\le\tfrac12 M,\quad
 \tfrac7{39}B\le A\le5B.}
\]

The **new reverse amplitude bound** \(B\le(39/7)A\) admits an explicit four-noise-scale reconstruction, described below.

Consequently, for this **source-consistent image family** (not arbitrary random quadratic families), these two uniform assertions are quantitatively equivalent:

- (Q3) \(V^2\le C_3 B^2M\) for all degree-\(\le3\) sources;
- (coupled Q2) \(U^2\le K A^2J\) for all associated replica-lift quadratics.

Specifically, **coupled Q2 with \(K\) implies Q3 with \(C_3=50K\)**, while **Q3 with \(C_3\) implies coupled Q2 with \(K=(4563/98)C_3\)**. These are nonoptimal transfers, not numerical values of either presently unknown universal constant.

For pure degree-three canonical \(f\) (no lower levels, including the mean), \(U=\tfrac34V\), \(J=\tfrac38M\), and \(B\le\tfrac87 A\). Here \(K=(96/49)C_{3,\mathrm{pure}}\) suffices in the Q3-to-coupled direction; conversely \(C_{3,\mathrm{pure}}=(50/3)K\) suffices. This tighter reverse estimate comes from the scalar identity \(R=\tfrac78f\).

## Exact reconstruction mechanism (independent of Q3)

Define the **source return** of the fair quadratic:
\[
 R(x)=\mathbb E_{Z\sim\mu} Q_{x,Z}(+\mathbf1).
\]
For any source ANOVA expansion \(f=f_0+f_1+f_2+f_3\), the highest Walsh term in \(F_{x,Z}\) has \(Z\)-expectation exactly \(2^{-3}f_3(x)\). Hence
\[
 \boxed{R=f-\tfrac18 f_3=f_0+f_1+f_2+\tfrac78f_3.}
\]
This also gives \(\|R\|_\infty\le A\).

For \(0\le t\le1\), let \(T_t\) be **original-product** independent-coordinate refresh noise: keep each \(x_i\) with probability \(t\), otherwise resample from \(\mu_i\). It is an \(L^\infty\) contraction and \(T_tR=R_0+tR_1+t^2R_2+t^3R_3\). Exact Lagrange interpolation at \(0,1/4,3/4,1\) gives
\[
 R_3=-\tfrac{16}{3}T_0R+\tfrac{32}{3}T_{1/4}R
      -\tfrac{32}{3}T_{3/4}R+\tfrac{16}{3}T_1R .
\]
Since \(f=R+\tfrac17R_3\), the **source reconstruction certificate** is
\[
 \boxed{f=\tfrac1{21}\big(37T_1R-32T_{3/4}R+32T_{1/4}R-16T_0R\big).}
\]
The absolute coefficient sum is \(117/21=39/7\); by positivity and contraction of every \(T_t\), \(B\le39A/7\) with no bias, alphabet-size, or dimension floor.

The remaining bounds are the direct two-replica binomial Walsh energy identities from the predecessor note: \(U=\frac12E_1+\frac34(E_2+E_3)\) and \(\mathbb E I_i^\varepsilon(Q)=\frac12 I_i^\mu(f)-\frac18 E_{3,i}\), where \(E_{3,i}=\sum_{|S|=3,i\in S}\|f_S\|_2^2\le I_i^\mu(f)\). The fair top-degree Walsh removal gives \(A\le5B\). All statements hold up to the usual almost-everywhere representatives; the proof does **not** evaluate an \(L^2\) source on the measure-zero diagonal \((X,Z)=(x,x)\).

## Why the equivalence matters, and what remains open

The prior one-way reduction was a legitimate sufficient gate. This reconstruction proves that its *source-consistent coupled Q2 gate is neither stronger nor weaker in existence* than the sought Q3 theorem, up to explicit factors. Thus it is mathematically sound to concentrate on proving or disproving coupled Q2 **on replica-lift images only**. It is *not* sound to replace it by ordinary fiberwise quadratic Q2, or to exchange an averaged maximum with the maximum of averages; PR #799 contains explicit counterexamples to both shortcuts.

This is a representation/operator result, **not a closure of unrestricted exponent two**. All-degree and infinite-coordinate analogues would require their own boundedness/density and source-coupling audits. The two proof obligations still missing are (1) a genuinely universal coupled inequality for the image family, or a counterexample to it; and (2) formal Lean and independent expert review of the reconstruction itself.

## Exact audit

Run \`python3 research/nightfall/cubic-q3/check_replica_reconstruction.py\`. It enumerates the full two-replica fair-Walsh projection, derives \(R\) independently from source values, applies the four original-law noise maps, and checks the identity, energy sandwich, and amplitude inequality exactly for both skewed binary and heterogeneous binary/ternary products. These finite examples are regression checks only; the displayed ANOVA/Markov algebra is the general argument.

**Discovery graph:** Q3 → two-replica fair-Walsh image → source-return Markov operator → 4-node cubic interpolation → exact inverse → two-way quantitative reduction → unproved coupled-Q2 gate. Prior-art priority and full source Lean certification remain pending.
