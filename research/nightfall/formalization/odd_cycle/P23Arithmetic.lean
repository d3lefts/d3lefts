import Init

namespace Nightfall.OddCycle

/-- Arithmetic consequence of the odd-cycle overlap estimate for p = 23,
r = 2. This is NOT a proof of the underlying combinatorial estimate. -/
theorem p23_capacity_arithmetic (codeSize : Nat)
    (overlap_bound : codeSize ≤ ((23 - 1) / 2) * 23 + 1) :
    codeSize < 2 ^ 8 := by
  exact Nat.lt_of_le_of_lt overlap_bound (by decide)

/-- At p = 23 and r = 2, the proposed universal overlap ceiling
is strictly smaller than the eight-sign alphabet. -/
theorem p23_numeric_gap :
    ((23 - 1) / 2) * 23 + 1 < 2 ^ 8 := by
  decide

end Nightfall.OddCycle
