import Mathlib
import ProductSphereObstruction

/-! Paper III v7, Lemma 3.1 topology route: the independent-antipode
Reynolds projection preserves smoothness and uniform approximation
on the actual product sphere. This removes the parity-preservation
step of smoothing, not the existence of a smooth approximant or Sard. -/
namespace Nightfall.ProductBUReynolds
open Nightfall.ProductSphereObstruction
open scoped ContDiff
abbrev V (n : ℕ) := Fin n → ℝ

def pureU {n : ℕ} (f : V n → V n → ℝ) (u v : V n) : ℝ :=
  (f u v - f (-u) v + f u (-v) - f (-u) (-v)) / 4

def pureV {n : ℕ} (f : V n → V n → ℝ) (u v : V n) : ℝ :=
  pureU (fun x y => f y x) v u

theorem pureU_odd {n : ℕ} (f : V n → V n → ℝ) (u v : V n) :
    pureU f (-u) v = -pureU f u v := by
  simp only [pureU, neg_neg]
  ring

theorem pureU_even {n : ℕ} (f : V n → V n → ℝ) (u v : V n) :
    pureU f u (-v) = pureU f u v := by
  simp only [pureU, neg_neg]
  ring

theorem pureV_even {n : ℕ} (f : V n → V n → ℝ) (u v : V n) :
    pureV f (-u) v = pureV f u v := pureU_even _ _ _

theorem pureV_odd {n : ℕ} (f : V n → V n → ℝ) (u v : V n) :
    pureV f u (-v) = -pureV f u v := pureU_odd _ _ _

theorem pureU_smooth {n : ℕ} (f : V n → V n → ℝ)
    (hf : ContDiff ℝ (⊤ : ℕ∞) (fun p : V n × V n => f p.1 p.2)) :
    ContDiff ℝ (⊤ : ℕ∞) (fun p : V n × V n => pureU f p.1 p.2) := by
  have h1 : ContDiff ℝ (⊤ : ℕ∞) (fun p : V n × V n => f (-p.1) p.2) :=
    hf.comp (by fun_prop : ContDiff ℝ (⊤ : ℕ∞) (fun p : V n × V n => (-p.1,p.2)))
  have h2 : ContDiff ℝ (⊤ : ℕ∞) (fun p : V n × V n => f p.1 (-p.2)) :=
    hf.comp (by fun_prop : ContDiff ℝ (⊤ : ℕ∞) (fun p : V n × V n => (p.1,-p.2)))
  have h3 : ContDiff ℝ (⊤ : ℕ∞) (fun p : V n × V n => f (-p.1) (-p.2)) :=
    hf.comp (by fun_prop : ContDiff ℝ (⊤ : ℕ∞) (fun p : V n × V n => (-p.1,-p.2)))
  unfold pureU
  exact (((hf.sub h1).add h2).sub h3).div_const 4

theorem pureV_smooth {n : ℕ} (f : V n → V n → ℝ)
    (hf : ContDiff ℝ (⊤ : ℕ∞) (fun p : V n × V n => f p.1 p.2)) :
    ContDiff ℝ (⊤ : ℕ∞) (fun p : V n × V n => pureV f p.1 p.2) := by
  have hs : ContDiff ℝ (⊤ : ℕ∞) (fun p : V n × V n => (p.2,p.1)) := by fun_prop
  have ht : ContDiff ℝ (⊤ : ℕ∞) (fun p : V n × V n => f p.2 p.1) := hf.comp hs
  exact (pureU_smooth (fun x y => f y x) ht).comp hs

private theorem unit_neg {n : ℕ} {u : V n} (hu : UnitVec n u) :
    UnitVec n (-u) := by
  simpa [UnitVec] using hu

/-- A scalar pure-U approximation on the actual product sphere keeps
the same uniform error after symmetrization. -/
theorem pureU_uniform_error {n : ℕ} (f g : V n → V n → ℝ) (eps : ℝ)
    (hodd : ∀ u v, UnitVec n u → UnitVec n v → g (-u) v = -g u v)
    (heven : ∀ u v, UnitVec n u → UnitVec n v → g u (-v) = g u v)
    (happrox : ∀ u v, UnitVec n u → UnitVec n v → |f u v - g u v| ≤ eps)
    (u v : V n) (hu : UnitVec n u) (hv : UnitVec n v) :
    |pureU f u v - g u v| ≤ eps := by
  have hn := unit_neg hu
  have hm := unit_neg hv
  have e1 := abs_le.mp (happrox u v hu hv)
  have e2 := abs_le.mp (happrox (-u) v hn hv)
  have e3 := abs_le.mp (happrox u (-v) hu hm)
  have e4 := abs_le.mp (happrox (-u) (-v) hn hm)
  rw [hodd u v hu hv] at e2
  rw [heven u v hu hv] at e3
  rw [hodd u (-v) hu hm, heven u v hu hv] at e4
  apply abs_le.mpr
  unfold pureU
  constructor <;> linarith [e1.1,e1.2,e2.1,e2.2,e3.1,e3.2,e4.1,e4.2]

theorem pureV_uniform_error {n : ℕ} (f g : V n → V n → ℝ) (eps : ℝ)
    (heven : ∀ u v, UnitVec n u → UnitVec n v → g (-u) v = g u v)
    (hodd : ∀ u v, UnitVec n u → UnitVec n v → g u (-v) = -g u v)
    (happrox : ∀ u v, UnitVec n u → UnitVec n v → |f u v - g u v| ≤ eps)
    (u v : V n) (hu : UnitVec n u) (hv : UnitVec n v) :
    |pureV f u v - g u v| ≤ eps :=
  pureU_uniform_error (fun x y => f y x) (fun x y => g y x) eps
    (fun x y hx hy => hodd y x hy hx)
    (fun x y hx hy => heven y x hy hx)
    (fun x y hx hy => happrox y x hy hx) v u hv hu

#print axioms pureU_odd
#print axioms pureU_even
#print axioms pureV_even
#print axioms pureV_odd
#print axioms pureU_smooth
#print axioms pureV_smooth
#print axioms pureU_uniform_error
#print axioms pureV_uniform_error
end Nightfall.ProductBUReynolds
