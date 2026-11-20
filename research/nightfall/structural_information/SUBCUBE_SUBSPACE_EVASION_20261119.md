# Tensor-subcube row-set subspace evasiveness: a sharp theorem and an adaptive quotient certificate

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
