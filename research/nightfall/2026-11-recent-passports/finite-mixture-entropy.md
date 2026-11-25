# Finite-mixture Shannon chain identity

**Editorial checkpoint:** 2026-11-23
**Claim ID:** `finite-mixture-entropy`
**Evidence tier:** merged-lean
**Public status:** Merged / 20 checks green
**Primary pull request:** https://github.com/d3lefts/d3lefts/pull/1168

## Exact claim

A finite-sum Shannon entropy identity converts posterior conditional entropy into output entropy minus expected component entropy, including zero-mass atoms.

## Scope and assumptions

Finite normalized mixtures and finite alphabets; exact source-independent algebraic identity.

## Mechanism / operator

Exact weighted entropy expansion using finite Fubini and zero-atom-safe mass normalization.

## Certificate and provenance

Merged #1168: 20/20 exact-head checks, pinned Lean compile, independent leanchecker and axiom allowlist. Run #45254493929, source Git blob 01a3923d5add628ce047fc2e60422a3186c1f85a.

- Named declaration: `Nightfall.FiniteMixtureEntropyChain.finite_mixture_entropy_chain`
- Exact-head source revision: `d72bbf3470f6b69371524b9e4eeabb4ae01e7b05`
- CI run: https://github.com/d3lefts/d3lefts/actions/runs/45254493929

## Limitation / falsification boundary

Does not alone establish multivariate Wyner information, affine-code infimum, global optimization or novelty.

## Credit and antecedents

NIGHTFALL formalization using Mathlib finite Shannon identities.

## Next independent check

Compose with original Route 1 mutual-information convention, support cardinality and attaining-latent witness.

## Primary sources

- https://github.com/d3lefts/d3lefts/pull/1168
- Research and process synthesis: https://d3lefts.github.io/d3lefts/research-dispatch-20261123.html#finite-mixture-entropy

This passport is an editorial index into versioned primary sources, not a stand-alone external referee report, universal theorem certificate, or novelty adjudication.
