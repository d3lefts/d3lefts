# Characteristic-three adaptive decoder: formal proof path

**Checkpoint:** 2026-10-29. **Status:** formalization started, the full adaptive-decoder theorem **has not been kernel checked**. This is a narrow first machine-checkable sanity slice only. Research lead: Devin J. Wright.

## What is actually formalized

[Finite3.lean](Finite3.lean) contains two fully elaborable *candidate* statements over the literal three-element type Fin 3:

- cubing a residue returns the same residue modulo 3;
- cubing a sum is additive modulo 3.

Both are proved with finite enumeration through Lean's decidable reflection, without imported axioms, sorry, or native_decide. The GitHub Actions workflow [lean-char3-sanity.yml](../../../../.github/workflows/lean-char3-sanity.yml) compiles the file using pinned Lean 4.35.0. The claim may be called **kernel checked only after that run succeeds** and the axiom printouts are inspected.

These two identities are established elementary arithmetic, not original discoveries, and **do not imply** the full F_(3^r) decoder theorem.

## Exact next proof target

Formalize the nonzero-phase recovery lemma in F9 (not just mod 3), with a fully specified two-round measurement model and a finitely checkable relative-phase alphabet. Then define the general characteristic-three field with r-dimensional F3 basis, show the cancellation/shift-transversal property and the query budget k+ceil(max(s−1,0)/r) under the exact input model stated in the manuscript. The construction and information-theoretic lower bound require separate formal objects.

Independently review the formal *statement* against [characteristic-three candidate PR #77](https://github.com/d3lefts/d3lefts/pull/77) and [unifying subgroup-power theorem PR #92](https://github.com/d3lefts/d3lefts/pull/92), including fixed vs adaptive measurements, subgroup-power model, zero-coordinate conventions and full-field operations. Mechanically proving an easier lemma never upgrades the more general manuscript.

## Gates

**R0:** exact manuscript statement frozen; **R1:** finite core lemma source and CI; **R2:** all-dependency kernel check, no-sorry audit, independent statement/proof comparison; **R3:** first actual kernel-checked *decoder theorem* with exact toolchain and checker receipt; **R4:** independent mathematical novelty and significance review. The site must not label any headline theorem formalized until R3.
