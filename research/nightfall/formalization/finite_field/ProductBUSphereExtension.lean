import Mathlib
import ProductSphereObstruction

/-!
# Continuous extension of product-sphere test responses

The product-sphere topology interface uses maps continuous only on the
embedded product of unit spheres. The globally-defined continuous maps
required by the ambient Euclidean smoothing operator can be produced
from the pinned Mathlib Tietze extension theorem, after proving the
product-sphere set is closed. No extension or topology theorem is assumed.

This is purely a continuity/representation result. It does not prove
a zero of a separately equivariant map, a transversality theorem, or
one-manifold boundary parity. Preservation of antipodal characters
requires the independent Reynolds projector (#1032).
-/

namespace Nightfall.ProductBUSphereExtension

open Nightfall.ProductSphereObstruction
abbrev V (n : ℕ) := Fin n → ℝ

/-- The product-sphere defined by the original zero proposition is a
closed subset of the ambient finite-dimensional real vector space. -/
theorem spherePair_isClosed (n : ℕ) :
    IsClosed (SpherePair n) := by
  have hn : Continuous (fun u : V n => ∑ i : Fin n, u i ^ 2) := by
    fun_prop
  have hn1 : Continuous
      (fun z : V n × V n => ∑ i : Fin n, z.1 i ^ 2) :=
    hn.comp continuous_fst
  have hn2 : Continuous
      (fun z : V n × V n => ∑ i : Fin n, z.2 i ^ 2) :=
    hn.comp continuous_snd
  have hc1 : IsClosed {z : V n × V n | UnitVec n z.1} := by
    simpa [UnitVec] using
      (isClosed_eq hn1
        (continuous_const : Continuous (fun _ : V n × V n => (1 : ℝ))))
  have hc2 : IsClosed {z : V n × V n | UnitVec n z.2} := by
    simpa [UnitVec] using
      (isClosed_eq hn2
        (continuous_const : Continuous (fun _ : V n × V n => (1 : ℝ))))
  simpa [SpherePair, Set.ofPred_and] using hc1.inter hc2

/-- Any real-valued map continuous on the product sphere extends to
a globally continuous ambient map agreeing EXACTLY at every point
on the original product of unit spheres.

This uses a theorem already present at the pinned Mathlib revision:
ContinuousMap.exists_restrict_eq (closed-subspace Tietze).
It does not use an unbounded-map shortcut or introduce an axiom. -/
theorem exists_continuous_extension (n : ℕ)
    (f : (V n × V n) → ℝ)
    (hf : ContinuousOn f (SpherePair n)) :
    ∃ g : (V n × V n) → ℝ,
      Continuous g ∧ Set.EqOn g f (SpherePair n) := by
  let s : Set (V n × V n) := SpherePair n
  have hs : IsClosed s := spherePair_isClosed n
  let fsub : C(s, ℝ) := ⟨fun p => f p.1, hf.domRestrict⟩
  obtain ⟨G, hG⟩ := ContinuousMap.exists_restrict_eq hs fsub
  refine ⟨G, G.continuous, ?_⟩
  intro x hx
  have h := congrArg (fun H : C(s, ℝ) => H ⟨x,hx⟩) hG
  change G x = f x at h
  exact h

#print spherePair_isClosed
#print axioms spherePair_isClosed
#print exists_continuous_extension
#print axioms exists_continuous_extension

end Nightfall.ProductBUSphereExtension
