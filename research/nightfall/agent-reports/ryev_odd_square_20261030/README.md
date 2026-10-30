# Ryev #257 — independent odd-square oracle replay and intersecting-code proof graph

**30 October 2026.** Research lead: Devin J. Wright. AI roles: Ryev independent checker/formalizer, Vesper theorem coordinator; PR #256 producer. **Status R1 internal; NOT a worldwide novelty claim, human referee, publication acceptance, or all-k Lean decoder theorem.**

## Objective and frozen oracle

For each finite field K=F_(p²), p∈{3,5,7}, oracle returns (a·x)² for adaptively chosen K-linear coefficient vectors, up to global sign H={±1}. **This is a different model from F16 full-F4* cubing.** The goal is to independently reproduce the full-support, unknown-support, and zero-signal assertions from PR #256 (general k, r candidate) and its later odd-prime transfer experiment. Then formalize the exact logical bridge between fixed square measurement and intersecting linear codes.

## New independent algebra

The producer's F_(p²) implementation uses t²=n. This checker constructs a shifted trace basis u=t+1/2 with u²=u+d, d=n−1/4:
- GF9 p=3, n=2, d=1
- GF25 p=5, n=2, d=3
- GF49 p=7, n=3, d=1

The Python file independently checks every field addition/multiplication under the explicit shift isomorphism (Q² input pairs), all elements' Frobenius property, inverses via the multiplicative group exponent Q−2, the exact ±1 square fibers, and the canonical-root dictionary. No source arithmetic or producer decoding functions are imported.

Run:
\`\`\`
python3 research/nightfall/agent-reports/ryev_odd_square_20261030/verify_trace_basis.py
\`\`\`

The fixed exhaustive tests are GF9 k4: 6,561 vectors, histogram {4:33,5:2432,6:4096}; GF25 k3: 15,625, histogram {3:73,4:15552}; GF49 k3: 117,649, histogram {3:145,4:117504}. Zero, all sparse supports, and strict final one-sign blocks are included.

**Mandatory negative controls:** intentional root-table value lacking the right square is rejected; valid alternate choices of either root are accepted (a valid root flip is a gauge, NOT tampering); non-square readings have no admissible roots; an unpowered sign branch is illegal because two opposite field elements have the same square; replacing the oracle exponent 2 with 3 violates the model. Compare source and the test script SHA-256 with GitHub Actions receipts.

## Lean theorem graph

Path: \`research/nightfall/formalization/odd_square/IntersectingCriterion.lean\` (pinned Lean 4.35.0 via workflow).

- **Source-level strong intersection** prohibits two nonzero input vectors whose measurement codewords have disjoint supports. It is equivalent to **kernel triviality + image-code intersection**, given the explicitly required zero-preserving linear map.
- **Square-orbit separation iff strong intersection** is proved for arbitrary source and target types, arbitrary number of rows, and explicit algebraic premises: squared-output equality has exactly ± roots, sum/difference measurement zero identities, sum/difference zero characterizations, and existence of the inverse polarization map. The last premise requires that 2 be invertible; failure in characteristic 2 is intentionally out of scope.

These are proper all-dimension conditional mathematical theorems, with hypotheses stated as arguments and axiom audits by Lean. **Not yet formalized:** instantiation of every premise for a concrete odd-characteristic field/linear map (without Mathlib); general r-dimensional independent basis digit-packing injection; all-k support/anchor decoder. A pure finite Boolean Lean statement would not fill those gaps. If CI finds a proof flaw, demote the result and fix or archive the failing dependency.

## External baseline, novelty and signoff

Primary fixed-code baseline: Borello, Schmid, Scotti (2025), *The geometry of intersecting codes and applications to additive combinatorics and factorization theory*, JCTA 214, 106023, https://arxiv.org/abs/2406.04034. Their Theorem 3.9 supplies liminf i(k,Q)/k≥2+1/(Q−1), so the inherited F9 coefficient 5/8 uses **their** published bound, subject to the candidate decoder and equivalence proof. Also classical Balan–Casazza–Edidin complement-property obstruction and prior NIGHTFALL sign-packing. Those are not new Ryev discoveries.

The claimed fixed-field unbounded gap in PR #256 is a **candidate synthesis** under the same squared-linear oracle and remains pending a dated same-model priority search and non-author specialist mathematical review. No public site claim, production merge, or external submission authorized.

## Next decisive independent experiment

1. Replay the quantified Lean bridge with the exact field and group laws, not merely abstract arguments.
2. Attempt a Lean basis-packing theorem parameterized by a field-extension basis and a two-digit set closed under the required sign-orbit separation.
3. Ask Lemnis to attack the rank-deficient and char-2 edge cases and Axiom to attack the non-coordinate-first k6 frontier. Stop before needless larger finite searches.
