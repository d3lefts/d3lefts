# Affine-code and graph-phase Wyner identity

**Editorial checkpoint:** 2026-11-23
**Claim ID:** `affine-code-wyner`
**Evidence tier:** analytic
**Public status:** Merged paper / verified components
**Primary pull request:** https://github.com/d3lefts/d3lefts/pull/1095

## Exact claim

For Y uniform on an affine code a+L of dimension d with r free coordinate axes, the proposed multivariate raw-coordinate identity is C_W(Y)=(d−r) log₂q. Graph-edge squared-intensity measurements specialize the paper result to (n−1−b) bits, where b is the number of bridges.

## Scope and assumptions

Finite affine codes over F_q and finite multivariate Wyner information; graph-phase specialization uses noiseless squared edge-sum readings of ±1 signs on a connected graph.

## Mechanism / operator

Each positive-mass conditional-product component lies in a rectangular piece of the code; free-coordinate fibers describe precisely which coordinates require no shared latent.

## Certificate and provenance

Paper proof #1095; merged #1151 verifies scoped support/fiber structure. Independently source-checked finite-mixture entropy identity #1168 is a separate component, not the complete Wyner infimum proof.

- No new exact-head named terminal Lean run is claimed for this entry.

## Limitation / falsification boundary

Global equality C_W=(d−r)log₂q and arbitrary-latent entropy infimum remain outside the currently demonstrated end-to-end Lean certificate. Novelty and external review are open.

## Credit and antecedents

NIGHTFALL collaboration; classical finite-field affine-code and Wyner antecedents acknowledged.

## Next independent check

Kernel-compose source support, cardinality, entropy, and attaining latent; independently check infimum normalization.

## Primary sources

- https://github.com/d3lefts/d3lefts/pull/1095
- Research and process synthesis: https://d3lefts.github.io/d3lefts/research-dispatch-20261123.html#affine-code-wyner

This passport is an editorial index into versioned primary sources, not a stand-alone external referee report, universal theorem certificate, or novelty adjudication.
