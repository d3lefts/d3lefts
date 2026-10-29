# Ryev 2026-10-29 — global Q7 face-first and independent Blossom audit

**Research owner:** Devin J. Wright. **Status:** exact mathematical reduction and internally checked FPT-exponent tightening; global Q7 remains unresolved. Independent mathematical/priority review pending. Primary [#48](https://github.com/d3lefts/d3lefts/issues/48); independent verifier [#108](https://github.com/d3lefts/d3lefts/issues/108); systems [#30](https://github.com/d3lefts/d3lefts/issues/30).

## Q7: symmetry-safe global 305 model

Build all 128 vertices, 448 edges and 672 distinct coordinate squares independently. Every 305-edge C4-free Q7 must satisfy 672 square constraints `sum(x_e in square)<=3` and `sum x_e=305`. Conversely any integral solution is an actual 305-edge witness. Exact 305 is sufficient for deciding whether f(7)>=305, since a larger C4-free graph can lose edges.

Add **all** 14 Q6 face bounds <=132 and all 84 Q5 face bounds <=56 (imported established exact results; OEIS A245762). Permute coordinate axes to sort seven directional edge counts `d0>=...>=d6`. Since they sum to 305, `d6<=43`; the two Q6 faces perpendicular to axis6 sum to at least 262. Each has at most132, so after reflecting axis6 the 0-face has >=131 and the 1-face >=130. This normalization covers **every** potential 305-edge graph; it does not assume any 132-edge face or published 304 seed. The generator emits a reproducible exact OPB for a proof-producing PB solver. No solver proof is yet available.

**Exact full artifact:** `NIGHTFALL_Ryev_GlobalQ7_Blossom_20261029.zip` SHA256 `edfa788fa5c0081d4a650910139db7e0c2e4318f271096492136d611941f62d9` (originating session). Generated enhanced OPB SHA256 `79f2e4f6468c0b7babb570eeed08ea8c2ac21a6c651596adfd62f74e9d89d774` (448 vars, 782 scalar inequalities); base OPB SHA256 `f45010f50854b1efe462aea40765a8db518424eceeffefdc74c75fdd9509aedc` (674 inequalities). 304 seed exact edge-list SHA256 `b47c7bba3cf07ea8db4b424c1d96e46957049656111ae035166edb19d4739655`.

**Measured:** SciPy 1.17 HiGHS 12.005s base and 15.067s enhanced, both **TIME LIMIT with no incumbent**. A longer first enhanced run was terminated by outer wall-time and is discarded. No UNSAT, no 305 witness, no global improvement: **304<=f(7)<=308 unchanged**. Seed 304 passes all 672 square checks and independent common-neighbor C4 test. No local-depth-five or 180-seed inference is used. External benchmark: Minamoto 2026 revised repo, OEIS A245762 (27 Oct 2026).

## Independent Blossom and stronger Vesper #108 bound

Separate self-contained Edmonds Blossom (alternating forest, odd-cycle contraction, augmenting path) versus Vesper's exponential bitmask matching. Independent *literal sum-pair* collision support generator, general-graph matching and protected deletion. **925** general graphs n=2..38 match NetworkX independent Blossom; **635** small Sidon cases have exact brute-force deletion optimum (9 high-incidence, 202 exceptional), SHA256 test rows `aaa5fdd8b2a7e6690142c0e261e1c9e383b9cf37f7ccba2520dda1ab40efbacc`. Further **266** k=4..6 held-out cases in Z37/Z53/Z67/Z2^3xZ3/Z3xZ4xZ3 all match brute force, 19 high-incidence, max high core 5. Tests include torsion, protected marks, diagonal sums, intrinsic E failure. Internal independent audit, not external refereeing.

**Exact improvement to Vesper's FPT exponent:** in a (2,1) collision `a+b=c+z`, a,b,c in E, z in D, `c=a` or `c=b` would force `z=b` or `z=a`, contradicting disjoint D,E. For distinct unordered (a,b), only k−2 choices of c; for diagonal (a,a), only k−1. Thus at most `C(k,2)(k−2)+k(k−1)=k²(k−1)/2` (2,1) candidates, improving the earlier `k*C(k+1,2)` by k². Add (1,1) <=2C(k,2) and (2,0) <=2C(k+1,2) support marks: `|B0| <= (k³+3k²)/2`, **not** the looser `(k³+5k²)/2`. The same correct core-branch/matching algorithm therefore has runtime `2^[c+(k³+3k²)/2] poly(|D|+k)`, a **k²-bit theoretical branch-bound improvement**. Valid in all abelian groups; no observed speedup or global Sidon density claim. Exact combinatorial control k=1..99 passes. Please request Lemnis to challenge this new count and Vesper to incorporate after independent proof review.

## Gate C

Evidence Bridge merged; Gate C has **zero genuine provider-metered matched pairs and zero blinded independent grades**. No synthetic success promoted; no site status or owner release gate altered.

**Next:** a proof-producing OPB/SAT engine plus independently checkable VeriPB/DRAT/LRAT proof; exact branch coverage for canonical Q6 face count pairs. A time-limited MILP output never proves UNSAT.