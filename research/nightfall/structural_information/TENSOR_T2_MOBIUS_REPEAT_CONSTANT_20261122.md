# Tensor T2 repeated-label Möbius compression — November 22, 2026

**Status: conditional improvement to a paper-level quantum theorem; exact integer equality identity independently formalized in Lean (kernel check pending).** Does not close all complex Hilbert-space estimates or certify the full simulator. Develops PR #1059/#1068; these are related parallel claims, not separate discoveries.

## Precise improvement

For the generic finite binary-label phase-oracle criterion, let K4 bound the nonzero-frequency ordered primitive four-slot lifts, let M2 bound nonzero ordered two-label XOR fibers in D=R∪{0}, and η>0 be the heavy-label threshold.

PR #1059/#1068 gave the **candidate** Fourier-tail inequality

    ||f - E[f | heavy original row readings]||₂
        <= (2 sqrt(K4) + 145 sqrt(M2)) sqrt(η).

The new proof replaces the 57 higher pair-equality intersections with FOUR triple-equality patterns. Using **the same frame-energy hypotheses** as PR #1059, the improved bound is

    ||f - E[f | heavy original row readings]||₂
        <= (2 sqrt(K4) + 35 sqrt(M2)) sqrt(η).

Thus the previously proposed *paper-level conditional* query count improves to

    Q <= min(|R|, ceil(2(2 sqrt(K4)+35 sqrt(M2))²/(ε²δ))).

For the coarse tensor six-site candidate K4=O(L^6), M2=O(L²), the exponent O(L^6/(ε²δ)) remains unchanged. The sharpening can be quantitatively important for other binary-label families whose M2 contribution dominates. It is **not yet a theorem in the Lean kernel about all quantum circuits**.

## Exact nonzero-XOR Möbius identity

Name the four labels a,b,a',b'. For nonzero total XOR z=a+b+a'+b' ≠0 (characteristic two), the only equality patterns are all-distinct, exactly one equal pair, or one equal triple with a different singleton. Two disjoint pairs or four equal labels force zero XOR. Therefore pointwise

    1[any repeated pair] =
        sum_{6 unordered slot-pairs e} 1[e equal]
        - 2 sum_{4 unordered slot-triples t} 1[t equal].    (★)

All-distinct gives 0=0; one pair gives 1=1; triple gives 1=3−2. Identity (★) includes the zero *label* where permitted, but is restricted to nonzero *total frequency*. It is false on zero frequency: a,a,b,b with a≠b gives left 1, right 2. The Fourier zero frequency is retained by the chosen conditional expectation, so it is irrelevant to the tail.

The attached Lean source TensorT2RepeatMobius.lean proves (★) as a general four-element equality theorem under the three disjoint-pair exclusions and derives those exclusions from exponent-two XOR ≠0. Its third named theorem checks the rational square-root upper bound ≤35. All proofs must pass actual compile/leanchecker/standard-axiom CI before promotion. No quantum Hilbert axiom is introduced.

## Hilbert energy argument, independently simplified

Let the four-path coefficient be c_{a,b,a',b'}. For z outside the span W of all heavy original rows, each tuple contains at least one nonzero light-stage label. The original source frame estimate bounds ungrouped squared coefficient energy of the union of the four light-slot sets by 4η.

- Each of the SIX single-equality grouped Fourier tails has L² norm ≤sqrt(2 M2 η), as established at paper level in PR #1059. Summing gives 6sqrt(2 M2 η).
- Let T be the union of the FOUR triple-and-singleton equality patterns. At nonzero z, these four patterns are disjoint, and there are at most 4 M2 original ordered quadruples in T with that XOR: choose the singleton position (four choices) and an ordered pair (triple label, singleton label) with XOR z (at most M2). By Cauchy–Schwarz over Fourier fibers and the original ungrouped light-slot energy bound,

    ||T tail||₂² <= (4 M2)*(4η) =16 M2 η.

Thus its tail norm is at most 4sqrt(M2 η). The **minus two** factor in (★) costs 8sqrt(M2 η). The total repeated-label tail is

    ||repeat tail||₂ <= (6sqrt(2)+8) sqrt(M2 η).

- The nonprimitive distinct zero-triple class remains bounded by 4(1+2sqrt(3)) sqrt(M2 η), using the existing paper-level Hilbert regroupings. Primitive class is ≤2sqrt(K4 η).

Hence the total pair-related constant is

    c = 6sqrt(2)+8+4(1+2sqrt(3))
      = 12+6sqrt(2)+8sqrt(3) = 34.341... <35.

For a **rational exact certificate**, sqrt(2)≤3/2 and sqrt(3)≤7/4, giving c≤35. The source Lean scalar theorem proves that arithmetic claim, not the operator inequality.

## Independent exact check and failure fixture

The Python checker check_t2_repeat_mobius_exact.py exhausts all 8⁴ ordered quadruples in F₂³ including the zero label; precisely 3,584 have nonzero total XOR. It checks the identity pointwise and after Gaussian-rational complex coefficients are summed by Fourier frequency. The output explicitly rejects the unqualified zero-frequency version using a,a,b,b. It uses only the standard Python library, integer XOR and Fraction arithmetic.

## Prior art, mechanism, and stop rule

Möbius/partition-lattice counting is established mathematics. Only the exact application and improved quantitative bound within NIGHTFALL's proposed T2 criterion are research candidates. Lovitz 2018, Lovitz–Petrov 2023 and Wang–Yuan 2026 are the tensor counting predecessors; Blanc–Docter–Strassle–Tan and Liu–Mutreja 2026 are independent-oracle quantum simulation comparators. Neither full operator theorem nor global novelty is certified by this note.

**Remaining decisive work:** independently certify the six grouped noncommuting Hilbert contractions and four zero-triple survivor contractions; formally establish all-frequency tensor primitive bound from published circuit support; identify the physical phase oracle; assemble and kernel-check complete T2 terminal theorem. Keep draft and do not merge as a full quantum theorem.
