# NF Frontier Dispatch — proof-bottleneck assignment demo

**Owner:** Devin J. Wright / NIGHTFALL PHASESHIFT. **Prototype date:** 2026-10-29.
**Public route after deployment:** https://d3lefts.github.io/d3lefts/frontier.html
**Classification:** research instrument demo, not a new mathematical discovery.

## Proposition and distinction

Start with **real unresolved or underdocumented mathematical subproblems**, selected by Agent NF from a dated internal evidence ledger. Offer a source-pinned research contract and an explicit choice: investigate, propose an exact resolution, or divide the defined question into smaller **disjoint and exhaustive** branches.

The product distinction from Cairn Commons (https://cairn-commons.com/about) is the *research-dependency engine and NIGHTFALL's exact tools*—a program-specific attempt to identify mathematical bottlenecks and carry them through the Research Desk, Orchestrator, Claim Lab and reproducible checkers. This is not an imitation of Cairn's global marketplace, reputation scoring, crowdsourcing workflow, or blind review model.

## First two real seeded questions

### Sidon #156 / N184 / nine marks
Erdős #156 remains an open asymptotic maximal-Sidon question (https://www.erdosproblems.com/156). OEIS A382397 (https://oeis.org/A382397) reports published finite minima through N183, with N184 unreported as of the frozen snapshot. Axiom PR #55 (https://github.com/d3lefts/d3lefts/pull/55) has a complete fixed-decision SAT encoding; its timed search returned neither YES witness nor UNSAT proof.

**Slice:** Does there exist an inclusion-maximal nine-element Sidon subset of [1,184]?

**YES contract:** nine distinct marks in range, 45 distinct unordered pair sums including diagonal pairs, and no one-point insertion allowed at any of 175 omitted integers. The demo's independent JavaScript arithmetic checker checks all of these in the browser. An independently replayed YES would settle only this finite existence question.

**NO contract:** a complete, independently checked UNSAT proof for a correctly proved equisatisfiable finite encoding, or another complete exact mathematical exclusion. Timeout is inconclusive.

**Division:** split by smallest selected mark, first into [1,92] and [93,184], with recursive integer midpoint splits. Children are disjoint and exhaustive. A positive witness closes its containing branch and the positive existential parent after independent replay; a negative parent requires checked NO for **every** branch.

### Hypercube Erdős #86 / Q7 six-deletion search
Erdős #86 is an open extremal graph question (https://www.erdosproblems.com/86). Project PR #70 (https://github.com/d3lefts/d3lefts/pull/70) reports internally exact five-deletion exclusion over 180 pinned 304-edge Q7 representatives derived from Minamo Minamoto's released catalogue (https://github.com/minamominamoto/c4free-hypercube).

**Slice:** Is an exactly six-deletion, seven-insertion move from one of these 180 specific supplied 304-edge representatives sufficient to produce a 305-edge C4-free graph?

**YES contract:** 305-edge edge list, exact six-deletion lineage, independently reconstructed Q7 with 128 vertices, 448 edges and 672 square cycles.

**NO contract:** complete independently checked exhaustive six-deletion/seven-insertion exclusion for all selected catalogue representatives. Even a negative all-180 result would **not** prove the global bound, since these representatives are not known to exhaust all 304-edge graphs.

**Division:** split by published representative index, initially [0,89] and [90,179], then recursive contiguous halves. A decision for a child transfers to the parent only under the correct existential/universal logic and full certificate coverage.

## Agent NF prioritization v0

The first demo uses a **frozen deterministic editorial scoring rule**, not a live LLM or statistically calibrated probability. Expose all input values; update the frozen snapshot on source supersession.

Score = 3 × decisiveness + 3 × downstream leverage + 2 × evidence readiness + 2 × urgency − 2 × estimated search cost.

The finite-Sidon slice scores **37**, and the Q7 slice scores **28** from explicitly authored 1–5 inputs. Next-stage agent inference must ground each score in current source-typed claim dependencies with versioned snapshots and uncertainty. Never portray the frozen demo rank as a fresh NF model prediction.

## Live workflow and trust gates

1. Inspect source, exact parent, frozen bottleneck, decisiveness and proof contract.
2. Claim in this browser (localStorage only; **no shared lease or unique reservation**). Optionally open a prefilled GitHub issue to request human-coordinated assignment; an issue is not automatically created or assigned by the webpage.
3. Copy the research brief; use Orchestrator for independent lanes, Claim Lab for bounded attempts, and the proper exact verifier for the exact model. The site's general-purpose Referee checks different finite models and **cannot** certify maximal Sidon N184.
4. Submit a positive witness, negative certificate, or documented obstruction as an unreviewed local record with HTTPS evidence. Export JSON or request public GitHub review. A local success label **never** upgrades published scientific claim status.
5. Split into two disjoint exhaustive integer ranges (recursive), with parent-child provenance preserved. Parent remains an open obligation until the appropriate evidence-dependent synthesis.

No server AI, live coordination, automatic remote compute, external reviewer system, exclusive assignment, or machine-certified UNSAT verification exists in version 0. Public GitHub requests require authenticated contributors and human triage. The browser only writes its own namespaced local storage; no owner source data is mutated.

## Reproduce the demo's finite mathematics

Run:

    node --check docs/frontier-core.js
    node --check docs/frontier.js
    node research/nightfall/frontier-dispatch/test.cjs

The checker tests exact score ordering, recursive split coverage, malformed partitions, repeat-sum rejections, protected branch conditions and the known nine-mark Golomb-ruler sample [1,2,6,13,26,28,36,42,45]. It passes as a maximal nine-mark Sidon set at N=45 and correctly **fails** maximality at N=184. This is a negative control, not a new solution to N184. Browser smoke covers mobile/tablet/desktop and a full claim → split → negative witness → unreviewed submission → export → reload sequence.

## Next deployment milestones

To become a true multiuser research system: generate dated Agent NF bottleneck candidates from approved proof dependencies; store authenticated durable claim/work IDs with transactional collision-free leases and expiries; preserve mathematical split-cover proofs; pass proof-carrying work packets between Orchestrator/Claim Lab/Evidence Bridge; run distinct certificate verifiers with external scientific review; measure decisive independently checked outcomes **per reviewer-hour**. Public status changes require owner-approved scientific governance.

The initial demo retains the existing four flagship packages, 33 research dossiers, and three Original Findings unchanged.
