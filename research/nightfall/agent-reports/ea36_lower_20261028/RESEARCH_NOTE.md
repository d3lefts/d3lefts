# NIGHTFALL — Erdős #36 lower bound: independent recovery and exact fixed-dual obstruction

**Research lead:** Devin J. Wright  
**Audit date:** 2026-10-28  
**Result classification:** conditional universal lower deduction, with independently replayed exact rational arithmetic. Upstream outward-rounded Wetch integrals remain inherited evidence.

## 1. Strongest frozen lower certificate recovered

The intact October 27 archive `ERDOS36_NEW_LOWER_ENVELOPE_20261027.zip` contains a strict universal lower deduction, provided the original Wetch analytic kernel and original central/outer Arb enclosures are valid:

\[
\boxed{\mu>\frac{9515686865667}{25000000000000}=0.38062747462668}. 
\]

This endpoint exceeds Wetch's publicly posted 0.380627425 by 0.00000004962668, approximately 4.96 × 10^-8. Relative to NIGHTFALL's October 22 V5+ checkpoint 0.380627474626, it sharpens only by 6.8 × 10^-13. **It is a recovered earlier conditional deduction, not a newly discovered global record in this turn.**

The original project reported Wetch's 0.380627425 with full local fresh-copy verification. Its theorem uses universal Fourier/Gram/kernel premises, not merely a finite set of tests. The inherited numerical enclosures were checked from archived result files here; their original transcendental/Arb computations were not regenerated with an independently authored ball-arithmetic implementation.

With NIGHTFALL's separately audited 131,072-cell construction at `0.380856370118029325246278763656...`, the *conditional* interval width is `0.000228895491349325246278763656...`. This is an upper/lower gap, not a proof of the exact constant.

## 2. Exact audit of the eight-row intermediate mean cover

Let `m` be the first moment of the signed overlap distribution, with `m∈[-1,1]`. The archived proof separates:

- Central: `|m|≤1/25000`, inherited positive lower margins (three original source integral checks).
- Intermediate: `1/25000≤|m|≤9/2560`, new exact-rational eight-row dual cover.
- Outer: `9/2560≤|m|≤1`, inherited 180-bin interval-arithmetic source reports in each original/refined backend.

Every unchanged dual row has the form `R_i(m)=(a_i+b_i*m+c*m²)/d_i`, where `d_i>0` and the identical `c<0` is specified exactly in the original certificate. Therefore each is strictly concave, and endpoint checks are enough on a closed interval. The eight archived intervals cover the entire intermediate band; each endpoint has positive exact surplus above `T=0.38062747462668`. Reflection covers negative means. An exact finite cover plus the inherited central/outer source premises gives the stated conditional strict global bound.

**Executed this session**:

1. Original Oct 27 independent `verify_independent.py`: **PASS**, eight rational interval endpoints, hashes, concavity, exact cover, original source premise comparison.
2. `adversarial_controls.py`: **PASS**, rejection upon deliberately raising the target and creating an interval gap.
3. Original V5 `checker_B.py`: **PASS**, exact rational Gram positive definiteness restricted to the zero-sum subspace, unchanged physical kernel, exact multipliers, and complete cover.
4. V5+ exact retarget and independent handoff checker: **PASS**, archived original central/outer margins and exact intermediate-row comparison.
5. Archived independent analytic stress suites rerun here: **PASS**, 398 rational density cases and 1,518 density/kernel cases with 45,540 exact rational dual-flow tests. These are falsification controls, not proofs by exhaustive enumeration.
6. Archived Wetch outer report checker: **PASS** for consistency of the two original 180-bin interval reports, with their recorded outward lower endpoints above `0.380631603689`. The actual original Arb integrals remain a separate execution prerequisite.

## 3. Exact fixed-dual saturation theorem — new independent refinement

**Theorem (fixed-row ceiling, explicitly scoped).** Keep precisely the eight V5+ row numerator/denominator triples frozen in `data/new_rows.tsv` and the common negative quadratic coefficient frozen in `data/certificate.json`. For the exact rational mean

```
m0 = 0.00015476385606657769751043995839161416772
```

all eight row returns satisfy

```
R_i(m0) < 0.380627474626686 .
```

Every positive linear combination of these eight valid dual returns gives a denominator-weighted average of their returns at `m0`. Consequently, **no selection, interpolation, endpoint refinement, remeshing, or nonnegative mixture involving only these unchanged eight rows can certify a uniform bound of `0.380627474626686` through their pointwise returns.**

The bound is a **ceiling on this fixed proof family**, **not an upper bound on the true Erdős constant**. In combination with the certified exact intermediate cover above `0.38062747462668`, the possible improvement from the unchanged family is strictly below

```
0.000000000000006 = 6e-15.
```

The independent checker `verify_dual_ceiling.py` reads and SHA-256 pins the unmodified original rows, verifies the complete lower cover, then evaluates all eight values using Python exact fractions at `m0`. The two tight returns come from rows 2 and 3. The nearby crossing is `m≈0.00015476385606657769751044` with envelope ≈`0.380627474626685770907245749...`; only the **rational point bound** is needed for the theorem.

**Research consequence:** A gain at the NIGHTFALL reporting threshold of 10^-8 requires new valid dual geometry: change the physical kernel, create a different feasible flow/Gram multiplier, or derive a new common-profile coupling. Reoptimizing these eight frozen intervals has a certified saturation obstruction.

## 4. Evidence scope and unresolved gates

| Layer | Result |
|---|---|
| Frozen original archive digests | SHA-256 identity confirmed |
| Oct 27 eight-row exact lower return | PASS |
| V5 exact Gram and source-kernel transfer | PASS |
| 398 analytic rational controls + 45,540 flow tests | PASS |
| Source outer 180-bin report integrity | PASS on stored interval endpoints |
| Fresh recomputation of the Wetch Arb continuum integrals | PENDING |
| Full external specialist mathematical review | PENDING |
| Fixed-family ceiling at exact rational m0 | PASS |
| Improvement of >=1e-8 over the previously strongest NIGHTFALL conditional result | NONE |

The unreviewed original Arb calculations and the complete analytic reduction are explicit dependencies of the claimed universal lower bound. An exact rational cover alone proves a finite implication conditional on them. Formal proof of all upstream lemmas, a fresh complete arithmetic replay, and a distinct new dual direction are the three meaningful next gates.

### References and attribution

- Justin Wetch, *Bounds for Erdős' minimum-overlap constant* (public reproducibility package): https://github.com/justinwetch/erdos-36-minimum-overlap
- NIGHTFALL / Devin J. Wright, V5 and V5+ source Gram/multiplier refinements and Oct 27 rational envelope tightening (unchanged frozen ZIPs included).
- Prior work: E. P. White, Acta Arithmetica 2023; Ben Zanghi's interval/Bochner framework; Price's later lower certificate. Each has separate evidentiary scope and historical comparison.

This archive changes no original data. New calculations are a supplemental independent audit.