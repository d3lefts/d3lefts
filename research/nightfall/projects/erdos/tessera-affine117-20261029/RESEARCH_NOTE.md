# TESSERA — Source-adaptive Singer affine-orbit repair, 2026-10-29

**Scientific status:** exact finite theorem and fully enumerated negative family, **not** an asymptotic Sidon record or solution of Erdős #44/#329. Human referee and external novelty review pending. Self-designed assignment [#117](https://github.com/d3lefts/d3lefts/issues/117); parent standing [#95](https://github.com/d3lefts/d3lefts/issues/95). Prior same-source barrier [#115](https://github.com/d3lefts/d3lefts/pull/115).

## Main result

Given a cyclic perfect difference set \`D⊂Z/vZ\`, any unit multiplier \`u\`, cut \`c\`, and integer translation \`T\`, let \`B=T+((uD−c) mod v)\`. Given a Sidon prefix \`A\`, the \`A+B=A+B\` sum collisions form a simple graph on the \`|D|\` newly inserted marks. Its edges represent exactly the pairs of new marks whose **ordinary positive difference** equals a positive difference of \`A\`. Removing source marks to eliminate this collision family is **exactly minimum vertex cover**, of size \`|D|−α(G)\`. This statement includes triple or higher multiplicities of a sum: each collision supplies all pairwise edges.

The graph depends on the cyclic cut \`c\` only through which source points have crossed the cut. For fixed \`u\`, there are at most \`|D|+1\` constant graph intervals; each interval is weighted by its exact number of integer cuts. The standalone verifier uses this **lossless event compression** to enumerate every multiplier and every cut, solving maximum independent set exactly with a Bron–Kerbosch pivot algorithm, without a solver dependency.

### Exhaustive results

| Singer q | v | K | Protected prefix size | All multiplier/cut pairs | Distinct cut states | Minimum AB/AB deletions | Exact full distribution by deletion cost |
|---|---:|---:|---:|---:|---:|---:|---|
| 5 | 31 | 6 | 4 | 930 | 205 | 2 | 2:354; 3:576 |
| 7 | 57 | 8 | 5 | 2,052 | 319 | **2** | 2:12; 3:1206; 4:834 |
| 25 | 651 | 26 | 17 | **234,360** | **9,708** | **15** | 15:3840; 16:3972; 17:6876; 18:78780; 19:125856; 20:15036 |

For q=25, **no affine unit-multiplier/cut combination** beats the original source's \`m−2=15\` old-new/old-new repair lower bound, for this one fixed 17-mark prefix and frozen 26-mark difference set. This is a completely finite subgroup theorem; other Singer sources and larger q remain open.

### A full Sidon escape at q=7

The frozen source is \`D={0,7,16,21,22,24,34,53}\` modulo 57. The source-coupled prefix is \`A={1,8,17,22,23}\`. Choose \`u=29\`, \`c=12\` and \`T=49\`. The eight new residues are \`[45,20,53,27,56,0,5,43]\` in source order. Delete indices 3 and 6. This produces

\`C={1,8,17,22,23,49,69,92,94,102,105}\`.

All **66 unordered sums** of C are distinct. Exhaustive testing of the eight possible single-mark deletions shows none works; thus exactly **two deletions** suffice and are necessary at this transformed source/cut/translation. The new source \`29D\` is not a cyclic translate of D. The prior same-source theorem required **at least three deletions** for every cut and every translation placing the source above A. Hence affine source change genuinely escapes that narrower obstruction in a finite, fully verifiable instance.

A further independent exhaustive sweep of **36 units × 57 cuts × 10 translations (T=47,…,56)**, checking *every* old-old/old-new/new-new repeated sum, yields 20,520 full-repair instances. Exact repair minima histogram: **2:6, 3:6171, 4:13356, 5:987**. Six instances (at T=49 or 52) permit two deletions.

## Reproduce and independent verification

Run \`python3 research/nightfall/projects/erdos/tessera-affine117-20261029/certify.py\` with Python 3.12 standard library. It reconstructs all nonzero modular differences for q5, q7, q25, checks each protected prefix, executes every weighted compressed affine cut, compares the exact census with frozen integer constants, verifies the full 11-mark witness, and independently checks every one of the 20,520 q7 full repair instances.

The originating research bundle, \`NIGHTFALL_Tessera_Affine_Source_20261029.zip\`, additionally contains:
- An independently written **C++17** bitset-coloring maximum-clique census, its input data, and complete compressed-state CSVs;
- A separate literal-sums Python checker, exhaustive q5/q7 brute force, and 120 independent q25 MILP checks;
- All exact outputs, proof note, SHA-256 manifest and negative checks.

Hash of independently executed standalone Python verifier (archive): \`8d3a21e66cd50a147ea00cf2d8a30af679500b092e03bda436e8c31ffeccbae4\`. Exact ZIP SHA-256: \`e955cfba155ad8c7ca635097aa7b8021666362777ad7a4f29a4c90229fd0efd9\`.

## Next theorem gate

These results disprove extending a **same-source** deletion lower bound to all affine source transformations, yet the q25 finite census also shows that adaptation need not help. The necessary next step is a **uniform-in-q quantitative theorem for a source-adaptive, recursively closed family** of prefixes, with explicit repair-loss bounds for **all** A+A/A+B/B+B collision classes. No inference about infinite Sidon density follows from the finite source escape.

**Prior art:** Singer cyclic difference sets are classical. Alexeev–Mixon (PNAS, 2026) and Niu (arXiv:2604.25214) concern exact perfect-difference-set embedding obstructions, a different conjecture from deletions-permitted grafting. [Singer background](https://personal.ntu.edu.sg/bernhard/Publications/pub/Singer.pdf) · [Alexeev–Mixon](https://pubmed.ncbi.nlm.nih.gov/42172271/) · [Niu](https://arxiv.org/abs/2604.25214). No worldwide novelty priority asserted.
