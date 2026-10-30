# Adaptive rank–orbit and signed-projective obstructions for finite-field powered measurements

**Attribution correction (cross-team, 2026-10-30):** Lemnis independently derived the same adaptive rank-prefix lower bound and the exact GF9 dimensions k=6 and k=9 **before** Axiom's current PR, with signed audit in [Lemnis PR #264](https://github.com/d3lefts/d3lefts/pull/264) and [#257 comment](https://github.com/d3lefts/d3lefts/issues/257#issuecomment-6531172211). Treat Axiom's k6/k9 replay as corroboration, NOT another original finding or a new count attributable to this PR. **Axiom's distinct R1 extension is the k=8 exact lower bound**, combining an online rank-phase adversary with the new 38-projective-type/78,125-row finite certificate. Both remain internal AI mathematics awaiting external human review.

**Checkpoint:** 2026-10-30. **Research owner:** Devin J. Wright. **Construction and proof draft:** Axiom (AI research role). **Assignment:** Vesper's #257. **Scientific stage:** R1 internally derived mathematical theorem candidate, exact finite regression, and external mathematical review/priority unresolved. Do not claim worldwide originality or independent human refereeing.

## Problem, baseline and stopping rule

Let K be a finite field of size Q, H ≤ K* a multiplicative subgroup of order h>1, and observe arbitrary adaptively selected K-linear forms through exactly the oracle (a·x)^h, for unknown x∈K^k modulo ONE common H scalar. Every query is charged, including zero measurements. Zero signal and all support patterns belong to the feasible set. The exact output alphabet is L=1+(Q−1)/h, including the zero value.

**Closest source checked:** Lemnis [PR #264](https://github.com/d3lefts/d3lefts/pull/264) already proves the same k6/k9 rank-prefix facts; those are **prior in-program evidence**, not an Axiom novelty claim. Vesper's #257, PR #256 gives a candidate upper A(k,r)≤k+ceil((k−1)/r) over GF(3^r) under the square oracle, with source-comparison to Borello–Schmid–Scotti (JCTA 214, 2025) on intersecting codes and other phase-retrieval models. BSS addresses fixed measurements, not the present adaptive lower-bound branch construction. Web search on 30 Oct 2026 found related finite-field/phaseless literature without locating this exact prefix argument. A targeted search is not worldwide priority clearance.

**Objective at origin:** independently attack whether eight queries recover every GF9^6 signal modulo sign; Lemnis reached the same answer first. **New decisive objective after attribution reconciliation:** exclude GF9 k8 with eleven adaptive queries by a structural rank-phase argument and exact projective finite audit. Existing candidate upper is nine; output counting only rules out seven. An additional k9 test is included because it costs a single exact inequality. Compute budget: source-independent finite enumeration of the 531,441 six-coordinate field vectors and symbolic integer inequalities; stop before solver/random search. Independent audit: Lemnis mathematics, Ryev distinct verification and Lean dependency map, Vesper historical comparison.

## Universal rank–orbit prefix theorem (R1)

For integers k≥t≥2 and m≥t, if

    min( Q^(k−t+1), h^(t−1) Q^(k−t) ) > L^(m−t),

then NO adaptive protocol using at most m legal powered-linear observations distinguishes every signal in K^k up to global H.

### Proof with fully adaptive coefficient choices

An identically zero first linear row is wasted, so it can be omitted from an optimal candidate. If there is early termination, pad that branch with zero queries without improving its distinguishability.

Construct a feasible transcript through t observations as an adversary. For the first nonzero row choose a nonzero powered response. Every later row is now determined by previous powered outcomes. If it is linearly independent of earlier rows, choose ANY nonzero powered output: surjectivity of the enlarged linear map onto K^r guarantees that output is compatible with some signal. If it is dependent, choose any compatible output and continue on a nonempty branch.

At the end, let r be the rank of the t rows selected along this transcript, which are fixed functions of the observed path.

**Case 1: at least one row dependence.** Then r≤t−1. Fix any compatible signal x and its complete vector b of UNPOWERED linear readings for these selected rows. The linear system A z=b has exactly Q^(k−r) solutions. Every one has first linear reading b_1≠0. Two different solutions are not related by a common nonidentity scalar in H: any such scalar would change b_1. Therefore this single powered transcript contains at least Q^(k−r)≥Q^(k−t+1) globally inequivalent signals. This argument uses only ONE compatible unpowered lift and does not improperly claim that dependent later output branches preserve all relative sign patterns.

**Case 2: all t rows independent.** Every chosen powered response is nonzero. Each has exactly h unpowered roots. By surjectivity there are exactly h^t Q^(k−t) compatible signals. The global H action is free and permutes them, so this node contains exactly h^(t−1) Q^(k−t) global H-orbits.

After t queries, at most L^(m−t) distinct transcript leaves remain under ANY adaptive strategy. If the displayed minimum exceeds this count, distinct valid signal orbits collide in every alleged m-query strategy. This is a proof by adversarial branch construction, not a random search or a fixed-row lower bound. QED, subject to independent proof challenge.

**Important model boundary:** Every row may depend on the previous cubed/squared observations. The adversary does not inspect unpowered values to select the next query. Linear lift b is chosen analytically after fixing the path, to count existing compatible signals, never as information supplied to the decoder. Any zero signal remains in the original input domain; we establish impossibility by one nonzero branch alone.

## Two exact GF9 consequences

Set K=GF9, H={±1}, h=2, square oracle and L=1+(9−1)/2=5 outputs per query.

| k | attempted m | prefix t | rank-drop fiber 9^(k−t+1) | independent fiber 2^(t−1) 9^(k−t) | remaining leaves 5^(m−t) | status |
|---:|---:|---:|---:|---:|---:|---|
| 6 | 8 | 4 | 729 | 648 | 625 | 8 queries impossible |
| 9 | 12 | 3 | 4,782,969 | 2,125,764 | 1,953,125 | 12 queries impossible |

Combining with PR #256's all-support, coordinate-first construction giving upper bounds of 9 and 13, the resulting **mathematical candidate exact minima** are:

    A_GF9(k=6) = 9;     A_GF9(k=9) = 13.

The upper theorem remains independently reviewable. **The rank-only prefix lemma does not settle k=8**, whose closure requires the separate seven-phase signed-projective classification below. Neither finite mechanism proves a better asymptotic linear lower-bound coefficient.

### Exact finite verification and checker contract

- [check_prefix.py](check_prefix.py) performs all strict inequalities as integers and constructs direct sign-orbit sets using GF3[u]/(u²+1). The actual independent-four-coordinate output (1,1,1,1) has exactly **648** global-sign classes with two free GF9 coordinates.
- The dependent-fourth-row example fixes the first three coordinate squares equal to 1 and measures the square of x1+x2+x3. Its fourth-output buckets are **729** and **2187** sign classes. A dependent row can concentrate classes; our proof uses a minimum Q^(k−r) affine fiber, never a fictitious all-nonzero h-factor.
- [independent_gf9.py](independent_gf9.py) independently represents the field as GF3[v]/(v²+v+2) and visits all **531,441** six-coordinate vectors. It counts global-sign classes directly for the same two prefixes, including zero-powered outcomes and a different modular reduction formula.
- Negative control: using six alphabet symbols instead of the legal five makes 6^4=1296 greater than 648, so a false output-alphabet count cannot justify the reported k6 obstruction. Both scripts fail loudly on changed counts.

Scripts require only Python 3.12. CI prints their SHA-256 values. These computations certify small exact fibers, **not** a mechanically formalized universal theorem or historical novelty.

## New second-stage theorem — GF9 dimension eight also needs twelve adaptive queries

**Claim (R1 internally checked):** In the same frozen GF9 sign-square oracle, no adaptive protocol can recover every x∈GF9^8 modulo global ± using only 11 measurements, even when it chooses all coefficient rows based on previously observed squares. PR #256's independent upper candidate uses 8+ceil(7/2)=12; if that constructive proof survives review, **A_GF9(8)=12 exactly**. This is stronger than the elementary global output-count lower bound 11. It resolves the target Vesper #257 left open in the earlier version of this note.

### Adaptive phase-palette invariant — every rank history, not just a fixed first round

As above, an identically zero first row is wasted. An alleged 11-query strategy may be strengthened by substituting a nonzero first query, so assume the first query is nonzero. As adversary, select its square output to be 1 and use the global ± quotient to anchor its raw linear reading to 1.

For a path of readings, choose a linearly independent subcollection of its queried rows. Let r be their rank and let S be the set of raw **relative sign vectors** of the r independent readings which are compatible with *all* powered outcomes on that path, normalized at the anchored first row. We choose every independent queried row's square output to be 1, so each independent raw reading is ±1. Each sign vector in S corresponds to exactly **9^(8−r) distinct global sign-orbits**, because the associated full-rank unpowered linear system has 9^(8−r) solutions and the first linear reading is fixed to 1. Thus a node with N=|S| retains exactly N·9^(8−r) candidate global orbits.

- When the next row is **independent**, the linear map extends surjectively, and the adversary chooses square output 1. Every prior sign vector has exactly two compatible raw readings ±1 in the new independent coordinate: N becomes 2N, rank r+1.
- When the next row is **dependent**, it is an F9-linear combination of preceding independent rows and its square depends only on the current sign vector. This partitions S into at most **five** observable squared outcomes. Choose a largest fiber; N becomes **at least ceil(N/5)** with rank unchanged. The adversary has used only legal observed squares, never revealed signs.

Apply this for the first eight queries. Start at rank 1 and N=1. Enumerating all 2^7 abstract sequences of independent/dependent choices for queries 2 through 8 gives a rigorous **worst-case lower recurrence** for each possible adaptive rank history. Except for ONE history, N·9^(8−r) is already strictly greater than the remaining three-query transcript capacity 5³=125.

The unique exceptional history is **IIIIIIID** (seven independent nonzero readings followed by one dependent row). In it, the simple alphabet pigeonhole gives only ceil(64/5)=13 relative-phase words, hence 13·9=117≤125. No other rank history can evade the obstruction. The independent history of eight rows retains 2^7=128 orbits, already larger than 125.

### Exact finite projective obstruction for the sole exceptional history

For seven independent observations each squared to 1, there are **64** relative sign patterns (seven raw ± signs, quotient one global ±). The dependent eighth row is some F9-linear combination with coefficients (c_1,…,c_7)∈F9^7. Its squared output is

    (c_1 epsilon_1+...+c_7 epsilon_7)^2,  epsilon_i∈{±1},

considered over the 64 global-sign classes. We must show **every** such coefficient row has a squared-output fiber of at least **14** phase patterns. That leaves ≥14·9=126 global orbits, exceeding the 125 remaining transcripts.

**Exact symmetry reduction.** View F9 as the two-dimensional additive F3-vector space. Since each epsilon_i ranges over ±1, flipping a coefficient c_i to −c_i only permutes the input sign patterns. There are five relevant coefficient types: zero and the four one-dimensional projective lines of F3². Permuting the seven coordinate positions changes no output-fiber sizes. Finally GL_2(F3) induces all S4 permutations of the four projective directions (PGL_2(F3)≅S4). Any invertible F3-linear transformation preserves equality of squared outputs, because it preserves ±-equivalence; it merely relabels the four nonzero squared-output classes.

Thus every arbitrary coefficient vector reduces **without loss** to an integer occupancy profile

    (n_0,n_1,n_2,n_3,n_4), sum n_i=7, n_1≥n_2≥n_3≥n_4≥0.

Exactly **38** such profiles exist. On the additive group F3², compute the exact signed-convolution coefficient table

    P = product_i (delta_(c_i)+delta_(-c_i)),

group its 9 raw sums into the zero orbit plus four ± nonzero orbits, and divide every result by 2 to account for the global sign action. The explicit [38-type checker](check_seven_phase.py) proves that **all 38 profiles have maximum fiber ≥14**, with equality **only** for the profile (1,2,2,2,0), whose sorted output-fiber sizes are **(14,14,14,12,10)**.

For extra verification without the S4 reduction, [an independently coded exhaustive checker](independent_seven_phase.py) uses the different field representation F3[v]/(v²+v+2) and evaluates **all 5^7=78,125 coefficient sign-classes** directly. It finds the same minimum maximum fiber **14**, attained for exactly **2,520** coefficient tuples; the latter count follows independently from 7!/(1!2!2!2!) ·4 = 2520. Both calculations are finite, integer-exact, and include the zero coefficient and zero powered-output class.

Combining the online all-rank-history adversary and this sharp finite classification yields **eleven-query impossibility for all adaptive coefficient strategies at k=8**. The candidate exact table, conditional only on independent audit of the constructive upper proof, is now:

| k | global counting lower | stronger adaptive lower (this work) | existing proposed upper | exact candidate |
|---:|---:|---:|---:|---:|
| 6 | 8 | **9** | 9 | 9 |
| 8 | 11 | **12** | 12 | 12 |
| 9 | 12 | **13** | 13 | 13 |

This does **not** establish a new asymptotic lower-bound coefficient, a universally optimal decoder in every dimension, or worldwide historical priority. It is a sharply scoped **finite-field adaptive decision-tree lower theorem candidate**, subject to a non-author mathematical proof challenge.

### Additional independent attack contract

Lemnis must attack the phase-palette invariant under path-dependent rank choices, the legality of prescribing a nonzero squared output on every independent row, the GL2(3) symmetry normalization, the exact number of canonical profiles, the output label grouping and early-termination padding. Ryev should write a non-importing 38-type or full 78,125-row verifier and attempt a Lean formal proof of the affine-fiber and 2N/ceil(N/5) steps. Vesper should check historical finite-field phase-retrieval and adaptive separating-code literature, *including negative results that already rule out k8=11*, before considering scientific novelty. **Stop after rigorous adversarial review; no unrelated coefficient annealing.**

## Distinctness, limitations and scientific review

Prior work: [Borello, Schmid and Scotti, The geometry of intersecting codes (2025)](https://arxiv.org/abs/2406.04034) develops fixed linear-code geometry; [Vesper #257](https://github.com/d3lefts/d3lefts/issues/257) provides the GF9 adaptive upper and fixed-code baseline, with [PR #256](https://github.com/d3lefts/d3lefts/pull/256) carrying the pending theorem proof. The complement property and alphabet counting are established background. The present mechanism combines **an adversarial adaptive path and two separate linear-rank orbit-fiber formulas**. Whether this criterion or the exact k6/k9 values appear in old finite-field decision-tree literature remains unresolved. No published originality, improvement over historical source or flagship promotion is asserted.

**Falsifiers:** (i) an eight-query GF9 k6 decoder with a full verified transcript certificate; (ii) a compatible dependent path with fewer than Q^(k−r) orbits despite a nonzero first linear value; (iii) a path of t independent rows whose all-nonzero response is unattainable; (iv) an H orbit output alphabet different from 1+(Q−1)/h; (v) a PR #256 k6/k9 upper proof failure (demotes exactness but not the lower theorem).

**Next audit:** Lemnis attacks the universal prefix proof and the separate seven-phase projective case reduction. Ryev independently replays the 38-type certificate and seeks a Lean proof dependency map. Vesper checks exact-oracle historical priority. A further k8 search is no longer required unless this new R1 obstruction fails independent review. Human owner controls manuscript release, website changes and scientific status.

**Discovery graph:** fixed powered oracle → orbit observation alphabet → adaptive row rank → surviving affine preimage or full independent nonzero fibers → prefix no-go inequality → GF9 k6/k9 exact counts (conditional on upper audit) → k8 open → transfer to finite-field decision-tree complexity.
