# C7 fifth-power construction: exact baseline and restricted operator audit

**2026-10-30 · NIGHTFALL · Draft evidence · Historical source: Polak–Schrijver (2019)**

## Scope and achievement
- Reconstruct the **published** 327-word core by the exact published shift (40,123,40,123,40) and rounding `floor(2i/109)` of 382 cyclic words.
- Reconstruct an exact 40-word independent completion from the 71 words compatible with the core. The complete 367-word output has SHA-256 `45e55b09cc3fdcd6cd916a44e7f51586adf5e7d4162bcd55206dc164d6fd2123`; **all 67,161 pairs independently verified with integer modular arithmetic**, zero duplicate words. The completion is not asserted to match the author's appendix byte-for-byte.
- Define a substantially different **restricted search space**: all 327 core words plus *all* noncore 5-tuples conflicting with at most two core words. It contains **1,198 noncore words**, and the induced candidate graph has **21,645 noncore edges**. An integer MILP (HiGHS, SciPy) reports zero-gap maximum independent-set cardinality **367**, including arbitrary deletions among the core. This is a **solver-optimal empirical result in a restricted domain**; no standalone exact upper-bound certificate is provided and **this is not a proof `alpha(C7^5)<=367`**.
- After a bounded follow-up attempt with degree ≤3, the general induced model was too expensive for the selected computational budget and produced no certified result. Stop this exact operator family; switch construction/geometry.

## Reproduction

```sh
python3 research/nightfall/leaderboards/c7-five-20261030/verify_367.py --write c7-367.txt
python3 -m pip install scipy==1.15.3 numpy
python3 research/nightfall/leaderboards/c7-five-20261030/restricted_milp.py --max-core-conflicts 2
```

The first checker uses only the standard library and is the authoritative witness-validity test. The second is an optimization experiment and must retain its solver version and MIP dual-bound receipt.

## Experimental observation and mathematical limitation

Given the fixed 327-word Polak–Schrijver core M, define `D_2={v in Z7^5: v in M or v is confusable with at most 2 members of M}`. The solver reports `alpha(C7^5[D_2])=367`. Any proposed 368-word construction, *if the solver's optimum is confirmed with an independent exact proof certificate*, must contain at least one word confusable with 3 or more members of M. This conditional consequence is a **family-scoped obstruction**, not global nonexistence. An independent proof-producing SAT or rational-cover certificate is the appropriate next audit. No 'discovery' or 'record' gate is crossed by these tests.

## External comparison and direction

[Polak & Schrijver (2019)](https://doi.org/10.1016/j.ipl.2018.11.006) constructed 367 using a 382-word circular graph and core extension. The latest [EinsteinArena problem](https://einsteinarena.com/problems/shannon-capacity-c7-5) lists 367, explicitly flags scorer review, and cites newer tenth- and 500th-power capacity records. The [molind/c7-five research archive](https://github.com/molind/c7-five) already closes numerous one-/few-word exchanges around related published cores. This checkpoint is not claimed to outdo that archive or improve the global bound.

**Next experiment with positive information value:** rather than allowing a few conflicts with the *same* core, use a new algebraic cyclic generator, a joint nonlinear discretization, or exchange blocks supported on a new seed, and seek an explicit 368-word witness. For a hypothetical witness, independently check exactly `368*367/2=67,528` pairs in two implementations, retain a SHA and obtain owner authorization before external submission.

**Provenance:** AI-assisted NIGHTFALL Vesper reconstruction; published 367 credited to Sven C. Polak and Alexander Schrijver. No human-independent review; no externally submitted record. Campaign issue [#261](https://github.com/d3lefts/d3lefts/issues/261).
