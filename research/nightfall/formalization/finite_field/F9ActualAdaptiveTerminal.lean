import Mathlib
import F9PhysicalSquareBlock
import F9AllSupportNormalForm
import F9SignPacketAllK
import F9ConcreteLower

/-!
# NIGHTFALL — all-source actual GF9 square-power adaptive decoder

This module composes the existing field basis, square-source normalization,
source-calibrated legal linear measurements and arbitrary-length bit packets.
All mathematical statements below are explicitly source-derived, never
assuming an unsquared measurement or an opaque oracle-complexity premise.
-/

namespace Nightfall.FiniteField.F9ActualAdaptiveTerminal
open Nightfall.FiniteField.F9CalibratedRow
open Nightfall.FiniteField.F9PhysicalSquareBlock
open Nightfall.FiniteField.F9AllSupportNormalForm
open Nightfall.FiniteField.F9SignPacketAllK
open Nightfall.FiniteField.F9OracleBridge
abbrev F9 := Nightfall.FiniteField.F9ActualField.F9
noncomputable section

theorem phase_to_digit (b : Bool) :
    (1 : F9) + phase b = digit b := by
  cases b <;> simp [phase, digit] <;> ring

theorem root_zero : canonicalRoot (0 : F9) = 0 := by
  have h : (canonicalRoot (0 : F9)) ^ 2 = 0 := by
    simpa using canonicalRoot_square (0 : F9)
  exact (sq_eq_zero_iff).mp h

theorem weighted_slot_cancel (u v e t : F9)
    (h : u ≠ 0 ∨ v = 0) :
    (v / u) * (e * t * u) = e * v * t := by
  rcases h with hu | hv
  · field_simp [hu] <;> ring
  · simp [hv]

theorem actual_two_digit_with_zero_slots
    (u0 u1 u2 v w e : F9)
    (b0 b1 : Bool)
    (hu0 : u0 ≠ 0)
    (hu1 : u1 ≠ 0 ∨ v = 0)
    (hu2 : u2 ≠ 0 ∨ w = 0)
    (he : e ^ 2 = 1) :
    (((v + w) / u0) * (e * u0) +
       (v / u1) * (e * phase b0 * u1) +
       (w / u2) * (e * phase b1 * u2)) ^ 2 =
       (v * digit b0 + w * digit b1) ^ 2 := by
  have ha : ((v + w) / u0) * (e * u0) = e * (v + w) := by
    field_simp [hu0] <;> ring
  have hb : (v / u1) * (e * phase b0 * u1) =
      e * v * phase b0 :=
    weighted_slot_cancel u1 v e (phase b0) hu1
  have hc : (w / u2) * (e * phase b1 * u2) =
      e * w * phase b1 :=
    weighted_slot_cancel u2 w e (phase b1) hu2
  rw [ha, hb, hc]
  have hcombine :
      e * (v + w) + e * v * phase b0 + e * w * phase b1 =
        e * (v * (1 + phase b0) + w * (1 + phase b1)) := by ring
  rw [hcombine, phase_to_digit, phase_to_digit, mul_pow, he, one_mul]


/-- The calibrated root profile is a deterministic function of squared outputs. -/
noncomputable def rootProfile {n : ℕ} (q : Fin (n + 1) → F9) :
    Fin (n + 1) → F9 := fun i => canonicalRoot (q i)

/-- The first usable anchor need only be chosen from the measured square
profile, never from a private sign bit. -/
noncomputable def measuredAnchor {n : ℕ}
    (q : Fin (n + 1) → F9) : Fin (n + 1) := by
  classical
  exact if h : ∃ i, rootProfile q i ≠ 0 then Classical.choose h else 0

/-- Padding indexes are public: a missing last digit aliases the anchor,
whose coefficient is set to zero. -/
def slotIndex {n : ℕ} (a : Fin (n + 1))
    (block : Fin ((n + 1) / 2)) (d : Fin 2) : Fin (n + 1) :=
  if h : 2 * block.val + d.val < n then
    a.succAbove ⟨2 * block.val + d.val, h⟩
  else a

/-- A zero square represents a zero signal: the associated basis coefficient
is suppressed, rather than attempting to divide by its zero root. -/
noncomputable def slotWeight {n : ℕ}
    (q : Fin (n + 1) → F9) (a : Fin (n + 1))
    (block : Fin ((n + 1) / 2)) (d : Fin 2) : F9 := by
  classical
  exact if h : 2 * block.val + d.val < n then
    if canonicalRoot (q (a.succAbove ⟨2 * block.val + d.val, h⟩)) = 0
      then 0
      else Nightfall.FiniteField.F9ActualField.actual_F9_basis d
    else 0

/-- Suppress unobservable sign bits at zero coordinates. -/
noncomputable def activeBits {n : ℕ}
    (q : Fin (n + 1) → F9) (a : Fin (n + 1))
    (bits : Fin n → Bool) : Fin n → Bool := by
  classical
  exact fun j =>
    if canonicalRoot (q (a.succAbove j)) = 0 then false else bits j

/-- Every mixed row is a deterministic function of the k previous
coordinate-square outputs. No unsquared source values enter its definition. -/
noncomputable def legalBlockRow {n : ℕ}
    (q : Fin (n + 1) → F9) (a : Fin (n + 1))
    (block : Fin ((n + 1) / 2)) : Fin (n + 1) → F9 :=
  calibratedRow q a (slotIndex a block 0) (slotIndex a block 1)
    (slotWeight q a block 0) (slotWeight q a block 1)

/-- The actual oracle transcript: all k coordinate squares, followed by
floor(k/2) legally chosen squared-linear readings. -/
noncomputable def actualAdaptiveTranscript {n : ℕ}
    (x : Fin (n + 1) → F9) :
    (Fin (n + 1) → F9) × (Fin ((n + 1) / 2) → F9) :=
  let q := fun i => (x i) ^ 2
  (q, fun block =>
    (dot (legalBlockRow q (measuredAnchor q) block) x) ^ 2)

theorem legalBlockRow_prefix_determined {n : ℕ}
    (q r : Fin (n + 1) → F9) (h : q = r)
    (block : Fin ((n + 1) / 2)) :
    legalBlockRow q (measuredAnchor q) block =
      legalBlockRow r (measuredAnchor r) block := by
  subst r
  rfl

theorem actualAdaptiveTranscript_coordinate_prefix {n : ℕ}
    (x : Fin (n + 1) → F9) :
    (actualAdaptiveTranscript x).1 = fun i => x i ^ 2 := by
  rfl



/-- Every nonzero slot uses a nonzero measured root; unused or zero slots
have a zero coefficient. This allows legal sparse-support rows. -/
theorem slot_weight_root_or_zero {n : ℕ}
    (q : Fin (n + 1) → F9) (a : Fin (n + 1))
    (block : Fin ((n + 1) / 2)) (d : Fin 2) :
    canonicalRoot (q (slotIndex a block d)) ≠ 0 ∨
      slotWeight q a block d = 0 := by
  classical
  by_cases hv : 2 * block.val + d.val < n
  · let j : Fin n := ⟨2 * block.val + d.val, hv⟩
    by_cases hr : canonicalRoot (q (a.succAbove j)) = 0
    · right
      simp [slotWeight, hv, j, hr]
    · left
      simpa [slotIndex, hv, j] using hr
  · right
    simp [slotWeight, hv]

/-- The actual signed normal-form coordinate, indexed without materializing
a hidden sign value in the chosen query coefficient. -/
theorem normalized_slot_value {n : ℕ}
    (q : Fin (n + 1) → F9) (a : Fin (n + 1))
    (bits : Fin n → Bool) (j : Fin n) :
    normalizedSource (rootProfile q) a (activeBits q a bits)
        (a.succAbove j) =
      if activeBits q a bits j then canonicalRoot (q (a.succAbove j))
      else -canonicalRoot (q (a.succAbove j)) := by
  simp [normalizedSource, rootProfile]

/-- All source rows are built from q, and a padded/zero slot has no effect.
The equality is BEFORE squaring, at the legal coefficient level. -/
theorem slot_weighted_readout {n : ℕ}
    (q : Fin (n + 1) → F9) (a : Fin (n + 1))
    (bits : Fin n → Bool)
    (block : Fin ((n + 1) / 2)) (d : Fin 2) :
    (slotWeight q a block d /
       canonicalRoot (q (slotIndex a block d))) *
       normalizedSource (rootProfile q) a (activeBits q a bits)
          (slotIndex a block d) =
      slotWeight q a block d *
        phase (paddedPair (activeBits q a bits) block d) := by
  classical
  by_cases hv : 2 * block.val + d.val < n
  · let j : Fin n := ⟨2 * block.val + d.val, hv⟩
    have hi : slotIndex a block d = a.succAbove j := by
      simp [slotIndex, hv, j]
    by_cases hr : canonicalRoot (q (a.succAbove j)) = 0
    · have hw : slotWeight q a block d = 0 := by
        simp [slotWeight, hv, j, hr]
      simp [hw]
    · have hw : slotWeight q a block d =
          Nightfall.FiniteField.F9ActualField.actual_F9_basis d := by
        simp [slotWeight, hv, j, hr]
      have hb :
          paddedPair (activeBits q a bits) block d =
            activeBits q a bits j := by
        simp [paddedPair, hv, j]
      rw [hi, hw, hb, normalized_slot_value]
      cases hh : activeBits q a bits j <;>
        simp [hh, phase] <;> field_simp [hr] <;> ring
  · have hw : slotWeight q a block d = 0 := by
      simp [slotWeight, hv]
    simp [hw]

/-- Suppressed padded/zero slots also suppress their digit contribution. -/
theorem slot_weight_digit {n : ℕ}
    (q : Fin (n + 1) → F9) (a : Fin (n + 1))
    (bits : Fin n → Bool)
    (block : Fin ((n + 1) / 2)) (d : Fin 2) :
    slotWeight q a block d *
      digit (paddedPair (activeBits q a bits) block d) =
      Nightfall.FiniteField.F9ActualField.actual_F9_basis d *
      digit (paddedPair (activeBits q a bits) block d) := by
  classical
  by_cases hv : 2 * block.val + d.val < n
  · let j : Fin n := ⟨2 * block.val + d.val, hv⟩
    by_cases hr : canonicalRoot (q (a.succAbove j)) = 0
    · have hb :
          paddedPair (activeBits q a bits) block d = false := by
        simp [paddedPair, activeBits, hv, hr, j]
      simp [slotWeight, hv, hr, hb, digit, j]
    · simp [slotWeight, hv, hr, j]
  · have hb : paddedPair (activeBits q a bits) block d = false := by
      simp [paddedPair, hv]
    simp [slotWeight, hv, hb, digit]



theorem measuredAnchor_nonzero {n : ℕ}
    (q : Fin (n + 1) → F9)
    (hex : ∃ i, rootProfile q i ≠ 0) :
    rootProfile q (measuredAnchor q) ≠ 0 := by
  unfold measuredAnchor
  dsimp
  split_ifs with h
  · exact Classical.choose_spec h
  · exact False.elim (h hex)

theorem normalized_source_mask_eq {n : ℕ}
    (q : Fin (n + 1) → F9) (a : Fin (n + 1))
    (bits : Fin n → Bool) :
    normalizedSource (rootProfile q) a bits =
      normalizedSource (rootProfile q) a (activeBits q a bits) := by
  classical
  funext i
  rcases Fin.eq_self_or_eq_succAbove a i with rfl | ⟨j, rfl⟩
  · simp [normalizedSource]
  · by_cases hz : canonicalRoot (q (a.succAbove j)) = 0
    · simp [normalizedSource, rootProfile, activeBits, hz]
    · simp [normalizedSource, rootProfile, activeBits, hz]

theorem normalized_anchor_value {n : ℕ}
    (q : Fin (n + 1) → F9) (a : Fin (n + 1))
    (bits : Fin n → Bool) :
    normalizedSource (rootProfile q) a bits a = canonicalRoot (q a) := by
  simp [normalizedSource, rootProfile]

/-- Physical squared-linear observation on an arbitrary padded block agrees
with the already certified two-digit square code. Any suppressed zero slot
has exactly zero contribution; neither future readings nor secret signs
appear in a query coefficient. -/
theorem actual_normalized_block_square {n : ℕ}
    (q : Fin (n + 1) → F9) (a : Fin (n + 1))
    (bits : Fin n → Bool)
    (ha : canonicalRoot (q a) ≠ 0)
    (block : Fin ((n + 1) / 2)) :
    (dot (legalBlockRow q a block)
      (normalizedSource (rootProfile q) a (activeBits q a bits))) ^ 2 =
      (blockValue Nightfall.FiniteField.F9ActualField.actual_F9_basis
        (paddedPair (activeBits q a bits) block)) ^ 2 := by
  let W0 := slotWeight q a block 0
  let W1 := slotWeight q a block 1
  let B := paddedPair (activeBits q a bits) block
  have hanchor :
      ((W0 + W1) / canonicalRoot (q a)) *
        normalizedSource (rootProfile q) a (activeBits q a bits) a =
        W0 + W1 := by
    rw [normalized_anchor_value]
    field_simp [ha] <;> ring
  have hs0 := slot_weighted_readout q a bits block (0 : Fin 2)
  have hs1 := slot_weighted_readout q a bits block (1 : Fin 2)
  have hd0 := slot_weight_digit q a bits block (0 : Fin 2)
  have hd1 := slot_weight_digit q a bits block (1 : Fin 2)
  have hcombine :
      (W0 + W1) + W0 * phase (B 0) + W1 * phase (B 1) =
        W0 * digit (B 0) + W1 * digit (B 1) := by
    rw [← phase_to_digit (B 0), ← phase_to_digit (B 1)]
    ring
  calc
    (dot (legalBlockRow q a block)
      (normalizedSource (rootProfile q) a (activeBits q a bits))) ^ 2 =
      ((W0 + W1) + W0 * phase (B 0) + W1 * phase (B 1)) ^ 2 := by
        unfold legalBlockRow
        rw [calibratedRow_dot]
        change (((W0 + W1) / canonicalRoot (q a)) *
                normalizedSource (rootProfile q) a (activeBits q a bits) a +
              (W0 / canonicalRoot (q (slotIndex a block 0))) *
                normalizedSource (rootProfile q) a (activeBits q a bits)
                  (slotIndex a block 0) +
              (W1 / canonicalRoot (q (slotIndex a block 1))) *
                normalizedSource (rootProfile q) a (activeBits q a bits)
                  (slotIndex a block 1)) ^ 2 = _
        rw [hanchor, hs0, hs1]
    _ = (W0 * digit (B 0) + W1 * digit (B 1)) ^ 2 := by rw [hcombine]
    _ = (Nightfall.FiniteField.F9ActualField.actual_F9_basis 0 * digit (B 0) +
          Nightfall.FiniteField.F9ActualField.actual_F9_basis 1 * digit (B 1)) ^ 2 := by
        rw [hd0, hd1]
    _ = (blockValue Nightfall.FiniteField.F9ActualField.actual_F9_basis B) ^ 2 := by
        rw [actual_basis_block_expansion B]



/-- Actual source input, not a prechosen normalized signal: the legal
squared-linear packet reading equals the previously certified algebraic
two-bit code with every zero sign explicitly masked. -/
theorem actual_source_block_square {n : ℕ}
    (q x : Fin (n + 1) → F9) (a : Fin (n + 1))
    (hq : ∀ i, (x i) ^ 2 = q i)
    (ha : canonicalRoot (q a) ≠ 0)
    (block : Fin ((n + 1) / 2)) :
    (dot (legalBlockRow q a block) x) ^ 2 =
      (blockValue Nightfall.FiniteField.F9ActualField.actual_F9_basis
        (paddedPair (activeBits q a
            (orientationBits x (rootProfile q) a)) block)) ^ 2 := by
  let r := rootProfile q
  let bits := orientationBits x r a
  have hroot (i : Fin (n + 1)) : (x i) ^ 2 = (r i) ^ 2 := by
    change (x i) ^ 2 = (canonicalRoot (q i)) ^ 2
    rw [← hq i]
    exact (canonicalRoot_square (x i)).symm
  have hnorm := square_profile_has_normal_form x r a hroot
  have hnegative (z : Fin (n + 1) → F9) :
      (dot (legalBlockRow q a block) (-z)) ^ 2 =
      (dot (legalBlockRow q a block) z) ^ 2 := by
    exact calibratedRow_global_sign_invariant q z a
      (slotIndex a block 0) (slotIndex a block 1)
      (slotWeight q a block 0) (slotWeight q a block 1)
  rcases hnorm with hx | hx
  · conv_lhs => rw [hx, normalized_source_mask_eq q a bits]
    exact actual_normalized_block_square q a bits ha block
  · conv_lhs => rw [hx, hnegative, normalized_source_mask_eq q a bits]
    exact actual_normalized_block_square q a bits ha block



theorem transcript_prefix_equal {n : ℕ}
    (x y : Fin (n + 1) → F9)
    (h : actualAdaptiveTranscript x = actualAdaptiveTranscript y) :
    (fun i => (x i) ^ 2) = (fun i => (y i) ^ 2) := by
  have hp := congrArg Prod.fst h
  simpa only [actualAdaptiveTranscript] using hp

theorem transcript_block_equal {n : ℕ}
    (x y : Fin (n + 1) → F9)
    (h : actualAdaptiveTranscript x = actualAdaptiveTranscript y)
    (block : Fin ((n + 1) / 2)) :
    let q := fun i => (x i) ^ 2
    (dot (legalBlockRow q (measuredAnchor q) block) x) ^ 2 =
      (dot (legalBlockRow q (measuredAnchor q) block) y) ^ 2 := by
  have hp := transcript_prefix_equal x y h
  have hs := congrArg Prod.snd h
  dsimp only [actualAdaptiveTranscript] at hs
  rw [← hp] at hs
  exact congrArg (fun f : Fin ((n + 1) / 2) → F9 => f block) hs

theorem actual_square_profile_root {n : ℕ}
    (q x : Fin (n + 1) → F9)
    (hq : ∀ i, (x i) ^ 2 = q i)
    (i : Fin (n + 1)) :
    (x i) ^ 2 = (rootProfile q i) ^ 2 := by
  change (x i) ^ 2 = (canonicalRoot (q i)) ^ 2
  rw [← hq i]
  exact (canonicalRoot_square (x i)).symm

theorem actual_square_profile_zero {n : ℕ}
    (q x : Fin (n + 1) → F9)
    (hq : ∀ i, (x i) ^ 2 = q i)
    (hzero : ∀ i, rootProfile q i = 0) :
    x = 0 := by
  funext i
  have hs := actual_square_profile_root q x hq i
  rw [hzero i] at hs
  exact (sq_eq_zero_iff).mp (by simpa using hs)

theorem measured_packet_budget (n : ℕ) :
    (n + 1) + (n + 1) / 2 =
      Nightfall.FiniteField.F9GapArithmetic.adaptiveUpper (n + 1) := by
  simp only [Nightfall.FiniteField.F9GapArithmetic.adaptiveUpper]
  omega



/-- THE END-TO-END ORACLE THEOREM: For every positive finite dimension,
two arbitrary GF9 signals with identical ACTUAL squared-linear adaptive
transcripts are equivalent under precisely one global ± sign. All mixed rows
are source-calibrated only from earlier coordinate-square observations,
including zero/sparse supports and a padded last packet. -/
theorem actual_adaptive_transcript_injective {n : ℕ}
    (x y : Fin (n + 1) → F9)
    (h : actualAdaptiveTranscript x = actualAdaptiveTranscript y) :
    x = y ∨ x = -y := by
  classical
  let q : Fin (n + 1) → F9 := fun i => (x i) ^ 2
  have hp : q = (fun i => (y i) ^ 2) :=
    transcript_prefix_equal x y h
  have hxq : ∀ i, (x i) ^ 2 = q i := by intro i; rfl
  have hyq : ∀ i, (y i) ^ 2 = q i := by
    intro i
    exact (congrArg (fun f : Fin (n + 1) → F9 => f i) hp).symm
  by_cases hex : ∃ i, rootProfile q i ≠ 0
  · let a := measuredAnchor q
    have ha : canonicalRoot (q a) ≠ 0 :=
      measuredAnchor_nonzero q hex
    let bx : Fin n → Bool := orientationBits x (rootProfile q) a
    let yBits : Fin n → Bool := orientationBits y (rootProfile q) a
    have hcode :
        ∀ block : Fin ((n + 1) / 2),
          (blockValue Nightfall.FiniteField.F9ActualField.actual_F9_basis
            (paddedPair (activeBits q a bx) block)) ^ 2 =
          (blockValue Nightfall.FiniteField.F9ActualField.actual_F9_basis
            (paddedPair (activeBits q a yBits) block)) ^ 2 := by
      intro block
      calc
        (blockValue Nightfall.FiniteField.F9ActualField.actual_F9_basis
          (paddedPair (activeBits q a bx) block)) ^ 2 =
            (dot (legalBlockRow q a block) x) ^ 2 := by
              exact (actual_source_block_square q x a hxq ha block).symm
        _ = (dot (legalBlockRow q a block) y) ^ 2 := by
              simpa only [q, a] using
                (transcript_block_equal x y h block)
        _ = (blockValue Nightfall.FiniteField.F9ActualField.actual_F9_basis
            (paddedPair (activeBits q a yBits) block)) ^ 2 := by
              exact actual_source_block_square q y a hyq ha block
    have hbits : activeBits q a bx = activeBits q a yBits :=
      all_sign_bits_decoded n (activeBits q a bx)
        (activeBits q a yBits) hcode
    have hnorm :
        normalizedSource (rootProfile q) a bx =
        normalizedSource (rootProfile q) a yBits := by
      calc
        normalizedSource (rootProfile q) a bx =
          normalizedSource (rootProfile q) a (activeBits q a bx) :=
            normalized_source_mask_eq q a bx
        _ = normalizedSource (rootProfile q) a (activeBits q a yBits) := by
            rw [hbits]
        _ = normalizedSource (rootProfile q) a yBits :=
            (normalized_source_mask_eq q a yBits).symm
    have hxr : ∀ i, (x i) ^ 2 = (rootProfile q i) ^ 2 :=
      actual_square_profile_root q x hxq
    have hyr : ∀ i, (y i) ^ 2 = (rootProfile q i) ^ 2 :=
      actual_square_profile_root q y hyq
    have hxform := square_profile_has_normal_form x (rootProfile q) a hxr
    have hyform := square_profile_has_normal_form y (rootProfile q) a hyr
    rcases hxform with hx | hx
    · rcases hyform with hy | hy
      · left
        rw [hx, hy, hnorm]
      · right
        rw [hx, hy, hnorm]
        simp only [neg_neg, yBits]
    · rcases hyform with hy | hy
      · right
        rw [hx, hy, hnorm]
      · left
        rw [hx, hy, hnorm]
  · have hzero : ∀ i, rootProfile q i = 0 := by
      intro i
      by_contra hi
      exact hex ⟨i, hi⟩
    have hx0 : x = 0 := actual_square_profile_zero q x hxq hzero
    have hy0 : y = 0 := actual_square_profile_zero q y hyq hzero
    left
    rw [hx0, hy0]

/-- All positive dimensions have an actual squared-oracle protocol with
the claimed exact legal query budget, not a stipulated decoder premise. -/
theorem all_dimensions_actual_adaptive_upper (n : ℕ) :
    (∀ x y : Fin (n + 1) → F9,
      actualAdaptiveTranscript x = actualAdaptiveTranscript y →
        x = y ∨ x = -y) ∧
    (n + 1) + (n + 1) / 2 =
      Nightfall.FiniteField.F9GapArithmetic.adaptiveUpper (n + 1) := by
  exact ⟨fun x y h => actual_adaptive_transcript_injective x y h,
    measured_packet_budget n⟩

/-- The source-closed actual adaptive construction meets the ALL-DIMENSION
fixed-design obstruction for the IDENTICAL powered K-linear oracle.
There is no unproved adaptive-bound premise on this terminal: its witness
and exact query count are the preceding named theorems. -/
theorem actual_same_oracle_gap_unbounded
    (fixed : ℕ → ℕ)
    (rows : (k : ℕ) → Fin (fixed k) → Fin k → F9)
    (hsep : ∀ k,
      Nightfall.FiniteField.F9NonadaptiveLower.fixedSquareSeparates (rows k)) :
    (∀ n, ∀ x y : Fin (n + 1) → F9,
      actualAdaptiveTranscript x = actualAdaptiveTranscript y →
        x = y ∨ x = -y) ∧
    (∀ threshold : ℕ, ∃ k : ℕ,
      threshold ≤ fixed k -
        Nightfall.FiniteField.F9GapArithmetic.adaptiveUpper k) := by
  constructor
  · intro n x y h
    exact actual_adaptive_transcript_injective x y h
  · exact Nightfall.FiniteField.F9ConcreteLower.same_oracle_gap_given_actual_adaptive_upper
      fixed Nightfall.FiniteField.F9GapArithmetic.adaptiveUpper rows
      hsep (by intro k hk; exact le_rfl)


#print axioms Nightfall.FiniteField.F9ActualAdaptiveTerminal.actual_two_digit_with_zero_slots
#print axioms Nightfall.FiniteField.F9ActualAdaptiveTerminal.actual_adaptive_transcript_injective
#print axioms Nightfall.FiniteField.F9ActualAdaptiveTerminal.actual_same_oracle_gap_unbounded
#print axioms Nightfall.FiniteField.F9ActualAdaptiveTerminal.transcript_block_equal
#print axioms Nightfall.FiniteField.F9ActualAdaptiveTerminal.actual_source_block_square
#print axioms Nightfall.FiniteField.F9ActualAdaptiveTerminal.actual_normalized_block_square
#print axioms Nightfall.FiniteField.F9ActualAdaptiveTerminal.legalBlockRow_prefix_determined

end
end Nightfall.FiniteField.F9ActualAdaptiveTerminal
