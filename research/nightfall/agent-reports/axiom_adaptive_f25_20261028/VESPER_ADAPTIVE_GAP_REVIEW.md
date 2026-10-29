# VESPER independent audit — exact two-coordinate adaptive gap
2026-10-29 UTC. Research lead: Devin J. Wright. Independent proof and verifier: Vesper (GPT-6).
Canonical Axiom theorem: this PR's RESEARCH_NOTE.md. Scope: F25 fourth-power *linear* measurements, all signals modulo F5*; sensing rows may be adaptive only where explicitly stated.
Status: mathematical proof plus independent exhaustive exact implementation PASS; published same-model priority and human referee OPEN.

## Theorem
For k=2, the minimum worst-case number of adaptive fourth-power linear queries is 3, whereas the minimum number of fixed/nonadaptive rows for uniform injectivity is 4.

For general k>=1 every deterministic adaptive protocol needs at least
m >= ceil(log_7(1+(25^k-1)/4))
measurements in its worst case. In particular, Axiom's <=2k-1 protocol is measurement-optimal for k=1,2,3,4 (k=4 uses the sharper fibre bound below).

## Proof: universal adaptive lower bound
The map t -> t^4 takes F25 to {0} union a subgroup of size 24/4=6. Each query therefore has at most seven possible answers, even when its sensing row depends on all earlier answers. A decision tree of depth m has at most 7^m transcripts. Since F25^k has 1+(25^k-1)/4 equivalence classes under scalar multiplication by mu4=F5*, distinct classes must have distinct transcripts. Hence 7^m >= 1+(25^k-1)/4. For k=1,2,3 this forces m>=1,3,5, matching Axiom's adaptive worst-case counts.

## Proof: three fixed rows always fail when k=2
If the three sensing rows span a proper subspace of F25^2, a nonzero common kernel vector is indistinguishable from the zero vector. Otherwise two rows are independent. Permute them first and apply an invertible linear change of signal coordinates to normalize the design to
e1, e2, (a,b).
If a,b are both nonzero, choose x=(b,a), x'=(2b,a). The first readings agree, since 2^4=1 in F5, and their third linear forms are 2ab and 3ab respectively; 2^4=3^4=1. Yet x' is no global mu4 multiple of x, as the second coordinate is unchanged and nonzero while the first differs.
If a=0 or b=0, choose x=(1,1), x'=(2,1); the first two fourth powers agree and the third reading depends on only one coordinate, so it agrees as well. Thus every fixed three-row design fails.

## Proof: four fixed rows suffice
Choose theta in F25\F5 and use e1, e2, e1+e2, e1+theta e2.
Coordinate readings determine zeros exactly. If only one coordinate is nonzero, it is fixed modulo global mu4. When both are nonzero, fix one fourth root of x1^4 and write v=x2/x1. Candidate ratios differ by zeta in mu4=F5*. At least one of v and theta*v lies outside F5. For w outside F5, the four quantities (1+zeta*w)^4 are pairwise different: equality implies a ratio lambda in F5*, giving 1+zeta*w=lambda*(1+eta*w), which forces lambda=1 and zeta=eta by linear independence of 1,w over F5. Therefore at least one of the two mixed readings uniquely determines the relative phase. All 157 phase classes are separated.

## Independent certificate
Run: python3 vesper_independent_two_coordinate_gap.py
Implementation: F5[u]/(u^2-2), no import from other NIGHTFALL code.
Expected: output alphabet 7; exactly 157 phase classes; 4-row design outputs 157 unique signatures with zero collisions; each of 625 normalized third rows fails; the maximum number of distinct signatures for a fixed three-row normalized design is 145.
Original standalone source SHA-256: 8c64a4007bdb8634fd06da8532215ca01da70d09041718dd4d9b4347e5f80388.
Git blob SHA-1: 25c48d180e9f89fd60d2486760c461e46aabd99d.

## Boundary
These are exact measurement-count results for the stated sensing law and dimension. They make no worldwide novelty claim, and do not imply a nonadaptive polynomial-time random-design inverse. Do not apply 3-vs-4 beyond k=2. The universal counting bound allows fewer than 2k-1 measurements for k>=5; its attainability is open.

## Stronger adaptive decision-tree obstruction at k=4
**Theorem:** The minimum worst-case number of adaptive F25 fourth-power linear readings is exactly **7** for k=4, matching Axiom's construction; the six-reading possibility is mathematically excluded.

**Proof.** Suppose a six-query adaptive protocol recovered all 97,657 global mu4 classes. Its first sensing row must be nonzero: a zero row wastes one reading, and five seven-valued queries offer at most 7^5=16,807 transcripts, fewer than the total classes. Fix any **nonzero** fourth-power response to the first nonzero linear form. The surviving set has exactly 25^3=15,625 distinct global-mu4 classes, because the linear form has four roots and 25^3-dimensional-fibre points per root, and all such signals are nonzero.

The protocol chooses its second row based on the fixed first answer. If the second row is dependent on the first, its response is predetermined and the survivor count remains 15,625. If the two rows are independent, choose a nonzero second fourth-power response. The two simultaneous equations have 4*4*25^2 field-valued solutions, grouped freely into mu4-orbits of size four, leaving exactly 4*25^2=2,500 inequivalent signals. Both cases leave **at least 2,500** classes sharing the first two outputs. Four queries remain. They generate at most 7^4=2,401 possible continuations, a strict contradiction. Thus six adaptive queries are insufficient; Axiom's seven-query protocol is optimal. QED.

This is an exact integer/fibre-count obstruction, independent of the exhaustive k=2 checker. It further establishes Axiom's upper bound as optimal for k=1,2,3,4. An improvement gap remains from k=5 onward. Test next: k=5 with 8 adaptive readings; generic leaf counting permits this, so a new structural obstruction or a new phase-compression representation is required.
