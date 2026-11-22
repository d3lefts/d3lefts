# Phase retrieval as an explicit block decoder for Route 1

**NIGHTFALL scoped manuscript / proof passport candidate, 2026-11-22.**

**Status:** algebraic product-block reduction on paper; finite example exact
integer checker and independently written finite Lean goals; full formal
Route 1 composition in `PhaseBlockRoute1.lean` pending source-pinned CI.
The universal (T)-query quantum acceptance-polynomial reduction is the
**published external Beals–Buhrman–Cleve–Mosca–de Wolf (1998) method**, not
an original new theorem or Lean construction in this PR. Worldwide novelty,
a new published priority claim, independent specialist audit, and efficient
runtime overhead are **not** established.

## Objective and model: charge every real oracle query

Let (B\ge1) and (S\) be a finite set of hidden block symbols.
A block-local raw oracle has indices ((b,j)in[B]\times[J]) and
responses (Y_{b,j}=g_j(X_b)), where (X_1,\ldots,X_B) are
independent under a product law (\mu=\bigotimes_b\mu_b).

Suppose a specified deterministic exact decoder recovers any (X_b)
from **at most (c) queries to those original (Y_{b,j})**.
A classical policy over hidden symbols is implemented using at most (c)
physical original-oracle calls per new block, caching previously decoded
blocks. Its total query cost is at most (c n) if the logical policy
queries at most (n) blocks. No access to a free hidden-symbol oracle
is being presumed.

The target is a bounded (f:S^B\to[0,1]) with interaction degree
at most (d), or a fixed (T)-query circuit over the **same raw oracle**
whose acceptance probability, when restricted to the codebook, pulls
back to such an (f).

### General locality-preservation lemma

Suppose an arbitrary bounded raw-table observable admits a
finite interaction expansion
[
  P(y)=\sum_{\lambda} P_{\lambda}(y),
  \qquad P_{\lambda}	ext{ depends on a set }
    R_{\lambda}\subseteq[B]\times[J],\quad |R_{\lambda}|\le d.
]
Its hidden-block pullback is (f(x)=P(g(x))).
Each (P_{\lambda}\circ g) depends only on the blocks
(\pi_B(R_{\lambda})), and
[
   |\pi_B(R_{\lambda})|\le|R_{\lambda}|\le d.
]
Thus **block interaction degree cannot exceed raw-oracle interaction
degree**. The result is independent of (B) and of alphabet sizes.

For a fixed quantum **value oracle** with a finite encoded response
alphabet, the usual polynomial-method amplitude expansion gives a
real acceptance probability of raw-coordinate interaction degree
(d\le2T). This is an external theorem; it uses the complete
one-hot indicator family for value responses, not a possibly invalid
assumption that squared intensities are Boolean input bits. One oracle
query contributes at most one raw coordinate to each amplitude term,
and squaring amplitudes uses at most (2T) positions.
Since (g_j(X_b)) depends on exactly one block, the hidden pullback
has degree at most (2T).

**Important:** this proves a *distributional acceptance-probability
simulator* once Route 1 applies. It does NOT simulate every final
quantum state, jointly sample arbitrary quantum circuit outputs,
reproduce quantum oracle access coherently, or establish polynomial
classical running time. All circuit gates/measurement outcomes and the
acceptance function must have the usual input-independent semantics.

### The exact existing Route 1 theorem applied to decoded coordinates

Use merged `Nightfall.Route1Polylog.route1_wyner_general` from #970/#976.
With (d\ge\max(1,2T)), finite (S), product (\mu) so that
(C_W(\mu)=0), tolerance (\varepsilon>0), and
(\tau\in(0,1]), for any (s>0) and integer (n>0) there is a
deterministic decision tree on block symbols of depth at most (n) with
[
  \Pr_{X\sim\mu}\!
  \bigl[|f(X)-t(X)|>\varepsilon\bigr]
  \ \le \frac{\frac{\pi^2 d^2/2}{2\gamma(d,\tau)}
   +\frac{s}{\eta_C(d,\tau)^2 w_{0,C}(\pi^2 d^2/2,d,\tau)}}{n}
   +\frac{\tau}{\varepsilon^2}.
]
Here (\gamma,\eta_C,w_{0,C}) are *exactly* the definitions from the
merged Lean source. Choose (\tau\) small and (n) large as a
function of (d,\varepsilon,\delta) (with (s>0) arbitrarily small)
to achieve desired failure probability (\delta). Therefore the
raw-oracle query count is at most (c n), **independent of the number
of independent blocks (B)**.

For (T=0), the acceptance probability is constant and needs no
oracle queries; (d\ge1) is only the mathematical theorem's input.

The source Lean theorem in this PR proves the raw-support degree
pullback and invokes Route 1 on the actual supplied `\nu` with
explicit hypothesis `wynerGen \nu < s`. It does **not** formalize
Beals' quantum gate-to-polynomial derivation or (C_W(\mu)=0) for all
finite alphabets. Those must be identified as external/paper
composition steps, never misrepresented as a single source-closed
quantum terminal.

## Concrete eight-state phase-retrieval code

Represent distinct signals up to global sign by choosing (a>0):
[
  S=\{(a,sb):a,b\in\{1,3\},\ s\in\{-1,+1\}\}.
]
The **fixed four allowed** squared-linear readings are
[
  g(x)=(a^2,b^2,(a+sb)^2,(a-sb)^2).
]
Exactly three measurements, e.g. coordinates (0,1,2), decode
all 8 states. The first two fix (a,b); the third determines the
relative sign because (a,b>0). Direct enumeration shows *every*
three distinct readings decode.

A full decision-tree minimax enumeration over the same 4 permitted
rows establishes **three is necessary, even for adaptive
two-query strategies**. Each first measurement has a particular
positive-probability outcome such that no second permitted row
separates the remaining codewords. (Hard outcomes are respectively
(1,1,4,4).)

**Model-scope falsifier:** an additional real squared-linear
measurement ((a+4sb)^2) takes 8 distinct values and decodes the same
finite codebook in one query. Thus the three-query lower bound is
strictly a result about the fixed four-row oracle, **not unrestricted
real phase retrieval**.

## Large raw Wyner cost and zero decoded Wyner cost

Every two distinct four-reading codewords differ in at least two
positions (minimum Hamming distance exactly 2). Consequently its
support contains no distinct pair differing in only one raw coordinate
(an axis-adjacent pair).

**Support-rectangle lemma.** If a finite code (C\subseteq
\prod_{j\in J}A_j) has no axis-adjacent pair, every product probability
measure supported on (C) is a **point mass**. Otherwise choose a
coordinate with two distinct positive-support letters. Holding
positive-support letters on all other coordinates fixed yields two
distinct axis-adjacent points, contradiction.

The same condition holds for (C^B), with its (4B) raw reading
coordinates. For a uniformly chosen independent block symbol
(X_b\sim\mathrm{Unif}(8)), its raw encoded vector (Y_b=g(X_b))
is uniform on an injective eight-word code. Any (even
arbitrary-measurable-latent) conditional product-law representation
of the full (Y=(Y_1,\ldots,Y_B)) must have its conditional laws
point masses almost surely, hence
[
 C_W(Y_1^1,Y_1^2,Y_1^3,Y_1^4,\ldots,Y_B^4)
 = H(Y)=3B\ \text{bits}.
]
Here Wyner common information is over **the (4B) scalar reading
coordinates**. After decoding, the law of block symbols
((X_1,\ldots,X_B)) is a product law, hence
(C_W(X_1,\ldots,X_B)=0).

**Note:** these numbers are not obtained by an optimization routine;
their certificate is the support-rectangle entropy proof. The checker
verifies code structure for (B=1) and (B=2), and Lean verifies the
fixed finite separation facts; the all-(B) entropy statement
remains at paper level in this PR.

This does **not** prove every raw-oracle classical algorithm needs
(Ω(B)) queries. It only shows why naively charging Route 1's
Wyner-information parameter on a correlated raw-table representation
can give a (B)-dependent *upper bound*, while charging the independent
block representation avoids it after paying a genuine decoder cost.

## Scope, sign, and physical access traps

- Independent sign gauge: all readings (g_j(X_b)) are invariant
  under flipping the full original vector in block (b).
  Consequently a circuit with access **only** to these readings
  automatically respects each independent block-sign ambiguity.
- Cross-block relative-sign observables are *not* accessible from
  these local intensities. If the original oracle also exposes
  ⟨x_b,x_{b'}⟩ or an absolute phase reference, the raw position
  no longer depends on a single hidden block. That enlarged oracle
  requires a new locality analysis and possibly a separate learning
  cost. A free relative-sign oracle is not included in this theorem.
- Total functions versus promises: Route 1 applies to the bounded
  acceptance function extended to **all** block-symbol tuples.
  The codebook is the entire alphabet (S^B), not an unmodelled
  Boolean promise.
- Cache cost: a classical logical query consumes 3 fixed permitted
  original intensity readings on a fresh block. Repeated queries
  can reuse measured values, so total original cost is (\le3n),
  with no additive (3B) preprocessing assumption.
- The conclusion is about average-case absolute approximation of
  acceptance probability under the supplied product input law, not
  worst-case approximation on every possible input.
- Circuit *description/computation time* and oracle query complexity
  are separate; the theorem gives no efficient procedure for finding
  the tree or evaluating an arbitrary gigantic acceptance polynomial.
- The standard one-hot polynomial representation for finite-alphabet
  oracle values should be independently audited for the circuit's
  precise XOR, phase, and quantum response-register model.

## Primary sources and novelty boundary

- Beals, Buhrman, Cleve, Mosca, de Wolf, *Quantum Lower Bounds by
  Polynomials* (1998): https://arxiv.org/abs/quant-ph/9802049
- NIGHTFALL merged [#970](https://github.com/d3lefts/d3lefts/pull/970)
  and [#976](https://github.com/d3lefts/d3lefts/pull/976), exact
  Lean finite product/mixed/Wyner simulation.
- NIGHTFALL merged [#912](https://github.com/d3lefts/d3lefts/pull/912):
  coherent fetch/decode/uncompute for finite block oracles, but no
  complete gate/query-cost bridge.
- Turturean (Nov. 2026), *A proof of the Aaronson–Ambainis conjecture*,
  https://arxiv.org/abs/2611.09773, plus other 2026 distributional
  simulation work: independently check their scope before a priority
  claim. This construction is a reusable block-local application and
  not presently established as a novel global quantum simulation theorem.

## Independent checker and next certification gates

Run the exact finite checker:
```sh
python3 research/nightfall/structural_information/check_phase_block_route1_exact.py
```
It computes two-query impossibility via an independent minimax dynamic
program and direct outcome adversary; enumerates all triples, one- and
two-block no-axis-pair support, and falsifying extra-row/mutated-code
negative controls. All arithmetic is integral.

Lean modules:
- `PhaseBlockEight.lean`: exhaustive finite decoder / 2-query
  obstruction / axis-adjacent separation on exactly four rows.
- `PhaseBlockLocality.lean`: general raw-local term support projects
  to no more hidden blocks than original raw positions.
- `PhaseBlockRoute1.lean`: full source-level conditional composition
  with `route1_wyner_general`; it does not assume a free hidden oracle.

To upgrade the result: independently kernel-replay these declarations;
write a standalone Lean proof that finite product measures have
(C_W=0), the all-(B) support-rectangle entropy lemma, and (if
claiming a complete **quantum** theorem) the exact finite-alphabet
(T)-query polynomial representation. Obtain a dated source-specific
priority audit. Preserve original Beals / Aaronson–Ambainis / Route1
credit, plus user-reported construction.

**Significance threshold:** a provable model-class extension or
strict quantitative gain not covered by existing independent
product-law simulation, not merely a change of representation
that hides original oracle queries.
