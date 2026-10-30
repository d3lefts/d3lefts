# Adaptive rank–orbit prefix obstruction for finite-field powered measurements

**Checkpoint:** 2026-10-30. **Research owner:** Devin J. Wright. **Construction and proof draft:** Axiom (AI research role). **Assignment:** Vesper's #257. **Scientific stage:** R1 internally derived mathematical theorem candidate, exact finite regression, and external mathematical review/priority unresolved. Do not claim worldwide originality or independent human refereeing.

## Problem, baseline and stopping rule

Let K be a finite field of size Q, H ≤ K* a multiplicative subgroup of order h>1, and observe arbitrary adaptively selected K-linear forms through exactly the oracle (a·x)^h, for unknown x∈K^k modulo ONE common H scalar. Every query is charged, including zero measurements. Zero signal and all support patterns belong to the feasible set. The exact output alphabet is L=1+(Q−1)/h, including the zero value.

**Closest source checked:** Vesper's #257, PR #256 gives a candidate upper A(k,r)≤k+ceil((k−1)/r) over GF(3^r) under the square oracle, with source-comparison to Borello–Schmid–Scotti (JCTA 214, 2025) on intersecting codes and other phase-retrieval models. BSS addresses fixed measurements, not the present adaptive lower-bound branch construction. Web search on 30 Oct 2026 found related finite-field/phaseless literature without locating this exact prefix argument. A targeted search is not worldwide priority clearance.

**Objective:** decide whether eight queries recover every GF9^6 signal modulo sign. Existing candidate upper is nine; output counting only rules out seven. An additional k9 test is included because it costs a single exact inequality. Compute budget: source-independent finite enumeration of the 531,441 six-coordinate field vectors and symbolic integer inequalities; stop before solver/random search. Independent audit: Lemnis mathematics, Ryev distinct verification and Lean dependency map, Vesper historical comparison.

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

The upper theorem remains independently reviewable. **k=8** remains OPEN between 11 and 12 with this method. This prefix method generally yields a finite additive improvement over alphabet counting, not a new asymptotic linear lower-bound coefficient.

### Exact finite verification and checker contract

- [check_prefix.py](check_prefix.py) performs all strict inequalities as integers and constructs direct sign-orbit sets using GF3[u]/(u²+1). The actual independent-four-coordinate output (1,1,1,1) has exactly **648** global-sign classes with two free GF9 coordinates.
- The dependent-fourth-row example fixes the first three coordinate squares equal to 1 and measures the square of x1+x2+x3. Its fourth-output buckets are **729** and **2187** sign classes. A dependent row can concentrate classes; our proof uses a minimum Q^(k−r) affine fiber, never a fictitious all-nonzero h-factor.
- [independent_gf9.py](independent_gf9.py) independently represents the field as GF3[v]/(v²+v+2) and visits all **531,441** six-coordinate vectors. It counts global-sign classes directly for the same two prefixes, including zero-powered outcomes and a different modular reduction formula.
- Negative control: using six alphabet symbols instead of the legal five makes 6^4=1296 greater than 648, so a false output-alphabet count cannot justify the reported k6 obstruction. Both scripts fail loudly on changed counts.

Scripts require only Python 3.12. CI prints their SHA-256 values. These computations certify small exact fibers, **not** a mechanically formalized universal theorem or historical novelty.

## Distinctness, limitations and scientific review

Prior work: [Borello, Schmid and Scotti, The geometry of intersecting codes (2025)](https://arxiv.org/abs/2406.04034) develops fixed linear-code geometry; [Vesper #257](https://github.com/d3lefts/d3lefts/issues/257) provides the GF9 adaptive upper and fixed-code baseline, with [PR #256](https://github.com/d3lefts/d3lefts/pull/256) carrying the pending theorem proof. The complement property and alphabet counting are established background. The present mechanism combines **an adversarial adaptive path and two separate linear-rank orbit-fiber formulas**. Whether this criterion or the exact k6/k9 values appear in old finite-field decision-tree literature remains unresolved. No published originality, improvement over historical source or flagship promotion is asserted.

**Falsifiers:** (i) an eight-query GF9 k6 decoder with a full verified transcript certificate; (ii) a compatible dependent path with fewer than Q^(k−r) orbits despite a nonzero first linear value; (iii) a path of t independent rows whose all-nonzero response is unattainable; (iv) an H orbit output alphabet different from 1+(Q−1)/h; (v) a PR #256 k6/k9 upper proof failure (demotes exactness but not the lower theorem).

**Next audit:** Lemnis attack the adaptive branch quantifiers, premature termination and linear-lift counting; Ryev independently check all GF9 rows with a nonstandard field basis and create a Lean proof dependency graph; Vesper perform a dated exact-oracle priority audit. A sharper adaptive branch invariant, not more random rows, is required for k8 m11. Human owner controls manuscript release, website changes and scientific status.

**Discovery graph:** fixed powered oracle → orbit observation alphabet → adaptive row rank → surviving affine preimage or full independent nonzero fibers → prefix no-go inequality → GF9 k6/k9 exact counts (conditional on upper audit) → k8 open → transfer to finite-field decision-tree complexity.
