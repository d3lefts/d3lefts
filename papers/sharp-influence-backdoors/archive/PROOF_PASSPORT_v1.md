# Proof passport — 12 November 2026

## Objective
Standalone, 15–20-page analytical paper proving quadratic influence and adaptive recovery on arbitrary independent product spaces, without dependency on the November 2026 all-degree Boolean-cube result.

## Model/assumptions
Independent product of arbitrary measurable probability spaces (completed product permitted); real scalar or bounded real-Hilbert output; degree at most two **in the Hoeffding interaction decomposition**, not arbitrary metric smoothness; known prior and target; whole-coordinate classical queries. Quantum application assumes independent locally prepared states, faithful product average on support, positive local *SLD* Gram visibility on entire active centered contrast spaces.

## Core proof chain
- Four-corner even/odd coupling on disjoint interaction edges gives matching budget <=4B.
- Product Markov-noise interpolation and coordinatewise switching polynomial yield `sum_i ||h_i||_2 <= 2(1+sqrt2)B` and `sum_i E||U_i|| <=8B`.
- Descending-edge matching assigns all pair kernels to endpoints; Hilbert fourth moment and interpolation give `Var(f) <= (10+2sqrt2)(1+sqrt3)B sqrt(M)`.
- Rademacher sign compression gives `V(G) <= D2*B*sqrt(3r*M)`.
- Degree-weighted posterior ANOVA potential has exact conditional drift equal to resampling influence; reciprocal telescoping gives `12*C2*r*B^2/eta` observation upper bound.
- Independent rank/accuracy lower and addressing separation prove worst-case scale and genuine role of adaptivity.
- Finite-partition approximation and summable-influence superlevel maximum attainment transfer core proof to any input cardinality.

## Verification this session
- Full 17-page LaTeX PDF compiled twice with no unresolved references or overfull boxes; all pages rendered and sample contact sheet inspected.
- `python3 -I check_quadratic_models.py` passed exact rational finite-model tests (see `EXACT_CHECKER_RESULTS.txt`).
- Two manuscript proof-presentation repairs: affine-output projection in rank lemma and scalar vs rank-r constant for one-query error-probability result.
- Web prior-art check: 2005 OSSS, 2008 Blais-O'Donnell-Wimmer, 2026 GMNR, Turturean, and 2023/2026 completely bounded polynomial results.

## Unproved/uncertified
- End-to-end Lean proof of independent quadratic theorem and observer.
- Independent specialist proof review, full global novelty audit (notably categorical Grothendieck and bilinear tensor norms).
- Efficient implementation of adaptive selector, extension to arbitrary correlated sources or degree >=3 at exponent 2.
- Any stronger conjectural qubit trine visibility bound.

## Cheapest next decisive audit
Have an independent mathematician rederive matching coupling, verify vector-valued fourth moments and affine rank reduction, test posterior drift on nontrivial heterogeneous categorical products, then compare the source inequality against existing categorical bilinear Grothendieck theorems. One invalid lemma demotes all downstream adaptive/quantum corollaries.
