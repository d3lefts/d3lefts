# NIGHTFALL — Paley(5591) triple-out-neighborhood passport, v0.2

**Date:** 2026-11-20. **Status:** author-side exact finite computation, two independently implemented exhaustive checks, plus an analytic reduction to the classical Hasse bound. **Not** Lean-certified or independently peer-reviewed. **No improved block-sensitivity exponent is claimed.**

## Problem and claim

Let `p=5591` (prime, `p mod 4=3`), let `Q` be the nonzero quadratic residues modulo `p`, and direct `a -> b` exactly when `(b-a) mod p in Q`. For a vertex `a`, write `N+(a)={x: x-a in Q}`. The session claim is

    max_{a,b,c distinct in F_5591} |N+(a) ∩ N+(b) ∩ N+(c)| = 717.

The published 2.13981 ordinary-sensitivity construction reports a bound of 800 for the common out-neighborhood of three distinct vertices in this Paley tournament. The exact calculation tightens that **one finite combinatorial bound** by 83, or 10.375%. It does not establish a change in the full sensitivity recurrence.

## Mechanism A: analytic upper bound

For arbitrary three distinct `a,b,c` and the quadratic character `chi` extended by `chi(0)=0`, put

    S = sum_{x in F_p} chi((x-a)(x-b)(x-c)).

As an expansion of the indicator of a *nonzero* square, and using the standard identities `sum chi(x-a)=0` and `sum chi((x-a)(x-b))=-1` for `a != b`, we have

    8 * |N+(a) ∩ N+(b) ∩ N+(c)| = p - 3 + S - 4t,

where `t` is the number of vertices among `a,b,c` which are out-neighbors of **both** other vertices (so `t` is 0 or 1 for a tournament). In particular `t>=0`.

The nonsingular elliptic curve `y^2=(x-a)(x-b)(x-c)` has `p+1+S` points over `F_p`, including the point at infinity. The classical Hasse bound yields `|S| <= 2 sqrt(p)`. Since `4*5591=22364<22500=150^2`, `S<150`, hence `S<=149` because `S` is an integer. Therefore

    8N <= 5591 - 3 + 149 = 5737,
    N <= floor(5737/8) = 717.

This proves the **upper** bound assuming the standard Hasse theorem and elementary character-sum identities. It is not a new proof of Hasse's theorem.

## Mechanism B: sharp witness

The normalized triple `(a,b,c)=(0,1,838)` forms a directed 3-cycle under the convention above, hence `t=0`. The exact character sum is `S=148`, which gives `8N=5591-3+148=5736` and `N=717`. The supplied executable checks the witness directly from both modular squares and Euler's criterion.

## Independent exhaustive audit

For any ordered triple `(a,b,c)` with distinct entries, translate so `a=0`. Multiplying all vertices by any nonzero square preserves the tournament. If `b` is square, normalize `b=1`; if `b` is nonsquare, normalize `b=-1`, because `-1` is nonsquare for `p mod 4=3`. Thus exactly `2*(p-2)=11178` normalized cases cover all possibilities.

- Checker A forms the residue set by modular squares and uses cyclic bit shifts plus `bit_count()` to count intersections.
- Checker B independently forms a quadratic-character table with Euler's criterion and directly counts membership for every possible third vertex.

They match on every one of the 11,178 cases. Their common maximum is 717; minimum is 680. Equality occurs in six cases for `b=1` and six cases for `b=-1`.

Files: `nightfall_paley5591_triple_audit.py` and its generated `nightfall_paley5591_triple_receipt.json`. Run `python3 nightfall_paley5591_triple_audit.py`. Uses only Python standard library. The receipt contains the source SHA-256.

## Provenance, prior art, status, and transfer

- Record to improve: `SensitivityCampaign.reach_213981`, Prove2Me theorem `/theorems/0e93b146-3cac-42d3-b8f4-74010d06b636`, published Oct. 27, 2026; mission text gives Paley(5591), 22 levels, 2,739-dimensional sensitivity invariant, original triple cap 800, and four-stage sensitivity factor 10,121,928.
- Hasse character-sum background: MIT 18.783 elliptic-curve notes and the FLINT elliptic-curve point-counting tutorial. Brouwer–Martin, *Triple intersection numbers for the Paley graphs*, is analogous prior art **for graphs**, not a uniqueness/novelty claim about tournaments.
- Exact 717 was not located in a targeted same-session web search. This is insufficient for a novel-contribution classification.
- Transfer hypothesis: replace any use of a **uniform triple-common-out-neighborhood cap** of 800 in the accepted 22-level sensitivity checker by 717, then rebuild all profile inequalities and re-evaluate its four-stage growth factor `A`.
- **Critical limitation:** the accepted dependency closure and all 97,594 sensitivity-row cases were not accessible for independent replay in this session. It is unknown whether the cap 800 is on the critical path or whether the source already uses a sharper effective restriction. No improvement to `A`, `s(f)`, `bs(f)`, or the exponent has been established.

## Exact follow-up threshold

Keep block-growth factor `5591^4`. Then exponent `>107/50=2.14` is equivalent to the integer comparison `5591^200 > A^107`, and the maximum admissible positive integer is `A=10,107,721`. The current `A=10,121,928` would need to decline by at least `14,207`, a `0.140356...%` reduction. A checkpoint also gives `A<=9,377,206` for `>43/20=2.15`, equivalently `5591^80 > A^43`. These integer thresholds were computed separately from the Paley check.

## Audit plan and stop rule

1. Recover the pinned Lean 4.33.1 source closure and exact definition of the tournament triple cap. Verify its provenance; do not replace any other combinatorial parameter by 717.
2. Identify every dependency on 800, and regenerate the sensitivity profile with only this parameter changed. Record changes in endpoint `A` and every failed inequality.
3. Validate the result using an independently written sensitivity-profile interpreter against all packed cases; then certify in pinned Lean and obtain an external review of semantics.
4. First decisive experiment: a *single full endpoint replay* with cap 717. If `A` is unchanged, mark geometric tightening as inactive and pivot to profile subeigenvector/search optimization rather than tuning the cap further.
5. No public record claim or repository integration of a new exponent without the actual source-level proof, a replay receipt, and human authorization.
## v0.2: orientation-aware exact refinement and blocked transfer

The two-implementation exhaustive checker was rerun on 2026-11-20. Classifying every symmetry-reduced triple by whether it is a directed 3-cycle (`t=0`) or transitive (`t=1`) gives exact maxima **717** over 2,796 cyclic cases and **716** over 8,382 transitive cases. The additional `nightfall_paley5591_orientation_check.py` checks these figures and records the number of equality cases (12 and 96, respectively). No inference about the sensitivity recurrence follows without the author's actual source. 

The published Prove2Me periodic theorem `Sensitivity213981Formal.ThreeBoundEndpoint22CampaignComplete.periodic_upper` pins the factor `10121928` and the accepted mission describes a triple cap of `800`. Its listed proof source is an archive URL `https://chatgpt.com/library?file_id=libfile_431310a5a24c81918d3f7bda6cf4262b&account_id=personal`, with publicly reported SHA-256 `15679de91204c2f0619380925cb21f560610f5a2467627ac5de8715f34ff3ddd`. This archive was **not obtainable** from our available GitHub, public web, or file-library retrieval; its hash is a *reported target*, not a locally verified digest. The published theorem page exposes imports and the statement, not the 97,594 packed summary rows or the endpoint generator. Consequently, no replacement of `800` in the source, replay of the 22-level endpoint, or improved exponent has been performed. Do not claim that any existing checker has accepted this geometry substitution.

Independent exact threshold check: `A <= 10107721` is necessary and sufficient (for integral `A>0`) to make `4*log(5591)/log(A) > 107/50`, assuming `A>1`; the condition is `5591^200 > A^107`. At `A=10121928` the old endpoint remains `2.1398136583162706859...`. 
