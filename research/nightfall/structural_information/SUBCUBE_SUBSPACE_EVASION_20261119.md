# Tensor-subcube row-set subspace evasiveness: a sharp theorem and an adaptive quotient certificate

## Certification update — November 20, 2026 (supersedes historical status below)

**S1 and S2: universal Lean kernel certificates; the optimal linear exponent is certified.** The all-depth tensor family `E 0=F₂`, `E (L+1)=E L × E L`, `R 0={1}`, `R (L+1)={ (r,0),(0,r),(r,r) : r∈R L }` is defined in `SubcubeAllLevels.lean`. The following named results are compiled at pinned Lean 4.36.0-rc2 / Mathlib `9d581dfff2e41de989072ea63abf3daf69311520` and independently replayed by `leanchecker` with **only standard axioms** (`propext`, `Classical.choice`, `Quot.sound`), without `sorry`, `admit`, or new axioms:

- **All-L S1:** `SubcubeSharpAllLevels.all_levels_sharp` proves `|R_L∩W| ≤ (finrank W)^α` for **every** `L` and **every** binary linear subspace `W≤E_L`, `α=log 3/log 2`. The certified analytic dependency `SubcubeSharpScalar.triple_alpha` proves the exact pairwise three-slice exponent inequality via convexity and `two_rpow_alpha`. [Merged PR #977](https://github.com/d3lefts/d3lefts/pull/977), merge `817863f54963d10c220f20eeaa517e69b411f63f`, [exact-head PASS run #44739986591](https://github.com/d3lefts/d3lefts/actions/runs/44739986591).
- **All-L S2:** `SubcubeSharpAllLevels.all_levels_affine_sharp` proves `|R_L∩(a+W)| ≤ (finrank W+1)^α` for every `L,a,W`, using `a+W⊆W+span(a)`. This is an affine **upper bound**, not a claim that the multiplicative constant is best possible. Same PR and CI.
- **Optimal exponent:** `SubcubeSharpness.rows_nonzero`, `all_levels_cardinality`, and `full_space_extremizer` certify `|R_L|=3^L` and `dim E_L=2^L` for **every** tensor depth, via exact injective disjointness of the three embeddings. Together with `2^α=3`, this supplies the matching equality extremizers `W=E_L`, so the exponent cannot be lowered. [Merged PR #978](https://github.com/d3lefts/d3lefts/pull/978), merge `b2d12927cf0a20f9e10d38bba1dc467308679139`, [exact-head PASS run #44741027976](https://github.com/d3lefts/d3lefts/actions/runs/44741027976).
- **Independent finite audit:** `SubcubeAllSpacesL3.source_rows_L3` identifies recursive tensor rows with the original explicit numeric-mask generator through `L=3`; `scripts/check_subcube_subspace_evasion.py` exhaustively enumerates every binary subspace through `L=3`. This is an **adversarial check**, not an axiom used by the all-L proofs. [Merged PR #968](https://github.com/d3lefts/d3lefts/pull/968), [PASS run #44714760380](https://github.com/d3lefts/d3lefts/actions/runs/44714760380).

**Provenance and remaining gaps.** The inductively defined `R_L` is the precise ternary tensor-product row family; a single all-L Lean equality to the separate **integer-bitmask** function `tensorMask L` is not yet certified (only `L≤3` is). **S3**, the sought polynomial bound on affine **secant** intersections `(R_L+R_L)∩(a+W)`, and the coherent `T≥2` quantum-to-classical simulation remain open. These results are **kernel-checked mathematical constructions**, not claims of a new journal-level theorem, independent human peer review, or cleared historical novelty. The manuscript proof and older status statements below are retained for provenance rather than silently rewritten.

---

> **Certified update (2026-11-20):** The previously paper-only universal intersection bound through L=3 is now kernel-checked in `SubcubeAllSpacesL3.lean` as `subcube_all_W_L3`, with `source_rows_L3` proving identification with the original tensor-mask rows. Pinned Lean 4.36.0-rc2/Mathlib `9d581dfff...`, independent `leanchecker` and the entire RREF exhaustive Python checker passed at [run 44714141980](https://github.com/d3lefts/d3lefts/actions/runs/44714141980), head `6d556cd5f27fba890b01793df719ac55565d16b7`. **Boundary:** all-L S1, affine S2, secant S3 and T≥2 simulation are not certified by this finite theorem. Historical status wording below reflects the original unreviewed paper checkpoint.

Date: 2026-11-19 ET. **Scope:** independent author-side exact theorem and finite exhaustive audit. This note addresses the *remaining* adaptive-quotient obstruction after Claude's one-query energy theorem; it is **not** a T>=2 simulation theorem, not a Lean certificate and not a novelty/peer-review certificate.

## Recovered baseline and objective

Source: Claude's structural-information-theory branch at its checked 2026-11-19 state, especially ONE_QUERY_ENERGY_20261119.md (a one-query non-frame simulation using pair multiplicity), SUBCUBE_FAMILY_20261119.md (frame obstruction and all linear-local representations), and INFLUENCE_ROUTE_20261119.md (row-norm potential and the open quotient-uniform influence gate). Independent related extension PR #961 already proves the coarse *general* bound mu(quotient)<=2^q mu(original), which is exponential in the conditioned rank q. We seek a structural constraint on quotient fibers that is polynomial in q and independent of the tensor level L. Our proof establishes this **for single row fibers**, not for pair-sum fibers.

Notation: let \(E_L=(\mathbb F_2^2)^{\otimes L}\) with \(\dim E_L=2^L\); let
\[
\mathcal R_L=\{u_1\otimes\cdots\otimes u_L:
u_i\in\{e_0,e_1,e_0+e_1\}\}.
\]
These are the \(3^L\) nonzero indicator vectors of all axis-aligned subcubes of \(\{0,1\}^L\). All tensors, vector spaces and dimensions below are over \(\mathbb F_2\). Write \(\alpha=\log_2 3\).

## Theorem S: sharp subspace-evasive tensor Segre bound

For **every** linear subspace \(W\le E_L\) of dimension \(q\), including arbitrary synthetic/non-coordinate W,
\[
\boxed{|\mathcal R_L\cap W|\le q^\alpha.}\tag{S1}
\]
The \(q=0\) case is interpreted as \(0^\alpha=0\). The exponent is **sharp**: for every \(0\le k\le L\), a \(q=2^k\)-dimensional tensor-factor subspace has **exactly** \(3^k=q^\alpha\) rows. No constants depend on L, and no small-doubling, random-row, quantum circuit or frame hypothesis is used.

**Proof.** At L=1 every nonzero vector of \(\mathbb F_2^2\) lies in \(\mathcal R_1\); a q-dimensional subspace contains \(2^q-1\in\{0,1,3\}\) rows for q=0,1,2, exactly bounded by \(q^\alpha\). For L>=2, fix \(E_L=E_{L-1}\oplus E_{L-1}\) by the first tensor factor. Define
\[
W_0=\{v:(v,0)\in W\},\quad W_1=\{v:(0,v)\in W\},\quad
W_*=\{v:(v,v)\in W\}.
\]
Let their dimensions be \(q_0,q_1,q_*\). The three lifted subspaces \((W_0,0),(0,W_1),(W_*,W_*)\) are subspaces of W with **pairwise trivial intersection**. Therefore
\[
q_i+q_j\le q\quad\text{for all pairs }i\ne j.
\tag{P}
\]
The 3^L tensor rows partition uniquely into \((r,0),(0,r),(r,r)\) with \(r\in\mathcal R_{L-1}\). Hence, by induction,
\[
|\mathcal R_L\cap W|=
|\mathcal R_{L-1}\cap W_0|+
|\mathcal R_{L-1}\cap W_1|+
|\mathcal R_{L-1}\cap W_*|
\le q_0^\alpha+q_1^\alpha+q_*^\alpha.
\]
It remains to show the elementary **three-subspace dimension inequality**: for nonnegative \(q_i\) with (P), \(\sum q_i^\alpha\le q^\alpha\). If q=0 it is immediate. Otherwise put \(x_i=q_i/q\). If \(\max x_i\le\tfrac12\), then
\(\sum x_i^\alpha\le(1/2)^{\alpha-1}\sum x_i
\le(1/2)^{\alpha-1}(3/2)=3/2^\alpha=1\),
where \(\sum x_i\le3/2\) is obtained by adding the three pair constraints. If \(\max x_i=t\ge1/2\), the other two are each <=1-t, so
\(\sum x_i^\alpha\le t^\alpha+2(1-t)^\alpha\).
The last function is convex on [1/2,1], and has value exactly 1 at BOTH endpoints, since \(2^\alpha=3\); therefore it never exceeds 1. This completes the induction. For sharpness take
\(W=(\mathbb F_2^2)^{\otimes k}\otimes\mathrm{span}(e_0)^{\otimes(L-k)}\);
this has dimension 2^k and its contained rank-one rows are exactly the 3^k tensors with each of the first k factors nonzero and the remaining factors e0. QED.

## Corollary S-A: affine and adaptive quotient fiber cardinality

For any affine q-dimensional coset \(a+W\subset E_L\),
\[
\boxed{|\mathcal R_L\cap(a+W)|\le(q+1)^\alpha.}\tag{S2}
\]
If \(a\in W\) the better bound q^\alpha applies; otherwise the coset lies inside the (q+1)-dimensional linear subspace \(\mathrm{span}(W,a)\), and Theorem S applies. This statement is independent of the position and geometry of W.

Let q observed parity queries span W; quotient the row vectors by W (i.e. identify row labels indistinguishable after conditioning on those queries). Every **single quotient row label** then has at most \((q+1)^\alpha\) original tensor rows mapping to it, and the zero label has at most \(q^\alpha\) original tensor rows. This remains valid for every adaptive transcript: conditional uniform secret cosets change known signs, not the geometric row-class fibers.

For q=O(poly(L)), the number of original row labels *within a given quotient class* is polynomial in L. This is an exact low-leakage/row-class noncollapse statement that cuts out one potential source of uncontrolled growth in adaptive one-query arguments.

**Critical limitation:** a bound on the size of EACH row class does NOT bound the number of **different class pairs** whose quotient sum is the same. Thus (S2) alone does not establish mu(quotient)=poly(q,L), a quotient-uniform influence inequality, or any T=2+ classical simulator. Pair-multiplicity is controlled by intersections of affine q-flats with the SECANT set \(\mathcal R_L+\mathcal R_L\), not just \(\mathcal R_L\). The next mathematical gate is precisely an affine low-rank/secant-evasiveness theorem:
\[
\text{bound }|(\mathcal R_L+\mathcal R_L)\cap(a+W)|\text{ by poly}(q,L),
\tag{OPEN}
\]
or find a counterexample that forces abandoning worst-case quotient multiplicity. The coarse bound 2^q mu_0 in PR #961 still applies in the absence of this new bound.

## Lemma S-C: exact reduction of adaptive pair multiplicity to secant intersections

Write \(A_L=\mathcal R_L\cup\{0\}\) and, for any finite set \(A\) in an \(\mathbb F_2\)-space, let \(\mu(A)\) be the maximum over nonzero \(\gamma\) of the number of **unordered** pairs of DISTINCT elements \(\{a,b\}\subseteq A\) with \(a+b=\gamma\). For a subspace W, let \(\pi:E_L\to E_L/W\) be the quotient map. Define
\[
E_2(W)=\max_{\gamma\notin W}
  |(A_L+A_L)\cap(\gamma+W)|,
\]
with maximum zero if the quotient is trivial. Then
\[
\boxed{\mu(\pi(A_L))\le \mu(A_L)\,E_2(W)
=(L+1)\,E_2(W)\quad(L\ge2).}\tag{S3}
\]

**Proof.** Fix any nonzero quotient sum \(\bar\gamma\). Choose one original representative \(a_c\in A_L\) for every distinct quotient row label \(c\in\pi(A_L)\). Each unordered quotient pair \(\{c,d\}\) with \(c+d=\bar\gamma\) determines a different unordered original representative pair \(\{a_c,a_d\}\), and its sum belongs to \((A_L+A_L)\cap\pi^{-1}(\bar\gamma)\), an affine W-coset not containing zero. Group the representative pairs by their *exact* original sum. At most \(\mu(A_L)\) pairs have any given nonzero exact sum, and there are at most \(E_2(W)\) possible sums in the coset. Maximize over \(\bar\gamma\). QED.

Since \(E_2(W)\le |W|=2^{\dim W}\), (S3) recovers the coarse general quotient bound already obtained in PR #961. **A uniform polynomial upper bound on \(E_2(W)\)** for this tensor family would replace that exponential factor by a polynomial, precisely the missing combinatorial ingredient for *transcript-relative one-query energy and influence*. It would **not** by itself resolve coherent \(T\ge2\) algorithms, whose distinct Fourier frequency sectors can be nonorthogonal (the exact T=2 counterexample in PR #962).

The one-query unordered multiplicity \(\mu(A_L)=L+1\) is Claude's established result (equivalently ordered \(2L+2\)), independently reproduced in PR #961; it is not derived anew here. Formula S3 uses its value but proves its own quotient-vs-secant reduction.

## Corollary S-B: independent proof of Claude's exact one-row subspace number

Claude's Proposition R states that the largest subspace \(V\subseteq\mathcal R_L\cup\{0\}\) has dimension exactly 2. Theorem S immediately recovers the nontrivial upper bound: for \(d=\dim V\),
\[
2^d-1=|\mathcal R_L\cap V|\le d^\alpha.
\]
For integers \(d\ge3\) this inequality is impossible: it fails directly at d=3,4, while for d>=5 use \(d^\alpha\le d^2\) and \(2^d-1>d^2\). A two-dimensional example is \(\{0,r_0,r_1,r_0+r_1\}\) where \(r_0,r_1\) are complementary half-subcubes and their sum is the parent. Hence \(N_1(R_L)=2\). This is a short independent route to an already established result, not a priority claim.

The same estimate controls query synthesis in a row span: any q independent observed parity queries can make at most \(q^\alpha\) original subcube query rows deterministically recoverable *without further queries* (precisely, rows lying in the known span W). This does not bound information gained about an arbitrary quantum observable.

## Exact independent finite audit and falsifier

A standalone Python stdlib integer-matrix enumerator \`scripts/check_subcube_subspace_evasion.py\` independently constructs every GF(2) row-reduced-echelon subspace of \(E_L\) for \(L\le3\), including **all 200,787 four-dimensional subspaces** at L=3. It checks every linear intersection against q^\alpha and **every affine fiber** against (q+1)^\alpha (by exact integer threshold comparison; the checker uses 3^k vs 2^k and a conservative integer-power bound to avoid tolerance). For L=3 the exact maximum intersections as q runs from 0 to 8 are
\[
(0,1,3,5,9,11,15,19,27).
\]
The exact extremizers q=1,2,4,8 attain q^\alpha=1,3,9,27. The separate quotient-pair test shows that nontrivial collisions **do increase under conditioning** (at L=3 the largest ordered pair multiplicity rises from 8 at q=0 to 20 for some q=2 subspace). This is a direct negative control against upgrading S2 into a uniform pair-collision theorem without another argument.

Finite checks independently audit proof inputs; they do not prove every L, which is supplied by the algebraic recursion above.

## Novelty, proof gates and transfer

This is an extremal fact about GF(2) rational points on a Segre tensor variety. Nearby established literature includes geometric Segre intersection theory and generalized Hamming weights of tensor/simplex codes; the exact inequality was **not identified** in the limited current web search, but that is not a priority clearance. Search anchors: https://doi.org/10.1016/j.disc.2007.07.037 and https://www.sciencedirect.com/science/article/abs/pii/S0012365X24003716 . No claim of an original genus, coding-theory bound, or accepted peer-reviewed proof.

For independent external review check: (i) pairwise-direct lifted subspaces, (ii) nonnegative triple inequality for alpha=log2(3), (iii) exact sharpness count, (iv) quotient representation after conditioning, (v) distinction between row classes and pair sums. Lean kernel certification and priority screening remain independent future gates.

**Discovery graph:** tensor rows → recursive three-slice representation → pairwise-transverse lifted subspaces → sharp \(q^\alpha\) intersection → affine quotient sparsity → open secant/weighted-coherence collision control → potential all-T transfer.

**Status:** author-side exact theorem with complete written proof, finite exhaustive replay, no human independent audit or Lean theorem. Does not settle all-T subcube query complexity.
