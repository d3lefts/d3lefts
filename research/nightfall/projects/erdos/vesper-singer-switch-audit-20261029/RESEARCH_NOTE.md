# Vesper: a scoped exact obstruction for affine Singer block switching

**29 October 2026 — R1 internal finite certificate; global novelty, outside referee and scale-transfer theorem OPEN.** Research lead: Devin J. Wright; investigator: Vesper. Standing [#96](https://github.com/d3lefts/d3lefts/issues/96), Tessera handoff [#95](https://github.com/d3lefts/d3lefts/issues/95).

## Question and mathematical representation

Given one cyclic Singer difference set \(D\subset \mathbb{Z}_v\) with \(v=q^2+q+1\), \(|D|=q+1\), and every nonzero modular difference represented once, enumerate **every** affine source/cut pair
\[
 X_c=\{(d+c)\bmod v:d\in D\},\qquad
 Y_{u,e}=\{(ud+e)\bmod v:d\in D\},
\quad c,e\in\mathbb{Z}_v,\ u\in(\mathbb{Z}_v)^\times.
\]
Regard \(X,Y\) as **integer** sets in \([0,v-1]\). Put \(\Delta^+(X)=\{x_j-x_i:x_i<x_j\}\). The test concerns two separated full blocks \(X\cup(Y+L)\), where \(L=10v\), with optional deletions in either block.

**Elementary exact reduction:** each block is Sidon over integers. The AA/AB/BB pair-sum ranges are disjoint for \(L=10v\). An AB–AB collision exists iff \(\Delta^+(X)\cap\Delta^+(Y)\neq\varnothing\), with each shared positive difference yielding exactly one unordered 4-mark conflict. Deleting marks to remove these conflicts is an exact 4-uniform hitting-set instance. A deleted mark kills at most \(q\) conflicts, implying the simple necessary bound \(d\ge \lceil |\Delta^+(X)\cap\Delta^+(Y)|/q\rceil\), which need not be sharp.

## Exact finite findings

| q | v | Units | Affine cut pairs checked | Min full-block positive-difference overlap | Global minimum deleted marks to repair union |
|---|---|---|---|---|---|
| 5 | 31 | 30 | 28,830 | 4 | **2** |
| 7 | 57 | 36 | 116,964 | 10 | **3** |
| **Total** | | | **145,794** | | |

Here “global minimum” means **only within all affine multiplier/cut pairs of the one verified Singer source supplied for that q**, never arbitrary Singer difference sets, arbitrary inserted blocks, arbitrary scales, or asymptotic Sidon construction.

The initial source is produced from the trace-zero hyperplane of \(\mathbb{F}_{q^3}=\mathbb{F}_q[t]/(t^3+t+1)\) using a generated primitive element. Exact sources:
- q=5: \(D=\{12,16,18,21,28,29\}\), primitive element coordinates \((0,0,2)\).
- q=7: \(D=\{3,19,21,29,32,33,38,53\}\), primitive \((0,1,2)\).

Both source lists are independently tested to have every \(v-1\) nonzero modular difference represented exactly once. Exact minimum-overlap witnesses \((u,c,e)\):
- q=5: (3,13,8), overlap \(\{4,7,11,25\}\), exact minimum 2 deletions; resulting 10-mark integer Sidon set (before global +1 shift) \(\{3,10,11,25,29,310,312,323,335,340\}\).
- q=7: (2,25,51), overlap \(\{1,2,7,10,16,20,23,33,40,43\}\), exact minimum 3 deletions; resulting 13-mark Sidon set \(\{0,6,21,28,44,46,54,570,571,583,602,613,622\}\).

The separate *global minimal deletion* incidence-mask checker rules out one deletion for all 28,830 q5 pairs and two deletions for all 116,964 q7 pairs. The direct unordered-pair-sum checker, independently written without importing either enumeration, tests both exact optimal witnesses including diagonal sums. Add +1 to all marks for the positive-integer convention.

## Source-independent mean identity (elementary, do not claim originality)

For any cyclic perfect difference set \(D\) and any \(d\in\{1,\dots,v-1\}\), exactly \(v-d\) cyclic cuts contain \(d\) as a **positive integer** difference. Hence for two independently uniformly selected cuts of any two perfect difference sets:
\[
\mathbb E_{c,e}|\Delta^+(D+c)\cap\Delta^+(E+e)|
=\frac{1}{v^2}\sum_{d=1}^{v-1}(v-d)^2
=\frac{(v-1)(2v-1)}{6v}.
\]
The unit multiplier makes no difference to the mean. This follows directly from unique modular differences and elementary cyclic-arc counting. It is **not** a new Singer theorem, does not lower-bound the minimum across cuts, and does not establish an \(\Omega(q)\) universal deletion obstruction for all fields.

## Reproduction and falsifiers

Standard Python 3.12, no dependencies:

\`\`\`bash
cd research/nightfall/projects/erdos/vesper-singer-switch-audit-20261029
python3 test.py
python3 audit.py
python3 global_min.py
python3 independent.py
\`\`\`

- \`audit.py\` independently generates primitive-field Singer sources and performs all 145,794 **positive integer**, not merely modular, source-cut comparisons; checks exact cut-average identity.
- \`global_min.py\` uses an independently specified pair-incidence bitmask model; rules out every deletion set of cardinality below the claimed minimum.
- \`independent.py\` reconstructs finite Singer sources and enumerates literal unordered sums, including diagonals, to verify repaired witnesses.
- \`test.py\` locks all global counts and includes deliberately invalid additive triples as negative controls.
- Dedicated GitHub Actions workflow runs the independent tests.

**Strongest immediate falsifier:** an affine \((u,c,e)\) at q5 requiring fewer than 2 deletions, at q7 fewer than 3, a missed modular difference, or a literal repeated pair sum in either displayed repaired witness.

## Scope, prior art, transfer and next step

Classical foundation: Singer's cyclic perfect difference sets, Golomb-ruler/Sidon difference equivalence; see [Singer treatment](https://personal.ntu.edu.sg/bernhard/Publications/pub/Singer.pdf) and [MathWorld Sidon definitions](https://mathworld.wolfram.com/SidonSet.html). NIGHTFALL closest prior work includes [Tessera PR #115](https://github.com/d3lefts/d3lefts/pull/115) (fixed-source cut deletion barrier) and [Tessera #125](https://github.com/d3lefts/d3lefts/issues/125) (source-independent mean/covariance research). Finite exhaustive values above are not claimed to be original mathematics; dated **same-scope** priority is uncompleted.

**Transfer limit:** neither a finite q5/q7 nonzero overlap floor nor its global deletion optimum implies any uniform-in-q floor, growing-prefix closure, infinite sequence, or improved Erdős #44/#329 density coefficient.

**Next cheapest decisive test:** Tessera tests two **genuinely inequivalent** source families at q25 (not simply another cut/multiplier of one source), with an adversarial retained-prefix and second-generation repair. Seek a proof of an all-q cross-source collision-density obstruction; the alternative is an explicit low-loss source switch that breaks the extrapolation. Lemnis attacks the finite-to-uniform quantifiers and claim novelty; Ryev independently replays code and probes corruption. Axiom checks field arithmetic. No self-certified publication.
