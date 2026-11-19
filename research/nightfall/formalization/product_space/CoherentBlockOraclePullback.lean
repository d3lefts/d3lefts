import Mathlib

/-!
# Coherent block-oracle pullback: reversible fetch, fixed decode, uncompute

A standard coherent value oracle can be implemented on an ancilla-zero
subspace by (1) coherently fetching a seed block, (2) applying the fixed
decoded symbol update, and (3) uncomputing the seed block.

This file proves that identity on *basis vectors and arbitrary complex
superpositions* and proves norm preservation of the resulting finite
permutation action. It treats one packed W-valued fetch as a primitive;
the additional decomposition into exactly m controlled bit queries and
the quantitative BDST application remain explicit independent obligations.

There are no assumptions asserting the desired simulation bound.
-/

namespace Nightfall.CoherentBlockOracle

variable {I W Z : Type*} [AddCommGroup W] [AddCommGroup Z]

/-- Query index, response register, and auxiliary seed-block workspace. -/
abbrev Reg (I Z W : Type*) := I × Z × W

/-- Coherently add the block U_i into the workspace. -/
def fetch (U : I → W) (s : Reg I Z W) : Reg I Z W :=
  (s.1, s.2.1, s.2.2 + U s.1)

/-- Uncompute the fetched block without measuring the index. -/
def uncompute (U : I → W) (s : Reg I Z W) : Reg I Z W :=
  (s.1, s.2.1, s.2.2 - U s.1)

/-- The decoder is a fixed, input-independent controlled group update. -/
def decode (D : I → W → Z) (s : Reg I Z W) : Reg I Z W :=
  (s.1, s.2.1 + D s.1 s.2.2, s.2.2)

/-- Inverse of the fixed decoder gate. -/
def undoDecode (D : I → W → Z) (s : Reg I Z W) : Reg I Z W :=
  (s.1, s.2.1 - D s.1 s.2.2, s.2.2)

theorem fetch_uncompute (U : I → W) (s : Reg I Z W) :
    uncompute U (fetch U s) = s := by
  rcases s with ⟨i, z, w⟩
  simp [fetch, uncompute]

theorem uncompute_fetch (U : I → W) (s : Reg I Z W) :
    fetch U (uncompute U s) = s := by
  rcases s with ⟨i, z, w⟩
  simp [fetch, uncompute]

theorem decode_undoDecode (D : I → W → Z) (s : Reg I Z W) :
    undoDecode D (decode D s) = s := by
  rcases s with ⟨i, z, w⟩
  simp [decode, undoDecode]

theorem undoDecode_decode (D : I → W → Z) (s : Reg I Z W) :
    decode D (undoDecode D s) = s := by
  rcases s with ⟨i, z, w⟩
  simp [decode, undoDecode]

/-- The three-stage oracle is an actual bijection on the entire register.
Its inverse is explicit, so the finite complex linear extension is unitary. -/
def compiledOracle (U : I → W) (D : I → W → Z) :
    Reg I Z W ≃ Reg I Z W where
  toFun s := (s.1, s.2.1 + D s.1 (s.2.2 + U s.1), s.2.2)
  invFun s := (s.1, s.2.1 - D s.1 (s.2.2 + U s.1), s.2.2)
  left_inv := by
    rintro ⟨i, z, w⟩
    change (i, z + D i (w + U i) - D i (w + U i), w) = (i, z, w)
    simp
  right_inv := by
    rintro ⟨i, z, w⟩
    change (i, z - D i (w + U i) + D i (w + U i), w) = (i, z, w)
    simp

/-- Exact basis-level equivalence with fetch–decode–uncompute. -/
theorem compiledOracle_three_stage (U : I → W) (D : I → W → Z)
    (s : Reg I Z W) :
    compiledOracle U D s = uncompute U (decode D (fetch U s)) := by
  rcases s with ⟨i, z, w⟩
  change (i, z + D i (w + U i), w) =
    (i, z + D i (w + U i), (w + U i) - U i)
  simp

/-- The ancilla-zero subspace implements precisely the decoded
coherent symbol-value oracle, with the seed workspace restored to zero. -/
theorem compiledOracle_zero (U : I → W) (D : I → W → Z)
    (i : I) (z : Z) :
    compiledOracle U D (i, z, (0 : W)) =
      (i, z + D i (U i), (0 : W)) := by
  simp [compiledOracle]

/-- Action of a basis permutation on complex amplitudes. It is a
linear permutation action, not a postulated stochastic approximation. -/
noncomputable def permute {S : Type*} (e : S ≃ S)
    (ψ : S → ℂ) : S → ℂ :=
  fun s => ψ (e.symm s)

/-- Embed an arbitrary quantum state with a clean workspace. -/
noncomputable def cleanWorkspace
    (ψ : (I × Z) → ℂ) : Reg I Z W → ℂ := by
  classical
  exact fun s => if s.2.2 = 0 then ψ (s.1, s.2.1) else 0

/-- Full coherent amplitude identity, not just a computational-basis test:
the three-stage permutation transforms every superposition exactly as
the decoded symbol oracle would, leaving the workspace clean. -/
theorem coherent_pullback (U : I → W) (D : I → W → Z)
    (ψ : (I × Z) → ℂ) :
    permute (compiledOracle U D) (cleanWorkspace ψ) =
      cleanWorkspace
        (fun iz => ψ (iz.1, iz.2 - D iz.1 (U iz.1))) := by
  classical
  funext s
  rcases s with ⟨i, z, w⟩
  change
    (if w = 0 then ψ (i, z - D i (w + U i)) else 0) =
    (if w = 0 then ψ (i, z - D i (U i)) else 0)
  by_cases hw : w = 0
  · subst w
    simp
  · simp [hw]

/-- Squared Hermitian norm of a finite vector. -/
noncomputable def energy {S : Type*} [Fintype S] (ψ : S → ℂ) : ℝ :=
  ∑ s : S, Complex.normSq (ψ s)

/-- A finite basis permutation preserves the actual quantum norm. -/
theorem permutation_energy {S : Type*} [Fintype S]
    (e : S ≃ S) (ψ : S → ℂ) :
    energy (permute e ψ) = energy ψ := by
  classical
  unfold energy permute
  apply Fintype.sum_equiv e.symm
    (fun s : S => Complex.normSq (ψ (e.symm s)))
    (fun s : S => Complex.normSq (ψ s))
  intro s
  rfl

/-- The reversible coherent block-oracle circuit is unitary in the
operational norm-preservation sense, for every complex input state. -/
theorem compiledOracle_unitary [Fintype I] [Fintype Z] [Fintype W]
    (U : I → W) (D : I → W → Z) (ψ : Reg I Z W → ℂ) :
    energy (permute (compiledOracle U D) ψ) = energy ψ :=
  permutation_energy (compiledOracle U D) ψ

/-- In the Boolean-bit realization, a packed fetch modifies the j-th
workspace bit by exactly the j-th seed-oracle bit. This is the
per-bit semantic equation required by a subsequent query-count proof. -/
theorem bit_fetch_coordinate (m : ℕ)
    (U : I → (Fin m → ZMod 2))
    (i : I) (z : Z) (w : Fin m → ZMod 2) (j : Fin m) :
    (fetch U (i, z, w)).2.2 j = w j + U i j := by
  rfl

#print axioms Nightfall.CoherentBlockOracle.compiledOracle_zero
#print axioms Nightfall.CoherentBlockOracle.coherent_pullback
#print axioms Nightfall.CoherentBlockOracle.permutation_energy
#print axioms Nightfall.CoherentBlockOracle.compiledOracle_unitary
#print axioms Nightfall.CoherentBlockOracle.bit_fetch_coordinate

end Nightfall.CoherentBlockOracle
