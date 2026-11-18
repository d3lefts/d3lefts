# NIGHTFALL universal product-space exponent-two influence conjecture
Version: 1.0 — 2026-11-17 (US Eastern)
Status: **OPEN CONJECTURE; NOT A THEOREM, NOT LEAN-CERTIFIED, NOT NOVELTY-CLEARED.**
Research direction: Devin J. Wright / NIGHTFALL; mathematical development AI-assisted.
Credit: Scott Aaronson and Andris Ambainis (original conjecture); David Turturean (2026 uniform-cube proof); previous product and completely bounded results as noted below. No independent expert review is claimed.

## Objective — precisely subsume the 2014 Aaronson–Ambainis statement

**Finite-product flagship, N-UE2(6).** There is a universal real \(C<\infty\) such that, for every \(d\ge1\), every finite nonempty index set \(I\), every independent collection of probability spaces \((\Omega_i,\mu_i)\), and every essentially bounded real \(f\in L^2(\bigotimes_i\mu_i)\) with Efron–Stein/Hoeffding degree \(\le d\),

\[
\tag{N-UE2(6)}
\operatorname{Var}(f)^2 \ \le\ C\,d^6\,B(f)^2\,\sup_{i\in I}\operatorname{Inf}_i(f),
\qquad
B(f)=\inf_{c\in\mathbb R}\|f-c\|_{L^\infty}.
\]

Here \(\operatorname{Inf}_i(f)=\|f-\mathbb E[f\mid X_{I\setminus\{i\}}]\|_2^2\) is the **original-law resampling influence**, not Boolean flip influence, and all supports and bounds are understood modulo measure-zero sets. Degree is the largest order of a nonzero canonical ANOVA component; at finite \(I\) this is unambiguous even with zero-mass atoms. The case \(B=0\) has both sides zero. Writing \(B\) as half the essential oscillation makes the claim translation-invariant and exactly homogeneous.

**Arbitrary-index extension, N-UE2(6)-infinite.** Use \(\sup_i\) (not a possibly unattained maximum), and define degree \(\le d\) as the \(L^2\)-closed span of genuine Hoeffding components supported on at most \(d\) coordinates. The infinite statement follows by the standard finite-cylinder conditional approximation **if the finite conjecture holds**; sketch below. It is not a separate proven bound.

**Weaker backup claim** (distinct from the flagship): existence of some finite exponent \(k\) in place of 6 while retaining variance exponent two. This would still strengthen the qualitative original Aaronson–Ambainis conjecture on the uniform cube, but for \(k>6\) it would not preserve Turturean's quantitative degree dependence. Do not silently substitute this weaker claim for N-UE2(6).

## Exact subsumption / normalization audit

Aaronson–Ambainis [Theory of Computing 10 (2014), Conj. 1.7] originally asks for a polynomial influence lower bound on \(p:\{0,1\}^n\to[0,1]\), uniform bits. Turturean [arXiv:2611.09773, submitted 2026-11-06] proves
\[
\max_i\operatorname{Inf}^{\rm flip}_i(p)
\ge
\frac{8\sqrt{15}}{125\pi^4}\frac{\operatorname{Var}(p)^{5/2}}{d^6}.
\]
Turturean's \(\operatorname{Inf}^{\rm flip}_i(p)=\mathbb E[(p(X)-p(X^{\oplus i}))^2]\). For a uniform bit and an arbitrary \(p\), \(\operatorname{Inf}^{\rm flip}_i(p)=4\operatorname{Inf}^{\rm resample}_i(p)\).

Set \(g=2p-1\), so \(\|g\|_\infty\le1\), \(\operatorname{Var}(g)=4\operatorname{Var}(p)\), and \(\operatorname{Inf}^{\rm resample}_i(g)=\operatorname{Inf}^{\rm flip}_i(p)\). If N-UE2(6) holds with constant \(C\), then
\[
\max_i\operatorname{Inf}^{\rm flip}_i(p)
\ge \frac{16}{C}\,\frac{\operatorname{Var}(p)^2}{d^6}.
\]
This genuinely subsumes the **qualitative** original conjecture, and improves the variance exponent from \(5/2\) to \(2\), on a strictly larger domain of input laws and alphabets.

**Numerical-constant caveat:** a universal but unspecified \(C\) does NOT ensure that this bound is pointwise larger than Turturean's explicit coefficient for every \(p,d\). Since \(\operatorname{Var}(p)\le1/4\), a sufficient condition to dominate his coefficient everywhere is \(C\le500\pi^4/\sqrt{15}\approx1.26\times 10^4\). Without that additional condition we claim a stronger exponent/order, **not** a numerically stronger lower bound at all parameter values. The original conjecture itself did not stipulate Turturean's coefficient.

**Averaging convention:** for fair signs in \([-1,1]\), the standard half-flip influence \(\mathbb E[((f(X)-f(X^i))/2)^2]\) equals the original resampling influence. Do not interchange the two flip conventions.

## Sharpness certificates (classical constructions, not original discoveries)

**Variance exponent cannot be <2 even at degree one.** Let \(\epsilon_1,\dots,\epsilon_n\) be independent fair signs and \(f_n=\frac1n\sum_{i=1}^n\epsilon_i\). Exact values:
\[
d=1,\ B=1,\ \operatorname{Var}(f_n)=1/n,\quad
\max_i\operatorname{Inf}_i(f_n)=1/n^2.
\]
A putative lower bound \(\max\operatorname{Inf}\ge\operatorname{Var}^\alpha/(C d^k B^{2\alpha-2})\) with any fixed \(\alpha<2\) fails as \(n\to\infty\).
Moreover, the **complete degree-one bound** is already an elementary theorem:
\[
\operatorname{Var}(f)^2\le B(f)^2\max_i\operatorname{Inf}_i(f)\quad(d\le1)
\]
with **sharp constant 1**. Proof: write \(f=c+\sum_i h_i(X_i)\) with independent centered \(h_i\). Essential oscillations add, \(\sum_i\operatorname{osc}(h_i)=2B\). Popoviciu gives \(\sqrt{\operatorname{Inf}_i(f)}\le\operatorname{osc}(h_i)/2\), hence \(\sum_i\sqrt{\operatorname{Inf}_i(f)}\le B\), and \(\operatorname{Var}(f)=\sum_i\operatorname{Inf}_i(f)\le\sqrt M B\). The fair-sign averages attain equality. This is a classical fact; no novelty claim.

**Polynomial degree exponent must be \(\boldsymbol{k\ge1}\) for any universal all-degree statement with variance exponent two.** Use the classical tribes family, not an original construction. At width \(w\), set \(t=2^w\), \(n=d_w=wt\), independent uniform bits \(x_{a,j}\), and
\[
g_w(x)=2{\bf1}\{\exists a\le t:\ x_{a,1}=\cdots=x_{a,w}=1\}-1.
\]
It has \(B=1\) and **exact Boolean polynomial degree \(d_w=n\)** (the full-degree monomial coefficient is \(2(-1)^{t+1}=-2\)). Put \(q=1/t\), \(r=(1-q)^t\). Then
\[
V_w=4r(1-r),\qquad
M_w=2q(1-q)^{t-1},
\]
\[
R_w:=\frac{V_w^2}{B^2M_w}
=8t(1-1/t)r(1-r)^2.
\]
Thus \(R_w/t\to8e^{-1}(1-e^{-1})^2>0\), while \(d_w=wt\). Hence \(R_w/d_w^k\to\infty\) for every \(k<1\). Any conjecture \(V^2\le C d^k B^2M\) valid for all bounded degree-\(d\) functions must have \(k\ge1\). For \(k=1\) this family does NOT rule the conjecture out. The tribes pivotality calculation is standard; see O'Donnell, *Analysis of Boolean Functions* and the CMU lectures linked below.

**Scope of sharpness:** these tests exclude \(\alpha<2\) and \(k<1\); they do NOT prove N-UE2(6), nor do they establish the optimal degree exponent. The published sharpness examples and the elementary degree-one argument are prior mathematical knowledge.

The stdlib-only exact checker \`research/nightfall/flagship-influence/check_ue2_sharpness.py\` uses fractions, verifies all formulas for widths 1–8, and independently brute-enumerates widths 1 and 2. It also checks all exact degree-one equalities \(n=1,\dots,32\) and the \([0,1]\) versus \([-1,1]\) influence-normalization identities.

## Standard finite→arbitrary-index bridge (conditional on finite theorem)

Let \(I\) be any index set and \(P=\bigotimes_i\mu_i\). For finite \(F\subset I\) let \(P_Ff=\mathbb E[f\mid X_F]\). For a bounded \(f\) in the degree-\(\le d\) Hoeffding closed span, \(P_Ff\) remains bounded by the same centered \(B\) and has degree \(\le d\). For each \(i\in F\), independence and commuting coordinate projections give \(D_iP_F=P_FD_i\), hence \(\operatorname{Inf}_i(P_Ff)\le\operatorname{Inf}_i(f)\le M\). Finite-coordinate cylinders are dense in product \(L^2\), so \(P_Ff\to f\) in \(L^2\) along the directed finite-set net and \(\operatorname{Var}(P_Ff)\to\operatorname{Var}(f)\). Applying the **hypothetical** finite N-UE2(6) to each \(P_Ff\) and taking the limit proves the infinite extension with the **same constant**. This is a standard conditional transfer, not a certificate of the unknown finite bound. Measurability and completion details need a formal check before promoting the infinite formulation.

## Recovered evidence and bounded prior-art audit (2026-11-17)

* **Verified external:** Turturean arXiv:2611.09773, uniform cube, exponent \(5/2\), degree \(d^6\), explicitly lists sharp variance exponent as open.
  https://arxiv.org/abs/2611.09773
* **Verified external:** Girish–Mittal–Nehoran–Raz arXiv:2609.35327 (2026-09-28), distributional fixed-bias / slice equivalences; not a stated arbitrary heterogeneous-alphabet exponent-two theorem.
  https://arxiv.org/abs/2609.35327
* **Verified external:** Blanc–Docter–Strassle–Tan arXiv:2611.11626 and Huffstutler–Miloschewsky–Podder arXiv:2611.12795, 2026 proof/exposition on cube.
  https://arxiv.org/abs/2611.11626
  https://arxiv.org/abs/2611.12795
* **Classical comparator:** O'Donnell, *Analysis of Boolean Functions*, tribes family; exact pivotal formula in CMU lecture 14.
  https://www.cs.cmu.edu/~odonnell/boolean-analysis/lecture14.pdf
* **Other relevant scope**: completely bounded polynomial influence theorems, Grothendieck, decoupling, and original 2014 statement (see repo Q2 priority dossier). Two purported Nov 2026 Zenodo product claims remain **unverified leads**, not established precedence.
* **Internal verified dependency:** merged PR #776 (finite/infinite arbitrary-product \(d\le2\) and coefficient about 105.416), Claude's PR #801 degree-two Hoeffding source bridge (its own exact-head CI status must be verified before promotion). Restricted cubic top-cover PR #787 and fair-block anchored PR #804 do NOT imply this conjecture.
* **Current unrestricted obstruction:** PRs #799/#803 reduce degree-three exponent-two to a source-consistent mean-coupled quadratic inequality; it remains unproved. A proof of N-UE2(6) for all degrees would of course settle degree three, but cannot be obtained by asserting the reduction's missing hypothesis.

**Novelty gate:** A theorem subsumes prior results mathematically only if its statement and proof are verified and its hypotheses/normalizations line up. We have not established originality of this exact conjecture or its proof (there is no proof). Conduct exhaustive dated full-text search, compare quantitative constants, seek non-author referee assessment, and obtain human authorization before submission.

## Discovery contract, audit and stop rule

1. **Representation:** separate \(\alpha=2\) (necessary), degree penalty \(k=6\) (candidate, only \(k\ge1\) known necessary), arbitrary-product law, canonical degree, resampling influence and centered radius.
2. **Strongest externally checked this session:** Turturean 2026 theorem \(V^{5/2}/d^6\) on the uniform cube; GMNR distributional equivalence; classical tribes lower bound. Neither proves N-UE2(6).
3. **Best verified construction:** fair-degree-one sharp ratio 1, classical tribes exact degree-penalty obstruction; existing Lean Q2 on arbitrary products and author-side restricted cubic. No all-degree exponent-two candidate proof.
4. **Remaining central gap:** find a single original-product, dimension-free mechanism that upgrades the coupled two-replica quadratic route, or an alternative all-degree inequality, without illicit \(\mathbb E[\max_i]\leftrightarrow\max_i\mathbb E\) interchange or lost bias/alphabet dependence.
5. **Cheapest decisive experiments:** (a) vary rare categorical routing selectors and balanced tribes in exact rational finite models; (b) attempt a source-coupled rather than arbitrary random-family inequality; (c) search finite small-degree cases for ratios exceeding any proposed \(C d^6\). Finite searches can falsify a proposed constant, never certify all-degree truth.
6. **Independent attack planned:** construct separate finite-state checker computing ANOVA degree and all original-law influences; audit concentration and uniformity in \(d\); verify precise constant conversion and boundary \(d=1,B=0,I=\varnothing\).
7. **Budget/stop rule:** do not polish coefficients or launch Lean until a general analytic operator is found; switch mechanism after repeated failures; do not merge the conjecture into a proven theorem. Reserve exploration budget for counterexamples and independent prior-art checks.
8. **Completion gate:** complete paper proof → independent reproduction and adversarial proof review → strict Lean source and exact-head build/axiom check → novelty/priority clearance → owner-approved publication.

Mechanism graph: original product ANOVA → coordinate heat-bath influence → two-replica lift / anchor range or new operator → source-coupled energy control (OPEN) → \(V^2/(B^2M)\le Cd^6\) (OPEN) → finite-cylinder limit (conditional, standard) → finite/infinite all-degree theorem (OPEN).

**Do not label this conjecture proved, original, or competitive until its independent gates pass.**
