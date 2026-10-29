# Axiom / NIGHTFALL — Sidon repair and prefix-compatible finite bridge

**Checkpoint:** 2026-10-29. **Status:** a self-contained exact finite construction and an internally proved matching-reduction **theorem candidate**, with independent exhaustive finite tests. Neither has an external mathematical referee or a novelty clearance. **No Erdős problem solved; no new record claimed.**

Related assignments: [#46](https://github.com/d3lefts/d3lefts/issues/46), [#49](https://github.com/d3lefts/d3lefts/issues/49). Previous complementary checkpoint: [draft PR #55](https://github.com/d3lefts/d3lefts/pull/55). This branch is intentionally independent of #55 and does not change the public site.

## Dated contract and literature

- [Erdős #156](https://www.erdosproblems.com/156): construct maximal Sidon subsets of [1,N] of size O(N^(1/3)). Ruzsa's published O((N log N)^(1/3)) construction remains the comparison. [OEIS A382397](https://oeis.org/A382397) and [Huber 2026](https://oeis.org/A399118/a399118.pdf) give finite exact data through N=183, with minimum size 9 for N=145..183. #46's prior Axiom pass ruled out a particular fixed-witness one-point lift at N=184 and found a nine-mark near-candidate with two addable points. It did not establish a global lower bound at N=184.
- [Erdős #44](https://www.erdosproblems.com/44): preserve any finite Sidon prefix A and extend to size (1-epsilon)*sqrt(M). [#329](https://www.erdosproblems.com/329) asks whether an infinite Sidon set can have limsup coefficient 1; the catalogued lower coefficient is 1/sqrt(2). Both remain open.
- The stronger perfect-difference-set embedding conjecture [#707](https://www.erdosproblems.com/707) is false (Alexeev–Mixon, PNAS 2026; Hall 1947), and the five-point prefix {1,2,4,8,13} below is their counterexample to **that stronger conjecture**, not to #44. [DOI](https://doi.org/10.1073/pnas.2531760123).
- A targeted 2026-10-29 literature search did not locate a Sidon-specific single-insertion matching theorem. The generic minimum-edge-cover/matching identity is classical; **novelty is not established**.

**Objective:** find an exact operator for repairing arbitrary Sidon sets after prescribed insertions, then test whether it transfers to dense integer blocks. **Feasible set:** Sidon D in an abelian group, a outside D; for the finite bridge, integers and a frozen prefix. **Significance gate:** an externally checked new general theorem, a provable asymptotic improvement, or a genuinely new finite extremal record with dated priority review. The finite bridge below meets none of those gates. **Verifier:** direct unordered pair-sum enumeration, including diagonals, torsion cases, independent regeneration and SHA-256; never trust solver status. **Budget/stop:** after three stalled #156 operator families, switch; use a bounded finite bridge scan and stop without an asymptotic lemma.

## Proof candidate: prescribed single-point Sidon repair reduces to matching

Let D be a finite Sidon set in an abelian group G, and let a not belong to D. For each z in D for which a+z=x+y with x,y in D, form the support C_z={x,y,z}; the unordered pair {x,y} is unique by Sidon. Remove duplicate supports, if any. If 2a=x+y for x,y in D, form one additional exceptional support P={x,y}. This P is unique if present.

**Collision lemma.** A deletion set R subset D makes (D\R) union {a} Sidon **if and only if** R meets every C_z and also P when present. Indeed, the only new repeated unordered sums are a+z=x+y and 2a=x+y. All sums within D were unique.

**Degree-two lemma.** Each t in D belongs to at most two distinct C_z. It appears as the distinguished z in at most one; as one of x,y, the equation y-z=a-t (nonzero) has at most one ordered solution (y,z) in D^2 by uniqueness of nonzero differences in a Sidon set. The two roles may occur in the same support, so the degree can be smaller. This also handles 3-torsion duplicate supports.

**Matching reduction.** Regard the m distinct C_z as vertices of an auxiliary graph. Every element t in D incident to two supports gives an edge between those vertices; an element incident to one gives a singleton-cover option. Deleting t covers exactly its incident vertices. The minimum number of deletions hitting all C_z is the classical edge-cover number

\[
m-\nu,
\]

where \(\nu\) is the maximum matching size among two-vertex edges. If P is absent, this is the answer. If P is present, force one element t of P to be deleted; discard all C_z already hit by t and compute the residual m_t and matching number nu_t. The exact answer is

\[
1+\min_{t\in P}(m_t-\nu_t).
\]

This is an **internally checked proof candidate**, not a novelty-certified theorem. The reduction admits O(|D|^3) time using standard general-graph maximum matching (after O(|D|^2) pair-sum preprocessing). The provided finite reference implementation instead uses exponential bitmask matching DP to keep its bounded test auditable without dependencies.

**Adversarial controls:** omitting P gives the wrong answer for D={0,1,3,9} in Z/13Z and a=7 (triple-only answer 1; true answer 2). Even-order groups can have 2a=2x for a!=x; the checker includes Z/4Z, D={0,1}, a=2. Modulus 21 contains duplicate C_z supports from 3-torsion, which are deduplicated before matching.

**Independent finite audit:** all Sidon D subset Z/vZ for 3<=v<=15 and |D|<=6, all a outside D: **20,668** repair instances. Builder derives the matching formula; the separate checker enumerates all removal subsets and directly tests unordered sums. All 20,668 costs agree. Canonical rows SHA-256: `c71436b535140658623893cd3e7be752e1508b33a084f2d738d92c1fc530c92c`. This does not replace a proof audit.

## Exact finite bridge for a forbidden perfect-difference-set prefix

Fix A={1,2,4,8,13}. Construct the Bose–Chowla Sidon set of size 1009 modulo 1009^2-1=1,018,080 using F_1009[u]/(u^2-11), primitive theta=7+u. Its exponents e satisfying theta^e=theta+t for t in F_1009 form the block S. Take B={776795+s : s in S} and delete the **44** sorted-index positions in `sidon_prefix_bridge_certificate.json`.

The resulting **integer** Sidon set A union B' has:
- |A|=5; |B'|=965; |A union B'|=**970**.
- Maximum element M=**1,794,316**.
- Exactly **470,935** distinct unordered pair sums, including diagonal pairs (970*971/2).
- Exact positive arithmetic check: **2*965^2-M=68,134**. Thus the new block alone has finite ratio 965/sqrt(M) = approximately **0.7204068745**, above 1/sqrt(2) approximately 0.7071067812.

The 44 deletions came from a finite hitting-set MILP exploration of 401 candidate translation fractions; the **certificate does not claim exact MILP optimality**. The independent verifier regenerates the field via a different matrix recurrence, checks irreducibility and primitivity, checks the full original modular Sidon block, and checks all 470,935 final integer sums. It does not import the builder or trust the optimizer.

**Interpretation:** a finite, prefix-compatible transfer demonstration. A finite ratio above 1/sqrt(2) is **not** an asymptotic improvement, and the set is not asserted extremal. It does not settle #44, #329, or #707. The specific prefix is already known not to embed in a perfect difference set; the constructed set is not a perfect difference set.

## Reproduce (Python 3 standard library)

```sh
python3 sidon_repair_matching.py > /tmp/sidon_repair_matching_certificate.json
python3 verify_sidon_repair.py sidon_repair_matching_certificate.json
python3 sidon_prefix_bridge_builder.py > /tmp/sidon_prefix_bridge_certificate.json
python3 verify_sidon_prefix_bridge.py sidon_prefix_bridge_certificate.json
sha256sum *_certificate.json
```

The builders' deterministic output files match the committed JSON. Independent verifier code does not import builder modules. File SHA-256 values from the 2026-10-29 local replay:

| File | SHA-256 |
| --- | --- |
| `sidon_repair_matching.py` | `b0c8619f032fa45dbf0fa31c3bca3a2f0b4427307f07634a391f9535ce2cc53d` |
| `verify_sidon_repair.py` | `e74818307d4f68171cd47fb8f9dda7fb51f05999c73ceab4b4b877b552e2899a` |
| `sidon_repair_matching_certificate.json` | `94721042dcd07511ddda586da070b17b3becac894c1e8145292db268c244065d` |
| `sidon_prefix_bridge_builder.py` | `8ed36db8a42c50a3a899d2d36478e28b8275d87272892693aa7b4c8fcf0074df` |
| `verify_sidon_prefix_bridge.py` | `940b0752dfdd5f37dc0a991659a3d576fff9b3a2eebb1ea5dacdbec396c57a36` |
| `sidon_prefix_bridge_certificate.json` | `d0ed5a364f9c3c907cab259349620eab5cb8a1e624481c0e515684c6a6b08097` |

## Operator registry, failures and handoff

1. **Singer direct puncturing:** prior #49 proof candidate forces Omega(k) deletions in a fixed cyclic perfect difference set. **Status:** rejected as an o(k)-repair mechanism.
2. **Sidon single-point repair as a degree-two hypergraph:** replaces brute-force 2^k deletions by a matching problem. **Status:** internally proved, independently finite-tested; novelty and non-author proof review pending.
3. **Bose–Chowla boundary translation plus exact collision hitting:** produces the certified finite 970-mark prefix-compatible example. **Status:** finite construction only; asymptotic mechanism unproved.
4. **#156 9-mark saturation:** previous #46 operators (fixed-witness lift, stochastic local moves, exact 2/3-coordinate neighborhoods) stalled at two addable points. This pass did not obtain a better certified N=184 construction. **Status:** stop local polishing, reopen only with a genuinely different exact SAT or algebraic operator.

**Next cheapest decisive experiment:** establish or falsify a **uniform boundary-triple estimate** for translated near-optimal Bose–Chowla blocks. For fixed prefix size r, a bound of the form O(r*delta^2*|S|)+o(|S|) on the necessary deletion count at translation (1-delta)*L would imply a *prefix-dependent* improvement over 1/sqrt(2) for sufficiently small delta. The finite data do not establish this estimate, and even such a prefix-dependent gain would not automatically solve #329. Require an analytic bound, held-out primes, and an independent proof attack before any theorem claim.

**End state:** best certified output is the finite 970-mark construction; the matching formula remains a proof candidate; #156 unchanged. No homepage promotion or external record submission.
