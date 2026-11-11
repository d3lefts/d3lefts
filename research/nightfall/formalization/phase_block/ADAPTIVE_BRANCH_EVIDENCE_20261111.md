# Archived adaptive F16 proof certificate — source recovery and boundary audit

**Date:** 2026-11-11. **Provenance:** NIGHTFALL Tessera PR 255 (2026-10-30), independent Ryev PR 252 and Lemnis PR 253; original authors and reviewer roles preserved in Git histories. **Status:** CLOSED / UNMERGED research branches. **Publication and worldwide novelty:** NOT CLEARED.

## Source discovery

The active main-branch F16 passport describes the **earlier 2026-10-29** fixed three-row block with 81 distinct four-phase outputs. The dated main-branch source `research/nightfall/projects/adaptive-finite-field-decoder-2026-10-29/F16_THREE_QUERY_PHASE_BLOCK_20261029.md` already explicitly establishes the k=5 eight-query claim using the finite witness and a written all-k transfer. Reconstructing that theorem in a new session is **replication**, not original discovery.

A stronger **2026-10-30** construction remains on an unmerged closed branch. The fixed/oracle model is still K=F16, L=F4, H={1,6,7} and queries (a·x)^3. Do not conflate it with complex phaseless intensity measurements or with power exponents different from three.

- [Original Tessera theorem and explicit six-branch table](https://github.com/d3lefts/d3lefts/blob/6ac911cd74baebb95092793efe1a57ecbe365126/research/nightfall/projects/finite-field/tessera-f16-adaptive-20261030/THEOREM.md)
- [Tessera executable finite audit](https://github.com/d3lefts/d3lefts/blob/6ac911cd74baebb95092793efe1a57ecbe365126/research/nightfall/projects/finite-field/tessera-f16-adaptive-20261030/audit.py)
- [Archived PR 255 passing action 41104093748](https://github.com/d3lefts/d3lefts/actions/runs/41104093748)
- [Ryev branch Lean certificate](https://github.com/d3lefts/d3lefts/blob/d720d8ef4bc91e3d22fcb3bba24e3b73bc2209f7/research/nightfall/formalization/adaptive_f16/AdaptiveBlock.lean)
- [Ryev strict Lean workflow 41110673165](https://github.com/d3lefts/d3lefts/actions/runs/41110673165)
- [Ryev independent quadratic-tower workflow 41110673139](https://github.com/d3lefts/d3lefts/actions/runs/41110673139)
- [Lemnis closed PR 253](https://github.com/d3lefts/d3lefts/pull/253) independently examined all 349,526 projective k=5 classes, but this does not establish external referee independence.

## Exact finite certificate: 27-state adaptive branch

For eta=(eta1,eta2,eta3) in H^3, evaluate first cube y=(1+2 eta1+3 eta2+4 eta3)^3. Choose the second coefficient row **only from this observed y**:

| y | 0 | 1 | 8 | 10 | 12 | 15 |
|---|---|---|---|---|---|---|
| branch row | (0,0,0,1) | (1,0,2,8) | (0,1,4,8) | (0,1,2,4) | (0,1,8,4) | (0,1,2,4) |
| first-fiber states | 1 | 5 | 5 | 6 | 5 | 5 |

The 27 ordered adaptive output transcripts are pairwise distinct. The finite part is represented in **closed PR 252** by `Nightfall.AdaptiveF16.adaptive_twenty_seven_boolean_certificate` and `first_reading_branch_boolean_certificate` in the pinned Lean source. Compilation and a separate strict-axiom check of the two counting inequalities and the conditional all-k phase factorization passed CI. The exact support/anchor/chunking adaptive decoder was **not compiled as one Lean theorem**.

## Mathematically scoped consequences (written proof and exact replay, not Lean all-k)

The archived transfer uses k initial coordinate cubes, an observed anchor, and two branch-dependent mixed queries per full group of three relative phases, plus one query per remaining phase. Its stated cost for s positive-supported coordinates is

`m(k,s) <= k + 2 floor((s-1)/3) + ((s-1) mod 3)`.

At k=4 the worst cost is 6, and at k=7 it is 11. Decision-tree counting yields `6^5=7776 < 21846=1+(16^4-1)/3` and `6^10=60466176 < 89478486=1+(16^7-1)/3`, so these rates are exact **if the archived all-signal transfer proof is accepted**. Archived exact tests enumerate all 65,536 F16^4 signals, 5,461 seven-coordinate support/phase representatives and 12,000 seeded full-amplitude k7 inputs. Another branch independently implements a GF4 tower. These are machine-checkable computational evidence, not a Lean-checked all-k theorem or a peer-reviewed priority certificate.

The archived fixed-row obstruction is **not** an adaptive impossibility theorem. It checks 4,369 canonical first-nonzero-normalized rows, 439 collision masks and exactly four minimal fixed-two-row collision pairs in the three-phase anchored model. This establishes a finite fixed-vs-adaptive separation within the specified input/operator model, conditional on complete audit replay.

## Prior-art boundary

Dated adjacent research includes Charikar–Wu–Ye, *Adaptive Discrete Phase Retrieval*, SOSA 2020 (complex magnitude-squared oracle, NOT the finite cube map; DOI https://doi.org/10.1137/1.9781611976014.9); Ivanyos–Karpinski–Santha–Saxena–Shparlinski, *Polynomial Interpolation and Identity Testing from High Powers Over Finite Fields* (different input/query model; DOI https://doi.org/10.1007/s00453-016-0273-1); Bartusel–Führ–Oussa, *Phase retrieval for affine groups over prime fields* (complex group-frame measurements; https://arxiv.org/abs/2109.07123). Their publicly accessible descriptions do not establish an exact same-oracle predecessor. **This is not an exhaustive global-priority search.**

## Adversarial checker and stop rule

1. Independently rerun both field models, the 27-state table and the exhaustive 4,369-row fixed-mask search against exact branch source SHAs. Recompute the number of signals/classes and explicitly count every conditional second query.
2. Reconstruct all support/anchor normalizations and posterior branch decisions, including y=0, from oracle-visible readings alone. Test failure modes where a branch depends on the unpowered hidden sum.
3. Independently formalize the actual adaptive transcript-to-phase decoder and the finite lower bound in one toolchain. Distinguish formal implication from program-supplied hypotheses.
4. Perform dated same-oracle priority review and obtain non-author mathematical criticism before promotion. **Do not merge the closed PR, publish an Original Finding, or treat an unmerged compiled artifact as part of main's 39 Lean source files without separate owner authorization.**

The original fixed-block passport remains a valid separately scoped result. This document is a **recovered evidence docket**, not a retrospective new discovery.
