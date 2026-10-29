# Fresh-layer factorization in one-way planar Busy Beaver machines

**Original research checkpoint:** October 6, 2026. **Status:** mathematical manuscript proof, expert prior-art and edge-case audit pending. **Original PDF:** `Fresh_Layer_Factorization_Busy_Beaver.pdf` (Library, pending GitHub binary mirror).

## The result

A deterministic n-state, m-symbol machine acts on an initially blank half-plane tape Z x N. The head moves Left, Right, or Up; it never descends. Let S_U(n,m) denote its maximum finite halting steps, with S(n,m) the usual one-dimensional step Busy Beaver quantity under an identical halting convention.

The source derives **S(n,m) <= S_U(n,m) <= n*S(n,m)**. After every Up move, the machine enters a fresh blank row. An eventual halting trajectory cannot repeat a row-entry state without reproducing an infinite deterministic state orbit. Hence there are at most n finite row phases. Each phase is simulated by a one-dimensional halting machine with the same state alphabet, producing at most S(n,m) steps per phase. The ordinary one-dimensional class embeds as the zero-Up case, giving the lower inequality.

The separate externally controlled k-climb variant has **S_k(n,m)=(k+1)S(n,m)** because the external controller makes exactly k restarts. That controller expands the computational model; the equality does not apply to the autonomous Up-only machine.

## Why it belongs in the library

This is a **separate automata-model theorem**, distinct from finite-field reconstruction, quantum Werner states, and six-state arithmetic macros. The conclusion is structural, with a transparent proof obligation and a meaningful state-dependence bound.

## Independent review contract

Verify halting-step conventions, blank-row phase semantics, treatment of repeated states, right/left infinite row support, and possible established one-way two-dimensional machine analogues. No BB(6) blank-tape halting classification follows.

[Recovered technical dossier](../expansion-2026-10-28/04-busy-beaver-return-maps.md), section A. Research lead Devin J. Wright; AI-assisted research, originality pending.
