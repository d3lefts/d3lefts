# NIGHTFALL: a periodic forest-gauge obstruction in 4D lattice Yang--Mills
Date: 2026-10-27. Label: **exact combinatorial theorem, independently integer-checked**. Originality and significance against the complete literature remain unconfirmed. Continuum Yang--Mills existence/mass gap remains open.

## Question
The October 2026 Bhattacharjee--Bhattacharya *Mass Gap of Four-Dimensional Lattice Yang--Mills Theory in a Forest Gauge* describes a **free-boundary** construction with one forest-gauge-fixed edge per plaquette, leaving each free edge interacting with 12 other free edges. Can a periodic four-dimensional cubical lattice use a forest with the same exact local geometry and the same degree-12 maximum?

### Definitions
Let \(\Lambda=(\mathbb Z/L\mathbb Z)^4\) for \(L\ge3\), with its standard directed coordinate links and plaquettes. Thus \(V=L^4\), \(E=4V\), \(P=6V\). Let \(F\subset E\) be any forest when orientations are forgotten (so its number of connected components, including isolated vertices, is \(c=V-|F|\ge1\)). The remaining links are free. For any plaquette \(p\), let \(r_p\in\{0,1,2,3,4\}\) count its fixed edges, and let \(n_j=\#\{p:r_p=j\}\). For each free link \(e\), let \(d_F(e)\) be the number of *distinct* other free links sharing a plaquette with \(e\). For \(L\ge3\), distinct links of this standard cubical cellulation share at most one plaquette.

## Theorem: periodic forest defect conservation
For every such forest,
\[
\boxed{\sum_{e\notin F}\big(d_F(e)-12\big)=12c+2n_0+2n_3+6n_4.}
\]
Moreover \(n_4=0\), since a fully fixed plaquette is a 4-cycle inside a forest. Consequently,
\[
\boxed{\sum_{e\notin F}\big(d_F(e)-12\big)=12c+2(n_0+n_3)\ge12.}
\]
In particular, \(\max_{e\notin F}d_F(e)\ge13\). Thus **no periodic four-dimensional forest gauge has at most 12 free plaquette-sharing partners at every free link**.

### Proof
Let \(q_p=4-r_p\) be the number of free edges in plaquette \(p\). Counting the unordered pairs of free links inside each plaquette in two ways yields
\[
\sum_{e\notin F}d_F(e)=\sum_p q_p(q_p-1).
\]
For integer \(r\in\{0,1,2,3,4\}\),
\[
(4-r)(3-r)=10-4r+(r-1)(r-2),
\]
where \((r-1)(r-2)=2,0,0,2,6\), respectively. There are \(6V\) plaquettes; each fixed link lies in exactly six plaquettes, hence \(\sum_p r_p=6|F|\). Therefore
\[
\sum_{e\notin F}d_F(e)=60V-24|F|+2n_0+2n_3+6n_4.
\]
Subtract \(12(4V-|F|)\), which gives \(12(V-|F|)+2n_0+2n_3+6n_4\). The forest identity \(V-|F|=c\) finishes the proof. QED.

## Corollary: no exact-one fixed-edge forest on a 4D torus
Suppose every plaquette has exactly one fixed edge. Double-counting incidences gives \(6V=6|F|\), hence \(|F|=V\). Any forest on \(V\) vertices has at most \(V-1\) edges. Contradiction.

This obstruction is independent of the gauge group and action. It applies to the proposed **geometry** on periodic four-dimensional lattices, not to the paper's explicitly stated free-boundary construction.

## Dimension-critical extension
On the \(d\)-dimensional periodic cubical lattice, \(E=dV\), \(P=\tfrac12 d(d-1)V\), and each link belongs to \(2(d-1)\) plaquettes. Let \(d_F(e)\) again count distinct other free links sharing a plaquette, with \(L\ge3\). Then
\[
\sum_{e\notin F}\left[d_F(e)-4(d-1)\right]
=(d-1)\big[(d-4)V+4c\big]+2n_0+2n_3+6n_4.
\]
For all \(d\ge4\), the right side is positive; hence some free link has more than \(4(d-1)\) neighbors. If exactly one fixed edge per plaquette, incidence counting forces \(|F|=dV/4\); this is incompatible with a forest for \(d\ge4\). The critical combinatorial dimension is four. This does **not** establish a relationship to the physical criticality of Yang--Mills coupling.

## Exact checker and falsification
Run:
```
python NIGHTFALL_QCD_forest_obstruction_checker_20261027.py
```
The checker independently (A) counts free-free plaquette pairs and (B) builds a free-link adjacency graph using sets. It constructs 24 deterministic random forests on periodic L=3,4,5 four-dimensional lattices, independently checks forest acyclicity via union-find during generation, tests pair uniqueness, verifies the exact defect identity and the existence of a link with degree >=13. Uses only integer arithmetic, no numerical tolerances. Passing finite tests is evidence of implementation consistency; the universal theorem rests on the counting proof.

## Scope, potential application, and next obligation
The bound on *maximal* degree is relevant to **supremum-based** Dobrushin and block-influence estimates: boundary-topology defects cannot simply be averaged away while continuing to use 12 as a global maximum on a periodic torus. The October 2026 forest-gauge preprint explicitly frames its principal SU(3) theorem with **free-boundary** states; the theorem above does not contradict that statement. A transfer to periodic volume needs a modified gauge, local defect correctors, or a gauge-invariant formulation. Whether one can retain the same exponential mixing constant is an unresolved analytic question.

No new mass-gap estimate, no continuum construction, and no QCD-specific inequality has been established. The combinatorial theorem has not been shown to be absent from prior literature and is therefore **not** labeled a novel contribution. No claim of competitive record.

## Relevant contemporaneous reference
D. Bhattacharjee and U. Bhattacharya, *Lattice Yang-Mills theory: spacing-uniform obstructions, the mass gap up to the Dobrushin ceiling and in a forest gauge, and Lean certificate*, Zenodo 10.5281/zenodo.23490028, v3.3.1 (2026-10-20), description of free-boundary and 12-partner forest construction. https://zenodo.org/records/23490028

Follow-up to check against original paper text: full bundle was not downloadable in this session. The Hexagon landing page for the forest-gauge title linked to a 29-page PDF whose title was instead *Mass Gap of Lattice Yang--Mills Theory up to the Dobrushin Ceiling*; that PDF does not establish the full forest-gauge assumptions.

## Handoff
Best result: periodic forest defect conservation identity, labeled an exact combinatorial theorem. Open hypothesis: periodic finite-volume bounds can be recovered with localized edge/plaquette defect correctors. Last decisive experiment: 24 integer-count tests all passed, including explicit degree excess up to 18. Next operator: construct a periodic near-forest with optimal defect support and test its maximal influence; maintain separate treatment of the physical continuum limit.
