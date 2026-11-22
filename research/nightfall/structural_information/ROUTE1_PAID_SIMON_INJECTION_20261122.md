# Route 1 after paid structure recovery: injective labels and Simon

**Status:** paper-level composition with an independent internal audit.
The reciprocal-grid bound is due to Zhandry. No specialist priority
or end-to-end Lean claim. The accompanying Lean module checks the
atom-polynomial algebra only; it does not model probability laws or
formalize Zhandry's theorem.

## 1. Bounded degree testing against a uniform injection

Let \(J\) be a finite set of table positions with \(|J|\le A\).
Compare a uniformly random injection \(I:J\hookrightarrow[A]\)
and the IID uniform labeling \(U:J\to[A]\). For a globally
\([0,1]\)-valued function \(g:[A]^J\to\mathbb R\) of
interaction degree at most \(k\), the following bound holds:
\[
|\mathbb E_I g-\mathbb E_U g|
 \le \min\{1,\pi^2\max(k-1,0)^3/(6A)\}.
\]

For an integer \(r\ge1\), sample independent uniform keys in
\([r]\) at all positions, then inject the occupied keys uniformly
into \([A]\). This is always possible since \(|J|\le A\). An
atom fixing \(j\ge1\) positions and \(\ell\) distinct output
labels has probability
\[
(r)_\ell/(r^j(A)_\ell)
  =\frac{\lambda^{j-\ell}\prod_{i=0}^{\ell-1}(1-i\lambda)}
    {(A)_\ell},\qquad \lambda=1/r.
\]
Indeed, there are \((r)_\ell\) ordered choices of distinct keys
for its prescribed equality classes; all other assignments
are incompatible with an injective relabeling. Then the assigned
distinct labels have probability \(1/(A)_\ell\), by symmetry,
regardless of additional occupied keys. The polynomial has degree
at most \(j-1\) since the \(i=0\) factor is 1.
At \(r=A\) the law is IID (one can use a full independent
permutation to relabel all keys). At \(\lambda=0\) it is the
uniform injection, as one sees on every atom. Zero-coordinate
atoms are constant.

Expand \(g\) into indicator monomials on at most \(k\) coordinates,
so its expected value along this family is a polynomial of
degree at most \(\max(k-1,0)\). Global boundedness puts it in
\([0,1]\) at zero and at all positive reciprocal integers.
[Zhandry, Theorem B.1 with \(\Delta=1\)](https://eccc.weizmann.ac.il/report/2012/140/revision/1/download/)
gives the bound (degree zero is immediate). This is an
application of the existing small-range interpolation method.

## 2. Compose with a product-source decision tree

For any globally bounded degree-\(d\) target \(f\) and a depth-\(q\)
tree \(t\) with leaf values clipped to \([0,1]\), the loss
\(g=(f-t)^2\) also lies in \([0,1]\). It has interaction degree at
most \(K=\max(2d,d+q)\): each tree leaf is an atom on at most
\(q\) positions, \(t^2\) is another tree on those same leaves,
and the cross product has degree at most \(d+q\).
Thus an IID loss bound \(\mathbb E_U(f-t)^2\le a\) gives
\[
\Pr_I(|f-t|>\varepsilon)\le
\frac{a+\pi^2\max(K-1,0)^3/(6A)}{\varepsilon^2}.
\]
Use the product case of [Route 1](https://github.com/d3lefts/d3lefts/pull/970)
to obtain depth \(\operatorname{poly}(d,1/\varepsilon,1/\delta)\)
and IID squared risk ≤\(\varepsilon^2\delta/2\).
For example, choose probability of error at most
\(\varepsilon^2\delta/4\) at threshold
\(\varepsilon\sqrt\delta/2\), and use clipping and \(g\le1\).
The injection guarantee follows when
\(A\ge \pi^2\max(K-1,0)^3/(3\varepsilon^2\delta)\).
If this gate fails, querying the entire table uses ≤\(A\) queries,
which is itself bounded by a polynomial in the same parameters
whenever the table size is at most the alphabet size.

## 3. Simon on the original oracle: no free access to the shift

Let \(N=2^n\). Use Simon's standard conditional source: for nonzero
shift \(s\in\mathbb F_2^n\), the \(N/2\) pairs \(\{x,x+s\}\)
receive distinct labels via a uniform injection into \([N]\).
The statement works for any prior on the nonzero shift, and the
worst-case lower bound below uses a uniform shift.

First query \(U_0\cup V_0\) for complementary binary coordinate
subspaces of dimensions \(\lfloor n/2\rfloor,\lceil n/2\rceil\).
Each \(s\) has a representation \(u+v\) with one point in each
subspace. Since \(s\ne0\), \(u\ne v\); these readings have the same
label. Any equal-label distinct pair certifies the true shift.
This stage costs \(2^{\lfloor n/2\rfloor}+2^{\lceil n/2\rceil}-1\)
original queries, a known difference-cover construction.

For the second stage pick one representative per recovered pair,
and substitute the shared label into each of the two original
addresses. A globally bounded degree-\(d\) function on the
original table remains globally bounded and degree at most \(d\):
substitution only merges coordinates in indicator monomials.
Then use §2 on the quotient, charging one original oracle query
for each representative coordinate actually read.

There are two valid implementations:
1. Use a preselected quotient simulator depending only on \(s\).
   Its error analysis conditions only on \(s\); the representative
   labels are still uniform injective under that conditioning.
2. Reuse the full cover transcript. Conditional on \(s\) and a
   possible transcript, exactly \(h\) quotient entries are fixed and
   the rest are uniform injective into the unused alphabet of size
   \(N-h\). (A deterministic transcript specifies a cylinder.)
   Fixing the known entries cannot increase degree. Use §2 on the
   remaining table; the error bound then holds conditional on each
   such transcript. Since \(h=O(\sqrt N)\), \(N-h\ge N/2\) for
   sufficiently large \(N\). Outside the finite-size gate, the
   full-table fallback costs at most an additive polynomial in
   the simulation parameters.

The resulting depth is \(O(\sqrt N)+\operatorname{poly}(d,1/\varepsilon,1/\delta)\)
and accuracy is distributional on the original source. This is
nonuniform query complexity, not a runtime bound or a simulation
of quantum output states. In particular \(d\le 2T\) for the
standard \(T\)-query quantum acceptance polynomial; the result
covers arbitrary such acceptance observables, not merely the
hidden-shift task.

For fixed accuracy the \(O(\sqrt N)\) term cannot be improved
uniformly over all \(O(\log N)\)-query acceptance observables.
Take a quantum algorithm for one designated bit of the hidden
shift. Until a classical collision, each fixed distinct-label
transcript has equal probability under every shift except the
at most \(\binom q2\) nonzero XOR differences ruled out by its
\(q\) query points. Thus a \(q=o(\sqrt N)\) transcript leaves
the hidden bit almost unbiased with high probability (the
conditional probability of a new collision is at most
\(q/(N-1-\binom q2)\)). A constant-error predictor of the
quantum acceptance would distinguish the bit. This invokes
the usual Simon quantum upper bound, not a new Simon lower bound.

## 4. Multiple injection blocks and a latent reference

For multiple conditionally independent injection blocks with
one common alphabet size \(A\), use the same integer \(r\) in the
interpolation independently in each block. An atom touching
\(j\) positions in \(c\ge1\) blocks has reciprocal degree at most
\(j-c\), so the same bound applies without multiplying by block
count. One may also have a fixed latent measure on the chosen
block ranges; if all component range sizes equal \(A\), averaging
the interpolation coefficients preserves the degree, and the IID
endpoints are product components over those ranges. Route 1 can
charge the Wyner information of this IID replacement mixture,
plus whatever original-oracle cost is needed to recover or
decode the structural representation. This is a sufficient
principle, not a characterization. The common-\(A\) argument
does not by itself handle unequal unused alphabets.

## Prior art and evidence boundaries

- [Zhandry's reciprocal-grid theorem](https://eccc.weizmann.ac.il/report/2012/140/revision/1/download/)
  and [small-range applications](https://arxiv.org/pdf/1312.1027)
  are prior art for the polynomial comparison. [Chailloux's
  permutation-symmetric simulation](https://doi.org/10.4230/LIPIcs.ITCS.2019.19)
  is related but treats worst-case symmetric properties.
- [#987](https://github.com/d3lefts/d3lefts/pull/987) preserves
  the difference cover and states the task-aware recovery target;
  [#988](https://github.com/d3lefts/d3lefts/pull/988) supplies the
  exact loss-degree observation. The proposed contribution is the
  paid-recovery composition, its conditional-transcript form, and
  multi-block use, not these ingredients in isolation.
- The atom identity was internally replayed on 1,925 finite cases.
  That does not prove the reciprocal-grid inequality or the whole
  simulator formally. The final theorem, source-law construction,
  and specialist priority review remain separate verification tasks.
