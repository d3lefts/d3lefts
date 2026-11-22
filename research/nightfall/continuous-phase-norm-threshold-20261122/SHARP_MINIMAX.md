# Sharp noiseless recovery error one reading below the threshold

**NIGHTFALL extension of [#997](https://github.com/d3lefts/d3lefts/pull/997),
2026-11-22.** Paper proof with independent internal audit of the infimum
argument; not Lean-certified or externally reviewed. Literature priority
has not been established. This note sharpens the annular error order in
the [exact-norm proof passport](../continuous-phase-norm-threshold-20261122/PROOF_PASSPORT.md).

## Exact minimax infimum

Fix \(n\ge2\) and \(0\le r<R\), with signal domain
\(D=\{x:r\le\|x\|\le R\}\). Consider the infimum, over deterministic
continuous causal squared-linear protocols using \(2n-2\) readings and
arbitrary deterministic decoders into the sign quotient of \(\mathbb R^n\),
of their worst-case noiseless \(d_\pm\) reconstruction error on \(D\).
Then
\[
\boxed{\quad E_{2n-2}(r,R)=\frac{R-r}{2}.\quad}
\]
Continuity means continuity of the vector-valued selector on genuinely
reachable histories, as in #997. The infimum is unchanged if every row
must have norm at most one. On the unit ball the exact value is \(1/2\).
The fixed-protocol infimum is the same but is not attained; a continuous adaptive protocol attains it.

**Lower bound.** The separated collision theorem from #997 gives two
inputs with the same transcript and quotient distance \(R-r\) for
every admissible protocol. One common decoder output has error at
least half that distance on one of the inputs.

**Upper bound.** Put \(W=\mathbb R^{n-1}\times\{0\}\) and \(e=e_n\).
Pick \(2n-2\) distinct real numbers \(t_i\), and for \(\varepsilon>0\)
use the fixed rows
\[
a_i^\varepsilon=(1,t_i,\ldots,t_i^{n-2},\varepsilon t_i^{n-1}).
\]
All \(n\)-row blocks are invertible whenever such blocks exist.
Every \(n-1\) rows are independent even in the limit
\(\varepsilon\to0\), and in that limit span \(W\). More explicitly,
for a block indexed by \(I\), let \(V_I\) be the square Vandermonde
matrix of the first \(n-1\) columns, and \(w_I=(t_i^{n-1})_{i\in I}\).
Its common kernel is the line through
\((-\varepsilon V_I^{-1}w_I,1)\).
Thus every vector in one of these kernel lines obeys
\(\|P_W z\|\le\eta_\varepsilon\|z\|\), with
\(\eta_\varepsilon=\varepsilon\max_I\|V_I^{-1}w_I\|\to0\).
Normalizing rows preserves the kernels and the equality of
intensity transcripts.

If \(x\ne\pm y\) give identical readings, put
\(u=(x+y)/2\), \(v=(x-y)/2\). Each row annihilates \(u\) or \(v\).
Neither vector is zero, and neither can be annihilated by \(n\)
rows. Hence the rows partition into two \(n-1\)-row blocks and
\(u,v\) belong to their respective kernel lines. It follows that
\[
\|P_Wx\|\le\eta_\varepsilon(\|u\|+\|v\|)
\le\sqrt2 R\eta_\varepsilon.
\]
In particular **every** signal in a nonsingleton quotient fiber
lies this close to the \(e\)-axis: for each such signal one may
choose any different sign class in its fiber.

Decode singleton quotient fibers exactly. Decode every other
reachable fiber to \([((r+R)/2)e]\), which also belongs to the
annulus. Choose the representative sign of \(x\) making
\(\langle x,e\rangle\ge0\). Then
\[
\|x-\|x\|e\|^2
=2\|x\|(\|x\|-\langle x,e\rangle)\le2\|P_Wx\|^2,
\]
including \(x=0\). Its error from the midpoint decoder is at
most \((R-r)/2+2R\eta_\varepsilon\). Let \(\varepsilon\to0\).
No continuity of the decoder is asserted.

## The optimum is attained by a continuous adaptive policy

Let \(d=n-1\) and \(K=\sum_{j=1}^d3^{j-1}\). Read the first \(d\)
coordinate intensities, so \(m_j=|x_j|\) is known. In one further
batch of \(d\) readings, measure with the rows
\[
a_i=e_i+\lambda\sum_{j\ne i,\ j\le d}
    \frac{m_i^2\,3^{j-1}}{\max(m_i,m_j)}e_j
    +\frac{\lambda m_i^2}{4R}e_n,\qquad
\lambda=\frac{1}{2R(K+1)}.
\]
Take a coefficient of the form \(0/0\) to be zero. Since
\(m_i^2/\max(m_i,m_j)\le m_i\) where defined, each row depends
continuously on the reachable prefixes. Normalize each row if
needed and undo its known scale at decoding; its \(i\)-th
coefficient is one before normalization.

If some \(m_i>0\), choose an index \(i\) of smallest positive
magnitude *at decoding*, and orient the signal with \(x_i=m_i\).
The total perturbation of the amplitude \(\langle a_i,x\rangle\)
away from \(m_i\) has absolute value at most
\(\lambda m_i^2(K+1/4)\le m_i/2\).
Thus the positive square root gives that amplitude. Subtract
\(m_i\) and divide by \(\lambda m_i^2\). Each nonzero \(x_j\),
\(j\ne i\), has \(m_j\ge m_i\), so the result is
\[
\sum_{j\ne i,\ j\le d}3^{j-1}\operatorname{sgn}(x_j)
    +\frac{x_n}{4R}.
\]
The last summand lies in \([-1/4,1/4]\). Rounding to the nearest
integer recovers the signed ternary digits uniquely (take
\(\operatorname{sgn}(0)=0\)); the remainder recovers \(x_n\).
Both steps are exact. No discontinuous minimum-selection operation
takes place in the sensing policy.

The only ambiguous fiber is the \(e_n\)-axis, on which all
observations vanish. Its sign quotient is \([r,R]\), so its
midradius vector attains error exactly \((R-r)/2\).
This proves the infimum is a **minimum** among continuous
adaptive protocols, for every \(n\ge2\).

**No fixed protocol attains that minimum.** If its rows span a
proper subspace, choose a unit vector \(e\) in their common
kernel and \(w\) orthogonal to \(e\). The orthogonal pair
\(R(w\pm e)/\sqrt2\) has identical readings, forcing error
at least \(R/\sqrt2>(R-r)/2\).
If the rows span \(\mathbb R^n\), split them into groups of
\(n-1\). Their kernels each contain a unit vector, and one
can select nonparallel vectors \(u,v\) from these kernels
(otherwise both kernels are the same line). Set
\(a=(R+r)/2\) and \(b=(R-r)/2\); both \(au+bv\) and \(au-bv\)
have norms strictly between \(r\) and \(R\), since
\(|\langle u,v\rangle|<1\). Their common transcript and distance
\(2b\) follow from the split kernel constraints. Scale both by
the same factor slightly larger than one, keeping both in the
annulus. They still have a common transcript and their new
quotient distance is strictly greater than \(R-r\).
Thus the fixed-protocol infimum is the same, but is never attained.

## Exact minimax error on a known sphere

On the known sphere of radius \(R>0\), the analogous minimum
at \(2n-3\) readings is \(R/\sqrt2\) for unrestricted outputs, or
\(R\sqrt{2-\sqrt2}\) if outputs must also have norm \(R\).
For the lower bounds use the orthogonal collision in #997. In the
sphere-valued case, an output \(z\) of norm \(R\) cannot have inner
products of absolute value greater than \(R^2/\sqrt2\) with both
members of an orthogonal pair, by Bessel's inequality.

For attainment use a fixed full-spark frame of \(2(n-1)-1\) rows
on \(W=e^\perp\). It retrieves the projection \(w=P_Wx\) up to
sign. The known norm determines the other coordinate's absolute
value \(t=\sqrt{R^2-\|w\|^2}\). Thus each quotient fiber consists
of at most two classes with representatives \(w+te,w-te\).
Choose the signs of the representatives to have nonnegative
inner product, and decode to their midpoint, or its normalization
to norm \(R\) if required. An angle of at most \(\pi/2\) gives
the respective worst-case bounds \(R/\sqrt2\) and
\(R\sqrt{2-\sqrt2}\), so both are attained without adaptivity.

## Noise caveat

**The near-coplanar construction is not uniformly robust to noise.**
If normalized rows have \(\max_i|\langle a_i,e\rangle|\le\gamma\),
take a unit \(w\in W\) and \(x_\pm=R(w\pm e)/\sqrt2\).
Both have norm \(R\), are orthogonal, and differ in each squared
reading by at most \(2R^2\gamma\).
Adversarial additive error of size \(R^2\gamma\) per reading can
give them the same corrupted transcript, forcing error at least
\(R/\sqrt2\). This observation concerns the displayed fixed frames,
not all continuous causal protocols.

## Formalization handoff

Keep the genuine-prefix collision and equivariant zero obligations
of #997 separate from this elementary upper bound. The latter only
needs the finite Vandermonde determinant, the block partition
from equality of squares, and the two Euclidean estimates.
Do not substitute finite numerical replay for the lower bound
or report this extension as already kernel-checked.
