# Paper B — Spectral Adaptive Prediction on Heterogeneous Product Spaces

**Devin J. Wright · NIGHTFALL Constellation · public research manuscript v1.0 · 11 November 2026**

**Status:** Author-side analytic manuscript for external proof review; **not** an end-to-end Lean-certified theorem, non-author referee acceptance, worldwide priority determination, or computationally efficient algorithm. The explicitly identified *finite scalar* foundation is kernel checked separately. This manuscript is a coherent publication-facing version of the existing principal observability argument, not an independent newly certified claim.

## Abstract

An observable may depend on arbitrarily many independent inputs of unrelated, possibly nonatomic laws while having bounded Hoeffding interaction degree. We establish an analytic quantitative route from a finite categorical scalar influence theorem to adaptive prediction of bounded Hilbert-valued observables. The key inequality converts scalar sensitivity into coordinate trace influence through a positive-semidefinite Rademacher exponential moment bound:
\[
k v^{5/2}\le 4m\log\left(1+(\sqrt 2-1)\frac{p}{m}\right),\qquad
k=\frac{c_*}{d^6B^3r^{3/2}},
\]
where \(v\) is projected Hilbert variance, \(p\) total projected influence, \(m\) maximum coordinate trace influence, and \(r\) output rank. A rigorous actual-posterior total-influence identity, a perspective-function Jensen step and a capped concave potential then yield dimension- and alphabet-independent prediction error at most spectral tail plus \(\eta\), after an explicit logarithmic query budget. In the disjoint-output-group regime, a complementary scalar allocation argument improves rank scaling to *linear* with no logarithm. We distinguish this unconditional-to-the-scoped-finite-base argument from the separate unrefereed quadratic exponent-two proposal, whose optimal \(r/\eta\) regime requires additional assumptions.

## 1. Problem, definitions and main theorems

Let \(I\) be any index set, \((\Omega_i,\mathcal A_i,\mu_i)\) arbitrary independent probability spaces, and \(H\) a real Hilbert space. Let \(F:\prod_{i\in I}\Omega_i\to H\) be **strongly measurable**, \(\|F\|\le B\) almost surely, \(B>0\), and have Hoeffding interaction degree at most \(d\ge1\) in \(L^2\). As with scalar products, strong measurability gives countably many effective coordinates and an essentially separable output range.

Let \(C_F=\mathbb E[(F-\mathbb EF)\otimes(F-\mathbb EF)]\) be the trace-class output covariance; write \(\lambda_1\ge\lambda_2\ge\cdots\ge0\) for its eigenvalues, and
\[
\tau_r=\operatorname{tr}C_F-\sum_{j=1}^{r}\lambda_j,\quad
c_*=\frac{\sqrt{3/12500}}{\pi^6},\quad
U=\frac{d^7B^3r^{3/2}}{c_*\eta^{3/2}}.
\]

**Theorem B1 (Hilbert spectral adaptive prediction; analytic composition).** For every \(r\ge1\) and \(\eta>0\), there exists a deterministic measurable adaptive policy, observing at most
\[
\boxed{N_{\mathrm{log}}=
\left\lceil\frac{40}{3}U\log(1+4U)\right\rceil}
\tag{B1}
\]
distinct whole input coordinates, such that the conditional-mean predictor \(\widehat F\) obeys
\[
\boxed{\mathbb E\|F-\widehat F\|^2\le\tau_r+\eta.}
\tag{B2}
\]
These are *observation* bounds, not runtime bounds. The bound is independent of the number of coordinates, the cardinalities of their alphabets and their smallest positive atom masses. Its analytic derivation imports only the specified finite scalar influence theorem (Section 2) and standard product probability/PSD tools; it does not require the unresolved degree-three or arbitrary-law quadratic exponent-two conjecture.

**Theorem B2 (Hilbert-valued spectral-tail influence inequality).** If \(G\) takes values in an \(r\)-dimensional Hilbert subspace, \(\|G\|\le B\), and has interaction degree at most \(d\), put
\[
v=\mathbb E\|G-\mathbb EG\|^2,\quad
A_i=\mathbb E[(G-\mathbb E_iG)\otimes(G-\mathbb E_iG)]\succeq0,
\]
\[
p=\sum_i\operatorname{tr}A_i,\qquad
m=\sup_i\operatorname{tr}A_i,\qquad
k=c_*B^{-3}d^{-6}r^{-3/2}.
\]
Then \(v\le p\le dv\), and, when \(v>0\),
\[
\boxed{k v^{5/2}\le4m\log(1+(\sqrt2-1)p/m),\qquad
m\ge\frac{k v^{5/2}}{8\log(1+4p/(kv^{5/2}))}.}
\tag{B3}
\]
For general \(F\), apply this inequality to the leading covariance projection \(G=P_rF\); the orthogonal residual contributes at most \(\tau_r\) to the final risk.

**Theorem B3 (rank-linear disjoint-output regime).** Suppose the rank-\(r\) target has orthogonal scalar output components \(G=(g_1(X_{J_1}),\ldots,g_r(X_{J_r}))\) with pairwise disjoint independent input groups \(J_j\), common interaction-degree cap \(d\), and \(\|G\|\le B\) almost surely. Then for each \(\eta>0\) there is a measurable policy achieving projected MSE at most \(\eta\) in
\[
\boxed{N_{\mathrm{disjoint}}\le
r+\frac{5d^7B^3}{3c_*\eta^{3/2}}\,r.}
\tag{B4}
\]
An additional fixed orthogonal output residual with covariance trace \(\tau_r\) gives total risk at most \(\tau_r+\eta\). **This linear-rank guarantee uses disjoint output-input groups; it is not asserted for general overlapping-output functions.**

**Scalar corollary.** For real \(|f|\le B\), \(r=1\) is handled directly without the sign compression or logarithm:
\[
N_{\mathrm{scalar}}\le
\left\lceil\frac{5d^7B^3}{3c_*\eta^{3/2}}\right\rceil.
\tag{B5}
\]

## 2. Exactly pinned finite scalar Lean foundation

The source theorem is the named Lean declaration **Nightfall.ProductSpace.Influence.product_influence**, pinned to commit
**e67990dfc252b6ef9446c7b7c1a9ebf06e5c58eb** and [successful Actions run 42929857470](https://github.com/d3lefts/d3lefts/actions/runs/42929857470), with Lean **4.33.0** and the specified Mathlib pin. The finite coordinate type uses a common finite alphabet type with **coordinate-dependent** normalized nonnegative probability tables, including zero-mass symbols, and bounded indicator-product polynomial degree at most \(d\). It certifies the precise consequence
\[
3\,\mathrm{Var}(h)^5\le12500(\pi^2d^2)^6 I_j(h)^2
\]
for some coordinate \(j\), in its documented normalization. Equivalently, after scalar scaling to \(|h|\le A\),
\[
\sup_i I_i(h)\ge c_*A^{-3}d^{-6}\mathrm{Var}(h)^{5/2},
\qquad I_i(h)=\mathbb E|h-\mathbb E_i h|^2.
\tag{2.1}
\]

**Certification boundary.** Only the finite scalar declaration and its imported conditions are Lean kernel-checked. The categorical embedding, general measurable-product passage, Hilbert PSD estimate, posterior policy and covariance tail below are written analytic proof steps. The inherited cube proof and methodology are due to **David Turturean**, *A proof of the Aaronson–Ambainis conjecture* (6 November 2026), https://arxiv.org/abs/2611.09773; original Aaronson–Ambainis query formulation is credited, not re-proved here.

### 2.1 Finite categorical and arbitrary-product lift

Any finite heterogeneous collection of finite alphabets embeds in their common disjoint union. Invalid symbols at coordinate \(i\) are retracted to a fixed legal symbol, preserving boundedness and indicator-product degree. A finite Hoeffding-degree-\(d\) function is an indicator-product polynomial of degree at most \(d\), by expanding each finite-support component into coordinate value indicators. Thus (2.1) applies to all finite heterogeneous product laws, not only uniform signs.

For a bounded scalar \(h\) on an arbitrary completed independent product, take an uncompleted measurable version and a countable active coordinate support. Approximate it by a sequence \(h_n=\mathbb E[h\mid\mathcal P_n]\) of finite rectangular finite-partition conditional expectations, with \(\mathcal P_n\) increasing to the effective sigma field. Standard product martingale convergence gives \(h_n\to h\) in \(L^2\), \(|h_n|\le A\), and \(\mathrm{Var}(h_n)\to\mathrm{Var}(h)\). Commuting coordinate averaging with the rectangular product projection preserves degree at most \(d\). Since conditional projections contract \(L^2\), every coordinate satisfies \(I_i(h_n)\le I_i(h)\) (coordinates not used in the partition have influence zero). Apply (2.1) to each \(h_n\) and pass to the limit to obtain **exactly the same** scalar constant for arbitrary independent inputs. This analytic measure-theoretic step is not supplied by the finite Lean theorem.

## 3. Proof of the Hilbert trace influence inequality

Assume first that \(G\) has rank at most \(r\), projected covariance variance \(v>0\), and \(\|G\|\le B\). Choose a covariance eigenbasis of its range. For every \(\varepsilon\in\{-1,1\}^r\), define
\[
h_\varepsilon=\langle\varepsilon,G\rangle .
\]
Diagonal covariance gives \(\mathrm{Var}(h_\varepsilon)=v\) **for every sign vector**, not merely on average. Moreover \(|h_\varepsilon|\le\sqrt r B\), and \(I_i(h_\varepsilon)=\varepsilon^\top A_i\varepsilon\). Applying (2.1) yields
\[
\sup_i\varepsilon^\top A_i\varepsilon\ge L:=kv^{5/2}
\quad\text{for all }\varepsilon .
\tag{3.1}
\]

**PSD sign-moment lemma.** If \(A\succeq0\) is \(r\times r\) with \(s=\operatorname{tr}A>0\), Gaussian linearization with \(Z\sim N(0,A)\) yields
\[
\begin{aligned}
\mathbb E_\varepsilon\exp(\varepsilon^\top A\varepsilon/(4s))
&=\mathbb E_Z\prod_j\cosh(Z_j/\sqrt{2s})\\
&\le \mathbb E_Z\exp(\|Z\|^2/(4s))\\
&=\det(I-A/(2s))^{-1/2}\le\sqrt2.
\end{aligned}
\tag{3.2}
\]
The last inequality follows from \(\prod_j(1-\lambda_j/(2s))\ge1-\sum_j\lambda_j/(2s)=1/2\); the argument allows singular matrices.

Let \(s_i=\operatorname{tr}A_i\le m\). The exponential chord inequality and (3.2) give
\[
\mathbb E_\varepsilon[e^{\varepsilon^\top A_i\varepsilon/(4m)}-1]
\le(\sqrt2-1)s_i/m.
\]
All quadratic forms are nonnegative; therefore
\[
e^{\sup_i\varepsilon^\top A_i\varepsilon/(4m)}-1
\le\sum_i(e^{\varepsilon^\top A_i\varepsilon/(4m)}-1).
\]
For a countably active product use monotone convergence. Taking expectations and using (3.1) and Jensen gives
\[
e^{L/(4m)}-1\le(\sqrt2-1)p/m,
\]
which proves the first part of (B3).

For the explicit inversion let \(t=L/(4m)\), \(y=4p/L\) and \(a=\sqrt2-1<1/2\). Then \(e^t-1\le ayt\). Since \((e^t-1)/t\) increases strictly on \((0,\infty)\), and at \(t_0=2\log(1+y)\) one has
\[
e^{t_0}-1=y(2+y)>2ay\log(1+y)=ayt_0,
\]
it follows that \(t<t_0\). Hence \(m\ge L/[8\log(1+4p/L)]\). Finally \(v\le p\le dv\) is the classical degree-\(d\) ANOVA total-influence sandwich. This proves B2. \(\square\)

**Measurability point.** The covariance eigenbasis is used only as an existential device for the basis-invariant trace inequality. The adaptive policy below selects on coordinate **trace influence**, not on a chosen measurable posterior eigenbasis.

## 4. Actual posterior potential and deterministic hard cap

After \(t\) adaptive whole-coordinate observations, the unqueried coordinates retain their original independent product law, conditional on the transcript. By countable-support reduction and Fubini, posterior sections remain degree at most \(d\) and bounded by \(B\), almost surely. The first maximal posterior coordinate influence exists: a countable nonnegative summable sequence attains its positive supremum, with deterministic fixed-order tie breaking. Fubini makes each influence measurable in the revealed symbols, and countably many index choices make the policy measurable.

For the residual product function at a transcript \(\omega\), denote \(v(\omega)\) its variance, \(p(\omega)=T(G_\omega)=\sum_i I_i(G_\omega)\) its total ANOVA influence, and \(m(\omega)=\max_i I_i(G_\omega)\). Define expected quantities
\[
V_t=\mathbb E\,v(\omega),\qquad P_t=\mathbb E\,p(\omega),\qquad M_t=\mathbb E\,m(\omega).
\]
Then \(V_t\le P_t\le dV_t\). For any unqueried \(i\), the **exact** Hoeffding identity is
\[
\mathbb E_{X_i}T(G_\omega\mid X_i)=T(G_\omega)-I_i(G_\omega),
\tag{4.1}
\]
proved by tracking each Hoeffding set \(S\): observing \(i\in S\) removes exactly one unit of degree weight from that component's expected energy. It is *not* true with \(T\) replaced by output variance. Querying the maximizer gives
\[
\boxed{P_{t+1}=P_t-M_t.}
\tag{4.2}
\]

The per-transcript inequality (B3) implies \(kv(\omega)^{5/2}\le4m(\omega)\log(1+a p(\omega)/m(\omega))\), where \(a=\sqrt2-1\). Since \(x\mapsto x^{5/2}\) is convex and \((m,p)\mapsto m\log(1+ap/m)\) is jointly concave (perspective of the concave logarithm), Jensen gives the **correct placement of posterior expectations**:
\[
kV_t^{5/2}\le4M_t\log(1+aP_t/M_t).
\tag{4.3}
\]
The inversion in Section 3 now yields
\[
M_t\ge\frac{kV_t^{5/2}}{8\log(1+4P_t/(kV_t^{5/2}))}.
\tag{4.4}
\]
Thus no interchange of expected maximum with maximum expected influence is required.

For \(V_t>\eta\), use \(P_t\le dV_t\) and put
\[
U=\frac{d}{k\eta^{3/2}},\qquad H_0=\log(1+4U).
\]
Then \(M_t\ge kV_t^{5/2}/(8H_0)\). Introduce the increasing concave capped potential
\[
\Phi(z)=\frac{8H_0}{k}\int_0^z\max\{\eta,s/d\}^{-5/2}\,ds .
\tag{4.5}
\]
By concavity, (4.2) and \(P_t/d\le V_t\), while \(V_t>\eta\),
\[
\Phi(P_t)-\Phi(P_{t+1})
\ge\Phi'(P_t)M_t\ge1.
\tag{4.6}
\]
The finite total available potential is exactly
\[
\Phi(\infty)=\frac{8H_0}{k}
\left[d\eta^{-3/2}+\frac{2d}{3}\eta^{-3/2}\right]
=\frac{40}{3}U\log(1+4U).
\tag{4.7}
\]
If \(V_N>\eta\) at \(N=\lceil\Phi(\infty)\rceil\), monotonicity of expected posterior risk forces the unit decrease (4.6) for all earlier steps, hence \(N\le\Phi(P_0)-\Phi(P_N)<\Phi(\infty)\le N\), contradiction. Therefore \(V_N\le\eta\) with a deterministic hard query cap.

For scalar \(f\), (2.1) directly gives \(M_t\ge k_0V_t^{5/2}\), \(k_0=c_*d^{-6}B^{-3}\). Omitting the sign/log machinery in (4.5) bounds total potential by \(5d/(3k_0\eta^{3/2})\), proving (B5).

## 5. Spectral truncation and the full Hilbert risk

Take the fixed projection \(P_r\) onto leading covariance eigenvectors of \(F\), let \(G=P_rF\) and \(R_F=(I-P_r)F\). The projected function remains bounded by \(B\), has degree at most \(d\), and takes values in rank at most \(r\). Run the policy of Section 4 on \(G\), but predict the *full* \(F\) by its conditional mean. Orthogonality of output ranges and conditional-expectation contraction give
\[
\begin{aligned}
\mathbb E\|F-\mathbb E[F\mid\mathcal T_N]\|^2
&=\mathbb E\|G-\mathbb E[G\mid\mathcal T_N]\|^2\\
&\quad+\mathbb E\|R_F-\mathbb E[R_F\mid\mathcal T_N]\|^2\\
&\le\eta+\mathrm{Var}(R_F)=\eta+\tau_r .
\end{aligned}
\]
This proves (B1)–(B2), analytically from the finite scalar premise. \(\square\)

## 6. A different regime: rank-linear bounds for disjoint output groups

Let \(g_j\) depend only on \(J_j\), with pairwise disjoint \(J_j\), and \(b_j=\mathrm{ess\,sup}|g_j|\). Independence implies \(\sum_{j=1}^r b_j^2\le B^2\): for any \(\epsilon>0\), all finitely many independent near-supremum events can occur jointly with positive probability, and \(\|G\|\le B\) there.

For each \(j\) separately use the scalar bound (B5) to attain MSE \(\eta_j\). Choose
\[
S=\sum_j b_j^{6/5},\qquad \eta_j=\eta b_j^{6/5}/S
\]
over the nonzero components. The unrounded cost is
\[
\frac{5d^7}{3c_*}\sum_j b_j^3\eta_j^{-3/2}
=\frac{5d^7}{3c_*\eta^{3/2}}S^{5/2}.
\]
Hölder gives \(S^{5/2}\le r(\sum_j b_j^2)^{3/2}\le rB^3\), and integer ceilings contribute at most \(r\). Observing disjoint groups for their individual policies yields total error \(\sum_j\eta_j=\eta\), proving (B4).

**Interpretation.** The general PSD logarithmic transfer costs \(O(d^7B^3r^{3/2}\eta^{-3/2}\log(1+d^7B^3r^{3/2}\eta^{-3/2}))\). The disjoint-group theorem costs \(O(r+d^7B^3r\eta^{-3/2})\). The latter has better rank growth but strictly narrower structural hypotheses. One cannot replace the former by the latter for overlapping output groups merely because the covariance is diagonal.

The distinct *degree-two* scalar candidate \(\mathrm{Var}(g)\le16(1+\sqrt3)B\sqrt{\sup_i I_i(g)}\), if independently established in its required arbitrary-law scope and lifted with a valid vector argument, yields a faster \(\Theta(r/\eta)\) rank-\(r\) regime for bounded quadratic observables; see the original principal theorem. **That stronger exponent-two comparison is an unrefereed separate premise, not a consequence of the present finite \((5/2,6)\) Lean theorem.** The additive fair-sign example from the principal source supplies a matching \(r/\eta\) *lower* scaling for that model; it is not a general matching lower bound for (B1).

## 7. Independent audit ledger and falsification gates

The completed analytic chain is: *finite categorical scalar influence* → *finite-to-measurable product lift* → *signed scalar covariance trace* → *PSD sign-moment and logarithmic inversion* → *actual posterior identity (4.2)* → *perspective Jensen* → *capped potential* → *fixed spectral projection*. Its imported source theorem has an exact Lean pin; every subsequent arrow is a written analytic proof, **not** end-to-end kernel compilation.

Reproducible finite falsifiers are committed as [posterior/Hilbert exact Fraction checker](../universal-observability/checks/check_posterior_hilbert_exact.py) and [PSD/log stress checker](../universal-observability/checks/check_psd_log_stress.py). The source [chain audit](../universal-observability/CHAIN_AUDIT_v1.md) records the tested cases and receipt boundaries. Re-run the checkers; do not treat finite pass counts as a proof of the general measurable theorem. The [full author-side analytic supplement](../universal-observability/PROOF_SUPPLEMENT_v1.md) supplies additional null-atom, section-measurability and limit arguments.

An independent non-author referee should specifically attack (i) finite partition degree preservation and completed-product countable support, (ii) every coefficient in the PSD exponential moment and inversion, including singular PSD cases, (iii) conditional Fubini and measurable greedy index selection under arbitrary alphabets, (iv) the *expected* total-influence identity and Jensen perspective, and (v) output tail decomposition and deterministic stopping. A counterexample requires demoting dependent claims.

## 8. Credit, prior art and provenance

**Inherited:** Aaronson–Ambainis, *The Need for Structure in Quantum Speedups*, *Theory of Computing* 10 (2014), https://www.theoryofcomputing.org/articles/v010a006/; **David Turturean**, *A proof of the Aaronson–Ambainis conjecture* (6 Nov 2026), https://arxiv.org/abs/2611.09773; classical Hoeffding/Efron–Stein orthogonal decompositions and influence identities; Rademacher/Gaussian quadratic-moment machinery; **Blanc, Docter, Strassle and Tan**, *Proof of the Aaronson–Ambainis Conjecture: An Exposition* (8 Nov 2026), https://arxiv.org/abs/2611.11626; **Huffstutler, Miloschewsky and Podder**, *A short proof ... via the completion framework* (9 Nov 2026), https://arxiv.org/abs/2611.12795. Broader product-space influence antecedent: **Grimmett, Janson and Norris**, *Influence in product spaces*, *Adv. Appl. Probab.* (2016). These sources do not, by themselves, certify priority for the current Hilbert observation claim.

**NIGHTFALL original research record:** [principal full-chain statement](../../research/nightfall/2026-11-principal-observability/PRINCIPAL_THEOREM.md); [finite Lean proof passport](../../research/nightfall/formalization/product_space/FINITE_PRODUCT_INFLUENCE_PROOF_PASSPORT_20261110.md); [scoped claim registry](../../research/catalogue/CLAIMS.json); [dated targeted prior-art comparison](../universal-observability/PRIOR_ART_CHECK_20261111.md). The lead is Devin J. Wright with AI-assisted NIGHTFALL analysis. Validity, source completeness, reproducibility, novelty, independent review, and journal publication are separate certification gates.
