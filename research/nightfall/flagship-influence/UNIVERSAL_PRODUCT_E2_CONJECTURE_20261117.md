# NIGHTFALL universal product-space exponent-two influence conjecture
Version: 1.1 — 2026-11-17 (US Eastern), Chebyshev parity upgrade
Status: **OPEN CONJECTURE; NOT A THEOREM, NOT LEAN-CERTIFIED, NOT NOVELTY-CLEARED.**
Research direction: Devin J. Wright / NIGHTFALL; mathematical development AI-assisted.
Credit: Scott Aaronson and Andris Ambainis (original conjecture); David Turturean (2026 uniform-cube proof); previous product and completely bounded results as noted below. No independent expert review is claimed.


## V1.1 sharp-degree upgrade: two nested conjectures and Chebyshev parity audit

**Status: OPEN CONJECTURES, NOT LEAN THEOREMS.** Keep **N-UE2(6)** as the immediate flagship. Introduce the **sharp-degree landmark N-UE2(2)**, identical in scope/normalization but with \(d^2\) in place of \(d^6\). If N-UE2(2) holds with constant \(C\), it entails N-UE2(6) with the same constant, since \(d^2\le d^6\) for \(d\ge1\). The following classical obstruction shows why exponent 2 is the least possible; it does **not** prove that 2 suffices.

**Degree-exponent obstruction from classical Chebyshev polynomials.** For each integer \(d\ge1\), take \(n=d^2\) independent fair signs, \(S_n=\sum_{i=1}^n X_i\), and \(f_d=T_d(S_n/n)\), where \(T_d(\cos\theta)=\cos(d\theta)\). Let \(B_d=(\max f_d-\min f_d)/2\) be the **actual essential centered radius**, \(V_d=\operatorname{Var}(f_d)\), and \(M_d=\mathbb E[\operatorname{Var}(f_d\mid X_{-1})]\). The Walsh degree is exactly \(d\): the coefficient of a \(d\)-fold multilinear monomial from the leading Chebyshev term is nonzero. Set \(t_k=T_d((2k-n)/n)\). With the **original-law resampling** convention:

\[
m_d=2^{-n}\sum_{k=0}^n {n\choose k}t_k,\quad
V_d=2^{-n}\sum_{k=0}^n {n\choose k}t_k^2-m_d^2,\quad
M_d=2^{-(n+1)}\sum_{k=0}^{n-1}{n-1\choose k}(t_{k+1}-t_k)^2.
\]

For odd \(d\), \(m_d=0\) and \(B_d=1\). For even \(d\), \(m_d\ne0\) generally, and **finite** \(B_d\) need not equal 1; nonetheless \(B_d\to1\). With \(Z\sim N(0,1)\), the Gaussian scaling \(S_{d^2}/d\Rightarrow Z\) and the local sine/cosine Chebyshev formulas give separate **author-derived analytic limits, pending independent proof audit**:

\[
\begin{array}{ll}
d\ \mathrm{odd}:&
V_d\to (1-e^{-2})/2,\quad d^2M_d\to(1+e^{-2})/2,\\
&\displaystyle\frac{V_d^2}{B_d^2d^2M_d}
\to\frac{(1-e^{-2})^2}{2(1+e^{-2})}\approx0.329261797574;\\
d\ \mathrm{even}:&
V_d\to(1-e^{-1})^2/2,\quad d^2M_d\to(1-e^{-2})/2,\\
&\displaystyle\frac{V_d^2}{B_d^2d^2M_d}
\to\frac{(1-e^{-1})^4}{2(1-e^{-2})}\approx0.092325555245.
\end{array}
\]

In either parity subsequence the ratio stays positive, so \(V_d^2/(B_d^2M_d)=\Omega(d^2)\). **Every universal proposed degree power \(k<2\) is false** for a variance-squared influence inequality. The Chebyshev family itself is classical; this is a stronger necessary degree-exponent control than the tribes \(k\ge1\) calculation recorded below, *not* a novelty claim. A rigorous published-style proof must bound the tails and derivative approximation; finite exact arithmetic alone is not such a proof.

**Reproducible exact finite checker.** Run python3 research/nightfall/flagship-influence/check_ue2_chebyshev.py. It uses exact rational Chebyshev recurrence, binomial moments, two independently formulated conditional-variance influences, and direct whole-cube enumeration at \(d=1,2,3\). It covers \(d=1,\ldots,16\), including even \(d=8,12,16\) with true-radius ratios 0.094778902182, 0.093335481283, 0.092881243799 and odd \(d=9,13,15\) with ratios 0.328588000082, 0.328965446849, 0.329043648752. Its Gaussian limits are printed as predictions; CI does not certify them.

**Conditional implication/Lean targets (not kernel-certified by this note).** (1) N-UE2(2) implies N-UE2(6) for the same \(C\); (2) N-UE2(6) on the uniform Boolean cube implies original-AA flip influence at least \(16 V^2/(C d^6)\), since flip influence is four times resampling influence and centered radius of a [0,1]-valued function is at most \(1/2\); (3) for numerical domination of Turturean's *exact* coefficient for all \(V\), the sufficient condition is \(C\le500\pi^4/\sqrt{15}\), **not** a condition in the conjecture; (4) finite-to-infinite transfer needs a named cylinder-approximation theorem preserving boundedness, Hoeffding degree, and original-law influence. Degree-two a.e. infinite-product terminal is in **merged PR #776**; the separate textbook Hoeffding bridge PR #801 remains open. The cubic top-degree cover theorem **PR #787 is merged**. The unrestricted cubic gate is the *source-consistent mean-coupled quadratic inequality* developed in merged provisional PR #799 and pending PR #803, **not** the disproved generic annealed version or the retired coefficient-one spike-tail shortcut (#797/#802).

**Prior-art boundary.** Turturean 2026 §9.5 explicitly raises variance exponent two and a row-cost intermediate; Huffstutler–Miloschewsky–Podder 2026 Appendix A proves a uniform-cube polynomial bound with weaker exponents; Blanc–Docter–Strassle–Tan 2026 supplies another uniform-cube exposition. None is an established proof of N-UE2(6) over arbitrary product laws. These are bounded checks, not exhaustive novelty clearance.

---

## Objective — conditional quantitative subsumption of Aaronson–Ambainis

**Finite-product flagship, N-UE2(6).** There is a universal real \(C<\infty\) such that, for every \(d\ge1\), every finite nonempty index set \(I\), every independent collection of probability spaces \((\Omega_i,\mu_i)\), and every essentially bounded real \(f\in L^2(\bigotimes_i\mu_i)\) with Efron–Stein/Hoeffding degree \(\le d\),

\[
\tag{N-UE2(6)}
\operatorname{Var}(f)^2 \ \le\ C\,d^6\,B(f)^2\,\sup_{i\in I}\operatorname{Inf}_i(f),
\qquad
B(f)=\inf_{c\in\mathbb R}\|f-c\|_{L^\infty}.
\]

Here \(\operatorname{Inf}_i(f)=\|f-\mathbb E[f\mid X_{I\setminus\{i\}}]\|_2^2\) is the **original-law resampling influence**, not Boolean flip influence, and all supports and bounds are understood modulo measure-zero sets. Degree is the largest order of a nonzero canonical ANOVA component; at finite \(I\) this is unambiguous even with zero-mass atoms. The case \(B=0\) has both sides zero. Writing \(B\) as half the essential oscillation makes the claim translation-invariant and exactly homogeneous.

**Sharp-degree landmark, N-UE2(2) (OPEN).** Under precisely the same arbitrary-independent-product assumptions and centered essential radius, conjecture
\[
\tag{N-UE2(2)}
\operatorname{Var}(f)^2\le C_2\,d^2\,B(f)^2\,\sup_i\operatorname{Inf}_i(f).
\]
Here \(C_2\) is an absolute constant independent of the number, laws and alphabets of coordinates and the degree. Since \(d^2\le d^6\) for \(d\ge1\), **N-UE2(2) implies N-UE2(6) with the same constant**. The degree exponent \(2\) is necessary by the exact classical Chebyshev construction below. Neither conjecture is proved for unrestricted cubic functions.

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

**Tribes give a weaker necessary degree exponent \(\boldsymbol{k\ge1}\), superseded by Chebyshev's \(k\ge2\) obstruction above.** Use the classical tribes family, not an original construction. At width \(w\), set \(t=2^w\), \(n=d_w=wt\), independent uniform bits \(x_{a,j}\), and
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

**Scope of sharpness:** degree-one examples exclude \(\alpha<2\); tribes exclude \(k<1\), while Chebyshev excludes \(k<2\). None proves N-UE2(6) or N-UE2(2). The published sharpness examples and the elementary degree-one argument are prior mathematical knowledge.

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
* **Current unrestricted obstruction:** merged PR #799 and draft #803 reduce degree-three exponent-two to a source-consistent mean-coupled quadratic inequality; it remains unproved. The unstructured annealed inequality is false and the coefficient-one spike-tail shortcut was retired by PR #802. A proof of N-UE2(6) for all degrees would of course settle degree three, but cannot be obtained by asserting the reduction's missing hypothesis.

**Novelty gate:** A theorem subsumes prior results mathematically only if its statement and proof are verified and its hypotheses/normalizations line up. We have not established originality of this exact conjecture or its proof (there is no proof). Conduct exhaustive dated full-text search, compare quantitative constants, seek non-author referee assessment, and obtain human authorization before submission.

## Discovery contract, audit and stop rule

1. **Representation:** separate \(\alpha=2\) (necessary), degree penalty \(k=6\) (flagship) or \(k=2\) (sharp candidate, with \(k\ge2\) necessary by Chebyshev), arbitrary-product law, canonical degree, resampling influence and centered radius.
2. **Strongest externally checked this session:** Turturean 2026 theorem \(V^{5/2}/d^6\) on the uniform cube; GMNR distributional equivalence; classical tribes and Chebyshev lower bounds. Neither proves N-UE2(6).
3. **Best verified construction:** fair-degree-one sharp ratio 1, classical tribes exact degree-penalty obstruction; existing Lean Q2 on arbitrary products and author-side restricted cubic. No all-degree exponent-two candidate proof.
4. **Remaining central gap:** find a single original-product, dimension-free mechanism that upgrades the coupled two-replica quadratic route, or an alternative all-degree inequality, without illicit \(\mathbb E[\max_i]\leftrightarrow\max_i\mathbb E\) interchange or lost bias/alphabet dependence.
5. **Cheapest decisive experiments:** (a) vary rare categorical routing selectors and balanced tribes in exact rational finite models; (b) attempt a source-coupled rather than arbitrary random-family inequality; (c) search finite small-degree cases for ratios exceeding any proposed \(C d^6\). Finite searches can falsify a proposed constant, never certify all-degree truth.
6. **Independent attack planned:** construct separate finite-state checker computing ANOVA degree and all original-law influences; audit concentration and uniformity in \(d\); verify precise constant conversion and boundary \(d=1,B=0,I=\varnothing\).
7. **Budget/stop rule:** limit Lean to conditional implications unless a full analytic proof is found; prioritize PR #799/#803 source-consistent Q3 gate rather than polishing Q2 constants; switch mechanism after repeated failures; do not merge either conjecture as a proven theorem. Reserve exploration budget for counterexamples and independent prior-art checks.
8. **Completion gate:** complete paper proof → independent reproduction and adversarial proof review → strict Lean source and exact-head build/axiom check → novelty/priority clearance → owner-approved publication.

Mechanism graph: sharp Chebyshev degree obstruction k>=2 → original product ANOVA → coordinate heat-bath influence → two-replica lift / anchor range or new operator → source-coupled energy control (OPEN) → \(V^2/(B^2M)\le Cd^6\) (OPEN) → finite-cylinder limit (conditional, standard) → finite/infinite all-degree theorem (OPEN).

**Do not label this conjecture proved, original, or competitive until its independent gates pass.**
