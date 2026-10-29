# LEMNIS — Dimension-uniform twisted-voltage girth-14 theorem candidate

**2026-10-29 | Research owner Devin J. Wright | Investigator Lemnis | parent #47, earlier finite #194 | R1 / OF-C only.** Internal exact source and two different verification representations; independent nonauthor mathematical review, complete same-scope priority, external referee, and human publication authorization remain OPEN. **Not an Erdős–Gyárfás #64 solution:** all graphs contain a simple C32.

## Objective, reference, falsifier and budget

Replace the finite d=2,3 semidirect label classification (#194) with a parameter-uniform operator. Feasible class: regular K3,3 covers with primitive action of GF(2^d)^+ ⋊ Z_m and cyclic chord voltages (1,5,17,64). Best verified in-program baseline: d2/d3 girth-14 and C32, 24/224 finite successful auxiliary label chambers; direct-product and cyclic results are separate. Closest dated comparators checked October 29: Daniel Garcia, September 2026 [arXiv:2609.04686](https://arxiv.org/abs/2609.04686), Gebendorfer 2026 girth-six dyadic-cycle studies, and Deng–Li–Wang–Yu September 2026 [arXiv:2609.27613](https://arxiv.org/abs/2609.27613) on regular covers. Exact family novelty remains unestablished. Cheap decisive test: enumerate all 144 cyclic-neutral reduced C12 words as Laurent forms, then independently traverse actual finite-field voltages in GF256 and GF512. Stop on any identically zero C12 polynomial, failed primitive root selection, vertex collision, or negative control.

## Theorem candidate (for every integer d≥8)

For every d≥8, there exists a primitive element α∈F=GF(2^d) such that a regular voltage lift of K3,3 is connected, cubic, bipartite, has **girth exactly 14**, has no simple C4,C8,C16, and has a **simple C32**. Let m=lcm(147,2^d−1) and G=F^+ ⋊_α Z_m with multiplication (z,u)(z',u')=(z+z',u+α^z u'). Assign zero to the five tree edges; the four left-to-right cotree voltages are

| Edge | Cyclic | Auxiliary |
|---|---:|---|
| 1→4 | 1 | 0 |
| 1→5 | 5 | b=α^(-59)+α^(-58) |
| 2→4 | 17 | 1 |
| 2→5 | 64 | 1 |

The graph has **6m2^d vertices**. At d=8, primitive polynomial 0x11d with α=X gives b=69 and 19,192,320 vertices. At d=9, polynomial 0x211 gives b=84 and 32,965,632 vertices. No smallest-order/record/novelty claim.

## Proof: six-polynomial obstruction and root avoidance

**Quotient exclusion.** The deck quotient G→Z_147 retains chord voltages (1,5,17,64). Complete six-root cyclically nonbacktracking closed base-walk enumeration yields **zero** quotient-neutral walks of lengths 4,6,8,10,16; exactly **144** of length12 and **504** of length14. Therefore all simple cycles of the excluded lengths are impossible, regardless of auxiliary labels.

**Twisted holonomy.** A forward cotree traversal with cyclic prefix s and field label a contributes α^s a; a reverse traversal with signed cyclic voltage −w contributes α^(s−w) a. For the displayed b, the 144 quotient-neutral length12 words give exactly six nonzero normalized Laurent polynomials, **24 words each**:

1. P1=1+X²
2. P2=1+X
3. P3=1+X+X^59+X^65
4. P4=1+X^47
5. P5=1+X+X^47+X^48
6. P6=1+X+X^17+X^59

The normalization removes only an invertible monomial factor X^k, so zeros in F* are preserved. This is a finite combinatorial lemma, reconstructed exactly in the checker, not an assumed table from #194.

**Primitive root existence.** The total degrees of these six polynomials equal **222**. At most 222 nonzero field elements are roots of their product. For d=9,…,15 the exact values of φ(2^d−1) are 432,600,1936,1728,8190,10584,27000. For d≥16, n=2^d−1 is odd and φ(n)≥√n>222, by the prime-power inequality φ(p^a)^2≥p^a for odd p. Hence for every d≥9 some primitive α avoids all six polynomials. For d=8, α=X in GF2[X]/(X^8+X^4+X³+X²+1) has order255; the six polynomial values in integer field encoding are **5,3,111,34,102,73**, all nonzero. Thus C12 is excluded for every chosen field.

**Positive simple cycles.** Base words `03140524130425` (14 steps) and `03140523041325140314031403140314` (32 steps) have zero **integer** cyclic voltage and identically zero auxiliary Laurent holonomy for these labels. Their 14/32 states (base vertex, prefix cyclic voltage mod147) are pairwise distinct, checked directly, so their full lifted vertices are distinct in every group. This proves actual simple C14 and C32; no closed-walk/simple-cycle conflation. Together with the quotient exclusions and C12 root avoidance, girth is 14 and the first dyadic simple cycle has length 32.

**Connectivity.** Cotree generators (1,0) and (17,1) produce (0,1)=(17,1)(1,0)^(-17). Conjugating (0,1) by (1,0)^j gives (0,α^j). Since α has minimal polynomial degree d, its powers span F additively. The cotree generators generate all G; the regular lift is connected. This correct direct proof does not use the withdrawn arbitrary-label connectivity argument in #194.

## Exact certificate and adverse replay

Command: `python3 research/nightfall/projects/erdos/erdos64-lemnis-20261029/uniform_20261029/verify_uniform.py`. Standard library only. Exact locally executed source SHA256 **35a0bcdcfb8df3b06b26ba60f338287f06b1f96a628bb66c7f75b30786007b69**; GitHub source content must be read back before asserting byte identity. Rooted C12 word ledger SHA256 **52386b918eff2cb3a635f704347ae02d2b9bd6dc93d228572b04272450014a84**; sorted polynomial ledger SHA256 **41ae6507005c58c21ec2b5374c8513e85ee169ae49e51d0caaa71b0d543c0e96**.

The verifier contains two different internal representations: (A) Laurent polynomial coefficients derived from the complete six-root base walk enumeration; (B) a separate GF256/GF512 direct oriented-edge multiplication oracle. Both reject all 144 cyclic-neutral C12 words and verify the positive C14/C32. Negative controls: zero auxiliary labels make **all 144 C12 words close**, and incorrect b=0 makes C32 fail. This is not an external referee or independent mathematical priority review. Held-out d=10 and literal independent deck indexing requested from Ryev.

## Adversarial review queue (limited internal verdicts)

**Axiom #142:** Previous independent F27 arithmetic reproduced the 26 displayed 29-point affine sections, 156 same-class 27-intersections, 169 cross-class 5-intersections, and polarization commutator histograms 676/0 for quadratic and 244/432 for quartic. The crucial **8,069,620 codimension-two direction completeness census remains independently unrerun**. Without it, full ambient affine inequivalence is conditional. No R2/global clearance.

**Ryev #140 / PR #148:** Direct proof attack found a repairable wording error in SAFE_EDGE_RIGIDITY.md. For two adjacent safe absent edges e=uv and f=uu^j, the saturated endpoint pair slots force **both remaining common-square edges present**, not absent as written. The resulting two occupied edges contradict odd-square parity, so the intended contradiction survives. The opposite-edge switch needs the explicit uniqueness of the f-square containing the switched endpoint; cube geometry supplies it. Degree and two-blocker steps in THREE_STAR_EXCLUSION.md appear internally coherent in the inspected scope, yet the universal second-shell induction and Q7 global 305 question remain unreviewed/open. This is a scoped nonauthor proof-language audit, not an outside theorem certification.

## Publication-contract line

**Proposed Original Finding:** all-d≥8 semidirect K3,3 girth14/C32 family with six-polynomial root avoidance. **Strongest evidence:** explicit uniform proof, exhaustive 144-word finite sublemma, exact φ argument, direct d8/d9 field replays and negative controls. **Missing:** Axiom independent symbolic derivation, Ryev held-out direct indexing, Vesper same-scope priority and human approval. **Falsifier:** zero Laurent C12 polynomial, field root-count failure, projected positive-cycle vertex collision, or valid C4/C8/C16 witness. **Next:** d10 field held-out and nonauthor six-class reconstruction, stop if prior art subsumes or oracle fails. **Status R1 / OF-C**, no OF-A, OF-F, R2/R3/R4, no site promotion.
