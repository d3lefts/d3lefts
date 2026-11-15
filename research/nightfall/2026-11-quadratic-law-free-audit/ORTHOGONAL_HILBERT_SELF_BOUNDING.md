# NIGHTFALL: orthogonal-increment self-bounding norm theorem (2026-11-14)

**Status:** analytic proof, not yet Lean-certified or independently reviewed. This is a structured subclass result, **not** the unrestricted independent-Hilbert comparison. Research direction: Devin J. Wright; AI-assisted derivation and exposition.

## Theorem (nonnegative square-root sums)

Let (X_1,ldots,X_n) be independent random variables with (0\le X_i\le c^2) almost surely, (a\ge0), and (R=\sqrt{a+\sum_iX_i}). Then

[
\operatorname{Var}(R)\le c\,\mathbb ER,
\qquad
\mathbb ER^2\le(\mathbb ER)^2+c\mathbb ER.
]

No centering, symmetry, identical-distribution, or lower atom-mass assumption is required. The finite case includes degenerate laws.

**Proof.** Define (R_{-i}=\sqrt{a+\sum_{j\ne i}X_j}), measurable with respect to the other coordinates. For each outcome, (d_i=R-R_{-i}\ge0), (d_i\le\sqrt{X_i}\le c), and, when (R>0),

[
d_i=\frac{X_i}{R+R_{-i}}\le\frac{X_i}{R},
\qquad \sum_i d_i\le\frac{\sum_iX_i}{R}\le R.
]

If (R=0), all (d_i=0), so the last inequality remains valid. Efron--Stein tensorization for independent coordinates and the conditional-variance comparison with (R_{-i}) yield

[
\operatorname{Var}(R)
\le\sum_i\mathbb E\operatorname{Var}(R\mid X_{-i})
\le\sum_i\mathbb E(R-R_{-i})^2
\le c\mathbb E\sum_i d_i
\le c\mathbb ER.
]
The second-moment claim follows from the variance identity. QED.

## Corollary (orthogonal Hilbert increments)

Let (H) be a real Hilbert space; let (h\in H), and let (Y_i) be independent random vectors supported in pairwise orthogonal subspaces (H_i\subseteq h^\perp). Suppose (\|Y_i\|\le c) almost surely. Then, for (Z=h+\sum_iY_i),

[
\operatorname{Var}(\|Z\|)\le c\mathbb E\|Z\|,
\quad
\mathbb E\|Z\|^2\le(\mathbb E\|Z\|)^2+c\mathbb E\|Z\|.
]

Indeed, Pythagoras gives (\|Z\|=\sqrt{\|h\|^2+\sum_i\|Y_i\|^2}), and the theorem applies with (X_i=\|Y_i\|^2). **Centering is not needed.** The coefficient 1 on the squared first moment is stronger than the coefficient 2 conjectured in the unrestricted comparison.

## Scope and failure mode

For nonorthogonal increments, (\|h+\sum_iY_i\|\) may *increase* when (Y_i) is deleted; thus (R-R_{-i}\ge0) fails, and the above proof cannot be transferred directly. It does not imply the unrestricted all-n conjecture
[
\mathbb E\|h+\sum_iY_i\|^2\le2(\mathbb E\|h+\sum_iY_i\|)^2+c\mathbb E\|h+\sum_iY_i\|.
]
The latter still requires centering and independence, and remains open in the repository. Nor does the orthogonal theorem improve the certified unrestricted Q2 coefficient 105.741756923658.

## Open-problem audit / possible closures

1. **Closed analytically for the orthogonal sector:** all-n independent-Hilbert norm comparison, with coefficient 1, even without centering. This is a subclass, not the unrestricted question. Next certificate: Lean proof of the nonnegative square-root-sum theorem using finite Efron--Stein tensorization.
2. **Already treated in parallel:** the one-increment norm-variance comparison in PR #571. Do not claim it as new from this note; check its current-head Lean receipt before promotion.
3. **Still open:** unrestricted independent-Hilbert all-n comparison and the proposed unconditional Q2 coefficient 96.5735201305411. PRs #563 and #569 identify method obstructions and finite tests, not a proof.
4. **Still open:** source graph-cover improvement from 8B to 6B. PR #570 yields only a conditional coefficient 96.10039906698208. Orthogonality of Hilbert increments does not establish the graph-cover premise.
5. **Cheapest discriminating test:** search exact asymmetric two-dimensional nonorthogonal increment laws for failure of the *deletion self-bounding mechanism*, separately from counterexamples to the target inequality. Record both outcomes distinctly. If no operator transfer survives, seek an alternate signed or two-copy operator.

## Verification and novelty ledger

- Proof checker: hand-verifiable Efron--Stein inequality + algebra above; no Lean run or independent proof audit attached to this branch.
- External priority: **not checked** for this elementary self-bounding subclass theorem; no originality claim.
- Research graph: independent nonnegative squared norms -> deletion operator -> self-bounding inequalities -> Efron--Stein -> variance certificate -> orthogonal Hilbert corollary -> limitation (cancellation) -> prospective signed/two-copy operator.
- Do not promote to unrestricted C96 or publication without separate proof and priority checks.
