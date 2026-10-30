import Init

/-!
RYEV #257: model-independent proof graph for fixed square retrieval.

Theorems are universally quantified in V, K and Fin m. Field identities
are *explicit arguments* to the main theorem, NOT secret axioms.
For odd-characteristic vector spaces they follow from (a²=b²) iff a=±b,
the usual sum/difference linearity, invertibility of 2, and full rank.

This proves the formal reduction GIVEN those algebraic premises. Instantiating
the laws for all finite fields of odd characteristic and formalizing the
adaptive basis-packing decoder are separate obligations. Finite arithmetic
tests do not discharge these universal proof dependencies.
-/
namespace Nightfall.OddSquare

universe u v

def Disjoint {V : Type u} {K : Type v} {m : Nat}
    (A : V → Fin m → K) (zeroK : K) (x y : V) : Prop :=
  ∀ i, A x i = zeroK ∨ A y i = zeroK

def StrongIntersecting {V : Type u} {K : Type v} {m : Nat}
    (A : V → Fin m → K) (zeroV : V) (zeroK : K) : Prop :=
  ∀ x y, Disjoint A zeroK x y → x = zeroV ∨ y = zeroV

def KernelTrivial {V : Type u} {K : Type v} {m : Nat}
    (A : V → Fin m → K) (zeroV : V) (zeroK : K) : Prop :=
  ∀ x, (∀ i, A x i = zeroK) → x = zeroV

def ImageIntersecting {V : Type u} {K : Type v} {m : Nat}
    (A : V → Fin m → K) (zeroK : K) : Prop :=
  ∀ x y, Disjoint A zeroK x y →
    (∀ i, A x i = zeroK) ∨ (∀ i, A y i = zeroK)

def Separates {V : Type u} {K : Type v} {m : Nat}
    (A : V → Fin m → K) (square : K → K) (negativeV : V → V) : Prop :=
  ∀ x y, (∀ i, square (A x i) = square (A y i)) →
    x = y ∨ x = negativeV y

-- Strong source-level intersection automatically rules out kernel vectors;
-- this is why one must include full rank when discussing image codes.
theorem strong_intersecting_iff_full_rank_and_image
    {V : Type u} {K : Type v} {m : Nat}
    (A : V → Fin m → K) (zeroV : V) (zeroK : K)
    (A_zero : ∀ i, A zeroV i = zeroK) :
    StrongIntersecting A zeroV zeroK ↔
      KernelTrivial A zeroV zeroK ∧ ImageIntersecting A zeroK := by
  constructor
  · intro h
    constructor
    · intro x hx
      rcases h x x (by intro i; exact Or.inl (hx i)) with h0 | h0
      · exact h0
      · exact h0
    · intro x y hxy
      rcases h x y hxy with h0 | h0
      · left
        intro i
        rw [h0]
        exact A_zero i
      · right
        intro i
        rw [h0]
        exact A_zero i
  · intro h x y hxy
    rcases h.2 x y hxy with hx | hy
    · exact Or.inl (h.1 x hx)
    · exact Or.inr (h.1 y hy)

-- Exact complement/intersection equivalence. The hypotheses expose
-- precisely the algebra that must be instantiated in each field model.
theorem square_separation_iff_strong_intersection
    {V : Type u} {K : Type v} {m : Nat}
    (A : V → Fin m → K) (zeroV : V) (zeroK : K)
    (square : K → K) (negativeK : K → K) (negativeV : V → V)
    (difference sumV : V → V → V)
    (square_sign : ∀ a b, square a = square b ↔
      a = b ∨ a = negativeK b)
    (difference_measurement : ∀ x y i,
      A (difference x y) i = zeroK ↔ A x i = A y i)
    (sum_measurement : ∀ x y i,
      A (sumV x y) i = zeroK ↔ A x i = negativeK (A y i))
    (difference_zero : ∀ x y, difference x y = zeroV ↔ x = y)
    (sum_zero : ∀ x y, sumV x y = zeroV ↔ x = negativeV y)
    (polarization : ∀ u v, ∃ x y, difference x y = u ∧ sumV x y = v) :
    Separates A square negativeV ↔ StrongIntersecting A zeroV zeroK := by
  constructor
  · intro separation u v disjoint
    obtain ⟨x, y, hx, hy⟩ := polarization u v
    have sameSquares : ∀ i, square (A x i) = square (A y i) := by
      intro i
      rcases disjoint i with hz | hz
      · have heq : A (difference x y) i = zeroK := by
          rw [hx]
          exact hz
        exact (square_sign _ _).2 (Or.inl ((difference_measurement x y i).1 heq))
      · have hneg : A (sumV x y) i = zeroK := by
          rw [hy]
          exact hz
        exact (square_sign _ _).2 (Or.inr ((sum_measurement x y i).1 hneg))
    rcases separation x y sameSquares with heq | hneg
    · left
      have hzero : difference x y = zeroV :=
        (difference_zero x y).2 heq
      rw [←hx]
      exact hzero
    · right
      have hzero : sumV x y = zeroV :=
        (sum_zero x y).2 hneg
      rw [←hy]
      exact hzero
  · intro intersecting x y sameSquares
    have disjoint : Disjoint A zeroK (difference x y) (sumV x y) := by
      intro i
      rcases (square_sign (A x i) (A y i)).1 (sameSquares i) with heq | hneg
      · exact Or.inl ((difference_measurement x y i).2 heq)
      · exact Or.inr ((sum_measurement x y i).2 hneg)
    rcases intersecting (difference x y) (sumV x y) disjoint with hd | hs
    · exact Or.inl ((difference_zero x y).1 hd)
    · exact Or.inr ((sum_zero x y).1 hs)

-- The reusable sign-packing operator, quantified over an arbitrary
-- number r of independent basis digits. It explains how an injective
-- linear expansion remains injective after squaring, provided the digit
-- alphabet contains no distinct opposite-sign pair.
--
-- In F_(p^r) for odd p, D={0,2}, the rigidity hypothesis is the
-- elementary 2 != -2 (characteristic not 2). A field-basis map supplies
-- basis_unique and basis_neg. These instantiations are not claimed here.
theorem signed_digit_packing_injective
    {K : Type v} {r : Nat}
    (square negativeK : K → K) (D : K → Prop)
    (encode : (Fin r → K) → K)
    (square_sign : ∀ a b, square a = square b ↔
      a = b ∨ a = negativeK b)
    (basis_unique : ∀ a b, encode a = encode b → ∀ i, a i = b i)
    (basis_neg : ∀ b,
      encode (fun i => negativeK (b i)) = negativeK (encode b))
    (digit_rigidity : ∀ a b, D a → D b →
      a = negativeK b → a = b) :
    ∀ a b : Fin r → K, (∀ i, D (a i)) → (∀ i, D (b i)) →
      square (encode a) = square (encode b) →
      ∀ i, a i = b i := by
  intro a b ha hb hsq
  rcases (square_sign (encode a) (encode b)).1 hsq with heq | hneg
  · exact basis_unique a b heq
  · have hencoded :
        encode a = encode (fun i => negativeK (b i)) := by
      rw [basis_neg]
      exact hneg
    have hcoords := basis_unique a (fun i => negativeK (b i)) hencoded
    intro i
    exact digit_rigidity (a i) (b i) (ha i) (hb i) (hcoords i)

#print axioms Nightfall.OddSquare.strong_intersecting_iff_full_rank_and_image
#print axioms Nightfall.OddSquare.square_separation_iff_strong_intersection
#print axioms Nightfall.OddSquare.signed_digit_packing_injective

end Nightfall.OddSquare
