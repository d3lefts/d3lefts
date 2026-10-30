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
  if ((sq x).1.val == (sq y).1.val) &&
     ((sq x).2.val == (sq y).2.val) then theta else one

def third (x y : F9) : F9 :=
  sq (add x (mul (coeff x y) y))

def readings (x y : F9) : F9 × F9 × F9 :=
  (sq x, sq y, third x y)

def fromIndex (i : Fin 9) : F9 :=
  (red i.val, red (i.val / 3))

def encode (x : F9) : Nat :=
  x.1.val + 3 * x.2.val

def packedReadings (i j : Fin 9) : Nat :=
  let x := fromIndex i
  let y := fromIndex j
  encode (sq x) + 9 * encode (sq y) + 81 * encode (third x y)

-- The Boolean form is equivalent to: matching three-query signatures
-- imply agreement up to one common nonzero F3 scalar.
def correctlySeparated (i j k l : Fin 9) : Bool :=
  (packedReadings i j != packedReadings k l) ||
    ((i.val == k.val && j.val == l.val) ||
      (i.val == encode (neg (fromIndex k)) &&
       j.val == encode (neg (fromIndex l))))

theorem f9_three_readings_identify_global_sign :
    ∀ i j k l : Fin 9, correctlySeparated i j k l = true := by
  decide

-- For four adaptive singleton tests, follow the all-"nonmember" branch:
-- four tested directions always leave two projective points indistinguishable.
def survivingDirections (a b c d : Fin 6) : List Nat :=
  (List.range 6).filter
    (fun i => i != a.val && i != b.val && i != c.val && i != d.val)

theorem four_singleton_queries_leave_two_directions :
    ∀ a b c d : Fin 6, 2 ≤ (survivingDirections a b c d).length := by
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
