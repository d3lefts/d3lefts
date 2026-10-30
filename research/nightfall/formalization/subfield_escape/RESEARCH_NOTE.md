# Subfield escape in adaptive powered sensing: exact two-coordinate query transition

Date: 2026-10-29 (America/New_York)
Status: INTERNAL ANALYTIC PROOF; FINITE COMPUTATIONAL CHECKS; LEAN KERNEL COMPILED for F9 with explicitly reported standard `propext` dependency; FOUR SCOPED ZERO-AXIOM LEAN LEMMAS PASS; full general theorem is NOT formalized; external novelty and mathematical referee OPEN.
Research owner: Devin J. Wright. Derivation and synthesis in this session: GPT-6 (Vesper collaboration). Earlier 2k-1 adaptive subfield construction: Axiom, PR #37. Classical vector-space search baseline: Héger, Patkós, Takáts (2014).

## Theorem: exact adaptive complexity in two signal coordinates

Fix a finite field F with q elements, an integer n>0 and H={u in F*:u^n=1}, |H|=d>1. At each step choose a known linear form a·x, possibly depending on earlier readings, and observe (a·x)^n. Recover x in F^2 modulo the global H action, including x=0.

(1) For every such F and n, **at least three** queries are required in the worst case.

(2) If H is contained in the multiplicative group of a proper subfield K⊊F, **three adaptive queries suffice**. Hence the exact adaptive worst-case complexity is three.

(3) For every prime power s≥3, consider the exponent n=s−1 on F_(s^r). For r=1, the exact adaptive worst-case complexity is s; for every r≥2, it is three. The ratio s/3 is unbounded as s grows. This is a comparison of different fields with the same exponent, not a fixed-field algorithmic acceleration.

## Proof of lower bound in (1)

The nonzero n-th powers form a group of size (q−1)/d. Every adaptive query has at most A=1+(q−1)/d outcomes. The number of global phase classes of F^2 is B=1+(q²−1)/d. Elementary arithmetic yields

    d² (B−A²) = (d−1)(q−1)² > 0.

Thus two queries produce at most A² distinct transcripts, fewer than B needed; adaptive row selection cannot circumvent this pigeonhole obstruction.

## Proof of upper bound in (2): the subfield-escape operator

Measure y1=x1^n, y2=x2^n. If either coordinate vanishes, its reading detects that exactly and the other power determines the entire phase orbit.

Otherwise choose any nth root alpha of y1 in F and choose any w0 satisfying w0^n=y2/y1. The true relative ratio x2/x1 is h w0 for some unknown h∈H. Because H≤K*, membership of w0 in K does not depend on the chosen root. Fix theta∈F\K, and set c=theta if w0∈K, c=1 otherwise. Then v=c*w0 lies outside K.

The third query z=(x1+c*x2)^n determines (1+h*v)^n=z/y1. If two h,t∈H had equal powers, both factors are nonzero (v∉K). Their ratio is lambda∈H≤K*. Therefore

    1+h*v = lambda*(1+t*v)
    (h−lambda*t)*v = lambda−1.

As v∉K while all coefficients belong to K, both coefficients must vanish. Hence lambda=1 and h=t. Thus the third observation identifies the unique relative phase. Reconstruct x/ H. The protocol is deterministic given a root-selection convention and takes three queries; computational cost of root extraction is a separate question.

## Proof of (3)

For r≥2, the unique subfield K=F_s is proper in F_(s^r), and H=F_s* is exactly the (s−1)-th-root group. Apply (1) and (2).

For r=1, Fermat's identity makes each measurement equal to 0 or 1. Each nonzero signal phase orbit is a point of the projective line PG(1,s), which has s+1 points. A nonzero row has a one-dimensional kernel, hence its reading is zero at exactly one projective point. An arbitrary adaptive decision tree with at most s−1 queries has an all-nonzero path that eliminates at most s−1 projective points, leaving at least two possibilities. Hence at least s queries are necessary.

For an upper bound, select any s of the s+1 distinct projective kernel directions and query their associated rows **nonadaptively**. Their s binary response patterns are distinct on the s+1 projective points (each queried direction has a unique zero, and the unqueried direction has no zeros). The zero vector returns zeros to every query. Since s≥3, this is different from any nonzero projective signature. Therefore s queries suffice, and the lower bound is sharp. (For s=2, two queries also suffice; only the unbounded s≥3 comparison is of interest.)

## Distinguishing measurements from computation and novelty

The result concerns zero-error recovery and number of oracle queries; no uniform bit-complexity claim is made for general finite-field root extraction. The r≥2 construction relies on signal-dependent choice of the third row. The r=1 lower bound allows any adaptive strategy. Existing Axiom PR #37 proves a related F25 adaptive upper bound 2k−1 for all k; its k=2 case is not newly discovered here. The contribution of this note is the cross-regime exact law and general subfield-containment sufficient condition, pending external priority search.

Classical baseline / known related source:
- Tamás Héger, Balázs Patkós, Marcella Takáts, *Search Problems in Vector Spaces*, Designs Codes Cryptography (2014), arXiv:1309.6731; geometric incidence search and k-dimensional adaptive bounds: https://arxiv.org/abs/1309.6731
- Jamison (1977) and Brouwer–Schrijver (1978) on affine blocking sets provide related geometric tools; not claimed as NIGHTFALL novelty.
- Axiom, adaptive F25 theorem, PR #37: https://github.com/d3lefts/d3lefts/pull/37

## Reproducibility / scope

- Formal core: `research/nightfall/formalization/subfield_escape/SubfieldEscape9.lean` tests the F9 three-reading map and the F5 geometric finite obstruction/upper bound, plus exact F9/F25 count inequalities. Workflow run [40995405288](https://github.com/d3lefts/d3lefts/actions/runs/40995405288) PASSED on Lean 4.35.0: F9 exhaustive theorem compiled with Lean's standard `propext` axiom disclosed, four smaller incidence/count lemmas passed `--strict` with no axioms reported; five bridge protocol tests and the independent F9/F25 arithmetic checker also passed. No claim that these checks kernel-formalize the general arbitrary-field theorem.
- Independent Python pair-arithmetic checker (run locally in this session) enumerated F9^2 (81 signals) and F25^2 (625 signals), finding 41 and 157 distinct signatures and zero collisions.
- Remaining proof gate: a **general finite-field formalization** of the subfield-escape argument (not yet present), independent human review, and a more exhaustive exact-model priority investigation.

Claim status is deliberately below “Novel Contribution” and below “Theorem (non-author proof review)” under the NIGHTFALL certification protocol.
