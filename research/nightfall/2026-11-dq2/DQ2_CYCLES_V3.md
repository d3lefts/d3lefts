# DQ2 v3 — Restricted quadratic covariance without tree paths

**2026-11-17 · NIGHTFALL · Author-analytic theorem with exact finite independent-implementation checks · NOT Lean certified or independently refereed · Novelty/priority unresolved**

## Target and strongest relevant prior art

Move from independent-block/weighted-tree DQ2 (draft PR #786) to all finite graphs with cycles, including signed and frustrated couplings, and farther to globally spin-flip-invariant *non-pairwise* binary laws. Retain the **restricted quadratic sector comparison** and **native single-site conditional influence**; do not replace either with raw graph-dependent density ratios.

The 2021/2022 literature on robust learning of Ising models under Dobrushin conditions already establishes dimension-free degree-two variance upper/lower comparisons (Daskalakis, Dikkala, Kamath et al., *Outlier-Robust Learning of Ising Models Under Dobrushin's Condition*, arXiv:2102.02171, Lemma 4.1, Theorem 4.2 and Theorem 5.2). The existence of related Ising quadratic bounds is **not novel**. Also consult Koehler–Lifshitz–Minzer–Mossel, STOC 2024, arXiv:2307.07625; Eldan–Koehler–Zeitouni, PTRF 2022, arXiv:2007.08200; Chen–Chen–Zhang, 2026-11-12 revision of arXiv:2609.24687. The explicitly parameterized transfer below, its broader mean-zero non-Ising interface, and its proof-composition method still need claim-by-claim priority comparison. No priority is asserted.

## Definitions (finite, exact)

Let \(V\) have \(n\ge1\) elements. Let \(\nu\) be a full-support probability law on \(\{-1,1\}^{V}\). Write

\[
 m_i(x_{-i})=\mathbb E_\nu[X_i\mid X_{-i}=x_{-i}],\qquad
 v_i(x_{-i})=1-m_i(x_{-i})^2.
\]

Define \(c_{ij}\) for \(i\ne j\) as the supremum of the total variation distance of the two conditional laws of \(X_i\) when only the other coordinate \(j\) is flipped (equivalently \(\frac12\sup|\Delta_j m_i|\)), and \(c_{ii}=0\). Put
\(\delta=\max(\|c\|_{\infty},\|c\|_1)\), where the norms are maximum absolute row and column sums. Assume \(\delta<1\), all means \(\mathbb EX_i=0\), and a positive conditional-variance floor \(v\le\min_{i,x}v_i(x)\), \(0<v\le1\).

Let \(\mu\) denote the *uniform independent-sign* law on the same cube. For either law \(\lambda\), use the actual native conditional-resampling influence

\[
 I_{\lambda,i}(f)=\mathbb E_\lambda\operatorname{Var}_\lambda(f\mid X_{-i}).
\]

Define algebraic quadraticity (NOT dependent Hoeffding degree) by

\[
 f(x)=c_0+\sum_i a_i x_i+\sum_{i<j}b_{ij}x_i x_j,
 \qquad |f(x)|\le B \quad\text{for every }x\in\{-1,1\}^V.
\]

We use the **existing finite product Q2 theorem** as an input:
\(\operatorname{Var}_\mu(f)^2\le K_0 B^2\max_i I_{\mu,i}(f)\).
The Q2 theorem must be verified at its exact original source and named pinned Lean receipt; nothing here proves that input anew or certifies the infinite-product integration.

## DQ2-CYCLES general transfer theorem (analytic proof)

Under the preceding assumptions, writing \(\gamma=1-\delta\),

\[
\boxed{\operatorname{Var}_\nu(f)^2
 \le \frac{4(1+\delta)^2}{v^3(1-\delta)^5}
 K_0 B^2\max_i I_{\nu,i}(f).}
\tag{DQ2-v3-general}
\]

This theorem requires **no graph, tree decomposition, conditional independence, or pairwise Ising assumption**. It is a finite-law theorem, with dimension-free coefficient whenever \(\delta\) and \(v\) have dimension-uniform bounds.

### Corollary: arbitrary cyclic and higher-order symmetric binary laws

If \(\nu(x)=\nu(-x)\) for all configurations (global spin-flip symmetry), then \(\mathbb EX_i=0\) and \(|m_i(x_{-i})|\le\sum_{j\ne i}c_{ij}\le\delta\): compare \(m_i(x_{-i})\) and \(m_i(-x_{-i})=-m_i(x_{-i})\) by flipping other coordinates one at a time. Consequently \(v\ge1-\delta^2\), and

\[
\boxed{\operatorname{Var}_\nu(f)^2
\le \frac{4K_0}{(1-\delta)^8(1+\delta)}
B^2\max_i I_{\nu,i}(f).}
\tag{DQ2-v3-symmetric}
\]

In particular, for any finite zero-field Ising model
\[\nu(x)\propto \exp(\sum_{\{i,j\}\in E}J_{ij}x_ix_j)\]
on **any** finite graph (including cycles, arbitrary loops, signed/frustrated edges), one may take
\(c_{ij}\le\tanh|J_{ij}|\), hence the readily checkable sufficient condition
\[\delta_J:=\max_i\sum_{j\ne i}\tanh|J_{ij}|<1\]
(with symmetric couplings, row and column maxima coincide), and replace \(\delta\) in the displayed bound by \(\delta_J\). The conclusion has no factor depending on \(|V|\), edge count, girth or loop rank. The bound is not sharp; at \(\delta=0\) our transfer yields \(4K_0\), though the original product theorem gives \(K_0\).

The symmetric-law result also covers finite higher-order *even* interactions, for example laws proportional to \(\prod_{A:\,|A|\text{ even}}(1+t_A\prod_{i\in A}x_i)\) when their **actual** Dobrushin coefficient obeys \(\delta<1\). Do not substitute the pairwise edge formula \(\sum_j\tanh|J_{ij}|\) for those models; compute their conditional coefficient matrix directly.

## Proof with independent obligations

**(1) Heat-bath Poincaré from Dobrushin path coupling.** Consider the reversible discrete-time Glauber kernel \(P=(1/n)\sum_i\mathbb E_i\), with one coordinate sampled and replaced by its true \(\nu\)-conditional law. For configurations differing at exactly one coordinate \(j\), couple a common update site. If site \(j\) updates, the disagreement vanishes; if \(i\ne j\) updates, the old disagreement persists and a new one appears with probability at most \(c_{ij}\). The expected Hamming distance after one step is therefore at most
\(1-(1-\sum_i c_{ij})/n\le1-\gamma/n\).
Path coupling extends to arbitrary pairs and contracts the Lipschitz seminorm. Every nonconstant eigenfunction of the *positive-semidefinite reversible* kernel \(P\) has eigenvalue at most \(1-\gamma/n\). Thus the single-site Dirichlet form obeys
\[
\gamma\operatorname{Var}_\nu(h)\le\sum_i I_{\nu,i}(h)\quad\text{for every }h.
\tag{Poincare}
\]
The normalization (site updates rate one in the continuous-time convention, not one *total* rate) is important.

**(2) Upper spin covariance.** Let \(S_a=\sum_i a_iX_i\). The Poincaré inequality gives
\[\operatorname{Var}_\nu(S_a)\le\gamma^{-1}\sum_i a_i^2,\]
since \(I_{\nu,i}(S_a)=a_i^2\mathbb E v_i\le a_i^2\).
For mean-zero spins, the covariance matrix \(C=\mathbb E XX^\top\) obeys \(C\preceq\gamma^{-1}I\).

**(3) Lower spin covariance: score duality.** Put \(R_i=X_i-m_i(X_{-i})\) and \(T_a=\sum_i a_iR_i\). Conditional orthogonality yields
\[
\mathbb E[S_aT_a]=\sum_i a_i^2\mathbb E v_i\ge v\|a\|_2^2.
\]
A flip in coordinate \(j\) changes \(T_a\) by at most \(2(|a_j|+\sum_{i\ne j}|a_i|c_{ij})\), hence
\[\sum_j I_{\nu,j}(T_a)\le\|(I+c^\top)|a|\|_2^2\le(1+\delta)^2\|a\|_2^2.\]
Apply (Poincaré) to \(T_a\): \(\operatorname{Var}(T_a)\le(1+\delta)^2\gamma^{-1}\|a\|_2^2\). Centering \(S_a\) (and \(\mathbb ET_a=0\)), Cauchy–Schwarz gives
\[\operatorname{Var}(S_a)\ge \alpha\|a\|_2^2,\quad \alpha:=\frac{v^2\gamma}{(1+\delta)^2}.\]
Thus **both** \(\alpha I\preceq C\preceq\gamma^{-1}I\) hold, with no tree paths, no four-point expansion, and no loss of graph-size independence.

**(4) Restricted degree-two covariance upper comparison.** Write \(g_i(X_{-i})=a_i+\sum_{j\ne i}b_{ij}X_j\), so the native single-site conditional influence is exactly \(I_{\nu,i}(f)=\mathbb E[v_i g_i^2]\le\mathbb E g_i^2\). Mean zero and Step 2 imply
\[
\begin{aligned}
\operatorname{Var}_\nu(f)
 &\le\gamma^{-1}\sum_i I_{\nu,i}(f)\\
 &\le\gamma^{-1}\left(\sum_i a_i^2+2\gamma^{-1}\sum_{i<j}b_{ij}^2\right)\\
 &\le2\gamma^{-2}\left(\sum_i a_i^2+\sum_{i<j}b_{ij}^2\right)
 =2\gamma^{-2}\operatorname{Var}_\mu(f).
\end{aligned}
\]
The step \(\gamma\le1\) justifies the final coefficient. This **is** the required restricted quadratic covariance operator comparison under a dependent law.

**(5) Native influence lower comparison.** The same \(g_i\) and Step 3 give
\[
I_{\nu,i}(f)\ge v\mathbb E g_i^2
\ge v\alpha\left(a_i^2+\sum_{j\ne i}b_{ij}^2\right)
=v\alpha I_{\mu,i}(f).
\]
The final transfer coefficient is \((2\gamma^{-2})^2/(v\alpha)=4(1+\delta)^2/(v^3\gamma^5)\), giving the general theorem. Under spin-flip symmetry substitute \(v=1-\delta^2\), giving \(4/((1-\delta)^8(1+\delta))\).

## Adversarial tests / exact certificate boundary

- `dq2_cycles_exact.py`: exact rational Gibbs enumeration on 8 distinct cyclic, signed and frustrated pairwise graphs, up to 8 spins; 240 random coefficient vectors and 1290 native influence checks. Crucially, exact rational **positive-definiteness checks of the entire covariance operator on ALL degree-two coefficient vectors and each native-coordinate influence form**, not just the 240 random vectors. Also exact full-function heat-bath Poincaré PSD for all functions on each of 4 small cyclic graphs. A strong-coupling test outside \(\delta<1\) is intentionally rejected.
- `dq2_general_spinflip_exact.py`: exact rational conditional distributions, *actual* Dobrushin matrices, and native influences for 5 non-tree laws, including pure 4-spin, overlapping 4-spin, signed pairwise+4-body, and one odd 3-spin interaction with zero one-point means but without spin-flip symmetry (using a directly calculated positive floor \(v\)). Exact rational finite-instance covariance lower/upper PSD and all native-gradient influence PSD. A biased product law deliberately violates the needed zero-mean/symmetry premise. For a pure 4-spin law with \(t=1/9\), all degree-two pair expectations vanish yet \(\operatorname{Cov}(X_0X_1,X_2X_3)=1/9\), demonstrating a genuinely non-tree quadratic covariance coupling.
- Finite tests are independent *implementations* and include whole coefficient-space matrix tests, but they **do not prove the theorem in arbitrary dimension**. All-size correctness rests on the explicit analytic proof; **external reviewer and named pinned Lean theorem remain absent**. Do not mislabel local PSD checks as theorem proof or Lean certificates.

## Limitations / next decisive test

1. Quantitative constants are deliberately loose; product endpoint returns 4K0 via the general route rather than K0. Improving the \(\kappa\) step to \(1+O(\delta)\) would recover a sharp perturbative endpoint and be a meaningful future structural goal.
2. The \(\delta<1\) restriction is material; no claim for strong coupling/criticality or arbitrary dependent laws. Constant diverges as \(\delta\uparrow1\), as expected near redundancy. Arbitrary finite alphabets and nonzero biases are not covered by the symmetric corollary. The general lemma allows mean-zero nonsymmetric laws only with an explicitly certified variance floor.
3. Prior art (especially arXiv:2102.02171) already provides closely related quadratic Ising bounds. No novelty is certified; exact priority comparison with all relevant dependent-law inequalities is needed before claiming a new mathematics result.
4. Next **highest-value formalization**: prove the generic heat-bath Poincaré and score-duality covariance lower interface in Lean for an arbitrary finite, full-support binary law, then compose with the already source-certified product Q2 theorem. A tree-path formalization is no longer prerequisite for the cyclic DQ2 theorem. Named theorem and strict source-hash/axiom CI must be attached before promotion.
5. Next broader research: arbitrary finite alphabets via conditional-score basis and local Gram conditioning; degree-three sector, or perturbative \(1+O(\delta)\) quadratic comparison. Preserve the exact operator budget \((\gamma,v,\delta)\) with the Proof Passport.

### Provenance and reproducibility

Artifacts: this markdown, Python exact checkers, JSON result files, SHA256SUMS. Independently phrased exact finite calculations and author-analytic proof are present; no external human referee or Lean kernel checking occurred in this DQ2 v3 turn. Prior DQ2 v1/v2 remain unmodified for historical traceability.