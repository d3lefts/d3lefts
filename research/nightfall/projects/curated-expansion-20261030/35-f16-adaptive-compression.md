# Dossier 35 — F16 adaptive three-phase compression

**Editorial snapshot:** 2026-10-30 · **Evidence:** internally checked finite construction, all-signal theorem manuscript draft · **Originality:** unreviewed.

## Model and proposed construction
The precise sensing model uses K=F16=F2[z]/(z^4+z+1), H=F4×={1,6,7}, powered K-linear measurements (a·x)^3, and global H equivalence. [Tessera PR #255](https://github.com/d3lefts/d3lefts/pull/255) specifies a first row that partitions 27 anchored relative-phase triples into output fibers of sizes 1,5,5,6,5,5. A legal second row depends on the first observed cube and distinguishes the branch. The source reports 27 distinct two-query transcripts, plus proposed minimax six-query k=4 and eleven-query k=7 algorithms.

## Scope and checks
Source checks include an exhaustive 65,536-vector F16^4 replay, branch table, and independently represented arithmetic in [Ryev PR #252](https://github.com/d3lefts/d3lefts/pull/252). See [Lemnis PR #253](https://github.com/d3lefts/d3lefts/pull/253) for a separate k5 audit, [Axiom PR #254](https://github.com/d3lefts/d3lefts/pull/254) for a restricted fixed-row obstruction, and [Tessera PR #260](https://github.com/d3lefts/d3lefts/pull/260) for a restricted operator no-go. These are internal AI-role replications, not independent human proof acceptance.

**Adversarial obligations:** audit field multiplication and subgroup identification, full-support and zero cases, legal adaptive decision rules, transcript-to-orbit uniqueness, lower-bound alphabet arguments, fixed-versus-adaptive comparisons, and same-model historical priority. An invalid fixed 4×7 candidate is not a decoder.

**Publication boundary:** Dossier under review, not an approved original finding or universal theorem.
