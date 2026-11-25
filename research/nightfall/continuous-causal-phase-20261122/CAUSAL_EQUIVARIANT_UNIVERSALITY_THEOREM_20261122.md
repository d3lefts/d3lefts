# A causal equivariant universality theorem for continuous adaptive sensing

**NIGHTFALL research manuscript v1.0 — 2026-11-22 (America/Chicago).**  
**Status:** Complete *author-side paper proof* of the specifically stated results, conditional only on named classical topology and extension theorems. Not independently refereed, not Lean kernel-certified, and not priority-cleared. The two-character causal result generalizes the already independently audited Theorem B in PR #1000; do not claim its underlying mechanism is entirely new. The additional multicharacter topology, radius-uniform minimax statement, and exact allocation discussion need independent prior-art audit.

## Abstract

We give a structural obstruction to universal recovery by finite-stage adaptive measurements. A sensor chooses a continuous real matrix block from its attained observation history, and the block is followed by any continuous response even in its linear sensor input. The response may be nonlinear, vector-valued, dependent on the entire history, or non-injective. If the sensor blocks can be assigned to two groups with at most \(n-1\) total linear coordinates in each, any such finite causal protocol on \(\mathbb R^n\) identifies two signals distinct modulo sign. This conclusion survives when policies are defined and continuous **only on their attainable histories**, rather than on every abstract observation sequence. For any radius \(R>0\), the collision can be chosen inside the closed radius-\(R\) ball with projective Euclidean separation **exactly \(R\)**; hence every decoder has worst-case projective error at least \(R/2\). In particular, continuously selected scalar linear intensity measurements require exactly \(2n-1\) readings for universal real phase retrieval when \(n\ge2\), and this is achieved by fixed full-spark frames. We identify the abstract equivariant characteristic-class certificate behind the mechanism and its limits, including counterexamples to unrestricted claims that continuous adaptation never helps.

## 1. Exact sensing model

Let \(n\ge1\), \(m\ge0\), and let \(d_j,\ell_j\in\mathbb N\) be the sensor-input dimension and measured-output dimension at stage \(j\). Put \(H_0=\{()\}\) and \(L_j=\ell_1+\cdots+\ell_j\).

At stage \(j\) the input is \(x\in\mathbb R^n\), the previous *actual* transcript is \(h_{j-1}(x)\in H_{j-1}\subseteq\mathbb R^{L_{j-1}}\), and the instrument chooses
\[
B_j:H_{j-1}\longrightarrow\mathbb R^{d_j\times n}
\]
and then measures
\[
y_j(x)=\Phi_j\bigl(h_{j-1}(x),B_j(h_{j-1}(x))x\bigr)
  \in\mathbb R^{\ell_j},
\qquad
h_j(x)=(h_{j-1}(x),y_j(x)).
\tag{1}
\]
Here \(H_{j-1}=h_{j-1}(\mathbb R^n)\) is endowed with the **subspace topology**, \(B_j\) and
\(\Phi_j:H_{j-1}\times\mathbb R^{d_j}\to\mathbb R^{\ell_j}\) are continuous, and
\[
\Phi_j(h,-z)=\Phi_j(h,z)\qquad
(h\in H_{j-1},\ z\in\mathbb R^{d_j}).
\tag{2}
\]
No boundedness, nonzero-row, detector monotonicity, differentiability, invertibility, normalization, or prior knowledge of unattainable histories is assumed.

For vectors \(x,y\in\mathbb R^n\) write
\[
d_\pm(x,y)=\min\{\|x-y\|_2,\|x+y\|_2\}.
\]
This is the quotient metric on real signals modulo global sign. Universal recovery modulo sign is the assertion that \(h_m(x)=h_m(y)\) implies \(d_\pm(x,y)=0\).

## 2. Main theorem — causal equivariant universality obstruction

**Theorem 1 (exact collisions for even-block causal measurements).** Assume \(n\ge1\) and that stages can be partitioned into two colour sets \(U,V\), in any time order, with
\[
r:=\sum_{j\in U}d_j\le n-1,\qquad
s:=\sum_{j\in V}d_j\le n-1.
\tag{3}
\]
For **every** protocol (1)–(2) and **every** \(R>0\), there are
\(x_+,x_-\in\overline B(0,R)\) such that
\[
h_m(x_+)=h_m(x_-),\qquad d_\pm(x_+,x_-)=R.
\tag{4}
\]
Consequently no decoder, even a discontinuous one, can have worst-case projective Euclidean error less than \(R/2\) on the radius-\(R\) ball, and universal exact recovery modulo sign is impossible.

The finite-dimensional real readout hypothesis is essential to the elementary Tietze extension argument given below; more general codomains require separate extension hypotheses. For continuously chosen rank-\(d_j\) projections **without a continuous matrix lift** (1), the theorem is not automatically applicable.

### Proof of Theorem 1

**Step A: move from attainable-only policies to globally defined continuous even policies, without changing the ball.** Fix \(R>0\) and \(K=\overline B(0,R)\). A causal induction using continuity of \(B_j,\Phi_j\) on their relative domains proves that each actual transcript map \(h_j:\mathbb R^n\to\mathbb R^{L_j}\) is continuous. Therefore
\[
K_{j-1}:=h_{j-1}(K)\subseteq H_{j-1}
\]
is compact, hence closed in the ambient Euclidean history space.

The restriction \(B_j|_{K_{j-1}}\) is continuous and bounded. For each matrix coefficient, bounded Tietze extension supplies a continuous function of **all** ambient histories agreeing with the corresponding coefficient on \(K_{j-1}\). Assembling the coordinates gives a globally continuous
\(\widetilde B_j:\mathbb R^{L_{j-1}}\to\mathbb R^{d_j\times n}\)
equal to \(B_j\) on \(K_{j-1}\).

Choose \(M_j\ge0\) bounding the operator norm \(\|B_j(h)\|_{\mathrm{op}}\) for \(h\in K_{j-1}\). The product
\[
A_j=K_{j-1}\times\overline B_{\mathbb R^{d_j}}(0,RM_j)
\]
is compact, closed in \(\mathbb R^{L_{j-1}}\times\mathbb R^{d_j}\), and invariant under \((h,z)\mapsto(h,-z)\). The restriction of \(\Phi_j\) to \(A_j\) is continuous and bounded, componentwise. Apply bounded Tietze extension to each of its \(\ell_j\) scalar components to obtain a globally continuous \(F_j\), then set
\[
\widetilde\Phi_j(h,z)
=\tfrac12\bigl(F_j(h,z)+F_j(h,-z)\bigr).
\tag{5}
\]
This is globally continuous and even in \(z\). On \(A_j\), it agrees with \(\Phi_j\) by evenness (2) and sign invariance of \(A_j\).

Apply this construction to the **original** protocol data stage by stage, where \(K_{j-1}\) comes from the original transcript on \(K\). By induction on \(j\), the modified globally defined protocol \(\widetilde h_j\) agrees with \(h_j\) at every \(x\in K\): the histories are equal, \(\widetilde B_j=B_j\) there, and the actual block \(B_j(h)x\) has norm at most \(RM_j\), where (5) equals the original detector. Hence
\[
\widetilde h_m|_K=h_m|_K.
\tag{6}
\]
There is **no** use of a globally closed full attainable-history set and no evaluation of the original policies outside their domains.

**Step B: build the two-character continuous virtual-history recursion.** Fix the given colouring, write \(\rho=R/2\), and take independently arbitrary \(u,v\in S^{n-1}\). Define a virtual history \(q_j(u,v)\in\mathbb R^{L_j}\) and a stage obstruction vector \(g_j(u,v)\in\mathbb R^{d_j}\) recursively. Start \(q_0=()\) and put
\[
C_j(u,v)=\widetilde B_j(q_{j-1}(u,v)).
\]
If \(j\in U\), define
\[
g_j(u,v)=C_j(u,v)u,\qquad
q_j(u,v)=\bigl(q_{j-1}(u,v),
   \widetilde\Phi_j(q_{j-1}(u,v),\rho C_j(u,v)v)\bigr).
\tag{7U}
\]
If \(j\in V\), define
\[
g_j(u,v)=C_j(u,v)v,\qquad
q_j(u,v)=\bigl(q_{j-1}(u,v),
   \widetilde\Phi_j(q_{j-1}(u,v),\rho C_j(u,v)u)\bigr).
\tag{7V}
\]
All maps are continuous because the extended policies are continuous on the whole ambient history spaces. By induction on \(j\), \(q_j\) is invariant under both independent sign flips: the induction hypothesis makes \(C_j\) separately invariant, and (5) makes the newly appended output invariant under a sign flip of its sensor argument. Consequently every \(U\)-stage \(g_j\) is **odd in \(u\)** and **even in \(v\)**, while every \(V\)-stage \(g_j\) is **even in \(u\)** and **odd in \(v\)**.

Concatenate the \(U\) stages into \(g_U:S^{n-1}\times S^{n-1}\to\mathbb R^r\) and the \(V\) stages into \(g_V:S^{n-1}\times S^{n-1}\to\mathbb R^s\). These are continuous maps with the exact two pure antipodal characters.

**Step C: invoke the topological obstruction.** The classical product-sphere Borsuk–Ulam zero lemma (§3 below) says every such pair \(g_U,g_V\) has a simultaneous zero when \(r,s\le n-1\). Choose unit vectors \(u,v\) for which **all** \(g_j(u,v)=0\).

**Step D: identify the virtual history with the two actual histories at the zero.** Set \(x_\pm=\rho(u\pm v)\). Their norms satisfy
\(\|x_\pm\|\le\rho(\|u\|+\|v\|)=R\); hence both lie in \(K\).
We prove by causal induction that
\[
\widetilde h_j(x_+)=\widetilde h_j(x_-)=q_j(u,v)\quad(j=0,\ldots,m).
\tag{8}
\]
It is trivial at \(j=0\). Assume it at \(j-1\); both signals then use the same matrix \(C_j\) and detector \(\widetilde\Phi_j\) as in (7U)/(7V). If \(j\in U\), the zero condition says \(C_ju=0\), so
\[
C_jx_+=\rho C_jv,\qquad C_jx_-=-\rho C_jv.
\]
Evenness of \(\widetilde\Phi_j\) makes both observations equal to the virtual output in (7U). If \(j\in V\), the zero says \(C_jv=0\), so both block inputs equal \(\rho C_ju\); their measured outputs equal the virtual entry in (7V). Thus (8) holds for all \(j\).

Taking \(j=m\) in (8), and using (6), proves equality of the **original**, not only extended, full causal transcripts:
\[
h_m(x_+)=h_m(x_-).
\tag{9}
\]

**Step E: quantitative separation and decoder impossibility.** Since \(u,v\) are unit,
\[
x_+-x_-=2\rho v,\qquad x_++x_-=2\rho u,
\]
and hence
\[
d_\pm(x_+,x_-)=\min(2\rho,2\rho)=2\rho=R>0.
\tag{10}
\]
In particular the two signals are distinct modulo global sign. For any (deterministic) decoder \(\Delta\) from measurement transcripts to signal classes, the common transcript \(h_m(x_+)=h_m(x_-)=y\) and the triangle inequality for \(d_\pm\) give
\[
R=d_\pm(x_+,x_-)
  \le d_\pm(x_+,\Delta(y))+d_\pm(\Delta(y),x_-).
\]
At least one error is \(\ge R/2\). No continuity requirement on \(\Delta\) is used. This proves the theorem. \(\square\)

## 3. Topological input and multicharacter generalization

**Lemma 2 (classical two-character product-sphere zero).** For \(n\ge1\), \(r,s\ge0\) with \(r,s\le n-1\), every pair of continuous maps
\(g_U:S^{n-1}\times S^{n-1}\to\mathbb R^r\) and
\(g_V:S^{n-1}\times S^{n-1}\to\mathbb R^s\), respectively odd/even and even/odd under independent sign flips, has a simultaneous zero.

**Proof.** Let \(G=(\mathbb Z/2)^2\) act freely by independent antipodes. Its quotient is
\(B=\mathbb RP^{n-1}\times\mathbb RP^{n-1}\). The pair defines a section of the real vector bundle
\[
E=L_U^{\oplus r}\oplus L_V^{\oplus s}
\longrightarrow B
\]
where \(L_U,L_V\) are pullbacks of the respective tautological lines. If \(r+s=0\), any point is a common zero. Otherwise the mod-two cohomology ring and Whitney product formula give
\[
H^*(B;\mathbb F_2)=\mathbb F_2[\alpha,\beta]/(\alpha^n,\beta^n),
\qquad w_{r+s}(E)=\alpha^r\beta^s\ne0.
\]
A nowhere-zero section would split off a trivial real line and force the top Stiefel–Whitney class to vanish, a contradiction. \(\square\)

**Theorem 3 (arbitrary product-sphere characters; classical equivariant index).** Let \(q\ge1\), \(n_1,\ldots,n_q\ge1\), and \(G=(\mathbb Z/2)^q\) act by independent antipodes on
\[
S=S^{n_1-1}\times\cdots\times S^{n_q-1}.
\]
For \(j=1,\ldots,m\), let \(c_j\in\mathbb F_2^q\) specify a real sign character \(\chi_{c_j}\), and let \(d_j\ge0\). Suppose
\[
P(\alpha_1,\ldots,\alpha_q)
=\prod_{j=1}^m
\Bigl(\sum_{a=1}^q(c_j)_a\alpha_a\Bigr)^{d_j}
\ne0
\quad\text{in }\
\mathbb F_2[\alpha_1,\ldots,\alpha_q]/
(\alpha_1^{n_1},\ldots,\alpha_q^{n_q}).
\tag{11}
\]
Then every continuous equivariant map
\[
g:S\to\bigoplus_{j=1}^m\mathbb R^{d_j}_{\chi_{c_j}}
\tag{12}
\]
has a zero.

**Proof.** If \(D=\sum_j d_j=0\), the target is zero-dimensional and the assertion is immediate. If \(D>0\), the quotient \(S/G\) is
\(B=\prod_a\mathbb RP^{n_a-1}\). Each \(\chi_{c_j}\) defines the tensor-product line bundle
\(L_{c_j}=\bigotimes_{a:(c_j)_a=1}L_a\), and \(w_1(L_{c_j})=\sum_a(c_j)_a\alpha_a\). Map (12) descends to a section of
\(E=\bigoplus_j L_{c_j}^{\oplus d_j}\). By Whitney's formula its top Stiefel–Whitney class is exactly \(P\); (11) makes it nonzero. A nowhere-zero section would split a trivial line summand, making its top class vanish, contradiction. \(\square\)

Theorem 3 supplies a **testable reusable certificate** for any causal construction that independently realizes the character transformation law of (12), together with a stagewise equality implication analogous to (8). It does **not** by itself claim that every arbitrary \(q\)-factor causal sensing model has such a realization. For \(q=2\) with \(c_U=(1,0)\), \(c_V=(0,1)\), formula (11) reduces to \(\alpha^r\beta^s\), and Theorem 1 explicitly constructs the required causal realization.

**Exact certificate boundary.** Nonvanishing of \(P\) is a sufficient zero-forcing test. If \(P=0\), the characteristic-class test is silent; it does not show that a zero-free equivariant map exists or that recovery is possible.

## 4. Two-bin rank certificate and its sharp scope

Let \(C=n-1\), \(d_1,\ldots,d_m\in\mathbb N\), \(S=\sum_jd_j\), and \(M=\max_jd_j\), with \(M=0\) if \(m=0\).

**Lemma 4 (checkable sufficient allocation bound).** If
\[
S\le 2C+1-M,
\tag{13}
\]
then there is a partition of the stages into \(U,V\) with \(\sum_{U}d_j\le C\) and \(\sum_{V}d_j\le C\).

**Proof.** If \(S=0\), assign all stages arbitrarily. If \(0<S\le C\), assign all to \(U\). Otherwise \(S>C\). Set \(L=S-C>0\) and choose the **shortest chronological prefix** whose block sum \(U\) is at least \(L\). Such a prefix exists because the total is \(S\ge L\). The preceding prefix has sum at most \(L-1\), so
\[
L\le U\le (L-1)+M=S-C-1+M\le C
\]
by (13). The complement has \(V=S-U\le C\). \(\square\)

This bound is **sufficient, not necessary**. The exact topological certificate for the two-colour mechanism is existence of a partition with both bin sums at most \(n-1\); that can be decided by finite subset-sum or dynamic programming. In this pure-character representation the polynomial is nonzero **exactly** for such an allocation, since \(\alpha^r\beta^s\) is nonzero in the truncated ring exactly when \(r<n\) and \(s<n\). Failure to allocate is *not* an existence counterexample to the collision theorem; it only blocks this particular certificate.

**Example showing rank total alone is not sufficient.** At \(n=4\), three stages of sensor-input dimension \(d_j=2\) have total dimension \(S=6=2n-2\), but capacity \(C=3\) cannot accommodate two blocks of size 2 in the same bin. Hence Theorem 1 does not follow merely from \(S\le2n-2\) when whole blocks must be kept intact.

## 5. Corollaries and separation from plain dimension counting

**Corollary 5 (sharp continuous-causal real phase retrieval).** For \(n\ge2\), consider a protocol of \(m\) real scalar intensity measurements
\[
y_j(x)=(a_j(h_{j-1}(x))\cdot x)^2,
\]
where \(a_j:H_{j-1}\to\mathbb R^n\) is continuous on the **attainable** preceding squared-output histories. It recovers every \(x\in\mathbb R^n\) modulo sign only if \(m\ge2n-1\). Conversely a fixed full-spark frame with \(2n-1\) vectors succeeds. Therefore
\[
\boxed{m_{\mathrm{continuous\ causal,\ real\ intensity}}(n)=2n-1.}
\tag{14}
\]

**Proof.** Set \(d_j=\ell_j=1\), \(B_j(h)=a_j(h)^\top\), and \(\Phi_j(h,z)=z^2\). If \(m\le2n-2\), colour at most \(n-1\) scalar stages \(U\) and the rest \(V\), so (3) holds; Theorem 1 gives a collision. At \(2n-1\) fixed rows chosen to be full spark, the complement property holds because any partition has a side of size at least \(n\), and every \(n\) rows span. The classical complement-property characterization says the associated real squared-linear map is injective modulo sign. \(\square\)

**Corollary 6 (even nonlinear detectors).** The conclusion of Theorem 1 holds, under (3), for detector functions such as absolute value, bounded saturating functions of \(\|B_j(h)x\|\), or any continuous even vector-valued function of the chosen finite-dimensional block and full transcript. In particular neither quadraticity nor scalar readout is necessary for the lower bound. No injectivity or regularity of the detector readout is assumed.

**Corollary 7 (uniform reconstruction error).** For every radius \(R>0\) and every protocol satisfying (3), the minimax worst-case projective Euclidean reconstruction error on \(\overline B(0,R)\) is at least \(R/2\), even with arbitrary nonlinear/discontinuous decoding. This is a **noiseless** lower bound forced by a pair of exactly identical transcripts; it is not an upper bound, and no statistical assumptions are needed.

### Two decisive negative controls

**Without evenness, the theorem is false.** At \(n\ge2\), take \(n\) fixed rank-one coordinate sensors \(B_jx=x_j\) with identity readouts \(\Phi_j(z)=z\). Their joint transcript is \(x\), giving exact reconstruction with \(n<2n-1\) continuous stages. The sign-evenness assumption cannot be removed.

**Without the two-bin rank condition, exact recovery can occur in one even stage.** Take \(d_1=n\), \(B_1=I_n\), and the continuous even detector \(\Phi_1(z)=zz^\top\in\mathrm{Sym}_n\mathbb R\simeq\mathbb R^{n(n+1)/2}\). The output is injective modulo \(\pm\): if \(xx^\top=yy^\top\), then \(x=0\) iff \(y=0\), and otherwise their rank-one ranges are equal and equality of squares forces \(y=\pm x\). Thus no unconditional theorem can declare all even adaptive measurements ineffective irrespective of sensor rank or detector output dimension.

**Model boundary:** A continuously chosen rank-one *projection* need not admit a continuous signed vector lift on a non-simply-connected attainable-history space. Such physical projective detectors are not necessarily of the global matrix form (1). The scope of the present theorem is **continuous real matrix blocks**, not arbitrary projective sensing bundles; a twisted-bundle generalization would require its own characteristic-class calculation.

## 6. Audit and reproducibility contract

**Proof dependency graph.**
- Continuous causal input → compact actual-history images → bounded componentwise Tietze → global even virtual policy.
- Two-bin sensor dimensions → independent antipodal characters of virtual block kernel maps → nonzero \(\alpha^r\beta^s\) → simultaneous stage-kernel zero.
- Stage-kernel zero → exact physical transcript equality for \(x_\pm=\tfrac R2(u\pm v)\) → \(d_\pm(x_+,x_-)=R\) → error \(\ge R/2\).
- Scalar intensity specialization + classical full-spark complement property → exact threshold \(2n-1\).

**Adversarial checks to prioritize.** Check Tietze's boundedness on the *compact* symmetric \(A_j\), not the unbounded \(H_{j-1}^K\times\mathbb R^{d_j}\); check the parity of the *virtual history* rather than only of the target detector; check exact alignment of virtual and actual histories only at the joint zero; test zero-size blocks and readouts; check \(n=1\), \(m=0\), \(R>0\), and nonzero \(x_\pm\) not required; check that the two-bin threshold (13) is sufficient and not asserted necessary; check the quotient metric triangle inequality; test a projective detector without lift as out of scope.

**Prior art and credit.** The topological proof is a standard Stiefel–Whitney/Fadell–Husseini equivariant-index computation, related to the product-sphere Borsuk–Ulam theorems of Chan–Chen–Frick–Hull (*Borsuk–Ulam theorems for products of spheres and Stiefel manifolds revisited*, arXiv:1902.00935). The continuous-history causal two-character recursion and real phase-retrieval threshold originate in NIGHTFALL PR #995 and its non-author PR #1000 audit; PR #1000 already stated the even-block extension called Theorem B. The compact-domain bounded-Tietze repair and exact two-bin proof are in NIGHTFALL's \`PR1000_TOPOLOGY_RECONCILIATION_AND_BLOCK_REPAIR.md\`. Ullrich's *A Borsuk–Ulam theorem for adaptive continuous measurements* (arXiv:2610.33781, October 2026) has a different general adaptive-functional model and an exponential-dimensional antipodal bound, so its existence does not establish the specific real even-block statement above. These distinctions require a dated specialist literature review before any novelty or record claim.

**Independent certification:** None performed on this manuscript as of this commit. The classical Lemma 2 has an author-side unconditional paper proof via augmented Sard and smooth zero-fiber cobordism in NIGHTFALL PR #1147; an end-to-end Lean terminal for \`ProductSphereZero\` remains separate. The theorem statements here are complete **paper results**, not source-exact Lean declarations or research priority certificates.
