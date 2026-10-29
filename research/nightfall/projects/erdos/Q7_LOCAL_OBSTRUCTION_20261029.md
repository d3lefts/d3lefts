# Erdős #86: exact local obstruction at a public 304-edge Q7 witness

**Date:** 2026-10-29  
**Status:** independently rerun *finite local obstruction*; **not** a global upper bound, **not** a new Erdős record. External publication-priority/referee review open.  
**Research issue:** [#48](https://github.com/d3lefts/d3lefts/issues/48)

## Scope and prior art
Let \(f(7)\) be the maximum number of edges in a four-cycle-free subgraph of the seven-dimensional Boolean cube. The known range is \(304\le f(7)\le308\). The baseline 304-edge construction was published by Minamo Minamoto, with an older historical 1979 construction acknowledged in its corrected repository. This file analyzes **one specific external 304-edge witness** and claims no ownership of that construction.

Source: https://github.com/minamominamoto/c4free-hypercube/blob/main/selected_edges_best.json  
Primary problem: https://www.erdosproblems.com/86  
OEIS: https://oeis.org/A245762

## Finite result

For the 304-edge graph \(H\) encoded in the source file, any four-cycle-free graph \(H'\) with **at least 305 edges** differs from \(H\) in **at least 11** of the 448 possible edge coordinates.

Equivalently: there is no strict improvement obtainable by deleting at most **four** edges of \(H\) and adding arbitrary originally absent cube edges.

**Reason:** Every originally absent edge lies in exactly 3 or 4 *tight squares* (squares containing all other three edges of \(H\)). The three already-present edges in those tight squares are disjoint across distinct squares incident with the same absent edge, so adding the absent edge after deletions requires hitting each tight triple.

The 144 absent edges divide into:
- 60 with 3 tight squares;
- 84 with 4 tight squares.

Enumerate every four-edge removal set able to unlock at least one absent edge, by selecting one edge in each required tight square (plus an arbitrary fourth removed edge in the 3-square case). This enumerates **475,234** removal sets. Exact counts of individually unlockable absent edges:

| Unlockable | Four-edge removal sets |
| --- | ---: |
| 1 | 464,579 |
| 2 | 6,980 |
| 3 | 3,675 |
| 4 or more | **0** |

For any removal set of cardinality at most four, no more than three originally absent edges become individually insertable. Any strict improvement after \(r\le4\) removals requires at least \(r+1\) additions, impossible by the count. For a strict 305-edge improvement, \(r\ge5\), giving a minimum symmetric-difference distance \(r+(r+1)=11\).

This is a finite **local** certificate, and cannot establish \(f(7)=304\).

## Reproduction

From repository root, standard-library Python:

```sh
python3 research/nightfall/projects/erdos/q7_local_obstruction_20261029.py
```

Expected output: `result: PASS`, 448 cube edges, 672 four-cycles, witness size 304, square occupancies `{1:36, 2:120, 3:516}`, four-removal unlock distribution as above and minimum improvement distance 11.

The included 448-bit bitmask transcribes the linked author's published edge list, in order \((v,i)\) for \(0\le v<128\), \(0\le i<7\), with bit \(i\) of \(v\) zero. To audit the transcription, compare all 304 decoded edges against the author's JSON. In the internal replay a separate coordinate-square enumerator and a second bitset enumeration both reproduced the 475,234/464,579/6,980/3,675 counts. The independent second-path script can be obtained with the session artifact.

## Discovery handoff

The structural lesson is an active-set transition: **one-to-four deletion local repairs on this specific witness cannot improve 304**. Future research must switch representation, e.g. nonisomorphic 304-edge seeds, parity-breaking orbits, larger-than-four deletions, fixed-305 edge-assignment feasibility, or an exact upper certificate.

Do **not** advertise this as a breakthrough resolving Erdős #86; use it to eliminate a finite search neighborhood and prioritize a different operator family. Treat any solver dual bound as provisional until accompanied by a checkable proof.
