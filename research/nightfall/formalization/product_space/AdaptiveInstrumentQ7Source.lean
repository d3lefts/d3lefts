import AdaptiveInstrumentQ7Packing

/-! Source-exact face and mask checks for the 105 Q7 packing instances.
Each embedded mask is checked against the frozen archive by the separate
source audit; Lean checks the face geometry, tightness and exclusion. -/

set_option maxRecDepth 4096
set_option maxHeartbeats 4000000

namespace Nightfall.Q7SourcePacking

open Nightfall.Q7BlockerPacking

structure Face where
  a : ℕ
  b : ℕ
  v : ℕ
  missing : ℕ

def edgeIndex (d v : ℕ) : ℕ :=
  64 * d + v % (2 ^ d) + (v / (2 ^ (d + 1))) * (2 ^ d)

def Face.edges (f : Face) : Finset ℕ :=
  {edgeIndex f.a f.v, edgeIndex f.b f.v,
    edgeIndex f.b (f.v + 2 ^ f.a), edgeIndex f.a (f.v + 2 ^ f.b)}

def Face.Valid (f : Face) : Prop :=
  f.a < f.b ∧ f.b < 7 ∧ f.v < 128 ∧
    f.v.testBit f.a = false ∧ f.v.testBit f.b = false

def Face.Tight (f : Face) (seed : ℕ) : Prop :=
  f.Valid ∧ f.missing ∈ f.edges ∧ seed.testBit f.missing = false ∧
    ∀ e ∈ f.edges.erase f.missing, seed.testBit e = true

instance (f : Face) : Decidable f.Valid := by
  unfold Face.Valid
  infer_instance

instance (f : Face) (seed : ℕ) : Decidable (f.Tight seed) := by
  unfold Face.Tight
  infer_instance

def FaceFree (target : Set ℕ) : Prop :=
  ∀ f : Face, f.Valid → ¬ (∀ e ∈ f.edges, e ∈ target)

theorem tight_blocker_hit (f : Face) (seed : ℕ) (ht : f.Tight seed)
    (target : Set ℕ) (deleted : Finset ℕ) (hfree : FaceFree target)
    (ha : f.missing ∈ target)
    (hk : ∀ e, seed.testBit e = true → e ∉ deleted → e ∈ target) :
    ∃ e ∈ deleted, e ∈ f.edges.erase f.missing := by
  classical
  by_contra hn
  apply hfree f ht.1
  intro e he
  by_cases hem : e = f.missing
  · rw [hem]; exact ha
  · have hb : e ∈ f.edges.erase f.missing := Finset.mem_erase.mpr ⟨hem, he⟩
    exact hk e (ht.2.2.2 e hb) (fun hd => hn ⟨e, hd, hb⟩)

structure Entry where
  seed : ℕ
  added : Finset ℕ
  faces : Fin 8 → Face
  blockers : List (List ℕ)

def Entry.SourceValid (r : Entry) : Prop :=
  ∀ i : Fin 8, (r.faces i).Tight r.seed ∧
    (r.faces i).missing ∈ r.added ∧
    (r.faces i).edges.erase (r.faces i).missing = groups r.blockers i

instance (r : Entry) : Decidable r.SourceValid := by
  unfold Entry.SourceValid
  infer_instance

def Entry.Valid (r : Entry) : Prop :=
  PairwiseDisjoint r.blockers ∧ r.SourceValid

theorem entry_bound (r : Entry) (hr : r.Valid)
    (target : Set ℕ) (deleted : Finset ℕ) (hfree : FaceFree target)
    (ha : ∀ e ∈ r.added, e ∈ target)
    (hk : ∀ e, r.seed.testBit e = true → e ∉ deleted → e ∈ target) :
    8 ≤ deleted.card := by
  apply certified_record r.blockers hr.1 deleted
  intro i
  have hi := hr.2 i
  rw [← hi.2.2]
  exact tight_blocker_hit (r.faces i) r.seed hi.1 target deleted hfree
    (ha _ hi.2.1) hk

-- Orbit 19; source mask decoded in canonical edge order.
def entry0 : Entry := ⟨720527418019650599322010874408478994678356827527927582173773488164847978586651047110686807626017244463855017265848765461044305968594656, {0, 63, 136, 183}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩], record0⟩
theorem entry0_valid : entry0.Valid := ⟨record0_disjoint, by decide⟩
-- Orbit 19; source mask decoded in canonical edge order.
def entry1 : Entry := ⟨720527418019650599322010874408478994678356827527927582173773488164847978586651047110686807626017244463855017265848765461044305968594656, {0, 63, 136, 261}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩], record1⟩
theorem entry1_valid : entry1.Valid := ⟨record1_disjoint, by decide⟩
-- Orbit 19; source mask decoded in canonical edge order.
def entry2 : Entry := ⟨720527418019650599322010874408478994678356827527927582173773488164847978586651047110686807626017244463855017265848765461044305968594656, {0, 63, 136, 314}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record2⟩
theorem entry2_valid : entry2.Valid := ⟨record2_disjoint, by decide⟩
-- Orbit 19; source mask decoded in canonical edge order.
def entry3 : Entry := ⟨720527418019650599322010874408478994678356827527927582173773488164847978586651047110686807626017244463855017265848765461044305968594656, {0, 63, 183, 261}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩], record3⟩
theorem entry3_valid : entry3.Valid := ⟨record3_disjoint, by decide⟩
-- Orbit 19; source mask decoded in canonical edge order.
def entry4 : Entry := ⟨720527418019650599322010874408478994678356827527927582173773488164847978586651047110686807626017244463855017265848765461044305968594656, {0, 63, 183, 314}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record4⟩
theorem entry4_valid : entry4.Valid := ⟨record4_disjoint, by decide⟩
-- Orbit 19; source mask decoded in canonical edge order.
def entry5 : Entry := ⟨720527418019650599322010874408478994678356827527927582173773488164847978586651047110686807626017244463855017265848765461044305968594656, {0, 63, 261, 314}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record5⟩
theorem entry5_valid : entry5.Valid := ⟨record5_disjoint, by decide⟩
-- Orbit 19; source mask decoded in canonical edge order.
def entry6 : Entry := ⟨720527418019650599322010874408478994678356827527927582173773488164847978586651047110686807626017244463855017265848765461044305968594656, {0, 136, 183, 261}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩], record6⟩
theorem entry6_valid : entry6.Valid := ⟨record6_disjoint, by decide⟩
-- Orbit 19; source mask decoded in canonical edge order.
def entry7 : Entry := ⟨720527418019650599322010874408478994678356827527927582173773488164847978586651047110686807626017244463855017265848765461044305968594656, {0, 136, 183, 314}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record7⟩
theorem entry7_valid : entry7.Valid := ⟨record7_disjoint, by decide⟩
-- Orbit 19; source mask decoded in canonical edge order.
def entry8 : Entry := ⟨720527418019650599322010874408478994678356827527927582173773488164847978586651047110686807626017244463855017265848765461044305968594656, {0, 136, 261, 314}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record8⟩
theorem entry8_valid : entry8.Valid := ⟨record8_disjoint, by decide⟩
-- Orbit 19; source mask decoded in canonical edge order.
def entry9 : Entry := ⟨720527418019650599322010874408478994678356827527927582173773488164847978586651047110686807626017244463855017265848765461044305968594656, {0, 183, 261, 314}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record9⟩
theorem entry9_valid : entry9.Valid := ⟨record9_disjoint, by decide⟩
-- Orbit 19; source mask decoded in canonical edge order.
def entry10 : Entry := ⟨720527418019650599322010874408478994678356827527927582173773488164847978586651047110686807626017244463855017265848765461044305968594656, {63, 136, 183, 261}, ![⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩], record10⟩
theorem entry10_valid : entry10.Valid := ⟨record10_disjoint, by decide⟩
-- Orbit 19; source mask decoded in canonical edge order.
def entry11 : Entry := ⟨720527418019650599322010874408478994678356827527927582173773488164847978586651047110686807626017244463855017265848765461044305968594656, {63, 136, 183, 314}, ![⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record11⟩
theorem entry11_valid : entry11.Valid := ⟨record11_disjoint, by decide⟩
-- Orbit 19; source mask decoded in canonical edge order.
def entry12 : Entry := ⟨720527418019650599322010874408478994678356827527927582173773488164847978586651047110686807626017244463855017265848765461044305968594656, {63, 136, 261, 314}, ![⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record12⟩
theorem entry12_valid : entry12.Valid := ⟨record12_disjoint, by decide⟩
-- Orbit 19; source mask decoded in canonical edge order.
def entry13 : Entry := ⟨720527418019650599322010874408478994678356827527927582173773488164847978586651047110686807626017244463855017265848765461044305968594656, {63, 183, 261, 314}, ![⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record13⟩
theorem entry13_valid : entry13.Valid := ⟨record13_disjoint, by decide⟩
-- Orbit 19; source mask decoded in canonical edge order.
def entry14 : Entry := ⟨720527418019650599322010874408478994678356827527927582173773488164847978586651047110686807626017244463855017265848765461044305968594656, {136, 183, 261, 314}, ![⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record14⟩
theorem entry14_valid : entry14.Valid := ⟨record14_disjoint, by decide⟩
-- Orbit 31; source mask decoded in canonical edge order.
def entry15 : Entry := ⟨703492828586395843027244717147693921081233706481056809237960927760018591109016486053238895230047931594426240205591900645192755846151904, {0, 62, 136, 181}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 3, 116, 62⟩, ⟨0, 6, 60, 62⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 3, 97, 181⟩, ⟨2, 6, 41, 181⟩], record15⟩
theorem entry15_valid : entry15.Valid := ⟨record15_disjoint, by decide⟩
-- Orbit 31; source mask decoded in canonical edge order.
def entry16 : Entry := ⟨703492828586395843027244717147693921081233706481056809237960927760018591109016486053238895230047931594426240205591900645192755846151904, {0, 62, 136, 261}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 3, 116, 62⟩, ⟨0, 6, 60, 62⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩], record16⟩
theorem entry16_valid : entry16.Valid := ⟨record16_disjoint, by decide⟩
-- Orbit 31; source mask decoded in canonical edge order.
def entry17 : Entry := ⟨703492828586395843027244717147693921081233706481056809237960927760018591109016486053238895230047931594426240205591900645192755846151904, {0, 62, 136, 312}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 3, 116, 62⟩, ⟨0, 6, 60, 62⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨3, 4, 96, 312⟩, ⟨4, 6, 40, 312⟩], record17⟩
theorem entry17_valid : entry17.Valid := ⟨record17_disjoint, by decide⟩
-- Orbit 31; source mask decoded in canonical edge order.
def entry18 : Entry := ⟨703492828586395843027244717147693921081233706481056809237960927760018591109016486053238895230047931594426240205591900645192755846151904, {0, 62, 181, 261}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 3, 116, 62⟩, ⟨0, 6, 60, 62⟩, ⟨2, 3, 97, 181⟩, ⟨2, 6, 41, 181⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩], record18⟩
theorem entry18_valid : entry18.Valid := ⟨record18_disjoint, by decide⟩
-- Orbit 31; source mask decoded in canonical edge order.
def entry19 : Entry := ⟨703492828586395843027244717147693921081233706481056809237960927760018591109016486053238895230047931594426240205591900645192755846151904, {0, 62, 181, 312}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 3, 116, 62⟩, ⟨0, 6, 60, 62⟩, ⟨2, 3, 97, 181⟩, ⟨2, 6, 41, 181⟩, ⟨3, 4, 96, 312⟩, ⟨4, 6, 40, 312⟩], record19⟩
theorem entry19_valid : entry19.Valid := ⟨record19_disjoint, by decide⟩
-- Orbit 31; source mask decoded in canonical edge order.
def entry20 : Entry := ⟨703492828586395843027244717147693921081233706481056809237960927760018591109016486053238895230047931594426240205591900645192755846151904, {0, 62, 261, 312}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 3, 116, 62⟩, ⟨0, 6, 60, 62⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨3, 4, 96, 312⟩, ⟨4, 6, 40, 312⟩], record20⟩
theorem entry20_valid : entry20.Valid := ⟨record20_disjoint, by decide⟩
-- Orbit 31; source mask decoded in canonical edge order.
def entry21 : Entry := ⟨703492828586395843027244717147693921081233706481056809237960927760018591109016486053238895230047931594426240205591900645192755846151904, {0, 136, 181, 261}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 3, 97, 181⟩, ⟨2, 6, 41, 181⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩], record21⟩
theorem entry21_valid : entry21.Valid := ⟨record21_disjoint, by decide⟩
-- Orbit 31; source mask decoded in canonical edge order.
def entry22 : Entry := ⟨703492828586395843027244717147693921081233706481056809237960927760018591109016486053238895230047931594426240205591900645192755846151904, {0, 136, 181, 312}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 3, 97, 181⟩, ⟨2, 6, 41, 181⟩, ⟨3, 4, 96, 312⟩, ⟨4, 6, 40, 312⟩], record22⟩
theorem entry22_valid : entry22.Valid := ⟨record22_disjoint, by decide⟩
-- Orbit 31; source mask decoded in canonical edge order.
def entry23 : Entry := ⟨703492828586395843027244717147693921081233706481056809237960927760018591109016486053238895230047931594426240205591900645192755846151904, {0, 136, 261, 312}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨3, 4, 96, 312⟩, ⟨4, 6, 40, 312⟩], record23⟩
theorem entry23_valid : entry23.Valid := ⟨record23_disjoint, by decide⟩
-- Orbit 31; source mask decoded in canonical edge order.
def entry24 : Entry := ⟨703492828586395843027244717147693921081233706481056809237960927760018591109016486053238895230047931594426240205591900645192755846151904, {0, 181, 261, 312}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨2, 3, 97, 181⟩, ⟨2, 6, 41, 181⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨3, 4, 96, 312⟩, ⟨4, 6, 40, 312⟩], record24⟩
theorem entry24_valid : entry24.Valid := ⟨record24_disjoint, by decide⟩
-- Orbit 31; source mask decoded in canonical edge order.
def entry25 : Entry := ⟨703492828586395843027244717147693921081233706481056809237960927760018591109016486053238895230047931594426240205591900645192755846151904, {62, 136, 181, 261}, ![⟨0, 3, 116, 62⟩, ⟨0, 6, 60, 62⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 3, 97, 181⟩, ⟨2, 6, 41, 181⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩], record25⟩
theorem entry25_valid : entry25.Valid := ⟨record25_disjoint, by decide⟩
-- Orbit 31; source mask decoded in canonical edge order.
def entry26 : Entry := ⟨703492828586395843027244717147693921081233706481056809237960927760018591109016486053238895230047931594426240205591900645192755846151904, {62, 136, 181, 312}, ![⟨0, 3, 116, 62⟩, ⟨0, 6, 60, 62⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 3, 97, 181⟩, ⟨2, 6, 41, 181⟩, ⟨3, 4, 96, 312⟩, ⟨4, 6, 40, 312⟩], record26⟩
theorem entry26_valid : entry26.Valid := ⟨record26_disjoint, by decide⟩
-- Orbit 31; source mask decoded in canonical edge order.
def entry27 : Entry := ⟨703492828586395843027244717147693921081233706481056809237960927760018591109016486053238895230047931594426240205591900645192755846151904, {62, 136, 261, 312}, ![⟨0, 3, 116, 62⟩, ⟨0, 6, 60, 62⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨3, 4, 96, 312⟩, ⟨4, 6, 40, 312⟩], record27⟩
theorem entry27_valid : entry27.Valid := ⟨record27_disjoint, by decide⟩
-- Orbit 31; source mask decoded in canonical edge order.
def entry28 : Entry := ⟨703492828586395843027244717147693921081233706481056809237960927760018591109016486053238895230047931594426240205591900645192755846151904, {62, 181, 261, 312}, ![⟨0, 3, 116, 62⟩, ⟨0, 6, 60, 62⟩, ⟨2, 3, 97, 181⟩, ⟨2, 6, 41, 181⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨3, 4, 96, 312⟩, ⟨4, 6, 40, 312⟩], record28⟩
theorem entry28_valid : entry28.Valid := ⟨record28_disjoint, by decide⟩
-- Orbit 31; source mask decoded in canonical edge order.
def entry29 : Entry := ⟨703492828586395843027244717147693921081233706481056809237960927760018591109016486053238895230047931594426240205591900645192755846151904, {136, 181, 261, 312}, ![⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 3, 97, 181⟩, ⟨2, 6, 41, 181⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨3, 4, 96, 312⟩, ⟨4, 6, 40, 312⟩], record29⟩
theorem entry29_valid : entry29.Valid := ⟨record29_disjoint, by decide⟩
-- Orbit 66; source mask decoded in canonical edge order.
def entry30 : Entry := ⟨717865411425340795173707829253800040993816883953036435745284184134858669349384979494161581807383475382923935261995814861277420451888872, {0, 63, 200, 247}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨3, 5, 16, 200⟩, ⟨3, 6, 16, 200⟩, ⟨3, 5, 71, 247⟩, ⟨3, 6, 39, 247⟩], record30⟩
theorem entry30_valid : entry30.Valid := ⟨record30_disjoint, by decide⟩
-- Orbit 66; source mask decoded in canonical edge order.
def entry31 : Entry := ⟨717865411425340795173707829253800040993816883953036435745284184134858669349384979494161581807383475382923935261995814861277420451888872, {0, 63, 200, 265}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨3, 5, 16, 200⟩, ⟨3, 6, 16, 200⟩, ⟨4, 5, 9, 265⟩, ⟨4, 6, 9, 265⟩], record31⟩
theorem entry31_valid : entry31.Valid := ⟨record31_disjoint, by decide⟩
-- Orbit 66; source mask decoded in canonical edge order.
def entry32 : Entry := ⟨717865411425340795173707829253800040993816883953036435745284184134858669349384979494161581807383475382923935261995814861277420451888872, {0, 63, 200, 310}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨3, 5, 16, 200⟩, ⟨3, 6, 16, 200⟩, ⟨4, 5, 70, 310⟩, ⟨4, 6, 38, 310⟩], record32⟩
theorem entry32_valid : entry32.Valid := ⟨record32_disjoint, by decide⟩
-- Orbit 66; source mask decoded in canonical edge order.
def entry33 : Entry := ⟨717865411425340795173707829253800040993816883953036435745284184134858669349384979494161581807383475382923935261995814861277420451888872, {0, 63, 247, 265}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨3, 5, 71, 247⟩, ⟨3, 6, 39, 247⟩, ⟨4, 5, 9, 265⟩, ⟨4, 6, 9, 265⟩], record33⟩
theorem entry33_valid : entry33.Valid := ⟨record33_disjoint, by decide⟩
-- Orbit 66; source mask decoded in canonical edge order.
def entry34 : Entry := ⟨717865411425340795173707829253800040993816883953036435745284184134858669349384979494161581807383475382923935261995814861277420451888872, {0, 63, 247, 310}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨3, 5, 71, 247⟩, ⟨3, 6, 39, 247⟩, ⟨4, 5, 70, 310⟩, ⟨4, 6, 38, 310⟩], record34⟩
theorem entry34_valid : entry34.Valid := ⟨record34_disjoint, by decide⟩
-- Orbit 66; source mask decoded in canonical edge order.
def entry35 : Entry := ⟨717865411425340795173707829253800040993816883953036435745284184134858669349384979494161581807383475382923935261995814861277420451888872, {0, 63, 265, 310}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨4, 5, 9, 265⟩, ⟨4, 6, 9, 265⟩, ⟨4, 5, 70, 310⟩, ⟨4, 6, 38, 310⟩], record35⟩
theorem entry35_valid : entry35.Valid := ⟨record35_disjoint, by decide⟩
-- Orbit 66; source mask decoded in canonical edge order.
def entry36 : Entry := ⟨717865411425340795173707829253800040993816883953036435745284184134858669349384979494161581807383475382923935261995814861277420451888872, {0, 200, 247, 265}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨3, 5, 16, 200⟩, ⟨3, 6, 16, 200⟩, ⟨3, 5, 71, 247⟩, ⟨3, 6, 39, 247⟩, ⟨4, 5, 9, 265⟩, ⟨4, 6, 9, 265⟩], record36⟩
theorem entry36_valid : entry36.Valid := ⟨record36_disjoint, by decide⟩
-- Orbit 66; source mask decoded in canonical edge order.
def entry37 : Entry := ⟨717865411425340795173707829253800040993816883953036435745284184134858669349384979494161581807383475382923935261995814861277420451888872, {0, 200, 247, 310}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨3, 5, 16, 200⟩, ⟨3, 6, 16, 200⟩, ⟨3, 5, 71, 247⟩, ⟨3, 6, 39, 247⟩, ⟨4, 5, 70, 310⟩, ⟨4, 6, 38, 310⟩], record37⟩
theorem entry37_valid : entry37.Valid := ⟨record37_disjoint, by decide⟩
-- Orbit 66; source mask decoded in canonical edge order.
def entry38 : Entry := ⟨717865411425340795173707829253800040993816883953036435745284184134858669349384979494161581807383475382923935261995814861277420451888872, {0, 200, 265, 310}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨3, 5, 16, 200⟩, ⟨3, 6, 16, 200⟩, ⟨4, 5, 9, 265⟩, ⟨4, 6, 9, 265⟩, ⟨4, 5, 70, 310⟩, ⟨4, 6, 38, 310⟩], record38⟩
theorem entry38_valid : entry38.Valid := ⟨record38_disjoint, by decide⟩
-- Orbit 66; source mask decoded in canonical edge order.
def entry39 : Entry := ⟨717865411425340795173707829253800040993816883953036435745284184134858669349384979494161581807383475382923935261995814861277420451888872, {0, 247, 265, 310}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨3, 5, 71, 247⟩, ⟨3, 6, 39, 247⟩, ⟨4, 5, 9, 265⟩, ⟨4, 6, 9, 265⟩, ⟨4, 5, 70, 310⟩, ⟨4, 6, 38, 310⟩], record39⟩
theorem entry39_valid : entry39.Valid := ⟨record39_disjoint, by decide⟩
-- Orbit 66; source mask decoded in canonical edge order.
def entry40 : Entry := ⟨717865411425340795173707829253800040993816883953036435745284184134858669349384979494161581807383475382923935261995814861277420451888872, {63, 200, 247, 265}, ![⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨3, 5, 16, 200⟩, ⟨3, 6, 16, 200⟩, ⟨3, 5, 71, 247⟩, ⟨3, 6, 39, 247⟩, ⟨4, 5, 9, 265⟩, ⟨4, 6, 9, 265⟩], record40⟩
theorem entry40_valid : entry40.Valid := ⟨record40_disjoint, by decide⟩
-- Orbit 66; source mask decoded in canonical edge order.
def entry41 : Entry := ⟨717865411425340795173707829253800040993816883953036435745284184134858669349384979494161581807383475382923935261995814861277420451888872, {63, 200, 247, 310}, ![⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨3, 5, 16, 200⟩, ⟨3, 6, 16, 200⟩, ⟨3, 5, 71, 247⟩, ⟨3, 6, 39, 247⟩, ⟨4, 5, 70, 310⟩, ⟨4, 6, 38, 310⟩], record41⟩
theorem entry41_valid : entry41.Valid := ⟨record41_disjoint, by decide⟩
-- Orbit 66; source mask decoded in canonical edge order.
def entry42 : Entry := ⟨717865411425340795173707829253800040993816883953036435745284184134858669349384979494161581807383475382923935261995814861277420451888872, {63, 200, 265, 310}, ![⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨3, 5, 16, 200⟩, ⟨3, 6, 16, 200⟩, ⟨4, 5, 9, 265⟩, ⟨4, 6, 9, 265⟩, ⟨4, 5, 70, 310⟩, ⟨4, 6, 38, 310⟩], record42⟩
theorem entry42_valid : entry42.Valid := ⟨record42_disjoint, by decide⟩
-- Orbit 66; source mask decoded in canonical edge order.
def entry43 : Entry := ⟨717865411425340795173707829253800040993816883953036435745284184134858669349384979494161581807383475382923935261995814861277420451888872, {63, 247, 265, 310}, ![⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨3, 5, 71, 247⟩, ⟨3, 6, 39, 247⟩, ⟨4, 5, 9, 265⟩, ⟨4, 6, 9, 265⟩, ⟨4, 5, 70, 310⟩, ⟨4, 6, 38, 310⟩], record43⟩
theorem entry43_valid : entry43.Valid := ⟨record43_disjoint, by decide⟩
-- Orbit 66; source mask decoded in canonical edge order.
def entry44 : Entry := ⟨717865411425340795173707829253800040993816883953036435745284184134858669349384979494161581807383475382923935261995814861277420451888872, {200, 247, 265, 310}, ![⟨3, 5, 16, 200⟩, ⟨3, 6, 16, 200⟩, ⟨3, 5, 71, 247⟩, ⟨3, 6, 39, 247⟩, ⟨4, 5, 9, 265⟩, ⟨4, 6, 9, 265⟩, ⟨4, 5, 70, 310⟩, ⟨4, 6, 38, 310⟩], record44⟩
theorem entry44_valid : entry44.Valid := ⟨record44_disjoint, by decide⟩
-- Orbit 68; source mask decoded in canonical edge order.
def entry45 : Entry := ⟨720616143449862465397522193477581094167317250429996862052191966548239694307191224915150164697482063012505346409598095139439544053366496, {0, 63, 136, 183}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩], record45⟩
theorem entry45_valid : entry45.Valid := ⟨record45_disjoint, by decide⟩
-- Orbit 68; source mask decoded in canonical edge order.
def entry46 : Entry := ⟨720616143449862465397522193477581094167317250429996862052191966548239694307191224915150164697482063012505346409598095139439544053366496, {0, 63, 136, 261}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩], record46⟩
theorem entry46_valid : entry46.Valid := ⟨record46_disjoint, by decide⟩
-- Orbit 68; source mask decoded in canonical edge order.
def entry47 : Entry := ⟨720616143449862465397522193477581094167317250429996862052191966548239694307191224915150164697482063012505346409598095139439544053366496, {0, 63, 136, 314}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record47⟩
theorem entry47_valid : entry47.Valid := ⟨record47_disjoint, by decide⟩
-- Orbit 68; source mask decoded in canonical edge order.
def entry48 : Entry := ⟨720616143449862465397522193477581094167317250429996862052191966548239694307191224915150164697482063012505346409598095139439544053366496, {0, 63, 183, 261}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩], record48⟩
theorem entry48_valid : entry48.Valid := ⟨record48_disjoint, by decide⟩
-- Orbit 68; source mask decoded in canonical edge order.
def entry49 : Entry := ⟨720616143449862465397522193477581094167317250429996862052191966548239694307191224915150164697482063012505346409598095139439544053366496, {0, 63, 183, 314}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record49⟩
theorem entry49_valid : entry49.Valid := ⟨record49_disjoint, by decide⟩
-- Orbit 68; source mask decoded in canonical edge order.
def entry50 : Entry := ⟨720616143449862465397522193477581094167317250429996862052191966548239694307191224915150164697482063012505346409598095139439544053366496, {0, 63, 261, 314}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record50⟩
theorem entry50_valid : entry50.Valid := ⟨record50_disjoint, by decide⟩
-- Orbit 68; source mask decoded in canonical edge order.
def entry51 : Entry := ⟨720616143449862465397522193477581094167317250429996862052191966548239694307191224915150164697482063012505346409598095139439544053366496, {0, 136, 183, 261}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩], record51⟩
theorem entry51_valid : entry51.Valid := ⟨record51_disjoint, by decide⟩
-- Orbit 68; source mask decoded in canonical edge order.
def entry52 : Entry := ⟨720616143449862465397522193477581094167317250429996862052191966548239694307191224915150164697482063012505346409598095139439544053366496, {0, 136, 183, 314}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record52⟩
theorem entry52_valid : entry52.Valid := ⟨record52_disjoint, by decide⟩
-- Orbit 68; source mask decoded in canonical edge order.
def entry53 : Entry := ⟨720616143449862465397522193477581094167317250429996862052191966548239694307191224915150164697482063012505346409598095139439544053366496, {0, 136, 261, 314}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record53⟩
theorem entry53_valid : entry53.Valid := ⟨record53_disjoint, by decide⟩
-- Orbit 68; source mask decoded in canonical edge order.
def entry54 : Entry := ⟨720616143449862465397522193477581094167317250429996862052191966548239694307191224915150164697482063012505346409598095139439544053366496, {0, 183, 261, 314}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record54⟩
theorem entry54_valid : entry54.Valid := ⟨record54_disjoint, by decide⟩
-- Orbit 68; source mask decoded in canonical edge order.
def entry55 : Entry := ⟨720616143449862465397522193477581094167317250429996862052191966548239694307191224915150164697482063012505346409598095139439544053366496, {63, 136, 183, 261}, ![⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩], record55⟩
theorem entry55_valid : entry55.Valid := ⟨record55_disjoint, by decide⟩
-- Orbit 68; source mask decoded in canonical edge order.
def entry56 : Entry := ⟨720616143449862465397522193477581094167317250429996862052191966548239694307191224915150164697482063012505346409598095139439544053366496, {63, 136, 183, 314}, ![⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record56⟩
theorem entry56_valid : entry56.Valid := ⟨record56_disjoint, by decide⟩
-- Orbit 68; source mask decoded in canonical edge order.
def entry57 : Entry := ⟨720616143449862465397522193477581094167317250429996862052191966548239694307191224915150164697482063012505346409598095139439544053366496, {63, 136, 261, 314}, ![⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record57⟩
theorem entry57_valid : entry57.Valid := ⟨record57_disjoint, by decide⟩
-- Orbit 68; source mask decoded in canonical edge order.
def entry58 : Entry := ⟨720616143449862465397522193477581094167317250429996862052191966548239694307191224915150164697482063012505346409598095139439544053366496, {63, 183, 261, 314}, ![⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record58⟩
theorem entry58_valid : entry58.Valid := ⟨record58_disjoint, by decide⟩
-- Orbit 68; source mask decoded in canonical edge order.
def entry59 : Entry := ⟨720616143449862465397522193477581094167317250429996862052191966548239694307191224915150164697482063012505346409598095139439544053366496, {136, 183, 261, 314}, ![⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record59⟩
theorem entry59_valid : entry59.Valid := ⟨record59_disjoint, by decide⟩
-- Orbit 73; source mask decoded in canonical edge order.
def entry60 : Entry := ⟨720528111188396241463306303786681857278296065493535565336781261174544652411674508644506505876868271575523970198772574677959775808745184, {0, 63, 136, 183}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩], record60⟩
theorem entry60_valid : entry60.Valid := ⟨record60_disjoint, by decide⟩
-- Orbit 73; source mask decoded in canonical edge order.
def entry61 : Entry := ⟨720528111188396241463306303786681857278296065493535565336781261174544652411674508644506505876868271575523970198772574677959775808745184, {0, 63, 136, 261}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩], record61⟩
theorem entry61_valid : entry61.Valid := ⟨record61_disjoint, by decide⟩
-- Orbit 73; source mask decoded in canonical edge order.
def entry62 : Entry := ⟨720528111188396241463306303786681857278296065493535565336781261174544652411674508644506505876868271575523970198772574677959775808745184, {0, 63, 136, 314}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record62⟩
theorem entry62_valid : entry62.Valid := ⟨record62_disjoint, by decide⟩
-- Orbit 73; source mask decoded in canonical edge order.
def entry63 : Entry := ⟨720528111188396241463306303786681857278296065493535565336781261174544652411674508644506505876868271575523970198772574677959775808745184, {0, 63, 183, 261}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩], record63⟩
theorem entry63_valid : entry63.Valid := ⟨record63_disjoint, by decide⟩
-- Orbit 73; source mask decoded in canonical edge order.
def entry64 : Entry := ⟨720528111188396241463306303786681857278296065493535565336781261174544652411674508644506505876868271575523970198772574677959775808745184, {0, 63, 183, 314}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record64⟩
theorem entry64_valid : entry64.Valid := ⟨record64_disjoint, by decide⟩
-- Orbit 73; source mask decoded in canonical edge order.
def entry65 : Entry := ⟨720528111188396241463306303786681857278296065493535565336781261174544652411674508644506505876868271575523970198772574677959775808745184, {0, 63, 261, 314}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record65⟩
theorem entry65_valid : entry65.Valid := ⟨record65_disjoint, by decide⟩
-- Orbit 73; source mask decoded in canonical edge order.
def entry66 : Entry := ⟨720528111188396241463306303786681857278296065493535565336781261174544652411674508644506505876868271575523970198772574677959775808745184, {0, 136, 183, 261}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩], record66⟩
theorem entry66_valid : entry66.Valid := ⟨record66_disjoint, by decide⟩
-- Orbit 73; source mask decoded in canonical edge order.
def entry67 : Entry := ⟨720528111188396241463306303786681857278296065493535565336781261174544652411674508644506505876868271575523970198772574677959775808745184, {0, 136, 183, 314}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record67⟩
theorem entry67_valid : entry67.Valid := ⟨record67_disjoint, by decide⟩
-- Orbit 73; source mask decoded in canonical edge order.
def entry68 : Entry := ⟨720528111188396241463306303786681857278296065493535565336781261174544652411674508644506505876868271575523970198772574677959775808745184, {0, 136, 261, 314}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record68⟩
theorem entry68_valid : entry68.Valid := ⟨record68_disjoint, by decide⟩
-- Orbit 73; source mask decoded in canonical edge order.
def entry69 : Entry := ⟨720528111188396241463306303786681857278296065493535565336781261174544652411674508644506505876868271575523970198772574677959775808745184, {0, 183, 261, 314}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record69⟩
theorem entry69_valid : entry69.Valid := ⟨record69_disjoint, by decide⟩
-- Orbit 73; source mask decoded in canonical edge order.
def entry70 : Entry := ⟨720528111188396241463306303786681857278296065493535565336781261174544652411674508644506505876868271575523970198772574677959775808745184, {63, 136, 183, 261}, ![⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩], record70⟩
theorem entry70_valid : entry70.Valid := ⟨record70_disjoint, by decide⟩
-- Orbit 73; source mask decoded in canonical edge order.
def entry71 : Entry := ⟨720528111188396241463306303786681857278296065493535565336781261174544652411674508644506505876868271575523970198772574677959775808745184, {63, 136, 183, 314}, ![⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record71⟩
theorem entry71_valid : entry71.Valid := ⟨record71_disjoint, by decide⟩
-- Orbit 73; source mask decoded in canonical edge order.
def entry72 : Entry := ⟨720528111188396241463306303786681857278296065493535565336781261174544652411674508644506505876868271575523970198772574677959775808745184, {63, 136, 261, 314}, ![⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record72⟩
theorem entry72_valid : entry72.Valid := ⟨record72_disjoint, by decide⟩
-- Orbit 73; source mask decoded in canonical edge order.
def entry73 : Entry := ⟨720528111188396241463306303786681857278296065493535565336781261174544652411674508644506505876868271575523970198772574677959775808745184, {63, 183, 261, 314}, ![⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record73⟩
theorem entry73_valid : entry73.Valid := ⟨record73_disjoint, by decide⟩
-- Orbit 73; source mask decoded in canonical edge order.
def entry74 : Entry := ⟨720528111188396241463306303786681857278296065493535565336781261174544652411674508644506505876868271575523970198772574677959775808745184, {136, 183, 261, 314}, ![⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record74⟩
theorem entry74_valid : entry74.Valid := ⟨record74_disjoint, by decide⟩
-- Orbit 87; source mask decoded in canonical edge order.
def entry75 : Entry := ⟨720528111187074129525725806588706354830480833679140917877160058208581354222082532601365292357648877113391071159568336242805776581492448, {0, 63, 136, 183}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩], record75⟩
theorem entry75_valid : entry75.Valid := ⟨record75_disjoint, by decide⟩
-- Orbit 87; source mask decoded in canonical edge order.
def entry76 : Entry := ⟨720528111187074129525725806588706354830480833679140917877160058208581354222082532601365292357648877113391071159568336242805776581492448, {0, 63, 136, 261}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩], record76⟩
theorem entry76_valid : entry76.Valid := ⟨record76_disjoint, by decide⟩
-- Orbit 87; source mask decoded in canonical edge order.
def entry77 : Entry := ⟨720528111187074129525725806588706354830480833679140917877160058208581354222082532601365292357648877113391071159568336242805776581492448, {0, 63, 136, 314}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record77⟩
theorem entry77_valid : entry77.Valid := ⟨record77_disjoint, by decide⟩
-- Orbit 87; source mask decoded in canonical edge order.
def entry78 : Entry := ⟨720528111187074129525725806588706354830480833679140917877160058208581354222082532601365292357648877113391071159568336242805776581492448, {0, 63, 183, 261}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩], record78⟩
theorem entry78_valid : entry78.Valid := ⟨record78_disjoint, by decide⟩
-- Orbit 87; source mask decoded in canonical edge order.
def entry79 : Entry := ⟨720528111187074129525725806588706354830480833679140917877160058208581354222082532601365292357648877113391071159568336242805776581492448, {0, 63, 183, 314}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record79⟩
theorem entry79_valid : entry79.Valid := ⟨record79_disjoint, by decide⟩
-- Orbit 87; source mask decoded in canonical edge order.
def entry80 : Entry := ⟨720528111187074129525725806588706354830480833679140917877160058208581354222082532601365292357648877113391071159568336242805776581492448, {0, 63, 261, 314}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record80⟩
theorem entry80_valid : entry80.Valid := ⟨record80_disjoint, by decide⟩
-- Orbit 87; source mask decoded in canonical edge order.
def entry81 : Entry := ⟨720528111187074129525725806588706354830480833679140917877160058208581354222082532601365292357648877113391071159568336242805776581492448, {0, 136, 183, 261}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩], record81⟩
theorem entry81_valid : entry81.Valid := ⟨record81_disjoint, by decide⟩
-- Orbit 87; source mask decoded in canonical edge order.
def entry82 : Entry := ⟨720528111187074129525725806588706354830480833679140917877160058208581354222082532601365292357648877113391071159568336242805776581492448, {0, 136, 183, 314}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record82⟩
theorem entry82_valid : entry82.Valid := ⟨record82_disjoint, by decide⟩
-- Orbit 87; source mask decoded in canonical edge order.
def entry83 : Entry := ⟨720528111187074129525725806588706354830480833679140917877160058208581354222082532601365292357648877113391071159568336242805776581492448, {0, 136, 261, 314}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record83⟩
theorem entry83_valid : entry83.Valid := ⟨record83_disjoint, by decide⟩
-- Orbit 87; source mask decoded in canonical edge order.
def entry84 : Entry := ⟨720528111187074129525725806588706354830480833679140917877160058208581354222082532601365292357648877113391071159568336242805776581492448, {0, 183, 261, 314}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record84⟩
theorem entry84_valid : entry84.Valid := ⟨record84_disjoint, by decide⟩
-- Orbit 87; source mask decoded in canonical edge order.
def entry85 : Entry := ⟨720528111187074129525725806588706354830480833679140917877160058208581354222082532601365292357648877113391071159568336242805776581492448, {63, 136, 183, 261}, ![⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩], record85⟩
theorem entry85_valid : entry85.Valid := ⟨record85_disjoint, by decide⟩
-- Orbit 87; source mask decoded in canonical edge order.
def entry86 : Entry := ⟨720528111187074129525725806588706354830480833679140917877160058208581354222082532601365292357648877113391071159568336242805776581492448, {63, 136, 183, 314}, ![⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record86⟩
theorem entry86_valid : entry86.Valid := ⟨record86_disjoint, by decide⟩
-- Orbit 87; source mask decoded in canonical edge order.
def entry87 : Entry := ⟨720528111187074129525725806588706354830480833679140917877160058208581354222082532601365292357648877113391071159568336242805776581492448, {63, 136, 261, 314}, ![⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record87⟩
theorem entry87_valid : entry87.Valid := ⟨record87_disjoint, by decide⟩
-- Orbit 87; source mask decoded in canonical edge order.
def entry88 : Entry := ⟨720528111187074129525725806588706354830480833679140917877160058208581354222082532601365292357648877113391071159568336242805776581492448, {63, 183, 261, 314}, ![⟨0, 5, 94, 63⟩, ⟨0, 6, 62, 63⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record88⟩
theorem entry88_valid : entry88.Valid := ⟨record88_disjoint, by decide⟩
-- Orbit 87; source mask decoded in canonical edge order.
def entry89 : Entry := ⟨720528111187074129525725806588706354830480833679140917877160058208581354222082532601365292357648877113391071159568336242805776581492448, {136, 183, 261, 314}, ![⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 5, 75, 183⟩, ⟨2, 6, 43, 183⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨4, 5, 74, 314⟩, ⟨4, 6, 42, 314⟩], record89⟩
theorem entry89_valid : entry89.Valid := ⟨record89_disjoint, by decide⟩
-- Orbit 104; source mask decoded in canonical edge order.
def entry90 : Entry := ⟨703490055916701722212384988426784480472737681876203466424414647585085088567290544090524956303521400996282024630713617482118076375596768, {0, 62, 136, 181}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 3, 116, 62⟩, ⟨0, 6, 60, 62⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 3, 97, 181⟩, ⟨2, 6, 41, 181⟩], record90⟩
theorem entry90_valid : entry90.Valid := ⟨record90_disjoint, by decide⟩
-- Orbit 104; source mask decoded in canonical edge order.
def entry91 : Entry := ⟨703490055916701722212384988426784480472737681876203466424414647585085088567290544090524956303521400996282024630713617482118076375596768, {0, 62, 136, 261}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 3, 116, 62⟩, ⟨0, 6, 60, 62⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩], record91⟩
theorem entry91_valid : entry91.Valid := ⟨record91_disjoint, by decide⟩
-- Orbit 104; source mask decoded in canonical edge order.
def entry92 : Entry := ⟨703490055916701722212384988426784480472737681876203466424414647585085088567290544090524956303521400996282024630713617482118076375596768, {0, 62, 136, 312}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 3, 116, 62⟩, ⟨0, 6, 60, 62⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨3, 4, 96, 312⟩, ⟨4, 6, 40, 312⟩], record92⟩
theorem entry92_valid : entry92.Valid := ⟨record92_disjoint, by decide⟩
-- Orbit 104; source mask decoded in canonical edge order.
def entry93 : Entry := ⟨703490055916701722212384988426784480472737681876203466424414647585085088567290544090524956303521400996282024630713617482118076375596768, {0, 62, 181, 261}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 3, 116, 62⟩, ⟨0, 6, 60, 62⟩, ⟨2, 3, 97, 181⟩, ⟨2, 6, 41, 181⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩], record93⟩
theorem entry93_valid : entry93.Valid := ⟨record93_disjoint, by decide⟩
-- Orbit 104; source mask decoded in canonical edge order.
def entry94 : Entry := ⟨703490055916701722212384988426784480472737681876203466424414647585085088567290544090524956303521400996282024630713617482118076375596768, {0, 62, 181, 312}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 3, 116, 62⟩, ⟨0, 6, 60, 62⟩, ⟨2, 3, 97, 181⟩, ⟨2, 6, 41, 181⟩, ⟨3, 4, 96, 312⟩, ⟨4, 6, 40, 312⟩], record94⟩
theorem entry94_valid : entry94.Valid := ⟨record94_disjoint, by decide⟩
-- Orbit 104; source mask decoded in canonical edge order.
def entry95 : Entry := ⟨703490055916701722212384988426784480472737681876203466424414647585085088567290544090524956303521400996282024630713617482118076375596768, {0, 62, 261, 312}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨0, 3, 116, 62⟩, ⟨0, 6, 60, 62⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨3, 4, 96, 312⟩, ⟨4, 6, 40, 312⟩], record95⟩
theorem entry95_valid : entry95.Valid := ⟨record95_disjoint, by decide⟩
-- Orbit 104; source mask decoded in canonical edge order.
def entry96 : Entry := ⟨703490055916701722212384988426784480472737681876203466424414647585085088567290544090524956303521400996282024630713617482118076375596768, {0, 136, 181, 261}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 3, 97, 181⟩, ⟨2, 6, 41, 181⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩], record96⟩
theorem entry96_valid : entry96.Valid := ⟨record96_disjoint, by decide⟩
-- Orbit 104; source mask decoded in canonical edge order.
def entry97 : Entry := ⟨703490055916701722212384988426784480472737681876203466424414647585085088567290544090524956303521400996282024630713617482118076375596768, {0, 136, 181, 312}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 3, 97, 181⟩, ⟨2, 6, 41, 181⟩, ⟨3, 4, 96, 312⟩, ⟨4, 6, 40, 312⟩], record97⟩
theorem entry97_valid : entry97.Valid := ⟨record97_disjoint, by decide⟩
-- Orbit 104; source mask decoded in canonical edge order.
def entry98 : Entry := ⟨703490055916701722212384988426784480472737681876203466424414647585085088567290544090524956303521400996282024630713617482118076375596768, {0, 136, 261, 312}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨3, 4, 96, 312⟩, ⟨4, 6, 40, 312⟩], record98⟩
theorem entry98_valid : entry98.Valid := ⟨record98_disjoint, by decide⟩
-- Orbit 104; source mask decoded in canonical edge order.
def entry99 : Entry := ⟨703490055916701722212384988426784480472737681876203466424414647585085088567290544090524956303521400996282024630713617482118076375596768, {0, 181, 261, 312}, ![⟨0, 5, 0, 0⟩, ⟨0, 6, 0, 0⟩, ⟨2, 3, 97, 181⟩, ⟨2, 6, 41, 181⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨3, 4, 96, 312⟩, ⟨4, 6, 40, 312⟩], record99⟩
theorem entry99_valid : entry99.Valid := ⟨record99_disjoint, by decide⟩
-- Orbit 104; source mask decoded in canonical edge order.
def entry100 : Entry := ⟨703490055916701722212384988426784480472737681876203466424414647585085088567290544090524956303521400996282024630713617482118076375596768, {62, 136, 181, 261}, ![⟨0, 3, 116, 62⟩, ⟨0, 6, 60, 62⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 3, 97, 181⟩, ⟨2, 6, 41, 181⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩], record100⟩
theorem entry100_valid : entry100.Valid := ⟨record100_disjoint, by decide⟩
-- Orbit 104; source mask decoded in canonical edge order.
def entry101 : Entry := ⟨703490055916701722212384988426784480472737681876203466424414647585085088567290544090524956303521400996282024630713617482118076375596768, {62, 136, 181, 312}, ![⟨0, 3, 116, 62⟩, ⟨0, 6, 60, 62⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 3, 97, 181⟩, ⟨2, 6, 41, 181⟩, ⟨3, 4, 96, 312⟩, ⟨4, 6, 40, 312⟩], record101⟩
theorem entry101_valid : entry101.Valid := ⟨record101_disjoint, by decide⟩
-- Orbit 104; source mask decoded in canonical edge order.
def entry102 : Entry := ⟨703490055916701722212384988426784480472737681876203466424414647585085088567290544090524956303521400996282024630713617482118076375596768, {62, 136, 261, 312}, ![⟨0, 3, 116, 62⟩, ⟨0, 6, 60, 62⟩, ⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨3, 4, 96, 312⟩, ⟨4, 6, 40, 312⟩], record102⟩
theorem entry102_valid : entry102.Valid := ⟨record102_disjoint, by decide⟩
-- Orbit 104; source mask decoded in canonical edge order.
def entry103 : Entry := ⟨703490055916701722212384988426784480472737681876203466424414647585085088567290544090524956303521400996282024630713617482118076375596768, {62, 181, 261, 312}, ![⟨0, 3, 116, 62⟩, ⟨0, 6, 60, 62⟩, ⟨2, 3, 97, 181⟩, ⟨2, 6, 41, 181⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨3, 4, 96, 312⟩, ⟨4, 6, 40, 312⟩], record103⟩
theorem entry103_valid : entry103.Valid := ⟨record103_disjoint, by decide⟩
-- Orbit 104; source mask decoded in canonical edge order.
def entry104 : Entry := ⟨703490055916701722212384988426784480472737681876203466424414647585085088567290544090524956303521400996282024630713617482118076375596768, {136, 181, 261, 312}, ![⟨2, 5, 16, 136⟩, ⟨2, 6, 16, 136⟩, ⟨2, 3, 97, 181⟩, ⟨2, 6, 41, 181⟩, ⟨4, 5, 5, 261⟩, ⟨4, 6, 5, 261⟩, ⟨3, 4, 96, 312⟩, ⟨4, 6, 40, 312⟩], record104⟩
theorem entry104_valid : entry104.Valid := ⟨record104_disjoint, by decide⟩

def entries : List Entry := [entry0, entry1, entry2, entry3, entry4, entry5, entry6, entry7, entry8, entry9, entry10, entry11, entry12, entry13, entry14, entry15, entry16, entry17, entry18, entry19, entry20, entry21, entry22, entry23, entry24, entry25, entry26, entry27, entry28, entry29, entry30, entry31, entry32, entry33, entry34, entry35, entry36, entry37, entry38, entry39, entry40, entry41, entry42, entry43, entry44, entry45, entry46, entry47, entry48, entry49, entry50, entry51, entry52, entry53, entry54, entry55, entry56, entry57, entry58, entry59, entry60, entry61, entry62, entry63, entry64, entry65, entry66, entry67, entry68, entry69, entry70, entry71, entry72, entry73, entry74, entry75, entry76, entry77, entry78, entry79, entry80, entry81, entry82, entry83, entry84, entry85, entry86, entry87, entry88, entry89, entry90, entry91, entry92, entry93, entry94, entry95, entry96, entry97, entry98, entry99, entry100, entry101, entry102, entry103, entry104]

theorem all_entries_valid (r : Entry) (hr : r ∈ entries) : r.Valid := by
  simp only [entries, List.mem_cons, List.not_mem_nil, or_false] at hr
  rcases hr with h0 | h1 | h2 | h3 | h4 | h5 | h6 | h7 | h8 | h9 | h10 | h11 | h12 | h13 | h14 | h15 | h16 | h17 | h18 | h19 | h20 | h21 | h22 | h23 | h24 | h25 | h26 | h27 | h28 | h29 | h30 | h31 | h32 | h33 | h34 | h35 | h36 | h37 | h38 | h39 | h40 | h41 | h42 | h43 | h44 | h45 | h46 | h47 | h48 | h49 | h50 | h51 | h52 | h53 | h54 | h55 | h56 | h57 | h58 | h59 | h60 | h61 | h62 | h63 | h64 | h65 | h66 | h67 | h68 | h69 | h70 | h71 | h72 | h73 | h74 | h75 | h76 | h77 | h78 | h79 | h80 | h81 | h82 | h83 | h84 | h85 | h86 | h87 | h88 | h89 | h90 | h91 | h92 | h93 | h94 | h95 | h96 | h97 | h98 | h99 | h100 | h101 | h102 | h103 | h104
  · rw [h0]; exact entry0_valid
  · rw [h1]; exact entry1_valid
  · rw [h2]; exact entry2_valid
  · rw [h3]; exact entry3_valid
  · rw [h4]; exact entry4_valid
  · rw [h5]; exact entry5_valid
  · rw [h6]; exact entry6_valid
  · rw [h7]; exact entry7_valid
  · rw [h8]; exact entry8_valid
  · rw [h9]; exact entry9_valid
  · rw [h10]; exact entry10_valid
  · rw [h11]; exact entry11_valid
  · rw [h12]; exact entry12_valid
  · rw [h13]; exact entry13_valid
  · rw [h14]; exact entry14_valid
  · rw [h15]; exact entry15_valid
  · rw [h16]; exact entry16_valid
  · rw [h17]; exact entry17_valid
  · rw [h18]; exact entry18_valid
  · rw [h19]; exact entry19_valid
  · rw [h20]; exact entry20_valid
  · rw [h21]; exact entry21_valid
  · rw [h22]; exact entry22_valid
  · rw [h23]; exact entry23_valid
  · rw [h24]; exact entry24_valid
  · rw [h25]; exact entry25_valid
  · rw [h26]; exact entry26_valid
  · rw [h27]; exact entry27_valid
  · rw [h28]; exact entry28_valid
  · rw [h29]; exact entry29_valid
  · rw [h30]; exact entry30_valid
  · rw [h31]; exact entry31_valid
  · rw [h32]; exact entry32_valid
  · rw [h33]; exact entry33_valid
  · rw [h34]; exact entry34_valid
  · rw [h35]; exact entry35_valid
  · rw [h36]; exact entry36_valid
  · rw [h37]; exact entry37_valid
  · rw [h38]; exact entry38_valid
  · rw [h39]; exact entry39_valid
  · rw [h40]; exact entry40_valid
  · rw [h41]; exact entry41_valid
  · rw [h42]; exact entry42_valid
  · rw [h43]; exact entry43_valid
  · rw [h44]; exact entry44_valid
  · rw [h45]; exact entry45_valid
  · rw [h46]; exact entry46_valid
  · rw [h47]; exact entry47_valid
  · rw [h48]; exact entry48_valid
  · rw [h49]; exact entry49_valid
  · rw [h50]; exact entry50_valid
  · rw [h51]; exact entry51_valid
  · rw [h52]; exact entry52_valid
  · rw [h53]; exact entry53_valid
  · rw [h54]; exact entry54_valid
  · rw [h55]; exact entry55_valid
  · rw [h56]; exact entry56_valid
  · rw [h57]; exact entry57_valid
  · rw [h58]; exact entry58_valid
  · rw [h59]; exact entry59_valid
  · rw [h60]; exact entry60_valid
  · rw [h61]; exact entry61_valid
  · rw [h62]; exact entry62_valid
  · rw [h63]; exact entry63_valid
  · rw [h64]; exact entry64_valid
  · rw [h65]; exact entry65_valid
  · rw [h66]; exact entry66_valid
  · rw [h67]; exact entry67_valid
  · rw [h68]; exact entry68_valid
  · rw [h69]; exact entry69_valid
  · rw [h70]; exact entry70_valid
  · rw [h71]; exact entry71_valid
  · rw [h72]; exact entry72_valid
  · rw [h73]; exact entry73_valid
  · rw [h74]; exact entry74_valid
  · rw [h75]; exact entry75_valid
  · rw [h76]; exact entry76_valid
  · rw [h77]; exact entry77_valid
  · rw [h78]; exact entry78_valid
  · rw [h79]; exact entry79_valid
  · rw [h80]; exact entry80_valid
  · rw [h81]; exact entry81_valid
  · rw [h82]; exact entry82_valid
  · rw [h83]; exact entry83_valid
  · rw [h84]; exact entry84_valid
  · rw [h85]; exact entry85_valid
  · rw [h86]; exact entry86_valid
  · rw [h87]; exact entry87_valid
  · rw [h88]; exact entry88_valid
  · rw [h89]; exact entry89_valid
  · rw [h90]; exact entry90_valid
  · rw [h91]; exact entry91_valid
  · rw [h92]; exact entry92_valid
  · rw [h93]; exact entry93_valid
  · rw [h94]; exact entry94_valid
  · rw [h95]; exact entry95_valid
  · rw [h96]; exact entry96_valid
  · rw [h97]; exact entry97_valid
  · rw [h98]; exact entry98_valid
  · rw [h99]; exact entry99_valid
  · rw [h100]; exact entry100_valid
  · rw [h101]; exact entry101_valid
  · rw [h102]; exact entry102_valid
  · rw [h103]; exact entry103_valid
  · rw [h104]; exact entry104_valid

theorem all_source_records_require_eight (r : Entry) (hr : r ∈ entries)
    (target : Set ℕ) (deleted : Finset ℕ) (hfree : FaceFree target)
    (ha : ∀ e ∈ r.added, e ∈ target)
    (hk : ∀ e, r.seed.testBit e = true → e ∉ deleted → e ∈ target) :
    8 ≤ deleted.card :=
  entry_bound r (all_entries_valid r hr) target deleted hfree ha hk

end Nightfall.Q7SourcePacking

#print axioms Nightfall.Q7SourcePacking.tight_blocker_hit
#print axioms Nightfall.Q7SourcePacking.all_entries_valid
#print axioms Nightfall.Q7SourcePacking.all_source_records_require_eight
