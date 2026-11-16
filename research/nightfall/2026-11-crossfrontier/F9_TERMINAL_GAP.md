# F9 asymptotic separation: terminal proof ledger (2026-11-16)

## Model

Fixed field K=F9; oracle returns (a·x)^2 with a K-linear form; all support patterns including zero; reconstruction modulo one global sign, *same oracle* for adaptive and fixed designs. Write A(k) for minimal adaptive worst-case reads and F(k) for minimal fixed nonadaptive reads.

## Mathematical theorem and dependencies

1. Fixed-design obstruction: F(k)≥2k−1 for k≥2. Classical complement property; the repository THEOREM.md supplies a source-specific algebraic derivation.
2. Explicit all-length F9 decoder: A(k)≤k+ceil((k−1)/2) (k coordinate squares, then extension-degree sign packing). The repository THEOREM.md supplies an algebraic construction and independently checked finite regressions.
3. Direct algebra: F(k)−A(k)≥floor((k−1)/2), hence unbounded. **New `F9GapArithmetic.lean` proves this precise implication for all k with kernel-checked natural arithmetic, conditional on (1) and (2).**
4. Stronger imported rate: nonadaptive square retrieval is equivalent to the minimum length i(k,9) of a linear intersecting code. Borello–Schmid–Scotti 2025 establish liminf i(k,9)/k≥17/8. Then liminf (F(k)−A(k))/k≥5/8. This imported asymptotic theorem is *not* yet ported into Lean.

## Scope of current compiler claim

A pinned Lean compile and strict named-declaration audit of the new source, if successful, establishes **arithmetic implication and unboundedness given the sharp oracle bounds**. It does NOT certify the entire theorem until the actual F9 field arithmetic, full adaptive algorithm correctness for arbitrary k, nonadaptive complement obstruction and published intersecting-code liminf are each transitive kernel dependencies. No `axiom`, `sorry` or hidden oracle fact may be used to bypass that obligation.

## Independent audit design (set before any later terminal completion)

Implement F9 once via F3[t]/(t²+1) and independently via 3×3 lookup tables. Exhaust k≤3 for all signals and fixed matrices, attack zero support and signed equivalence. Then require the full arbitrary-k Lean algebra and a proof of code equivalence. The published asymptotic coding result may be formalized or explicitly cited only in the non-Lean paper; it cannot be silently treated as kernel proven.

## Next decisive source proof

Port the characteristic-three basis-cancellation decoder correctness into Lean using a concrete F9 field model and a Fin k block partition; prove every output uniquely determines each block's relative signs. Next port the complement property and the k→∞ coding bound. Do not promote a terminal claim until the pin's direct full source gate passes.
