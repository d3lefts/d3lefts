# Classical Query Simulation over Finite Mixtures of Product Distributions

**Research preprint — draft for mathematical review, 19 November 2026. Not submitted.**

**Authorship and acknowledgments:** To be confirmed by human contributors before any submission. The foundational uniform-cube influence proof is due to David Turturean, using methods and lemmas attributed in his source and paper. Aaronson and Ambainis formulated the original conjecture. Independently originated mathematical contributions, machine formalizations and reviewer observations must be credited accurately after reviewing commit histories and author approvals.

**Certification boundary:** A complete source-level Lean proof of the Jensen *low-degree mixture* theorem passed at [PR #867, run 44456342019](https://github.com/d3lefts/d3lefts/actions/runs/44456342019); the original mixture theorem is on merged PR #858. The finite complex-circuit-to-product simulator passed the exact-head [PR #866, run 44460308357](https://github.com/d3lefts/d3lefts/actions/runs/44460308357). The **circuit-to-mixture Jensen composition and total-variation extension** are submitted in draft [PR #878](https://github.com/d3lefts/d3lefts/pull/878) and require their *own* exact-head CI. Do not describe the combined headline as machine checked until that run passes. Novelty and priority are not certified.

## Abstract

We establish a quantitative, coordinate-query simulation theorem for bounded low-interaction-degree functions under finite mixtures of independent product measures. If a known distribution on a finite input product space is a mixture of \(M\) product laws and \(f\) takes values in \([0,1]\) with indicator-polynomial degree at most \(d\ge1\), then a deterministic adaptive whole-coordinate decision tree with \(n\) queries approximates \(f\) outside a set of probability at most

\[
\frac{3\sqrt2\,\pi^6d^6M/(\tau\sqrt{\tau})+
512d^4M^4/\tau^3}{n}+\frac{\tau}{\varepsilon^2}
\]

for \(0<\tau\le1/2\). Consequently \(O(d^6M\varepsilon^{-3}\delta^{-5/2}+d^4M^4\varepsilon^{-6}\delta^{-4})\) queries suffice for error \(\varepsilon\) outside \(\delta\) mixture mass. The bound does not depend on the number of input coordinates, minimum positive source probabilities, or alphabet cardinality. The argument combines a product-space mean-absolute-increment potential with a posterior-component Gini potential, a degree-sensitive marginal perturbation inequality, and a weighted Jensen step. 

For finite complex matrix-oracle query circuits, exact path expansion gives acceptance-polynomial degree at most \(2T\); norm-preserving fixed and query matrices imply Born acceptance in \([0,1]\). Composing these observations yields a \(T\)-query quantum-to-classical simulation theorem for mixtures, within the specified oracle model, pending the combined Lean verification gate. An input distribution within total-variation distance \(\eta\) of such a mixture has the same classical query bound with additive failure \(\eta\). We distinguish the existence/query guarantee from classical computation-time efficiency, the unresolved logarithmic-in-\(1/\delta\) strong simulation conjecture, and questions of novelty.

## 1. Introduction

Aaronson and Ambainis asked whether acceptance probabilities of low-query quantum algorithms can be classically predicted on almost every uniformly random input using polynomially many classical input queries. Turturean proved the bounded low-degree polynomial influence conjecture on the uniform Boolean cube, enabling the known polynomial simulation principle. Subsequent work considered fixed-bias product distributions and slices. The distributional guarantee of interest here permits arbitrary zero or tiny probabilities, arbitrary finite symbol alphabets, and—crucially—latent mixtures of independent components.

A finite mixture model is
\[
\nu(x)=\sum_{\theta\in[M]}w_\theta\prod_{i\in I}p_{\theta,i}(x_i),
\quad w_\theta\ge0,\quad\sum_\theta w_\theta=1.
\]
The entire mixture description is available to the classical decision tree, and only symbol reads are counted. Unlike a generic correlated law, the conditional distribution after inspecting coordinates remains a mixture of at most \(M\) product laws. However, it has a posterior over component indices that changes in response to each observation. This creates a second source of uncertainty, beyond variation within each product component.

The central mechanism is a pair of supermartingale potentials. One accounts for unresolved within-component variation; the other accounts for uncertainty about the latent component. Querying is productive whenever overall conditional variance exceeds a threshold, because the law of total variance splits it into within- and between-component terms. The resulting theorem is fully quantitative and applies with no lower bound on any probability.

## 2. Model, definitions and exact statement

Let \(I\) and \(\Sigma\) be finite, with \(\Sigma\) nonempty, and let \(\Omega=\Sigma^I\). For each component \(\theta\in[M]\), choose normalized coordinate masses \(p_{\theta,i}(a)\ge0\) with \(\sum_{a\in\Sigma}p_{\theta,i}(a)=1\), permitting zero masses. Let \(w\) be normalized mixture weights.

Write \(\deg_{\mathrm{ind}}(f)\le d\) if \(f\) is a finite linear combination of coordinate-symbol indicator monomials \(\prod_{i\in S}{\bf1}[x_i=a_i]\), with \(|S|\le d\). On finite products this agrees pointwise with the vanishing of Efron–Stein/Hoeffding components above degree \(d\), even with zero-mass atoms (the finite-product equivalence is separately formalized in the NIGHTFALL repository).

A decision tree adaptively reads one whole symbol \(x_i\) per query and returns a real-valued estimate. Its worst-case query count is bounded by \(n\); its computational running time is not constrained by the result.

**Theorem 1 (Jensen mixture simulation; Lean source certified).** For \(f:\Omega\to[0,1]\) with \(\deg_{\mathrm{ind}}(f)\le d\), \(d\ge1\), \(0<\tau\le1/2\), \(\varepsilon>0\), \(n\ge1\), there is a deterministic decision tree \(Q\) of worst-case depth at most \(n\) such that
\[
\Pr_{X\sim\nu}(|f(X)-Q(X)|>\varepsilon)
\le \frac{A_d(M,\tau)}n+\frac{\tau}{\varepsilon^2},
\]
where
\[
A_d(M,\tau)=
\frac{3\sqrt2\pi^6d^6M}{\tau\sqrt{\tau}}
+\frac{512d^4M^4}{\tau^3}.
\]
In particular, for \(0<\varepsilon,\delta\le1\), taking \(\tau=\varepsilon^2\delta/2\) and any positive integer \(n\ge2A_d(M,\tau)/\delta\) gives failure probability at most \(\delta\). It suffices to take
\[
n=\left\lceil
24\pi^6d^6M\varepsilon^{-3}\delta^{-5/2}
+8192d^4M^4\varepsilon^{-6}\delta^{-4}
\right\rceil
\]
(with \(n\ge1\)).

The exact formal statement is Nightfall.ProductSpace.Mixture.mixture_simulation_jensen in MixtureSimulation.lean, with the explicit hypotheses above. The constant \(512\) in the second term reflects the certified endpoint-Markov marginal perturbation constant; the paper's original sharper \(32\) separator constant is not the constant used in this Lean theorem.

## 3. Proof mechanism

### 3.1 Degree-sensitive marginal perturbation

**Lemma 2 (bounded polynomial fooling).** Suppose \(\mu=\bigotimes_i\mu_i\) and \(\mu'=\bigotimes_i\mu_i'\), and \(\max_i\mathrm{TV}(\mu_i,\mu_i')\le\gamma\le1/2\), with \(\gamma>0\). If \(\deg_{\mathrm{ind}}(g)\le d\) and \(|g(x)|\le1\) everywhere, then
\[
|\mathbb E_\mu g-\mathbb E_{\mu'}g|\le16d^2\gamma.
\]
In particular for \(0\le f\le1\), applying this to \(2f-1\) gives a bound \(8d^2\gamma\) on the difference of the two means.

A proof uses the common overlap of the marginals and follows two probability-law interpolation paths. For an integer \(m=\lfloor1/\gamma\rfloor\), both paths stay in the probability simplex up to \(m\); embedding the path in the Hamming weight of a cube of \(m\) bits converts bounded polynomial degree into the vendored endpoint-Markov sensitivity inequality. The shared-overlap path costs a factor of two; the integer approximation accounts for the remaining constant. When \(\gamma=0\), the product laws coincide; this case is immediate and excluded from the quantified Lean lemma.

### 3.2 Posterior states and two potentials

After a history \(\rho\), let \(v_\theta\) be the unnormalized posterior weight for component \(\theta\), \(V=\sum_\theta v_\theta\), and \(g=f_\rho\) the restricted function. The mixture conditional law remains a mixture of the restricted product components. The unnormalized representation avoids any division by a zero posterior weight.

For each component define \(m_\theta=\mathbb E_{\mu_\theta}g\) and \(v_\theta^{\rm in}=\operatorname{Var}_{\mu_\theta}(g)\). Normalizing the posterior when \(V>0\) yields total conditional variance \(W+B\), with
\[
W=\sum_\theta \pi_\theta v_\theta^{\rm in},\qquad
B=\sum_\theta\pi_\theta(m_\theta-\bar m)^2.
\]

For component \(\theta\), let \(L_j^\theta(g)\) be the mean absolute change when coordinate \(j\) is independently resampled; set \(L^\theta(g)=\sum_j L_j^\theta(g)\). The row-certificate bound gives \(L^\theta(g)\le K=\pi^2d^2/2\) for all restrictions \(g\). Define
\[
\Phi(v,g)=\sum_\theta v_\theta L^\theta(g),\qquad
\mathrm{Sq}(v)=\frac{\sum_\theta v_\theta^2}{V},
\qquad
\Psi(v,g)=\frac{\Phi(v,g)}{g_a}+\frac{V-\mathrm{Sq}(v)}{g_b}.
\]
When a coordinate \(j\) is queried, the expected change in the first potential is precisely its posterior-weighted increment. The second potential is monotone in expectation, with its gain controlled by a finite chi-square/Cauchy–Schwarz inequality. On zero-mass answer branches the unnormalized posterior remains valid and contributes zero to the expectation.

### 3.3 Within-component case: Jensen

If \(W>\tau/2\), the product-space mean-increment theorem supplies, for each positive-variance component, a witness coordinate with increment at least
\[
(v_\theta^{\rm in})^{3/2}/(12K^2).
\]
Pigeonholing among at most \(M\) candidate coordinates and Jensen across the normalized posterior give
\[
\max_j\sum_\theta\pi_\theta L_j^\theta(g)
\ge\frac{\sum_\theta\pi_\theta(v_\theta^{\rm in})^{3/2}}
{12K^2M}
\ge\frac{W^{3/2}}{12K^2M}.
\]
Thus querying the maximizing coordinate guarantees expected reduction in the absolute-increment potential of at least
\(g_a=(\tau/2)^{3/2}/(12K^2M)\).
The proof of this Jensen step is the quantitative improvement over the original heavy-component argument.

### 3.4 Between-component case: posterior impurity

If \(W\le\tau/2\) and the total variance exceeds \(\tau\), then \(B>\tau/2\). The weighted pairwise identity for the means finds a sufficiently heavy pair with separated conditional means. Lemma 2 forces a coordinate where the two components' marginals differ. Querying that coordinate decreases posterior impurity in expectation by at least
\[
g_b=\frac{\tau^3}{512d^4M^4}.
\]
The finite-sum chi-square proof handles zero-mass symbols without using undefined \(0\cdot\infty\) products.

### 3.5 Amortization and error

At each nonterminal state at least one coordinate has combined-potential decrease sufficient to pay one query. A finite-fuel induction proves the expected number of queries is bounded by the normalized root potential:
\[
\mathbb E N\le\frac K{g_a}+\frac1{g_b}
=A_d(M,\tau).
\]
Variance at a completed leaf is at most \(\tau\). The indicator of error larger than \(\varepsilon\) is bounded by squared error divided by \(\varepsilon^2\), while a depth-capped unfinished leaf is charged to the query-count term. This yields Theorem 1. All aspects of this argument, including the numeric Jensen constants, are in the pinned Lean proof source and strict certificate.

## 4. Quantum circuit interpretation (combined formalization pending)

Consider a finite complex vector space with a finite basis and an initial normalized state. A query step consists of a symbol-dependent oracle matrix whose entries are a linear combination of one-coordinate symbol indicators, followed by an input-independent complex matrix. If all fixed and realized oracle matrices preserve the squared Hermitian norm, the circuit is well formed. Let \(T\ge1\) be the number of oracle steps. Measure a fixed subset of output basis states; let \(f_C(x)\) be the resulting Born acceptance probability.

**Theorem 3 (source-certified circuit degree).** For the specified finite matrix-oracle model, \(f_C\) is a coordinate-indicator polynomial of degree at most \(2T\). For well-formed normalized circuits, \(0\le f_C(x)\le1\) for every input. The source-level theorem and strict kernel audit are recorded in PR #866, including the complex query-path identity and the unit-norm proof.

The acceptance probability can be expanded as a quadratic combination of amplitudes; each amplitude is a sum over paths carrying at most \(T\) symbol indicators, so each real/imaginary square has degree at most \(2T\). The formal theorem matches the exact degree predicate used in Theorem 1.

**Corollary 4 (combined circuit-to-mixture simulation; proposed).** Under Theorem 1's known finite mixture and Theorem 3's normalized finite matrix-oracle circuit, there exists a classical whole-symbol decision tree of worst-case depth \(n\) with
\[
\Pr_\nu(|f_C(X)-Q(X)|>\varepsilon)
\le \frac{A_{2T}(M,\tau)}n+\frac{\tau}{\varepsilon^2}.
\]
Consequently it is sufficient to take
\[
n=\left\lceil
1536\pi^6T^6M\varepsilon^{-3}\delta^{-5/2}
+131072T^4M^4\varepsilon^{-6}\delta^{-4}
\right\rceil.
\]
The paper deduction is immediate from the two certified ingredients, but the combined named Lean declaration in draft PR #878 has **not yet passed its exact-head compilation gate** as of this draft. It must remain a proposed combined formal certificate until the receipt is inspected.

The result concerns existence and classical *input-query* cost; it does not assert polynomial classical time or resolve all conventions for unit-cost quantum oracle access. It assumes known source laws and applies to finite symbol alphabets, with no minimum-atom lower bound.

## 5. Approximate product mixtures

Let \(\tilde\nu\) be an \(M\)-component product mixture and \(\nu\) any other finite input law satisfying \(\mathrm{TV}(\nu,\tilde\nu)\le\eta\). For any event \(E\),
\[
\nu(E)\le\tilde\nu(E)+\eta.
\]
The elementary finite-sum proof writes \(d(x)=\nu(x)-\tilde\nu(x)\), uses \(\sum_xd(x)=0\), and bounds the event contribution by \((d(x)+|d(x)|)/2\), summed over all \(x\). The inequality therefore also holds for any test function taking values in \([0,1]\).

**Corollary 5 (TV robustness; source-level Lean candidate).** Running the classical simulator constructed for \(\tilde\nu\) on an actual input drawn from \(\nu\) uses the same maximum number of queries, and its failure probability is at most
\[
\frac{A_{2T}(M,\tau)}n+\frac{\tau}{\varepsilon^2}+\eta.
\]
This does not require identifying the latent mixture component. The complete Lean proof of the finite TV transfer and its circuit composition is in draft PR #878; its exact-head CI remains a merge gate.

## 6. Relation to prior work and scope limits

- **Aaronson–Ambainis (2014).** The original simulation and low-degree influence conjectures on uniform Boolean inputs establish the central question and polynomial-method connection.
- **Turturean (2026), arXiv:2611.09773.** A Lean-verified proof of the uniform-cube low-degree influence conjecture, supplying the fundamental row/endpoint mechanisms; our product-space development uses and credits vendored portions.
- **Girish–Mittal–Nehoran–Raz (2026), arXiv:2609.35327.** Equivalences between uniform and fixed-biased Boolean product and slice variants; this does not directly state the present uniform-in-all-biases, arbitrary-finite-alphabet, finite-mixture guarantee.
- **Blais–O'Donnell–Wimmer (COLT 2008).** Polynomial regression and agnostic learning under arbitrary products and mixtures. This precedent is essential to a serious priority comparison; learning labeled examples is a different access model from adaptive symbol-query simulation, but the analytical representations overlap.
- **Blanc–Docter–Strassle–Tan (2026), arXiv:2608.19158.** Parallel-query simulation and its stronger query-weight Conjecture 2. The latter would imply polylogarithmic dependence on inverse failure probability and stronger random-oracle implications. Our bounds retain polynomial dependence on \(1/\delta\).
- **Huffstutler–Miloschewsky–Podder (2026), arXiv:2611.12795.** A completion-framework quantum simulation result on the uniform Boolean cube with different promise/accuracy assumptions; weighted generalization remains a priority-review question.

The mixture count is a sufficient structural upper-bound parameter, not a necessary-and-sufficient characterization of classical simulability. Large product-mixture complexity can coexist with extremely easy classical adaptive observation. An exact Gaussian-sign Forrelation input law also admits a separate paper-level information-theoretic exponential mixture lower bound; this is maintained as a distinct, not yet fully Lean-certified research track in PRs #868 and #871, not used as a lemma here.

The manuscript does not assert: classical running-time efficiency; universal source identification from samples; arbitrary correlated distributions; search-output simulation; biased random-oracle complexity-class equivalences; or the strong \(\mathrm{polylog}(1/\delta)\) simulation conjecture. These are open extensions or separate problems.

## 7. Certification, reproducibility and release gates

The exact proof statement matters more than an informal slogan. Confirm the following before submission:

1. Frozen Jensen mixture source: PR #867, head b5e81949dfeb8107de24ad8c9e9baafe8adad9b5, successful run 44456342019. Raw mixture receipt and checksum register archived in draft PR #872.
2. Frozen complex finite matrix-oracle circuit bridge: PR #866, head 424c0a821e9458e0a39f00ea5f89e09d6f9de59f, successful strict run 44460308357.
3. Combined circuit/mixture/TV theorem: PR #878, head ce2428e3ea154dd8003573a1fa7d434bf7c1f2e8 at writing; require exact-head pinned kernel build, printed types and the three standard axioms without sorry, plus receipt archive. Do not promote while running.
4. Reconcile dependency graph and source inventories for merged main and require full unified Lake checks, not merely independent pinned source compilations.
5. Independent mathematical referee to examine posterior drift under all zero-mass branches, the latent Gini bound, matrix-oracle semantics, normalization and true result scope.
6. Comprehensive dated prior-art review, author and license attribution, human author approval, and any institutional ownership/disclosure review. **No arXiv posting or public scientific priority claim is authorized by the existence of this draft alone.**

### References (working)

- S. Aaronson and A. Ambainis, *The Need for Structure in Quantum Speedups*, Theory of Computing 10 (2014). https://arxiv.org/abs/0911.0996
- D. Turturean, *A Proof of the Aaronson–Ambainis Conjecture*, 2026. https://arxiv.org/abs/2611.09773
- U. Girish, K. Mittal, B. Nehoran, R. Raz, *Distributional Variants of the Aaronson–Ambainis Conjecture*, 2026. https://arxiv.org/abs/2609.35327
- E. Blais, R. O'Donnell, K. Wimmer, *Polynomial Regression Under Arbitrary Product Distributions*, COLT 2008, pp. 193–204. https://mlanthology.org/colt/2008/blais2008colt-polynomial/
- G. Blanc, J. Docter, C. Strassle, L.-Y. Tan, *Quantum Speedups Require Structure or Depth*, 2026. https://arxiv.org/abs/2608.19158
- M. Huffstutler, J. Miloschewsky, S. Podder, *A Short Proof of the Aaronson–Ambainis Conjecture via the Completion Framework*, 2026. https://arxiv.org/abs/2611.12795

**Working-paper status:** Complete main statement and proof architecture; the combined circuit and TV results are correctly marked conditional on their outstanding exact-head Lean certificate. An external preprint submission is deferred until those checks and the human gates above.
