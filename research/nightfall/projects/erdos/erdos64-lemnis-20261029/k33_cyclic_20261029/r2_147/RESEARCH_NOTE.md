# Lemnis R2 — 882-vertex cyclic K3,3 witness and quotient-family transfer

**Date:** 2026-10-29. **Parent:** issue #47, draft PR #57. **Evidence:** internally proved with exact Python transfer and separately coded literal C++ simple-cycle checks. **Scientific stage:** R2-internal; independent Axiom/Ryev mathematical audit, same-scope historical priority, and human publication approval OPEN. This is not a solution of Erdős–Gyárfás #64.

## Theorem (quantified)

For each positive integer `r`, put `m=147r`. Construct the graph `G_m` on `(u,x)`, `u=0,...,5`, `x in Z/mZ`, joining every left `u=0,1,2` to every right `v=3,4,5` via `(u,x)--(v,x+w_uv)`. The only nonzero weights are

```
(u,v) : (1,4) (1,5) (2,4) (2,5)
w_uv  :    1     5     17     64
```

Then `G_m` is a connected simple cubic bipartite graph with `6m` vertices and **girth exactly 12**, with **no 16-cycle** and with a **simple 32-cycle**. Hence its first cycle whose length is a power of two has length 32. In particular `G_147` has **882 vertices**, compared with the prior same-family 3,006-vertex certificate `G_501` using (1,5,25,125).

**Additional all-moduli tail:** the same assertion holds for every integer `m>=257` with these fixed new weights, independently of the condition `147|m`. The word and graph construction are unchanged. The threshold `m>=257` is sharp as an uninterrupted tail for this particular tuple: at `m=256`, literal DFS returns simple 16-cycles.

## Proof / certificate

1. The base is `K3,3`, so the cover is simple, bipartite, cubic; connectedness follows from the connected base and the fundamental-cycle voltage 1.
2. Every simple cycle in a regular cover projects to a cyclically nonbacktracking closed base walk of the same length whose net voltage vanishes modulo `m`.
3. The standalone **finite exact transfer-matrix** checker enumerates *all six roots and all three first edges*, forbids immediate backtracking and cyclic end backtracking, and finds the following closed walk counts and distinct residue counts modulo 147:

| length | total cyclic nonbacktracking rooted words | distinct residues | residue zero |
| ---: | ---: | ---: | ---: |
| 4 | 72 | 18 | absent |
| 6 | 72 | 12 | absent |
| 8 | 648 | 90 | absent |
| 10 | 1800 | 78 | absent |
| 16 | 133128 | 146 | absent |

4. If `m=147r`, net zero modulo `m` implies net zero modulo `147`; thus the preceding exclusions hold for **every r**, not merely for tested instances. For the all-moduli tail, independent integer winding enumeration has **no zero voltage** at lengths 4,6,8,10,16 and absolute voltage at most 256, so no modulus `m>=257` can annihilate one.
5. The explicit simple 12-cycle base word `031405130415` has total **integer voltage zero**, fiber range `[-5,1]` and distinct (base,fiber) states modulo 147. The explicit 32-cycle base word `03140523041325140314031403140314` has total **integer voltage zero**, fiber range `[-64,1]` and 32 distinct (base,fiber) states modulo 147. They close with simple lifted vertices for all multiples of 147 and for all m>=257. Consequently girth is exactly 12 and the first power-of-two cycle is 32.
6. Separate **literal C++ graph construction/DFS** checks cubicity, every simple cycle through translation-representative roots at lengths 4,6,8,10,12,14,16, and the full 32-vertex witness. Observed `m=147`: rooted counts `C4=0,C6=0,C8=0,C10=0,C12=144,C14=504,C16=0`; explicit C32 passes. The same verifier passes `m=168,257,294`; `m=256` has 8 rooted directed C16 walks (negative control). This is an internal distinct-code replay.

## Transfer operator

**Quotient-voltage preservation.** For any base graph B, regular voltage deck group A, epimorphism `pi:A -> Q`, and forbidden cycle-length set L, if the quotient-Q voltage graph admits no cyclically nonbacktracking closed base walk of length in L with identity voltage, then neither does the A-cover. A positive lifted cycle word in A remains simple when its image has distinct (base,quotient-fiber) states. This applies to any finite abelian deck group A with a quotient `Z/147Z` and voltages lifting the four values above, provided `w15=5*w14` in A and the voltages generate A for connectedness. Its C12 word is abelian-homology zero; its C32 word has winding `5*w14-w15=0`. Thus the construction extends beyond cyclic deck groups without new short-cycle enumeration. This is a general covering argument, not claimed historical novelty.

## Reproduction

```sh
python3 check_147.py
g++ -O3 -std=c++17 literal_audit.cpp -o /tmp/lemnis_147
/tmp/lemnis_147 147
/tmp/lemnis_147 256   # must find C16 and exit nonzero
/tmp/lemnis_147 257
/tmp/lemnis_147 294
```

- Independently run `check_147.py` and `literal_audit.cpp` rather than treating the same generator's assertions as an external referee.
- The modular walk-count checker uses an aggregated transfer matrix over voltage residues; the C++ path builds the actual `6m` vertices and tests simple paths.
- Verify the edge orientation and 32-cycle witness state list directly; mutate one weight / base digit as negative controls.
- The R1 `m>500` certificate remains historically preserved.

## Prior art and claim gate

The 2026-10-29 source check of Erdős problem #64 still shows the minimum-degree-3 question unresolved. Important nearby work: abelian theta girth bounds (EJC 2004), Feng–Kwak cubic girth-12 families (JCTB 2007), Conder–Ma on abelian covers of K3,3 (J Algebra 2013), and Gebendorfer's July 2026 study of girth-12 C16-free cubic graphs with C32. **An 882-vertex cubic graph of girth 12, C16-free, with C32 is not asserted to be the smallest known graph or a world-first.** This note strengthens the in-program explicit family, and its quotient proof is reusable. Establish same-scope originality before any public Original Finding claim.

**Request:** Axiom independently attack the all-root cyclic boundary counting and 32-word noncollision; Ryev independently construct G147 and test graph6/cycle spectrum with fresh code; Vesper audit source-equivalence and worldwide priority; owner retains release authority.
