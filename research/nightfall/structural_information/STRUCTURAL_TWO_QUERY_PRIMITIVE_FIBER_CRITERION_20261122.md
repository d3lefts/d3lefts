# Structural two-query simulation criterion from primitive XOR fibers
Version 1.0 — 2026-11-22
**Paper-level theorem candidate, independently reconstructed algebra; NOT complete Lean certification or globally cleared originality.**

This separates the reusable quantum-information operator from tensor-specific counting. Sources: archived #1016, scoped audit #1029, and new six-site method #1059. No tensor hypothesis is needed for this statement.

## The proposed general theorem

Let V be any finite-dimensional vector space over F₂ and R⊂V\{0} a finite row family; D=R∪{0}. A uniform hidden s∈V* supplies each original-row oracle answer (-1)^(a·s). Define

    M(R) := max(1, max_{z≠0} #{(a,b)∈D²:a+b=z}).

Let B(R) be max(1, max_{z≠0} of the number of **ordered quadruples** (a,b,c,d)∈D⁴ whose total XOR is z and whose nonzero labels are all distinct and have no nonempty zero-XOR subcollection).

For EVERY finite-dimensional two-query quantum circuit using this oracle, with any complex ancillary workspace and arbitrary terminal effect 0≤P≤I (no rank or trace condition), define its acceptance probability f(s). The paper proof in [TENSOR_T2_RANK_FREE_OPERATOR_PAPER_AUDIT_20261122.md](TENSOR_T2_RANK_FREE_OPERATOR_PAPER_AUDIT_20261122.md) gives a deterministic **nonadaptive original-row** estimator g(s)∈[0,1] satisfying

    Pr_{s uniform}(|f(s)-g(s)|>ε) ≤ δ

using at most

    min{|R|, ceil[2(2sqrt(B(R))+145sqrt(M(R)))²/(ε²δ)]}

original row queries, for all 0<ε,δ<1. Preprocessing and classical evaluation cost are unrestricted, and the output approximates acceptance probability, not full quantum states.

**Mechanism:** write the four-slot quantum path Fourier expansion; select first- and second-query sector labels with mass at least η; bound ungrouped light-slot coefficient energy by the rank-free Hilbert frame inequality; partition all nonzero frequency terms into primitive tuples (at most B lifts), six repeated-label equality events (bounded by M) and four unique zero-triple survivor groups (bounded by M). Conditional expectation on the selected original-row parities preserves exactly their span's frequencies. Details and constants are given in the linked operator audit. This is an all-R theorem candidate, not merely a tensor-specific statement.

**Why this is not a tautology:** B(R) and M(R) are source-combinatorial quantities defined before seeing the quantum circuit, and do not use optimal classical decision trees or quantum acceptance functions as part of their definitions. The bound is a general *operator-to-certificate* sufficient condition. It need not be sharp or necessary.

## Corollary A — binary tensor rows (paper-level)

For R_L consisting of 3^L distinct rank-one F₂² factor tensors, published Lovitz–Petrov Corollary 21 combined with the symmetric-difference circuit partition gives

    B(R_L) ≤ B_{4,L}=(1+4*3^6)^4 Σ_{j≤min(6,L)} C(L,j);
    M(R_L) ≤ B_{2,L}=(1+2*3²)^2 Σ_{j≤min(2,L)} C(L,j).

Therefore the *general criterion*, if fully certified, yields O(L^6/(ε²δ)) **row-query** classical simulation for arbitrary two-query circuits, without assuming the sharper unverified cubic primitive count or the exact pair-spectrum theorem. The stronger M=2L+2, separately supported in #1029, is optional and not a correctness dependency.

## Corollary B — binary row families with no short circuits

Suppose R has **no nonempty subset of distinct rows of size at most eight with XOR zero**. Any two primitive subsets of size≤4 representing the same nonzero z must coincide: their nonempty symmetric difference would be a forbidden zero-sum set of size≤8. An unordered set of r nonzero rows (1≤r≤4) has 4!/(4−r)! ordered four-slot placements with other slots zero, at most 24, so B(R)≤24. Similarly, nonzero ordered pair XOR fibers have multiplicity at most two: two distinct unordered pairs would give a zero relation of length≤4, and an additional zero-label pair can coexist with a nonzero pair only if a forbidden zero triple exists. Thus M(R)≤2 and the criterion yields

    Q_class ≤ min{|R|,
      ceil[2(2sqrt(24)+145sqrt(2))²/(ε²δ)]}.

This query count is independent of the size of R, but no polynomial classical *running time* is claimed. IMPORTANT PRIOR ART: high-girth row systems induce 8-wise independent answer distributions, and general bounded-degree polynomial/quantum-query simulation under independent coordinates is established external literature (e.g. Blanc–Docter–Strassle–Tan, FOCS 2026). This corollary is a consistency check/transfer of the proposed primitive-fiber criterion, not an assertion of a new independent quantum simulation breakthrough.

## Proof dependencies, priority and certificate status

1. General Fourier expansion from a standard binary response oracle to the phase oracle with the combined nonphase (+1) sector at label 0. Workspaces are finite complex Hilbert spaces.
2. The unrestricted *matrix-frame repeated-label and unique-zero-triple energy inequalities* in the companion author-side paper audit. These require human non-author adversarial reproduction and eventual Lean formalization; exact finite rational tests are not proofs.
3. The primitive all-frequency tensor bound uses *published* Lovitz–Petrov circuit support and small active-mode exchange precedent Wang–Yuan (Oct 2026); credit both. The source-isomorphic finite Lean certificate for one eight-row circuit and the conditional all-k support sum do not formally establish the general published theorem in Mathlib.
4. General fixed-round uniform-oracle simulation already exists (Blanc–Docter–Strassle–Tan; Liu–Mutreja, 2026). The tensor distribution is supported on a tiny linear code of density 2^(2^L−3^L), so those generic ambient-uniform results do not immediately give the same structured promise theorem; priority remains open.
5. Novelty threshold: specialist search must locate any prior theorem parameterized by primitive four-term Fourier fibers/M(R), or a uniform-source theorem that covers the correlated code without exponentially bad conditioning. A dated negative search is not a uniqueness proof.

**Status:** **paper-level full proof candidate and useful general operator criterion**. No worldwide discovery or theorem promotion until the quantum inequalities, exact source model, Lean kernel terminal and non-author paper/priority review all pass. Preserve counterexamples if found.
