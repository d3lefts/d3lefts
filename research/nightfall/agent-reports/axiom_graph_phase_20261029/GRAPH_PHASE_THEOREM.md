# AXIOM — exact support-connectivity criterion for finite-field phase recovery

**Research date:** 29 October 2026. **Self-assignment:** GitHub issue #119. **Research lead:** Devin J. Wright; derivation and independent internal checkers: Axiom (GPT-6). **Status:** mathematically self-contained restricted-model theorem + two exact implementations; independent human referee and same-scope publication-priority review OPEN.

## Model and complete theorem

Fix the field `F=F_25`, `K=F_5`, the phase group `mu_4=K^*` and any `theta in F\K`. Fix a simple undirected graph `G=(V,E)` on `V={1,...,k}`. Make the **nonadaptive, deterministic** measurements

* `x_i^4` for every vertex `i`,
* `(x_i+x_j)^4` and `(x_i+theta*x_j)^4` for every edge `{i,j}`, with one fixed ordering `i<j`.

They consist of `k+2|E|` known fourth-power linear measurements.

**Theorem 1 (exact iff).** For every unknown `x in F^k`, the fiber of this measurement map equals exactly its global `mu_4`-orbit **if and only if** the subgraph induced by the nonzero support of `x` is connected. Empty and one-vertex supports count as connected for this statement. If the nonzero induced subgraph has `c>=1` components, its measurement fiber equals precisely the `mu_4^c` independent-component orbit (of cardinality `4^c`); no additional ambiguity exists. For the all-zero input, the fiber is a singleton.

**Algorithm.** Choose a fourth root `r_i` for each positive observed coordinate fourth power, with `r_i=0` at a zero coordinate. On an edge joining two nonzero vertices, enumerate the four `eta in K^*` and select the unique value compatible with both edge observations for the trial pair `(r_i,eta*r_j)`. Starting with phase `1` at one active vertex, propagate edge ratios through the induced-support graph using BFS. Verify all original measurements. If the graph is disconnected, return the exact list of independent component-phase degrees of freedom instead of pretending recovery is unique. Fixed-field runtime `O(k+|E|)` arithmetic operations and measurements; memory `O(k+|E|)`.

**Proof of one-edge separation.** For any `z!=0`, consider the four candidate edge phase readings

`F_z(eta)=((1+eta*z)^4,(1+theta*eta*z)^4)` for `eta in K^*`.

If `w not in K`, equality `(1+eta*w)^4=(1+eta'*w)^4` forces `eta=eta'`: if both affine terms vanish, they have the same unique root; otherwise their quotient is some `lambda in K^*`, so `1+eta*w=lambda*(1+eta'*w)`, forcing `(eta-lambda*eta')*w=lambda-1`. Both coefficients lie in K, whence linear independence of `1,w` over K implies `lambda=1` and `eta=eta'`. Now at least one of `z` and `theta*z` is outside K, since `theta not in K`. Thus `F_z` is injective for every nonzero z. Factoring out the unknown first endpoint phase (whose fourth power is one) proves exactly one relative-phase solution for every active edge.

**Proof of iff and complete fiber.** A nonzero coordinate fourth power fixes the coordinate up to exactly four `K^*` phases. Each active edge fixes the quotient of its endpoint phases uniquely by the preceding lemma. Therefore all phases within an induced-support connected component agree up to one free common phase. Different components have no edges between active vertices; all inter-component edges are incident to zero coordinates, so their readings depend only on the individual coordinate fourth powers. Independent phase rotations on the components preserve every measurement, and no other assignments can preserve all edge constraints. This proves the exact `4^c` fiber and iff.

### Graph optimality within this exact measurement architecture

For fixed `k`, this architecture uniquely recovers every input with at most `t` zero coordinates iff deleting any `<=t` vertices from G leaves a connected graph whenever at least two vertices remain. Consequently:

1. **No zero coordinates, `k>=2`:** G must be connected; min edges `k-1` (a tree). **Exactly `3k-2` total readings**, achieved by any tree.
2. **At most one zero, `k>=3`:** G must be 2-vertex-connected; minimum edges `k` (min degree 2). A cycle attains **exactly `3k` readings**.
3. **At most two zeros, `k>=4`:** G must be 3-vertex-connected; minimum edges `ceil(3k/2)` (min degree 3). The explicit Harary `H_(3,k)` graph attains **exactly `k+2ceil(3k/2)` readings**: equal to `4k` for even k, `4k+1` for odd k.

**Direct 3-connectivity construction and proof.** Arrange k vertices cyclically and add the cycle edges. If k=2m is even, add `m` chords `{i,i+m}` for `0<=i<m`. If k=2m+1 is odd, add `m+1` chords `{i,i+m}` for `0<=i<=m`. Every vertex has a chord at cyclic distance `m=floor(k/2)`, and the graph has `ceil(3k/2)` edges. After deleting any two vertices, the original cycle either remains a path or splits into two paths. Take the shorter surviving path; it has at most `m-1` vertices. Every vertex in that path has a long chord to the longer surviving path: the shorter path and its two deleted boundary vertices form a cyclic interval with at most `m+1` vertices, whose internal cyclic distances are below `m`; hence a chord of cyclic distance `m` cannot terminate in the shorter path or either deleted boundary. Therefore at least one chord reconnects the pieces. Deletion of fewer vertices also retains connectivity. The lower bound `|E|>=ceil(3k/2)` follows from minimum degree at least 3: a vertex of degree at most 2 could be isolated by making its neighbors zero, leaving at least one other active coordinate when k>=4. This is the classical Harary minimum-edges theorem; the proof above is included for audit.

**Exact sharp falsifier.** The 3-vertex path `0--1--2` with `x=(1,0,1)` and `x'=(1,0,2)` gives identical measurements, while the vectors belong to distinct `mu_4` orbits. On a minimal 3-connected Harary graph, removing any edge reduces the degree of an endpoint to two; setting its two remaining neighbors to zero separates the active support and yields an exact ambiguity. The checker verifies all 151 such single-edge mutations for k=4..14.

### Extension fields

The same theorem works with `F=F_(p^r)` for any odd prime p and r>=2, using `(p-1)`-st powers, phase group `F_p^*`, and any `theta in F\F_p`. The pair proof uses only that `F_p^*` is the full group of `(p-1)`st roots of unity and the linear independence of `1,theta` over `F_p`. With fixed p and fixed extension degree, the decoder is linear-time in k+|E|; no claim of constant-time root finding when field parameters grow is made.

## Independent exact evidence and source files

* `verify_graph_phase.py`: independent integer-pair arithmetic `F5[u]/(u²−2)`, explicit BFS phase decoder, complete phase-fiber enumeration for k=2 (625 inputs), k=3 path (15,625) and k=3 complete graph (15,625); exhaustive support-deletion tests for k=4..14 and `t=0,1,2`; exact non-equivalent ambiguity fixture. Output `verify_graph_phase.log`.
* `verify_independent.py`: disjoint tuple arithmetic `F5[v]/(v²−3)` and direct collision-signature grouping rather than importing decoder A; same 31,875 small-dimensional inputs, 24 nonzero ratio classes and an independently implemented NetworkX vertex-connectivity check for k=4..14; all 151 single-edge deletions give explicit non-equivalent observation collisions. Output `verify_independent.log`.

**Mutation control:** In the first verifier, a missing zero-coordinate case was discovered before certification and fixed. In the second verifier, an unnecessarily quadratic-over-classes repeated collision scan caused a timeout and was replaced by direct cached signature classes. Neither failed run is counted as a mathematical PASS; final clean runs of both independent paths pass.

## Scope, prior art and credit

* Graph-based phase synchronization, polarization and graph-connectivity criteria are established background: Alexeev–Bandeira–Fickus–Mixon, *Phase Retrieval with Polarization*, SIAM J. Imaging Sci. (2014), DOI 10.1137/12089939X; Cheng–Daubechies–Dym–Lu, *Stable phase retrieval from locally stable and conditionally connected measurements*, Applied and Computational Harmonic Analysis 55 (2021), DOI 10.1016/j.acha.2021.07.001.
* Harary's sharp minimum-edge vertex-connected graphs are classical: Harary (1962), *The Maximum Connectivity of a Graph*, PNAS 48, 1142–1146; see https://mathworld.wolfram.com/HararyGraph.html.
* **Exact new scope relative to our internal corpus:** finite-field fourth-power edge-pair separation and the zero-pattern iff/measurement-edge sharpness. **Priority remains INCONCLUSIVE** until a serious direct same-observation-model literature review and independent mathematical refereeing. This is not a generic iid phase-retrieval optimality theorem and is not a solution of Erdős #156/#44/#329.
* Axiom adaptive protocol PR #37 uses adaptively selected rows and ≤2k−1 readings; the present graph protocol is **nonadaptive** and has explicit sparse-zero support assumptions. Axiom iid random design PR #16 has a stochastic all-signals guarantee and different performance measures. No unqualified head-to-head sample-count record claimed.

**Requested review:** Lemnis attack the field-pair separation and graph iff under zero-coordinate patterns; Ryev independently reproduce source with nonisomorphic graphs and mutation tests; Vesper checks prior art and claim status. Do not promote to Original Findings before these gates.