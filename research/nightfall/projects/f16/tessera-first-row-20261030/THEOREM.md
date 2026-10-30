# TESSERA — projective first-query capacity and restricted-pencil no-go

**2026-10-30.** Assignment #251, flagship program #248. Status **R1 internal exact theorem candidate**, subject to independent non-author mathematical review and prior-art audit. The five-query/eight-phase F16 adaptive decoder is **still open**; this result is a restriction on one construction family, not a universal impossibility theorem. Preserve the earlier correct 2-query/3-phase adaptive code in PR #255.

## Frozen oracle and exact target

F=GF(16)=GF(2)[z]/(z^4+z+1), L=GF(4), H=L*={1,6,7}. We have eight relative phases eta in H^8 and a fixed anchored constant 1. A permitted measurement has arbitrary F-coefficients a=(a0,a1,...,a8) and returns exactly (a0+sum(ai*eta_i))^3. Its alphabet contains 6 values: zero plus 5 nonzero H-orbits. The 6561 phase assignments must yield unique five-query adaptive transcripts. For a five-query tree a necessary condition after t measurements is that every ambiguity class contains no more than 6^(5-t) states.

## Theorem 1 — general q-projective additive Fourier operator

For any quadratic finite-field extension F=GF(q²), L=GF(q), full phase group H=L*, and the SAME exponent q-1, let N(z) be the number of anchored phase inputs whose *unpowered* linear sum equals z in F. For each additive character chi of F let V_i=ai*L when ai is nonzero. Then exactly:

    N(z) = (1/q²) * sum_chi chi(a0-z) * product_i B_i(chi)

where B_i(chi)=q-1 if ai=0 or chi is identically 1 on V_i; and B_i(chi)=-1 otherwise. Powered-output zero fiber has N(0) states. A nonzero powered output fiber has sum of N(z) over the q-1 nonzero elements in its projective L-line. 

**Proof:** On each nonzero L-line, sum_{h in L*} chi(ai*h) is q-1 if chi restricted to that line is trivial, and -1 otherwise, since the complete L-line character sum is zero. When ai=0 the sum is q-1. Independence multiplies Fourier transforms, and additive Fourier inversion yields the expression. Nonzero (q-1)th powers identify precisely the L-projective line. All field and zero-coefficient cases included. This Fourier identity is classical in method; no novelty presumed.

## Theorem 2 — sharp exhaustive first-query capacity at eight phases

Across **all 16^9=68,719,476,736 possible first anchored coefficient rows** the smallest possible *largest* powered output fiber is exactly:

    min_a max_y # {eta in H^8 : (a0+sum ai*eta_i)^3=y} = 1215.

It is attained by the explicit row:

    (a0;a1,...,a8)=(0;0,0,0,1,2,3,4,5)

whose six output fiber counts are (486,1215,1215,1215,1215,1215).

**Finite proof compression:** Each nonzero ai belongs to one of the five one-dimensional GF4 subspaces of F, and multiplying ai by an element of H only permutes the phase value in that coordinate. Permuting phase coordinates also preserves the multiset of output sizes. Thus the six occupancy counts (zero coefficients and five projective lines), summing to 8, together with the exact anchored coefficient a0 in F, determine the full first-row fiber profile. There are exactly 16*C(13,5)=20,592 compressed signatures. The exact additive convolution enumerator tests all 20,592 and proves min-max 1215, attained in 16 signatures. The next four queries permit at most 6^4=1296 possibilities. **15,591** signatures satisfy this necessary capacity bound, and **5,001** fail. These are *signature counts*, not an assertion about the fraction of raw rows. Literal 6561-state enumerations for 30 varied rows independently check the compression.

**Interpretation:** The first row alone does not preclude the target five-query decoder; any universal no-go requires additional information.

## Theorem 3 — exact two-stage projective-pencil obstruction

Suppose the first row's anchored coefficient is zero, the eight phase coefficients are all nonzero, and four distinct GF4 projective directions each occur twice. By global nonzero GF16 scaling (which multiplies the cubed output by a known scalar), phase coordinate permutation and phase relabeling within H, every such row is equivalent for collision purposes to:

    a=(0;2,2,3,3,4,4,5,5).

The first reading has output fibers (417,1224,1230,1230,1230,1230). Permit the second row to be selected adaptively from the first **powered observation only**, yet require each phase coefficient bi to stay in the original line ai*GF4, including zero, with arbitrary anchored constant b0 in GF16. There are 4^8*16 = 1,048,576 eligible second rows for each first reading.

**Sharp exact exhaustive result:** On each of the five nonzero first-reading branches the minimum, over *all* those second rows, of the largest resulting second-reading class equals **225**. On the first zero-output branch the corresponding minimum equals 78. Thus any allowed second-row selector leaves, for some first/second transcript, at least **225** phase states. Only three queries remain, allowing at most **6^3=216** distinct transcripts. Consequently **no five-query code whose first two rows have this restricted projective-pencil relationship can be injective**, even when all remaining queries are fully adaptive.

**Sound symmetry:** GF16* acts transitively on its five GF4* cosets, so one common nonzero scalar maps whichever direction was omitted into the canonical omitted direction. This permutes the other four and preserves cube-output equality. Individual H coefficient factors can be absorbed into bijective phase-coordinate relabelings. Both operations preserve the requirement bi in ai*GF4. No overbroad normalization of arbitrary GL2 changes is assumed.

## Exact computational certificates and independent attacks

- first_row.py: dependency-free exact six-category occupancy/anchor enumeration; 20,592 signatures; 30 independent literal evaluations on all 6,561 inputs; checks zero coefficients, nonzero anchors, six-output oracle.
- pencil_full.cpp: independent direct polynomial GF16 enumeration of **6 × 1,048,576** branch/second-row choices, including all zero coefficients. Each nonzero branch has minimum worst-class size 225 and exactly zero second rows satisfying the necessary 216 bound.
- pencil_orbit.py: different schoolbook polynomial multiplication and **160,000** independent symmetry-quotiented second-row tests on a decisive 1,224-state first-output branch. Each of the four two-coordinate groups may exchange its phases, reducing 16 ordered coefficient choices to 10 unordered options per group; 10^4 choices times 16 anchored constants exhausts the equivalence. Minimum largest class 225, with explicit sharp output distribution (108,216,225,225,225,225). None passes 216.
- Negative controls: any use of the unpowered 16-symbol value to claim extra information is rejected; the genuine cube alphabet has only six symbols. Zero second coefficients and branch-dependent second choices are included; no hidden unpowered side information.
- Reproduce: python3 first_row.py; python3 pencil_orbit.py; g++ -O3 -std=c++17 pencil_full.cpp -o pencil_full && ./pencil_full. A dedicated Actions workflow runs all three.

## Implications and next proof obligation

The natural balanced four-direction first row is **insufficient together with line-preserving second rows**. However the globally most balanced first row has **three zero phase coefficients** and five different projective directions; other first-row distributions and second-row direction changes are outside the theorem. The cheapest next necessary test is to search second rows that change projective directions for one of the 16 optimal first-row signatures, seeking all second-fiber sizes <=216. This would establish only two-query necessary feasibility, not a complete five-query decoder.

**Independent review:** Lemnis challenges projective equivalence, all-coefficient completeness and adaptive decision-tree quantifiers; Ryev reproduces in a GF4-quadratic tower with mutation tests; Axiom targets a genuinely cross-direction second row; Vesper audits dates, originality and global model identity. AI reviews cannot substitute for a human proof referee.

**Prior-art boundaries, non-exhaustive 2026-10-30:** Classical additive-character convolution and finite projective lines; the 2025 journal Foundations of Additive Codes over Finite Fields (doi:10.1016/j.ffa.2025.102592); Bartusel–Führ–Oussa 2023 affine-group complex phase retrieval (doi:10.1016/j.laa.2023.07.033). Neither source grants novelty clearance for this fixed F16 pencil census.

**Status:** internally exact R1, no verified original publication, no five-query decoder, no k9 improvement, no public Original Finding, and no site/flagship merge.
