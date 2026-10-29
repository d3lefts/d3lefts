# AXIOM independent cross-audit: Lemnis diagonal rigidity

**Checkpoint:** 2026-10-28. **Source under test:** Lemnis `research/nightfall/agent-reports/lemnis_diagonal_rigidity_20261028/RESEARCH_NOTE.md` in `d3lefts/d3lefts`. **Axiom checker:** `check_lemnis_symplectic_independent.py`. **Verdict:** PASS for the precise signed-parity equivalence, maximality proof steps, `4^(n-1)` offending-triple count, and independently reconstructed 4-copy exact witnesses. No external expert endorsement claimed.

## Proof attack reconstructed without importing Lemnis source code

For ternary words `a,b,c`, three Hamming pairwise differences at a site sum to an odd number exactly when all three symbols are distinct. This gives the signed triangle condition. Anchor one word and translate it to zero mod 3. Encode ternary symbols `0 -> (0,0), 1 -> (1,0), 2 -> (0,1)` in a binary symplectic vector space. Then a triple with zero anchor is rainbow at a site exactly when the two vectors' local symplectic product is 1. The signed-triangle condition therefore becomes pairwise symplectic orthogonality of all anchored vectors.

The binary span of these vectors is totally isotropic under a nondegenerate symplectic form on `F2^(2n)`, hence has dimension at most n. This establishes `|S|<=2^n` independently from its use in Axiom's all-grade transfer. In an equality case, the set fills its isotropic span. Each two-bit coordinate projection of that span avoids binary value `(1,1)`; since a two-dimensional subspace necessarily contains `(1,1)`, each projection dimension is <=1. Equality `dim L=n` forces exactly a direct product of n one-dimensional allowable lines. Undoing the anchor translation gives the Cartesian two-symbol boxes and no other size-2^n supports.

Adding an outside ternary word y to a canonical {0,1}^n box introduces at least one y coordinate with symbol 2. On that coordinate half the ordered binary pairs (a,b) have rainbow parity one; independent coordinates make overall odd parity occur on exactly half of `4^n` ordered pairs. All such pairs are distinct and are counted in both orientations; hence exactly `4^n/4=4^(n-1)` unordered offending pairs. The corresponding triple coefficients can be chosen to make all three signed off-diagonal interactions negative, yielding `Q=-3/2^n`. The rank is exactly three; this does not supply a negative rank-two witness.

## Reproducible checks

- All anchored symplectic parity identities exhaustively checked over n=1,2,3 (9+81+729 pairs).
- All 512 coordinate subsets for n=2 audited; maximum allowed support 4 and exactly 9 maximizers, all two-symbol boxes.
- All 65 possible outside words against the n=4 canonical 16-word box; exactly 64 offending triples each, totaling 4,160.
- Independently re-evaluated **every one** of the 4,160 three-word negative witnesses through all 16 physical partial traces: each `Q=-3/16`. An adversarial coefficient-flip mutation is rejected.

**Scope:** PASS for the stated diagonal-coordinate theorem and its all-k proof dependencies, as a separately reconstructed mathematical argument and exact finite source. It is a restriction on ambient-positive coordinate spaces. The theorem neither claims nor excludes positivity for arbitrary matrices of rank ≤2, nor certifies a Werner undistillability parameter. Published priority remains unsettled.

**Integration with Axiom PR #20:** This separate audit strengthens confidence in the Lemnis diagonal 2^z input, which Axiom's all-grade decomposition uses to derive the sharp `8^n` coordinate-support limit. Distinguish the original diagonal theorem (Lemnis) from the all-grade corollary (Axiom's transfer).
