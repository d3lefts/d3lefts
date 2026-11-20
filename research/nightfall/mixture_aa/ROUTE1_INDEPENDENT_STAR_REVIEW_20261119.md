# NIGHTFALL external-to-author review — Route 1 product-mixture AA (2026-11-19)

**Reviewer role:** independent AI proof attack. **Source:** original Route 1 note at [d3lefts/d3lefts@ac8b92df211b946bcd32cb6ed734ecb9b41368ee](https://github.com/d3lefts/d3lefts/blob/ac8b92df211b946bcd32cb6ed734ecb9b41368ee/research/nightfall/mixture_aa/ROUTE1_PROOF_20261119.md), author Claude Opus 5.5. **Review result:** key lemma and stopping-potential proof are valid **at paper level** under the expressly stated row/degree/product-AA inputs. No counterexample was found. New, simpler *reference-star maximal coupling* is constructed below and strengthens the constant. This is NOT Lean certification of Route 1, a human referee report, or novelty clearance.

## Theorem independently reconstructed

Let \(\nu=\sum_{\theta=1}^{M}\pi_\theta\bigotimes_{j=1}^{n}p_{\theta,j}\) be any finite mixture of product laws on nonempty finite alphabets, allowing zero atoms and zero mixture weights. Let \(f:\prod_j\Sigma_j\to[0,1]\) have **algebraic coordinate degree** at most \(d\ge1\), i.e. an expansion \(f=\sum_{|S|\le d}f_S(x_S)\). For every \(0<\varepsilon,\delta<1\), a deterministic classical coordinate-query decision tree of depth at most
\[
\left\lceil\frac2\delta\left(
\frac{2d^2}{2\gamma}+
\frac{\log M}{(\gamma/C_d)^3}\right)\right\rceil,\quad
\tau=\varepsilon^2\delta/2,\quad
\gamma=\frac{\sqrt{3/12500}\,\tau^{5/2}}{(\pi^2(d+1)^2)^3},\quad
C_d=d^2(\pi^4/4+4),
\]
outputs a number within \(\varepsilon\) of \(f(x)\) except with \(\nu\)-probability at most \(\delta\). This is \(O((d^8\tau^{-5/2}+d^{24}\tau^{-15/2}\log M)/\delta)\). For \(d=0\), \(f\) is constant and needs no queries.

**Input #1 (existing kernel-certified theorem, not independently reproved here):** every bounded finite-product algebraic-degree-\(d\) function has a nonnegative row \(a_j(x)\) with \(\sum_j a_j(x)\le \pi^2d^2\) and \(|f(x)-f(y)|\le\sum_{j:x_j\ne y_j}a_j(x)\), and \(\sum_j\operatorname{osc}_j(z)\le4d^2\) for [0,1]-valued functions, from PR #310 \`RowBound.product_row_bound\` / \`product_block_inequality\`. That source is stated for a **common** finite alphabet. To apply it to heterogeneous alphabets, embed every \(\Sigma_j\) in their finite disjoint union \(A\), choose a default \(\sigma_j\), and define a coordinatewise retraction \(r_j:A\to\Sigma_j\). Extend \(f\) by \(F(a)=f((r_j(a_j))_j)\). The extension retains its range and algebraic coordinate degree and the row inequality restricts to the original coordinates. This paper-level finite retraction transfer should be made an explicit Lean bridge.

**Input #2 (existing kernel-certified theorem):** PR #858 \`Nightfall.InfinitePiAAProductTerminal.infinitePi_aa_product\`, for arbitrary product probability spaces including zero atoms, ES degree \(D\) and \(|G|\le1\), asserts \(3\operatorname{Var}(G)^5\le12500(\pi^2D^2)^6(\sup_i\mathrm{Inf}_i)^2\). This yields \(\gamma(\tau,D)\) above. Exact theorem type reviewed.

## 1. Constructive finite maximal reference-star coupling (new improvement)

At a current decision-tree node fix posterior weights \(\pi_\theta\) and component coordinate laws \(p_{\theta,j}\). Define \(q_j=\sum_\theta\pi_\theta p_{\theta,j}\). For **each** \(\theta,j\), abbreviate \(p=p_{\theta,j}\), \(q=q_j\), \(c(a)=\min\{p(a),q(a)\}\), and \(\Delta=1-\sum_a c(a)=\operatorname{TV}(p,q)\).

For \(q(a)>0\), if \(\Delta>0\), define the conditional kernel
\[
K_\theta(b\mid a)=\frac{c(a)}{q(a)}\mathbf1_{b=a}
+\frac{q(a)-c(a)}{q(a)}\frac{p(b)-c(b)}{\Delta}.
\tag{1}
\]
If \(\Delta=0\), choose \(K_\theta(b\mid a)=\mathbf1_{b=a}\). If \(q(a)=0\), define \(K_\theta(\cdot\mid a)\) arbitrarily (the reference never visits this atom).

Draw \(\bar X_j\sim q_j\) and, conditionally on \(\bar X_j=a\), draw \(Y_{\theta,j}\sim K_\theta(\cdot\mid a)\) **independently for the finitely many \(\theta\)**. Let \(u_j=(\bar X_j,(Y_{\theta,j})_\theta)\) be a single finite-alphabet seed; draw the \(u_j\) independently across coordinates and independently of the label \(\Theta\sim\pi\). Define \(\bar h_j(u_j)=\bar X_j\), \(h_j(\theta,u_j)=Y_{\theta,j}\).

**Exact marginal proof.** For each \(b\),
\[
\Pr(Y_{\theta,j}=b)=c(b)+\Big(\sum_a(q(a)-c(a))\Big)\frac{p(b)-c(b)}{\Delta}
=c(b)+(p(b)-c(b))=p(b).
\]
In the residual branch, \(\bar X_j=a\) requires \(q(a)>c(a)=p(a)\), whereas \(Y_{\theta,j}=a\) would require \(p(a)>c(a)=q(a)\), impossible. The residual branch therefore always mismatches; it has probability \(\Delta\). Hence
\[
\Pr(h_j(\theta,u_j)\ne\bar h_j(u_j))=\operatorname{TV}(p_{\theta,j},q_j),
\]
**not \(2\operatorname{TV}\)**. This star coupling is exact for any finite number of component laws, including zero atoms. Pairwise optimality *between two arbitrary components* is unnecessary. The finite seed avoids continuous common uniforms, exponentially distributed clocks or a KT/Holenstein external theorem.

## 2. Switching-time inequality

For any [0,1]-valued coordinate-degree-\(d\) function, the row theorem's product-block inequality implies
\[
\sum_j \operatorname{osc}_j(z)\le4d^2,\qquad
\operatorname{osc}_j(z):=\max_{a,b}|f(z^{j\leftarrow a})-f(z^{j\leftarrow b})|.
\]
Proof of this constant: for any fixed \(z\), choose \(a_j,b_j\) maximizing the oscillation, split the difference through \(f(z)\); each of the two families of single-coordinate changes has sum at most \(2d^2\) for an [0,1]-valued function by affine scaling of \`product_block_inequality\`.

Now for random pairs \((X_j,Y_j)\) that are independent across \(j\), independently choose uniform switching times \(T_j\in[0,1]\). Let \(Z(t)\) use \(Y_i\) at sites with \(T_i\le t\) and \(X_i\) elsewhere. At the jump of coordinate \(j\), the event \(\{X_j\ne Y_j\}\) is independent of \(T_j\) and the other coordinates. Since \(\operatorname{osc}_j\) ignores coordinate \(j\), one can bound the expected jump by \(q_j E[\operatorname{osc}_j(Z(t))]\), where \(q_j=\Pr(X_j\ne Y_j)\). Sum over \(j\), integrate \(t\in[0,1]\), and use the pointwise oscillation budget:
\[
\mathbb E|f(X)-f(Y)|\le4d^2\max_j q_j. \tag{2}
\]
No independence between \(X_j\) and \(Y_j\) *inside* a pair is required.

## 3. M-free latent-label lemma — strengthened

Define \(I_j=I(\Theta;X_j)=\sum_\theta\pi_\theta\operatorname{KL}(p_{\theta,j}\|q_j)\), \(I_*=\max_j I_j\), and
\[
\phi_{\theta,j}=\arccos\sum_a\sqrt{p_{\theta,j}(a)q_j(a)}.
\]
As usual \(\phi^2\le(\pi^2/4)\operatorname{KL}(p_{\theta,j}\|q_j)\) and \(\operatorname{TV}(p_{\theta,j},q_j)\le\sin\phi\le\phi\).
For \(0<\eta\le1\), define deterministic \(L_\theta=\{j:\phi_{\theta,j}>\eta\}\). Sample common independent seeds \(u_j\) from section 1, set \(\bar x=\bar h(u)\), \(y=h(\theta,u)\) and \(z_j=y_j\) on \(L_\theta\), \(z_j=\bar x_j\) otherwise.

**Large-angle bound.** The row \(a(\bar x)\) is independent of \(\theta\), because \(\bar x\) is a coordinatewise component-independent reference. Pointwise in \(u\),
\[
E_\Theta|f(\bar x)-f(z)|
\le\sum_j a_j(\bar x)\Pr_\Theta(j\in L_\Theta)
\le\pi^2d^2\max_j\Pr_\Theta(\phi_{\Theta,j}>\eta)
\le \frac{\pi^4d^2}{4\eta^2}I_*.
\]
The max is *outside* the component average, so there is no invalid interchange.

**Small-angle bound.** For fixed \(\theta\), the pairs \((z_j,y_j)\) remain independent across coordinates (since \(L_\theta\) is deterministic), and mismatch only for \(j\notin L_\theta\), at rate
\(\operatorname{TV}(p_{\theta,j},q_j)\le\phi_{\theta,j}\le\eta\).
Equation (2) gives \(E_u|f(z)-f(y)|\le4d^2\eta\) *for every component*. Combine:
\[
\boxed{E_{\Theta,u}|f(h(\Theta,u))-f(\bar h(u))|
\le \frac{\pi^4d^2}{4}\frac{I_*}{\eta^2}+4d^2\eta.}\tag{3}
\]
For \(0<I_*\le1\), take \(\eta=I_*^{1/3}\). If \(I_*=0\), every positive-mass component equals the reference at each coordinate, and the difference is zero. If \(I_*>1\), the trivial [0,1] range bound \(E|\cdot|\le1\le C_d I_*^{1/3}\) suffices. Thus
\[
E_{\Theta,u}|f(h(\Theta,u))-f(\bar h(u))|
\le C_d I_*^{1/3},\quad C_d=(\pi^4/4+4)d^2.\tag{4}
\]

## 4. Product-AA lift, crux, and stopping-potential audit

Choose an algebraic degree expansion \(f(x)=\sum_{|S|\le d} f_S(x_S)\). Define \(G(\theta,u)=f(h(\theta,u))\) on the product probability space \(\pi\otimes\bigotimes_j\lambda_j\). Every summand becomes a function of only the label \(\theta\) and seeds \((u_j)_{j\in S}\); thus it depends on at most \(d+1\) independent coordinates. Consequently every iterated residual on \(d+2\) distinct lifted coordinates annihilates \(G\), so \(ESDegreeLE\, (d+1)\) holds. \(G\in[0,1]\), and \(G\) has the exact \(f(X)\) law under \(\nu\), including zero atoms.

If \(\operatorname{Var}_\nu f\ge\tau\), the kernel-certified product theorem yields a lifted coordinate with influence \(\ge\gamma=\sqrt{3/12500}\,\tau^{5/2}/(\pi^2(d+1)^2)^3\). Since \(\operatorname{Inf}_c(G)=\tfrac12E(G-G^{(c)})^2\le\tfrac12 E|G-G^{(c)}|\):

- If the influential coordinate is a seed \(u_j\), its complete resampling at fixed \(\theta\) redraws \(X_j\sim p_{\theta,j}\) independently, hence \(E_\theta L_j^{p_\theta}(f)\ge2\gamma\).
- If it is \(\theta\), resampling \(\theta'\sim\pi\) independently with the same \(u\) gives \(2\gamma\le E|G(\theta,u)-G(\theta',u)|\le2 C_d I_*^{1/3}\) by (4) twice. Thus some **observable** \(j\) has \(I_j\ge(\gamma/C_d)^3=:\kappa\).

At any tree node, the conditional law after an observed coordinate remains a mixture of products and the restricted \(f\) remains bounded degree \(\le d\). Define
\[
\Phi=E_\theta\sum_i L_i^{p_\theta}(f_\rho)\le2d^2,\qquad H=-\sum_{\theta:\pi_\theta>0}\pi_\theta\ln\pi_\theta\le\ln M.
\]
The \(\Phi\) bound follows by applying the [0,1] scaled \(2d^2\) one-block inequality *pointwise* and averaging. If coordinate \(j\) is queried, the expected next \(\Phi\) is exactly \(\Phi-E_\theta L_j^{p_\theta}(f_\rho)\). For all observed values \(a\) with \(q_j(a)>0\) the posterior is \(\pi_{\theta|a}=\pi_\theta p_{\theta,j}(a)/q_j(a)\), and values with \(q_j(a)=0\) simply do not enter the expectation. The entropy chain rule, including zero-posterior components, is therefore exactly \(H-E_aH(\pi_{\cdot|a})=I_j\).

Thus the *single* combined nonnegative potential \(V=\Phi/(2\gamma)+H/\kappa\) drops by at least one **in conditional expectation** whenever \(\operatorname{Var}_\nu f_\rho>\tau\). A previously queried coordinate cannot be selected because its seed increment and latent information are both zero. Hence the stopping time is in fact bounded by \(n\), and the telescoping/optional-stopping argument is finite and legitimate:
\[
E N\le V_0\le 2d^2/(2\gamma)+(\ln M)/\kappa.
\]
Stop when the conditional variance drops below \(\tau\), output the posterior conditional mean. If necessary forcibly stop at depth \(D_{\max}=\lceil2V_0/\delta\rceil\). The probability of premature stopping is at most \(\delta/2\) by Markov; conditional Chebyshev on non-forced leaves gives an error greater than \(\varepsilon\) with probability \(\le\tau/\varepsilon^2=\delta/2\). Sum gives \(\delta\). This proves the stated query-depth theorem, *conditional on the cited kernel-certified row and AA inputs*.

## Explicit proof review conclusions

1. **No mathematical counterexample or unfixable gap found** in the Route 1 crux or stopping-time argument. Its large-angle averaging, degree-\(d+1\) lift and zero-posterior potential identities check out on paper.
2. **Real improvement:** the exact finite reference-star coupling replaces the KT/Holenstein pairwise-consistency construction and improves \(8d^2\eta\to4d^2\eta\). This avoids any need to sample continuous seed spaces or cite correlated-sampling literature. It is a new proof operator in this review, **not a claim of publication novelty**.
3. **Source bridge needing attention:** PR #310 row theorem is for a common finite alphabet, while the theorem targets heterogeneous alphabets. The disjoint-union retraction above fills the paper gap but is not yet a Lean-certified bridge.
4. **Input theorem:** PR #858 product-AA declaration and its exact type were inspected, including ES degree on the original L² source, and were reported kernel-checked by its source CI. This review did not replay Lean on the new mixture lift.
5. **Asymptotic conventions:** \(I_*=0\), \(I_*>1\), zero components, \(d=0\), and \(\delta\in(0,1)\) have explicit cases; exact hidden constant \(C_d\) only affects polynomial factors.
6. **Priority still open.** A dated public search located Girish–Mittal–Nehoran–Raz, *Distributional Variants of the Aaronson–Ambainis Conjecture* (arXiv:2609.35327), which addresses biased product and slice laws, not the stated finite-mixture theorem in its abstract. This is NOT a comprehensive novelty clearance. The Bernstein–Vazirani \(\Omega(\log M)\) lower-bound claim needs a separate rigorous average-case linear-query lower bound before being labeled tight.

## Reproduction / finite adversarial replay

Run \`python3 scripts/audit_route1_star_coupling.py\`. Independent standard-library exact-Fraction checker:

- 7,140 pairs of arbitrary distributions with alphabets 2,3,4 and masses from {0,1,2}, checking both marginals and mismatch **exactly** equals TV;
- a four-component star with a zero mixture weight and absent reference atom;
- a three-component four-coordinate degree-two [0,1]-valued function, checking the \(\Phi\) decrease on **every queried coordinate** as an exact rational equality, including posterior zeros; numerical entropy monotonicity is a separate sanity check.

**Checker limitations:** finite examples do not prove the analytic \(\pi^2 d^2\) row theorem, product-AA influence theorem, or the asymptotic decision-tree guarantee. This note is a complete **author-side review construction**, not independent human peer review or new Lean certification.