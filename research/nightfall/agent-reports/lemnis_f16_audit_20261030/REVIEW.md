# LEMNIS / F16 full-subfield cube-oracle adversarial review, v1

**Date:** 2026-10-30. **Scientific owner:** Devin J. Wright / NIGHTFALL. **Reviewer role:** Lemnis (internal AI mathematical adversary, not an external human referee). **Parent:** GitHub #247; source PR #243 at head `d3a3717e846390461c7cf2ec41553189d78267a1`. **Result:** PASS for the specific eight-query k=5 mathematical construction and lower bound, INCONCLUSIVE for worldwide novelty and universal 4x7 existence/nonexistence.

## Frozen mathematical contract

Original oracle: `K = F_16 = F_2[z]/(z^4+z+1)`, `L=F_4`, `H=L*= {1,6,7}`, `x in K^k`, adaptive queries `y_a=(sum a_j*x_j)^3`, with every query counted, and recovery modulo one global common multiplier from `H`. No supports known in advance, no access to any unpowered linear form, no additional phase or exact amplitude observation.

**Most relevant source checked:** PR #243 note/Lean/code at pinned head; original and independent arithmetic, the PR #243 workflow [GitHub Actions 40995299592](https://github.com/d3lefts/d3lefts/actions/runs/40995299592), which succeeded. Adjacent external prior-art sources: 2022 *Separating invariants over finite fields* (Journal of Pure and Applied Algebra, DOI `10.1016/j.jpaa.2021.106904`), and Bartusel–Führ–Oussa (2023), *Phase retrieval for affine groups over prime fields*, DOI `10.1016/j.laa.2023.07.033`. Neither, on the material inspected, is established to contain this exact cube-power, F16/F4, adaptive linear-form oracle. A proper dated same-model priority review is outstanding.

## Independent representation and exhaustive procedure

Rather than importing PR #243's bit-polynomial multiplication, represent the field using the tower

`L=F_2[w]/(w^2+w+1)`, `K=L[t]/(t^2+t+w)`.

The representation is isomorphic to the original `K` by `t=z` and `w=z^2+z`; all 16 elements are mapped bijectively to pairs of four-element-field coordinates. Multiplication occurs by `(a+bt)(c+dt) = ac + wbd + (ad+bc+bd)t`, implemented only with two-bit arithmetic. The subgroup and cube fibers are built from scratch.

Every nonzero `x` has an `H` orbit of size 3; zero is its own orbit. For k=5, select the first nonzero coordinate. Its 15 possible values collapse to five canonical representatives of `H`; each later coordinate remains arbitrary in K. This enumerates every global-H class exactly once, with 25, 750, 11,250, 84,375 and 253,125 classes of supports 1,2,3,4,5, plus the zero vector. Total **349,526**.

For each class, independently compute all five genuine coordinate cube queries; derive support and one fixed cube-root representative for each supported coordinate *only from those observed values*; choose the first supported anchor; issue the three genuine mixed powered linear-form queries for every full group of four nonanchor coordinates and the genuine one-per-phase powered query for remaining coordinates; decode from an 81-word table; verify that the reconstructed vector differs from the input by exactly one member of H. This includes *every support pattern*, the all-zero vector, and every initial anchor position. The maximum number of queries is 8 and support-wise maxima are `s=1:5, s=2:6, s=3:7, s=4:8, s=5:8`. The independent 81-word injectivity test passes. A two-output truncation deliberately fails, with explicit relative-phase collision `(1,1,1,6)` and `(1,6,6,1)` mapping to `(12,1)`.

The signal-class count establishes the lower bound with no assumption that queries have fixed coefficients: an adaptive protocol whose observations always lie in a six-symbol alphabet has at most `6^7 = 279,936` distinct leaves at depth seven, even if early termination is allowed. It cannot identify `349,526` equivalence classes. The constructed protocol has worst-case depth eight, proving **exact k=5 minimax query complexity 8** under this model. No transfer of this result to complex intensity phase retrieval is implied.

## Projective-pencil collision theorem for the open 4x7 case

For any distinct anchored phase vectors `u=(1,η_1,...,η_6)` and `v=(1,η'_1,...,η'_6)` in H^7 and any row `a in K^7`, the powered observations agree iff **there exists** `h in H` with

`sum_i a_i*(u_i - h*v_i)=0`.

This is an exact disjunction of three homogeneous K-linear hyperplanes. Both-zero evaluations are valid collisions, and one-zero/one-nonzero evaluations are excluded automatically. Since distinct anchored u,v are linearly independent over K, any pair of distinct hyperplanes meets in their common codimension-two subspace; thus exactly `3*16^6-2*16^5` of the `16^7` rows collide. The probability for a uniformly random row is exactly `46/256=23/128`. The independent quadratic-tower checker enumerated a 256-row normalized two-coordinate section and found **45** points of exactly one hyperplane, **one** point on all three, and **210** with none.

For four independent random rows, expected colliding unordered phase pairs are exactly

`C(729,2)*(23/128)^4 = 18,564,372,099/67,108,864 ≈ 276.63070110976696`.

This is a first-moment diagnostic, not a zero-collision existence bound or impossibility proof. The previously supplied 4x7 failed matrix in #248 was independently rechecked in the tower model: **570 distinct output words, 174 unordered colliding input pairs, 144 collision-containing output classes**; the pair `(1,1,1,1,1,1)` and `(6,7,7,6,7,6)` shares output `(15,1,8,1)`. Therefore the supplied matrix is invalid, and the existence of a zero-collision 4x7 remains OPEN. Any SAT encoding must preserve the zero-output event and row-wise separate scalar `h`; a single `h` common to all rows would be an unsound relaxation/restriction.

## Formal status and proof dependencies

Pinned GitHub workflow `40995299592` contains successful Lean compilation and checks of named declarations, reporting only `propext`, and additionally `Quot.sound` for the `field_inverses` lemma, within the configured allowed foundational scope. No `sorryAx` reported by the examined workflow output. The Lean file certifies the concrete finite block and associated elementary finite-field properties; **it does not itself contain the all-signal two-round transfer theorem**. That transfer is independently reconstructed in the exact Python audit above and justified mathematically by the coordinate-root/anchor/block argument.

- **PASS (internal independent):** k=5 exact construction, exhaustive 349,526-class verification, six-symbol counting lower bound, field-model consistency, 81-word gadget, one-row collision pencil, and explicit failed 4x7 control.
- **INCONCLUSIVE:** zero-collision 4x7 existence, all-matrix obstruction, external mathematical referee, same-model worldwide publication priority.
- **Adversarial negative control:** weakening a three-output block to two outputs loses injectivity; treating zero as an ordinary projective nonzero point misclassifies collisions; the frozen failed 4x7 matrix has an explicit collision.

**Source SHA-256**

- `lemnis_f16_independent_audit_20261030.py`: `25d2af1e39cc5d89f87950b99cab541e3705df3d00a07ba9058c22bed875fc56`
- `lemnis_f16_4x7_collision_attack_20261030.py`: `b0ea463eeb8458afc0ef91798450053fe0fcca6840efbfe94bc2fa162b12c9e1`
- `lemnis_f16_audit_receipt.json`: `968153f413f4c53baa2eb8d43a521e13fdf216ce57314407ac2dfcb314fae2a6`

## Independent follow-through and stop rule

Ask Ryev to check the exact source using a third representation and Axiom to attack the 4x7 pencil formulation. A genuinely new 4x7 matrix must produce **729 distinct observations with zero pair collisions** under the frozen cubic oracle, then pass another independently written checker and full k7 two-round decoding. If it cannot, do not infer any universal impossibility from random unsuccessful searches. Reserve future mathematical effort for projective-pencil/covering code lower bounds, certified SAT constraints, or algebraic code constructions; stop uncontrolled coefficient sweeps.