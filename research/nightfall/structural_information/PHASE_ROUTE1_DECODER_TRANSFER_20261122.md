# Exact phase retrieval as a paid, independent-block Route 1 oracle
**NIGHTFALL research note — 2026-11-22; v1.**

**Status:** finite decoder and adaptive two-reading obstruction under pinned Lean CI
(subject to exact-head receipt); an elementary all-block Wyner information proof
and a conditional paper-level transfer through the already merged Route 1
theorem; **no end-to-end Lean certificate for this composition** and no
new priority/novelty claim. Reproducibility script:
\`research/nightfall/structural_information/phase_route1_decode_exact.py\`.

## Objective and scope

The target is a **classical distributional simulator for the acceptance
probability or other bounded low-interaction-degree observable** of a
quantum query circuit on an intensity-only oracle. Unlike a nonadaptive
phase-retrieval *lower bound*, this is a constructive preprocessing:
a full block symbol is reconstructed from raw oracle outputs, and then
Route 1 operates on a product distribution of recovered blocks.

**CRITICAL MODEL:** Only the four named squared-linear forms per block
are permitted raw measurements. One may query a form at a chosen block,
and every such request counts as **one original oracle query**.
The finite codebook is known; blocks are independent. The output of each
raw form is an exact finite alphabet value; exact oracle encoding
and comparisons are assumed. Real-amplitude continuous noise, unknown
per-block codebooks, cross-block coherent field readings, and arbitrary
newly selected sensing vectors are *outside the theorem*.

## Completely explicit finite decoder and sharp local cost

Let S be the 8 distinct global-sign classes represented by

\[
x=(a,sb),\qquad a,b\in\{1,3\},\ s\in\{-1,1\}.
\]

All representatives have first coordinate positive, so no two are
global-sign equivalent. Let the four intensity symbols be

\[
y_0=u^2,\quad y_1=v^2,\quad
y_2=(u+v)^2,\quad y_3=(u-v)^2.
\]

The four frame rows are (1,0), (0,1), (1,1), (1,−1).
The exact table, in canonical signal order, is

| signal | y0 | y1 | y2 | y3 |
| --- | ---: | ---: | ---: | ---: |
| (1,−1) | 1 | 1 | 0 | 4 |
| (1,+1) | 1 | 1 | 4 | 0 |
| (1,−3) | 1 | 9 | 4 | 16 |
| (1,+3) | 1 | 9 | 16 | 4 |
| (3,−1) | 9 | 1 | 4 | 16 |
| (3,+1) | 9 | 1 | 16 | 4 |
| (3,−3) | 9 | 9 | 0 | 36 |
| (3,+3) | 9 | 9 | 36 | 0 |

**Theorem F1 (any three suffice):** For any omission from the four
readings, the remaining three determine (u²,v²,uv), hence xxᵀ and
therefore x modulo its global ± sign, **even for arbitrary x∈R²**.
The identities

\[
y_2+y_3=2(y_0+y_1),\quad
y_2-y_3=4uv
\]

show this directly. In particular the three fixed readings y0,y1,y2
recover every codeword, so the code has an exact three-query decoder.

**Theorem F2 (two adaptive queries are insufficient for this fixed
four-symbol measurement family):** Whatever the first reading j,
there is a single first output with >1 possible signals such that
*each* possible second reading k still collides on at least one pair.
The witness first outcomes for j=0,1,2,3 are respectively 1,1,4,4.
For j=0 and outcome 1, the candidate set is
(1,−1),(1,+1),(1,−3),(1,+3), and every possible next reading has
a collision. For j=1 use output 1; for j=2 or j=3 use output 4.
The exact checker enumerates all 544 deterministic policies whose
second row can be an arbitrary function of the observed first value
(including repeated measurements). None identifies all eight states.
Thus the worst-case exact deterministic depth is **exactly three**.

This does NOT lower-bound queries when the decoder can invent arbitrary
new real measurement rows: a generic row distinguishes any *finite*
list of pairwise nonequivalent real signals in one query. Nor does F2
hold for a fixed-unit-norm 2D codebook: one nonzero squared-linear
measurement on the unit circle has at most two projective candidates
per outcome, and a remaining separating row may be selected adaptively.

## The exact raw Wyner/common-information calculation

Take B independent blocks X_b, each uniform on S.
Let Y=(y_j(X_b): b∈[B], j∈{0,1,2,3}) be the **4B separately
addressed raw oracle coordinates**, and let Z=(X_1,...,X_B) be the
**B decoded block coordinates**. These are different choices
of product coordinate granularity.

**Theorem F3 (raw common information):**

\[
C_{\rm W}(Y_{1,0},\ldots,Y_{B,3})=3B\ \text{bits}.
\]

The raw alphabet support consists of 8^B valid codewords and the
map Z↦Y is injective, so H(Y)=3B. F1 implies every two distinct
valid single-block words differ in at least two of the four columns.
Consequently any two distinct global valid words differ in at least
two *raw* coordinates.

For a product distribution Q supported on this valid global code,
suppose two different words y,y' lie in the support of Q. Pick
one coordinate in which they differ. The Cartesian-product structure
forces the word obtained from y by changing **only that coordinate**
to the value at y' to have positive Q mass. But the valid code has
no one-coordinate neighbors: contradiction. Thus Q must be a point
mass. In **any** Wyner conditional-product representation of Y,
the conditional laws are point masses almost surely; therefore
Y is a deterministic function of W and I(Y;W)=H(Y)=3B.
The latent choice W=Y attains this cost. This holds for
arbitrary measurable latent labels with supplied conditional products,
not only finite latents.

For independent (not necessarily uniform) blocks, the same argument
gives C_W(Y)=∑_b H(X_b) provided the injective codebook is used.
The exact 3B count specifically assumes uniform 8-point blocks.

**Theorem F4 (after block regrouping):**

\[
C_{\rm W}(Z_1,\ldots,Z_B)=0,
\]

since the Z_b are themselves independent, with a one-component
product decomposition. This is **not** data processing of Wyner
information on a fixed set of coordinates. The coordinate
partition has changed: four correlated raw symbols become one
8-letter block symbol. Its cost must be accounted for by physical
decoding queries.

## Transfer theorem: paid decoding before Route 1

**Lemma T (oracle pullback):** Let B independent finite-alphabet
blocks Z_b. Suppose each virtual block query Z_b can be answered
by a deterministic zero-error decision tree of at most c actual
oracle queries that touch only block b, using a known blockwise
encoding. Suppose F:∏_b S_b→[0,1] is a bounded function of
interaction degree ≤d in the **block** coordinates. Then, for
ε,δ∈(0,1], there is a classical adaptive tree using

\[
\boxed{Q_{\rm raw}\le c\,N(d,\varepsilon,\delta)}
\]

raw oracle queries, where N is the product-source depth furnished
by the merged Route 1 theorem, with
Pr(|F(Z)−T(Z)|>ε)≤δ. N is independent of B, alphabet cardinalities,
and the raw within-block Wyner information.

**Proof:** Apply the *product* case of the merged Lean Route 1
\`route1_wyner_simulation\` with a single latent component,
for which mutInfo=0 (this is stronger than substituting s>0 in
the general Wyner theorem). Select Route 1 parameters τ≤δε²/2
and N large enough that its other error contribution is ≤δ/2.
Whenever the Route 1 tree requests coordinate b, execute the
exact c-query local decoder; cache the result. The sequence of
virtual block answers is exactly the correct Z for every legal input,
hence the distributional prediction error is unchanged and real
query count ≤cN. This is a PAPER composition argument: the
finite Route 1 theorem is kernel-checked upstream, but this
new physical-query implementation is not yet a named Lean theorem.

**Interaction-degree preservation:** If a function f on the
4B raw oracle coordinates is a sum of terms each depending on at
most d raw coordinates, its pullback F(Z)=f(Y(Z)) is a sum of terms
each depending on at most d **blocks**, because each raw reading
depends on exactly one block. Hence block interaction degree ≤d.

For the displayed code use c=3. This is a **classical** lazy
decoder; it is not a unitary quantum oracle implementation.

### Quantum circuit corollary (specified oracle model, conditional bridge)

For a T-query quantum circuit with a conventional finite-alphabet
indexed-symbol oracle (response encoding/reversible query convention
fixed), its acceptance probability is a bounded function with
interaction degree ≤2T in the **raw oracle coordinates**, by the
polynomial method (Beals–Buhrman–Cleve–Mosca–de Wolf, 1998/2001).
A finite response alphabet has coordinate-indicator variables,
each indexed oracle call contributing polynomial degree at most
one to the amplitude, and at most 2T to the acceptance probability.

Pulling back to the independent 8-letter blocks preserves that
interaction-degree bound; choose d=max(1,2T). A classical
simulator of the acceptance probability has raw query cost
at most

\[
3\,{\rm poly}(T,\varepsilon^{-1},\delta^{-1}),
\]

independent of B. This is **distributional** approximation under the
independent block source, not exact worst-case reconstruction of
all 8^B block variables. It does not claim a constant-query
simulation of the full quantum state or a way to execute the
original quantum oracle coherently by only three classical reads
when the circuit queries a superposition of indices.

**Symmetry restriction:** The quantum circuit's oracle symbols
must be functions of the sign-invariant intensities. An oracle
that directly exposes signed amplitudes, cross-block terms
\((u_b+u_{b'})^2\), or other relative-sign information is NOT
reconstructed by independent block-intensity decoders. Relative
signs or new cross-block correlations have to be modeled and
charged separately.

## Baseline comparison: what is and is not improved

An essential adversarial control is **trivial block grouping**. Since the
four raw readings of one signal are jointly independent of all other
blocks, the four-tuple itself can serve as one virtual product coordinate
without performing phase retrieval. A simulator can fetch the complete
four-tuple in **four** raw queries and already obtains a depth bound
independent of B. Thus the B-independent asymptotics of this *particular*
finite example are **not caused by the phase decoder**. The direct
contribution of phase retrieval here is the **sharp reduction from four
to three raw queries per simulated block request**, together with a
worked example exposing how the numerical value of Wyner CI depends on
which addressable variables are treated as separate product coordinates.

To seek a substantial rather than constant-factor gain, test growing
measurement families where the cost of reading an entire block is m
but a valid phase-retrieval decoder costs c≪m, under the **same permitted
query family**. Beware: adding an arbitrary generic fixed row to a
finite codebook can make a *one*-query decoder possible, invalidating
the two-query lower bound of the original four-row model. Continuous
signals allow a different measurement-complexity question but then the
finite-alphabet Route 1 theorem cannot be applied without a separately
justified measurable-alphabet or discretization bridge.

In particular, a statement like "C_W falls from 3B to 0, therefore
simulation becomes B-independent" is insufficient by itself: a fair
comparison must permit the baseline to group the same physical
addresses and account for its four-query per-block cost.

## Cheapest decisive tests and independent critique

- Source-level exact Python checker uses direct squared dot products,
  four independent exact sufficient-statistic inverses, exhaustive
  enumeration of all 544 adaptive two-reading policies, no
  one-coordinate code-support neighbors, and B=1,2,3 raw support tests.
- Separate Lean module \`PhaseRoute1Finite.lean\` states the actual
  integer squared-linear oracle and three finite theorems: any-three
  injectivity; per-first-reading adversarial two-query witness; and
  no valid one-coordinate flip. **Only an exact-head pinned CI
  success and #print axioms may promote these finite lemmas.**
- Independently attack the raw Wyner proof's product-support
  rectangle step, arbitrary-latent conditional laws, and the
  distinction between 4B original coordinates versus B grouped
  coordinates. A finite test cannot certify the all-B information
  identity.
- Independently check the interaction-degree preservation at the
  actual circuit/oracle encoding. The q→2q polynomial argument
  requires a genuine indexed finite-symbol query model, not
  arbitrary phase-sensitive sensing.
- Build a separate formal lemma implementing a DTree block
  query by a c-depth raw DTree, with an exact transcript and cost
  statement; then compose with already certified Route 1
  \`route1_wyner_simulation\`. No terminal Lean claim before
  that bridge is checked.

## Novelty, prior-art and significance

**Classical ingredients:** Balan–Casazza–Edidin (2006) real-frame
phase retrieval and complement property;
Beals–Buhrman–Cleve–Mosca–de Wolf (1998/2001) quantum query
polynomial degree; Wyner's common information and its conditional
product-law definition. Route 1 itself is NIGHTFALL's
already merged, kernel-checked #970/#976 work.

The explicit decoder-first *application* is a useful compositional
example of cost-aware representation choice and an exact boundary
for raw Wyner-CI as a coordinate-dependent simulation resource.
This note does **not** assert it is a new worldwide theorem, a
quantum speedup, or a new general quantum simulation result beyond
the already published/certified ingredients. A dated specialist
priority check and an independent non-author mathematical audit
remain open.

**Discovery graph:** raw intensity readings → exact local
phase decoder (3 real calls) → independent block alphabet →
product-source Route 1 (zero Wyner cost) → c·N real queries →
bounded-degree quantum acceptance, conditional on oracle model.

**Reproducibility:** Run
\`python3 research/nightfall/structural_information/phase_route1_decode_exact.py\`.
Proof status must travel with source commit, exact checker, Lean CI
receipt, limits, authorship and future independent audits.
