# COST III: Operational Hypergraph Universality, Noisy Quantum Recovery, and Computational Complexity

**NIGHTFALL research note — 11 November 2026 — working analytic proof, v0.3**  
**Status:** New synthesis and proof in this conversation. The quantum-ANOVA ingredient is already present in the NIGHTFALL repository and draws on established Personick/quantum-conditional-expectation methods. The positive-hypergraph representation is an established combinatorial notion. **No end-to-end Lean check, external referee, or novelty certification is claimed.** Scope: finite-dimensional, one physical copy, fixed-subset access, scalar squared-error loss unless explicitly extended.

## Abstract

We establish a representation--realization--complexity correspondence for operational quantum observation. For a finite classical--quantum ensemble of possibly entangled multipartite states whose unconditional average quantum state is a faithful product, the optimal one-copy scalar Bayesian squared-error gain obtained from any subset of registers decomposes into a positive hypergraph of interaction supports. Under a physical local replacement-noise channel, an order-\(r\) contribution is attenuated exactly by \(t^{2r}\). Conversely, *every* nonnegative weighted hypergraph is exactly realizable with independent fair classical signs encoded into the *same fixed pair of full-rank, noncommuting qubit states* at every site. We obtain an exact computational threshold: singleton-only sensor selection is solved by sorting; allowing pairwise interactions makes the explicitly encoded cardinality-selection decision problem NP-complete, by a rational \(1/80\) clique gadget; bounded primal treewidth restores exact polynomial-time optimization for fixed width. The optimal sensor sets vary with noise only at finitely many algebraic transition points. For complex-valued targets, the sum of the real and imaginary operational spectra sandwiches the physically attainable joint gain within a sharp factor two, reflecting measurement incompatibility. This is a unified classification within a specified observation model, not an adaptive quantum-query theorem.

## 1. Exact model

Fix \(n\) finite-dimensional register spaces \(\mathcal H_i\) and a finite label space \(\mathsf X\) with arbitrary prior \(p_x\). No product prior is needed. Let \(\rho_x\) be density matrices on \(\mathcal H=\bigotimes_{i=1}^n\mathcal H_i\). Individual \(\rho_x\) may be entangled or noncommuting. Require only

\[
B=\sum_x p_x\rho_x=\bigotimes_{i=1}^n b_i\succ0,\qquad \operatorname{Tr}b_i=1.
\]

For a real target \(f(x)\) subtract its mean, so \(\mathbb Ef=0\). Let \(A=\sum_xp_x f(x)\rho_x\) be its Hermitian *signal*; \(\operatorname{Tr}A=0\). Define the Jordan/Personick operator \(J_B(L)=(BL+LB)/2\) and its uniquely defined Hermitian score \(L=J_B^{-1}(A)\).

For \(Q\subseteq[n]\), observe only \(Q\)'s subsystem and permit any collective POVM on \(\mathcal H_Q\) with any scalar-valued estimator. Its optimal MSE is \(R^*(f;Q)\); its Bayes gain is \(G(Q)=\mathbb E f^2-R^*(f;Q)\).

For each coordinate define a physical local replacement channel (acting on the entire multipartite density operator)

\[
\mathscr D_{i,t}(Y)=tY+(1-t)(b_i\otimes \operatorname{Tr}_iY),\quad 0\le t\le1.
\]

Tensor-slot order is understood. The channels commute, are CPTP, and fix the product average state \(B\). Put \(\rho_x(t)=\mathscr D_{1,t}\cdots\mathscr D_{n,t}(\rho_x)\) and denote by \(G_t(Q)\) the corresponding optimal gain. This noise model is essential to the exact monomial law; it does **not** assert identical behavior for all noise channels.

## 2. The master operational spectrum

On the real vector space of Hermitian observables define \(\langle U,V\rangle_B=\operatorname{Tr}[U J_B(V)]\), which is a positive definite real Hilbert inner product because \(B\succ0\). For \(Q\subseteq[n]\), define the weighted conditional expectation \(P_Q\) onto the observables supported on \(Q\) (identities on \(Q^c\)); equivalently, it is the composition of the one-site maps \(E_i\), \(i\notin Q\), where

\[
E_i(U)=I_i\otimes\operatorname{Tr}_i[(b_i\otimes I_{-i})U].
\]

These are mutually commuting orthogonal projections for the \(B\)-inner product. Thus \(P_QP_R=P_{Q\cap R}\) and \(P_{[n]}=I\). Define the orthogonal Boolean-support projections

\[
D_S=\sum_{T\subseteq S}(-1)^{|S|-|T|}P_T.
\]

They satisfy \(D_SD_T=0\) for \(S\ne T\), \(\sum_{S\subseteq[n]}D_S=I\), and \(P_Q=\sum_{S\subseteq Q}D_S\). The centered condition gives \(D_\varnothing L=0\). Define

\[
\gamma_S=\|D_SL\|_B^2\ge0\qquad (S\ne\varnothing).
\]

**Theorem 1 (universal exact operational noise spectrum).** In the preceding finite one-copy model, for all \(t\in[0,1]\) and all \(Q\subseteq[n]\),

\[
\boxed{G_t(Q)=\sum_{\varnothing\ne S\subseteq Q} t^{2|S|}\gamma_S.}\tag{1}
\]

In particular, \(0\le G_t(Q)\le \operatorname{Var}(f)\), the subset set-function is monotone and supermodular, and if all \(\gamma_S=0\) below degree \(r\), then \(G_t(Q)\le t^{2r}\operatorname{Var}(f)\). At \(t>0\), all coefficients \(\gamma_S\) are uniquely identifiable from the collection of exact subset gains by Möbius inversion; at \(t=1\),

\[
\gamma_S=\sum_{T\subseteq S}(-1)^{|S|-|T|}G_1(T).
\]

**Proof.** First establish Personick's scalar identity. For any POVM \(\{M_y\}\) and real estimates \(h_y\), set \(H=\sum_y h_y M_y\). Kadison's inequality for the unital positive map from classical outcome functions implies \(\sum_y h_y^2M_y\succeq H^2\). Consequently,

\[
R\ge \mathbb E f^2-2\operatorname{Tr}(AH)+\operatorname{Tr}(BH^2).
\]

Completing the square in the \(B\)-inner product minimizes the right side at \(H=J_B^{-1}A\) and yields \(R\ge\operatorname{Var}(f)-\langle L,L\rangle_B\). The spectral projective measurement of the Hermitian \(L\), with its eigenvalues as estimates, achieves equality. The same argument on any subsystem \(Q\) gives \(G(Q)=\|P_QL\|_B^2\), since the restricted Personick score is precisely the weighted conditional expectation of the full score.

The product property of \(B\) makes the one-site maps \(E_i\) commuting orthogonal projections. The Schrödinger replacement \(Y\mapsto b_i\otimes\operatorname{Tr}_iY\) and the dual conditional expectation \(E_i\) intertwine the Jordan map:

\[
J_B(E_iU)=b_i\otimes\operatorname{Tr}_i(J_B U).
\]

Hence the noisy signal's Personick score is \(L_t=\prod_{i=1}^n[tI+(1-t)E_i]L\). Each \(D_S L\) is unchanged by \(E_i\) if \(i\notin S\) and killed by \(E_i\) if \(i\in S\); therefore \(L_t=\sum_S t^{|S|}D_SL\). Project onto \(Q\), then use mutual orthogonality:

\[
G_t(Q)=\|P_QL_t\|_B^2=\left\|\sum_{S\subseteq Q}t^{|S|}D_SL\right\|_B^2
=\sum_{S\subseteq Q}t^{2|S|}\|D_SL\|_B^2.
\]

The empty component vanishes. Monotonicity, supermodularity, inversion and the attenuation bound follow immediately. □

**Boundary:** if \(B\) is not product, the projections generally fail to commute. Even classical duplicate coordinates furnish a violation of the universal supermodularity assertion. The theorem does not give a quantum instrument protocol with feed-forward or repeated copies.

## 3. The physical converse: all positive hypergraphs are realizable

Let \(\mathcal W=\{w_S\ge0:\varnothing\ne S\subseteq[n]\}\) be any finite nonnegative weighted hypergraph; permit arbitrary real weights. Define the positive-hypergraph set function

\[
H_t(Q)=\sum_{\varnothing\ne S\subseteq Q}w_St^{2|S|}.
\]

**Theorem 2 (fixed-qubit realization).** For every such \(\mathcal W\), there is a finite independent fair-sign classical source, one fixed pair of *full-rank, noncommuting* qubit states used identically on all sites, and one real scalar target \(f\), whose optimal physical Bayesian gain is \(G_t(Q)=H_t(Q)\) for **every** \(Q,t\). If all nonzero weights have \(|S|\le d\), the target has classical Hoeffding/Fourier degree at most \(d\).

**Explicit construction and proof.** Take \(X_i\in\{-1,+1\}\) uniformly and independently, and define

\[
b=\begin{pmatrix}2/3&0\\0&1/3\end{pmatrix},\quad
D=\begin{pmatrix}0&1/6\\1/6&0\end{pmatrix},\quad
\rho_\pm=b\pm D.
\]

These are full-rank density matrices (determinant \(7/36\)), and \([\rho_+,\rho_-]\ne0\). Their mean is \(b\). The local replacement channel gives \(\rho_x(t)=b+txD\).

For each \(m\ge1\), define the strictly positive rational constant

\[
c_m=\operatorname{Tr}\!\left[D^{\otimes m}J_{b^{\otimes m}}^{-1}(D^{\otimes m})\right]
=2\left(\frac1{36}\right)^m
\sum_{z\in\{0,1\}^m}\frac1{b_z+b_{\bar z}},\quad
b_z=\prod_{i=1}^m \begin{cases}2/3,&z_i=0\\1/3,&z_i=1.\end{cases}
\]

The exact first constants are \(c_1=1/9\), \(c_2=1/80\), and \(c_3=11/7776\). Choose

\[
f(x)=\sum_{S:w_S>0}\sqrt{\frac{w_S}{c_{|S|}}}\,\chi_S(x),\qquad \chi_S(x)=\prod_{i\in S}x_i.
\]

Classical Fourier orthogonality makes \(\chi_S\) a pure centered interaction. Its signed quantum interaction operator is \(\sqrt{w_S/c_{|S|}}D^{\otimes |S|}\), so the corresponding Personick gain coefficient is exactly \(w_S\). Apply Theorem 1. The finite target is bounded by \(\sum_{S:w_S>0}\sqrt{w_S/c_{|S|}}\), and can be normalized to \(|f|\le1\) by a common scaling, with every gain weight then scaled by that square. □

**Meaning:** the physical operational gain functions of this observation model are *exactly* the positive-hypergraph (nonnegative Möbius transform) set functions. This is stronger than merely observing a generic supermodular function: not all supermodular functions have nonnegative individual Möbius coefficients. Positive-hypergraph valuations are well-established in combinatorial optimization; the physical realization is the element requiring separate novelty review.

## 3a. Strict collective-measurement advantage within the same qubit model

The physical converse is not just a re-expression of classical observations. Even with independent fair classical signs, one jointly optimized quantum measurement can outperform *every product of local POVMs* for mean-square prediction.

**Proposition (exact two-qubit separation).** In the above fixed-qubit model with \(f(X)=X_1X_2\) and \(t=1\), the optimal collective squared-error gain is \(c_2=1/80\), whereas the best gain of any product of local measurements is \(c_1^2=1/81\). The collective gain is therefore larger by the exact factor \(81/80\).

**Proof.** For independent local measurement outcomes \(Y_1,Y_2\), the posterior parity predictor factorizes: \(\mathbb E[X_1X_2\mid Y_1,Y_2]=m_1(Y_1)m_2(Y_2)\), where \(m_i(Y_i)=\mathbb E[X_i\mid Y_i]\). Its variance, which is precisely the Bayes gain, equals \(\mathbb E[m_1^2]\mathbb E[m_2^2]\). By the optimal *one-qubit* scalar Personick theorem, \(\mathbb E[m_i^2]\le c_1=1/9\), and the local \(\sigma_x\) measurement attains equality for each register. Thus the best product-measurement gain is \(1/81\). Theorem 2 and the exact Jordan calculation yield the unrestricted collective optimum \(c_2=1/80\). □

This separation concerns independent **product POVMs**, not the full class of adaptive LOCC or repeated-copy instruments. It is a modest but rigorous demonstration that noncommuting quantum readout adds operational content beyond a purely classical hypergraph.

## 4. The computational frontier

Assume the hypergraph weights are given explicitly (rational values, with their bit sizes included in the input), a rational fixed \(t\in(0,1]\), and a register budget \(k\). The fixed-subset selection problem is

\[
\max_{Q\subseteq[n],\,|Q|\le k}\ H_t(Q).
\]

**Theorem 3 (degree-one/degree-two transition).**

(a) With only rank-one hyperedges the optimum is obtained by sorting the \(n\) singleton weights, in polynomial time.

(b) At rank two the decision variant is NP-complete **on the following explicitly succinct family of legitimate quantum experiments:** all sensors are identical \(\rho_\pm=b\pm D\) above, the inputs are independent fair signs, \(t=1\), and the target is specified by an unweighted graph \(G\) as \(f_G(x)=\sum_{\{i,j\}\in E(G)}x_ix_j\). The optimal gain is

\[
\boxed{G_1(Q)=\frac{|E(G[Q])|}{80}.}\tag{2}
\]

Therefore an induced \(k\)-vertex clique exists if and only if the optimum over \(k\) retained registers is at least \(\binom{k}{2}/80\). Membership in NP is immediate for this restricted family: a subset \(Q\) is a polynomial-size certificate and its induced edge count is computable in polynomial time. It follows that the general explicit positive-hypergraph optimization problem is NP-hard. If one wishes to require \(|f_G|\le1\), dividing by the number of edges preserves the reduction after a known rational rescaling of the threshold. □

**Crucial distinction:** this is hardness of *selecting which registers to retain*, not of implementing a given optimal Personick observable and not of adaptive quantum query complexity. The quantum full-matrix state is specified succinctly by the repeated local qubit pair and graph edge list, rather than written as an exponentially large matrix.

**Theorem 4 (structural tractability).** Let \(\mathcal W\) have primal graph \(P\), obtained by joining any two vertices that co-occur in a positive hyperedge. Given a width-\(w\) tree decomposition of \(P\), optimal size-\(k\) selection at any fixed rational \(t\) can be computed exactly in

\[
O\!\big((n+|\mathcal W|)\,2^{w+1}(k+1)^2\operatorname{poly}(w,d)\big)
\]

rational-arithmetic operations (plus ordinary bit-cost factors); here \(d\le w+1\) for nonzero hyperedges when \(w\ge0\). Assign each hyperedge to one tree-decomposition bag containing it (every hyperedge is a clique in the primal graph and hence fits a bag). At each nice bag use a DP indexed by (i) the binary choice on bag vertices and (ii) the number of selected vertices already forgotten. Sum weights for hyperedges assigned to that bag if all their vertices are selected; handle introduce/forget/join nodes by the usual consistent bag-state transitions and cardinality convolution. The empty root state with count \(k\) gives the optimum. The method is standard tree-decomposition dynamic programming; the significance here is an **exact operational reduction** from the quantum selection problem to those tables. □

## 5. Exact noise-induced selection phase diagram

**Theorem 5.** Suppose the hypergraph has maximum rank \(d\) and rational weights. Let \(\mathcal F_k\) be the family of admissible \(k\)-subsets and \(N=|\mathcal F_k|\). Set \(z=t^2\). For a candidate subset \(Q\), its score is a polynomial
\[
P_Q(z)=\sum_{r=1}^d a_{Q,r} z^r,\quad a_{Q,r}\in\mathbb Q_{\ge0}.
\]

Unless \(P_Q\equiv P_R\), a pair of designs \(Q,R\) can tie for at most \(d-1\) positive values of \(z\): their difference is \(z\) times a polynomial of degree at most \(d-1\). Thus the global optimal design is constant on open intervals separated by at most \((d-1)\binom N2\) candidate crossover values in \((0,1]\). Every crossover can be certified with exact rational polynomial arithmetic and real-algebraic root isolation. At pure interaction order \(d\), the optimal design is independent of the attenuation strength \(t>0\). □

For a simple sharp crossover, choose weights \(w_{\{1\}}=2\) and \(w_{\{2,3\}}=4\), all others zero, and select two vertices. A pair containing 1 scores \(2z\); the pair \(\{2,3\}\) scores \(4z^2\), with a genuine change of optimal sensor set at \(z=1/2\), i.e. \(t=1/\sqrt2\).

## 6. The complex-output compatibility theorem

The exact operational interaction decomposition concerns **one real scalar target**. A complex target \(f=g+ih\) involves simultaneous measurement of two real predictions and cannot, in general, attain both individual Personick optima on one copy. Define the physically best squared-complex-error gain
\[
G^\mathbb C_t(Q)=\operatorname{Var}(g)+\operatorname{Var}(h)-\inf_{\mathrm{POVM},\widehat f}\mathbb E|f-\widehat f|^2.
\]

For each scalar component let \(G^g_t,G^h_t\) be its individually optimized gains. **Theorem 6 (sharp compatible-sensing sandwich):**

\[
\boxed{\frac12[G^g_t(Q)+G^h_t(Q)]\le G^\mathbb C_t(Q)\le G^g_t(Q)+G^h_t(Q).}\tag{3}
\]

The upper bound holds because no common POVM can beat either component's individual optimum. For the lower bound, flip a fair classical coin, choose the optimal measurement for \(g\) or for \(h\), estimate the chosen component and use zero as the other component's centered estimate. This physically implementable randomized measurement obtains exactly half the sum of separately optimal gains. These bounds carry the positive interaction-order spectrum as an operational envelope for genuinely complex targets. They do not assert exact additivity of simultaneously attainable gains.

**The factor \(1/2\) is attained.** Let \(X\) be uniform over three phases \(\theta=0,2\pi/3,4\pi/3\), \(f(X)=e^{i\theta}\), and encode it into the qubit state \(\rho_\theta=(I+c\cos\theta\,\sigma_x+c\sin\theta\,\sigma_y)/2\) with \(0<c<1\). The mean state is \(I/2\). The real and imaginary signed signals are \(A_g=(c/4)\sigma_x\) and \(A_h=(c/4)\sigma_y\), whence \(G^g=G^h=c^2/4\).

For any qubit POVM write \(M_y=(\alpha_y/2)(I+\mathbf r_y\cdot\boldsymbol\sigma)\), with \(\alpha_y\ge0\), \(|\mathbf r_y|\le1\), \(\sum_y\alpha_y=2\). The complex conditional-mean estimator is \(\widehat f(y)=(c/2)(r_{y,x}+ir_{y,y})\). Therefore
\[
G^\mathbb C=\sum_y\frac{\alpha_y}{2}\left|\widehat f(y)\right|^2
\le\frac{c^2}{4},
\]

and an ordinary projective \(\sigma_x\) measurement attains \(c^2/4\). Hence \(G^\mathbb C=(G^g+G^h)/2\). This is an explicit incompatibility example, not a claim of original discovery of the general Bayesian incompatibility phenomenon. □

## 7. Independent finite audit and a nonproduct conditional example

Run:

```sh
python3 cost_master_exact_audit.py
```

The checker uses only standard-library `fractions.Fraction` for exact rational arithmetic. It constructs the signal matrices directly by averaging the physical conditional density matrices, independently of the coefficient-based hypergraph calculation. It checks all 16 register subsets and four rational noise strengths for a mixed-degree four-qubit target: **64 exact identities**. It checks the strict collective-vs-product-POVM gain ratio \(81/80\), the noncommuting full-rank condition and exact constants \(c_1=1/9\), \(c_2=1/80\), \(c_3=11/7776\).

**Entangled conditional example:** \(\rho_+=|\Phi^+\rangle\langle\Phi^+|\), \(\rho_-=(I-\rho_+)/3\), with prior probabilities \(1/4\), \(3/4\) and centered target values \(3,-1\). The average is \(B=I_4/4\), even though one conditional state is maximally entangled and the ensemble is not a two-site local product preparation. Both conditional marginals equal \(I_2/2\). Its full optimal gain after local replacement noise is **exactly** \(3t^4\); each one-register gain is zero. The rational checker verifies four noise strengths directly.

Separately, the checker enumerates all **1,098** labelled graphs on 2--5 vertices, their **33,864** subsets, and **4,306** clique-decision instances. It checks a special width-two path-decomposition DP against exhaustive search for **136** weighted rank-three instances. It verifies the noise-selection crossover at \(t^2=1/2\), and the rational trine moments underlying the sharp complex-target factor-two example.

**Limit of these tests:** Exact finite counterexample searches/replays do not prove the universally quantified theorems, and the two quantum formula computations share the same underlying mathematical identity. There is no claimed independent non-author proof audit or kernel compilation.

## 8. What comes from the NIGHTFALL repository

- [Quantum ANOVA v2](https://github.com/d3lefts/d3lefts/blob/main/papers/quantum-operational-anova/OPERATIONAL_QUANTUM_ANOVA_v2.md): the analytic operational quantum support decomposition, including general product-average ensembles. **Imported mathematical foundation.**
- [Quantum ANOVA v3 + quadratic influence bridge](https://github.com/d3lefts/d3lefts/blob/main/papers/finite-product-influence/QUANTUM_ANOVA_BRIDGE_20261111.md): a conditional transfer from classical influence to *terminal* quantum marginal gain; **does not imply a from-scratch greedy sensor policy**.
- [Sharp SLD tensor bound](https://github.com/d3lefts/d3lefts/blob/main/papers/quantum-sld-tensorization/THEOREM_AND_AUDIT.md): an existing stronger operator comparison and physical ternary extremizers; **not superseded** by this note.
- [Wright v8 quadratic influence](https://github.com/d3lefts/d3lefts/blob/main/papers/finite-product-influence/V8_PROOF_PASSPORT.md): analytic \(V^2\le K_8B^2\max_i I_i\), not end-to-end Lean-certified, not externally refereed. Combining with the present fixed-qubit realization gives a conditional terminal-gain bound \(\max_i\Delta_i(t)\ge t^4 V^2/(80K_8B^2)\) for fair binary, degree-two, \(|f|\le B\). This is not an initial-gain or adaptive-query theorem.
- [Lean finite scalar influence foundation](https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/formalization/product_space/ProductInfluence.lean): a genuine but narrower Lean kernel-compiled theorem. It does not machine-certify this quantum or NP-hardness correspondence.
- [Classical spectral adaptive prediction](https://github.com/d3lefts/d3lefts/blob/main/papers/spectral-adaptive-prediction/MANUSCRIPT.md): dimension-independent classical whole-coordinate observation; the current quantum fixed-subset hardness is a **different** observation model.

## 9. Prior art and novelty gate

- S. Personick, *Application of quantum estimation theory to analog communication over quantum channels*, IEEE Transactions on Information Theory 17 (1971), 240--246, DOI 10.1109/TIT.1971.1054643: scalar quantum Bayes MSE and optimal score measurement.
- M. Tsang, *Generalized conditional expectations for quantum retrodiction and smoothing*, Phys. Rev. A 105, 042213 (2022), and *Operational meanings of a generalized conditional expectation in quantum metrology*, Quantum 7, 1162 (2023): quantum weighted conditional expectations.
- Feige, Feldman, Immorlica, Izsak, Lucier and Syrgkanis, *A Unifying Hierarchy of Valuations with Complements and Substitutes* (2014), arXiv:1408.1211: positive hypergraph rank is an established concept.
- NP-completeness of CLIQUE and standard tree-decomposition dynamic programming: established complexity theory; neither is an original claim here.
- *Measurement incompatibility in Bayesian multiparameter quantum estimation*, Quantum (2026), DOI 10.22331/q-2026-08-13-2192: directly relevant recent prior art on constant-factor incompatibility in Bayesian multi-parameter estimation.

A targeted 11 November 2026 search did not determine whether the complete **noncommuting fixed-qubit realization + exact noisy operational spectrum + computational reduction** has appeared elsewhere. The globally novel portion, if any, must be established by a dated specialist source-to-source review. The synthesis itself is not a novelty certificate.

## 10. Certification and extension roadmap

1. **Formalize first:** the finite positive-hypergraph zeta/Möbius identity, supermodularity and clique reduction using exact rational \(1/80\). This can be a Lean finite combinatorial module independent of quantum operators.
2. **Quantum kernel:** define finite matrix Jordan covariance, prove restricted conditional expectation's meet identity under product averages, then compose the noise eigenvalue and Personick score. Reuse only appropriately scoped NIGHTFALL Lean components.
3. **Adversarial audit:** try noncommuting and entangled conditional ensembles with product average, singular means, different local noise models, and real/complex incompatibility. Avoid extrapolation beyond explicitly proved hypotheses.
4. **Algorithmic research question, not a theorem:** determine whether useful approximation or parameterized algorithms exist for low-degree observability hypergraphs when the interaction coefficients are *not* given explicitly but must be learned through limited physical measurements. The current explicit-weight DP is not a sample-complexity guarantee.
5. **Publication gates:** independent specialist proof review, statement-by-statement 2026 prior-art review, and owner authorization before submission.

**Final status:** Complete finite-dimensional analytic construction and proof presented; rational counterexample/replay suite passed; **not** independently reviewed, globally originality-cleared, or Lean kernel-certified.
