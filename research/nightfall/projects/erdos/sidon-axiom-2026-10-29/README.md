# Axiom / NIGHTFALL — Erdős #156 and #44/#329 checkpoint (2026-10-29)

**Status:** independently reproduced finite observations; an elementary cyclic deletion-barrier proof candidate; **no new solution, verified novelty, or record**. Research issues: [#46](https://github.com/d3lefts/d3lefts/issues/46) and [#49](https://github.com/d3lefts/d3lefts/issues/49).

## Baseline and corrections

- [Erdős #156](https://www.erdosproblems.com/156): Ruzsa's published upper construction is O((N log N)^(1/3)); O(N^(1/3)) remains open.
- [OEIS A382397](https://oeis.org/A382397) is exact through N=183. **Correction:** the minimum cardinality is **9** for N=145..183, not 8. [Huber (2026)](https://oeis.org/A399118/a399118.pdf) proves the last interval admitting a saturated 8-mark set is N=144.
- [Erdős #44](https://www.erdosproblems.com/44) and [#329](https://www.erdosproblems.com/329) remain open; #329's recorded coefficient range is 1/sqrt(2) to 1.
- The stronger universal embedding into a perfect difference set (Erdős #707) is **false**: Alexeev–Mixon (2026), [arXiv:2510.19804](https://arxiv.org/abs/2510.19804), give a size-five counterexample and recover Hall's earlier example. This does **not** disprove #44.

## Contract and audit

For #156, optimize |A| with A subset [1,N], all unordered pair sums distinct, and every excluded point uninsertable. For #44, preserve an arbitrary fixed finite prefix exactly while approaching (1-epsilon)*sqrt(M); modular density alone does not qualify. Claims need an independently executable exact checker, full source, SHA-256, and dated novelty check. Stop local tuning after three stalled operator families.

Two intentionally separate verification paths are provided: #156 construction uses distinct positive differences and blocker geometry; independent verification enumerates all unordered sums for each insertion. The cyclic Singer builder enumerates triples and deletion masks; its verifier recomputes all ordered triples and all unordered sums for every possible deletion size. Cyclic and integer Sidon properties are **not conflated**.

## #156: negative one-mark lift

Huber's one-based saturated eight-mark witness is H={8,48,68,69,71,75,104,120} for N=144. For N=184, among all 40 ninth marks x in [145,184], **24** preserve the Sidon property; none saturates the interval. The best such fixed-witness lift is x=152, with **10** remaining addable points. This is an exhaustive statement **only about that one fixed eight-mark witness**.

A distinct nine-mark near-candidate A={49,50,56,78,93,104,125,139,149} has exactly two addable points, {16,166}, in [1,184]. It is **not** maximal. Stochastic 1–3-coordinate moves and exact 2/3-coordinate neighborhoods produced no certified nine-mark maximal witness. This does not prove nonexistence.

- Certificate: [sidon_156_probe_certificate.json](sidon_156_probe_certificate.json).
- SHA-256: 59323e83f910f83c8b67602c75111c925125cadbc49c027f4981638ddc73fb62.

## #44: cyclic perfect-difference-set repair barrier

**Proof candidate; external referee and novelty review pending.** Let D be a cyclic (v,k,1) perfect difference set with v=k(k-1)+1. For a outside D, if R is a subset of D and (D minus R) union {a} is Sidon **in Z/vZ**, then |R| >= ceil(k/4).

Proof: the group-ring identity D D^(-1) = (k-1)[0] + G gives D D D^(-1) = (k-1)D + kG. Hence there are exactly k ordered triples (x,y,z) in D^3 satisfying x+y-z=a. Every triple must be destroyed by a deletion. Fix t in D. It appears as x exactly once, and as y exactly once, by unique nonzero differences; it appears as z at most twice, by uniqueness of unordered pair sums. Thus a deletion destroys at most four ordered triples, forcing 4|R| >= k.

This **falsifies only o(k)-deletion repair of a fixed cyclic Singer block**. It does not disprove #44, preclude changing the construction, or imply an integer-interval deletion barrier. The group-ring identity is classical; the derived estimate is **not claimed novel**.

Exhaustive exact examples for cyclic moduli v=7,13,21,31,57,73,91, with k=3,4,5,6,8,9,10, give minimum/maximum deletions across all outside points respectively 1–2, 2–2, 2–3, 2–3, 2–3, 3–5, 3–4. All deletion subsets were enumerated independently.

- Certificate: [singer_barrier_certificate.json](singer_barrier_certificate.json).
- SHA-256: 16ca20a3e1bd307cd1de8f7c8eda6e0c1ddfa21472e3a80da4ce971697523bee.

## Reproduce and handoff

Run from this directory:

    python3 sidon_156_probe.py > /tmp/sidon_156_probe_certificate.json
    python3 verify_sidon_156.py sidon_156_probe_certificate.json
    python3 singer_barrier_builder.py > /tmp/singer_barrier_certificate.json
    python3 verify_singer_barrier.py singer_barrier_certificate.json
    sha256sum *_certificate.json
    g++ -O3 -std=c++17 sidon_search_anneal.cpp -o /tmp/sidon_anneal
    /tmp/sidon_anneal 184 100 250000

Builder outputs should match the committed certificate hashes; stochastic search may depend on C++ standard-library RNG distribution details. **The verifier checks certificates, not the search trajectory.**

**Operator registry:** (1) fixed-witness lift — rejected at N=184; (2) stochastic Sidon-preserving local moves — stalled at two addable points; (3) exact 2/3-coordinate neighborhoods — stalled; (4) cyclic Singer puncturing — linear deletion barrier. No gain relative to external records.

**Next cheapest decisive experiment:** encode the N=184,k=9 decision as a full SAT/CP-SAT search with exact saturation clauses, with a second independent pair-sum checker. For #44, abandon direct Singer puncturing and investigate noncyclic prefix-compatible lifts with explicit separation of A+A, A+B, B+B and asymptotic density accounting. Reserve exploration budget for genuinely different representations. Publish to the website only after a quantitative advance and a separate novelty audit.
