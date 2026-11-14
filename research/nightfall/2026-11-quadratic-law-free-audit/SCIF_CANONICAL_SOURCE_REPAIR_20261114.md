# SCIF v1.1: canonical source-change repair and influence ledger

**November 14, 2026 · NIGHTFALL · Research directed by Devin J. Wright; AI-assisted proof development.**

## Claim, assumptions, scope

Finite independent product source (p=\bigotimes_{i\in I}p_i) with arbitrary finite common alphabet, zero-probability atoms allowed. A fixed *pointwise* function (f:\prod_i A_i\to\mathbb R) has Efron–Stein degree at most two under the original law. Change exactly one coordinate law (p_k\mapsto q_k) while leaving (f), all other marginals, and the symbol representations unchanged. The edit is assumed complete and authenticated. No assertion about physical validity or arbitrary untrusted observational interfaces is made.

The source-normalized canonical decomposition is
[
 f=m+\sum_i h_i+\sum_{\{i,j\}}h_{ij},\quad
 E_{p_i}h_i=0,\quad E_{p_i}h_{ij}=E_{p_j}h_{ij}=0.
]
Every identity below is a **pointwise finite sum identity**, including on zero-mass symbols.

## The canonical recentering theorem

Define
[
 \beta=E_{q_k}h_k,\qquad b_j(x_j)=E_{q_k}h_{kj}(X_k,x_j).
]
Then exactly the new source canonical ANOVA representation is
[
m'=m+\beta,\quad
h'_k=h_k-\beta,\quad
h'_j=h_j+b_j\ (j\ne k),\quad
h'_{kj}=h_{kj}-b_j,
]
with all other pair kernels unchanged.

**Proof, not an assumed projector transport.** The formula reconstructs (f) pointwise because the (\beta) and each (b_j) cancel. The old (p_j)-centering of (h_{kj}) gives (E_{p_j}b_j=0). Centering (h_k-\beta) under (q_k) and (h_{kj}-b_j) under both (q_k,p_j) is immediate. Every unaffected pair/singleton remains centered. The finite normalized product Hoeffding/ANOVA decomposition is unique by its coordinate-centering and support conditions. Hence these are exactly its new canonical components, including cases of source atoms with probability zero. The independently Lean-certified theorem in draft PR #515 additionally proves that arbitrary finite Efron–Stein degree is invariant under normalized product-law replacement directly through the repository's `esComp` and `ESDegreeLE` definitions.

**Graph caveat:** Four-corner mixed differences of each affected pair table are invariant. This preserves the *pointwise algebraic interaction graph* under the same f. A graph defined only by positive-mass support may change as zero masses enter or leave; do not conflate the two.

## Exact actual sourceInfluence updates

For the repository's genuine conditional-variance convention,
[
 I_i(p,f)=E_p\left[f(X)-E_{p_i}\left(f(X)\mid X_{-i}\right)\right]^2,
]
orthogonality gives (I_i=\|h_i\|_{p_i}^2+\sum_{j\ne i}\|h_{ij}\|_{p_ip_j}^2).

For the edited coordinate (k),
[
\boxed{
I'_k-I_k=
E_{q_k-p_k}h_k^2-\beta^2+
\sum_{j\ne k}\left(
  E_{(q_k-p_k)p_j}h_{kj}^2-E_{p_j}b_j^2
\right).
}
]
For each untouched neighbor (j\ne k),
[
\boxed{
I'_j-I_j=
2E_{p_j}[h_j b_j]+E_{(q_k-p_k)p_j}h_{kj}^2.
}
]
If (h_{kj}=0) pointwise then (b_j=0), so (I'_j=I_j). All coordinates outside the intrinsic pair neighborhood of (k) have exactly unchanged influence. This is stronger than only claiming that the dependency graph is unchanged. The update is a direct expansion of new canonical energies; no resampling oracle or approximation is introduced.

## Cost and fixed-owner repair

Given the cached source canonical (h_k,h_j,h_{kj}) tables and the old influence scores, the (b_j), changed edge squares, and singleton cross terms take (O((\deg(k)+1)a^2)) arithmetic for a common alphabet of size (a). The cost excludes verifying the edit manifest, obtaining / authenticating changed marginals, deriving the task's canonical decomposition from scratch, and effect-time authorization.

Let (D=\sum_{a\in A_k}|q_k(a)-p_k(a)|). If an old source pair kernel obeys \(|h_{kj}|\le c_{o(k,j)}\) for an assignment of edges to unchanged owners and old (p_k)-centering, then
[
\left|h'_{kj}\right|\le (1+\min\{D,1\})c_{o(k,j)}.
]
Thus same owners work with a multiplicative cost scaling of at most (1+\min(D,1)\), with no mass-floor assumption, within this pair-amplitude certificate interface. The main-source bridge to a whole operational authority proof (including all alternative verification paths) remains open.

## Independent exact falsification

A separately written checker `check_scif_full_source_exact.py` recomputes **both** old and new actual canonical `esComp` via full original-product expectations and all Möbius sums for 40 random 3-coordinate, 3-symbol additive-plus-pair task instances, including zero-mass marginals. It independently computes true conditional-source influences from the original (f), compares each new canonical component with the recentering construction, and verifies both influence-update formulas using exact `fractions.Fraction`. GitHub CI `nightfall-scif-full-source-exact.yml` passed; this tests finite cases, it does not prove a universal theorem.

## Strict Lean certificate registry

- Draft PR #496: finite weighted-table recentering, four-corner graph invariance, exact pair-energy formula, fixed-owner clipped-L1 bound; staged pinned Lean receipts.
- Draft PR #515: actual source `ESDegreeLE` invariance for every finite degree and normalized product laws; successful strict Lean 4.36.0-rc2 workflow.
- Draft PR #513: genuine original-law `esComp` pair bridge, and exact actual `sourceInfluence` update for two-coordinate observables, plus a conditional table-transport statement. Do **not** call any stages kernel-certified until their current-head strict receipts succeed.
- Still **not kernel-certified:** the complete unrestricted multi-pair canonical source update and its total influence formula in one Lean declaration derived directly from arbitrary original `f` and `ESDegreeLE p f 2` without supplied pair tables.

## Prior art / originality boundary

Hoeffding and Efron–Stein projections and their uniqueness, Möbius inversion, change-of-measure recentering, and sparse local update mechanisms are well-established individually. Neither an exact finite check nor a Lean proof establishes historical novelty. A true distinct contribution would establish a quantitative source-owned recertification complexity separation with best competing oracles, authenticated evidence, and protected commits; compare incremental assurance case frameworks and FASE 2026 analysis slicing directly.
