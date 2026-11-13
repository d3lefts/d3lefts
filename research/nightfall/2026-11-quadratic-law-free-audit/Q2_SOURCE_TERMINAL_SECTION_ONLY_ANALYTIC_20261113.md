# Q2 — actual-source terminal proof via one section budget

**Status:** author-side analytic proof, finite independent product spaces, 13 November 2026. Not a strict terminal Lean certificate, external review, or originality claim. See PR #424 for exact declaration-level machine status.

## Formal target

Let (\iota) be a finite nonempty coordinate set, (\alpha) a finite nonempty alphabet, and (p_i\colon\alpha\to[0,1]) normalized arbitrary coordinate laws (zero masses allowed). Let (X\sim\bigotimes_{i\in\iota}p_i). Assume a **real** source function (f\colon\alpha^\iota\to\mathbb R) satisfies (|f(x)|\le B) at every source input and has genuine Efron–Stein/Hoeffding degree at most two. Define

\[
V=\operatorname{Var}(f(X)),\qquad
I_i(f)=\mathbb E[\operatorname{Var}(f(X)\mid X_{-i})],\qquad
M=\max_i I_i(f).
\]

Here (I_i) is exactly the repository's `pinfl p f i`, i.e. half the mean square independent resampling difference. Then

\[
\boxed{V\le16(1+\sqrt3)B\sqrt M},
\qquad
\boxed{V^2\le256(1+\sqrt3)^2 B^2 M}.
\]

**Advantage:** The dimension-free exponent-two result uses only the independently established sharp *section* budget, rather than an additional additive-projection estimate. The stronger V7 and V8 constants require separately audited additives.

## Exact source objects — no supplied energies

Canonical genuine Hoeffding components are (h_i=\operatorname{esComp}(p,\{i\},f)) and (h_{ij}=\operatorname{esComp}(p,\{i,j\},f)). They are pointwise functions of their true source coordinates and centered in every coordinate in their support. Set (A_i=\|h_i\|_{L^2(p_i)}) and (E_{ij}=\mathbb E[h_{ij}(X_i,X_j)^2]). Source orthogonality gives the exact identities

\[
V=\sum_i A_i^2+\sum_{i<j}E_{ij},
\qquad
I_i=A_i^2+\sum_{j\ne i}E_{ij}.
\tag{1}
\]

These are equations derived from original source product expectations. In Lean, the load-bearing candidates are `ActualESOrthogonalEnergy`, `ActualESInfluenceIdentity`, and `ActualESPairEnergyFubini`, each subject to strict compilation.

## Greedy ownership is a disjoint partition

Index every unordered pair by the **actual two-element subset** `Edge ι := {S : Finset ι // S.card = 2}`. The source's canonical kernel has full-alphabet amplitude (w_{ij}=\max_{a,b}|h_{ij}(a,b)|). The actual-source parity matching argument establishes (sum_{e\in F} w_e\le4B) for every matching (F). The weighted greedy cover produces nonnegative (c_i) with

\[
\sum_i c_i\le8B,\qquad w_{ij}\le\max(c_i,c_j).
\tag{2}
\]

Give each edge to the endpoint with larger (c), breaking ties deterministically. Every original edge belongs to exactly one `ownedEdges i`; all neighbors at any owner (i) are distinct original coordinate sites, since the canonical graph has no duplicate unordered edges. The proof of this ownership and the general source (4B/8B) bounds already has earlier strict receipts in PR #424.

Define the genuine owner section (a vector indexed by a source symbol (a)):

\[
H_i(X_{-i})(a):=\sum_{j:\,\{i,j\}\text{ owned by }i}h_{ij}(a,X_j).
\]

Let

\[
s_i:=\mathbb E_{X_{-i}}\sum_a p_i(a)H_i(X_{-i})(a)^2,
\quad z_i:=\mathbb E_{X_{-i}}\sqrt{\sum_a p_i(a)H_i(X_{-i})(a)^2}.
\tag{3}
\]

Pairwise centered independence of distinct original neighbors eliminates every cross term. Thus

\[
s_i=\sum_{j:\,\{i,j\}\text{ owned by }i}E_{ij},\quad
\sum_i s_i=\sum_{i<j}E_{ij},\quad
0\le s_i\le I_i\le M.
\tag{4}
\]

**All of (4) is derived** from source pair components, true source product weights, exact ownership, and (1). The written Lean candidates `ActualESOwnedSectionEnergy`, `ActualESOwnedInfluenceBound`, and `ActualESOwnedSectionCap` isolate exactly these equalities and inequalities; no independent (s_i\le I_i) premise is admitted in their theorem types.

## True conditional sections and Jensen — the key representation bridge

Set

\[
U_i(X_{-i})(a)
=f(X_{-i},a)-\sum_b p_i(b)f(X_{-i},b).
\]

Let (N_i) be the actual owned-neighbor coordinate set. Since the canonical quadratic source has no higher-order terms, and each interaction is centered in its other variable, the exact original-product conditional-expectation identity is

\[
\mathbb E[U_i(X_{-i})\mid X_{N_i}]
=h_i+H_i.
\tag{5}
\]

The conditioning in (5) is over the **real** product of the original coordinate laws; it does not independently resample repeated indices. The graph's injectivity makes (N_i) a genuine set of distinct source sites.

Define (u_i=\mathbb E\|U_i\|_{L^2(p_i)}). Conditional Jensen and the Hilbert triangle inequality yield, from (5),

\[
z_i\le u_i+A_i.
\tag{6}
\]

Likewise (h_i=\mathbb E[U_i]), so Jensen gives (A_i\le u_i).

The previously compiled sharp finite arbitrary-law source-section theorem (ported unchanged from PR #422) gives, for pointwise (|f|\le B),

\[
\sum_i u_i\le8B.
\tag{7}
\]

For (B>0) apply the theorem to (f/B); for (B=0) the result is trivial. Summing (6) and (A_i\le u_i) gives

\[
\sum_i A_i\le8B,\qquad \sum_i z_i\le16B.
\tag{8}
\]

This avoids importing the separate V7/V8 additive-projection budget. The pointwise sharp section lemma is in `Q2AllDimensions`; the true conditional-projection and Hilbert-Jensen identification are staged in `ActualESConditionalSection`, `ActualESConditionalProjection`, `ActualESOwnedConditional` and `ActualESConditionalJensen`.

## Derived fourth moment on genuine finite neighbors

Enumerate each finite (N_i) injectively as `Fin n -> ι` and zero-pad the unused natural-number increment table. For every genuine neighbor (j), let

\[
Y_{ij}(X_j)(a)=\sqrt{p_i(a)}\,h_{ij}(a,X_j).
\]

The source centering gives (\mathbb EY_{ij}=0), while the actual owner amplitude cover gives (\|Y_{ij}\|_2\le c_i). The genuinely independent original neighbor coordinates make (\sum_j Y_{ij}) the weighted section (H_i). Consequently the already compiled fourth-moment endpoint applies with (s_i\le M) **derived from (4)**:

\[
\mathbb E\|H_i\|_2^4\le c_i^2s_i+3s_i^2.
\]

Interpolating (L^1,L^2,L^4) gives

\[
s_i^3\le z_i^2(c_i^2s_i+3s_i^2)
\quad\Longrightarrow\quad
s_i\le z_i(c_i+\sqrt{3M})
\tag{9}
\]

(including (s_i=0)). The exact normalizations and zero-atom cases are handled in the existing independent-increment Lean endpoint. The bridging candidates are `ActualESOwnedNeighborEnumeration`, `ActualESOwnedMomentEnergy`, and `ActualESSourceHilbertEndpoint`. Their strict compile gate must still be checked.

Normalized product Cauchy–Schwarz and (4) also derive, not assume,

\[
z_i\le\sqrt{s_i}\le\sqrt M.
\tag{10}
\]

## Final scalar composition

By (1), (4), (8), (9), (10), and the source-generated cost budget (2),

\[
\begin{aligned}
V
 &=\sum_i A_i^2+\sum_i s_i\\
 &\le\sqrt M\sum_i A_i
 +\sum_i c_iz_i+\sqrt{3M}\sum_i z_i\\
 &\le8B\sqrt M+8B\sqrt M+16\sqrt3 B\sqrt M\\
 &=16(1+\sqrt3)B\sqrt M.
\end{aligned}
\]

Squaring proves the advertised exponent-two inequality. The pure scalar closure is `QuadraticSectionOnlyClosure.lean`; it explicitly labels its input inequalities and must NOT be represented as a source-level kernel certificate until equations (1),(5),(7),(9),(10) are all connected at the same source theorem type.

## Proof/certification status and reproducibility

- Source graph, amplitude/parity matching, greedy owner, original pair energy partition: strict historical Lean receipts on PR #424.
- Original sharp 8B source sections: scoped strict Lean receipt from PR #422, now source-identically copied into PR #424; still requires one-pin recompile.
- Source ANOVA/influence/Fubini, owned section identity, source conditional expectation and source Hilbert moment instantiation: newly authored candidate files, not represented as passing without a strict successful run.
- Pure scalar coefficient is an exact algebraic consequence, not a substitute for the above mathematical source interfaces.
- No `sorry`, unrestricted custom axiom, assumed (s_i\le I_i), assumed matching budget, assumed fourth moment, or external source-conditioned energy oracle is permitted in the final declaration.
- The desired final certificate must explicitly print the theorem type, axiom dependencies, compiler version/commit, all imported file hashes, CI receipt and independent replay. The previous historical 4.33.0 source pin and the repository-wide 4.35.0 migration must be reconciled rather than conflated.
- Infinite measurable-product extension and historical novelty are **outside the finite theorem** and need separate audit.

**Conclusion:** this closes the finite product theorem at the *analytic* level with a simpler set of source inputs. It is not a claim that Lean has already compiled the complete source-level Q2 declaration.
