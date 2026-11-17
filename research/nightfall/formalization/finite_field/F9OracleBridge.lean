import Mathlib

/-!
NIGHTFALL F9 same-oracle bridge: (1) a *genuinely squared* two-sign block
can be decoded from a characteristic-three two-dimensional field basis,
and (2) the classical complement collision for actual squared K-linear
measurements, conditional only on a pair of nonzero kernel witnesses.

This does not yet supply the all-k partition/existence theorem or the
all-k adaptive protocol. No stronger terminal scope is claimed.
-/

namespace Nightfall.FiniteField.F9OracleBridge
open scoped BigOperators
noncomputable section

def signBit (b : Bool) : ZMod 3 := if b then 2 else 0

theorem signBit_injective : Function.Injective signBit := by
  intro a b h
  have h20 : (2 : ZMod 3) ≠ 0 := by decide
  cases a <;> cases b <;> simp_all [signBit]

theorem signBit_neg_collision (a b : Bool)
    (h : signBit a = -signBit b) : a = b := by
  have h20 : (2 : ZMod 3) ≠ 0 := by decide
  have h02 : (0 : ZMod 3) ≠ -(2 : ZMod 3) := by decide
  have h22 : (2 : ZMod 3) ≠ -(2 : ZMod 3) := by decide
  cases a <;> cases b <;> simp_all [signBit]

variable {K : Type*} [Field K] [Algebra (ZMod 3) K]

def blockValue (β : Module.Basis (Fin 2) (ZMod 3) K)
    (bits : Fin 2 → Bool) : K :=
  β.equivFun.symm (fun i => signBit (bits i))

theorem block_value_squared_injective
    (β : Module.Basis (Fin 2) (ZMod 3) K)
    (a b : Fin 2 → Bool)
    (h : (blockValue β a) ^ 2 = (blockValue β b) ^ 2) :
    a = b := by
  have hsq : blockValue β a * blockValue β a =
      blockValue β b * blockValue β b := by
    simpa only [pow_two] using h
  have hchoice := (mul_self_eq_mul_self_iff).mp hsq
  rcases hchoice with hsame | hminus
  · have hcoordinate :
        (fun i : Fin 2 => signBit (a i)) =
          (fun i : Fin 2 => signBit (b i)) := by
      have hs := congrArg (fun y : K => β.equivFun y) hsame
      simpa only [blockValue, β.equivFun.apply_symm_apply] using hs
    funext i
    exact signBit_injective (congrArg (fun f : Fin 2 → ZMod 3 => f i) hcoordinate)
  · have hcoordinate :
        (fun i : Fin 2 => signBit (a i)) =
          -(fun i : Fin 2 => signBit (b i)) := by
      have hs := congrArg (fun y : K => β.equivFun y) hminus
      simpa only [blockValue, map_neg, β.equivFun.apply_symm_apply] using hs
    funext i
    exact signBit_neg_collision (a i) (b i)
      (by simpa using congrArg (fun f : Fin 2 → ZMod 3 => f i) hcoordinate)

section Complement
variable {k m : ℕ}

def dot (a x : Fin k → K) : K := ∑ j, a j * x j

theorem dot_add (a u v : Fin k → K) :
    dot a (u + v) = dot a u + dot a v := by
  simp [dot, Pi.add_apply, mul_add, Finset.sum_add_distrib]

theorem dot_sub (a u v : Fin k → K) :
    dot a (u - v) = dot a u - dot a v := by
  simp [dot, Pi.sub_apply, mul_sub, Finset.sum_sub_distrib]

theorem complement_kernel_collision
    (rows : Fin m → Fin k → K) (u v : Fin k → K)
    (hpartition : ∀ r, dot (rows r) u = 0 ∨ dot (rows r) v = 0) :
    ∀ r, (dot (rows r) (u + v)) ^ 2 =
      (dot (rows r) (u - v)) ^ 2 := by
  intro r
  rw [dot_add, dot_sub]
  rcases hpartition r with hu | hv
  · rw [hu]
    ring
  · rw [hv]
    ring

theorem complement_witness_not_sign_equivalent
    (u v : Fin k → K) (hu : u ≠ 0) (hv : v ≠ 0)
    (h2 : (2 : K) ≠ 0) :
    u + v ≠ u - v ∧ u + v ≠ -(u - v) := by
  constructor
  · intro heq
    apply hv
    funext j
    have hj := congrArg (fun f : Fin k → K => f j) heq
    have hzero : (2 : K) * v j = 0 := by
      dsimp [Pi.add_apply, Pi.sub_apply] at hj
      linear_combination hj
    exact (mul_eq_zero.mp hzero).resolve_left h2
  · intro heq
    apply hu
    funext j
    have hj := congrArg (fun f : Fin k → K => f j) heq
    have hzero : (2 : K) * u j = 0 := by
      dsimp [Pi.add_apply, Pi.sub_apply, Pi.neg_apply] at hj
      linear_combination hj
    exact (mul_eq_zero.mp hzero).resolve_left h2

end Complement

#print axioms Nightfall.FiniteField.F9OracleBridge.signBit_injective
#print axioms Nightfall.FiniteField.F9OracleBridge.signBit_neg_collision
#print axioms Nightfall.FiniteField.F9OracleBridge.block_value_squared_injective
#print axioms Nightfall.FiniteField.F9OracleBridge.dot_add
#print axioms Nightfall.FiniteField.F9OracleBridge.dot_sub
#print axioms Nightfall.FiniteField.F9OracleBridge.complement_kernel_collision
#print axioms Nightfall.FiniteField.F9OracleBridge.complement_witness_not_sign_equivalent

end
end Nightfall.FiniteField.F9OracleBridge
