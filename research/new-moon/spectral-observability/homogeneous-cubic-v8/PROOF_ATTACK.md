# v8 proof attack: matching-weight data alone do not force a soft cubic cover

**Date:** 2026-11-11. **Status:** Exact elementary combinatorial counterexample to a proposed *intermediate lemma*, **not** a counterexample to the bounded homogeneous-cubic influence conjecture.

## Candidate shortcut being attacked

One might hope to deduce a set of vertices \(T\) of size \(O(B/\sqrt M)\) with uncovered cubic energy \(W(T)=O(B\sqrt M)\) using only

1. an upper bound \(M\) on the sum of edge weights incident to each vertex; and
2. a bound \(A B\) on \(\sum_{e\in\mathcal M}\sqrt{w_e}\) for every matching \(\mathcal M\).

The first property follows for actual degree-three Hoeffding energies \(w_S=\|f_S\|_2^2\) from \(I_i(f)\le M\). A version of the second follows from the disjoint top-degree matching lemma by \(\|f_S\|_2\le\|f_S\|_\infty\). However, **these two combinatorial statements alone are insufficient**.

## Counterexample — weighted complete 3-hypergraph

For every \(n\ge3\), put a weight \(w_e=n^{-3}\) on each triple \(e\subseteq[n]\). Then

\[
M_n=\max_i\sum_{e\ni i}w_e=\binom{n-1}{2}/n^3\sim \frac1{2n},
\qquad
W_n=\sum_e w_e=\binom n3/n^3\longrightarrow\frac16.
\]

A matching contains at most \(\lfloor n/3\rfloor\) triples, hence

\[
\max_{\mathcal M}\sum_{e\in\mathcal M}\sqrt{w_e}
\le \frac{\lfloor n/3\rfloor}{n^{3/2}}\le1.
\]

For *every* subset \(T\) with \(|T|=t\), the uncovered energy is

\[
W_n(T)=\frac{\binom{n-t}{3}}{n^3}.
\]

Fix arbitrary constants \(C_1,C_2>0\). If \(t\le C_1/\sqrt{M_n}=O(\sqrt n)\), then \(W_n(T)\to1/6\), while \(C_2\sqrt{M_n}\to0\). Therefore the desired budget/residual conclusion cannot be deduced from these two numerical premises, even with constants allowed to depend on the fixed degree three.

### Scope and why it matters

This is **not** a sequence of bounded pure-cubic functions: arbitrary nonnegative edge weights need not arise from an \(L^\infty\)-bounded homogeneous cubic with these matching and energy parameters. In particular, the boundedness of the *whole function* gives analytic information absent from this countermodel. That additional information—cancellation, correlations of overlapping Hoeffding layers, and cross-link moment constraints—must enter any successful proof.

Consequently a purely weighted-hypergraph covering argument starting only from vertex energy budgets and disjoint matching amplitude bounds is insufficient. A decisive new operator must exploit the global bounded function or an equivalent analytic certificate, likely through link-dependent conditional moments or a structured decomposition that preserves \(L^\infty\) control.

## Exact replay

Run:

    python3 checks/weighted_hypergraph_no_go.py

The script checks the rational inequalities for three concrete instances, with no rounding in the assertions. It does not prove the asymptotic theorem, which follows from the displayed closed forms.

## Implications for the main v8 bridge

- The homogeneous projection \(\|f^{[3]}\|_\infty\le32B\) and the pure-cubic reduction are unaffected.
- The v8 soft-cover theorem remains a correct **conditional** theorem for a *supplied* cover \(T\).
- This obstruction limits one proposed way of **guaranteeing** a small-energy cover for unrestricted dense repeated-pair cubics.
- Next decisive test: develop a link-covariance / bounded-cubic polynomial certificate not expressible solely through \(w_e\) and vertex sums, and test it on complete hypergraphs with explicitly normalized bounded degree-three functions.

No unrestricted cubic exponent-two theorem, novelty certification or independent formal audit follows from this note.
