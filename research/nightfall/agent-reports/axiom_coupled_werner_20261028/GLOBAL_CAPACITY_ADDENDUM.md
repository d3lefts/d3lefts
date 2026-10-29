# AXIOM × LEMNIS — compositional all-sector coordinate-positive capacity

**Dated:** 2026-10-28. **Research owner:** Devin J. Wright. **Axiom mechanism:** conservative off-diagonal difference-grade decomposition and exact universal row-support theorem. **Lemnis premise:** independently archived *Sharp ternary parity-kernel rigidity and the first rank-three obstruction*, `research/nightfall/agent-reports/lemnis_diagonal_rigidity_20261028/RESEARCH_NOTE.md`. Its exact symplectic theorem asserts each ambient-positive ternary diagonal coordinate support on `z` sites contains at most `2^z` units, with equality precisely for a Cartesian product of two-symbol alphabets. **Status:** new derived all-grade corollary with exact finite verification, dependent on Lemnis's cited proof; external novelty and proof review pending.

## Sharp all-grade capacity theorem

For `n>=1` and unnormalized `Omega_3`, let `K_n=(I-|Omega_3><Omega_3|/2)^tensor n`. Consider a coordinate subspace `V_T=span{E_ab:(a,b) in T}`, with arbitrary `T subset ({0,1,2}^n)^2`. Require the **ambient** restriction of `K_n` to `V_T` be PSD on *all* complex matrices, regardless of rank. Then

`dim V_T=|T| <= 8^n`.

**Equality is achievable.** Choose the eight local units consisting of six off-diagonals `E_ab` with `a!=b`, plus the two diagonals `E_00,E_11`, and take their `n`-fold tensor products. This has exactly `8^n` distinct coordinates. The single-site compression of the Werner kernel onto these eight units is the direct sum of six positive `1`s and the diagonal two-by-two Gram `[[1/2,-1/2],[-1/2,1/2]]`, hence PSD; its tensor powers are PSD.

**Proof of the upper bound.** By Axiom's exact difference-grade identity, the 3^n grades decompose into independent coordinate groups. For a grade containing `z` zero positions, there are exactly `3^(n-z)` groups, one for each assignment of row labels in the nonzero positions. Every group has exactly the `z`-site ternary diagonal kernel of Lemnis, and therefore contains at most `2^z` supported basis units if it is ambient PSD. Summing sharp individual caps over all grades gives

`|T| <= sum_(z=0)^n C(n,z) 2^(n-z) * 3^(n-z) * 2^z = (6+2)^n = 8^n`.

Here `C(n,z)2^(n-z)` counts grade labels with z zero positions and `3^(n-z)` counts fixed nonzero-position groups. There are no missing cross terms: different grades and groups are exactly orthogonal for the Werner form.

**Exact classification and count of maximizers.** Equality forces equality in every independent group. By Lemnis's equality theorem, the supported row labels at the `z` zero positions form a box choosing exactly two of three symbols independently in each coordinate; there are `3^z` choices. Each group can choose independently. The number of maximal coordinate-supported PSD subspaces is exactly

`prod_(grade delta) (3^z)^(3^(n-z)) = 3^( n * 7^(n-1) )`.

This counts coordinate supports, not continuous changes of basis. For four qutrits `n=4`, maximum complex dimension is **4096** and there are `3^1372` maximizers. This is a **global coordinate-subspace maximality**, not a bound on general positive linear subspaces with non-coordinate bases, which can be larger.

**Sharp negative obstruction:** Any 4097-coordinate support contains some grade/group with more than its 2^z bound. Lemnis's three-word theorem gives a rank-three matrix supported in that group with `Q=-3/2^z`; in particular some `Q<0`, so the 4097-dimensional coordinate subspace cannot be ambient PSD. In the canonical `8^4` product construction, adding `E_(2000,2000)` produces exactly 64 distinct negative rank-three triples, each with `Q=-3/16`. An independent exact checker verifies these 64 witnesses.

**Interpretation.** This transfers Lemnis's diagonal rigidity to *every off-diagonal conservation grade*, forming an all-copy theorem through a compositional count. The local positive tensor construction gives the matching lower bound. It is a strict extension in applicable scope beyond the diagonal-only `2^n` result, while relying on its verified argument rather than claiming a separate original proof of that component.

**Limits:** All ingredients are elementary and connect to established Hamming schemes, symplectic coding, Schur products, and signed-graph switching. Priority remains open. Ambient PSD of coordinate subspaces does not establish endpoint positivity for arbitrary matrix-rank-two witnesses. No parameter threshold is improved.

**Evidence:** `check_global_capacity.py` enumerates every difference-grade/group capacity for `n=1,...,6`, verifies `8^n` and `3^(n*7^(n-1))` in exact integers, constructs the 4096-coordinate example, and checks all 64 three-coordinate signed negative witnesses. The analytic all-n claim rests on the exact proof above and Lemnis's all-n symplectic theorem, not extrapolation from n<=6.
