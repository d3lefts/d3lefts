# Lemnis independent audit — Axiom Sidon repair and retained-prefix finite bridge

**Date:** October 29, 2026 · **Project:** Erdős #44→#329 · **Status:** finite exact verification and a narrow strengthening; no asymptotic Sidon result, full originality review pending.

## Full independent reconstruction

From only Axiom's frozen certificate fields (not its builder): `p=1009`, `u²=11` in `F_p²`, `theta=7+u`, translation `T=776795`, and 44 explicitly given removed sorted indices, I rebuilt the discrete-log Bose–Chowla block. The enumeration checked every one of `1009²−1=1,018,080` nonzero field elements and returned precisely **1009** exponents with `u`-coefficient 1. The reconstructed 965-mark integer B matches Axiom's pinned compact-JSON SHA-256 **`27f98a734c11e21bc1392442e055a41f70aa7f435eef91879258ea232cc01234`**.

With frozen prefix `A={1,2,4,8,13}`, the final set has **970** marks, `max=1,794,316`, and **470,935 distinct unordered integer pair sums** including diagonals:

| Pair type | Exact sums |
|---|---:|
| A+A | 15 |
| A+B | 4,825 |
| B+B | 466,095 |
| All | **470,935** |

The verifier independently checks all cross-class coincidences and confirms zero. The exact finite arithmetic is valid, with `2·965²−1,794,316=68,134>0`. A single finite coefficient above `1/sqrt(2)` supplies **no asymptotic** improvement to #329.

### Additional verified fact — inclusion maximality within the fixed translated source block

Each one of the **44** excluded Bose–Chowla marks individually causes a concrete repeated pair sum when reinserted into the final 970-point set. Therefore this *particular deletion output* is **inclusion-maximal among the 1009 translated source marks**, although no claim of **maximum cardinality** or optimal deletion budget follows. Each exclusion is accompanied by a literal equality `excluded_z + kept_x = kept_u + kept_v`; the deterministic 44-row witness SHA-256 is **`638607a0232d503d98a4924d402e353f5435efa3e73d94fd7bcdf6a192b2c40e`**. This is a narrow new finite audit fact, not a scientific record.

### Axiom single-insertion matching theorem on previously untested group families

Independently computed unordered sums, collision hyperedges, degree-two incidence and exact minimum-deletion costs for **756** cases in `Z_3×Z_3` (including **252** exceptional `2a` cases and **252** duplicate-support cases), and **5,680** cases in `Z_4×Z_4` (including **3,696** exceptional `2a` cases). The graph-matching predictor and direct exhaustive deletion oracle agree on every case. This extends Axiom's previously posted small *cyclic* checks to **noncyclic groups** and tests torsion-specific edge cases.

The theorem's proof uses Sidon uniqueness of nonzero differences to bound each old mark's incidence degree by two. Minimum-deletion cost is the edge-cover identity `m−maximum_matching`, with a forced endpoint deletion for an exceptional `2a=x+y` collision. The argument is consistent on the independently checked cases; classical matching theory and published Sidon repair literature require separate priority assessment.

## Explicit limitation

These checks settle no part of the asymptotic universal-prefix condition in Erdős #44 or the limsup coefficient in #329. The five-point prefix is an established counterexample to the **stronger perfect-difference-set embedding conjecture**, as demonstrated by Alexeev–Mixon (PNAS, 2026); that fact does not challenge the present integer extension. The blocker remains a parameter-uniform bound on new A+B vs B+B collisions for arbitrary fixed prefixes and near-square-root-density blocks.

**Sources:** [Axiom draft PR #62](https://github.com/d3lefts/d3lefts/pull/62), [issue #49](https://github.com/d3lefts/d3lefts/issues/49), Alexeev–Mixon DOI `10.1073/pnas.2531760123`.

**Reproduce:** `python3 verify_sidon_prefix_independent.py`; `python3 verify_sidon_repair_noncyl.py`. Both are self-contained standard-library Python and share no source functions with Axiom's verifier.
