# Lemnis — all-modulus upper-tail hole theorem (additional structural transfer)

**Status:** R1 proof with exact finite checks. Originality review incomplete.

Let D=2^d≥8, and let q be **any integer** with q≥4D−3. In G=(Z/qZ)² let A=[0,D−1]², v=(2D−1,D+1), w=(−1,D+1), and T=A+{0,v}+{0,w}. Then:

1. The four D×D translates are disjoint; hence T is a binary cube with |T|=4D².
2. The point (2D−2,2D+1) is **absent from T+T**, so the sumset is never the whole group for any q≥4D−3.
3. The exact six-hole theorem of REVIEW.md is the stronger characterization in the two specific families q=4D−3 and q=4D−1. For larger q the complement can contain many more holes; do not extrapolate an exact six count.

**Proof:** Write I=[0,2D−2]. The sumset is the union of nine rectangles `I²+a v+b w` for a,b∈{0,1,2}. Fix target y=2D+1 and x=2D−2. For a+b=0, y≤2D−2. For a+b=1, y can equal the target but horizontal shifts are −1 and 2D−1, giving integer x intervals `[-1,2D−3]` and `[2D−1,4D−3]`, neither containing x modulo q≥4D−3. For a+b=2 the integer y interval `[2D+2,4D]` has possible wrapped values at most `4D−q≤3`, so misses the target. For a+b=3, the integer y interval `[3D+3,5D+1]` can wrap to at most `5D+1−q≤D+4<2D+1` (D≥8), so also misses the target. For a+b=4, horizontal shifts equal 4D−4, so the integer x interval is `[4D−4,6D−6]`. This cannot equal `2D−2 mod q`: it lies strictly above 2D−2, and its largest value 6D−6 is less than `(2D−2)+q≥6D−5`. Thus **no** rectangle contains the target. The four original tiles are disjoint because their y bands are disjoint except the v and w tiles; their x bands `[2D−1,3D−2]` and `[-1,D−2] mod q` are disjoint when q≥4D−3. □

**Meaning of the extension:** For every prime p≥4D−3 the same additive configuration lives in F_p² and yields a legal square-oracle phase-packing construction with b=2d+2 signs. This is **not claimed to improve** Tessera's preceding signed-digit capacity for general p; indeed for p≥4D−1 the elementary product formula already packs at least 2d+2 signs. Its strict capacity advantage is confined to field sizes where the previous formula falls short (notably p=4D−3 when prime). For composite q it is solely an additive-group result.

**Exact tail falsifier:** UPPER_TAIL_CHECK.py tests every integer q from 4D−3 through 7D for D=8,16,32; it validates pair-sum membership via nine independent interval rectangles, counts all four original tiles, and checks the target remains uncovered. The all-modulus assertion is proved above, not inferred from this finite check.