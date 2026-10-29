# AXIOM / NIGHTFALL — Singer batch-insertion collision-core explosion

**Checkpoint:** 2026-10-29. **Issue:** #132 (Axiom self-designed). **Related assignments:** #46, #49 and Vesper #108/merged PR #110; Ryev PR #120. **Scientific lead:** Devin J. Wright. **Status:** self-contained mathematical proof, two independently coded exact finite verifiers; external referee and worldwide priority open.

## Precise theorem

Let G be a cyclic group of odd order v=q(q-1)+1 and D ⊂ G a cyclic (v,q,1) *perfect difference set*: every nonzero element of G occurs exactly once as an ordered difference x-y with x,y∈D. Let a,b∈G\D be two distinct prescribed insertion marks. For a∉D put

H_a = { {x,y,z} : x,y,z∈D, a+z=x+y },

with **set-valued supports** (diagonal x=y yields a two-element support; z=x or z=y is impossible). Repeated supports are deduplicated. Let H=H_a∪H_b and

c(a,b)= #{t∈D: #{S∈H:t∈S}≥3}.

**High-incidence core theorem:** If gcd(v,3)=1, then for **every** pair a≠b outside D,

    c(a,b) >= max(0, ceil((q-5)/2)).                                    (T1)

If 3 divides v, a conservative universal version is

    c(a,b) >= max(0, ceil((q-13)/2)).                                   (T2)

Consequently there are infinitely many Singer difference-set instances (projective plane orders n=2^(2h+1), q=n+1 and v=n²+n+1 coprime to 3) for which the high-incidence core of **every** two-point outside insertion has size Ω(q). In particular, c need not be bounded by the fixed insertion batch size 2.

**Scope:** These are ordinary old-old versus old-new collision supports, before any deletions or special protection constraints. The result obstructs **automatic k-only boundedness of the parameter c** in Vesper's exact batch-repair FPT algorithm; it is **not** an NP-hardness theorem, lower bound on alternative algorithms, impossibility of insertion, or improvement of Erdős #44/#156/#329. A candidate may still be repaired by polynomial-time methods exploiting more structure.

## Proof

1. In the integral group ring, the perfect-difference identity gives D D^(-1)=(q-1)[0]+G; hence D²D^(-1)=(q-1)D+qG. For a∉D there are exactly **q ordered triples** (x,y,z)∈D³ with x+y-z=a.

2. Let h_a count those triples with x=y. When gcd(v,3)=1, two different distinguished z roles cannot make the same set-valued support for fixed a: for a three-element set two possible equations differ by twice a nonzero difference (impossible since v odd); for a two-element set the two diagonal orientations differ by three times a nonzero difference (impossible since gcd(v,3)=1). Non-diagonal triples occur in swapped ordered pairs, so H_a has (q-h_a)/2 three-element supports and h_a two-element supports. Its total old-mark incidence is I_a=(3q+h_a)/2≥3q/2.

3. Each old t∈D lies in **at most two** distinct H_a supports. If t occurs in a sum-side role, then y-z=a-t is a nonzero difference and uniquely determines y,z; swapping the sum-side entries yields the same support. If t occurs in the subtracted role, x+y=a+t has at most one unordered solution in D by Sidon uniqueness. These roles may coincide, reducing degree, never increasing it.

4. For a≠b, at most **one three-element support** is common to H_a and H_b: subtracting two possible equations yields a-b=2(u-w) for some two old marks; since 2 is invertible and nonzero differences are unique, those two old marks and the third are fixed. At most **one two-element support** is shared: the two diagonal orientations imply a-b=3(u-w), and gcd(v,3)=1 again fixes the old pair. Thus the combined H has total incidence at least I_a+I_b-3-2≥3q-5.

5. Since each old mark is in at most two H_a and two H_b supports, all H-degrees are ≤4. If c old marks have degree≥3, the total incidence is at most 2(q-c)+4c=2q+2c. Combining 3q-5≤2q+2c gives (T1).

6. **3-torsion qualification:** when 3|v, a fixed a may have at most one merged two-element support from opposite diagonal orientations, by uniqueness of the two nonzero order-three differences. This subtracts at most two incidences per a. For a≠b there is still at most one common three-element support, while 3(u-w)=a-b has at most three solutions, hence at most three common two-element supports. The combined incidence is at least (3q-4)-(3+6)=3q-13, giving (T2). This conservative extension also covers all cyclic difference-set examples checked here. The assumption is essential to the **sharper constant**, not to the linear asymptotic phenomenon.

7. Infinite family: standard Singer projective difference sets exist for every prime-power projective-plane order n, with q=n+1 points and v=n²+n+1. Taking n=2^(2h+1) gives v≡1 mod3, so (T1) yields c≥(q-5)/2 for unbounded q. This uses classical Singer existence, rather than claiming that existence as a new theorem.

## Exact finite independent tests

`verify_core_independent.py` enumerates literal unordered {x,y} with repetitions and z, then deduplicates supports. `verify_core_difference.py` uses the unique nonzero-difference map and reconstructs supports with **no imported enumerator**. Both exhaust **6,894 unordered outside insertion pairs** over cyclic perfect-difference sets:

| v | q | pairs | exact minimum c | proven bound T1/T2 | maximum shared support count |
|--:|--:|--:|--:|--:|--:|
|7|3|6|1|0|1|
|13|4|36|1|0|1|
|21|5|120|2|0|1|
|31|6|300|2|1|1|
|57|8|1176|3|0|1|
|73|9|2016|4|2|1|
|91|10|3240|5|3|1|

**Concrete falsifier of batch-size-only c≤2|E|:** For v=91, D={0,1,3,9,27,49,56,61,77,81}, E={4,67}, all external pair sums are distinct within E, and the union has high-incidence old marks **{0,3,9,27,61}**, so c=5>4=2|E|. The shared support is {0,77,81}. The full degree histogram is reconstructed exactly by both codes.

**Negative control:** A mere Sidon subset {0,1,3} in Z/101Z with outside batch {50,75} has no ordinary supports and c=0; *perfect difference* completeness is essential. Another mutation that omits x=y must fail the q-representation identity for a=4 in the v=91 example. The v=21 case demonstrates why the simple `(q+h)/2` support identity cannot be carried across 3-torsion without correcting coincident diagonal orientations.

## Reproduce

