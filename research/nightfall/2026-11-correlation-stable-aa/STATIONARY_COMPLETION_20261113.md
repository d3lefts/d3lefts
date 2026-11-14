# A multiclass stationary completion theorem beyond product measures

**NIGHTFALL research note | 13 November 2026 | Author-directed, AI-assisted derivation**

**Claim status:** Self-contained finite-model analytic theorem and exact rational falsification. This extends an **adversary/completion mechanism**, NOT the maximum-coordinate Aaronson–Ambainis influence bound. It does not make a distribution-free correlated AA influence theorem: the parity counterexample forbids that. Historical novelty and expert review remain unresolved.

## Historical placement

Huffstutler, Miloschewsky and Podder's November 9, 2026 completion proof (arXiv:2611.12795), developed in the broader 2026 promises/completions programme (arXiv:2603.29256), **subsumes the original Boolean AA problem** by working with the classical adversary measure rather than only polynomial degree. The relevant operative object is a completion of a partial function preserving a controlled coordinate-boundary quantity. The proof below extracts and extends *that* mechanism to multiple labels, arbitrary finite joint distributions, and coordinate-local stationary update channels. Classical Lipschitz/random perturbation and adversary methods are antecedents. This note does not claim first discovery of completion/random-shift machinery.

## Definitions

Let \(\Omega=\prod_{i=1}^n\Omega_i\) be finite. A partial labelled function \(F:A\to[q]\), \(A\subseteq\Omega\), has nonempty classes \(A_b\) for b=1,...,q. For each labelled source \(x\in A\), fix nonnegative weights \(\lambda_i^x\) such that for every x,y of **different labels**

\[
\sum_{i:x_i\ne y_i}\min(\lambda_i^x,\lambda_i^y)\ge1.
\tag{1}
\]

Let coordinate read/channel costs \(w_i\ge0\), and set

\[
K_b=\sup_{x\in A_b}\sum_i w_i\lambda_i^x.
\]

For every class b define a cost-to-class extension

\[
d_b(z)=\min_{x\in A_b}\sum_{i:z_i\ne x_i}\lambda_i^x.
\tag{2}
\]

Choose independent continuous \(U_b\sim{\rm Uniform}[0,1]\), and define a completed total classifier

\[
G_U(z)=\arg\min_{b\in[q]}\{d_b(z)+U_b\},
\tag{3}
\]

with fixed tie-breaking. The completion randomness is chosen independently of source law, channels, and state.

Let \(\nu\) be **any** probability law on \(\Omega\), possibly singular and correlated. For each coordinate i let \(P_i\) be a Markov kernel changing only coordinate i. Require **aggregate weighted stationarity**

\[
\sum_iw_i\nu P_i=\left(\sum_iw_i\right)\nu.
\tag{4}
\]

Individual P_i need not be reversible, and the entire law need not be a product. Define the edge-disagreement energy of a total label G by

\[
\mathcal E_i^\nu(G)=\frac12\sum_{z,y}\nu(z)P_i(z,y)\mathbf1\{G(z)\ne G(y)\}.
\]

The half normalization is important: these are stationary Markov boundary energies, not necessarily conditional-resampling Efron–Stein influences.

## Theorem: stationary multiclass low-boundary completion

Under (1)-(4), \(G_U(x)=F(x)\) for every x in A almost surely (simultaneously), and

\[
\boxed{\mathbb E_U\sum_iw_i\mathcal E_i^\nu(G_U)\le\sum_{b=1}^qK_b.}
\tag{5}
\]

This bound has **no factor for** n, alphabet sizes, smallest source atom, correlation, or reversibility. It holds for any finite number of classes. The value \(\sum_bK_b\) is a class-split adversary budget, rather than automatically the minimal classical adversary parameter.

### Proof

**Extension.** Fix x in A_b. Then \(d_b(x)=0\). For any c≠b and y in A_c, \(\sum_{i:x_i\ne y_i}\lambda_i^y\ge\sum_i\min(\lambda_i^x,\lambda_i^y)\ge1\); so \(d_c(x)\ge1\). Since independent U_b belong to [0,1], \(d_b(x)+U_b<d_c(x)+U_c\) with probability1, hence \(G_U(x)=b\). Finite A permits simultaneous probability one.

**One-coordinate stability.** For z,y differing only at i, let x be a source anchor achieving the minimum (2) at z. Then
\(d_b(y)\le d_b(z)+\lambda_i^x\). Denote the positive part \([d_b(y)-d_b(z)]_+\). For any fixed z, after averaging P_i(z,dy) and multiplying by w_i, this is at most \(w_i\lambda_i^x\). Summing i yields

\[
\sum_i w_i\mathbb E_{Y\sim P_i(z)}[d_b(Y)-d_b(z)]_+\le K_b.
\tag{6}
\]

For any two fixed z,y and independent U, if the winning class changes then for some class b its perturbation U_b crosses an interval of length at most \(|d_b(y)-d_b(z)|\), conditional on the other shifts and fixing that other classes' scores. A union bound therefore gives

\[
\Pr_U[G_U(z)\ne G_U(y)]\le\sum_b|d_b(y)-d_b(z)|.
\tag{7}
\]

**Stationary symmetrization without reversibility.** Equation (4) implies \(\sum_i w_i\mathbb E_{\nu,P_i}(d_b(Y)-d_b(X))=0\). Therefore the weighted expected negative part equals the positive part, giving

\[
\sum_iw_i\mathbb E_{\nu,P_i}|d_b(Y)-d_b(X)|
=2\sum_iw_i\mathbb E_{\nu,P_i}[d_b(Y)-d_b(X)]_+
\le2K_b.
\tag{8}
\]

Combining (7), (8) and the factor 1/2 in the definition of \(\mathcal E_i\) proves (5). QED.

## Why this changes scope, and where it does not

The proof works for **correlated**, even singular laws, and nonreversible coordinate channels provided the *weighted mixture* preserves the law. It retains the native alphabet and avoids biased-bit encodings. It is a structural completion result, not a statement that one original coordinate must have large conditional-resampling influence. In particular, the even-parity law has zero heat-bath influences for certain functions while the completion inequality still holds for a suitable stationary channel.

For source-product heat-bath refresh kernels, choosing w_i=1 gives an immediate special case. Comparing numerical constants with Huffstutler–Miloschewsky–Podder requires matching their exact adversary definition and boundary normalization, not merely comparing the appearance of K.

The source weights \(\lambda_i^x\) and sound stationarity contract are inputs. Finding them efficiently is not asserted. This theorem does not imply a full distribution-free quantum-query AA theorem for correlated inputs.

## Falsification evidence

Replay [check_stationary_completion.py](check_stationary_completion.py). The exact-rational checker constructs 320 finite partial-label source models, 181 two-class examples with *exactly integrated continuous shifts*, 139 three-class grid cases with a rigorously allowed finite-grid error term, 120 nonreversible coordinate-stationary cycles, and nonuniform distributions with zero atoms.

The discrete three-class grid audit checks a quantitative approximation, **not** exact integration of the continuous theorem. All claims about arbitrary q are from the analytic proof.

## Next originality test

Search random-perturbation Lipschitz extension and graph-partition literature for exact theorem subsumption; compare the *same stationary channel, same adversary weights, same boundary functional*. If it is known, credit the result and retain its use as an independently transferable operator. The higher-leverage question is to link this completion energy to a **source-aware routing inequality** that actually yields a lower bound on some coordinate influence under correlated sources, which the parity obstruction shows cannot be automatic.