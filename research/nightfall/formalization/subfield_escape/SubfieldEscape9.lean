import Init

/-!
A finite, kernel-checkable component of NIGHTFALL's subfield-escape argument.

These checks establish:
* the explicit two-coordinate adaptive three-reading map on F9 identifies
  all 81 signals modulo the global sign,
* a four-test all-nonmembership path cannot identify six directions,
* five fixed incidence tests distinguish six projective directions and zero,
* the two-reading alphabet count fails at F9 and F25.

They do not formalize the full arbitrary-prime or arbitrary-extension theorem.
The F9 arithmetic below represents a+b*u in F3[u]/(u^2-2).
-/

namespace Nightfall.SubfieldEscape

abbrev F9 := Fin 3 × Fin 3

def red (n : Nat) : Fin 3 :=
  ⟨n % 3, Nat.mod_lt n (by decide)⟩

def add (x y : F9) : F9 :=
  (red (x.1.val + y.1.val), red (x.2.val + y.2.val))

def mul (x y : F9) : F9 :=
  (red (x.1.val * y.1.val + 2 * x.2.val * y.2.val),
   red (x.1.val * y.2.val + x.2.val * y.1.val))

def neg (x : F9) : F9 :=
  (red (3 - x.1.val), red (3 - x.2.val))

def sq (x : F9) : F9 := mul x x

def one : F9 := (1, 0)
def theta : F9 := (0, 1)

-- c=theta if the two coordinate powers coincide; c=1 otherwise.
def coeff (x y : F9) : F9 :=
  if sq x = sq y then theta else one

def third (x y : F9) : F9 :=
  sq (add x (mul (coeff x y) y))

def readings (x y : F9) : F9 × F9 × F9 :=
  (sq x, sq y, third x y)

theorem f9_three_readings_identify_global_sign :
    ∀ x y u v : F9,
      readings x y = readings u v →
      (x = u ∧ y = v) ∨ (x = neg u ∧ y = neg v) := by
  decide

-- For four adaptive singleton tests, follow the all-"nonmember" branch:
-- four tested directions always leave two projective points indistinguishable.
theorem four_singleton_queries_leave_two_directions :
    ∀ a b c d : Fin 6,
      ∃ u v : Fin 6,
        u ≠ v ∧
        u ≠ a ∧ u ≠ b ∧ u ≠ c ∧ u ≠ d ∧
        v ≠ a ∧ v ≠ b ∧ v ≠ c ∧ v ≠ d := by
  decide

-- Six projective directions are 0..5; signal index 6 is the zero vector.
-- A query row is represented by its projective kernel direction, 0..4.
def projectiveF5Reading (signal : Fin 7) (query : Fin 5) : Bool :=
  if signal.val = 6 ∨ signal.val = query.val then false else true

theorem five_incidence_rows_separate_all_seven_orbits :
    ∀ s t : Fin 7,
      (∀ q : Fin 5, projectiveF5Reading s q = projectiveF5Reading t q) →
      s = t := by
  decide

theorem two_reading_count_f9 : 5 ^ 2 < 41 := by decide
theorem two_reading_count_f25 : 7 ^ 2 < 157 := by decide

end Nightfall.SubfieldEscape
