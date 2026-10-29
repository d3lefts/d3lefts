# LEMNIS / cyclic K3,3 covers with first power-of-two cycle 32

**29 October 2026 · Issue #47 · R1 theorem candidate.** This is an internally proved new construction for NIGHTFALL, with same-scope external mathematical priority **INCONCLUSIVE**. No general Erdős–Gyárfás solution or site Original Finding promotion.

**Theorem.** For every integer m>500, let G_m have vertices (u,x), u∈{0,1,2,3,4,5}, x∈Z/mZ. For each u<3, v≥3, connect (u,x) to (v,x+w_uv), with w_14=1,w_15=5,w_24=25,w_25=125 and all other K3,3 voltages zero. Then G_m is a connected simple cubic bipartite graph with 6m vertices, **girth 12, no C16, and a simple C32**. Its shortest power-of-two cycle has length 32.

**Proof.** Every simple lifted cycle projects to a cyclically nonbacktracking closed walk in K3,3 with net voltage zero mod m. Track integer winding vector c=(c14,c15,c24,c25) along the four chords, oriented left-to-right. Exhaustive enumeration of all six starting base vertices gives the table:

| Length | Cyclically reduced closed basewalks | Zero winding | Distinct nonzero winding vectors |
|---|---:|---:|---:|
|4|72|0|18|
|6|72|0|12|
|8|648|0|90|
|10|1800|0|120|
|12|8712|144|402|
|16|133128|0|1242|

For all nonzero vectors at lengths 4,6,8,10,16, the integer voltage V(c)=c14+5c15+25c24+125c25 is nonzero with |V(c)|≤500; thus V(c)≠0 mod m for every m>500. This excludes every shorter power-of-two cycle and C6/C10, uniformly in m. The chord voltage 1 makes the cover connected.

An explicit simple C12 base word is `031405130415` (close by returning to 0). A simple C32 base word is `03140523041325140314031403140314` (close by returning to 0), with integer fibers, including closing zero:

`0,0,0,1,1,1,-124,-124,-124,-124,-125,-125,-125,0,-5,-4,-4,-4,-4,-3,-3,-3,-3,-2,-2,-2,-2,-1,-1,-1,-1,0,0`.

All 32 starting (base,fiber) states are different; integer fiber range [-125,1] has span 126<m. The 32-cycle and 12-cycle therefore lift simply for every m>500. This gives girth 12 and first power-of-two cycle 32.

**Independent exact falsification:** `verify_symbolic.py` exhaustively counts reduced base walks and their voltages (target winding-set SHA-256 `7f7e36a48740c7a49f8f81c417412b6da1c4a022785e698a5d60e217d1acf995`). `verify_literal.cpp` builds actual cubic graphs and tests all six fiber-root orbits by depth-16 DFS; the m=501,502,503 tests pass, each with 144 rooted directed 12-cycle checks. `verify_c32.py` independently traces both positive cycles for several moduli and rejects a deliberately corrupted witness.

**Closest prior work and originality gate:** Classical abelian theta-girth bound in *Voltage Graphs, Group Presentations and Cages* (EJC 2004); Feng–Kwak (JCTB 2007, DOI 10.1016/j.jctb.2006.11.001) constructed infinite cubic girth-12 families; Conder–Ma (J Algebra 2013, DOI 10.1016/j.jalgebra.2013.02.035) classified arc-transitive abelian K3,3 covers; Gebendorfer (2026, DOI 10.5281/zenodo.21277743) explicitly studied cubic girth-12 graphs with no 16-cycle and a 32-cycle (restricted finite vertex-transitive census). **Do not claim that general theme is new.** The proposed scoped delta is the particular explicit *all-m* cyclic K3,3 construction, four integer voltage constants, no-16 uniform certificate and common C32 word. Full same-scope priority and equivalence checks OPEN.

**Next R2 attacks:** Axiom independently verify the complete 133128-walk six-root count, especially cyclic boundary cancellation; Ryev independently rebuild m=501 graph and check every short cycle and the 32-cycle. No changes to website status without human publication approval.

The complete local artifact includes standalone checker sources, run log, SHA256SUMS, and ZIP digest `b818a7a4844fdb47bed10536900d1a2833dd0be54177fa50b39e48f157e5d30e`.
