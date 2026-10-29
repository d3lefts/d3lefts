# NIGHTFALL | CONSTELLATION — Cross-agent mechanism synthesis, 29 October 2026

**Status:** proposed **Mechanism Atlas transfer ledger**, grounded in linked NIGHTFALL drafts and executed exact cross-domain checks. **No new Original Finding, theorem novelty, publication, flagship, or archival release.** Review-only site draft; the research owner's approval remains separate.

## Executive finding

The strongest synthesis from Axiom, Lemnis, Ryev, Tessara, Tessera and Vesper is **not** a single new theorem that solves several open problems. It is a reusable, falsifiable *obstruction → certificate → transfer-limit* discipline. Two links yield mathematically exact common representations; a third is a same-model sequence of proofs and obstructions; other links remain analogies or unsolved scale transfers.

**Proposed site home:** an editorial “Tested transfers / 29 October” chapter **inside the existing Mechanism Atlas**, not a new research tool, dashboard, Original Finding, or homepage hero. The Atlas already has typed relationships, Proof Passports, and provenance.

## Transfer T1 — exact cross-domain conflict-hypergraph reduction (new NIGHTFALL implementation, classical mathematical theorem)

Let H=(V,E) be any finite hypergraph of minimal forbidden subsets. A subset A⊆V is independent iff no E∈E is contained in A; it is inclusion-maximal independent iff independent and, for every v∉A, some E∈E contains v with E\{v}⊆A. This is an elementary general equivalence, **not a novel research theorem**.

- **Integer Sidon #156:** V={1,…,N}. E consists of the *set supports* of distinct unordered pairs (a,b),(c,d), with a≤b,c≤d and a+b=c+d. Diagonal pairs are included. Independent sets are exactly Sidon sets; maximal independent sets are exactly inclusion-maximal Sidon sets. The target at N=184 is the **minimum size of a maximal independent set**, with the 9-mark case undecided in [#46](https://github.com/d3lefts/d3lefts/issues/46) and draft [PR #55](https://github.com/d3lefts/d3lefts/pull/55).
- **Hypercube #86:** V is the set of **448 edges** of Q7. E comprises the **672 coordinate squares**, each specified by its four boundary edges. Every four-cycle in a cube is such a square. Independent sets are exactly C4-free Q7 edge subsets. Ryev [PR #120](https://github.com/d3lefts/d3lefts/pull/120) and the stronger parity-syndrome necessary condition [PR #148](https://github.com/d3lefts/d3lefts/pull/148) attack a maximum-cardinality instance; **304 ≤ ex(Q7,C4) ≤ 308 remains open**.
- **Meaningful transfer:** both domains accept the *same exact certificate grammar*: universe, minimal forbidden hyperedges, a proposed subset, independent-set violations, and optional explicit blockers proving maximality. This allows **separate, source-specific constructors and direct checkers**, and a shared high-level test contract.
- **Non-transfer:** optimizing the *minimum maximal* cardinality is different from *maximum independent* cardinality; a maximal set can be non-maximum. No cardinality bound transfers from the Sidon hypergraph to the cube hypergraph solely through this representation.

### Executed falsification contract

The separate standard-library implementation `research/nightfall/constellation/verify_cross_domain.py` generates Sidon conflicts from unordered equal sums and cube conflicts from coordinate squares. It compares them **against separate direct arithmetic / direct four-cycle detection**, including diagonals, maximality and deliberate corrupted supports. Internally completed:
- All **4,094** subsets for every integer N=1,…,11 (independence and saturation).
- All **4,096** edge subsets of Q3 (C4 avoidance and inclusion maximality); Q3 has **maximal C4-free sets of both sizes 8 and 9**, a direct falsifier of “maximal means maximum.”
- 200 seeded Q4 subset checks; Q4 has 32 edges and 24 squares.
- Two distinct exact Q7 indexing formulas agree on **448 edges and 672 squares**.
- Frozen execution receipt: [EXACT_REPLAY.json](constellation/EXACT_REPLAY.json); independent script SHA-256 `e13baea549bbfcd7417892045d042bbc11edc357b5e8b5325e0b27b355cad4ed`; receipt SHA-256 `fc73d7676880ede616a050046c6b75b7a370049b4ba66a0bf359744baa215c6d`.

These numbers certify the **bounded encoding tests**, not the N=184 or 305-edge decision.

## Transfer T2 — same-domain Sidon insertion: exact repair, sharp algorithmic boundary

The following agents work on the *same collision-support hypergraph* and therefore genuinely compose as method/obstruction, conditional on the proof boundaries of their respective drafts:

| Step | Agent / evidence | Actual scope | Transfer conclusion |
| --- | --- | --- | --- |
| 1 | Axiom [PR #62](https://github.com/d3lefts/d3lefts/pull/62) | Single prescribed insertion reduces to deletion hitting, at most degree two, solved with matching; exceptional 2a=x+y must be covered | Exact combinatorial representation; externally unrefereed |
| 2 | Vesper [merged PR #110](https://github.com/d3lefts/d3lefts/pull/110) | Batch insertions over finite abelian groups; branch on high-incidence core and exceptional supports, then solve residual matching | Conditional FPT in k+c, **not** k alone |
| 3 | Ryev [PR #120](https://github.com/d3lefts/d3lefts/pull/120) | Independent Blossom replay + smaller exponent of Vesper's bound | Independently exercised algorithm and precise complexity refinement |
| 4 | Tessera [PR #136](https://github.com/d3lefts/d3lefts/pull/136) | Special one-point insertion over all finite abelian groups via a partial-involution functional pseudoforest; O(K) after O(K²) preprocessing | Faster **one-point** specialization, not a batch theorem |
| 5 | Axiom [PR #135](https://github.com/d3lefts/d3lefts/pull/135) | Singer perfect-difference source, **two outside marks**: high-degree core c≥ceil((q−5)/2) when gcd(v,3)=1 | Explicitly falsifies extrapolating small k to uniformly small c; says nothing about computational hardness |

**Exact negative control:** D={0,1,3,9} in Z/13Z, insertion a=7. The ordinary triple collisions can be repaired by one deletion, yet the **full** Sidon repair requires two deletions because of 2a=x+y. Treat any source/solver which omits diagonal exceptional collisions as invalid. See PR #62 and PR #136.

## Transfer T3 — finite Sidon extension is not automatically an infinite density gain

- Axiom [PR #62](https://github.com/d3lefts/d3lefts/pull/62) and Ryev [PR #84](https://github.com/d3lefts/d3lefts/pull/84) certify fixed-prefix *finite extension* lower coefficients strictly above 1/√2. They depend on prescribed prefix size r and tend back toward 1/√2 as r increases.
- Tessera [PR #128](https://github.com/d3lefts/d3lefts/pull/128) shows exact first-moment collision counts are invariant under source switching, **yet optimal repair cover size can change**, so average collisions are an inadequate optimization certificate. Tessera [PR #143](https://github.com/d3lefts/d3lefts/pull/143) limits amplification of one six-mark coset-local motif; the source theorem is classical and the no-go is specific to that motif family.
- Vesper [merged PR #103](https://github.com/d3lefts/d3lefts/pull/103) proves the particular two-window sufficient certificate requires β<1/(8r) to exceed 1/√2. **This is a ceiling on that certificate mechanism, not on Sidon density.**
- **Missing lemma:** exhibit a genuinely recursively closed class of prefix-preserving operators with growing-r, source-uniform loss and endpoint bounds, then establish the infinite-scale transfer with the true quantifiers. No NIGHTFALL work cited here currently supplies that lemma. Erdős #44/#329 remain open.

This is the highest-value cross-agent *failed transfer*: it prevents several impressive finite improvements from being incorrectly concatenated into an infinite theorem.

## Transfer T4 — phase identifiability versus efficient recovery (separate sensing models)

- Vesper [PR #31](https://github.com/d3lefts/d3lefts/pull/31) gives simultaneous iid F25 information-theoretic uniqueness at m≥ceil(83k/24)+s under its stated tail bound, originally with exhaustive inversion.
- Axiom [PR #16](https://github.com/d3lefts/d3lefts/pull/16) proposes an F5-linear constant-list decoder under the **same iid F25 law** and coefficient, internally proved and tested. The decoder is distinct from the older Frobenius-lift one-dimensional kernel condition.
- Axiom [PR #37](https://github.com/d3lefts/d3lefts/pull/37) achieves ≤2k−1 *adaptive* queries; [PR #121](https://github.com/d3lefts/d3lefts/pull/121) proves a fixed-graph measurement family with zero-support connectivity conditions. These are **different sensing models**, thus their raw query counts are not a single leaderboard.
- Ryev [PR #45](https://github.com/d3lefts/d3lefts/pull/45) examines another projective geometry phase-family construction. Full same-scope novelty and external referee review remain open across drafts.

**Actual transfer:** the prime-subfield phase-line representation changes the decoder, subject to exact iid hypotheses. **Non-transfer:** adaptive and nonadaptive measurement guarantees cannot be mixed.

## Review boundaries and other agent tracks — no forced synthesis

- **Lemnis** [PR #57](https://github.com/d3lefts/d3lefts/pull/57): exactly 3,221,225,472 **fixed base/gadget configurations** excluded from a C4/C8/C16-free family; this does not prove the Erdős–Gyárfás conjecture. [PR #35](https://github.com/d3lefts/d3lefts/pull/35) and Vesper [PR #38](https://github.com/d3lefts/d3lefts/pull/38) establish restricted-family Werner positivity, **not unrestricted undistillability**. These are strong examples of correct scope control, not new domain-crossing theorems.
- **Ryev** [PR #148](https://github.com/d3lefts/d3lefts/pull/148): the all-n≥5 square-syndrome second-shell classification gives a stronger **necessary** Q7 hypothetical 305-edge condition (≥12 even squares). Neither a witness nor a global upper-bound proof follows.
- **Tessara** [#76](https://github.com/d3lefts/d3lefts/issues/76): the sought **universal** continuum minimum-overlap inequality has no confirmed new unconditional lower record in the reviewed handoff; the 131,072-cell upper-bound witness remains a separate *finite* object.
- **Vesper** [PR #133](https://github.com/d3lefts/d3lefts/pull/133): minimum independent-reproof shield reduces to classical directed minimum cut, **conditional on actually revalidating the selected proof vertices**. This is a verification-system analogue, not a mathematical transfer of Sidon conclusions into PAS.
- **Axiom** [PR #144](https://github.com/d3lefts/d3lefts/pull/144): candidate planar-function reflection-spectrum gluing; independent novelty relative to the existing quadratic construction remains unsettled, and an 8,069,620-case affine-invariant comparison failed to distinguish examples. Retain as R1; no Original Finding claim.

## Site packaging / editorial decision

**Recommend:** add a short “Tested transfers — Oct 29” section to `docs/atlas.html` linking this source ledger and exact cross-domain verifier. The three principal reader journeys are:
1. **One exact equivalence:** Sidon saturation ↔ maximal independent set, hypercube C4 avoidance ↔ independent set. Same certificate grammar; different extrema.
2. **One genuinely composable cross-agent method:** Sidon collision support → one-point matching → batch FPT → one-point linear DP, with explicit high-core and diagonal falsifiers.
3. **One failed scale transfer worth preserving:** fixed-prefix >1/√2, and a proof that the current two-window certificate loses its gap as r grows.

Include a short phase-model scope check and no site home/Original Findings/status modifications. The Atlas is an editorial research navigation interface; the actual automated tools retain separate runtimes and trust boundaries.

**External review / final gate:** Lemnis to attack the cross-domain hypergraph representations and subset-versus-saturation quantifiers; Ryev separately rebuild both direct oracles; Tessera/Vesper inspect collision taxonomy and nesting limits; Tessara confirms continuum status and analytic source caveats. Internal tests and source-linked synthesis do not constitute outside mathematics refereeing. Owner approval required for site merge.
