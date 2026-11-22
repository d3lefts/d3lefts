# Continuous causal real phase retrieval: product-sphere obstruction

**NIGHTFALL checkpoint v0.2 — 2026-11-22.**
**Status: PROVISIONAL ALL-POLICY PROOF.** Not Lean-certified; not independently
reviewed; novelty not established. Keep separate from merged certificates
[#695](https://github.com/d3lefts/d3lefts/pull/695) and
[#699](https://github.com/d3lefts/d3lefts/pull/699).

## 1. Claim and assumptions

For \(n\ge 2\), a length-\(m\) continuous causal real intensity protocol
has rows \(a_j:H_{j-1}\to \mathbb R^n\), continuous in the **subspace
topology on the attainable previous-transcript set**
\(H_{j-1}=\{T_{j-1}(x):x\in\mathbb R^n\}\), and
\(\|a_j(h)\|_2\le1\). A first-stage row is constant. Define

\[
T_0(x)=(),\qquad
T_j(x)=\left(T_{j-1}(x),
  \big(a_j(T_{j-1}(x))\cdot x\big)^2\right).
\]

**Provisional theorem.** If \(1\le m\le2n-2\), then there exist
\(u,v\in S^{n-1}\) for which
\[
T_m(u+v)=T_m(u-v),\qquad
u+v\ne u-v,\quad u+v\ne -(u-v).
\]
Consequently the optimal number, assuming the proof passes review, is
\[
\boxed{m_{\mathrm{cont}}(n)=2n-1,\quad n\ge2.}
\]
The \(2n-1\) upper bound is attained by an ordinary fixed full-spark
frame, formally proved in the scope of PR #695.

**In particular** the six-reading question in \(\mathbb R^4\)
would be answered negatively: \(m_{\mathrm{cont}}(4)=7\).
This is an actual *all-causal-prefix* claim, not the prior
coordinate-first obstruction, and requires its own review.

## 2. Mechanism: the two-colour virtual history

Colour each stage either U or V. Choose numbers \(r\) of U-stages and
\(s\) of V-stages with \(r+s=m\) and \(r,s\le n-1\), possible because
\(m\le2n-2\). For the moment take each policy row to be globally
continuous on all nonnegative history vectors. This stronger temporary
assumption is removed in Section 4.

For \((u,v)\in S^{n-1}\times S^{n-1}\), inductively construct a
**virtual common history** \(h_j(u,v)\) and obstruction scalar \(g_j\).
Start \(h_0=()\), put \(b_j=a_j(h_{j-1})\), and use

\[
\begin{array}{c|c|c}
\text{colour }j & g_j(u,v) & h_j(u,v)\\ \hline
\mathrm{U} & b_j\cdot u &
  (h_{j-1},(b_j\cdot v)^2)\\
\mathrm{V} & b_j\cdot v &
  (h_{j-1},(b_j\cdot u)^2)
\end{array}
\]

The \(h_j\) are *not claimed reachable* for arbitrary \((u,v)\).
Their purpose is to create an equivariant map.

**Parity induction:** \(h_0\) is invariant under either independent sign
flip. If \(h_{j-1}\) is invariant, then so is \(b_j\), and the squared
value used in the next virtual observation is invariant. Thus
\(h_j(-u,v)=h_j(u,-v)=h_j(u,v)\). At a U-stage,
\(g_j(-u,v)=-g_j(u,v)\) and \(g_j(u,-v)=g_j(u,v)\).
At a V-stage the signs are reversed. Therefore

\[
g=(g_1,\dots,g_m):
S^{n-1}\times S^{n-1}\longrightarrow
\mathbb R^r_{\mathrm{sign}\ U}\oplus
\mathbb R^s_{\mathrm{sign}\ V}
\]

is continuous and equivariant for **separate** antipodal actions
of \(G=(\mathbb Z/2)^2\).

## 3. Topological zero certificate (audit dependency)

Consider \(B=\mathbb RP^{n-1}\times\mathbb RP^{n-1}\).
The equivariant map \(g\) defines a section of

\[
E=L_U^{\oplus r}\oplus L_V^{\oplus s}\longrightarrow B
\]

where \(L_U,L_V\) are pullbacks of tautological real line bundles.
With mod-two degree-one generators \(\alpha,\beta\),

\[
H^*(B;\mathbb F_2)=
  \mathbb F_2[\alpha,\beta]/(\alpha^n,\beta^n).
\]

The top Stiefel–Whitney class is

\[
w_m(E)=w_1(L_U)^r w_1(L_V)^s
      =\alpha^r\beta^s\ne0
\]
because \(r,s\le n-1\). A nowhere-zero section of a real rank-\(m\)
vector bundle has vanishing top Stiefel–Whitney class. Hence the
section must vanish: there are unit \(u,v\) for which **every**
\(g_j(u,v)=0\).

This uses a classical standard zero theorem for product spheres;
the topological dependency is **not yet independently audited for
the precise representation**. See the separate-symmetry literature
(Chan–Chen–Frick–Hull, 2019,
https://arxiv.org/abs/1902.00935).

## 4. Reachable-only histories: compact extension bridge

**Critical gap avoided:** It is invalid to evaluate a policy defined
only on reachable histories at an arbitrary virtual \(h_j\).

Let \(K=\{x\in\mathbb R^n:\|x\|_2\le2\}\). For each \(j\), the original
\(T_j\) is continuous by causal composition; therefore
\(H_j^K=T_j(K)\) is compact (hence closed) in Euclidean transcript space.
The restriction of the next row to \(H_j^K\) is a bounded continuous
vector-valued function. Extend its coordinate functions from this
closed set to all of \(\mathbb R^j\) by Tietze's theorem.
Optionally project the resulting vector continuously onto the unit
ball, which preserves the original values because they already have
norm at most one. This supplies globally continuous rows
\(\widetilde a_j\).

By causal induction, the globally extended protocol agrees with the
original for **every** \(x\in K\). Importantly, this step does not assume
that the full unbounded reachable-history image is closed.

Perform Sections 2–3 using \(\widetilde a_j\). The resulting pair
\(x_+=u+v\), \(x_-=u-v\) lies in \(K\), as \(\|u\|=\|v\|=1\).
It remains to check the virtual history is the true common history
**at the simultaneous zero**, not everywhere.

## 5. Collision induction at the topological zero

At \(g(u,v)=0\), define \(x_\pm=u\pm v\).
At stage \(j=1\), previous histories coincide with \(h_0=()\).
Inductively assume both previous true transcripts equal \(h_{j-1}\);
then both use the same row \(b_j\).

If colour U, \(b_j\cdot u=g_j=0\), and both
\((b_j\cdot x_+)^2\) and \((b_j\cdot x_-)^2\) equal
\((b_j\cdot v)^2\). If colour V, \(b_j\cdot v=0\), and both
true readings equal \((b_j\cdot u)^2\). Both agree with the virtual
\(j\)-th observation. Inducting yields

\[
\widetilde T_m(x_+)=\widetilde T_m(x_-)=h_m.
\]

The same equality holds for the original protocol because both
signals belong to \(K\). Since
\(x_+-x_-=2v\ne0\) and \(x_++x_-=2u\ne0\),
they are not related by global sign. This proves the conditional-on-
Section-3 lower-bound argument.

## 6. Source, independent audit, and status gates

**Source foundations.** [PR #695](https://github.com/d3lefts/d3lefts/pull/695)
is the pinned Lean certificate for the unrestricted adaptive
\(n+1\) and fixed \(2n-1\) counts. [PR #699](https://github.com/d3lefts/d3lefts/pull/699)
is the pinned Lean coordinate-first obstruction. Neither certifies
the present universal result.

**Independent checks this session.**
- Exact-rational parity replay: 120 cases, \(n=2,\ldots,6\), passed.
  See verify_parity_exact.py. This checks the algebraic induction,
  not topology or existence.
- A genuinely history-dependent six-reading \(\mathbb R^4\) policy was
  stress-tested with a seeded SciPy root solve; the direct transcript
  difference was approximately \(1.53\cdot10^{-16}\). See
  phase_collision_probe.py. This is numerical evidence only.
- Current literature scan recovered the classical fixed complement
  property, product-sphere Borsuk–Ulam methods, and
  [Ullrich's 2026 adaptive continuous-measurement Borsuk–Ulam paper](https://arxiv.org/abs/2610.33781).
  These must be read at source level for scope and priority before any
  original-contribution claim.

**Separate adversarial reviews required.**
1. **Topology:** independently reproduce/refute the nonzero
   Stiefel–Whitney class calculation and representation-bundle link.
2. **Causal model:** check the virtual-history inductive equations,
   each parity claim, the compact reachable-set extension, and every
   zero-support/antipodal edge case. Seek an explicit counterexample.
3. **Numerical:** replay both scripts on a pinned environment and
   cross-check actual, not just virtual, observations. Numeric tests
   cannot prove the all-policy claim.
4. **Prior art:** compare at the exact model level (continuous
   **row choice**, not merely continuous measurement maps) and
   establish priority only with dated sources.
5. **Lean:** formalize product equivariant zero + extension bridge,
   then the transcript collision and fixed upper, and check axioms.

**Certification ladder:** plausible paper argument -> independent
mathematical audit -> kernel certificate -> prior-art novelty decision.
Current status is **provisional paper argument only**. No external
submission, merge to main, or publication is authorized by this file.

## 7. Mechanism transfer, separately provisional

The same lower-bound argument appears to hold for **any continuous even
scalar response** \(y_j=\varphi_j(a_j(h)\cdot x)\):
use virtual \(h_j=\varphi_j(b_j\cdot v)\) or
\(\varphi_j(b_j\cdot u)\); evenness gives both parities.
This does NOT establish a \(2n-1\) matching upper bound for arbitrary
even \(\varphi_j\). Test this generalization only after the primary
claim is independently sound.
