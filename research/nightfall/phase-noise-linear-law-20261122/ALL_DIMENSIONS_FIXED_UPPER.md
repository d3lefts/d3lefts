# Sharp small-noise exponent in every real dimension

**Status:** independently cross-checked paper-level extension of
[PR #1009](https://github.com/d3lefts/d3lefts/pull/1009) and
[the noiseless proof passport](https://github.com/d3lefts/d3lefts/pull/997).
No Lean or priority claim. This extends the fixed two-row upper bound in
#1009 to every fixed \(n\ge2\), with explicit dimension-dependent
constants. It uses the near-coplanar construction from
[#999](https://github.com/d3lefts/d3lefts/pull/999), but needs a noisy
fiber estimate: exact finite collisions alone do not control noisy error.

## Statement

On the radius-\(R\) Euclidean ball, use \(2n-2\) normalized real squared
linear readings and error \(d_\pm\) modulo global sign. Each intensity
can be corrupted by up to \(\sigma\) in absolute value. For each \(n\)
there are \(C_n,\sigma_n>0\) and a fixed (nonadaptive) row design,
chosen using \(\sigma,R\), with worst-case error
\[
E^{\mathrm{fix}}_n(\sigma,R)\le R/2+C_n\sigma/R
 \qquad(0<\sigma\le \sigma_n R^2).
\]
By the paper-level lower bound in #1009 applied to the collision in
#997, every admissible continuous causal policy on the ball has
error at least \(R/2+\sigma/(96R)\) for sufficiently small
\(\sigma/R^2\). Thus the linear exponent for the excess over \(R/2\)
is sharp **in every fixed dimension**, even when the upper bound is
restricted to fixed measurements. This does not show equality of
the adaptive and fixed sharp constants.

## Upper proof

Choose \(2n-2\) distinct real nodes and let \(B\) have Vandermonde rows
\((1,t_i,\ldots,t_i^{n-1})\), divided by one common constant so that
each row has norm at most one. Set \(W=e_n^\perp\), \(e=e_n\).
Let \(s>0\) be the minimum least singular value of an \(n\)-row
submatrix of \(B\), and \(c>0\) the corresponding minimum for all
\((n-1)\)-row submatrices restricted to \(W\). Both are positive by
the Vandermonde determinant. Put
\[
t=\sqrt{\sigma/2},\qquad
\gamma=\frac{4\sqrt n\,t}{sR},\qquad
A=B\,\operatorname{diag}(1,\ldots,1,\gamma).
\]
Assume \(\sigma\le s^2R^2/(8n)\), so \(0<\gamma\le1\) and the
rows of \(A\) have norm at most one.

For any possible observed vector \(h\), let \(F_h\) be the set of
ball inputs for which each true squared intensity differs from
\(h\) by at most \(\sigma\). Let \(x,y\in F_h\), and set
\(p=(x+y)/2,\ q=(x-y)/2\). For each row \(a_i\),
\[
4|\langle a_i,p\rangle\langle a_i,q\rangle|
 =\big|\langle a_i,x\rangle^2-\langle a_i,y\rangle^2\big|
 \le 2\sigma .
\]
Assign each row to a factor for which the absolute amplitude is
at most \(t\); such a factor exists, and ties can be assigned
arbitrarily.

* If either group contains at least \(n\) rows, the relevant factor
  \(z\in\{p,q\}\) satisfies \(\|z\|\le\sqrt n\,t/(\gamma s)\)
  by the lower singular value bound for an \(n\)-row block of \(A\).
  Hence \(d_\pm(x,y)\le2\|z\|\le R/2\).
* Otherwise each group has exactly \(n-1\) rows. For its associated
  factor \(z\), the restricted transverse block yields
  \[
  \|P_W z\|\le\frac{\sqrt{n-1}}{c}\,(t+\gamma|\langle z,e\rangle|).
  \]
  Here the last column of any selected block of \(B\) has norm at most
  \(\sqrt{n-1}\). Since \(\|p\|^2+\|q\|^2\le R^2\), both \(x,y\)
  have transverse norm at most \(D_n t\), where
  \[
  D_n=\frac{\sqrt{n-1}}c\left(2+\frac{4\sqrt{2n}}s\right).
  \]

For each nonempty feasible fiber, if it contains a signal with
transverse norm greater than \(D_n t\), output one such signal.
The dichotomy shows that its quotient distance to every member of
the fiber is at most \(R/2\). Otherwise output \((R/2)e\).
For every member \(x\) of that fiber,
\[
d_\pm(x,(R/2)e)^2
=\|P_Wx\|^2+\big(|\langle x,e\rangle|-R/2\big)^2
\le D_n^2t^2+R^2/4.
\]
Thus \(C_n=D_n^2/2\) works. The decoder is a feasible-fiber choice,
not claimed efficient or continuous. The rows may degenerate as
\(\sigma\to0\); this is not a stability guarantee for a single
fixed frame used at every noise level.

## Positive inner radius: upper bound

On a fixed annulus \(r\le\|x\|\le R\) with \(0<r<R\), replace \(R\) by
\(R-r\) in the definition of \(\gamma\), so the first case gives
distance at most \((R-r)/2\). The second case still gives transverse
norm at most \(D_{n,r/R}t\). For sufficiently small noise this is at
most \(r\). With \(b=\|P_Wx\|\), the last-coordinate magnitude belongs
to \([\sqrt{r^2-b^2},R]\), and \(r-\sqrt{r^2-b^2}\le b^2/r\).
Decoding a near-axis fiber to \(((R+r)/2)e\) then bounds its squared
error by \(b^2+((R-r)/2+b^2/r)^2\). This proves the upper excess is
\(O_{n,r/R}(\sigma/R)\) on each fixed positive-width annulus.
The following argument supplies a matching lower bound at a fixed positive inner radius.

## Matching lower on each fixed positive-width annulus

Fix \(0<r<R\), write \(w=R-r\), \(S=(R^2+r^2)/2\),
\(P_0=(R^2-r^2)/4\), and \(\eta=\sigma/R^2\).
Run the product-sphere collision proof of #997 with adaptive
**comparison radii**, not adaptive measurement rows: for unit
directions \(u,v\), let \(t=|\langle u,v\rangle|\), define
\(P=\min(S/2,P_0/t)\) (use \(S/2\) if \(t=0\)), and take
\(a\ge b>0\) with \(a^2+b^2=S\), \(ab=P\).
The ordered radii are continuous in \(t\) and invariant under
both sign flips, and \(x=au+bv,\ y=au-bv\) stay in the annulus.
The same test kills one of \(u,v\) at every actual common row.
After a sign change of a summand and possible swap of the two
candidate signals, take \(\langle u,v\rangle=t\ge0\).

* If \(1-t\ge\eta/8\), then \(P-P_0\ge P_0\eta/8\) for
  sufficiently small \(\eta\) at the fixed radius ratio. This
  holds in the capped case since \(S/2-P_0=r^2/2>0\).
  The derivative of \(b\mapsto b\sqrt{S-b^2}\) on the branch
  \(0\le b\le\sqrt{S/2}\) is at most \(R\).
  Since \(P_0\) corresponds to \(b=w/2\), the exact collision
  has quotient distance \(2b\ge w+P_0\eta/(4R)\).
* Otherwise, for sufficiently small \(\eta\), the cap is inactive:
  \(\|x\|=R,\ \|y\|=r\), and their angle \(\theta\) tends to zero
  as \(t\to1\). Every actual common row \(l\) annihilates one of
  \(u,v\), so \(|\langle l,y\rangle|\le R\|u-v\|\le\sqrt\sigma/2\).
  Rotate \(y\) away from \(x\) through \(\phi=\sqrt\sigma/(4r)\)
  at fixed radius \(r\), taking any rotation plane through \(x,y\)
  when they are parallel. Call the result \(y'\).
  The displacement is at most \(\sqrt\sigma/4\), so each
  intensity changes by at most \(5\sigma/16\) at the original
  common row. Replay the original common noisy transcript
  exactly, with zero error for \(x\) and compensating error for
  \(y'\), inductively keeping the same chosen rows. For small
  \(\eta\), \(\theta+\phi<\pi/2\) and \(\cos\theta\ge1/2\);
  the squared quotient distance increases by at least
  \(2Rr\cos\theta(1-\cos\phi)=\Omega_{r/R}(\sigma)\).
  The original distance is at least \(w\) and both distances
  are at most \(2R\), so the ordinary distance increases by
  \(\Omega_{r/R}(\sigma/R)\).

Thus the excess above \(w/2\) is also \(\Theta_{n,r/R}(\sigma/R)\)
on each fixed positive-width annulus. The constants and sufficient
noise threshold need not be uniform as \(r/R\) approaches zero or one.
This proof uses the product-sphere zero theorem on paper.

## Formalization handoff

The upper proof needs only square-difference algebra, finite row
partitioning, two finite singular-value estimates, and the midpoint
decoder inequality. The lower bound depends on #1009 and the
product-sphere collision in #997; a certificate of the upper bound
alone would not be a certificate of the sharp minimax law.
