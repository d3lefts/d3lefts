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
The proof does not claim an attaining fixed protocol.

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

## Exact minimax infimum on a known sphere

On the known sphere of radius \(R>0\), the analogous error infimum at
\(2n-3\) readings is \(R/\sqrt2\) for unrestricted outputs, or
\(R\sqrt{2-\sqrt2}\) if outputs must also have norm \(R\).
For the lower bounds use the orthogonal collision in #997. In the
sphere-valued case, an output \(z\) of norm \(R\) cannot have inner
products of absolute value greater than \(R^2/\sqrt2\) with both
members of an orthogonal pair, by Bessel's inequality.

For the matching upper bounds, use \(2n-3\) rows of the same
near-hyperplane construction, with the same definition of
\(\eta_\varepsilon\). In a nonsingleton fiber pick a reference
\(x\), and let \(y\ne\pm x\) be another member. In the annihilator
partition at least one block has \(n-1\) rows; after replacing
\(y\) by \(-y\) if necessary, \(v=(x-y)/2\) belongs to the kernel
of this block and its unit direction is within sine
\(\eta_\varepsilon\) of the \(e\)-axis. Because the norms of
\(x,y\) agree, \(u=(x+y)/2\) is orthogonal to \(v\), so
\(\|P_W v\|\le\eta_\varepsilon\|v\|\) and
\(|\langle u,e\rangle|\le\eta_\varepsilon\|u\|\).
For the reflection \(J=I-2ee^\top\) these give
\[
\|y-Jx\|\le2(\|P_W v\|+|\langle u,e\rangle|)
\le 4R\eta_\varepsilon.
\]
Every quotient point in the fiber other than the reference is
therefore within \(4R\eta_\varepsilon\) of \([Jx]\).
Choose the sign of \(Jx\) to have nonnegative inner product with
\(x\) and decode to their ambient midpoint, or to its normalization
to norm \(R\) for the sphere-valued decoder. In the first case
both reference classes are within \(R/\sqrt2\) of the midpoint;
in the second they are within \(R\sqrt{2-\sqrt2}\) of the normalized
midpoint since the angle between the chosen representatives is at
most \(\pi/2\). The error on the entire fiber is at most the
claimed infimum plus \(4R\eta_\varepsilon\), which tends to zero.

## Two boundary facts

**Attainment in dimension two.** For \(R>0\), read \(h=x_1^2\),
then use the continuous row \((1,\sqrt h/(2R))\) (normalize
if needed and undo its known scale at decoding). When \(h>0\),
choose the representative \(x_1=\sqrt h\). Because \(|x_2|\le R\),
the unsquared second reading is at least \(\sqrt h/2>0\), so its
positive square root determines \(x_2\). At \(h=0\) the two readings
both vanish and the whole remaining fiber is the \(e_2\)-axis
intersected with the annulus. Its quotient is the interval \([r,R]\);
output its midpoint. This protocol attains the bound for \(n=2\).
The argument does not settle attainment for \(n\ge3\).

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
