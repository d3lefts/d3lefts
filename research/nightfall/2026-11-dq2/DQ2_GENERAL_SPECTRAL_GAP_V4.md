# NIGHTFALL DQ2 v4 — general spectral-gap and score-sensitivity transfer

**Status:** Author-side analytic derivation, exact finite arithmetic tests, and **four Lean-kernel-checked scalar implication theorems**. The *law-level* heat-bath/score comparison and full dependent Q2 theorem are **not yet Lean certified**. No novelty priority claimed. Date: 2026-11-17/18.

## Statement (all finite binary laws)

Let V be any nonempty finite coordinate type and \(\nu\) a full-support probability law on \(\{-1,+1\}^V\). Denote \(\overline m_i=\mathbb E X_i\), \(m_i(x_{-i})=\mathbb E[X_i\mid X_{-i}=x_{-i}]\), \(v_i(x_{-i})=1-m_i(x_{-i})^2\). The native influence is \(I_{\nu,i}(h)=\mathbb E_\nu\operatorname{Var}_\nu(h\mid X_{-i})\).

Assume a heat-bath Poincaré gap \(0<\gamma\le 1\) with \(\gamma\operatorname{Var}_\nu(h)\le\sum_i I_{\nu,i}(h)\) for all h. Assume \(v_i\ge v>0\) and \(L\ge\lVert I+C^\mathsf T\rVert_{2\to2}\), where \(C_{ij}\) is the maximal conditional-TV response of the conditional law at i to flipping j, and \(C_{ii}=0\). We may take \(L=1+\sqrt{\lVert C\rVert_1\lVert C\rVert_\infty}\), even if the Dobrushin row/column sums exceed one.

For every algebraic quadratic \(f=c+\sum_i a_iX_i+\sum_{i<j}b_{ij}X_iX_j\), pointwise bounded \(|f|\le B\), the independent finite product Q2 theorem (coefficient \(K_0\)) implies

\[
\boxed{\operatorname{Var}_{\nu}(f)^2\le \frac{4L^2}{v^7\gamma^5} K_0 B^2\max_i I_{\nu,i}(f).}
\]

A more precise version keeps \(\beta=\min_i\operatorname{Var}_\nu X_i\) and replaces \(v^7\) by \(\beta^4 v^3\). But \(\beta\ge v\) follows automatically from total variance. The bound is **dimension-free only when \(v,\gamma,L\) remain uniformly controlled**; it is not a bound uniform across all dependent laws.

## Proof architecture (law-level analytic, NOT kernel-checked as a whole)

1. Choose \(\mu=\otimes_i\nu_i\), the product of the *actual* one-site marginals, so biases need not vanish. Set \(Y_i=X_i-\overline m_i\) and \(\sigma_i^2=\mathbb E Y_i^2\ge\beta\ge v\). Reexpand \(f=c'+\sum_i A_iY_i+\sum_{i<j}b_{ij}Y_iY_j\), where \(A_i=a_i+\sum_{j\neq i}b_{ij}\overline m_j\). This preserves algebraic degree two and the original pointwise B bound.
2. Poincaré on \(\sum_i a_iY_i\) gives \(\operatorname{Cov}_\nu(X)\preceq\gamma^{-1}I\).
3. Define conditional scores \(R_i=X_i-m_i(X_{-i})\), \(S_a=\sum_i a_iY_i\), \(T_a=\sum_i a_iR_i\). Conditional orthogonality gives \(\mathbb E S_aT_a=\sum_i a_i^2\mathbb E v_i\ge v\lVert a\rVert^2\). A single flip in coordinate j changes \(T_a\) by at most \(2(|a_j|+\sum_{i\ne j}C_{ij}|a_i|)\), hence \(\sum_j I_{\nu,j}(T_a)\le L^2\lVert a\rVert^2\). Poincaré and Cauchy yield \(\operatorname{Cov}_\nu(X)\succeq \alpha I\) with \(\alpha=v^2\gamma/L^2\le1\).
4. Writing \(g_i=a_i+\sum_{j\ne i}b_{ij}X_j=A_i+\sum_{j\ne i}b_{ij}Y_j\), the *actual* influence is \(I_{\nu,i}(f)=\mathbb E[v_i g_i^2]\). From Step 2 and Poincaré, \(\operatorname{Var}_\nu(f)\le \gamma^{-1}(\sum_i A_i^2+2\gamma^{-1}\sum_{i<j}b_{ij}^2)\). Independence of \(\mu\) gives \(\operatorname{Var}_\mu(f)=\sum_i\sigma_i^2 A_i^2+\sum_{i<j}\sigma_i^2\sigma_j^2b_{ij}^2\). Therefore \(\operatorname{Var}_\nu(f)\le 2/(\gamma^2\beta^2)\operatorname{Var}_\mu(f)\le2/(\gamma^2 v^2)\operatorname{Var}_\mu(f)\).
5. From Step 3, \(\mathbb E_\nu g_i^2=A_i^2+b_i^\mathsf T\operatorname{Cov}_\nu(X_{-i})b_i\ge\alpha\mathbb E_\mu g_i^2\), so \(I_{\nu,i}(f)\ge v\alpha I_{\mu,i}(f)=(v^3\gamma/L^2)I_{\mu,i}(f)\). Squaring Step 4 and composing the finite matched-product Q2 theorem proves the displayed result.

## Exact audit

The independent rational source `dq2_v4_bias_gap_exact.py` directly enumerates eight finite binary laws, including arbitrary biases, odd 3-body interactions, frustrated cycles, and two complete four-vertex graphs whose **actual** conditional-TV Dobrushin coefficient is \(9/4>1\). For the two latter instances, all-function heat-bath PSD certificates establish \(\gamma=1/512\) and \(\gamma=1/32\). Every case verifies whole quadratic covariance PSD, all native influence PSD, spin covariance coercivity, exact conditional gradients, and \(\beta\ge v\). Zero-pivot PSD handling is exact rational. Source SHA-256 `29a386e1e4d6e302d8c0e00722c515a1677df60951ac64574e55e944ef792ceb`; result JSON SHA-256 `d9679a24fc6303134c091e11127adc0e716977d45a14e505c8d2c9bfd3b73db3`.

## Lean certificate gate

Current source `research/nightfall/formalization/dq2/DQ2HeatBathScoreTransfer.lean` in GitHub PR #786. GitHub Actions run **44209385471** compiled four named scalar implication declarations on pinned Lean 4.36.0-rc2 / Mathlib revision `9d581dfff2e41de989072ea63abf3daf69311520`; exact source SHA-256 `2e619eea0c471004822de8e15439e223a33393be2663ec55975094bec37c5d0d`; only foundational axioms (`propext`, `Classical.choice`, `Quot.sound`). These implications **assume** the Poincaré and variance/influence comparisons, so they are not a complete all-law DQ2 Lean theorem.

## Assumptions removed and retained

**Removed as independent hypotheses:** trees, path uniqueness, pairwise Ising, no cycles, global spin-flip symmetry, zero marginal means, separate marginal variance floor, and strict Dobrushin \(\delta<1\) (a direct positive spectral-gap certificate replaces it). Full support need not be listed separately if a positive local-variance floor is required at every supported section: the cube's single-flip connectivity forces every atom into support.

**Still necessary for this proof:** finite binary coordinate spaces; algebraic degree ≤2; boundedness \(|f|\le B\); positive local conditional uncertainty; positive heat-bath spectral gap; finite score-sensitivity norm; a source-certified finite product Q2 input. A dimension-free *family* additionally needs \(\gamma,v,L\) bounded uniformly in system size. An infinite dependent-law lifting argument, arbitrary-alphabet vector scores, degree ≥3, and near-sharp \(K(\delta)\to K_0\) perturbative comparison are **not established**.

## Related work / priority

The 2021 COLT result on robust Ising learning under Dobrushin assumptions is by **Diakonikolas, Kane, Stewart, and Sun**, and covers nonzero external fields: https://proceedings.mlr.press/v134/diakonikolas21e.html . General influence inequalities for mixing measures and results about spectral independence are also prior art. No novel-priority assertion. A same-day claim comparison and external mathematical review are required for that gate.