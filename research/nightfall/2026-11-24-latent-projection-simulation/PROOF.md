# Latent projection and two-potential bounds for dimension-free classical simulation

**NIGHTFALL research manuscript — v0.1, 2026-11-24 (US Central time).**
Research directed by Devin J. Wright; derivation and drafting assisted by ChatGPT.
**Status:** complete paper-level candidate proof, dependent on two published product-space results; author-side algebraic review only. Not independently reviewed, not end-to-end Lean certified, and not cleared for external publication or historical priority.

## Abstract

Let \(X\) have an arbitrary law \(\nu\) on a finite product alphabet, and let \(f\) be globally \([0,1]\)-valued with interaction degree at most \(d\). We prove a deterministic original-coordinate query bound
\[
O(d^7\tau^{-3/2}+d^6 C_W(\nu)\tau^{-3})
\]
for mean squared error \(\tau\), where \(C_W\) is multivariate Wyner common information in nats. For degree two the first term improves to \(O(\tau^{-1})\). Consequently additive error \(\varepsilon\) outside probability \(\delta\) requires
\[
O(d^7\varepsilon^{-3}\delta^{-3/2}
+d^6 C_W(\nu)\varepsilon^{-6}\delta^{-3}),
\]
and in the quadratic case
\(O(\varepsilon^{-2}\delta^{-1}+C_W(\nu)\varepsilon^{-6}\delta^{-3})\).
The key is to project away the latent label before applying the product influence theorem, then account for the remaining latent variance directly via a switching inequality. A squared-influence potential and a residual mutual-information potential permit geometrically staged reduction of the expected posterior variance. No latent query is used. These are nonuniform query-count bounds, not runtime bounds.

## 1. Model and inputs to the proof

Let \(X\sim\nu\) on \(\Omega=\prod_{j=1}^n A_j\), where each \(A_j\) is finite and nonempty. A degree-\(d\) function is a sum of functions depending on at most \(d\) coordinates. Assume \(f:\Omega\to[0,1]\) globally, including off the support of \(\nu\). A query returns one original coordinate symbol. The tree and its numerical leaf outputs may depend on the entire known law and target; the unknown input is the only information queried. All logarithms are natural. Degree zero, an empty coordinate set, or a constant target on the support require no queries.

For a product law \(P\), let \(I_j^P(g)=\frac12\mathbb E(g(X)-g(X^{(j)}))^2\), where coordinate \(j\) is independently resampled. We use two results of the companion manuscripts [W,Q]:

* [W, Lemma 3.1]: for \(|g|\le1\), degree at most \(d\ge1\), and positive variance \(u\), some \(j\) has \(I_j^P(g)\ge c_0 d^{-6}u^{5/2}\), where \(c_0=\sqrt{3/12500}/\pi^6\).
* [W, Lemma 3.2]: for every \(x\in\Omega\) and degree-\(d\) function \(g:\Omega\to[0,1]\) there are nonnegative weights \(a_i(x)\) with \(\sum_i a_i(x)\le K_d=\pi^2d^2/2\) and \(|g(x)-g(y)|\le\sum_{i:x_i\ne y_i}a_i(x)\) for all \(y\).
* [Q, Theorem 1.1]: for degree at most two, \(\operatorname{Var}_P(g)^2\le C_2 B^2\max_i I_i^P(g)\) whenever \(|g|\le B\) on the positive support, with an explicit constant \(C_2\). Only the certified upper bound \(C_2<105.42\) is used here; to avoid transcription ambiguity we set \(C=106\), a rational strict upper bound. Thus \(I_i^P(g)\ge 4u^2/C\) for some \(i\) if \(0\le g\le1\), by applying the theorem to \(g-1/2\).

The following argument uses \(C=106\) throughout. The first two lemmas apply to arbitrary finite heterogeneous alphabets (a coordinatewise embedding into a common alphabet with retractions is also possible).

## 2. Exact finite latent reduction

Write \(C_W(\nu)=\inf I(\Theta;X)\) over joint extensions rendering the \(X_j\) conditionally independent. This infimum is attained by a finite mixture. Indeed the product-law space \(\mathcal P\) is compact, and \(P\mapsto(P,H(P))\) is continuous into a finite-dimensional real vector space. Its convex hull is compact by Carathéodory's theorem. The barycenter of any mixing measure lies in this hull. Above the fixed vector \(\nu\), maximize the entropy coordinate in the compact nonempty fiber (point masses supply feasibility). The maximizing point has a finite convex representation and minimizes \(H(\nu)-\mathbb E H(P_\Theta)\). Any arbitrary auxiliary variable induces such a mixing measure by its conditional probability vectors; conversely every mixture is admissible. Thus fix a minimizing finite mixture \(\nu=\sum_\theta\pi_\theta P_\theta\), with \(P_\theta=\bigotimes_j p_{\theta j}\), and \(J_0=I(\Theta;X)=C_W(\nu)\). This is the reduction of [W, Section 5.2].

## 3. Projection and switching

The following lemma is applied to any posterior mixture and any current section \(g\). For notational simplicity omit the history. Let \(q_j=\sum_\theta\pi_\theta p_{\theta j}\). For each coordinate independently, draw a finite seed \(U_j=(R_j,(Y_{\theta j})_\theta)\) such that \(R_j\sim q_j\), \(Y_{\theta j}\sim p_{\theta j}\), and
\[
\Pr(R_j\ne Y_{\theta j})=\operatorname{TV}(p_{\theta j},q_j).
\]
Construct it by taking a maximal coupling for each label with common reference \(R_j\), then sampling its conditional kernels given \(R_j\). Kernels at zero reference mass can be arbitrary. Let the independent label have distribution \(\pi\). The seeds are mutually independent and independent of the label.

Set \(G(\theta,U)=g(Y_\theta(U))\), \(F(U)=\mathbb E_\Theta G(\Theta,U)\). The law of \(G\) equals that of \(g(X)\). For each fixed label the composition of a cylinder term with \(Y_\theta\) depends on precisely the same subset of seed coordinates or fewer. Finite averaging preserves the degree-\(d\) subspace. Consequently \(F\) has degree at most \(d\), takes values in \([0,1]\), and
\[
v:=\operatorname{Var}(g(X))=\operatorname{Var}_U(F)+L,\qquad
L:=\mathbb E_U\operatorname{Var}_\Theta(G).
\]
The letter \(L\) here denotes latent variance, not the absolute increment potential of [W].

### Lemma 3.1 (projection contraction).

For each coordinate \(j\),
\[
I_j(F)\le\sum_\theta\pi_\theta I_j^{P_\theta}(g).
\]
**Proof.** Independently replace \(U_j\) by an identical-law seed. For the same pair of seed vectors, \(F(U)-F(U^{(j)})\) is the label-average of \(G(\theta,U)-G(\theta,U^{(j)})\). Jensen for the square and integration give the inequality. For fixed \(\theta\), the resulting \(Y_\theta\) pair is exactly the independent coordinate resampling under \(P_\theta\). End proof.

### Lemma 3.2 (small independent switches).

If independent coordinate pairs \((B_i,D_i)\) satisfy \(\Pr(B_i\ne D_i)\le\eta\le1/2\), then
\[
\mathbb E(g(B)-g(D))^2\le4d^2\eta.
\]
**Proof.** If \(\eta=0\) the claim is immediate. Write each pair law \(\rho_i=(1-\eta)\sigma_i+\eta\lambda_i\), with \(\sigma_i\) its normalized diagonal restriction and \(\lambda_i\) a probability law, possible since diagonal mass is at least \(1-\eta\). Interpolate the pair laws with parameter \(t\in[0,1]\). The expected squared difference \(p(t)\) has degree at most \(2d\): on the pair alphabet \(g(B)-g(D)\) has degree at most \(d\), and multiplying cylinder terms adds at most their support sizes. Expectation of a cylinder under the interpolated product is a polynomial of degree at most its support size. Thus \(0\le p(t)\le1\) on \([0,1]\), \(p(0)=0\). The classical Markov polynomial inequality on \([-1,1]\) for \(2p((s+1)/2)-1\) gives \(|p'(t)|\le(2d)^2\). Integrate from 0 to \(\eta\). This is the sharper written coefficient in [W, proof of Lemma 4.1], not the weaker coefficient used in that paper's Lean terminal. End proof.

### Lemma 3.3 (rare-switch estimate).

Suppose for every coordinate \(j\), \(\Pr_\Theta(\operatorname{TV}(p_{\Theta j},q_j)>\eta)\le w\). Then
\[
L\le\mathbb E(G-g(R))^2\le(\sqrt{K_dw}+2d\sqrt\eta)^2.
\]
**Proof.** The first inequality is conditional least-squares optimality of \(F(U)\); \(g(R)\) is a function of \(U\). For each label, let \(S_\theta=\{j:\operatorname{TV}(p_{\theta j},q_j)>\eta\}\), and form \(Z_\theta\) by replacing \(R_j\) with \(Y_{\theta j}\) on \(S_\theta\) only. Given a fixed seed vector, [W, Lemma 3.2] and \(|g(R)-g(Z_\theta)|\le1\) yield
\[
\mathbb E_\Theta(g(R)-g(Z_\Theta))^2
\le \sum_j a_j(R)\Pr_\Theta(j\in S_\Theta)\le K_dw.
\]
For fixed \(\theta\), the pairs \((Z_{\theta j},Y_{\theta j})\) are independent across coordinates. They agree on \(S_\theta\), and elsewhere have mismatch probability at most \(\eta\). Lemma 3.2 gives the squared norm bound \(4d^2\eta\), also after averaging labels. Minkowski in joint \(L^2(\Theta,U)\) gives the stated result. End proof.

### Theorem 3.4 (observable energy / latent information dichotomy).

If \(v>0\), some original coordinate \(j\) satisfies one of the following:
\[
\mathbb E_\Theta I_j^{P_\Theta}(g)\ge av^p,\qquad
I(\Theta;X_j)\ge bv^3 ,
\]
where in general \(p=5/2,\ a=2^{-5/2}c_0d^{-6}\); for degree at most two take \(p=2,\ a=1/C\). In both cases \(b=(2916K_dd^4)^{-1}\).

**Proof.** If \(\operatorname{Var}(F)\ge v/2\), apply the product influence bound to \(F\) (in the quadratic case apply it to \(F-1/2\)). Lemma 3.1 transfers the resulting influence to the same original coordinate, giving \(av^p\).

Otherwise \(L>v/2\). Choose \(w=v/(18K_d)\), \(\eta=v/(18d^2)\), which are positive and admissible since \(v\le1/4\). If every coordinate had the rare-switch probability at most \(w\), Lemma 3.3 would imply
\[
L\le(\sqrt{v/18}+2\sqrt{v/18})^2=v/2,
\]
a contradiction. Thus some \(j\) has rare-switch probability greater than \(w\), and \(\mathbb E_\Theta\operatorname{TV}(p_{\Theta j},q_j)^2>w\eta^2\). The KL representation of mutual information and Pinsker in nats give \(I(\Theta;X_j)\ge2\mathbb E_\Theta\operatorname{TV}^2>2w\eta^2=bv^3\). Zero-weight labels are omitted, and \(q_j\) dominates every positive-weight component, so the KL expressions are well-defined. End proof.

## 4. Exact drift under a legal query

At a positive-probability transcript \(h\) of a deterministic original-coordinate tree, the event of reaching \(h\) is exactly the cylinder specified by its revealed coordinates. Conditional on the label and transcript, unrevealed coordinates remain independent, with their component marginals unchanged. The section \(g_h\) remains globally bounded and degree at most \(d\). Define
\[
v(h)=\operatorname{Var}(f(X)\mid h),\quad
P(h)=\mathbb E_{\Theta\mid h}\sum_{i\ \mathrm{unread}}I_i^{P_\Theta}(g_h),\quad
J(h)=I(\Theta;X_{\mathrm{unread}}\mid h).
\]
The degree-weighted Hoeffding identity on a product law gives \(\sum_i I_i(g)=\sum_{S\ne\varnothing}|S|\|g_S\|_2^2\le d\operatorname{Var}(g)\); therefore \(0\le P(h)\le d\,v(h)\) by total variance. If \(h'\) is the child after observing \(X_j\), then
\[
P(h)-\mathbb E[P(h')\mid h]=\mathbb E_{\Theta\mid h} I_j^{P_\Theta}(g_h),
\quad
J(h)-\mathbb E[J(h')\mid h]=I(\Theta;X_j\mid h).
\]
For the first equality, condition on a label. The influence of every unread coordinate \(i\ne j\) is preserved in expectation when averaging the section over the revealed \(j\)-symbol, because independent resampling of \(i\) commutes with conditioning on \(j\). The \(j\)-influence disappears. Average over the posterior label using the tower property. The second equality is the mutual-information chain rule. Both potentials are nonnegative supermartingales under any legal query. Also \(v(h)\) is a supermartingale in the conditional-expectation sense by total variance; it need not decrease on every individual branch.

Use Theorem 3.4 at every positive-variance node to choose an energy-type or information-type query. Fix a deterministic ordering to resolve choices; only the law and current history are used. Freeze zero-variance nodes and nodes with no unread coordinates. Impossible transcripts terminate arbitrarily. This defines one deterministic policy; no seed or label is accessed in execution.

## 5. Staged drift theorem and explicit budgets

Let \(H_t\) be the frozen transcript at level \(t\), \(V_t=\mathbb E v(H_t)\), and let \(A_t,B_t\) be the events that the next query is of energy or information type. They partition positive-variance histories; on frozen histories the variance is zero. For any block of \(m\ge1\) levels starting at \(t=s\), telescope the two drift identities to obtain
\[
\sum_{t=s}^{s+m-1}\mathbb E[v(H_t)^p1_{A_t}]
\le d V_s/a,\qquad
\sum_{t=s}^{s+m-1}\mathbb E[v(H_t)^3 1_{B_t}]
\le J_0/b .
\]
The second bound uses the expected residual information at block start, which is no larger than \(J_0\). Average over levels and use Hölder on the joint law of a uniform level and its transcript:
\[
V_{s+m}\le\frac1m\sum_{t=s}^{s+m-1}V_t
\le (d V_s/(am))^{1/p}+(J_0/(bm))^{1/3}.
\tag{5.1}
\]
No pointwise variance monotonicity is assumed.

For \(0<\tau<1/4\), put \(r_j=2^{-j}/4\) and let \(N\) be the least integer with \(r_N\le\tau\). Since \(V_0\le1/4\), inductively use a block of length
\[
m_j=\left\lceil
\max\{1,\,4^p d\,r_j^{1-p}/a,\,64 J_0/(b r_j^3)\}
\right\rceil,\quad 0\le j<N.
\]
If \(V_s\le r_j\), each term on the right of (5.1) is at most \(r_j/4\); hence \(V_{s+m_j}\le r_j/2=r_{j+1}\). Summing and using \(r_{N-1}>\tau\) gives a deterministic depth bound
\[
q\le N+
\frac{4^p d}{a(1-2^{-(p-1)})}\tau^{-(p-1)}
+\frac{64J_0}{b(1-2^{-3})}\tau^{-3}.
\tag{5.2}
\]
Here the two nontrivial lower bounds in the maximum are positive and the energy bound is at least one for the specified \(a,p,d,r_j\); alternatively replace \(N\) by \(2N\) for arbitrary positive \(a\). If all coordinates are read earlier, freeze; the actual depth is at most the minimum of \(n\) and the integer sum of block lengths. At terminal leaves output the conditional mean, which lies in \([0,1]\); its squared-error risk is precisely \(V_q\le\tau\). For \(\tau\ge1/4\) the root mean suffices.

Substituting \(J_0=C_W(\nu)\) into (5.2), and absorbing \(N=O(1+\log(1/\tau))\) for \(0<\tau<1/4\), proves the main result:
\[
q=O(d^7\tau^{-3/2}+d^6 C_W(\nu)\tau^{-3}).
\]
For \(d\le2\) use the quadratic case, giving \(q=O(\tau^{-1}+C_W(\nu)\tau^{-3})\). Taking \(\tau=\varepsilon^2\delta\) for positive \(\varepsilon,\delta\le1\) and applying Markov to squared error gives the abstract's probability statements. End proof.

## 6. Consequences and limits

**Quantum corollary.** In the finite-symbol oracle of [W, Section 9], a \(T\)-query acceptance probability has global interaction degree at most \(2T\). To see this, expand each controlled query as a sum of operators weighted by single-coordinate symbol indicators. Products along amplitude paths use at most \(T\) coordinates; pairing amplitudes in the terminal effect uses at most \(2T\). The scalar acceptance lies in \([0,1]\). Substitution yields
\[
O(T^7\varepsilon^{-3}\delta^{-3/2}
+T^6 C_W(\nu)\varepsilon^{-6}\delta^{-3})
\]
for \(T\ge1\), and the quadratic bound for \(T=1\). This concerns scalar acceptance, not full state reconstruction or computation time.

**Query-local representation transfer.** If \(Z\sim\mu\), \(X'=\Phi(Z)\), each \(\Phi_i\) uses at most \(b_{\rm loc}\) latent coordinates, and each latent coordinate is recoverable on the support by at most \(r\) observed-coordinate queries, apply the main theorem to \(f\circ\Phi\), of degree at most \(D=b_{\rm loc}d\) (constant cases are trivial). Substitute the recovery trees, multiplying depth by at most \(r\). If \(\operatorname{TV}(\nu,\Phi_*\mu)=\zeta\), the failure probability is at most \(\delta+\zeta\); for a clipped estimator the MSE is at most \(\tau+\zeta\). Recovery outputs outside support can be assigned arbitrarily; depth remains capped. This is the paid-query transfer of [W, Theorem 1.4] with the new bound, not free access to latent coordinates.

**Comparison.** [W, Theorem 1.1] gives \(O(d^{24}\varepsilon^{-15}\delta^{-17/2}(1+C_W))\); the new common-information term has degree exponent 6, inverse accuracy exponent 6, and inverse failure exponent 3. The linear common-information dependence remains worst-case optimal at fixed degree and tolerances by [W, Theorem 1.3]. No optimality of the new error exponents or degree exponent is asserted. When \(C_W=0\), the quadratic rate agrees in order with [Q, Corollary 1.3]; the latter retains its sharper direct constant. [V] supplies a complementary additive-fiber bound for a special character oracle even when Wyner information is enormous; the present theorem does not subsume that mechanism.

## 7. Review contract and next experiment

Objective: improve the published uniform correlated-input query bound without modifying the legal oracle, global range hypothesis, or Wyner definition. Baseline: [W, Theorem 1.1]; [Q, Theorem 1.1 and Section 9] for quadratic input. Threshold: strictly better symbolic exponents, not an unmeasured runtime claim. Remaining gap: independent proof audit, kernel formalization of new steps, priority clearance and optimal error rates.

Dependency graph: finite-product influence + fractional rows -> degree-preserving latent projection and switching -> observable-coordinate dichotomy -> exact squared-influence and information drifts -> block averaging -> staged MSE and query bounds. Classical ingredients include Markov polynomial inequality, Pinsker, Jensen/Hölder, total variance, mutual information chain rule and Carathéodory.

Adversarial review plan (not performed by an independent reviewer):
1. Reconstruct the seed-space degree argument and influence contraction on zero-mass heterogeneous alphabets.
2. Verify Markov normalization, rare-switch conditioning, strict case split, and the exact cubic coefficient; look for dependence on unobserved seeds.
3. Independently derive the squared-influence identity under adaptive cylinders and verify the posterior tower property.
4. Audit the block inequality with branches switching types, including \(J_0=0\), deterministic mixtures, exhausted coordinates, \(\tau\ge1/4\), and nonmonotone individual posterior variances.
5. Formalize in this order: contraction, switching, dichotomy, squared drift, two-type block averaging, finite endpoint. Do not infer Lean certification from companion receipts.

Cheapest decisive computational probe: enumerate small rational mixtures of binary product laws, use exact fractions for projection/energy/variance and squared TV, and check the energy/information dichotomy with the TV lower bound in place of logarithms. This is a falsification tool, not proof. Budget: one independent proof pass and one finite exact checker before a formalization sprint; stop and demote if any inequality fails. No computational experiment or independent audit is claimed in this draft.

Prior-art scope: targeted public search on 2026-11-24 for correlated-input quantum simulation, Wyner information, and influence; identified Turturean [T] on the uniform Boolean cube. The published companion papers document their own prior-art comparisons. The present search does not establish global priority or exclude concurrent work; internal repository search also was not exhaustive. No external submission is authorized by this draft.

## References

[W] D. J. Wright, *Dimension-Free Classical Simulation Under Correlated Inputs: Wyner Common-Information Bounds and Query-Local Representations*, v0.7, November 2026, supplied manuscript; especially Lemmas 3.1–3.2, proof of Lemma 4.1, Sections 5.2, 7 and 9.

[Q] D. J. Wright, *Quadratic Influence Beyond the Boolean Cube: A Bias-Free, Exponent-Two Bound on Product Probability Spaces*, v0.7, November 2026, supplied manuscript; Theorem 1.1, Corollary 1.3, Section 9.

[V] D. J. Wright, *Beyond Common Information: Classical Simulation of Quantum Queries via Additive Fiber Multiplicity*, v2.1, November 2026, supplied manuscript; complementary scope.

[T] D. Turturean, *A proof of the Aaronson–Ambainis conjecture*, arXiv:2611.09773, November 2026, https://arxiv.org/abs/2611.09773. Public search verified the uniform-cube statement via https://www.alphaxiv.org/id/abs/2611.09773; the heterogeneous product-space theorem used here is [W], not attributed to [T].

## Revision history

v0.1: first written synthesis from the uploaded v0.7 Wyner and quadratic manuscripts. Added explicit finite-latent endpoint, exact energy drift, complete block schedule, query-local transfer, and audit contract. Claim status remains provisional pending non-author review.
