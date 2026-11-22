import Mathlib
import ProductBUCompactFiber

/-!
# Genuine free antipodal homeomorphisms of the exact homotopy zero fiber

For a zero-preserving augmented Euclidean response, both independent input
sign flips induce actual self-homeomorphisms of its original zero-fiber
subtype. Their three nonidentity actions are pointwise fixed-point-free,
because neither unit input vector is zero.

This is an exact topological *action* bridge toward the product-sphere
interval-component contradiction. It does not construct a manifold with
boundary, its interval component, the reference boundary orbit, or the
unconditional ProductSphereZero theorem.
-/

namespace Nightfall.ProductBUFiberFreeAction
open Nightfall.ProductSphereObstruction Nightfall.ProductBUCompactFiber

abbrev Z (n m : ℕ) (F : SpaceTime n → Values m) := zeroFiber n m F

def flipU {n : ℕ} (p : SpaceTime n) : SpaceTime n :=
  ((-p.1.1, p.1.2), p.2)

def flipV {n : ℕ} (p : SpaceTime n) : SpaceTime n :=
  ((p.1.1, -p.1.2), p.2)

def flipUV {n : ℕ} (p : SpaceTime n) : SpaceTime n :=
  ((-p.1.1, -p.1.2), p.2)

theorem flipU_involutive (n : ℕ) : Function.Involutive (@flipU n) := by
  intro p
  rcases p with ⟨⟨u, v⟩, t⟩
  simp [flipU]

theorem flipV_involutive (n : ℕ) : Function.Involutive (@flipV n) := by
  intro p
  rcases p with ⟨⟨u, v⟩, t⟩
  simp [flipV]

theorem flipUV_involutive (n : ℕ) : Function.Involutive (@flipUV n) := by
  intro p
  rcases p with ⟨⟨u, v⟩, t⟩
  simp [flipUV]

theorem flipU_continuous (n : ℕ) : Continuous (@flipU n) := by
  unfold flipU
  fun_prop

theorem flipV_continuous (n : ℕ) : Continuous (@flipV n) := by
  unfold flipV
  fun_prop

theorem flipUV_continuous (n : ℕ) : Continuous (@flipUV n) := by
  unfold flipUV
  fun_prop

theorem unitVec_neg (n : ℕ) (u : Fin n → ℝ)
    (hu : UnitVec n u) : UnitVec n (-u) := by
  simpa [UnitVec, Pi.neg_apply, neg_sq] using hu

theorem zeroFiber_flipU (n m : ℕ) (F : SpaceTime n → Values m)
    (hF : ∀ p, F p = 0 → F (flipU p) = 0)
    {p : SpaceTime n} (hp : p ∈ Z n m F) : flipU p ∈ Z n m F := by
  have hz := zeroFiber_mem n m F hp
  refine ⟨?_, ?_⟩
  · exact ⟨⟨unitVec_neg n p.1.1 hz.1.1, hz.1.2⟩, hz.2.1⟩
  · exact hF p hz.2.2

theorem zeroFiber_flipV (n m : ℕ) (F : SpaceTime n → Values m)
    (hF : ∀ p, F p = 0 → F (flipV p) = 0)
    {p : SpaceTime n} (hp : p ∈ Z n m F) : flipV p ∈ Z n m F := by
  have hz := zeroFiber_mem n m F hp
  refine ⟨?_, ?_⟩
  · exact ⟨⟨hz.1.1, unitVec_neg n p.1.2 hz.1.2⟩, hz.2.1⟩
  · exact hF p hz.2.2

theorem zeroFiber_flipUV (n m : ℕ) (F : SpaceTime n → Values m)
    (hF : ∀ p, F p = 0 → F (flipUV p) = 0)
    {p : SpaceTime n} (hp : p ∈ Z n m F) : flipUV p ∈ Z n m F := by
  have hz := zeroFiber_mem n m F hp
  refine ⟨?_, ?_⟩
  · exact ⟨⟨unitVec_neg n p.1.1 hz.1.1,
       unitVec_neg n p.1.2 hz.1.2⟩, hz.2.1⟩
  · exact hF p hz.2.2

noncomputable def eU (n m : ℕ) (F : SpaceTime n → Values m)
    (hF : ∀ p, F p = 0 → F (flipU p) = 0) : Z n m F ≃ₜ Z n m F where
  toFun p := ⟨flipU p.1, zeroFiber_flipU n m F hF p.2⟩
  invFun p := ⟨flipU p.1, zeroFiber_flipU n m F hF p.2⟩
  left_inv p := Subtype.ext (flipU_involutive n p.1)
  right_inv p := Subtype.ext (flipU_involutive n p.1)
  continuous_toFun := by
    exact Continuous.subtype_mk
      ((flipU_continuous n).comp continuous_subtype_val) _
  continuous_invFun := by
    exact Continuous.subtype_mk
      ((flipU_continuous n).comp continuous_subtype_val) _

noncomputable def eV (n m : ℕ) (F : SpaceTime n → Values m)
    (hF : ∀ p, F p = 0 → F (flipV p) = 0) : Z n m F ≃ₜ Z n m F where
  toFun p := ⟨flipV p.1, zeroFiber_flipV n m F hF p.2⟩
  invFun p := ⟨flipV p.1, zeroFiber_flipV n m F hF p.2⟩
  left_inv p := Subtype.ext (flipV_involutive n p.1)
  right_inv p := Subtype.ext (flipV_involutive n p.1)
  continuous_toFun := by
    exact Continuous.subtype_mk
      ((flipV_continuous n).comp continuous_subtype_val) _
  continuous_invFun := by
    exact Continuous.subtype_mk
      ((flipV_continuous n).comp continuous_subtype_val) _

noncomputable def eUV (n m : ℕ) (F : SpaceTime n → Values m)
    (hF : ∀ p, F p = 0 → F (flipUV p) = 0) : Z n m F ≃ₜ Z n m F where
  toFun p := ⟨flipUV p.1, zeroFiber_flipUV n m F hF p.2⟩
  invFun p := ⟨flipUV p.1, zeroFiber_flipUV n m F hF p.2⟩
  left_inv p := Subtype.ext (flipUV_involutive n p.1)
  right_inv p := Subtype.ext (flipUV_involutive n p.1)
  continuous_toFun := by
    exact Continuous.subtype_mk
      ((flipUV_continuous n).comp continuous_subtype_val) _
  continuous_invFun := by
    exact Continuous.subtype_mk
      ((flipUV_continuous n).comp continuous_subtype_val) _

theorem eU_no_fixed (n m : ℕ) (F : SpaceTime n → Values m)
    (hF : ∀ p, F p = 0 → F (flipU p) = 0)
    (p : Z n m F) : eU n m F hF p ≠ p := by
  intro h
  have he : -p.1.1.1 = p.1.1.1 := by
    have he' := congrArg (fun z : Z n m F => z.1.1.1) h
    simpa [eU, flipU] using he'
  have hzero : p.1.1.1 = 0 := by
    funext i
    have hi := congrFun he i
    change -(p.1.1.1 i) = p.1.1.1 i at hi
    change p.1.1.1 i = (0 : ℝ)
    linarith
  have hunit := (zeroFiber_mem n m F p.2).1.1
  exact (unitVec_ne_zero n p.1.1.1 hunit) hzero

theorem eV_no_fixed (n m : ℕ) (F : SpaceTime n → Values m)
    (hF : ∀ p, F p = 0 → F (flipV p) = 0)
    (p : Z n m F) : eV n m F hF p ≠ p := by
  intro h
  have he : -p.1.1.2 = p.1.1.2 := by
    have he' := congrArg (fun z : Z n m F => z.1.1.2) h
    simpa [eV, flipV] using he'
  have hzero : p.1.1.2 = 0 := by
    funext i
    have hi := congrFun he i
    change -(p.1.1.2 i) = p.1.1.2 i at hi
    change p.1.1.2 i = (0 : ℝ)
    linarith
  have hunit := (zeroFiber_mem n m F p.2).1.2
  exact (unitVec_ne_zero n p.1.1.2 hunit) hzero

theorem eUV_no_fixed (n m : ℕ) (F : SpaceTime n → Values m)
    (hF : ∀ p, F p = 0 → F (flipUV p) = 0)
    (p : Z n m F) : eUV n m F hF p ≠ p := by
  intro h
  have he : -p.1.1.1 = p.1.1.1 := by
    have he' := congrArg (fun z : Z n m F => z.1.1.1) h
    simpa [eUV, flipUV] using he'
  have hzero : p.1.1.1 = 0 := by
    funext i
    have hi := congrFun he i
    change -(p.1.1.1 i) = p.1.1.1 i at hi
    change p.1.1.1 i = (0 : ℝ)
    linarith
  have hunit := (zeroFiber_mem n m F p.2).1.1
  exact (unitVec_ne_zero n p.1.1.1 hunit) hzero

#print axioms eU_no_fixed
#print axioms eV_no_fixed
#print axioms eUV_no_fixed

end Nightfall.ProductBUFiberFreeAction
