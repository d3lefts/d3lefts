# Quantum ANOVA and classical quadratic observability: a scoped synthesis

**NIGHTFALL research addendum, 11 November 2026**  
**Status:** New author-side analytic deduction from two separate manuscripts; finite exact examples checked. **Not** a new end-to-end Lean certificate, independent non-author referee report, quantum adaptive-query theorem, or global originality certification. This note is a **proposed section for the next manuscript**, not a modification of the frozen v8 source or its SHA-256 manifest.

## Objective, sources, and exact boundary

The existing [v8 influence manuscript](Bias_Free_Aaronson_Ambainis_All_Product_Spaces_v8.tex) proves *analytically* a scalar quadratic influence bound and rank-sensitive adaptive **classical whole-input-coordinate** observation. The separate NIGHTFALL manuscript *Operational Quantum ANOVA: Exact Bayes Gain, Independence Characterization, and Spectral Visibility*, v3 (11 November 2026; its complete source is held in the research source package, **not yet deposited in this GitHub directory**) develops finite-dimensional quantum fixed-subset Bayes gain.

These are **not** the same observation model. The common mechanism is a Hilbert-space projection representation, and the quantitative connection requires **independent classical inputs with local quantum preparation channels**. The unconditional product-average quantum ANOVA is more general, allowing entangled/nonlocal conditional states; that generality does **not** carry over to the local-spectral transfer below.

The previously discussed bridge used the v7 coefficient
\(
K_7=225(1+\sqrt3)^2.
\)
The repository's current v8 coefficient is strictly better:
\[
\boxed{K_8=(10+2\sqrt2)^2(1+\sqrt3)^2
      =432+160\sqrt2+216\sqrt3+80\sqrt6.}
\]
All statements here use the canonical v8 coefficient. The coefficient is **conditional on validity of the analytic v8 scalar proof**, which has not been externally refereed or end-to-end Lean certified.

## 1. Common projection mechanism

Let \(\mathcal H_\mathbb R\) be a real Hilbert space, \(v\in\mathcal H_\mathbb R\), and suppose \(P_Q\), indexed by subsets \(Q\subseteq[n]\), are orthogonal projections satisfying
\[
P_QP_T=P_{Q\cap T},\qquad P_{[n]}=I,\qquad P_{\varnothing}v=0.
\]
The commuting projections induce mutually orthogonal Boolean atoms
\[
D_S=\sum_{T\subseteq S}(-1)^{|S|-|T|}P_T,\qquad
P_Q=\sum_{S\subseteq Q}D_S.
\]
Consequently, for \(\mathcal O_v(Q)=\|P_Qv\|^2\),
\[
\boxed{\mathcal O_v(Q)=\sum_{\varnothing\ne S\subseteq Q}
                 \|D_Sv\|^2.}
\]
Every Möbius coefficient is nonnegative, so \(\mathcal O_v\) is normalized, monotone, and supermodular. This Boolean-projection fact is standard Hilbert-space algebra and is **not** claimed novel.

- **Classical:** \(v=f-\mathbb Ef\), \(P_Qv=\mathbb E[v\mid X_Q]\) under independent inputs; \(\mathcal O_v(Q)=\operatorname{Var}(\mathbb E[f\mid X_Q])\).
- **Quantum:** for finite-dimensional CQ ensembles with average state \(B=\bigotimes_i b_i\succ0\), target signal \(A=\sum_xp_x(f_x-\bar f)\rho_x\), and score \(L=J_B^{-1}(A)\), where \(J_B(W)=(BW+WB)/2\), use the Jordan inner product \(\langle U,W\rangle_B=\operatorname{Tr}[U J_B(W)]\). The state-weighted projections onto observables supported on \(Q\) satisfy the meet identity. The optimized **scalar** mean-square Bayes gain is
\[
G^*(Q)=\operatorname{Tr}[A_QJ_{B_Q}^{-1}(A_Q)]
      =\|P_QL\|_B^2
      =\sum_{\varnothing\ne S\subseteq Q}\gamma_S,\quad \gamma_S\ge0.
\]
Only the product structure of **the unconditional average** \(B\) is required for this quantum decomposition; the individual \(\rho_x\) may be jointly encoded, entangled or noncommuting. This is an analytic statement of quantum ANOVA v3, **not** kernel-certified in this repository.

## 2. Independence as a universal complementarity law

**Classical finite-system characterization.** For an arbitrary joint law on finitely many coordinates, universal supermodularity of
\(\operatorname{Var}(\mathbb E[f\mid X_Q])\) over **every** real \(L^2\) target \(f\) is equivalent to independence of all coordinates. Sufficiency follows from the commuting-projection argument. Necessity: set \(f=U(X_i)\) centered. Then gain on \(i\) equals gain on all coordinates; the complementary-partition supermodularity inequality forces \(\operatorname{Var}(\mathbb E[U\mid X_{-i}])=0\). This for all centered \(U\) gives \(X_i\perp X_{-i}\), for every \(i\), hence the product law. This classical characterization is a short known-method consequence, **not** claimed original.

**Quantum v3 converse.** For faithful finite-dimensional \(B\), the following are equivalent:

1. \(B=\bigotimes_i B_i\).
2. \(G^*(Q)\) is supermodular for every finite scalar CQ ensemble having average \(B\).
3. The complementary-partition inequalities hold for every **equiprobable binary** CQ ensemble with average \(B\).

For necessity, if \(B\neq B_i\otimes B_{-i}\) choose marginal-centered local Hermitian \(U_i,V_{-i}\) with \(c=\operatorname{Tr}[B(U_i\otimes V_{-i})]\neq0\). Put \(U=U_i\otimes I\), \(M=J_B(U)\); for sufficiently small \(t>0\) the states \(\rho_\pm=B\pm tM\) are valid. With targets \(\pm1\), full and \(i\)-only scores both equal \(tU\), so \(G^*([n])=G^*(\{i\})\); the complementary signal obeys \(\operatorname{Tr}[A_{-i}V_{-i}]=tc\neq0\), hence \(G^*(-i)>0\), contradicting supermodularity. The full-rank assumption justifies the binary perturbation. This iff theorem is sourced to quantum ANOVA v3 and still requires independent specialist/priority review.

This is a **universal-over-ensembles** characterization; supermodularity of one particular gain function does not imply a product average.

## 3. New quantitative link: terminal quantum gain from scalar influence

**Proposition (v8 quadratic influence to local quantum visibility; analytic deduction).** Let \(n\ge1\). Suppose \(X_i\) are independent finite-alphabet inputs with positive atom probabilities, and \(\rho_x=\bigotimes_i\rho_{i,x_i}\) are finite-dimensional local quantum preparations. Assume each local average \(b_i=\mathbb E\rho_{i,X_i}\succ0\). For a real \(|f|\le B_0\), \(B_0>0\), of classical Hoeffding degree at most two, let \(V=\operatorname{Var}(f)\).

For the real centered local input space \(\mathcal V_i=L^2_0(p_i)\), define
\[
T_i(g)=\sum_{x_i}p_i(x_i)g(x_i)\rho_{i,x_i},\quad
\Omega_{b_i}(W)=b_i^{1/2}Wb_i^{1/2},\quad
K_i=T_i^*\Omega_{b_i}^{-1}T_i.
\]
Put \(\alpha_i=\lambda_{\min}(K_i)>0\),
\(\kappa_i=\lambda_{\max}(b_i)/\lambda_{\min}(b_i)\), and
\[
\kappa_S=\prod_{i\in S}\kappa_i,\quad
c_S=\frac{2\sqrt{\kappa_S}}{1+\kappa_S},\quad
\delta_2=\min_{\substack{\varnothing\ne S\subseteq[n]\\ |S|\le2}}
      c_S\prod_{i\in S}\alpha_i>0.
\]
Then the operational scalar Bayes gains for the preparation ensemble satisfy
\[
\boxed{\max_i\{G^*([n])-G^*([n]\setminus\{i\})\}
\ \ge\ \delta_2\max_i I_i(f)
\ \ge\ \frac{\delta_2 V^2}{K_8 B_0^2},}
\]
where \(I_i(f)=\mathbb E[(f-\mathbb E_i f)^2]\) is the **resampling** influence and the largest influence is interpreted as a supremum if needed (here \(n\) is finite).

**Proof.** In the independent/local-encoder specialization of quantum ANOVA v3, the nonnegative support coefficient is \(\gamma_S=\operatorname{Tr}(A_SJ_{B_S}^{-1}(A_S))\), \(A_S=(\otimes_{i\in S}T_i)f_S\). Multiplicativity of the geometric kernel and the support-local SLD/geometric comparison give
\[
\gamma_S \ge c_S\,
\langle f_S,(\otimes_{i\in S} K_i)f_S\rangle
\ge c_S\Big(\prod_{i\in S}\alpha_i\Big)\|f_S\|_2^2.
\]
As \(f_S=0\) for \(|S|>2\), \(\gamma_S\ge\delta_2\|f_S\|_2^2\) for all nonempty supports. The positive-zeta representation yields
\[
G^*([n])-G^*([n]\setminus\{i\})
=\sum_{S\ni i}\gamma_S
\ge\delta_2\sum_{S\ni i}\|f_S\|_2^2
=\delta_2 I_i(f).
\]
Finally apply the v8 analytic scalar quadratic theorem \(V^2\le K_8 B_0^2\max_i I_i(f)\). QED **relative to the two source analytic theorems**.

**Visibility and scope.** \(\alpha_i>0\) is equivalent, for finite positive classical probabilities, to affine independence of the local density matrices. It requires alphabet cardinality \(\le d_i^2\) for a \(d_i\)-dimensional local quantum register, but the dimension inequality alone is insufficient. If any \(\alpha_i=0\), a positive universal \(\delta_2\) need not exist. The conditional-state entanglement allowed in Section 1 is **not** allowed in this proposition's local-encoder hypothesis. This is a bound on a **leave-one-register-out terminal marginal gain**, not a lower bound for the gain of observing a single register from scratch, not a small-subset acquisition theorem, and **not** an adaptive quantum-measurement protocol.

**Improvement over the preliminary bridge.** The earlier note divided by \(K_7=225(1+\sqrt3)^2\); the present result divides by the strictly smaller \(K_8\). This is a sharper conditional transfer constant from a verified repository revision, **not** a claim of an independently original new exponent.

## 4. Exact rational sanity checks

Run from repository root:

\`\`\`sh
python3 papers/finite-product-influence/check_quantum_anova_bridge_exact.py
\`\`\`

The new standard-library-only checker directly computes the diagonal Personick gain
\(\sum_z A_Q(z)^2/B_Q(z)\) from exact rational partial traces in two cases:

1. **Product-average local parity:** independent fair \(X_1,X_2\), \(f=X_1X_2\); local qubit \(Z\)-basis preparations with contrasts \(c_1=1,c_2=1/3\). All average-register eigenvalues equal \(1/2\); \(G^*(1)=G^*(2)=0\), \(G^*(12)=1/9\). Local Gram minima are \(1,1/9\), giving \(\delta_2=1/9\); each terminal marginal gain equals \(\delta_2 I_i(f)=1/9\).
2. **Correlated-average obstruction:** \(B(z_1,z_2,z_3)=(1+z_1z_2z_3/2)/8\), binary perturbation \(A=tBZ_1\) with \(t=1/2\). All binary states are full rank, \(G^*(1)=1/4\), \(G^*(23)=1/16\), \(G^*(123)=1/4\), so the complementary-partition supermodularity violation is exactly \(1/16\).

These checks are **commuting finite examples**. They do not certify the general noncommuting projection theorem, arbitrary ensembles, SLD/geometric comparison, scalar v8 analytic theorem, or global originality.

## 5. Proposed manuscript architecture and gates

**Recommended editorial architecture:** (A) the common Hilbert projection/interaction algebra; (B) arbitrary-product influence and the rank-linear classical whole-coordinate observation theorem (canonical v8); (C) operational quantum fixed-subset ANOVA; (D) the product-average iff converse; (E) local spectral visibility and the new terminal marginal bridge. Put full quantum proofs, the metric-family generalization, and noncommuting examples into a technical appendix or accompanying source until independently reviewed. Do not replace or rewrite the frozen v8 paper under its existing filename or invalidate its source-hash manifest.

**Dependency graph:** classical Hoeffding and v8 scalar quadratic matching theorem + quantum v3 Personick/Jordan projection + local geometric Gram transfer -> the displayed \(\delta_2/K_8\) terminal-gain bound. This is not an end-to-end universal classical–quantum adaptive theorem.

**Source/review gates:** (1) deposit and hash the complete v3 quantum source/checkers into the archival workflow; (2) adversarially verify quantum Jordan partial traces for noncommuting, potentially entangled conditional states; (3) independently check the scalar v8 matching proof and all measured-space hypotheses; (4) repeat dated source-level prior-art comparison, notably Personick (1971), Guță–Butucea (2010), Tsang (2022–23), Beigi (2013), and Chen–Waggoner (2017); (5) distinguish author-side analytic proof, example check, Lean kernel compilation, novelty, and outside review. No external publication, website promotion, or claim-register elevation is authorized by this addendum.

**Mechanism/transfer registry:** operator: commuting meet-projections -> nonnegative Möbius interaction energies; scope: independent classical product or product unconditional quantum mean; quantitative transfer: local quantum Gram positivity -> terminal register gain; cost: spectral floor \(\delta_2\) (can vanish); success: exact rank-free scalar inequality with \(V^2\) using v8; failure: singular visibility, correlated average, or adaptive-quantum inference; novelty status: **unresolved**.
