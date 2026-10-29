# Discovery trace and rejected alternatives — 2026-10-29

1. **Target**: improve the finite 30-element `(4,5)` witness by direct insertion of a 31st integer while keeping its largest Sidon subset at 17; that would give a finite ratio 17/31 below the known 5/9 asymptotic baseline.
2. **Representation**: write admissible new integers as affine completion values `2a-b`, `(a+b)/2` of old marks; forbid distinct-four collisions `a+b-c`.
3. **First falsification**: all 1,132 AP candidates checked; only 305 preserve `(4,5)`, and each creates just one AP. Each allows an 18-point Sidon subset. **Target fails for every integer**, not just a bounded scan.
4. **Structural transition**: exact enumeration of the original 13-deletion transversal family gave 26,923 original 17-point Sidon subsets. Optimize a small, fixed **portfolio of 11** which handles *all* one-/two-point exception families.
5. **Second falsification**: 44,255 two-old-AP pairs; 7,174 one-old-AP plus mixed-AP pairs; 23 two-mixed-AP affine intersections. Every eligible pair admits 19 Sidon points.
6. **Independent implementation**: replace discovery scripts and transversal-family enumeration with a standard-library checker that regenerates candidate classes and confirms the explicit portfolio using exact unordered pair sums. Complete 12-deletion exclusion cross-check; negative mutations rejected.
7. **Meaning**: bounded but universal integer quantified theorem on this fixed witness. It rules out the naive insertion search operator and prioritizes point replacements, different seeds, or new constraint structures. The global problem remains open, and scholarly priority is unreviewed.

## Rejected hypotheses

- `h(B+x)=17` for some admissible integer x — contradicted by universal extension certificate.
- `h(B+x+y)=18` for some admissible integer pair — contradicted by universal extension certificate.
- Increasing random optimizer iterations without addressing insertion rigidity — ineffective; exact affine reduction supersedes search intensity.

The exploratory NumPy/Numba scripts were used as candidate generators only. The published theorem rests on the separate pure-Python verifier and explicit 11-subset certificate.