# Vendored: Turturean's Lean proof of the Aaronson–Ambainis conjecture (subset)

* Upstream: `physical-superintelligence/aaronson-ambainis`, commit
  `2a6ceaef872ae993708950f951989134084b851a` (2026-11-06), by David Turturean.
* License: Apache-2.0 (see `LICENSE`, `NOTICE`). Copyright 2026 David Turturean.
* Scope: the 43 modules in the import closure of the NIGHTFALL product-space chain
  (`ProductSpaceTwoSidedBridge`, `ProductRowBound`, `ProductInfluence`), plus 7 statement and
  transport modules used by `product_space/CubePrintedAA.lean` (`Conjecture`, `Level/Basic`,
  `Bridge/{Fourier,Algebra,Poly,Affine,PrintedAA}`), unchanged except:
  * `AaronsonAmbainis/DetLow/Unit.lean`, `AaronsonAmbainis/DetBij/Perm.lean`: `MvPolynomial.coeff`
    argument order updated for the pinned Mathlib (`coeff p m` since 2026-07). Each modified
    file carries a notice at the top.
* Purpose: compile the finite product-space theorem `Heterogeneous.heterogeneous_influence`
  at the repository's pinned Lean 4.36.0-rc2 / Mathlib `9d581dff` instead of the retired
  Lean 4.33 workspace. All mathematical credit for the vendored proof belongs to the upstream
  author.

* `Conjecture.lean` is byte-identical to upstream (sha256 `dd63776b…3a52`). Upstream's cube
  theorem (`MainTheorem.lean`, `Chain.lean`, `Main.lean`) is not vendored: `CubePrintedAA`
  proves `AaronsonAmbainis.MainTheorem` from the NIGHTFALL product-space chain and passes it to
  the upstream transport lemmas `zo_pow_of_mainTheorem` / `zo_sqrt_of_mainTheorem`.
