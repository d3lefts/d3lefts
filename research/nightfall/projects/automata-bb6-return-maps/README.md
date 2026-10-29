# Five BB(6) cryptids — exact symbolic arithmetic return maps

**Research checkpoint:** October 22, 2026. **Evidence:** machine-specific symbolic reductions from imported pinned transition tables, with internally reported rule-level tests. **Scope:** finite macro semantics, no proof of universal blank-tape nonhalting.

The manuscript `NIGHTFALL_BB6_Five_Cryptids.pdf` derives arithmetic macro transitions for **A.4, A.8, A.9, A.10, and A.11** in the six-state Busy Beaver candidate archive. The original pinned symbolic-transition implementation is an imported source dependency.

- A.4: a two-flag first-return map with sparse dyadic exception values.
- A.8: a complete C-return macro map and constructor lengths.
- A.9: the exact b=0 boundary return.
- A.10: D-to-E elimination followed by explicit E-sweep formulas.
- A.11: C-to-C/H return map, parity-dependent halting bands, and exact symbolic lengths.

The source reports **172,816** comparisons of direct rule replay against macro formula outputs. Longer 10,000-step return traces for two cases ended without halting; such finite runs are explicitly **inconclusive** on infinite nonhalting.

The main purpose is to shrink complicated transition systems into exact, testable recurrence objects. A macro-step is not automatically a physical machine step. Termination and guard partitioning for every macro remain separate proof obligations.

**Original artifacts awaiting mirror:** `NIGHTFALL_BB6_Five_Cryptids.pdf`, `NIGHTFALL_BB6_Five_Cryptids_A9_A10_A11.zip`, `NIGHTFALL_BB6_Phaseshift_III_Reproducibility.zip`.

[Original archive dossier](../expansion-2026-10-28/04-busy-beaver-return-maps.md), section B. Research lead Devin J. Wright; AI-assisted manuscript analysis. No claim of newly solved BB(6) cryptids.
