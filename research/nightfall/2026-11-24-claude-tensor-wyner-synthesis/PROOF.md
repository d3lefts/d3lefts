# Tensor-code representation obstructions and a covered-quadratic Wyner bound

**NIGHTFALL research manuscript v0.1 — 2026-11-24 (US Central).**
Research owner: Devin J. Wright. Both synthesis ideas were proposed by Claude in the review supplied by the research owner. ChatGPT developed the following detailed proofs, corrected the numerical normalization, strengthened the representation-score estimate, and ran an exact finite distance replay.

**Status:** written proof candidates with author-side/source review and finite distance replay. No independent non-author review, end-to-end Lean certificate, comprehensive novelty clearance, or external publication authorization is claimed. The second result is a useful proof transfer but is not the strongest current NIGHTFALL simulation bound.

## Abstract

For the binary pure-tensor character source at depth \(L\), the observed code has length \(3^L\), dimension \(2^L\), and minimum distance \(2^L\). Combining this exact distance with the static representation obstruction in the companion Wyner paper yields, for every exact query-local representation with locality \(b\), recovery depth \(r\), and latent law \(\mu\),
\[
 C_W(\mu)\ge \max\{0,2^L-br(3/2)^L\}\log 2,\qquad
 br(1+C_W(\mu))\ge (4/3)^L .
\]
Thus the representation-dependent sufficient budget in the Wyner theorem is exponentially large in \(L\) for every such representation, whereas the additive-fiber theorem gives polynomial sufficient budgets for one and two quantum queries. This is a separation of uniform sufficient guarantees, not a lower bound on actual simulation complexity.

Independently, the high-order cover theorem of the quadratic influence paper applies to the degree-three latent lift of a quadratic target. Direct substitution into the existing Wyner argument gives a deterministic original-coordinate query bound \(O(\varepsilon^{-12}\delta^{-7}(1+C_W))\). The result has a short proof using the existing stopping-time architecture, but is weaker than the degree-preserving projection approach already in repository PR #1154 and the staged-drift approach of #1197.

## 1. Models and sources

[W] is *Dimension-Free Classical Simulation Under Correlated Inputs*, v0.7, especially Theorem 1.4, Proposition 10.1 and Sections 3–6. [Q] is *Quadratic Influence Beyond the Boolean Cube*, v0.7, especially Corollary 7.1. [V] is *Beyond Common Information*, v2.1, especially Corollary 6.4 and Proposition 7.1. All are November 2026 manuscripts supplied by the research owner. We use their finite-alphabet models and natural-log convention throughout.

A classical query reveals an original coordinate. An exact query-local representation of a law \(\nu\) consists of a finite latent product alphabet, a law \(\mu\) on it, a deterministic map \(\Phi\) with \(\Phi_*\mu=\nu\), and positive integers \(b,r\). Each observed coordinate is a function of at most \(b\) latent coordinates; each latent coordinate can be recovered on \(\operatorname{supp}\mu\) by a deterministic observed-coordinate tree of depth at most \(r\). Alphabets may be heterogeneous and arbitrary finite size. No latent access is free. The common information \(C_W(\mu)\) is the infimum of \(I(W;Z)\) over all auxiliary variables \(W\) making the coordinates of \(Z\sim\mu\) conditionally independent. It is nonnegative. We use the finite-mixture endpoint of [W, §5.2], which follows from compactness of the convex hull of the pairs \((P,H(P))\) for product laws \(P\).

## 2. Exact tensor-code distance

Let \(L\ge1\), \(E=\mathbb F_2^2\), \(V=E^{\otimes L}\), and
\[
 R_L=\{a_1\otimes\cdots\otimes a_L:a_i\in E\setminus\{0\}\}.
\]
Let \(s\) be uniform on \(V^*\) and let the observed bits be \(X_a=s(a)\), \(a\in R_L\). The equivalent character reading is \((-1)^{X_a}\); this bijection costs no query. Write \(C_L\) for the image of the linear evaluation map.

### Lemma 2.1 (length, rank and distance).
The code \(C_L\) has parameters
\[
 [n,k,D]=[3^L,2^L,2^L]_2 .
\]

**Proof.** Nonzero pure tensors over \(\mathbb F_2\) have unique nonzero factors: if two such tensors coincide, contract all factors except one against linear functionals taking value 1 on the corresponding factors of the first tensor. The contraction on the first tensor is its nonzero remaining factor, and equality forces all the scalar factors on the second tensor to be 1 and its remaining factor equal to the first. Repeat at each site. Thus there are exactly \(3^L\) labels. The standard basis tensors belong to \(R_L\) and span \(V\), so evaluation is injective, giving dimension \(2^L\) and a uniform law on the code.

For the distance, use induction. For \(L=1\), every nonzero functional on \(E\) is 1 on exactly two of its three nonzero vectors. For \(L>1\), regard a nonzero \(s\) as two slices \(s_0,s_1\in(E^{\otimes(L-1)})^*\) by evaluating its last argument at the two basis vectors of \(E\). The three blocks of the evaluation word are the evaluations of \(s_0,s_1,s_0+s_1\). At least two of these three functionals are nonzero. By induction each nonzero block has weight at least \(2^{L-1}\), yielding weight at least \(2^L\). Conversely a tensor product of nonzero linear functionals evaluates to 1 precisely when every local evaluation is 1, giving exactly \(2^L\) nonzero positions. Since the code is linear, this is its minimum distance. End proof.

This elementary proof replaces the Reed–Muller distance citation in Claude's initial sketch. It also identifies the distance as the product-code distance of the binary \([3,2,2]\) simplex code.

## 3. Representation obstruction for arbitrary finite latent alphabets

### Lemma 3.1 (general binary-code counting).
Let \(\nu\) be uniform on a binary linear \([n,k,D]\) code with \(D>0\). Every exact query-local representation as in §1 obeys
\[
 C_W(\mu)\ge\max\{0,k-bnr/D\}\log2 .
\]

**Proof.** Recoverability of every latent coordinate implies that \(\Phi\) is injective on \(\operatorname{supp}\mu\): identical observed words yield the same output of every recovery tree and hence identical latent tuples. The map from that support onto the code is surjective because \(\Phi_*\mu=\nu\). It is therefore a bijection and \(H(Z)=k\log2\).

Fix for each observed coordinate \(i\) a global dependency set \(S_i\) of at most \(b\) latent coordinates; their total incidence count is at most \(bn\). Take any finite conditional-product decomposition of \(\mu\), with label \(W\). Every positive-weight conditional component has its product support rectangle inside \(\operatorname{supp}\mu\). In a rectangle, an active latent coordinate \(j\) (one with at least two support symbols) can be varied while all other coordinates remain fixed. Its two distinct latent tuples map to distinct codewords. These codewords differ in at least \(D\) positions; any such position must contain \(j\) in its dependency set \(S_i\). Thus each active coordinate accounts for at least \(D\) incidences, and at most \(bn/D\) latent coordinates can be active in the rectangle.

A depth-\(r\) recovery tree with binary observations has at most \(2^r\) leaves, including if it terminates early. Consequently its latent output range on the support has cardinality at most \(2^r\), regardless of the nominal latent alphabet size. Each active coordinate has conditional entropy at most \(r\log2\); all others have zero. By conditional product independence (or subadditivity),
\[
 H(Z\mid W=w)\le(bnr/D)\log2
\]
for every positive-weight component. Average and subtract from \(H(Z)\). Taking the infimum over decompositions, using the finite-mixture reduction, proves the result; the maximum with zero follows from nonnegativity. End proof.

The argument is the parameter-uniform portion of [W, Proposition 10.1]. No dual-distance hypothesis is required for this counting lemma. The tensor family in §2 does not satisfy the random-code bounded-independence premise of that proposition's separate simulation argument; we instead use [V] for simulation.

### Theorem 3.2 (exact representation obstruction on pure tensors).
For the law of §2 and every exact query-local representation,
\[
 C_W(\mu)\ge\max\{0,2^L-br(3/2)^L\}\log2 .
\tag{3.1}
\]
Moreover,
\[
 br(1+C_W(\mu))\ge (4/3)^L .
\tag{3.2}
\]

**Proof.** Substitute Lemma 2.1 into Lemma 3.1. Put \(t=br\ge1\), \(c=(3/2)^L\), \(k=2^L\), \(x=k/c=(4/3)^L>1\). If \(t\ge x\), (3.2) follows by nonnegativity. For \(1\le t\le x\), (3.1) implies
\[
 t(1+C_W)\ge F(t):=t[1+c(x-t)\log2].
\]
The quadratic \(F\) is concave and thus bounded below on \([1,x]\) by the smaller endpoint. We have \(F(x)=x\) and
\[
 F(1)=1+c(x-1)\log2\ge x,
\]
since \(c\ge3/2\) and \(\log2>2/3\) (strict Jensen for \(u\mapsto1/u\) integrated uniformly on \([1,2]\)). This proves (3.2). End proof.

Claude's original threshold split gave the weaker but valid lower bound \(\min\{(4/3)^L/2,2^{L-1}\log2\}\). Equation (3.2) is a direct endpoint improvement, not an assertion that the best representation attains it. The identity representation provides the upper bound \(1+2^L\log2\), by [V, Proposition 7.1], since \(D\ge2\) excludes free coordinate axes.

### Corollary 3.3 (polynomial versus exponential sufficient guarantees).
Fix positive accuracy and failure tolerances \(\varepsilon,\delta<1\). For one or two coherent quantum queries in the character oracle of [V], Corollary 6.4 there gives deterministic nonadaptive estimators using, respectively,
\[
 O(L/(\varepsilon^2\delta)),\qquad O(L^3/(\varepsilon^2\delta))
\]
original labels. These are simultaneous uniform bounds over all algorithms in the respective model; the one-query and two-query theorems and the tensor-circuit count of [V] are dependencies, not re-proved or independently certified here.

In contrast, the published explicit budget in [W, Theorems 1.1 and 1.4] is \(r\lceil 2(A_{D'}+sB_{D'})/\delta\rceil\) with \(D'=\max(1,bd)\), \(s=1+C_W(\mu)\), \(\tau=\varepsilon^2\delta/2\), and the constants of [W, equations (1)–(3)]. For any fixed \(d\ge1\) these expressions have \(B_{D'}(\tau)\) a positive tolerance-dependent constant times \(D'^{24}\), so the displayed sufficient budget is at least a positive constant times \(rb(1+C_W(\mu))\). Even if one optimizes the strict slack \(s>C_W\) instead of setting \(s=1+C_W\), the \(A_{D'}\) term supplies a positive multiple of \(rb\) and the \(B_{D'}\) term supplies a positive multiple of \(rb C_W\), at the fixed tolerances. Reading the entire \(n=3^L\) coordinates is an alternative upper bound; taking its minimum does not change the exponential lower scale of these numerical guarantees. The exact rank cap \(2^L\) from [V] is also exponential. By (3.2) the representation-dependent expression is \(\Omega((4/3)^L)\) uniformly over every exact representation. The same score argument applies to the displayed stronger bound of #1197, whose information term is proportional to \(r(bd)^6 C_W\) and whose energy term is at least proportional to \(rb\) at fixed tolerances (including the quadratic case \(bd\le2\), for which \(b\le2\)).

**Scope.** This compares specific sufficient-budget expressions, not minimal query complexity, actual runtime, impossibility of improving the Wyner method, nor arbitrary task-dependent simulators. It does not cover TV-approximate representations, moment-relaxed information, or other nonstatic interfaces. The polynomial budgets of [V] already show that the actual query complexity cannot satisfy the asserted exponential lower bound in this setting.

## 4. Covered-quadratic influence improves the original Wyner stopping proof

This section preserves the original latent lift and the stopping architecture of [W]. Let \(X\sim\nu\) on a finite product alphabet, and let \(f\) be globally \([0,1]\)-valued with interaction degree at most two. Let \(0<\tau\le1\). Set
\[
 C_2=(2(1+\sqrt2)\sqrt3+11901/6250)^2,\quad
 K=2\pi^2,\quad
 \gamma=\frac{4\tau^2}{(1+\sqrt{C_2})^2},\quad
 \eta=\frac{\gamma}{2048},\quad w_0=\frac{\gamma}{16K}.
\tag{4.1}
\]

### Lemma 4.1 (covered lift).
For any posterior mixture \(\sum_\theta\pi_\theta P_\theta\) of product laws and current degree-two section \(g\), construct independent seeds \(U_i\), an independent label \(\Theta\), common reference \(R\), and maximal-coupling component samples \(Y_\theta\) as in [W, §4]. The function \(G(\Theta,U)=g(Y_\Theta(U))\) satisfies
\[
 \max_c I_c(G)\ge\frac{4\operatorname{Var}(G)^2}{(1+\sqrt{C_2})^2}.
\tag{4.2}
\]

**Proof.** Each term of \(g\) supported on at most two observed coordinates lifts to a term supported on those seed coordinates and possibly the label. Consequently the product-space conditional expectation over the label has degree at most two, equivalently every canonical Hoeffding support of order at least three contains the label. The centered target \(G-1/2\) has absolute bound \(1/2\) and high-order cover \(\{\Theta\}\) of size one. Apply [Q, Corollary 7.1] with \(B=1/2,t=1\): \(v^2\le(1+\sqrt{C_2})^2 M/4\), where \(v=\operatorname{Var}(G)\), \(M=\max_c I_c(G)\). Centering does not change influences or variance. End proof.

The precise reciprocal coefficient in (4.2) is approximately \(1/31.73768\), not \(1/127\). The latter omits the factor four from \(B^2=1/4\). Claude's quoted numerical query budget is consistent with (4.2), not the erroneous parenthetical approximation.

### Lemma 4.2 (observable-coordinate dichotomy).
If \(\operatorname{Var}_\nu(g)>\tau\), some unread original coordinate \(j\) satisfies one of
\[
 \sum_\theta\pi_\theta L_j^{P_\theta}(g)\ge2\gamma,\qquad
 \sum_\theta\pi_\theta\operatorname{TV}(p_{\theta j},q_j)^2\ge\eta^2w_0 ,
\tag{4.3}
\]
where \(L_j^P(g)=\mathbb E|g(X)-g(X^{(j)})|\), and \(q_j=\sum_\theta\pi_\theta p_{\theta j}\).

**Proof.** The law of \(G\) is the current observed mixture law, so Lemma 4.1 gives a coordinate with influence at least \(\gamma\). If it is a seed \(j\), its influence equals the posterior average of the corresponding component influences, by independent resampling of that seed at fixed label. Since the increment has absolute value at most 1, \(2 I_j^P(g)\le L_j^P(g)\), giving the first alternative.

Otherwise it is the label. If the second alternative fails for every \(j\), Markov implies \(\Pr_\Theta(\operatorname{TV}(p_{\Theta j},q_j)>\eta)\le w_0\). The rare-large-switch lemma [W, Lemma 4.2] gives \(\mathbb E(G-g(R))^2\le2K w_0+128d^2\eta\) with \(d=2\). To recall its proof, replace the reference letters on the label-dependent large-TV set first, using the fractional row bound and the rarity of each replacement; then replace the remaining letters, using the independent small-mismatch lemma with coefficient \(64d^2\eta\); combine the two squared errors with the inequality \((x+y)^2\le2x^2+2y^2\). Resampling the label and comparing both outcomes to the same reference yields
\[
 I_\Theta(G)\le 2\mathbb E(G-g(R))^2
 \le 4K w_0+256d^2\eta=3\gamma/4<\gamma,
\]
a contradiction. This uses the original [W] switching coefficient, not the sharper coefficient of #1197. All parameter ranges are admissible since \(0<\gamma<1\). End proof.

### Theorem 4.3 (covered-quadratic Wyner simulation).
For every finite input law, globally bounded quadratic \(f\), \(s>C_W(\nu)\), integer \(q\ge1\), \(\varepsilon>0\), and \(0<\tau\le1\), there is a deterministic depth-at-most-\(q\) original-coordinate tree \(t\) satisfying
\[
 \Pr(|f(X)-t(X)|>\varepsilon)
 \le\frac{A+sB}{q}+\frac{\tau}{\varepsilon^2},\qquad
 A=\frac{K}{2\gamma},\quad B=\frac{1}{\eta^2w_0}
 =\frac{16K(2048)^2}{\gamma^3}.
\tag{4.4}
\]

**Proof.** Choose a finite product mixture with \(I(\Theta;X)<s\) (the finite endpoint also allows equality with \(C_W\)). At a positive-probability history \(h\), the posterior product mixture on unread coordinates is obtained by Bayes' rule, because a deterministic transcript event is exactly the cylinder specified by the observations. Let \(g_h\) be the restriction of \(f\), let \(L(h)\) be the posterior mean of the sum of component absolute increments, and \(J(h)=I(\Theta;X_{\rm unread}\mid h)\). These are nonnegative, with \(L(\varnothing)\le K\) by the fractional row bound and \(J(\varnothing)<s\). For a legal query \(j\), the expected drop in \(L\) is exactly the posterior mean \(L_j\): within each label the other resampling increments are preserved in expectation on revealing \(j\), and the posterior average follows by the tower property. The expected drop in \(J\) is \(I(\Theta;X_j\mid h)\) by the chain rule. Pinsker in nats gives this information at least \(2\sum_\theta\pi_\theta\operatorname{TV}(p_{\theta j},q_j)^2\).

Thus while the posterior variance exceeds \(\tau\), Lemma 4.2 provides a legal query whose conditional expected drop in \(L/(2\gamma)+J/(\eta^2w_0)\) is at least one. Stop when variance is at most \(\tau\) or all coordinates are read, and freeze stopped paths. Fix a deterministic coordinate ordering for any ties. Telescoping the expected potential for \(q\) levels shows that the expected number of pre-stop steps up to level \(q\) is at most \(A+sB\); paths not stopped by level \(q\) contribute \(q\) steps, so their probability is at most \((A+sB)/q\). On stopped paths output the posterior mean; the conditional failure probability there is at most \(\tau/\varepsilon^2\) by the second-moment bound. On unfinished paths output any number in \([0,1]\). Impossible histories are assigned arbitrary outputs respecting the depth cap. Summing establishes (4.4). No query reads the latent label or seed. End proof.

Choose \(\tau=\varepsilon^2\delta/2\), \(s=1+C_W\), and \(q=\lceil2(A+sB)/\delta\rceil\) for \(0<\varepsilon,\delta\le1\). Since \(A=O(\tau^{-2})\), \(B=O(\tau^{-6})\), the bound becomes
\[
 Q_{\mathrm{cl}}=O(\varepsilon^{-12}\delta^{-7}(1+C_W(\nu))).
\tag{4.5}
\]
It applies to the scalar acceptance probability of one query in the standard combined finite-symbol oracle: the post-query amplitudes have degree at most one in the symbol indicators and the terminal quadratic effect yields a degree-two acceptance function globally in \([0,1]\). It also transfers to a locality-one exact or TV-approximate representation by [W, Theorem 1.4]: multiply the depth by recovery cost \(r\), replace \(C_W(\nu)\) by \(C_W(\mu)\), and add the TV discrepancy to the failure probability. For \(b>1\) the pulled-back degree need not remain two and this specialization is not asserted. Theorem 1.3 of [W] and its Section 6 combined-oracle extremal Forrelation construction show that the linear common-information factor remains worst-case sharp at fixed tolerances. Counting separate controlled table accesses instead of a combined oracle changes the quantum query-count convention; the degree-two statement remains valid.

### Numerical comparison

At \(d=2,\varepsilon=\delta=1/4\), \(\tau=1/128\), the old influence threshold in [W] is \(\sqrt{3/12500}\tau^{5/2}/(\pi^2(2+1)^2)^3\). The new threshold is (4.1). Using ordinary floating point only for illustration, the coefficient \(2(A+B)/\delta\) is an upper bound on the unrounded stopping budget per unit \(1+C_W\); the actual expression also has a ceiling.

| Quantity | Published W | Cover transfer |
|---|---:|---:|
| gamma | 1.1924877661e-13 | 1.9231133239e-6 |
| 2(A+B)/delta | 6.2493927400e48 | 1.4899955965e27 |

The figures compare sufficient query-budget formulas, not measured queries or speedups; they do not supersede tighter product-law bounds. In particular #1154 uses degree-preserving latent averaging and a cubic information charge in \(\tau\), and #1197 uses a different staged drift argument yielding a still better stated mean-square bound. This cover transfer is therefore an alternative simpler bridge to the original proof, not the current strongest upper bound.

## 5. Exact replay and audit boundary

The following Python 3 code enumerates all nonzero secrets at depths 1 through 4, using the standard basis of \(E^{\otimes L}\), bit-packed evaluation rows and parity. It is independent of the inductive distance proof; it was executed in this session and returned the recorded values. It is not an independent non-author proof audit, and the finite cases alone do not prove Lemma 2.1.

```python
from itertools import product
from collections import Counter

for L in range(1, 5):
    masks = []
    for a in product((1, 2, 3), repeat=L):
        mask = 0
        for bits in product(range(2), repeat=L):
            if all(x & (1 << i) for x, i in zip(a, bits)):
                idx = sum(i << j for j, i in enumerate(bits))
                mask |= 1 << idx
        masks.append(mask)
    assert len(set(masks)) == 3**L
    hist = Counter(
        sum((s & m).bit_count() % 2 for m in masks)
        for s in range(1, 1 << (2**L))
    )
    assert 0 not in hist and min(hist) == 2**L
    print(L, len(masks), min(hist), hist[min(hist)])
```

Observed output (depth, length, minimum weight, multiplicity of minimum weight):
```
1 3 2 3
2 9 4 9
3 27 8 27
4 81 16 81
```
The replay checks 3 + 15 + 255 + 65535 = 65808 nonzero secrets in total. The exact score lower bound and entropy counting are analytic, not established by these finite checks. The approximation of \(C_2\) and the illustrative query budgets is numerical, not part of the proof.

## 6. Source custody, chronology and next gates

Internal search on 2026-11-24 queried issues and PRs for tensor/static representation, high-order cover/Wyner, and latent projection. It retrieved the following relevant records:

- [#1095](https://github.com/d3lefts/d3lefts/pull/1095): earlier affine-code Wyner identity and graph phase bridge; this is antecedent work, not the new tensor-wide representation score.
- [#1154](https://github.com/d3lefts/d3lefts/pull/1154): earlier quadratic Wyner latent-average composition, explicitly dated 2026-11-22, with information exponent three in the stopping threshold. This is prior internal work; no novelty claim for latent averaging in #1197 or here is warranted. The newer staged variance-drift argument in #1197 should be assessed separately for incremental contribution. #1154's own body distinguishes full proof attempts from kernel receipts.
- [#1197](https://github.com/d3lefts/d3lefts/pull/1197): staged squared-energy and information drift, written on 2026-11-24. The cover-transfer bound here is superseded quantitatively by its stated bound and by the latent-average direction in #1154.
- [#1021](https://github.com/d3lefts/d3lefts/issues/1021): earlier rank-free tensor-subcube simulator audit gate.

No identical tensor-wide static representation score result was found by these targeted searches. They are not an exhaustive branch/history audit or a worldwide priority search. External literature was not independently searched for this new synthesis during this session; the elementary distance proof is classical product-code geometry, and [W,Q,V] retain their original literature dependencies and status.

Objective: obtain a structured exact source on which every static query-local Wyner budget is exponential, while additive-fiber simulation is polynomial; additionally record the one-cover proof transfer. The decisive mathematical improvement is (3.2), not a measured runtime gain or a new universal lower bound. The strongest source comparator for the first result is [W, Proposition 10.1] plus [V, Corollary 6.4]; for the second it is #1154 and #1197, which are stronger candidates.

Independent review plan: (i) verify the tensor-code distance induction and uniformity; (ii) attack dependency-set counting with arbitrary latent alphabets, zero-mass symbols and early termination; (iii) check the concavity endpoints and the distinction between numerical sufficient budget and actual query complexity; (iv) verify the cover condition and all coefficients in (4.1)–(4.4); (v) audit the internal chronology and compare directly to the earlier #1154 paper; (vi) formalize distance and incidence/entropy lemma before attempting the combined theorem. Preserve the distinction between the scoped existing Lean receipts and new formalization obligations. Stop and demote if any dependency or inequality fails. The cheapest next extension is to determine whether a TV-approximate source map permits a robust replacement of the rectangle counting argument; no such theorem is asserted here.

No phase-retrieval synthesis theorem is claimed. The calibration/quotient analogy is a research direction, not a proved implication.

## References

[W] D. J. Wright, *Dimension-Free Classical Simulation Under Correlated Inputs: Wyner Common-Information Bounds and Query-Local Representations*, v0.7, November 2026. Theorems 1.1, 1.3, 1.4; Lemmas 3.1–3.2, 4.1–4.3; Sections 5–6 and Proposition 10.1.

[Q] D. J. Wright, *Quadratic Influence Beyond the Boolean Cube: A Bias-Free, Exponent-Two Bound on Product Probability Spaces*, v0.7, November 2026. Theorem 1.1 and Corollary 7.1.

[V] D. J. Wright, *Beyond Common Information: Classical Simulation of Quantum Queries via Additive Fiber Multiplicity*, v2.1, November 2026. Theorems 3.1, 4.1; Corollary 6.4 and Proposition 7.1. Full two-query proof is not reported as end-to-end kernel certified in that manuscript.

Revision v0.1: Claude's two synthesis ideas, detailed written proofs, corrected coefficient, strengthened score lower bound, depth-4 exact replay, and internal priority reconciliation.
