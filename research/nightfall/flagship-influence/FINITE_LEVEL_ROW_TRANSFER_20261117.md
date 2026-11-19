# Finite-output row-to-influence transfer and a sharp single-cut information barrier

**Research checkpoint:** 2026-11-17 Eastern. Author-side derivation by the NIGHTFALL parallel audit, under Devin J. Wright's research direction. **Mathematical status:** proved conditional on the **established Boolean two-sided fractional-row theorem** (Turturean 2026, Theorem 5.4 / Section 9.5; original-product finite-alphabet bridge in merged NIGHTFALL #298/#309). Exact independent finite rational regression checks included. This does **NOT** solve the unrestricted real-valued row problem, unrestricted Q3 exponent two, or N-UE2(2,1); no new Lean certificate or publication-priority determination. Attribution: Turturean's Boolean row theorem is an imported prior result.

## 1. Fully audited old obstruction: singleton sensitivity 4, optimal full row 6

On four independent fair signs define
\[
f(a,b,c,d)=(-a+b-c-d)/2+(a+b)(c-d)/4.
\]
The earlier real-valued sharp PSI statement using singleton sensitivity \(R=\max_x\sum_i|f(x)-f(x^i)|=4\) fails: \(V=5/4\), every genuine resampling influence \(I_i=3/8\), and \(4V^2/(R^2M)=25/24>1\) (draft #808).

The **true uniform fractional-row cost**
\[
K^*(f)=\max_x\min_{r^x_i\ge0}\left\{\sum_i r_i^x:
 |f(x)-f(y)|\le\sum_{i:x_i\ne y_i}r_i^x\quad\forall y\right\}
\]
is exactly **six**, not four. At \(x=(-1,+1,-1,-1)\) with \(f(x)=2\), the two destination states
\[
y_1=(-1,-1,+1,-1),\qquad y_2=(+1,+1,-1,+1)
\]
have \(f(y_1)=f(y_2)=-1\), and their disagreement sets are disjoint, \(\{b,c\}\) and \(\{a,d\}\). The two **simultaneous** full-row constraints force
\(r_b^x+r_c^x\ge3\) and \(r_a^x+r_d^x\ge3\), so \(K^*\ge6\). An independent exact table of sixteen explicitly feasible rational rows, each costing \(\le6\), proves the reverse inequality. This is a **primal/dual exact certificate**, with the two disjoint demands constituting a dual fractional packing of total value six; no generic LP optimizer is needed to verify it.

The tempting row coefficient-four conjecture \(M\ge4V^2/K^2\) **survives** this example, because \(4V^2/(K^{*2}M)=25/54<1\). Neither the c=4 row conjecture nor the weaker existence of some c>0 is established by this check.

## 2. New finite-level theorem — all finite source products

Let \(f\) be any bounded real function on a finite product of independent finite probability spaces, with **m \(\ge2\) distinct positive-support output levels** \(u_1<\cdots<u_m\). Null-mass letters are discarded. Suppose that every source point \(x\) admits a nonnegative **full fractional row** \(a^x\) with \(\sum_i a_i^x\le K\) and
\[
|f(x)-f(y)|\le\sum_{i:x_i\ne y_i}a_i^x\quad\text{for every supported }y.
\]
Put \(V=\operatorname{Var}(f)\), \(M=\max_i \operatorname{Inf}^{\rm resample}_i(f)\), \(\delta_k=u_{k+1}-u_k>0\), \(g_k=\mathbf1_{\{f\ge u_{k+1}\}}\), and \(q_k=\operatorname{Var}(g_k)=p_k(1-p_k)\), with \(p_k=\Pr[f\ge u_{k+1}]\). Then the exact **threshold-sensitive certificate** and its gap-free corollary are
\[
\boxed{\quad K^2M\ge\max_{1\le k<m}\delta_k^4q_k,\qquad
  K^2M\ge\frac{4}{(m-1)^4}V^2.\quad}\tag{FL}
\]
No degree bound, atom floor, equal alphabet, Boolean input assumption, or coordinate-count dependence appears. The only non-elementary imported input is the finite original-product Boolean two-sided row theorem; on the uniform cube this is explicitly Turturean 2026 Section 9.5. For general original product laws, use the true-law row/influence transfer in merged #298/#309 and positive-support reduction; its Lean top-level hypotheses must be audited before claiming an integrated terminal for (FL).

### Independent analytic proof

**A. One row works for every threshold after a known gap scaling.** For any supported \(x,y\) with \(g_k(x)\ne g_k(y)\), their output levels lie on opposite sides of \((u_k,u_{k+1})\), so
\[
\delta_k\le|f(x)-f(y)|\le \sum_{i:x_i\ne y_i}a_i^x.
\]
Consequently \(\lambda^{k,x}_i=a_i^x/\delta_k\) is a *genuine full row* for Boolean \(g_k\), with cost \(\le K/\delta_k\). The established **Boolean** row theorem implies
\[
\max_i I_i(g_k)\ge q_k\delta_k^2/K^2.
\]

**B. Preserve the genuine original-law influence.** Each source single-coordinate independent resampling pair \(X,X^{(i)}\) satisfies
\[
(f(X)-f(X^{(i)}))^2\ge\delta_k^2(g_k(X)-g_k(X^{(i)}))^2.
\]
Taking one-half expectation gives \(I_i(f)\ge\delta_k^2 I_i(g_k)\) under the actual independent laws. Thus \(K^2M\ge\delta_k^4q_k\) for **every** k.

**C. Recover total variance from nested threshold layers.** Pointwise,
\(f=u_1+\sum_{k=1}^{m-1}\delta_k g_k\). In \(L^2\) centered around expectations, the triangle inequality yields
\[
\sqrt V\le\sum_{k=1}^{m-1}\delta_k\sqrt{q_k}.
\]
Let \(S=\max_k\delta_k^2\sqrt{q_k}\). Since \(q_k\le1/4\),
\[
\delta_k\sqrt{q_k}
 =\sqrt{\delta_k^2\sqrt{q_k}}\ q_k^{1/4}
 \le\sqrt{S/2}.
\]
Therefore \(V\le (m-1)^2S/2\), so \(K^2M\ge S^2\ge 4V^2/(m-1)^4\). The case of constants has \(V=M=0\).

**At m=2**, this gives the **dictator-sharp coefficient four**, \(K^2M\ge4V^2\), and in fact the stronger \(K^2M\ge \delta_1^4q_1=4B(f)^2V\). The proof correctly specializes to Boolean real-output functions and arbitrary original product marginals.

## 3. Sharpness of the *single-threshold mechanism*, not of universal row complexity

For fixed \(m\ge3\), take a **single categorical source coordinate** with m equally spaced output values on \([-1,1]\):
\[
u_j=-1+\frac{2(j-1)}{m-1}.
\]
Put mass \((1-\varepsilon)/2\) on each endpoint and mass \(\varepsilon/(m-2)\) at each interior level, with \(0<\varepsilon<1\). As \(\varepsilon\to0\), \(\operatorname{Var}(f)\to1\), and for **every** threshold \(p_k\to1/2\), \(q_k\to1/4\), while \(\delta_k=2/(m-1)\). Hence
\[
\frac{\max_k\delta_k^4q_k}{V^2}
\longrightarrow \frac{4}{(m-1)^4}.
\]
So the *final numerical step based only on selecting one threshold and using its gap-rescaled row* cannot improve the power \(m^{-4}\). **This does not show that the true full-row inequality needs an m-dependent coefficient.** In fact this very example has one input coordinate, exact uniform full-row cost \(K=2\), and \(M=V\), so \(K^2M/V^2=4/V\to4\), with no dependence on m.

This is the decisive mechanism lesson: the single-cut information can be arbitrarily weaker than the actual coherent multi-level row geometry, **even for a one-coordinate source**. A universal real-valued bilinear estimate must aggregate **cross-threshold information**, not simply take the best separately normalized Boolean cut. This explains the cubic moment in Turturean's original integrated level proof (Section 7.2); it is not a new proof of the stronger desired quadratic-moment bound.

## 4. Independent replay and next adversarial test

Run \`python3 -I research/nightfall/flagship-influence/check_finite_level_rows_exact.py\`. It validates:
- 16 hard-coded, rational, feasible full rows for the four-bit PSI witness and a two-disjoint-block dual lower certificate forcing \(K=6\);
- full original-law resampling influences and *every* nested threshold's gap-rescaled row feasibility for rational-output functions on biased, heterogeneous and null-atom categorical products;
- the exact bound \(K^2M\ge\max \delta^4q\ge4V^2/(m-1)^4\) across all fixtures;
- m=2 Boolean equality for a fair dictator, and the multi-output one-coordinate near-endpoint sharpness mechanism.

**Certification:** analytic deduction + exact finite regression + explicit primal/dual certificate for the four-bit witness. No Lean (except the imported earlier Boolean source theorem), non-author mathematical review, or full universal/novelty proof. Exact checker is *not* evidence that the open real-valued row theorem holds for arbitrary m. The next decisive operator is a coherent *bilinear* estimate summing threshold interactions without losing one gap factor per cut. Any success must survive the one-coordinate m-level example, the four-bit \(K=6\) source certificate, and the true source-consistent Q3 replica witness with \(K_{\rm annealed}\ge64/49\) from draft #810.


## 5. Genuine **degree-three** bilinear proof attack: fixed optimal row cost, divergent ℓ¹(L²)

A separate exact source construction (related to the categorical selector/charge theorem of draft PR #811) disproves a tempting *intermediate norm estimate*, **even with full fractional rows and Efron–Stein degree precisely three**. It does **not** disprove the real-valued row-to-influence conjecture.

Fix \(m\ge2\). Let \(A,B\) be two independent uniform m-letter categorical variables, and let the \(m^2\) leaves \(Y_{ab}\) be mutually independent fair signs, independent of \(A,B\). Define
\[
\boxed{\quad f_m(A,B,Y)=Y_{AB}.\quad}
\]
This is sign-valued, centered, \(V=B(f_m)^2=1\), and has **ANOVA degree exactly three** for every \(m\ge2\). Indeed
\[
f_m=\sum_{a,b}\Big(\frac1m+\alpha_a(A)\Big)
                 \Big(\frac1m+\beta_b(B)\Big)Y_{ab},
\quad
\alpha_a=1_{\{A=a\}}-\frac1m,\ \beta_b=1_{\{B=b\}}-\frac1m,
\]
and the exact level-three energy is \(\sum_{a,b}\|\alpha_a\beta_bY_{ab}\|_2^2=(1-1/m)^2>0\).

The **true original-source resampling influences** are
\[
I_A(f_m)=I_B(f_m)=1-\frac1m,\qquad
I_{Y_{ab}}(f_m)=\frac1{m^2}.
\]
Thus \(M=1-1/m\), while
\[
\boxed{\sum_{\text{all source sites }i}\sqrt{I_i(f_m)}
=2\sqrt{1-1/m}+m\longrightarrow\infty.}
\]

Yet the **optimal uniform full fractional-row cost is exactly six** for every m. At a given source configuration \(x=(a,b,y)\), assign row weights \(r_A^x=r_B^x=2\), \(r_{Y_{ab}}^x=2\), all other weights zero. If a comparison \(z\) changes either address, the address row contributes at least 2 and dominates \(|f(x)-f(z)|\le2\); if both addresses stay fixed, the selected leaf row contributes exactly 2 when its output changes. Hence the row is valid against **every** comparison, with pointwise cost \(6\).

For the matching lower bound choose an input with \(Y_{ab}=+1\), \(Y_{a'b}=Y_{ab'}=-1\) for some \(a'\ne a,b'\ne b\). Three disjoint **singleton** changes — resample \(A\) to \(a'\), \(B\) to \(b'\), or flip \(Y_{ab}\) — each changes output by 2. Thus every row at this input has \(r_A\ge2,r_B\ge2,r_{Y_{ab}}\ge2\), and \(K^*(f_m)\ge6\). This is an exact primal/dual row certificate.

For this explicit optimal row family
\[
\sup_x\sum_i r_i^x=6,\qquad
\sum_i\|r_i\|_{L^2(\mu)}=4+2m\to\infty.
\]
Moreover the lower bound \(\sum_{a,b}\|r_{Y_{ab}}\|_2\ge2m\) holds for **every** valid row family, because the one-leaf comparison forces \(r_{Y_{ab}}^x\ge2\) whenever \((A,B)=(a,b)\), an event of probability \(1/m^2\).

**Proven no-go:** Neither
\[
\sum_i\sqrt{I_i(f)}\le C K^*(f)
\quad\text{nor}\quad
\sum_i\|r_i\|_{L^2}\le C K
\]
can hold with universal C, **even on bounded original-product functions of exact Efron–Stein degree three**, and the second statement fails for *all* feasible row choices. This destroys any proposed bilinear proof that first embeds the pointwise \(\ell_1\) row budget into a sum of coordinate \(L^2\) gradient norms. It also gives a genuine source-selector negative control for the annealed-Q2 challenge (#799/#803): the selector coordinates must be charged **jointly** with their \(m^2\) rare leaves. 

**What survives:** The real-valued row conjecture is perfectly consistent: \(K^{*2}M/V^2=36(1-1/m)\), bounded below by 18. The full-row coefficient-four hypothesis \(K^2M\ge4V^2\) holds with ample slack. The structure is a two-address extension of #811's already credited one-categorical-address proof attack, not asserted as a novel worldwide construction. Its new use here is the exact fixed-degree-three **all-feasible-row ℓ¹(L²) obstruction**, with explicit optimal primal/dual row cost.

**Independent exact replay:** \`python3 -I research/nightfall/flagship-influence/check_two_address_row_l2_no_go.py\` exhaustively checks genuine source influences at \(m=2,3\), and verifies symbolic all-m row feasibility, Efron–Stein level-three energy, the exact uniform K=6 dual, and the divergence formulas.


## 6. Exact bilinear representation: a Brownian-bridge threshold kernel and a row-polytope gauge

This is the mathematically precise missing **multilevel bilinear** interface. Its identities are author-side proved from elementary conditional covariance and finite LP duality. The Brownian-bridge kernel and tridiagonal Green precision are **classical**, not claimed as novel. Crucially, the final source-coupled inequality below is a **CONJECTURE**, not obtained by the identities.

Fix **the level labeling** \(\ell:\Omega\to\{1,\ldots,m\}\) on the supported product sample space; every label has positive mass \(r_j=\Pr(\ell=j)>0\). Vary the positive gap vector \(\delta=(\delta_1,\ldots,\delta_{m-1})\), and set
\[
f_\delta(x)=u_1+\sum_{k=1}^{m-1}\delta_k\,g_k(x),\qquad
g_k(x)=\mathbf1_{\{\ell(x)>k\}}.
\]
Let \(s_k=\Pr(\ell\le k)=\sum_{j\le k}r_j\), \(0=s_0<s_1<\cdots<s_m=1\), and write
\[
C_{k\ell}=\operatorname{Cov}(g_k,g_\ell)
=\min(s_k,s_\ell)-s_ks_\ell.
\]
This is the **Brownian bridge covariance matrix** sampled at the cumulative output probabilities. It is positive definite for positive \(r_j\), with an explicit **tridiagonal inverse**
\[
\boxed{\quad
(C^{-1})_{kk}=\frac1{r_k}+\frac1{r_{k+1}},\qquad
(C^{-1})_{k,k+1}=(C^{-1})_{k+1,k}=-\frac1{r_{k+1}},
\quad (C^{-1})_{k\ell}=0\ \text{if }|k-\ell|>1.
\quad}\tag{BB}
\]
Verification: the discrete Green function \(s\mapsto\min(s,s_\ell)-s\,s_\ell\) is piecewise affine with its only unit slope jump at \(s_\ell\); the weighted second difference with spacings \(r_k\) yields the Kronecker delta.

For an actual original source coordinate \(i\), define the **cross-level resampling Gram**
\[
J_i(k,\ell)=\mathbb E_{X_{-i}}
   \big[\operatorname{Cov}_{X_i}(g_k,g_\ell\mid X_{-i})\big]
=\tfrac12\mathbb E_{X,X_i'}\big[
    (g_k(X)-g_k(X_{-i},X_i'))(g_\ell(X)-g_\ell(X_{-i},X_i'))
  \big].
\]
All \(J_i\) are positive semidefinite **and entrywise nonnegative** (for each resampling pair, all nested threshold changes have the same sign). In fact
\[
\boxed{0\preceq J_i\preceq C\preceq\sum_iJ_i,}
\tag{MPS}
\]
where the first two inequalities are covariance decomposition/conditional Jensen and the last is original-product Efron–Stein applied to **every signed linear combination** of the \(g_k\).

**Exact energy identities:**
\[
\boxed{\operatorname{Var}(f_\delta)=\delta^\top C\delta,\qquad
I_i^\mu(f_\delta)=\delta^\top J_i\delta.}\tag{E}
\]
These are not approximations, do not change original source laws, and include all off-diagonal *cross-threshold* terms that disappear in the isolated-cut argument.

**Full row constraints as a polyhedral gauge.** Define \(D_x(y,i)=\mathbf1_{\{x_i\ne y_i\}}\), and the **threshold-crossing vector** \(w_x(y,k)=\mathbf1_{\{\min(\ell(x),\ell(y))\le k<\max(\ell(x),\ell(y))\}}\). For \(\delta\ge0\),
\[
|f_\delta(x)-f_\delta(y)|=\sum_k w_x(y,k)\delta_k.
\]
Therefore the minimum full fractional-row cost at x is *exactly* the primal/dual LP pair
\[
K_x^*(\delta)=\min_{\substack{a_i\ge0\\D_xa\ge W_x\delta}}
\sum_i a_i
=\max_{\substack{\lambda_y\ge0\\D_x^\top\lambda\le\mathbf1}}
\sum_{y,k}\lambda_y w_x(y,k)\delta_k.
\]
The uniform source cost is
\[
\boxed{\mathcal K(\delta)=\max_x K_x^*(\delta).}\tag{G}
\]
For fixed original support labeling, \(\mathcal K\) is a **positively homogeneous convex piecewise-linear support function** of the gap vector. Dual packings are exact checker-friendly certificates and automatically account for simultaneous disjoint multibit constraints, unlike \(R=\max_x\sum_i|f(x)-f(x^i)|\).

**The *unproved* sharp bilinear gate is now a finite-dimensional conic inequality**
\[
\boxed{
4\,(\delta^\top C\delta)^2
\ \stackrel{?}{\le}\
\mathcal K(\delta)^2\,
\max_i(\delta^\top J_i\delta)
\qquad(\delta>0).
}\tag{R4}
\]
For \(m=2\), it follows from the established Boolean two-sided row theorem. For fixed \(m\), (FL) proves the same statement with 4 replaced by \(4/(m-1)^4\). **The matrix positivity sandwich (MPS), the inverse (BB), and LP identity (G) alone do not establish (R4)**; the missing step is an estimate that uses the *source-consistent coupling* between row feasible faces and the off-diagonal conditional covariance Grams.

**Why this representation is useful.** After fixing an output-level partition and the source law, \(C\) and \(J_i\) are fixed exact rational matrices and the row costs are maxima of rational linear forms in \(\delta\) (vertices of the row dual polytopes). This isolates the continuous degree of freedom to the \(m-1\) nonnegative gaps. It gives an exact/interval-admissible adversarial search for the bilinear gate: enumerate supported labelings, compute the Brownian-bridge precision and true-law conditional Grams independently, generate row dual vertices, then optimize (R4) over positive gaps. A violating rational gap vector plus rational source masses and full primal/dual row certificates is a decisive falsifier of coefficient **four**, though not necessarily of the existence of some weaker constant.

**New exact checker:** \`check_row_threshold_brownian_bridge.py\` independently computes the Green inverse, all original resampling Grams by both pairwise replacements and conditional covariances, the PSD sandwich via exact principal minors, and random rational-gap energy identities. It also checks a dual packing certificate for the four-bit K=6 source example. Finite matrix tests do not establish the conjectural inequality (R4).

**Discovery graph:** real row problem → finite output threshold filtration → Brownian-bridge precision → source conditional Gram PSD/order → polyhedral fractional-row gauge → **missing coupled bilinear estimate** → hypothetical row \(\alpha=2\) → hypothetical polynomial degree-cost UE2. Original Aaronson–Ambainis/Turturean and finite-product Lean row bridge credited; no priority assertion.


## 7. Sharp additive equality rules out **entrywise** bilinear comparison

For any \(n\ge2\), take independent fair \(\{0,1\}\) bits \(X_1,\dots,X_n\) and the additive function \(f=\sum_i X_i\), whose \(m=n+1\) output levels are \(0,1,\dots,n\). This is **Efron–Stein degree one**, and exactly saturates the proposed coefficient-four full-row inequality:
\[
V=n/4,\quad I_i=1/4,\quad
K^*=n,\quad
\boxed{\frac{4V^2}{K^{*2}M}=1}.
\]
The row \(a_i(x)\equiv1\) is feasible, and at the all-zero input changing any single bit forces \(a_i\ge1\) for all i, so the exact uniform optimum is \(K^*=n\).

The threshold indicators \(g_k=\mathbf1_{\{\sum_i X_i\ge k+1\}}\), \(k=0,\ldots,n-1\), have a **dense strictly positive** global Brownian bridge covariance matrix \(C\):
\(C_{k\ell}=s_{\min(k,\ell)}(1-s_{\max(k,\ell)})>0\) for \(k\ne\ell\), since every binomial count \(0,\ldots,n\) has positive mass.

But for **every original coordinate** \(i\), a single-site resampling changes the count by at most one, so a pair of *distinct* thresholds can never change simultaneously. Thus the conditional/source influence matrix is **strictly diagonal**:
\[
\boxed{
J_i(k,\ell)=
\begin{cases}
\binom{n-1}{k}/(4\,2^{n-1})&k=\ell,\\
0&k\ne\ell.
\end{cases}
}
\]
In particular, any proposed **entrywise** comparison of the form \(C_{k\ell}\le cK^2\max_iJ_i(k,\ell)\) fails at every off-diagonal pair (positive left side, exactly zero right side), **even though the desired full quadratic-form row inequality is attained with equality**.

This is not a counterexample to the true bilinear target; it is a mandatory proof-shape restriction. The dense global covariance must be transported through cross-level geometry, for example the tridiagonal **Green inverse** (BB), and controlled by the *aggregate* diagonal original-source influence, not by an entrywise comparison of \(C\) and \(J_i\). In this family, \(\delta=(1,\ldots,1)\), \(\delta^\top C\delta=n/4\), \(\delta^\top J_i\delta=1/4\), and the row gauge \(K(\delta)=n\) restores exact equality.

**Independent checker:** the Brownian-bridge script now replays this equality and \(C_{k\ell}>0\), \(J_i(k,\ell)=0\) for n=2,3,4,5 with true original resampling and exact rational arithmetic. This example is the classical sharp degree-one additive family, credited accordingly; only its *use as an off-diagonal bilinear proof attack* is newly archived here.
