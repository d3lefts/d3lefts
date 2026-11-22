# Correlated hidden phase blocks: linear raw Wyner cost, ≤1-bit decoded Wyner charge

**NIGHTFALL exact constructive transfer, 2026-11-22.** This extends the
independent-block phase/Route1 application in parallel #1084, and
is paired with the stacked conditional Lean source theorem in #1105.
**Status:** mathematical proof using the classical product-support
rectangle argument and the merged Route1 general-Wyner theorem; finite
rational source checker for B≤3; correlated physical quantum terminal
Lean proof is **pending an exact-head kernel receipt**.
No new general Wyner theory or independent novelty claim.

## A concrete genuinely correlated law

Use **exactly** the eight original phase states, four original sensor
vectors and 26-symbol oracle of #1084, already source-certified at
finite scope in merged #1087. Let hidden symbol Z_b be an index in Fin 8.

Take a *single shared fair latent bit* W∈{0,1}.
Conditioned on W=w, draw all B symbols independently with

  P(Z_b=i | W=w) =
    3/16  if floor(i/4)=w,
    1/16  if floor(i/4)≠w.

Each conditional law has total probability 4·(3/16)+4·(1/16)=1.
Unconditionally each of the eight letters has mass
(1/2)(3/16+1/16)=1/8.

The blocks are **not independent** for B≥2. Let E_b be the event
Z_b∈{0,1,2,3}. Then P(E_b)=1/2 while
P(E_1∩E_2)=(1/2)((3/4)²+(1/4)²)=5/16>1/4.
Thus this is a concrete correlated—not merely regrouped product—source.

**Decoded common information.** W renders all B hidden letters
conditionally independent, so by Wyner's definition
C_W(Z_1,...,Z_B)≤I(W;Z_1,...,Z_B)≤H(W)=1 bit
(or ≤ln 2 in nats). The merged Lean Route1 Wyner theorem requires
any s above C_W, so its information charge remains bounded
independently of B. Source formalization #1105 explicitly uses
`wynerGen ν < s`, without assuming hidden independence.

**Raw common information.** Write Y_{b,j} for the genuine four
squared-linear intensities from the original four sensors. The
eight-word code has Hamming distance at least two, proved in finite
Lean by #1087 (and a general support-rectangle result is in open
#1084). The full valid raw support, across its 4B scalar sensor
coordinates, has no pair differing in only one coordinate.

For any latent L under which all 4B raw coordinate variables
are independent, each conditional product distribution supported
on the valid code must be a point mass: if one coordinate could vary
while others are fixed, the Cartesian support would contain a
forbidden axis-adjacent pair. This holds almost surely also for
arbitrary measurable L. Hence H(Y|L)=0 and
C_W(Y)=I(Y;L)=H(Y). Since the joint code is injective, H(Y)=H(Z).

The exact conditional entropy of each block given W is

  H(Z_b|W) = 2 + h₂(1/4),
  h₂(p)=−p log₂p−(1−p)log₂(1−p).

By the entropy chain rule for W and conditional independence,

  B(2+h₂(1/4)) ≤ C_W(Y) = H(Z)
                       ≤ B(2+h₂(1/4))+1.

Since h₂(1/4)≈0.811278, raw C_W is at least
2.811278 B bits, while decoded C_W≤1 bit.

**This proves an information-charge separation on genuinely
correlated sources**, rather than just B-independent product inputs.
It is still NOT a lower bound on all algorithms accessing the raw
oracle: direct grouping into whole four-row blocks can also exploit
the bounded hidden common information at cost at most 4 readings,
while the sharp phase decoder reduces that to 3 in this fixed oracle.

## Actual physical query bound and Lean dependency

The source-connected quantum model of #1084 supplies a recursive
finite complex matrix-oracle `Circuit (B×Fin4) (Fin26) κ T` whose
address query reads one genuine raw sensor coordinate. The existing
merged `QuantumCircuitSimulation.acceptance_degree` and #1084's
`PhaseBlockGrouping.grouped_degree` prove degree ≤2T of the
decoded-symbol acceptance function.

Stacked #1105 adds
`normalized_wyner_phase_block_route1_simulation`, which uses
`QuantumCircuitNormalization.WellFormed c` to derive [0,1] Born
acceptance from unitary gates (not assume it), invokes the exact
merged `route1_wyner_general` on the correlated decoded law with
explicit `wynerGen ν < s`, and physically compiles its DTree into
3 original sensor accesses per logical query, for ≤3n raw queries.
The same Route1 distributional error bound applies.

The *explicit* verification that this particular correlated family has
`wynerGen ν ≤ ln 2` is a standard entropy proof at paper level,
not a Lean declaration here. Neither this theorem nor the source
claims efficient classical **running time** or coherent **state**
simulation. General large alphabets, noise, phase references and
nonlocal cross-block sensor readings remain outside the model.

## Exact independent test and audit

`check_phase_wyner_correlated.py` enumerates B=1,2,3 distributions
using Python `fractions.Fraction`, validates every mass and the
pairwise correlation 5/16>1/4; uses the original #1084 integer phase
sensor model, checks decoder triples and no coordinate-edge support
for the finite products. It prints floating-point entropies solely
for readability, not as a numerical Wyner optimizer or a certificate
of the all-B theorem.

**References / credit:** User's phase-retrieval decoder proposal;
parallel exact and source-normalized circuit work #1084/#1087;
merged Route1 and Wyner lean theorems #970/#976; Beals et al.
(1998) polynomial method. This correlated extension follows the
existing general Wyner theory; dated specialist prior-art audit and
independent semantic review are open. Do not label it a world-first
quantum simulation breakthrough.

**Gates:** all-B information formula paper proof; finite rational
checker; pinned Lean terminal on #1105; independent proof review;
dated priority search. Never collapse those statuses.
