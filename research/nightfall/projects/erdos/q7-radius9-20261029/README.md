# NIGHTFALL / Ryev — Q7 exact local audit (2026-10-29)

**Status: certified finite reference reproduction and exact seed-local exclusion; no new extremal record or global theorem.**

## Baseline and attribution

- Erdős #86: find the largest C4-free subgraph of Q7.
- Best dated construction: **304** edges, historically attributable to Derrida–Pomeau–Toulouse–Vannimenus (1979), reproduced in Minamo Minamoto's 2026 work. Current general published window: **304 <= f(7) <= 308**.
- Source: https://github.com/minamominamoto/c4free-hypercube and https://www.erdosproblems.com/86
- `seed_edges.txt` is a canonical sorted `u v\n` transcription of Minamoto's public `selected_edges_best.json`. It is not original NIGHTFALL work.
- SHA-256 of **this canonical text file**: `b47c7bba3cf07ea8db4b424c1d96e46957049656111ae035166edb19d4739655`. Not the upstream JSON hash.

## Reproduction

```bash
python3 audit.py
```

No external dependencies. The verifier independently constructs 448 cube edges via pairwise Hamming distance, 672 square faces via opposite corners, and a second C4 check using length-two path multiplicities. The 304-edge reference has **zero** C4s and square intersection histogram `{1:36, 2:120, 3:516}`.

**Seed-local result:** each of the 144 absent edges is blocked by 3 or 4 disjoint almost-complete squares (60 with three blockers, 84 with four). The exact checker enumerates **1,576** relevant three-deletion sets and **475,234** relevant four-deletion sets. No such set unblocks more than **three** absent edges. Therefore any C4-free graph with at least 305 edges must be **at least 11 edge flips** from this particular 304-edge seed. This is a finite local statement, not `f(7) <= 304`; originality and independent human review remain open.

## Additional experiments and stopping decision

- HiGHS local 305-feasibility models reported infeasible for Hamming radii 3,5,7,9,11,13,15. Only radii <=9 have the separate portable exact enumeration here; no proof logs were produced for larger radii.
- All fourteen Q6 coordinate-face restricted MILPs were infeasible.
- Global 305-feasibility MILP, with a valid degree-five star symmetry break, **timed out after 25 seconds / 2,847 nodes** with no witness and no infeasibility proof. This does not improve the general upper bound of 308.
- Global LP bound from the simple square constraints is 336, weaker than the external upper bound.
- Three operator families were exhausted: local MILP, exact blocker transversals, and global symmetry-broken MILP. Do not continue by merely retuning the same seed.

**Next decisive experiment:** cross-orbit or support-transition search seeded from inequivalent 304-edge graphs; or a global SAT solver with a portable LRAT/DRAT unsatisfiability proof and independent checker. Any new 305-edge witness must pass an exact external verifier and a same-day priority search.

Full exploratory scripts, solver logs, manifest and hashes are preserved in the session's `NIGHTFALL_Ryev_Q7_20261029.zip` handoff; the two files in this directory suffice to reproduce the exact local claim.
