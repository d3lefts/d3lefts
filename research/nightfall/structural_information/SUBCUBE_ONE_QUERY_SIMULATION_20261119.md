# NIGHTFALL — the subcube source admits a non-frame one-query simulator

Date 2026-11-19 (America/New_York). **Status: complete author-side conditional-free theorem for T=1, with an independent exact finite verifier; NOT a Lean theorem, a human referee report, a priority-cleared novelty claim, or a general-T simulator.** Designed as a complementary continuation of Claude's tensor-subcube construction and Theorem H (source branch \`structural-information-theory\`), and parallel PRs #956/#957/#959.

## Objective, assumptions, and best result

We work in the standard **bit-oracle quantum query model**, allowing arbitrary known inter-query unitaries, workspaces, intermediate measurements via purification, and unlimited nonuniform preprocessing. Let \`s\` be uniformly random in \(\mathbb F_2^m\), and the observed binary oracle be \`x_i=<g_i,s>\` for specified public row vectors \`g_i\`. A single-query quantum algorithm \`Q\` has acceptance function \(f(s)\in[0,1]\).

Unlike a frame theorem, the new simulation uses the pair-collision structure of the row set **and the positive-contraction structure of the actual one-query circuit**, not merely the low-degree Fourier support of its acceptance polynomial.

**Main terminal (paper).** For the tensor-subcube rows
\[
R_L=\{u_1\otimes\cdots\otimes u_L:\;u_j\in\{(1,0),(0,1),(1,1)\}\}
\subset\mathbb F_2^{2^L},
\]
for every \(L\ge1\), \(0<\varepsilon,\delta<1\), and every single-query quantum acceptance function \(f\) on the original \(3^L\) observed bits, there exists a deterministic, nonuniform classical decision tree of depth at most
\[
\boxed{\min\left\{3^L,\left\lceil \frac{4L+4}{\varepsilon^2\delta}\right\rceil\right\}}
\]
whose output \(g(x)\in[0,1]\) satisfies
\[
\Pr_{s\sim\mathrm{Unif}}[|g(Gs)-f(s)|>\varepsilon]\le\delta.
\]
The tree does not require a high-girth frame, Route 1, a Wyner theorem, or a time-efficient simulator constructor. It exploits a **quantum-specific** positive semidefinite matrix factorization.

This gives a genuine positive **T=1** answer to the query-complexity alternative raised in TOWERS. The general \(\mathrm{poly}(T,L)\) statement and possible \(\mathrm{poly}(L)\)-query quantum vs \(2^{\Omega(L)}\)-classical task remain OPEN.

## Theorem A — general bounded-XOR-fiber simulator

Let \(D=\{0\}\cup\{g_i\}\) be the **distinct** available row frequencies plus zero, and define
\[
M(D)=\max\left(1,\max_{u\ne0}
  \left|\{(r,t)\in D^2:r+t=u\}\right|\right),
\]
counting **ordered pairs**. The maximum is taken only over nonzero differences; the potentially huge fiber at \(u=0\) is irrelevant because its terms are diagonal.

**Theorem.** Every one-query quantum bit-oracle algorithm on \(x_i=\langle g_i,s\rangle\), with uniformly random \(s\), has a deterministic classical \((\varepsilon,\delta)\) simulator using at most
\[
\boxed{\min\left(n,\left\lceil2M(D)/(\varepsilon^2\delta)\right\rceil\right)}
\]
original observed-bit queries.

**Proof (circuit exact, not an arbitrary bounded degree-two polynomial).** Purify the quantum algorithm and conjugate the answer qubit by a Hadamard. Immediately after its unique oracle call and after absorbing the final fixed unitary into a measurement effect \(0\le P\le I\), the state has the phase form
\[
|\psi_s\rangle=\sum_{r\in D}\chi_r(s)|v_r\rangle,\qquad
\chi_r(s)=(-1)^{\langle r,s\rangle},
\]
where the vectors \(v_r\) are **mutually orthogonal** and \(\sum_r\|v_r\|^2=1\). Why: each row-frequency term occupies the \(|-\rangle\) answer-eigenspace at its own oracle index, while the zero-frequency \(|+\rangle\) terms are orthogonal to them; repeated original rows are grouped into an orthogonal direct sum without changing this property.

Let \(p_r=\|v_r\|^2\), omitting zero-mass indices, and \(w_r=v_r/\sqrt{p_r}\). The \(w_r\) are orthonormal. Define \(A_{rt}=\langle w_r,Pw_t\rangle\). Then \(0\le A\le I\), \(A\) is Hermitian, and
\[
\sum_t|A_{rt}|^2=(A^2)_{rr}\le A_{rr}\le1
\quad\text{for every }r.
\tag{A1}
\]
The acceptance function is
\[
f(s)=\sum_{r,t\in D}
 \sqrt{p_rp_t}\,A_{rt}\,\chi_{r+t}(s).
\tag{A2}
\]
Set \(\tau=\varepsilon^2\delta/(2M)\) and choose the **heavy original row frequencies** \(H=\{r:p_r\ge\tau\}\). There are at most \(1/\tau\) of them, and the \(\chi_0\) character is free.

Query each original observed row corresponding to \(r\in H\setminus\{0\}\), and output
\[
g(s)=
 \sum_{r,t\in H}\sqrt{p_rp_t}\,A_{rt}\,\chi_{r+t}(s)
 +\sum_{r\notin H}p_r A_{rr}.
\tag{A3}
\]
This is a **real-valued** function of queried row bits. Moreover \(g(s)\in[0,1]\): the heavy quadratic form is nonnegative and at most \(\sum_{H}p_r\), while the omitted diagonal constant lies in \([0,\sum_{D\setminus H}p_r]\).

In \(f-g\), diagonal terms cancel. Every remaining ordered offdiagonal pair has at least one **light** endpoint. For each nonzero \(u\), at most \(M\) ordered pairs satisfy \(r+t=u\). Orthogonality of the characters under uniform \(s\), followed by Cauchy–Schwarz, yields
\[
\mathbb E_s|f(s)-g(s)|^2
 \le M\sum_{\substack{r\ne t\\r\notin H\;\lor\;t\notin H}}
         p_rp_t |A_{rt}|^2.
\tag{A4}
\]
The sum is at most \(2\tau\), **regardless of the number of light rows**:
\[
\sum_{\substack{r\notin H\\t\in D}}p_rp_t|A_{rt}|^2
\le\tau\sum_t p_t \sum_r |A_{rt}|^2\le\tau;
\]
likewise for pairs with \(t\notin H\). Therefore
\[
\mathbb E_s|f-g|^2\le2M\tau=\varepsilon^2\delta.
\tag{A5}
\]
Markov's inequality gives the desired event guarantee. If the nominal bound exceeds \(n\), simply query all \(n\) observed bits and simulate the fixed quantum circuit's acceptance probability exactly, at no restriction on classical computation time. QED.

**Important limits.** The quantum prequery frequency vectors are orthogonal only because there is **one** oracle call. With two or more adaptive calls, frequency-expansion vectors need not remain orthogonal; neither (A1) nor the bound follows automatically for the full \(T\)-query state. We have NOT claimed a general \(T\) theorem. No analogous bound is claimed for arbitrary globally bounded degree-two polynomials without the quantum PSD structure. If a source is not uniform on its secret space, character orthogonality must be replaced by a separate Gram operator estimate.

## Theorem B — exact maximum pair multiplicity for subcube rows

For all \(L\ge1\),
\[
\boxed{M(\{0\}\cup R_L)=2L+2.}
\tag{B1}
\]

**Independent structural proof.** Over \(\mathbb F_2\) the only three nonzero vectors of \(\mathbb F_2^2\) are \(u,v,u+v\), so an \(L\)-fold nonzero pure tensor has a unique sequence of factors (no nontrivial nonzero scalar rescaling). Let \(a,b\in R_L\) be distinct and let \(d\) be the number of tensor positions at which they differ.

1. **\(d=1\).** Their sum is a nonzero pure tensor. Conversely, if the sum of two distinct nonzero pure tensors is pure, the factors must differ in exactly one position. Every target pure tensor \(z\in R_L\) admits \(L\) choices of active position, and for each position exactly two ordered choices of the other two nonzero factor vectors whose sum is its factor there. Thus **exactly \(2L\)** ordered nonzero-row pairs sum to \(z\). Adjoining the zero frequency gives the two additional pairs \((0,z),(z,0)\), for a fiber of \(2L+2\).

2. **\(d\ge2\).** For \(z=a+b\), its flattening along a tensor position \(j\) has rank exactly two when \(a_j\ne b_j\), and rank one when \(a_j=b_j\). For differing \(j\) the remaining factor tensors are independent because at least one more position differs; for equal \(j\), the flattening is a nonzero pure factor. Therefore the set of differing positions is an **invariant of \(z\)**, so two decompositions with different values of \(d\ge2\) cannot represent the same \(z\), and none can represent a pure tensor.

3. **\(d=2\).** Strip off the common nonzero tensor factors (uniquely determined, since the base field has no nontrivial scalars). The remaining rank-two \(2\times2\) binary matrix has exactly **six** ordered decompositions into two rank-one nonzero summands: choose one of the \(|\mathrm{GL}_2(\mathbb F_2)|=6\) ordered bases on the first mode; the two second-mode factors are then uniquely determined.

4. **\(d\ge3\).** Flatten at one differing position. The image on the other factors is the two-dimensional span of nonzero pure tensors \(A,B\) which differ in at least two remaining positions. Its only three nonzero vectors are \(A,B,A+B\); the last is **not pure**, as it has flattening rank two. Hence that image contains exactly two nonzero pure tensors. Every alternate decomposition must use precisely \(A,B\) as its tail factors, and the first factors follow uniquely. Thus the decomposition is unique up to swapping: exactly **two** ordered pairs.

All nonzero fibers therefore have size \(2L+2\), \(6\), or \(2\). For \(L\ge2\), \(2L+2\ge6\); for \(L=1\), only the first case occurs. Since pure-target fibers attain \(2L+2\), (B1) follows. QED.

Combining Theorems A and B gives the claimed classical query depth \(\lceil(4L+4)/(\varepsilon^2\delta)\rceil\). Its coefficient is not optimized; the structural operator and dimension-independence matter.

## Independent finite adversarial audit

The attached \`scripts/check_subcube_one_query.py\` uses only integer XOR and exact rational arithmetic. It:

- independently enumerates every ordered pair XOR fiber through \(L=5\), confirming the maximum \(2L+2\) and the classifications (pure targets vs 2/6 collisions);
- independently exhausts all \(2^{2^L}\) secret assignments at \(L=1,2,3\) for explicit one-query algorithms with a normalized, nonuniform initial state and a rank-one positive projection;
- constructs the heavy-query surrogate and independently computes its mean-square error from both direct enumeration and the grouped Fourier coefficients; verifies the exact equality (Parseval), the Cauchy–Schwarz fiber bound, and the \(\le2M\tau\) matrix estimate;
- records source hash and full exact-head output via a dedicated GitHub Actions workflow.

These tests do not substitute for the all-\(L\) and all-quantum-circuit proofs. The latter are the two independent written derivations above. No Lean terminal or external independent referee review has been obtained.

## Connection to prior art and the precise remaining gap

- The phase query / polynomial method and structural positivity of quantum acceptance functions are standard quantum-query theory. Relevant context includes Arunachalam–Briët–Palazuelos, *Quantum Query Algorithms are Completely Bounded Forms*, and Bansal et al., *Influence in Completely Bounded Block-Multilinear Forms and Classical Simulation of Quantum Algorithms*, CCC 2022, https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.CCC.2022.28.
- The polynomial simulation problem over product inputs is addressed by the Aaronson–Ambainis/product-space research in this repository; we do **not** need its still-unfinished Route 1 mixture terminal here.
- The multiplicity classification is elementary rank-two tensor uniqueness over \(\mathbb F_2\); a specialist prior-art comparison of *this exact quantum-fiber simulation lemma* has NOT been completed. No novelty or world-first claim.
- The high-girth frame obstruction in Claude's Theorem H and PRs #956/#957/#959 is complementary: those prohibit cheap global high-girth frames, while the new simulator queries only high-probability prequery oracle rows and invokes an exact Walsh/PSD orthogonality estimate. This is a concrete mechanism by which **a bad frame can coexist with an efficient quantum-to-classical simulation** for T=1.

**Next falsifiable experiment:** attempt the \(T=2\) case by replacing the lost one-query frequency orthogonality with a matrix/operator-norm inequality for two-query path expansions. First independently find a counterexample to the naïve orthogonality extension; only then formulate a non-frame two-query potential. Parallel alternate attack: design an explicit two-query quantum acceptance function with variance bounded below and prove a superpolynomial-in-\(L\) classical row-query lower bound. The family-wide quantum-vs-classical alternative is not decided by the T=1 theorem.

**Discovery graph:** tensor-subcube family → exact rank-two XOR fibers → positive-contraction query matrix → heavy-frequency truncation → dimension-independent one-query simulation → exact audit → general-\(T\) orthogonality obstruction.

**Priority:** preserves source contributors, open review gates and failed frame approach. No merge or publication authorized.
