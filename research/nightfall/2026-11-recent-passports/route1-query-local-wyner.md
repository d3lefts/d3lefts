# Route 1: query-local Wyner information transfer

**Editorial checkpoint:** 2026-11-23
**Claim ID:** `route1-query-local-wyner`
**Evidence tier:** analytic
**Public status:** Merged paper / terminal Lean open
**Primary pull request:** https://github.com/d3lefts/d3lefts/pull/1150

## Exact claim

A b-local encoding with r-query recovery of each latent coordinate transfers the Route 1 simulator to original observed-coordinate queries at depth r·q. A duplicated-source family separates raw ambient Wyner information from latent information by a growing gap.

## Scope and assumptions

Bounded degree-d observed targets, explicitly finite source and access model, component-wise b-local encoding, source TV slack; general-latent Route 1 core already formalized separately in #970.

## Mechanism / operator

Pull each observed degree-d cylinder through a b-local map (degree at most bd), then substitute a costed deterministic adaptive decoder for each latent query.

## Certificate and provenance

Paper argument in merged #1150 and separate exact finite cylinder check. Earlier Route 1 named Lean theorem #970 is a dependency, not a certificate for this transfer. End-to-end b-local candidate #1157 was closed unverified.

- No new exact-head named terminal Lean run is claimed for this entry.

## Limitation / falsification boundary

No exact-head kernel certificate for the b-local terminal; the information-gap example is not a lower bound on optimal original-oracle query complexity, and no efficient classical runtime is shown.

## Credit and antecedents

NIGHTFALL paper extension of earlier Route 1 #970 and classical Wyner information.

## Next independent check

Reopen source-exact b-local DTree, degree-pullback, and final terminal under a green Lean+leanchecker receipt; independently audit the physical query interface.

## Primary sources

- https://github.com/d3lefts/d3lefts/pull/1150
- Research and process synthesis: https://d3lefts.github.io/d3lefts/research-dispatch-20261123.html#route1-query-local-wyner

This passport is an editorial index into versioned primary sources, not a stand-alone external referee report, universal theorem certificate, or novelty adjudication.
