# Fresh-layer factorization in one-way planar Busy Beaver machines

**Original research checkpoint:** October 6, 2026. **Status:** unverified theorem candidate; the stated upper bound has an unresolved proof gap. Expert prior-art and edge-case audit pending. **Original PDF:** `Fresh_Layer_Factorization_Busy_Beaver.pdf` (Library, pending GitHub binary mirror).

## The result

A deterministic n-state, m-symbol machine acts on an initially blank half-plane tape Z x N. The head moves Left, Right, or Up; it never descends. Let S_U(n,m) denote its maximum finite halting steps, with S(n,m) the usual one-dimensional step Busy Beaver quantity under an identical halting convention.

The source **proposes** `S(n,m) <= S_U(n,m) <= n*S(n,m)`. The lower inequality follows from embedding ordinary one-dimensional machines as zero-Up machines. **The upper inequality is unproved in this dossier.** Its argument assumes that repeating a row-entry control state forces the subsequent computation to repeat. That implication needs an independent configuration-equivalence proof: row-entry state alone omits head position and the history of previously visited rows. A fresh blank row does not automatically establish the same global configuration. Consequently the claimed limit of `n` row phases and the ensuing `n*S(n,m)` upper bound must be treated as conjectural until a valid invariant or independent proof is supplied.

The separate externally controlled k-climb variant has **S_k(n,m)=(k+1)S(n,m)** because the external controller makes exactly k restarts. That controller expands the computational model; the equality does not apply to the autonomous Up-only machine.

## Why it belongs in the library

This is a **separate automata-model theorem**, distinct from finite-field reconstruction, quantum Werner states, and six-state arithmetic macros. The proposed conclusion is structural, and the missing state-repetition argument is an explicit proof obligation. No upper bound is certified by this note.

## Independent review contract

Verify halting-step conventions, blank-row phase semantics, treatment of repeated states, right/left infinite row support, and possible established one-way two-dimensional machine analogues. No BB(6) blank-tape halting classification follows.

[Recovered technical dossier](../expansion-2026-10-28/04-busy-beaver-return-maps.md), section A. Research lead Devin J. Wright; AI-assisted research, originality pending.
