# Dossier 04 — Fresh-layer Busy Beaver and BB(6) arithmetic return maps

**Source dates:** 2026-10-06 and 2026-10-22. **Status:** mathematical proof manuscripts, with independently reported finite rule-replay tests. **No new BB(6) nonhalting classification.**

## A. One-way two-dimensional fresh-layer theorem

A deterministic \(n\)-state, \(m\)-symbol machine starts on an initially blank \(\mathbb Z\times\mathbb N\) tape and moves Left, Right, or Up, with no Down moves. Define \(S_U(n,m)\) as the largest halting step count in this model and \(S(n,m)\) as the usual one-dimensional step Busy Beaver function, using the same halting-step convention.

The source manuscript proves
\[
 S(n,m)\le S_U(n,m)\le nS(n,m).
\]
**Proof:** every upward move lands on a fresh blank row. The phase from row entry through the first Up or halt is determined entirely by the entry state. A halting trajectory cannot revisit an entry state: determinism would repeat its phase orbit forever. Hence there are at most \(n\) phases. Replace the final Up move of each phase by a halting move and relabel the phase's entry state as the one-dimensional start state. The resulting halting one-dimensional machine reproduces the phase's step count, which is at most \(S(n,m)\). Sum the at-most-\(n\) phases.

An **externally controlled** variant redirects the first \(k\) halt events into fresh blank rows, with the \((k+1)\)st halt final; its exact maximum step count is
\[
S_{k\text{-climb}}(n,m)=(k+1)S(n,m).
\]
The external controller supplies additional state. This equality must not be confused with the ordinary autonomous Up-only class.

Primary manuscript: \`Fresh_Layer_Factorization_Busy_Beaver.pdf\`. A related abstraction appears in \`Directed_Causal_Cuts_Complex_Flowtime.pdf\`.

## B. Five six-state cryptids: compressed arithmetic return maps

The manuscript \`NIGHTFALL_BB6_Five_Cryptids.pdf\` derives return-map formulas from pinned upstream symbolic transition rules for machines labeled **A.4, A.8, A.9, A.10 and A.11**. A.4 gets a two-flag first-return map and sparse dyadic exceptional values; A.8 a complete \(C\)-return map with constructor lengths; A.9 a closed boundary return on \(b=0\); A.10 a \(D\to E\) elimination plus \(E\)-sweep formula; A.11 a \(C\to C/H\) map with parity-dependent halting bands and exact symbolic lengths.

The source reports **172,816** rule-by-rule versus closed-form agreement tests; additional 10,000-step return prefixes for two systems did not halt. These are exact symbolic reductions based on upstream rules, not proofs of blank-tape nonhalting. A symbolic step is not automatically a raw machine step. The original authors' published Lean TM-to-pattern connection remains an imported dependency.

## Verification and novelty gates

1. Audit the exact definition of halting-step count in each machine model; investigate the fresh-layer proof's boundary cases.
2. Replay A.4/A.8/A.9/A.10/A.11 rules from the original pinned Lean source independently, then compare cases and length expressions.
3. Verify every integer guard is exhaustive, disjoint, terminating within a macro transition, and correct at zero-coordinate boundaries.
4. Obtain external originality review against prior one-way planar automata and return-map literature.

**Source artifacts awaiting binary mirror:** \`Fresh_Layer_Factorization_Busy_Beaver.pdf\`; \`NIGHTFALL_BB6_Five_Cryptids.pdf\`; \`NIGHTFALL_BB6_Five_Cryptids_A9_A10_A11.zip\`; \`NIGHTFALL_BB6_Phaseshift_III_Reproducibility.zip\`.
