# Continuous causal phase retrieval: the exact-norm threshold

**NIGHTFALL research note and proof passport, 2026-11-22.** Paper-level
proof, internally cross-checked; not externally refereed or Lean-certified.
No literature priority claim. This note does not promote or merge
[parallel draft #995](https://github.com/d3lefts/d3lefts/pull/995).

## Statement and model

Let \(n\ge2\), \(0\le r\le R\), and \(R>0\). The input set is
\(D_{r,R}=\{x\in\mathbb R^n:r\le\|x\|\le R\}\). A deterministic protocol
takes \(m\) exact readings. If \(T_{j-1}(x)\) is the prefix of readings
already taken, it chooses a real row \(a_j(T_{j-1}(x))\) and appends
\(\langle a_j(T_{j-1}(x)),x\rangle^2\). The selector \(a_j\) must be
continuous only on the set of prefixes actually reached by inputs in
\(D_{r,R}\), with its Euclidean subspace topology. Every selector is
vector-valued; continuity of a matrix-valued or unoriented row selector
without a continuous vector representative is not assumed sufficient.
The decoder need not be continuous. A fixed bound on row norms is
unnecessary; imposing an upper bound of one does not change the counts.

Recovery is up to global sign, with distance
\(d_\pm(x,y)=\min(\|x-y\|,\|x+y\|)\).

| Norm information | Exact minimum readings | Collision with one fewer reading |
| --- | --- | --- |
| \(0\le r<R\) | \(2n-1\) | \(d_\pm=R-r\) |
| Known positive norm \(r=R\) | \(2n-2\) | Orthogonal radius-\(R\) inputs, \(d_\pm=\sqrt{2}R\) |

The first row includes the unit ball and implies the unrestricted
all-signal lower bound. In dimension four, it separates seven readings
from six when the norm is known. By the triangle inequality on the sign
quotient, the displayed collisions give worst-case decoder errors at least
\((R-r)/2\) and \(R/\sqrt{2}\), respectively, even with noiseless data.
For \(n=1\), one reading gives the unknown norm and none are needed when
it is known. The singleton at norm zero needs no readings.

## Lower bounds using only genuine prefixes

For two vectors \(u,v\) chosen so that \(x_+=u+v\) and \(x_-=u-v\) both lie in
the input domain, form the test row
\[
b_j(u,v)=\tfrac12\left[a_j(T_{j-1}(x_+))+a_j(T_{j-1}(x_-))\right].
\]
All prefixes at which selectors are evaluated are genuine. The transcript
maps are continuous by induction on \(j\): the preceding transcript is
continuous into the reachable set and the next row is continuous there.
All transcripts are globally sign-invariant, also by induction.
Changing either sign of \(u,v\) therefore swaps the two prefixes (possibly
negating their inputs), so \(b_j\) is continuous and separately even.

Partition the stages into \(U,V\). Use obstruction coordinates
\(\langle b_j,u\rangle\) for \(j\in U\) and
\(\langle b_j,v\rangle\) for \(j\in V\). These have sign characters
\((-1,+1)\) and \((+1,-1)\), respectively. At a common zero, prove by causal
induction that \(T_j(x_+)=T_j(x_-)\). At the start the prefixes are empty.
At each subsequent stage, equality of the preceding prefixes makes both
actual rows equal to their average \(b_j\). The difference of the new
readings is then \(4\langle b_j,u\rangle\langle b_j,v\rangle=0\).
The two signals are distinct modulo sign since neither \(u\) nor \(v\)
is zero.

**Annulus of positive width.** Choose the two spheres of radii
\(\|u\|=(R+r)/2\) and \(\|v\|=(R-r)/2\). Triangle and reverse triangle
inequalities place both candidate signals in the annulus for every
pair. For \(m\le 2n-2\), choose both stage groups of size at most \(n-1\)
and pad by zero components to size \(n-1\) in each sign character. The
product-sphere zero theorem ([Chan–Chen–Frick–Hull, Remark 2.7](https://arxiv.org/pdf/1902.00935))
gives a common zero. Equivalently, the top Stiefel–Whitney class of the
associated bundle over \(\mathbb{RP}^{n-1}\times\mathbb{RP}^{n-1}\)
is \(\alpha^{n-1}\beta^{n-1}\ne0\). The collision distance is
\(2\min(\|u\|,\|v\|)=R-r\).

**Known positive norm.** Work directly on the Stiefel manifold
\(V_{n,2}\) of ordered orthonormal pairs and take \(u,v\) to be its two
vectors scaled by \(R/\sqrt{2}\). The candidates have norm \(R\) for
every pair, so even here no extension is required. For
\(m\le2n-3\), pad the \(U,V\) coordinates to \(n-1,n-2\), respectively.
[Chan–Chen–Frick–Hull, Theorem 1.1 with \(k=2\)](https://arxiv.org/pdf/1902.00935)
gives a zero for this exact representation on \(V_{n,2}\).
At the zero, the candidates are orthogonal because
\(\langle u+v,u-v\rangle=\|u\|^2-\|v\|^2=0\).

## Matching fixed constructions

Any full-spark \((2n-1)\times n\) real matrix \(A\) retrieves the sign
class: equal squared readings at \(x,y\) imply each row annihilates
\(x-y\) or \(x+y\), and one group contains at least \(n\) rows and spans.
One may take distinct real Vandermonde rows and normalize each row if
needed. This is the classical complement-property construction.

For known norm, instead use the full-spark Parseval matrix
\(B=A(A^\top A)^{-1/2}\). Right multiplication by an invertible matrix
preserves full spark; \(B^\top B=I\), so each row already has norm at
most one. Omit one row: the missing squared reading is \(R^2\) minus
the sum of the retained readings. The full-frame decoder then applies.

## Approximate recovery with one fewer reading on an annulus

At \(2n-2\) readings, for any fixed \(n\) the minimax worst-case error
over continuous deterministic protocols is **of order \(R-r\)**,
uniformly in \(0\le r<R\). The lower bound is \((R-r)/2\) above. For
the upper bound, use the same fixed truncated Parseval frame and return
any annular signal \(y\) consistent with the observed prefix. Such a
signal exists for every valid prefix; no efficiency claim is needed.

Let \(s>0\) be the smallest singular value among all \(n\)-row square
submatrices of the full Parseval frame. Choose the sign of \(y\) so
\(p=(x+y)/2\) satisfies \(\|p\|\ge\|q\|\) for \(q=(x-y)/2\). Then
\(d_\pm(x,y)=2\|q\|\); assume this is nonzero. Each retained row
annihilates \(p\) or \(q\) by equality of squared readings. Full spark
allows at most \(n-1\) rows to annihilate either nonzero vector, so
the \(2n-2\) retained rows partition into two groups of \(n-1\).
Adding the omitted row \(b\) to either group gives
\(|\langle b,p\rangle|\ge s\|p\|\) and
\(|\langle b,q\rangle|\ge s\|q\|\). Parseval and equality of the
retained entries give
\[
\big|\|x\|^2-\|y\|^2\big|
=4|\langle b,p\rangle\langle b,q\rangle|
\ge s^2 \max(\|x\|,\|y\|)\, d_\pm(x,y),
\]
using \(2\|p\|\ge\max(\|x\|,\|y\|)\).
The left side is at most \(2\max(\|x\|,\|y\|)(R-r)\), giving
\(d_\pm(x,y)\le 2(R-r)/s^2\). The constant depends on the frame,
not the annulus. This is noiseless, not a noisy stability claim,
a sharp minimax constant, or a bound uniform in dimension.

## Provenance and remaining verification

- [#695](https://github.com/d3lefts/d3lefts/pull/695) certifies the
  unrestricted adaptive and fixed counts in its own model.
  [#699](https://github.com/d3lefts/d3lefts/pull/699) certifies the
  narrower coordinate-first continuity obstruction, with a much weaker
  continuity assumption along one path. Neither certifies this result.
- Parallel [#995](https://github.com/d3lefts/d3lefts/pull/995), inspected
  at head [0360205](https://github.com/d3lefts/d3lefts/commit/03602051af4130c3e92414c655fb22a7f885743b),
  derives the unrestricted all-policy count with virtual histories and
  a Tietze extension. The distinct contributions here are the
  genuine-prefix proof, collision separation, the exact-known-norm vs.
  annulus threshold, and the annular approximation order.
- The topological inputs are established results, not claims of novelty.
  [Balan–Casazza–Edidin](https://arxiv.org/abs/math/0412411) is the
  fixed-frame baseline; [Bahmanpour et al., §4, after Proposition 4.6](https://arxiv.org/pdf/1409.8266)
  already exhibits recovering the omitted reading using known norm in
  dimension three. [Ullrich](https://arxiv.org/abs/2610.33781) gives
  a logarithmic lower bound for more general adaptive continuous
  functionals and ordinary antipodal equality; that equality alone
  is automatic here and cannot separate distinct sign classes.
- Scope excludes randomized recovery guarantees, adaptive stopping
  discontinuities, general quadratic measurements, and complex phase.
  Internal mathematical checking is not external review. Before
  promotion: same-model specialist priority review and an
  end-to-end Lean proof with audited topology dependencies.
