# Q2 source preservation without discrete owned-neighbor reconstruction

**Date:** 13 November 2026. **Version:** v1, *analytic alternative under adversarial audit*. **Research:** NIGHTFALL / Devin J. Wright, AI-assisted construction and checking.

**Status:** a complete alternative *author-side analytic route* through the source-preserving step, NOT a new sharp numerical constant, a new end-to-end Lean theorem, independent outside mathematical review, or a cleared historical novelty claim. The rigorous source-matching mass theorem already has a historical scoped kernel certificate. The genuinely new *proposed integration* is a fractional/noise-operator factorization which bypasses the discrete owner-neighbor sample-law bridge. Its elementary ingredients may have strong existing precedents in fractional decompositions and product noise operators; global priority is **not established**.

## The claim

Let \(\mu=\bigotimes_{i=1}^n\mu_i\) be an arbitrary finite heterogeneous product probability law. Each nonempty finite alphabet may have zero-probability atoms; restrict to its positive support when using pointwise suprema. Let real \(f\) be bounded by \(B\) on the positive-support product and have Hoeffding degree \(\le 2\) there. Let
\[
f=m+\sum_i h_i(X_i)+\sum_{i<j}h_{ij}(X_i,X_j)
\]
be its **genuine source-product**, separately centered Hoeffding decomposition. Define
\[
a_i^2=\mathbb E h_i(X_i)^2,\quad
e_{ij}=\mathbb E h_{ij}(X_i,X_j)^2,\quad
I_i=a_i^2+\sum_{j\ne i}e_{\{i,j\}},\quad
V=\sum_i a_i^2+\sum_{i<j}e_{ij},\quad M=\max_i I_i.
\]
Define source pair amplitude \(w_{ij}=\max_{a,b\text{ in positive support}}|h_{ij}(a,b)|\).

### Lemma A — actual-source matching amplitude (independent short reconstruction)

For every vertex-disjoint matching \(R\), \(\sum_{\{i,j\}\in R}w_{ij}\le4B\).

**Proof using a single shared parity bit.** For each edge \(e=\{i,j\}\in R\) choose a supported pair \((a,b)\) maximizing \(|h_{ij}|\). Separate centering gives
\[
h_{ij}(a,b)=\mathbb E_{a',b'}
[h_{ij}(a,b)-h_{ij}(a',b)-h_{ij}(a,b')+h_{ij}(a',b')].
\]
After choosing the favorable orientation, some supported four-corner rectangle \(\Delta_e\) is at least \(w_e\). Independently draw one fair bit \(U_e\) for each matching edge. In the **even** experiment, simultaneously take the first endpoint's value \(a_{U_e}\) and second endpoint's value \(b_{U_e}\). In the **odd** experiment, retain \(a_{U_e}\) but take \(b_{1-U_e}\). Fix unmatched source coordinates at arbitrary supported base values. Individual coordinate marginal distributions are unchanged between the two auxiliary experiments. Distinct matching blocks remain independent, so every source singleton and every *nonmatching* quadratic term has exactly the same expectation in both experiments, even if the original pair graph is dense. The matching-edge expectation difference is exactly \(\Delta_e/2\). Thus
\[
\mathbb Ef(X_{\rm even})-\mathbb Ef(X_{\rm odd})
=\tfrac12\sum_{e\in R}\Delta_e\le 2B,
\]
hence \(\sum_Rw_e\le4B\). The auxiliary even/odd law is **not falsely identified with \(\mu\)**: it is used only to extract pointwise rectangles of the original bounded source \(f\). All energies below use the original \(\mu\). The same mathematical matching principle was already available in NIGHTFALL's compiled packed-parity source lemma, and is **not asserted a new discovery**. \(\square\)

### Lemma B — source-generated cost vector (established greedy operator)

Greedily process edges by decreasing \(w_{ij}\); retain an edge when both endpoints are unused. Put its weight at both selected endpoints and zero at other endpoints. Then
\[
c_i\ge0,\qquad\sum_i c_i\le8B,\qquad
w_{ij}\le\max(c_i,c_j)\le\sqrt{c_i^2+c_j^2}.
\]
This is the original matching-to-cover construction (historically scoped Lean certificates exist), but it does **not** assign any edge a unique owner.

### Lemma C — source-preserving soft ownership (alternative bridge)

For \(i\ne j\), if \(d_{ij}=\sqrt{c_i^2+c_j^2}>0\), let
\[
\lambda_{ij}=\frac{c_i}{d_{ij}},\qquad
\lambda_{ji}=\frac{c_j}{d_{ij}}.
\]
If \(d_{ij}=0\), set both \(\lambda\)'s to zero; then \(w_{ij}=e_{ij}=0\), so there is no nonzero edge to allocate. Thus
\[
0\le\lambda_{ij}\le1,\quad
\lambda_{ij}^{2}+\lambda_{ji}^{2}=1\ \text{on nonzero edges},\quad
\lambda_{ij}w_{ij}\le c_i.
\]
For each original coordinate \(i\), write the actual centered source section
\[
U_i(a;x_{-i})=f(x_{-i},a)-\mathbb E_{p_i}f(x_{-i},X_i)
            =h_i(a)+\sum_{j\ne i}h_{ij}(a,x_j).
\]
Define the *soft pair section* and its moments entirely on original source coordinates:
\[
H_i(a;x_{-i})=\sum_{j\ne i}\lambda_{ij}h_{ij}(a,x_j),\qquad
s_i=\mathbb E\|H_i(\cdot;X_{-i})\|_{L^2(p_i)}^2,\qquad
z_i=\mathbb E\|H_i(\cdot;X_{-i})\|_{L^2(p_i)}.
\]
Then
\[
\boxed{s_i=\sum_{j\ne i}\lambda_{ij}^2 e_{\{i,j\}}\le I_i,\qquad
       \sum_i s_i=\sum_{i<j}e_{ij}.}
\tag{C1}
\]
**Proof.** For each fixed \(i\), the vectors
\(Y_{ij}=(\sqrt{p_i(a)}\lambda_{ij}h_{ij}(a,X_j))_{a\in A_i}\)
are functions of **distinct original independent coordinates \(X_j\)** and centered in \(X_j\). Their cross second moments vanish under the *original* product law, giving \(s_i=\sum_j\lambda_{ij}^2e_{ij}\). The coefficients are nonnegative, \(\lambda^2\le1\), and \(I_i\) contains all incident \(e_{ij}\), proving \(s_i\le I_i\). Summing over endpoints and using \(\lambda_{ij}^2+\lambda_{ji}^2=1\) for each nonzero pair proves exact total energy. This is not a globally independent collection indexed by \(i\); we need independence **only among \(j\) for each fixed \(i\)**. \(\square\)

### Lemma D — noise contraction replaces owner-conditioned projection

For each \(i\), let \(\mathbb E_j\) refresh just original coordinate \(j\) according to \(p_j\), and define the original-source *coordinate noise operator*
\[
\mathcal Q_i=\prod_{j\ne i}
     \big(\lambda_{ij}\mathrm{Id}+(1-\lambda_{ij})\mathbb E_j\big).
\tag{D0}
\]
Each factor is a Markov kernel (convex combination of retention and original-law refresh); they commute. Separate centering proves the **pointwise source identity**
\[
\boxed{\mathcal Q_i U_i=h_i+H_i.}\tag{D1}
\]
No synthetic fresh-neighbor table, finite neighbor injection, edge orientation, or comparison of recursively constructed sample-law moments is needed. Because \(\mathcal Q_i\) is a genuine source-measure-preserving Markov contraction, Hilbert-valued Jensen and stationarity yield
\[
\mathbb E\|h_i+H_i\|_{L^2(p_i)}
=\mathbb E\|\mathcal Q_iU_i\|_{L^2(p_i)}
\le\mathbb E\|U_i\|_{L^2(p_i)}.
\]
Consequently, letting \(u_i=\mathbb E\|U_i\|_{L^2(p_i)}\),
\[
\boxed{z_i\le u_i+a_i.}\tag{D2}
\]
This is the specific replacement for the old owner's conditional expectation on its owned-neighbor set. It works with overlapping neighbor sets at different owners, because no independence *across owners* is used. \(\square\)

### Lemma E — original-source fourth moment (exactly the existing local lemma)

Each \(Y_{ij}\) above is Hilbert-valued, independent over \(j\) for fixed \(i\), centered, and satisfies \(\|Y_{ij}\|\le\lambda_{ij}w_{ij}\le c_i\) on the original source. Standard independent Hilbert fourth-moment expansion gives
\[
\mathbb E\|H_i\|^4\le c_i^2s_i+3s_i^2.
\tag{E1}
\]
By Cauchy-Schwarz/Hölder interpolation and \(s_i\le M\),
\[
s_i^{3/2}\le z_i(\mathbb E\|H_i\|^4)^{1/2}
\quad\Longrightarrow\quad
\boxed{s_i\le z_i(c_i+\sqrt{3M})}.
\tag{E2}
\]
The zero \(s_i=0\) case is immediate. This uses the previously separately compiled **independent** Hilbert fourth-moment mechanism, not the false independence of global Doob differences. \(\square\)

### Corollary — the same stronger Q2 coefficient by a shorter source path

The previously reconstructed genuine-source degree-two switching estimate yields
\(\sum_i u_i\le8B\). Product-refresh interpolation yields the genuine additive budget
\(\sum_i a_i\le\alpha B\), \(\alpha=2(1+\sqrt2)\). In each case only the original law and bounded source function are used; see the source-level analytic proof in PR #448. In particular, \(\sum_i z_i\le(8+\alpha)B\); also \(z_i\le\sqrt{s_i}\le\sqrt M\).

Combining exact variance Parseval, (C1), (D2), (E2) and \(\sum c_i\le8B\):
\[
\begin{aligned}
V&=\sum_i a_i^2+\sum_i s_i\\
 &\le \sqrt M\sum_i a_i+\sum_i c_i z_i+\sqrt{3M}\sum_i z_i\\
 &\le (\alpha+8+\sqrt3(8+\alpha))B\sqrt M\\
 &= (10+2\sqrt2)(1+\sqrt3)B\sqrt M.
\end{aligned}
\]
Hence the **author-analytic finite-product candidate**
\[
\boxed{V^2\le (10+2\sqrt2)^2(1+\sqrt3)^2\,B^2\max_i I_i,
\quad K_2\approx1228.356323837.}
\tag{Q2-soft}
\]
This is not a distinct improvement in the constant or exponent over PR #448. Its significance is that it **eliminates the hardest owner-specific representation bridges from one complete source-level analytic proof route**. The matching mass gate remains as a known ingredient. Universal validity and priority are not promoted to kernel or external certification by this new derivation.

## Failure attacks and exact validation

A separate exact-rational *source enumeration* program was executed locally in this session on 36 random heterogeneous finite quadratic models and two categorical address models, including zero-mass atoms, using only positive-support pointwise bounds. It checked:

- 1,043 exact full-word ANOVA identities;
- 742 source-centering identities;
- 278 exhaustive edge-matching 4B bounds **and 278 direct even/odd original-function coupling equalities**;
- 36 source-generated 8B greedy covers;
- 149 exact fractional \(\lambda^2\) energy partitions, amplitude envelopes and source influence inequalities;
- 117 independently expanded rational Hilbert fourth moments and moment bounds;
- 3,170 exact *original-function Markov refresh* identities (tested for rational \(\lambda\), thereby challenging (D1)'s general algebraic identity);
- 36 exact-rational checks of the weaker explicit coefficient \(1229>K_2\).

A separate implementation in \(\mathbb Q(\sqrt2)\) (exact algebra, not floating point) directly enumerated the three-sign quadratic triangle \(f=x_0x_1+x_0x_2+x_1x_2\). It verified \(c=(1,1,0)\), owner \(i=0\) split \(\lambda_{01}=1/\sqrt2\), \(\lambda_{02}=1\); the direct fourth moment \(\mathbb E\|H_0\|^4=17/4\), \(s_0=3/2\); and the exact original-source Markov identity. Its negative control verifies the global martingale differences' squares are dependent: \(D_2^2=2(1+D_1)\). This explicitly defeats the tempting **incorrect** global independence shortcut without defeating the local owner-indexed source construction.

These tests are finite falsification, not an independently refereed proof of the universal theorem. Exact reproducibility artifacts in this conversation:

- \`check_q2_soft_ownership_exact.py\` — Python stdlib + \`fractions.Fraction\` only; SHA-256 \`26c867d2b23d056638ea6c40eba6f7f3fe1e0ad8dc04e3736052359fe25aef75\`.
- \`check_q2_soft_ownership_independent.py\` — separate exact \(\mathbb Q(\sqrt2)\) arithmetic; SHA-256 \`e929586841e5b488c82ef67ecef9fdbc4abc700ad7e07eee9220e8e689755d9d\`.

These are sandbox artifacts until actually committed: **do not claim a GitHub CI run or repo copy without explicit source upload**.

## Novelty and strongest historical reference checked

Before asserting any discovery of a global product influence inequality, compare the exact theorem type against classical bilinear/Grothendieck, decoupling, product-chaos, coordinate-noise and contraction literature. Specific references checked:

- Aaronson, Ambainis, Iraids, Kokainis, Smotrovs (ECCC 2015/196), *Polynomials, Quantum Query Complexity, and Grothendieck's Inequality*: known binary quadratic method, which does **not** automatically transfer to arbitrary categorical alphabets.
- de la Peña and Giné (1999), *Decoupling: From Dependence to Independence*: further detailed source theorem comparisons required.
- Filmus, Hatami, Keller, Lifshitz (2016), *On the Sum of L1 Influences of Bounded Functions*: cube-scope bounds.
- de Jong (1990) generalized multilinear forms, and classical Hoeffding/Efron–Stein ANOVA.
- Existing generalized coordinate noise/refresh operators are **classical**; the particular soft-ownership integration must not be represented as their invention.
- PR #447's exact categorical address obstruction to naive \(\sum_i\sqrt{I_i}\) and its false global martingale independence example.

A cursory web query found no identical named "soft ownership" statement, which is **not** a claim of novelty. A specialist needs to compare the weighted partition plus Markov contraction with established factorization/decoupling theorems in exactly this source model.

## Revised dependency graph and cheapest decisive next steps

**Historical hard-owner path:** source matching \(\to\) greedy 8B costs \(\to\) exact-once edge assignment \(\to\) owner orientation \(\to\) injected neighbor enumeration \(\to\) independent-sample law transfer \(\to\) owner-conditioned Jensen \(\to\) fourth moment \(\to\) Q2.

**Soft-owner path:** source matching \(\to\) **same** greedy 8B costs \(\to\) **fractional norm-preserving edge weights** \(\to\) **source Markov-noise Jensen** + original pair-energy Parseval + local independent fourth moments \(\to\) Q2.

1. **Next Lean target:** an original-source finite lemma with *arbitrary* parameters \(0\le t_{ij}\le1\) proving \(\mathcal Q_iU_i=h_i+\sum_jt_{ij}h_{ij}\) and vector-norm \(L^1\) contraction on the actual \(p\) product, permitting zero atoms. This isolates the key operator with no square roots.
2. Prove in Lean the real-algebraic weight constraints \(\lambda_{ij}^2+\lambda_{ji}^2=1\) and \(\lambda_{ij}w_{ij}\le c_i\) (zero denominator case). Source matching and source-greedy \(c\) are already separately compiled; ensure source-identical import.
3. Compose original source pair Parseval, fourth moment and noise Jensen, print one theorem **without** supplied amplitude, matching, energy, or moment hypotheses.
4. Only then run a same-source mathematical outsider proof attack and prior-art subsumption audit. Do not replace the full theorem's certificate with isolated tests or a smoke declaration.

**Stop rule:** if the generalized noise operator reproduces the owned-neighbor source-difficulty through hidden nonpositive weights, a false original-law identity, or an unjustified global independence substitution, demote the replacement and retain the exact failing source model. Otherwise prioritize this simpler mechanism over formalizing an arbitrary hard owner orientation.
