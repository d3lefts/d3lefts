# Oracle-matched minimum trusted checking: a decision-tree lower bound

**NIGHTFALL continuation | 13 November 2026 | Mathematical status: finite-model proof, classical adversarial-search mechanism**

The prior results optimize *which evidence to acquire*. This note separates two different costs of *reusing* that evidence after a change. A manifest-assisted verifier knows which dependencies changed, whereas a leaf-only verifier may obtain validity information only by explicitly checking individual proof leaves.

## Oracle contract (important)

Select n >= k+1 evidence rows whose nonempty dependency supports are pairwise disjoint. Every row is initially source-authenticated, adequate at baseline, but can be invalidated by changing one component of its own support. An adversary chooses a fixed update of at most k components **before** checking begins, so any selected set of at most k rows may be made invalid.

The leaf-only interface offers a trusted query Check(i) with known price t_i>=0, returning a signed current-version YES or NO. A deterministic zero-error algorithm **must output a fresh positive signed receipt**, not merely the name of a row inferred to be valid. It receives no authentic component-change manifest. Its cost is the sum of all Check query prices, including failed queries.

## Theorem E: exact minimum worst-case trusted checking expenditure

Let t_(1) <= ... <= t_(n) be the sorted leaf-check costs. The exact deterministic minimax expenditure is

    V(n,k) = t_(1) + ... + t_(k+1).

**Upper bound.** Query the k+1 cheapest rows, stopping upon the first signed YES. Since the supports are disjoint and at most k components change, at most k of those rows can be invalid. The worst-case paid cost is at most their sum.

**Lower bound.** Fix any deterministic zero-error strategy. Consider its hypothetical path in which each of its first k distinct queried rows returns signed NO. A fixed update hitting one component of each queried row realizes that path because supports are disjoint. The algorithm cannot output the required *positive signed receipt* after those k NO answers, so it must make a (k+1)st paid query. Those k+1 query costs sum to at least the globally cheapest k+1 costs. The fixed adversarial update can be selected from the known deterministic decision tree before execution. Together with the upper bound this proves equality.

**Scope caveat.** This theorem makes no lower-bound claim for randomized expected query cost, for a verifier allowed to output an unchecked row's identity, or for a verifier supplied with an authenticated complete update manifest. Those are different oracle contracts. It also does not apply if changing one component can invalidate multiple selected rows (unless other assumptions restore the same adversarial game).

## Certified manifest-assisted comparison

Suppose the same original proof leaves are fully authenticated, their version/dependency bindings can be re-used, and an authenticated, complete manifest of changed components is available. After verifying that manifest and that <=k components changed, the verifier can find an untouched row among the k+1 disjoint supports **without issuing any fresh leaf-check queries**. Its computation still includes manifest signature verification, set intersection tests, and checking that the earlier registered proof binding is valid; those operations are not free.

Thus the distinction is typed:

- Without a manifest, obtaining a *fresh positive attestation* requires the exact worst-case cost V(n,k).
- With a trusted manifest, the *additional leaf-check expenditure* is zero, subject to independent authentication and soundness of reused certificates.

This is a precise oracle-access separation, not a claim that all safety verification can be eliminated or that the underlying search-game lemma is unprecedented.

## Independent exact audit

A separately implemented finite minimax recursion enumerates optimal deterministic decision trees, compares them with the sorted-price formula, and checks 10,000 random instances (n<=8, 0<=k<n, exact Fraction costs). All cases matched. See [audit_trusted_queries.py](audit_trusted_queries.py).

## Prior art and next step

The combinatorial adversarial search principle is elementary; authenticated incremental proof reuse and proof-carrying evidence have extensive prior art. See Necula's proof-carrying code programme, Chaki et al. on assurance cases for proofs as evidence, and Diemert et al., *Incremental Assurance Through Eliminative Argumentation* (2023). The contribution **within this programme** is to identify the precise oracle access change needed for the evidence frontier to translate into verification-cost savings.

The next nontrivial target is the intermediate oracle: noisy, incomplete, or partially authenticated change manifests. A publishable theorem would need same-contract optimal upper/lower bounds with explicit adversarial failures and a checker that never silently upgrades uncertainty to authenticity.
