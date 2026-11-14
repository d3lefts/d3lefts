# Q2 hard-ownership reduction (provisional integration mechanism)

**Date:** 2026-11-14. **Scope:** finite original product sources.  
**Status:** mathematical reduction, not current-pin Lean certification,
not a terminal Q2 theorem, not an originality claim.

## Objective

Replace the fractional square-root owner weights in the Q2 analytic
source proof with 0–1 ownership, while preserving the source exact
energy partition, the per-owner uniform increment bound, and the
soft-refresh conditional projection.

## Representation and exact argument

Let a finite simple graph have symmetric edge amplitudes
$w_{ij}=w_{ji}\ge0$, nonnegative endpoint costs $c_i\ge0$,
and suppose $w_{ij}\le\max(c_i,c_j)$ for every edge.
Fix an arbitrary total order on vertex labels.

Define $o(i,j)=1$ if $c_i>c_j$, or if $c_i=c_j$ and
$i<j$; otherwise $o(i,j)=0$ for $i\ne j$.
(The diagonal is set to zero.)

For all distinct vertices:

1. Exactly one owner:
   `o(i,j)+o(j,i)=1`, hence also
   `o(i,j)^2+o(j,i)^2=1`.
   Proof: strict trichotomy for $c_i,c_j$, with label order
   breaking equality.
2. Owned amplitude:
   `o(i,j) * w(i,j) <= c(i)`.
   If `o(i,j)=0` this follows from $c_i\ge0$; otherwise
   $c_i\ge c_j$ and $w_{ij}\le\max(c_i,c_j)=c_i$.

Let $h_i,h_{ij}$ be the **actual** centered Hoeffding tables of the
same function $f$, and $e_{ij}=\mathbb E h_{ij}^2$.
Set
$
H_i(a,X_{-i})=\sum_{j\ne i}o(i,j)h_{ij}(a,X_j),\qquad
s_i=\mathbb E\|H_i\|^2.
$
Independence/centering of different actual neighbor coordinates yields
$s_i=\sum_{j\ne i}o(i,j)e_{ij}\le I_i$, and summing over
owners gives exactly $\sum_i s_i=\sum_{\{i,j\}}e_{ij}$.
No independence across owners is asserted.

For each owner $i$, choose source coordinate-retention
$r^{(i)}_i=1$, $r^{(i)}_j=o(i,j)$ for $j\ne i$.
This is now a **deterministic source conditional expectation**:
retain owned neighbors and refresh the rest from the true product law.
The existing centered source-star eigenaction gives
$Q_{r^{(i)}}U_i=h_i+H_i$.
$L^1$ contraction and the triangle inequality yield
$z_i=\mathbb E\|H_i\|\le u_i+a_i$.

Each independent owned-neighbor increment has Hilbert norm
at most $o(i,j)w_{ij}\le c_i$.
The existing independent-vector fourth-moment argument applies with
second-moment sum $s_i$, giving
$s_i\le z_i(c_i+\sqrt{3M})$, $M=\max_i I_i$.

Therefore **if** the genuinely source-derived 8B section budget,
8B greedy cover, variance Parseval, and the correctly integrated
distinct-neighbor fourth moment are all formally connected, this
hard-owner representation supports the *same* weak scalar endpoint
$V^2\le256(1+\sqrt3)^2B^2M$ without any square-root
division by endpoint costs. The sharper additive budget may likewise
be supplied from the original source, not as a hypothesis.

## Why this could reduce Lean proof cost

- No `Real.sqrt (c_i^2+c_j^2)` denominator, split on zero denominator,
  or fractional-weight square calculation.
- The owner partition is a decidable case distinction on endpoint cost
  and label order.
- The owner-specific noise mask takes values only in `{0,1}`;
  it can be presented as an actual conditional projection.
- The source-neighbor sample law already treats distinct site labels.
  Non-owned neighbor increments can be set to zero.

## Independent executable falsification

Exhaustive enumeration of all cost vectors in `{0,1,2}^n` for
`2<=n<=6`, testing each unordered edge, passed the exact Boolean
owner-complement and greater-endpoint properties in Python integer
arithmetic on 2026-11-14. This does **not** prove the analytic
reduction or certify any Lean declaration.

## Unclosed proof obligations

1. Port the hard-owner partition and owned amplitude lemma to the
   pinned Lean version with standard axioms only.
2. Construct actual-source owner stars and bridge their exact energies
   to the canonical Efron–Stein pair table (including zero-mass atoms).
3. Transport the existing actual-prefix Hilbert moment endpoint to
   owner-selected increments with no supplied moment budget.
4. Prove source soft-refresh contraction for the owned masks, and
   compose the source (8B) section budget with Jensen.
5. Compile one source-only terminal `Var^2 <= C B^2 max_i I_i`
   declaration and independently audit it. Until then, do not
   mark full Q2 formally certified.
