# Route 1 with many targets and one shared latent charge

**Paper theorem, independently cross-checked.** The accompanying Lean
module checks the selected-task drift arithmetic and its telescoping
only. The vector-output decision tree and degree-specific composition
remain outside this module. This note builds directly on the merged
[Route 1 / Wyner theorem](https://github.com/d3lefts/d3lefts/pull/970);
no specialist priority claim.

## Theorem

Let \(X\) have a distribution on a finite product alphabet, with
Wyner common information \(C_W\). For \(i=1,\ldots,h\), let \(f_i\)
be globally \([0,1]\)-valued with interaction degree at most \(d_i\ge1\).
Choose \(0<\tau_i\le1,\ \varepsilon_i>0\). Write
\(K_i=\pi^2d_i^2/2\), and let \(a_i=2\gamma(d_i,\tau_i)\),
\(b_i=\eta(d_i,\tau_i)^2 w_0(K_i,d_i,\tau_i)>0\) be precisely
the constants in Route 1, with \(b=\min_i b_i\).
For every \(s>C_W\) and integer budget \(m\ge1\), one deterministic
original-coordinate decision tree with depth at most \(m\) outputs
a vector \(\widehat f\) such that
\[
\Pr\bigl[\exists i:\ |f_i(X)-\widehat f_i(X)|>\varepsilon_i\bigr]
 \le
 \frac{\sum_i K_i/a_i+s/b}{m}
 +\sum_i \tau_i/\varepsilon_i^2 .
\]
The product-mixture representation can equivalently be explicit,
replacing \(s\) by its actual mutual information \(I(\Theta;X)\).
In particular the same transcript supports post hoc selection of
any target in the predetermined family. The information term is
paid once, not once per target. This is an existence result, not
a bound on evaluation time, and it does not claim that dimension,
confidence or precision are free.

## Proof

Take any finite latent representation with product components
and mutual information below \(s\); #970 and #976 justify using
finite latents when taking the all-latent infimum. At a tree node
let \(A\) be the revealed coordinates, \(v\) the unnormalized
posterior masses, and \(g_i\) each target section after those
observations. Let \(\Phi(v,g_i)\) and \(\mathrm{Info}(A,v)\) be
the original unnormalized Route 1 potentials. Use
\[
 \Psi(A,v,(g_i))=\sum_i \frac{\Phi(v,g_i)}{a_i}+
                  \frac{\mathrm{Info}(A,v)}{b}.
\]
Each summand is nonnegative on the reachable states.
Stop and predict all posterior means when each target has
conditional variance at most \(\tau_i\). At any nonterminal node
with positive mass and unused coordinates, select one offending
target \(j\), and run its certified scalar good-query rule.
For that query, its private drop divided by \(a_j\), plus the
common information drop divided by \(b_j\), is at least the node
mass. For all other targets, private drops are nonnegative
by the scalar sum-of-increments identity \(\Phi_{\rm parent}
-\sum\Phi_{\rm child}\ge0\). The common information drop is
nonnegative by the exact conditional-information chain rule;
using \(b\le b_j\) does not reduce it. Thus the total drop in
\(\Psi\) is at least the node mass. This is the only new drift
argument; the independent Lean arithmetic module checks it.

Every query is charged to the original coordinates and does not
repeat an already revealed coordinate. If all are revealed, every
target is constant under the conditional law, so the rule really
stops (zero-mass nodes are arbitrary). Telescoping across the
tree gives
\(\mathbb E[\#\mathrm{queries}]\le\sum_i K_i/a_i+I(\Theta;X)/b\).
Truncate the same tree at depth \(m\); unresolved leaves have
total mass at most this expectation divided by \(m\).
Every other leaf has all posterior variances at most their
respective \(\tau_i\). Conditional Chebyshev and the union
bound give the second term. There is a single truncation and
a single charged information budget for the entire output vector.

## Sanity bound and scope

The private target cost is not removable. On \(h\) independent
fair bits (Wyner information zero), take \(f_i(X)=X_i\) and
\(\varepsilon_i<1/2\). A common tree of depth \(m<h\) must
predict at least \(h-m\) still-independent fair bits on every
leaf, so simultaneous success is at most \(2^{-(h-m)}\).
This is not a lower bound matching every coefficient in the
upper theorem. For several quantum circuits with a common
source and native whole-coordinate oracle, the standard
\(d_i\le2T_i\) acceptance-degree implication gives a common
classical query transcript for all those acceptance probabilities;
a physical-circuit Lean terminal for this multi-target claim
is not provided here.
