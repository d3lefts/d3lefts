# Product Borsuk–Ulam obstruction for continuous causal phaseless sensing
Version: v0.1 | 2026-11-22 | **PROVISIONAL MATHEMATICAL PROOF — independent audit and Lean pending**

## Precisely scoped claim

For integer (n\ge2), let a length-(m) causal intensity protocol consist of row maps
[
a_j:H_{j-1}\longrightarrow\mathbb R^n,\quad
H_{j-1}=\{T_{j-1}(x):x\in\mathbb R^n\},
]
where (a_j) is **continuous in the subspace topology on reachable histories**,
(a_1) is constant, and (\|a_j(h)\|_2\le1). Set (T_0(x)=()) and
[
T_j(x)=\big(T_{j-1}(x),[a_j(T_{j-1}(x))\cdot x]^2\big).
]

**Proposed theorem (unreviewed):** If (m\le 2n-2), there exist
(x_+,x_-\in\mathbb R^n), with (x_+\ne x_-) and (x_+\ne -x_-),
such that (T_m(x_+)=T_m(x_-)). In fact a collision occurs with
(x_+=u+v, x_-=u-v) for **unit** (u,v\in S^{n-1}).

Together with the classical fixed full-spark (2n-1) upper construction
(already Lean-certificated in [#695](https://github.com/d3lefts/d3lefts/pull/695)),
this **would prove** (m_{\mathrm{cont}}(n)=2n-1) for all (n\ge2),
including the flagship (m_{\mathrm{cont}}(4)=7).
This conclusion has NOT been independently reviewed or Lean checked.
Do not describe it as a certified breakthrough or novel theorem.

## Mechanism: a two-colour artificial common transcript

Choose a colour (\chi(j)\in\{U,V\}) for each reading so that
(r=\#\chi^{-1}(U)\le n-1, s=\#\chi^{-1}(V)\le n-1).
Such a colouring exists whenever (m\le 2n-2).
Temporarily suppose all (a_j) are defined continuously on all
nonnegative histories (the reachable-only issue is discharged below).

For (u,v\in S^{n-1}), recursively define the artificial common history
(h_0(u,v)=()), the row (b_j=a_j(h_{j-1})), and:
[
\begin{array}{c|c|c}
\chi(j)&g_j(u,v)&h_j(u,v)\\ \hline
U&b_j\cdot u&(h_{j-1},(b_j\cdot v)^2)\\
V&b_j\cdot v&(h_{j-1},(b_j\cdot u)^2).
\end{array}
]

**Key induction:** Every (h_j(u,v)) is continuous and invariant under
either sign flip (u\mapsto-u) or (v\mapsto-v).
Consequently the (U)-coloured coordinates (g_j) are odd in (u)
and even in (v); the (V)-coloured coordinates are even in (u)
and odd in (v). The map
[
g:S^{n-1}\times S^{n-1}\to\mathbb R^r\oplus\mathbb R^s
]
is (G=(\mathbb Z/2)^2)-equivariant for separate antipodal actions on
the two spheres and the corresponding sign representations in the codomain.

### Topological zero certificate (standard, requires independent source review)

Let (B=\mathbb RP^{n-1}\times\mathbb RP^{n-1}),
with tautological real line bundles (L_U,L_V). Equivariance makes
(g) a continuous section of (E=L_U^{\oplus r}\oplus L_V^{\oplus s}).
Write (\alpha,\beta\in H^1(B;\mathbb F_2)) for their first
Stiefel–Whitney classes. By the Whitney product formula,
[
w_m(E)=\alpha^r\beta^s\ne0\quad\text{in}\quad
H^*(B;\mathbb F_2)=
\mathbb F_2[\alpha,\beta]/(\alpha^n,\beta^n).
]
The indicated nonzero top Stiefel–Whitney class prohibits a nowhere-vanishing
section of rank-(m) bundle (E). Therefore (g(u,v)=0) for some unit
(u,v). This uses **separate** \((\mathbb Z/2)^2\) sign symmetries, not
a diagonal-only Borsuk–Ulam argument.

### Collision induction

At such a zero, let (x_+=u+v, x_-=u-v).
Induct on (j). Suppose their true previous transcripts both equal
(h_{j-1}). Their (j)-th row is then (b_j).
If colour (U), (b_j\cdot u=g_j=0), so both outcomes equal
((b_j\cdot v)^2=h_j[j]). If colour (V), (b_j\cdot v=0), so both
outcomes equal ((b_j\cdot u)^2=h_j[j]).
Thus (T_m(x_+)=T_m(x_-)=h_m).
Because both (u,v) have norm one, equality (x_+=x_-) would imply
(v=0), and (x_+=-x_-) would imply (u=0); both are impossible.
Also \(\|x_\pm\|\le2\).

## Reachable-history continuity: compact restriction and extension

**This is essential, not optional.** Artificial (h_j(u,v)) need not
be attainable histories away from the zero set. It would be invalid to
evaluate an (a_j) defined only on reachable histories there.

Take the original protocol restricted to the compact input ball
(K=\{x:\|x\|\le2\}).
Every (T_j\vert_K) is continuous by induction, so the reachable
prefix image (H_j^K=T_j(K)) is compact and closed in Euclidean space.
The restriction (a_{j+1}\vert_{H_j^K}) is continuous and bounded.
Coordinatewise Tietze extension, followed if desired by projection
onto the closed unit ball, gives a continuous global row map
\(\widetilde a_{j+1}:\mathbb R^{j}\to\mathbb R^n\)
agreeing with the original row on (H_j^K). For (j=0), use
the same fixed row. By induction, the extended protocol agrees with
the original on **every input in (K)**. Apply the artificial-history
construction to the extended protocol. Its two colliding inputs lie in
(K), so the same collision holds for the original protocol.

**Audit dependency:** independently verify compactness, subspace
continuity, exact extension agreement, and that artificial histories
are evaluated only against the extended maps.

## Why existing PRs do not already certify this

- [#695](https://github.com/d3lefts/d3lefts/pull/695) proves sharp
  **unrestricted** causal (n+1) and **fixed** (2n-1) counts.
- [#699](https://github.com/d3lefts/d3lefts/pull/699) proves an
  obstruction for (n) coordinate-square prefix readings and one
  continuous final row. Its proof does not use the universal two-colour
  equivariant-history reduction.
- The claimed new step here is an **all-policy** continuity lower
  bound, independent of any fixed prefix. Full-cone topology alone
  does not provide the six-reading obstruction in dimension four.

## Independent auditing and novelty gates

1. **Topology B:** independently prove/refute that every separately
   equivariant map
   (S^{n-1}\times S^{n-1}\to\mathbb R^r_{\mathrm{sgn}U}
   \oplus\mathbb R^s_{\mathrm{sgn}V}) must vanish for
   (r,s\le n-1). Inspect the vector-bundle action and top
   Stiefel–Whitney class.
2. **Model B:** attack the reachable-only extension, continuity of
   (T_j), norm bounds, dependence on actual histories, and all
   antipodal/zero-support cases.
3. **Numerical B:** independently replay the exact rational parity
   checks and the deliberately adaptive (n=4,m=6) collision stress
   example. Neither numerical test proves the topology claim.
4. **Prior art B:** check classical complement property, equivariant
   product-sphere BU (Chan–Chen–Frick–Hull, 2019,
   https://arxiv.org/abs/1902.00935), and Ullrich's
   2026 adaptive BU paper (https://arxiv.org/abs/2610.33781).
   The latter is about general adaptive continuous measurements and
   is **not** itself a sourced priority determination for this theorem.
5. **Formal B:** write a Lean topology lemma for the product-space
   zero, then the pure causal recursion and the reachable-image
   extension bridge. Existing certificates do not establish this.
6. **Novelty:** do not claim independently new literature or external
   proof certification until specialist review.

### Reproduction and status

Local test commands, before branch upload:
`python verify_phase_parity_exact.py`
→ 120 exact rational sign-invariance tests, dimensions 2–6, pass;
`python phase_collision_probe.py`
→ seeded polynomial continuous adaptive (n=4,m=6) policy, numerical
colliding signals with max direct transcript discrepancy 1.53e-16.
These are ***illustrations/checks***, not a substitute for topology.

**Status:** mathematical proof candidate (not yet non-author-reviewed);
not Lean-certified; not independently established as novel;
no public publication/submission authorized.

## Potential transfer

The lower-bound mechanism uses only that each query is a continuous
causally chosen linear functional followed by an **even**
observation function. The same artificial-history proof appears to
extend to continuous even scalar responses
\(y_j=\varphi_j(a_j(h)\cdot x)\),
using (h_j=\varphi_j(b_j\cdot v)) or
(\varphi_j(b_j\cdot u)).
This transfer is separately provisional. It does not assert a matching
(2n-1) upper bound when the even response is non-injective.
