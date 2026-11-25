import Mathlib

/-! Harmless query padding for a standard finite additive response oracle.
An inactive branch swaps its active register with a fixed-address uniform
response register, executes the same oracle, then swaps back. The theorem
uses amplitudes directly; no controlled-oracle or additional query. -/

namespace Nightfall.ResponsePadding

variable {I G : Type} [DecidableEq I] [AddCommGroup G]

abbrev Reg (I G : Type) := I × G
abbrev State (I G : Type) := Reg I G × Reg I G

def back (x : I → G) (s : Reg I G) : Reg I G :=
  (s.1, s.2 - x s.1)

def response (x : I → G) (v : State I G → ℂ) : State I G → ℂ :=
  fun s => v (back x s.1, s.2)

def swap (v : State I G → ℂ) : State I G → ℂ :=
  fun s => v (s.2, s.1)

/-- Uniform response amplitude, with any scalar normalization c;
the fixed address is i0. -/
noncomputable def padded (i0 : I) (c : ℂ) (v : Reg I G → ℂ) :
    State I G → ℂ :=
  fun s => if s.2.1 = i0 then c * v s.1 else 0

theorem swap_involution (v : State I G → ℂ) : swap (swap v) = v := by
  funext s
  rcases s with ⟨a, b⟩
  rfl

theorem harmless_query_padding (x : I → G) (i0 : I) (c : ℂ)
    (v : Reg I G → ℂ) :
    swap (response x (swap (padded i0 c v))) = padded i0 c v := by
  funext s
  rcases s with ⟨a, b⟩
  rfl

/-- On a direct sum of active and inactive branches, one common response
operator with branch-controlled swaps is exactly the intended conditional
semantics; the inactive branch does not need a controlled black box. -/
def selectSwap (v : Bool → State I G → ℂ) : Bool → State I G → ℂ :=
  fun b => if b then v b else swap (v b)

def commonResponse (x : I → G) (v : Bool → State I G → ℂ) :
    Bool → State I G → ℂ :=
  fun b => response x (v b)

theorem conditional_padding (x : I → G) (i0 : I) (c : ℂ)
    (active : State I G → ℂ) (inactive : Reg I G → ℂ) :
    selectSwap (commonResponse x (selectSwap
      (fun b => if b then active else padded i0 c inactive))) =
      (fun b => if b then response x active else padded i0 c inactive) := by
  funext b
  cases b
  · simpa [selectSwap, commonResponse] using harmless_query_padding x i0 c inactive
  · simp [selectSwap, commonResponse]

end Nightfall.ResponsePadding

#print axioms Nightfall.ResponsePadding.harmless_query_padding
#print axioms Nightfall.ResponsePadding.conditional_padding
