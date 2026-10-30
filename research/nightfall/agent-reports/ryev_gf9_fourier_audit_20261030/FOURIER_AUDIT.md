# Ryev independent audit: a seven-sign GF9 Fourier obstruction without the 38-type case split

**Date:** 2026-10-30. **Research owner:** Devin J. Wright / NIGHTFALL. **Auditor:** Ryev (AI role), computationally and algebraically distinct from Axiom's PR #266 implementation. **Status:** R1 internal algebraic argument plus separate finite replay, awaiting non-author human mathematical review, priority comparison and owner decision. No result is presented as externally certified or first in the literature.

## Frozen model and target

Source: Axiom [PR #266](https://github.com/d3lefts/d3lefts/pull/266), Vesper [#257](https://github.com/d3lefts/d3lefts/issues/257). In K=GF(9), every legal query returns the *square* of a K-linear form, with no unpowered intermediate value. Inputs are all vectors of K^8, including zero and sparse vectors, modulo a *single global sign*. Every adaptive query costs one. Five output classes are possible per query: zero and four nonzero squares. Attempted depth: eleven.

**Audit target:** the sole unruled-out eight-query rank history in #266: seven independent queries, each with square output 1, followed by one dependent query. This node starts with 64 relative-sign words and one unconstrained GF9 coordinate. The weak five-bucket pigeonhole gives 13 words in a largest bucket (117 signal orbits), too few for the remaining-three-query obstruction (125 leaves). We require **14**, i.e. 126 signal orbits.

## Stronger lemma: a universal three-adic sign-projection identity

Let V be any finite-dimensional vector space over F3. Choose m coefficient vectors c_1,...,c_m in V, zero coefficients allowed. For every sign tuple eps in {+1,-1}^m form S(eps)=sum eps_i c_i. Signs are identified by *simultaneous negation*; their 2^(m-1) classes are well-defined, even when S=0. For a nonzero F3-linear functional lambda: V -> F3, let Z_lambda be the number of these global-sign classes with lambda(S)=0, and z_lambda the number of coefficients with lambda(c_i)=0.

Then the integer identity

    3 Z_lambda - 2^(m-1) = (-1)^(m-z_lambda) 2^z_lambda

holds for every m>=1.

**Proof without complex Fourier analysis.** Among the 2^m *raw* sign tuples, let A, B, C count lambda(S)=0,1,2. Simultaneous sign reversal gives B=C. Set F=A-B. Since A=2 Z_lambda and A+2B=2^m,

    F=(3A-2^m)/2=3 Z_lambda-2^(m-1).

For zero sign variables F=1. Appending c with lambda(c)=0 doubles A and B and therefore sends F->2F. Appending c with lambda(c) nonzero gives A'=B+C=2B and B'=A+C=A+B, hence F'=-F. Induction gives the displayed signed power of two. This is an exact integer induction in arbitrary dimension, not a complex-character or floating-point argument.

### The m=7, V=F3^2 corollary

The nine additive vectors of GF9 split into five global-sign output classes: zero and four projective lines. Write their bucket sizes as b_0,b_1,b_2,b_3,b_4 (sum 64). For each projective line l there is a nonzero lambda whose kernel is exactly that line. Thus Z_lambda=b_0+b_l, and the identity gives

    3 (b_0+b_l) - 64 = (-1)^(7-z_lambda) 2^z_lambda.

Suppose all five bucket sizes <=13. Because they sum to 64, the multiset must be {12,13,13,13,13}. If b_0=12 then b_0+b_l=25 for every l, making the left side 11. If b_0=13, a nonzero bucket of size 12 exists, and for its l the left side is again 11. Yet a signed power of two is never 11. Contradiction.

**Sharp result:** for every seven-term coefficient row, regardless of zero coefficients and linear relations, the largest legal squared-output bucket has **at least 14 relative-sign words**. The row with projective multiplicities (one zero, two coefficients on each of three different lines, none on the fourth) attains exactly sorted bucket sizes **14,14,14,12,10**. The finite 38-profile enumeration is therefore *unnecessary for the lower bound*; it remains useful as an independent witness census.

## Consequence for the fully adaptive eleven-query decision tree

At the first nonzero measurement choose square 1, fixing a global-sign anchor. For every subsequent independent queried row choose square 1; it doubles the surviving relative-sign palette and raises the row rank. For a dependent row choose a largest output bucket; it leaves at least ceil(N/5) sign words and does not increase rank. A compatible palette of N raw-relative-sign assignments at rank r yields N*9^(8-r) inequivalent signals because the anchored unpowered linear system has 9^(8-r) solutions.

Direct exact enumeration of 2^7=128 possible independent/dependent rank histories for the first eight queries leaves more than 5^3=125 compatible global-sign signal classes for all histories except **IIIIIIID** (seven independent rows, then one dependent). That exceptional path has 64 signs at rank seven before its eighth query. The seven-sign lemma upgrades its largest bucket from ceil(64/5)=13 to at least 14. As one coordinate remains free, the path retains at least 14*9=126 signal orbits, also exceeding 125.

Thus, **conditional on the rank/palette path invariant reviewed in Axiom #266 (independently rechecked here at the integer recurrence level), every adaptive eleven-query GF9 squared-linear design fails**. The existing proposed twelve-query upper construction is in Vesper PR #256; we have not independently reproved its universal all-support decoder in this audit. The candidate exact optimum A_GF9(8)=12 therefore remains R1/internal, with publication and priority review open.

## Independent checks, mutation tests and limits

Run from the repository root:

    python3 research/nightfall/agent-reports/ryev_gf9_fourier_audit_20261030/verify.py

The checker uses no GF9 multiplication and no producer scripts. It directly enumerates all 64 normalized sign words for all 5^7=78,125 coefficient sign-class tuples, re-evaluates four integer projection identities per tuple, verifies sharp minimum 14 and exactly 2,520 normalized attaining tuples, checks all 128 rank histories and the sole 117-orbit apparent exception, and tests the hypothetical (12,13,13,13,13) false ceiling. Negative controls retain zero-sum outcomes, disallow the nine-valued *unpowered* oracle, and check the legal five-class quotient.

**Logical boundaries:** This is a compact proof of the 14-word finite lemma plus a separate implementation of the rank recurrence. The full adaptive impossibility requires the semantic rank-path fiber invariant (unknown adaptive rows cannot access hidden signs), including early termination, which remains a proof-review dependency. The additive identity may be classical Fourier/code theory; novelty is unresolved. No external review, no Lean universal theorem, no new experimental outcome, no change to original field or query oracle, no production site change.

**Next falsifier:** an explicit adaptive path violating the rank-palette invariant, a seven-sign row with largest powered bucket <=13, or a valid 11-query complete decision tree with independently verified all-signal separation. Source/claim gating: Vesper and Lemnis independently assess correctness and scope; a human referee and dated priority comparison are required for promotion.
