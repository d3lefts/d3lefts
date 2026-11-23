# Quadratic Wyner Simulation: a degree-preserving information/influence dichotomy
**NIGHTFALL research manuscript v0.1 | 22 November 2026 (America/Chicago)**

**Evidence status: author-side complete paper derivation from previously Lean-certified theorems; the NEW composition is NOT yet Lean-certified, independently mathematically refereed, or worldwide-priority cleared.** It is not a general T-query quantum-simulation improvement for T>1. The theorem improves the current **certified** Route 1 degree-two numerical bound; a separate paper-level mean-increment optimization in NIGHTFALL PR #939 has better small-\(\tau\) exponents and must also be compared.

## Abstract

We give a degree-preserving integration of the original-product quadratic variance–influence inequality and the general-latent Wyner-information Route 1 simulator. Unlike the published Route 1 proof's product lift, which adds a latent-label coordinate and raises degree \(d\) to \(d+1\), we apply quadratic rigidity on the **product of the mixture's posterior coordinate marginals**, and then transfer its influential coordinate to the original product components using a common coupling. The alternative is that an unqueried coordinate carries conditional information about the component label. An exact dual potential converts this dichotomy into a deterministic classical **original-coordinate** simulation with an explicit \(O(\tau^{-2}+C_W\tau^{-6})\) pre-truncation charge, versus \(O(\tau^{-5/2}+C_W\tau^{-15/2})\) in the already certified generic Route 1 proof for degree two. The result is distributional scalar-value approximation, not a general complexity characterization or efficient runtime.

## 1. Theorem and mathematical model

Let \(I\) be a finite index set, \(A\) a nonempty finite alphabet, \(\nu\) **any** probability mass function on \(A^I\), and \(f:A^I\to[0,1]\) have original-coordinate indicator/Efron–Stein interaction degree at most two. This is the notion in the source definitions of \(\mathrm{HasProdDegreeLE}\); for finite products it agrees with a sum of terms depending on at most two coordinate indices. Zeros in \(\nu\) and the component measures are allowed. If \(I=\varnothing\), the result is immediate by a depth-zero constant tree; below assume \(I\ne\varnothing\).

Define \(C_W(\nu)\), in **nats**, as the infimum over arbitrary conditional-product representations of \(I(\Theta;X)\). The general-latent infimum equals the finite-mixture infimum by the already merged, source-checked theorem \(\mathrm{wynerGenSet\_eq}\) of PR #976.

Use the exact scalar source constant and row budget
\[
 C_2=\left(2(1+\sqrt2)\sqrt3+\frac{11901}{6250}\right)^2
 =105.416239819\ldots,\qquad K=2\pi^2.
\]
For any \(0<\tau\le1/4\), \(\varepsilon>0\), integer \(q\ge1\) and real \(s>C_W(\nu)\), there exists a deterministic tree \(t\), querying **only original coordinates** of \(X\), with worst-case depth at most \(q\), for which
\[
\boxed{\Pr_{X\sim\nu}\{|f(X)-t(X)|>\varepsilon\}
\le {16\pi^2 C_2\over q\tau^2}
+{2^{38}\pi^2 C_2^3s\over q\tau^6}
+{\tau\over\varepsilon^2}.}\tag{QW}
\]
No running-time, tree-description-size, computability of \(C_W\), quantum-state generation, or conditional exact reconstruction guarantee is asserted.

Because PR #970 / #976 already proves a separate arbitrary-degree tree bound, for degree at most two one may **select the smaller of the existing and new proven bounds** (possibly choosing different trees for different parameter choices). This envelope is at least as strong as either upper bound once QW is independently validated. The old constants come unchanged from \(\mathrm{route1\_wyner\_general}\).

**Fixed-failure corollary.** For \(0<\varepsilon,\delta\le1\), put \(\tau=\varepsilon^2\delta/4\) and choose
\[
q\ge \left\lceil {4\over3\delta}\left(
 {16\pi^2 C_2\over\tau^2}+{2^{38}\pi^2 C_2^3s\over\tau^6}
 \right)\right\rceil.
\]
Then the RHS of QW is at most \(\delta\), giving depth
\(O(\varepsilon^{-4}\delta^{-3}+s\varepsilon^{-12}\delta^{-7})\).
This follows with the exact constants, not an uncharged access to the latent component label.

## 2. Black-box theorems actually available on main

**Q2 original-source terminal.** PR #776's \(\mathrm{infinitePi\_q2\_105416\_ae}\), together with its finite supported product terminal \(\mathrm{native\_heterogeneous\_q2\_105416\_supported\_unconditional}\), gives, on each arbitrary finite product probability law \(Q\),
\[
 \operatorname{Var}_Q(g)^2\le C_2 B^2\max_{j\in I}\operatorname{Inf}_{Q,j}(g)
 \quad (\lVert g\rVert_\infty\le B,\ \deg(g)\le2).
 \tag{Q2}
\]
Influence is the genuine conditional-resampling variance
\(\operatorname{Inf}_{Q,j}(g)=\mathbb E_Q[(g-\mathbb E_Q[g\mid X_{-j}])^2]\);
equivalently, \(\frac12\mathbb E(g(X)-g(X^{(j)}))^2\).
This theorem is already end-to-end Lean compiled under the supported-degree hypotheses. We do not claim to have recompiled it here.

**Route 1 original-source apparatus.** In merged #970/#976, the finite maximum-star coupling \(\mathrm{seed\_coupling\_exists}\), \(\mathrm{key\_lemma}\), \(\mathrm{sum\_pincr\_le}\), \(\mathrm{Phi\_sum}\), \(\mathrm{info\_chain}\), and \(\mathrm{kl\_ge\_tvd\_sq}\) provide: a coupling of every product component to a shared product of marginals, squared mismatch control, initial increment potential at most \(K\), and exact remaining-information charge. They hold under arbitrary finite alphabets and allow zero-mass atoms.

## 3. Independent proof design and local counterexample agenda

Before treating the composition as established, the independent checker should try (a) failure of the quadratic bound under zero-atom posterior products; (b) the erroneous replacement of original-source influence by an auxiliary/latent influence; (c) coupling resampling that accidentally changes the latent label; (d) a hidden \(d+1=3\) lift; (e) wrong normalization between square increments and \(\operatorname{Inf}\); (f) information charge at previously queried coordinates; (g) a theorem that is just an off-model decoder or a lower bound masquerading as a simulator.

A separate exact-rational checker, not the Lean theorem, enumerates 720 heterogeneous Bernoulli-mixture instances of degree-two polynomial targets, including deterministic coordinate laws with probabilities zero and one and tests the resampling/variance transfer including triggered small-coupling regimes. It cannot prove the universal statement. The proof below is authored from the original source definitions; it is NOT independent non-author review.

## 4. Proof: the degree-preserving quadratic-information crux

Fix any finite product mixture \(\nu=\sum_{\theta\in\Theta}w_\theta P_\theta\) with \(I(\Theta;X)<s\). Existence for every \(s>C_W(\nu)\) follows from the finite/general Wyner equality and definition of the infimum.

Take any positive-mass posterior at an ordinary coordinate-query tree node. Let \(\pi_\theta\) be its normalized component weights and let \(g\) be the restricted \(f\), with queried coordinates frozen, so \(\deg(g)\le2\), \(0\le g\le1\), and \(g\) is invariant on all previously queried coordinates \(A_0\). Components are still products on the unqueried coordinates. Suppose the node has posterior variance \(V_\nu(g)>\tau\).

For each coordinate \(j\) put \(Q_j=\sum_\theta\pi_\theta P_{\theta j}\), and let \(Q=\bigotimes_jQ_j\). The finite maximal-star coupling in #970 supplies independent coordinate seeds \(U_j\) and jointly measurable discrete maps \(Y_j=Y_j(U_j)\), \(X_{\theta j}=X_{\theta j}(U_j)\) with \(Y\sim Q\), \(X_\theta\sim P_\theta\), independent seeds across \(j\), and the proper mismatch guarantees. The label \(\Theta\sim\pi\) is sampled independently of all seeds. Set
\[
 \Delta=\mathbb E_{\Theta,U}\bigl(g(X_\Theta)-g(Y)\bigr)^2.
 \tag{1}
\]
Write \(\beta_j(\eta)=\sum_\theta\pi_\theta\mathbf1\{\operatorname{TV}(P_{\theta j},Q_j)>\eta\}\).

**Lemma 4.1, source-exact key lemma.** For \(0<\eta\le1/2\), \(w_0\ge0\), if \(\beta_j(\eta)\le w_0\) for every **unqueried** \(j\notin A_0\), then
\[
 \Delta\le2K w_0+128\cdot2^2\eta=2K w_0+512\eta .
 \tag{2}
\]
This is \(\mathrm{Route1KeyLemma.key\_lemma}\) with \(d=2\) and \(K=2\pi^2\); crucially it is a **squared** comparison and never invokes a degree-three variance inequality.

Choose the fixed thresholds
\[
 a={\tau^2\over32C_2},\quad
 \eta={a\over1024}={\tau^2\over2^{15}C_2},\quad
 w_0={a\over4K}={\tau^2\over2^7C_2K},\quad
 h=\eta^2w_0={\tau^6\over2^{37}C_2^3K}.
 \tag{3}
\]
All are strictly positive and \(\eta<1/2\). If some unqueried \(j\) has \(\beta_j(\eta)>w_0\), then
\[
 I_j:=\sum_\theta\pi_\theta D_{\rm KL}(P_{\theta j}\Vert Q_j)
 \ge\sum_\theta\pi_\theta\operatorname{TV}(P_{\theta j},Q_j)^2
 >\eta^2 w_0=h .
 \tag{4}
\]
That is the information case. Here the KL-vs-TV inequality is the weak nats inequality proved in the Route 1 source; no Pinsker constants are silently strengthened.

Otherwise (2) implies \(\Delta\le a\), since \(2Kw_0=a/2\) and \(512\eta=a/2\).

**Lemma 4.2, variance survival.** For \(0\le g\le1\) and the coupled \(F=g(X_\Theta)\), \(G=g(Y)\),
\[
 |\operatorname{Var}F-\operatorname{Var}G|\le4\sqrt{\Delta}.
 \tag{5}
\]
Indeed \(|\mathbb EF^2-\mathbb EG^2|\le2\mathbb E|F-G|\le2\sqrt\Delta\), and \(|(\mathbb EF)^2-(\mathbb EG)^2|\le2\sqrt\Delta\). Since \(C_2>2\), \(\Delta\le\tau^2/(32C_2)\) gives \(4\sqrt{\Delta}\le\tau/2\). Hence
\[
 \operatorname{Var}_Q(g)>\tau/2.
 \tag{6}
\]
By the **degree-two** Q2 inequality (Q2), some coordinate \(j\) satisfies
\[
 \operatorname{Inf}_{Q,j}(g)>
 {\tau^2\over4C_2}.
 \tag{7}
\]
Since \(g\) is invariant on previously queried coordinates, \(j\notin A_0\).

**Lemma 4.3, original-coordinate influence transfer.** For every \(j\), define \(\bar I_j=\sum_\theta\pi_\theta\operatorname{Inf}_{P_\theta,j}(g)\). Under the coupling in (1),
\[
 \sqrt{\operatorname{Inf}_{Q,j}(g)}
 \le\sqrt{\bar I_j}+\sqrt{2\Delta}.
 \tag{8}
\]
*Proof.* Fix \(\Theta\), hold every seed except \(U_j\) fixed, and replace \(U_j\) by an independent fresh seed \(U'_j\) with the **same latent label**. Denote the paired original/reference words before and after resampling by \((X,Y)\), \((X',Y')\). The triangle inequality in \(L^2\) gives
\[
 \lVert g(Y)-g(Y')\rVert_2\le
 \lVert g(Y)-g(X)\rVert_2+
 \lVert g(X)-g(X')\rVert_2+
 \lVert g(X')-g(Y')\rVert_2.
\]
The outer norms are \(\sqrt\Delta\) each; the middle squared norm is \(2\bar I_j\), the left squared norm is \(2\operatorname{Inf}_{Q,j}(g)\). Divide by \(\sqrt2\). This proves (8), including zero probabilities and all end cases. \(\square\)

From (7) and \(\Delta\le a\le\operatorname{Inf}_{Q,j}(g)/8\), obtain
\[
 \bar I_j\ge\tfrac14\operatorname{Inf}_{Q,j}(g)>
 {\tau^2\over16C_2}.
 \tag{9}
\]
The existing bounded-function inequality \(\mathrm{pincr}\ge2\,\mathrm{pinfl}\) (same original source law and coordinate) shows the posterior-weighted mean absolute increment of \(j\) is at least
\[
 g_a={\tau^2\over8C_2}.
 \tag{10}
\]
Thus each high-variance node offers **either** an unqueried \(j\) with real-component increment at least \(g_a\), **or** an unqueried \(j\) with conditional component information at least
\[
 g_b=h={\tau^6\over 2^{37}C_2^3 K}.
 \tag{11}
\]
This is the new degree-preserving crux. It does **not** follow by substituting Q2 into the old degree-\(d+1\) lift.

## 5. Potential, stopping, and Wyner optimization

Use the **existing** unnormalized Route 1 posterior potentials, not a new source model:
- \(\Phi\): posterior expected sum of component mean absolute increments. The row theorem ensures \(\Phi_{\rm root}\le K\); each original coordinate query \(j\) decreases its expectation exactly by the posterior component increment of \(j\).
- \(\mathrm{Info}\): the remaining component-label mutual information in as-yet-unobserved coordinates; it starts at \(I(\Theta;X)<s\). Its exact query chain rule decreases expected value by \(I_j\) at query \(j\).
Both quantities are nonnegative and satisfy the existing source-exact telescoping identities at all positive-mass nodes. The candidate potential \(\Phi/g_a+\mathrm{Info}/g_b\) decreases in conditional expectation by at least one unit at every active node by (10)–(11). Standard finite-horizon telescoping gives expected number of active queries no more than
\[
 {K\over g_a}+{s\over g_b}
 = {16\pi^2C_2\over\tau^2}
   +{2^{38}\pi^2C_2^3s\over\tau^6}.
 \tag{12}
\]
Stop when posterior variance is at most \(\tau\), returning the posterior conditional mean. Truncate at \(q\) original coordinate queries. Markov on the active-query budget bounds truncation probability by (12)/\(q\). Conditional Chebyshev/Markov bounds the positive-mass stopping-leaf squared error event by \(\tau/\varepsilon^2\). No latent-label observation is made. This proves (QW) at the **paper** level. \(\square\)

## 6. Quantum and physical scope

An actual normalized one-query finite quantum circuit has scalar acceptance degree at most two by the certified circuit polynomial interface, and values in \([0,1]\) by Born normalization. Thus (QW) applies to its **acceptance function** under any finite input law. For the phase-block original-intensity interface certified in merged #1128, where one decoded coordinate can be computed using at most three physical squared-linear readings, composing the degree-two simulator with the already certified tree compiler multiplies its requested depth by at most three on valid source tables. It does NOT prove a general \(T>1\) quadratic theorem: acceptance degree is then at most \(2T\), and an uncontrolled projection to degree two would change the target. It does NOT give a polynomial-time construction, coherent-oracle simulation, or full state approximation.

## 7. Quantitative comparison, including NIGHTFALL's stronger paper comparator

For \(d=2\), the **certified** general Route 1 source uses
\(\gamma=\sqrt{3\tau^5/[12500(\pi^2 3^2)^6]}\),
\(\eta_C=\gamma/(512\cdot 2^2)\), and
\(w_{0,C}=\gamma/(16\cdot2\pi^2)\).
Its query-budget terms scale as \(\tau^{-5/2}\) and \(s\tau^{-15/2}\). The new source-Q2 terms \(\tau^{-2}\) and \(s\tau^{-6}\) strictly improve these exponents and, e.g., their exact numerical coefficients at \(\tau=1/10\).

However, NIGHTFALL's PR #939 is an **existing paper-level** alternative using a mean-absolute-increment theorem on the *degree-three lift*, with expected-query coefficients
\[
48\pi^4d^2(d+1)^4\tau^{-3/2}
+ (525.6\pi^4)^3d^6(d+1)^{12}\tau^{-9/2}\log M
\tag{13}
\]
at \(d=2\). For the finite-component version it has better *small-\(\tau\)* powers, and its information budget is \(\log M\), not the general-latent \(C_W\) form established here. At \(\tau=0.1\), the new QW coefficients are about 0.035 and 0.022 of (13)'s seed and information coefficients respectively if the latter information charge is replaced by the same numerical scalar; for \(\tau=0.001\) the paper #939 information exponent dominates. These are **coefficient comparisons only**, not a proved uniform dominance of one model or bound: \(\log M\) and \(C_W\) differ and #939 does not have a new full source-matched Lean terminal. A stronger eventual unified result should take a certified envelope, not erase this competitor.

## 8. Dated prior-art screen (22 November 2026)

| External source | Earlier contribution / relevance | What it does NOT establish from the accessible abstract or discussion |
| --- | --- | --- |
| Aaronson–Ambainis, *Forrelation: A Problem that Optimally Separates Quantum from Classical Computing?* and *The Need for Structure in Quantum Speedups*, Theory of Computing 2014, https://www.theoryofcomputing.org/articles/v010a006/ | Influence-to-classical simulation and oracle-polynomial method | Not a finite-law general-Wyner, quadratic-source coupling theorem of form (QW) |
| Turturean, *A proof of the Aaronson–Ambainis conjecture*, arXiv:2611.09773 (6 Nov 2026), https://arxiv.org/abs/2611.09773 | Landmark all-degree Boolean-cube influence and the source row/increment machinery | No exact original heterogeneous-law Q2/Wyner statement established from available source; the cube and structural lemmas must be credited |
| Girish–Mittal–Nehoran–Raz, *Distributional Variants of the Aaronson–Ambainis Conjecture*, arXiv:2609.35327 (28 Sep 2026), https://arxiv.org/abs/2609.35327 | Biased products, slice, equivalences to uniform cube, distributional AA | No source-exact arbitrary correlated-mixture \(C_W\) upper bound located |
| Huffstutler–Miloschewsky–Podder, *A short proof ... via the completion framework*, arXiv:2611.12795 (9 Nov 2026), https://arxiv.org/abs/2611.12795 | Strong uniform-cube classical simulator and completion/adversary mechanism | Does not by its abstract imply an all-finite-alphabet correlated-Wyner bound |
| O'Donnell–Saks–Schramm–Servedio, *Every decision tree has an influential variable*, 2005, https://arxiv.org/abs/cs/0508071 | Product-law influence/revealment inequalities; historical decision-tree precedent | Different premise: decision tree already computing a function, not QW's fixed-degree correlated-source simulator |
| Moakahr–Ghahremani–Banihashem–Hajiaghayi, *Decision Tree Learning on Product Spaces*, arXiv:2605.12983 (13 May 2026), https://arxiv.org/abs/2605.12983 | Influential-coordinate greedy learning on product spaces | Learning model and sample/target assumptions need same-theorem comparison; no Wyner-cost bound identified |
| Bruno–Vaccaro, *Wyner's Common Information and the Common Entropy are NP-Hard to Compute*, arXiv:2610.15402 (11 Oct 2026), https://arxiv.org/abs/2610.15402 | Structural information and support rectangles; underscores that \(C_W\) is not presumed cheaply computable | Does not supply QW's oracle-query simulator |
| O'Donnell et al., *Agnostic Learning Under Product Distributions*, https://www.cs.cmu.edu/~odonnell/papers/product-dists.pdf | Earlier generic learning reduction for mixtures of product distributions | Not interchangeable with distributional evaluation of arbitrary bounded low-degree acceptance functions and exact \(C_W\) charge |
| Wyner (1975), *The Common Information of Two Dependent Random Variables* | Definition and information-theoretic antecedent | No claim of novelty for common information itself |

**Search verdict:** A dated targeted source/abstract/title search did **not** locate an exact published theorem of type (QW). This is **not** exhaustive priority clearance. In particular, any current same-model result buried in the above proofs, and earlier unpublished deposits (including #749's inaccessible Bhattacharjee report), require careful theorem-statement comparison before originality promotion. The word “strongest” is not warranted on this evidence.

## 9. Exact audit, scope certificate, and next independent action

**Proven inputs already on main:** #776 Q2 original-product bound; #970/#976 finite/general-latent Route 1 and original-source coupling, entropy chain, row bound; #1128 physical finite quantum terminal. **New author paper result:** Lemmas 4.2–4.3, degree-preserving crux, and theorem (QW). **New finite numerical evidence:** separate exact-rational checker (720 finite cases, no floating arithmetic; SHA256 execution receipt in PR). **Not done:** Lean statement/terminal compilation of QW; non-author analytic proof verification; external same-theorem prior-art audit; optimized constants; rigorous direct comparison with #939 in its own source-law normalization.

**Independent-engine B checklist:** independently construct a coupling and prove (8) without using this manuscript; inspect the source definition of \(\mathrm{pinfl}\) vs original Q2 conditional variance and factor 2; test posterior atoms of mass zero; verify \(C_W\) units are natural logs; find a genuine \(d=2\) counterexample to the proposed interface or close all finite source predicates; compare the strongest known mean-increment route on the **same** \(s,\tau,\varepsilon,\delta\) parameters.

**Lean bridge order (do not fake terminal status):**
1. Show \(\mathrm{HasProdDegreeLE}(g,2)\) implies \(\mathrm{NativeSupportedDegreeTwo}\) on the posterior-product support, and show \(\mathrm{pinfl}\) equals the terminal's original-source influence.
2. Formalize a finite seeded coupling-with-resampling lemma proving (8) at all zero-mass boundary cases.
3. Prove the variance comparison (5), specialize Q2 on \(Q=\otimes q_j\), and obtain the new crux (10)–(11) with exact symbolic constants.
4. Reuse the existing Route 1 Info/Phi stopping potential by a genuinely checked alternative crux to derive (QW), then add strict pinned source/axiom/leanchecker/CI receipts.

**Authorship/credit:** NIGHTFALL research collaboration under Devin J. Wright; original Q2 contributor chain #587–#776, original Route 1 Claude-led chain #928/#970/#976, and physical oracle contributors #1084/#1118/#1128. Public pioneers identified above must be credited. No publication, public claim-status promotion, or scientific priority representation is authorized by this manuscript.

## 10. Exact same-model comparison with PR #939 (revision 0.2)

**Parameter equalization.** Both candidates concern a known *finite-alphabet* law \(\nu\), bounded scalar degree \(d=2\), original-coordinate queries, variance stopping threshold \(0<\tau\le 1/4\), and error term \(\tau/\varepsilon^2\). The information budget is **\(s>C_W(\nu)\) in nats**. In #939 as originally written the charge is \(\ln M\) for a supplied \(M\)-component product mixture. To compare on the same law/parameter, retain #939's mean-increment/key-lemma paper crux but replace its entropy potential with the already certified **remaining-information potential** of #970, so the tree pays \(I(\Theta;X)<s\) rather than \(H(\Theta)\le\ln M\). This is an **author-side corollary only**: #939's optimized mean-increment crux is not an end-to-end Lean terminal, and this Wyner-normalized #939 corollary must still be reviewed. The finite star-coupling source in merged #970 makes its seed coordinates finite in the finite-mixture setting, removing the infinite-seed discretization caveat from #939; its optimized constants still require independent review.

**Comparable information-and-seed budget forms** (each is divided by query cutoff \(q\), then \(\tau/\varepsilon^2\) is added):
\[
 \begin{aligned}
 S_{QW}(\tau,s)&=
     A_Q\tau^{-2}+B_Qs\tau^{-6},&
 A_Q&=16\pi^2C_2,&B_Q&=2^{38}\pi^2C_2^3,\\
 S_{939}(\tau,s)&=
     A_{939}\tau^{-3/2}+B_{939}s\tau^{-9/2},&
 A_{939}&=48\pi^4(2^2)(3^4),&
 B_{939}&=(525.6\pi^4)^3(2^6)(3^{12}).
 \end{aligned}
\]
Decimal evaluation (70-digit Python Decimal, **not a verified real interval proof**):
\[
 \begin{array}{c|c|c}
 \tau & A_Q\tau^{-2}/(A_{939}\tau^{-3/2})
       & B_Q\tau^{-6}/(B_{939}\tau^{-9/2})\\
 0.25&0.02197716&0.00556997\\
 0.1&0.03474894&0.02201722\\
 0.01&0.10988578&0.69624577\\
 0.005&0.15540197&1.96928043\\
 0.001&0.34748936&22.01722450\\
 0.0001&1.09885784&696.24577190
 \end{array}
\]
Exact symbolic coefficient crossovers:
\[
 \tau_{\mathrm{seed}}=(A_Q/A_{939})^2\approx0.000120748855,\qquad
 \tau_{\mathrm{info}}=(B_Q/B_{939})^{2/3}\approx0.007855521964.
\]
For \(\tau\ge\tau_{\mathrm{info}}\), QW is termwise no worse for **every** nonnegative \(s\). Between the crossovers, QW's seed term is smaller but #939's information term is smaller; winner depends on \(s\). At \(\tau=0.001\), for example, QW wins only for \(0\le s\lesssim 1.03\times10^{-26}\) nats under these unoptimized constants. Below \(\tau_{\mathrm{seed}}\), #939 dominates both terms. **Neither theorem dominates globally.**

The correct **paper-level joint envelope** is to choose the smaller of \(S_{QW}\) and \(S_{939}\). Comparing upper-bound coefficients does not produce a lower bound on optimal quantum/classical query complexity. The reproducible decimal comparator is check_qw_vs_939_same_model.py.

**Open formal gates:** QuadraticWynerTransferCore.lean attempts to prove the finite weighted-resampling factor-four transfer; QuadraticWynerParametric.lean extracts the general remaining-information tree conditional on an explicit original-source good-query certificate. They must be replayed on their exact source heads. Even if both pass, they do **not** discharge the source-specific Q2/coupling-information crux. Still required: source-level Q2 degree/normalization identification, actual posterior-coupling resampling equality and variance-stability inequality, and the genuine good-query disjunction on every positive-mass posterior. Do not hide the crux inside hypotheses of a supposedly unconditional theorem.


## 11. Rational interval certificate for a uniform source-matched regime

Beyond decimal checks, the file check_qw_939_rational_dominance.py proves a strictly **arithmetic** coefficient comparison using Python exact Fraction, given the elementary analytic bound \(49/5<\pi^2<10\) and rational square-root bounds that imply \(105<C_2<106\).

For **every** \(1/100\le\tau\le1/4\) and **every** \(s\ge0\),
\[
 S_{QW}(\tau,s)<S_{939}(\tau,s).
\]
Proof: \(A_Q<16(10)(106)\), \(A_{939}>48(49/5)^2(2^2)(3^4)\), and exact rational arithmetic proves \(10[16(10)(106)]<48(49/5)^2(2^2)(3^4)\). Since \(\tau^{-1/2}\le10\), the QW seed term is strictly smaller. Likewise \(B_Q<2^{38}(10)(106)^3\), \(B_{939}>(525.6(49/5)^2)^3(2^6)(3^{12})\), and the checker verifies \(1000[2^{38}(10)(106)^3]<(525.6(49/5)^2)^3(2^6)(3^{12})\); since \(\tau^{-3/2}\le1000\), QW's information term is smaller for \(s>0\) and tied at \(s=0\). The total still wins strictly by its seed term.

**Scope:** This is an exact rational implication after accepted elementary \(\pi\)-bounds. It does not independently prove (QW), the Wyner-normalized #939 paper corollary, an optimal query-complexity separation, or any Lean theorem. It strengthens evidence for the **comparison only**. At smaller \(\tau\), neither candidate dominates uniformly (§10).
