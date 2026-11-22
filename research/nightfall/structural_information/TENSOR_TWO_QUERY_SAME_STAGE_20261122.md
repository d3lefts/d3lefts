# NIGHTFALL — Two-query tensor: same-stage dephasing and residual
2026-11-22, v0.1. **Provisional paper-level lemma; not Lean certified;
not a full two-query simulator; novelty not audited.**

## Target and models

Uniform secret \(s\in\mathbb F_2^{2^L}\), original query rows
\[
R_L=\{u_1\otimes\cdots\otimes u_L:
u_i\in\{(1,0),(0,1),(1,1)\}\},\quad |R_L|=3^L.
\]
The goal is approximation of any two-query quantum acceptance function
under uniform \(s\), outside a \(\delta\) fraction, within \(\varepsilon\),
using polynomially many **original row-parity queries**. No arbitrary
derived XOR oracle queries are free.

Let \(D=R\cup\{0\}\). Purification and the phase-oracle basis express
any sequential two-query circuit as
\[
\psi_s=O_s U O_s\psi,\quad
O_s=\sum_{a\in D}\chi_a(s)\Pi_a,\quad
\chi_a(s)=(-1)^{\langle a,s\rangle},
\]
where \(\psi\) is a unit vector, \(U\) a fixed unitary, the
\(\Pi_a\) orthogonal projectors summing to identity, and
\(0\preceq P\preceq I\) the final effect. Write
\(v_{ba}=\Pi_b U\Pi_a\psi\), so
\[
f(s)=\sum_{a,b,a',b'\in D}
\chi_{a+b+a'+b'}(s)\langle v_{ba},Pv_{b'a'}\rangle.
\]

## Theorem (author-side): same-stage terms admit T=1 simulation

Define the first-stage diagonal, second-stage diagonal, and intersection
of both diagonals as
\[
\begin{aligned}
f_A(s)&=\sum_a\langle O_sU\Pi_a\psi,P O_sU\Pi_a\psi\rangle,\\
f_B(s)&=\langle O_s\psi,U^\dagger\mathcal E(P)U O_s\psi\rangle,
 \quad \mathcal E(P)=\sum_b\Pi_bP\Pi_b,\\
c&=\sum_{a,b}\langle v_{ba},Pv_{ba}\rangle.
\end{aligned}
\]

**Claim and proof.** \(f_A\) is a valid one-query acceptance function:
use the mixed initial state
\(U(\sum_a\Pi_a|\psi\rangle\langle\psi|\Pi_a)U^\dagger\),
the same oracle and the effect \(P\). \(f_B\) is also one-query,
because pinching is unital and positive, so
\(0\preceq U^\dagger\mathcal E(P)U\preceq I\).
Both lie in \([0,1]\); \(c\in[0,1]\) is constant.
Consequently \(q=(f_A+f_B)/2\) is a valid one-query acceptance
function via a classical known coin or purification.

By inclusion-exclusion on the original path-pair indices, the exact
same-stage part and its coherent complement are
\[
f_{\rm same}(s)=f_A(s)+f_B(s)-c=2q(s)-c,
\]
\[
h(s)=f(s)-f_{\rm same}(s)
  =\sum_{\substack{a\ne a'\\b\ne b'}}
     \chi_{a+b+a'+b'}(s)\langle v_{ba},Pv_{b'a'}\rangle.
\]
The remainder need not vanish. The decomposition is purely algebraic
and does **not** posit mutual orthogonality of the two-query Fourier
frequency vectors (an explicitly false shortcut in merged #962).

The paper-level one-query theorem archived by PRs #960/#962 gives
a deterministic distributional simulator of any one-query acceptance
function with at most \(\lceil2M/(\eta^2\zeta)\rceil\)
original-row queries, where
\[
M=\max\bigl(1,\max_{z\ne0}
 \#\{(a,b)\in D^2:a+b=z\}\bigr).
\]
Simulating \(q\) to accuracy \(\eta=\varepsilon/2\) and failure
\(\zeta=\delta\) and returning \(2\widetilde q-c\) shows
\[
\Pr[|\widetilde f_{\rm same}-f_{\rm same}|>\varepsilon]
 \le\delta,\qquad
Q_{\rm classical}\le
 \min\{|R|,\lceil8M/(\varepsilon^2\delta)\rceil\}.
\]
For the tensor family \(M=2L+2\):
\[
\boxed{Q_{\rm same}\le
 \min\{3^L,\lceil16(L+1)/(\varepsilon^2\delta)\rceil\}.}
\]

**This does not simulate the full function \(f\)**, because \(h\)
is uncontrolled. A conditional full simulator follows if
\(\mathbb E|h|^2\le \gamma^2\zeta\) for
\(0<\gamma<\varepsilon,\ 0<\zeta<\delta\):
by Markov and union bound, querying
\(\lceil8M/((\varepsilon-\gamma)^2(\delta-\zeta))\rceil\)
rows suffices. This is a sufficient condition, not a universal bound
on \(h\).

## Shared-row cancellations: exact simple lemma

For distinct \(a,b\in R_L\), the pairs
\((r+a,r+b)\in(D+D)^2\), indexed by \(r\in R_L\),
are distinct and all XOR to \(a+b\), giving at least \(3^L\)
ordered pairs in that fiber. But \(a+b\) is a parity accessible with
two original rows, so these pairs alone witness *multiplicity*,
not *query hardness*.

Over characteristic two, if any label repeats among
\(a,b,a',b'\), then \(a+b+a'+b'\) is a sum of at most two remaining
labels. Hence Fourier frequencies requiring more than two original
rows can occur only from four pairwise-distinct labels. Cross-stage
repetitions such as \(a=b'\) are still allowed in \(h\): the
same-stage reduction does **not** yet control their aggregate.


## Exact negative control: coherent remainder need not shrink with tensor depth

For the rational orthogonal four-sector circuit encoded in
check_two_query_dephasing_exact.py, let the available phases be
\(D=\{0,a,b,a+b\}\), for any distinct nonzero \(a,b\in R_L\)
with \(a+b\in R_L\). On uniform independent
\((\chi_a,\chi_b)\), its exactly computed residual is
\[
h(s)=(-1)^{\langle a+b,s\rangle}
    \frac{4608}{40625}
\]
up to the choice of sign conventions for row labels. Therefore
\[
\|h\|_{L^2(s)}=\frac{4608}{40625}
\quad\text{for every }L\ge1.
\]
At each tensor depth, such a triple exists: vary one local factor
through the three nonzero vectors of \(\mathbb F_2^2\), and fix the
remaining local factors. The two corresponding linear functionals on
uniform \(s\) are independent, while the third is their XOR.

**Consequence:** no theorem of the form
\(\sup_{\text{two-query circuits}}\|h\|_2=o_{L\to\infty}(1)\)
can be true for this same-stage dephasing. This is an **exact algebraic
counterexample to one tempting proof shortcut**, not a counterexample
to polynomial classical row-query simulation: the example depends
on only three available rows. The next certificate must recognize
and cheaply simulate large but low-complexity residuals.

## Reproduction and audit

- Exact rational four-sector example:
  check_two_query_dephasing_exact.py. It separately evaluates direct
  circuit expressions and full quadruple-path sums on every secret,
  verifying nonzero coherent remainder. Uses only Python stdlib.
- Exact tensor row four-distinct XOR enumeration:
  check_tensor_four_distinct.py for \(L\le4\).
  Observed at \(L=3\): 27 rows, 190 cost-\(\le2\) frequencies,
  17,550 four-distinct row quadruples and max cost-\(>2\) fiber 72.
  At \(L=4\): 81 rows, 2,350 cost-\(\le2\) frequencies,
  1,663,740 four-distinct quadruples and max cost-\(>2\) fiber 101.
  No all-depth polynomial fiber theorem follows from these samples.
- **Independent circuit auditor:** reconstruct dephasing and pinching
  without this note, check the \(8M\) factor and quantum implementability.
- **Interference auditor:** seek a valid circuit where \(h\) is large;
  attack crossed-stage repeats and four-distinct contributions using
  unitary/projector normalization.
- **Tensor auditor:** test high-cost fibers and proof candidates beyond
  small depths, avoiding the exponential raw pair-sum multiplicity.
- **Prior art:** relevant background is Bansal–Sinha–de Wolf CCC 2022
  and arXiv:2609.05201 (completely bounded polynomial inequalities).
  Distinguish their disjoint-block/nonadaptive regimes from this
  repeated correlated row oracle; no priority claim.
- **Lean:** formalize the pinching/inclusion-exclusion lemma and query
  reduction after independent proof audit. No topology/axioms shortcuts.

**Stop rule:** no new global T=2 claim until the crossed-history
coherent remainder is bounded by a real row-cost-sensitive operator
or a circuit-based counterexample is certified. Retain Simon
task-aware transcript simulation (PR #987) as the longer-term
structural-information question; maintain cubic arbitrary-product
influence Q3 (PR #803) as a separate mathematical target.
