# Dossier 02 — Periodic forest-gauge obstruction

**Source:** \`NIGHTFALL_QCD_periodic_forest_no_go_20261027.md\` (2026-10-27). **Evidence:** self-contained exact counting proof and reported independent integer checks. **Originality audit:** open. **Continuum Yang–Mills:** unresolved.

## Exact four-dimensional theorem

Let \(\Lambda=(\mathbb Z/L\mathbb Z)^4\), \(L\ge3\), with its standard cubical cell structure. There are \(V=L^4\) vertices, \(4V\) edges, and \(6V\) plaquettes. Let \(F\) be an undirected forest of fixed edges with \(c=V-|F|\ge1\) components. Each plaquette \(p\) has \(r_p\) fixed edges, and \(n_j=\#\{p:r_p=j\}\). For every free edge \(e\), let \(d_F(e)\) count **distinct** other free edges sharing a plaquette with \(e\). Then
\[
\sum_{e\notin F}\big(d_F(e)-12\big)
=12c+2n_0+2n_3+6n_4
=12c+2(n_0+n_3)\ge12.
\]
The second equality uses \(n_4=0\): a fully fixed square is a cycle and conflicts with the forest assumption. Thus **at least one free edge has \(d_F(e)\ge13\)**. A forest on the four-torus cannot have maximum free-neighbor degree 12 under these definitions.

## Integer proof

Every plaquette with \(r\) fixed edges supplies \((4-r)(3-r)\) ordered pairs of distinct free edges. Since two edges share at most one elementary plaquette when \(L\ge3\),
\[
\sum_{e\notin F}d_F(e)=\sum_p(4-r_p)(3-r_p).
\]
Use \((4-r)(3-r)=10-4r+(r-1)(r-2)\). Every fixed edge lies in exactly six plaquettes, hence \(\sum_pr_p=6|F|\). The correction polynomial takes values \(2,0,0,2,6\) for \(r=0,1,2,3,4\). Therefore
\[
\sum_{e\notin F}d_F(e)=60V-24|F|+2n_0+2n_3+6n_4.
\]
Subtract \(12(4V-|F|)\) and substitute \(V-|F|=c\). This establishes the identity with exact integer combinatorics.

**Corollary:** requiring exactly one fixed edge per plaquette would force \(|F|=V\) by incidence counting, whereas a forest has \(|F|\le V-1\). Such a periodic forest cannot exist.

## Scope and limits

This result rules out transferring one specific **free-boundary** forest-gauge local-degree property unchanged to the **periodic** lattice. It neither contradicts the source authors' free-boundary theorem nor proves a physical mass gap. The distinction between pair-count degree, distinct-neighbor degree, periodic cell structure, and edge orientation is essential. In dimensions \(d\ge4\), the same count yields
\[
\sum_{e\notin F}[d_F(e)-4(d-1)]
=(d-1)[(d-4)V+4c]+2n_0+2n_3+6n_4.
\]

## Audit record

The original checkpoint reports 24 deterministic forest samples at \(L=3,4,5\). A separate newly written direct-adjacency checker, [\`verify_periodic_forest.py\`](verify_periodic_forest.py), was executed before publication on 2026-10-28: **32 integer tests passed** at \(d=4,5\), \(L=3,4\), and eight seeds per pair. This tests the implementation on finite inputs; universality follows from the proof above.

## Source comparison

Reference: D. Bhattacharjee and U. Bhattacharya, [forest-gauge research record](https://zenodo.org/records/23490028), version identified as 2026-10-20 in the manuscript. The source free-boundary assumptions need manuscript-level comparison. Dated prior-art search for this exact periodic defect identity remains open.
