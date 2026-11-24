import TrustedBaseline

open InclusionBench InclusionBench.Support

namespace Nightfall.InclusionBridge.OneFrequency

def ones : List Bool → Int
  | [] => 0
  | b :: bs => (if b then 1 else 0) + ones bs

def zeros : List Bool → Int
  | [] => 0
  | b :: bs => (if b then 0 else 1) + zeros bs

theorem partition_count (xs : List Bool) :
    ones xs + zeros xs = (xs.length : Int) := by
  induction xs with
  | nil => rfl
  | cons b bs ih =>
      cases b <;> simp [ones, zeros] <;> omega

/-- Count accepting outcomes of the classical sampler, over a selector bit
and equally sized verifier tables. The paper proof identifies this with
the normalized Born probability of the one-phase-query circuit. -/
def hits (a b : List Bool) (z : Bool) : Int :=
  if z then zeros a + ones b else ones a + zeros b

theorem centered_hits (a b : List Bool) (same : a.length = b.length) :
    hits a b false - (a.length : Int) = ones a - ones b ∧
    hits a b true - (a.length : Int) = -(ones a - ones b) := by
  have ha := partition_count a
  have hb := partition_count b
  have hlen : (a.length : Int) = (b.length : Int) := by rw [same]
  simp only [hits, Bool.false_eq_true, if_false, if_true]
  constructor <;> omega

theorem positive_iff (a b : List Bool) (same : a.length = b.length) :
    (a.length : Int) < hits a b false ↔ ones b < ones a := by
  have h := (centered_hits a b same).1
  omega

theorem zero_iff (a b : List Bool) (same : a.length = b.length) :
    hits a b false = (a.length : Int) ↔ ones a = ones b := by
  have h := (centered_hits a b same).1
  omega

/-- Exponential sums of one uniformly FP-computable signed term are GapP.
No polynomial materialization assumption is needed for this counting-class
route. This does not assert that the sum is FP. -/
def signedContraction (term : Word → Int) (width : List Nat) (input : Word) : Int :=
  ((Randomized.coinStrings (Counting.polynomialValue width input.length)).map
    (fun bits => term (ProofSystems.encodeTriple input bits []))).sum

theorem signedContraction_gap (term : Word → Int) (width : List Nat)
    (efficient : Transducers.FP term) :
    Counting.GapP (signedContraction term width) :=
  gapP_sum_bits (gapP_of_fp efficient) width

theorem positive_contraction_in_PP (term : Word → Int) (width : List Nat)
    (efficient : Transducers.FP term) :
    Counting.PP (fun input => 0 < signedContraction term width input) :=
  pp_of_gap (signedContraction_gap term width efficient) (fun _ => Iff.rfl)

theorem zero_contraction_in_CeqP (term : Word → Int) (width : List Nat)
    (efficient : Transducers.FP term) :
    Counting.CeqP (fun input => signedContraction term width input = 0) :=
  ceqp_of_gap (signedContraction_gap term width efficient) (fun _ => Iff.rfl)

end Nightfall.InclusionBridge.OneFrequency
