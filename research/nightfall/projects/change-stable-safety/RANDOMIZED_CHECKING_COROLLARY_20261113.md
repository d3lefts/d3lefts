# Randomized trusted leaf checking: exact equal-cost minimax expectation

**NIGHTFALL addendum, 13 November 2026 | Elementary negative-hypergeometric adversarial-search identity**

This complements [the deterministic trusted-checking bound](TRUSTED_QUERY_LOWER_BOUND_20261113.md) and prevents the incorrect extension of that bound to randomized *expected* work. The identity is an author-side synthesis within the safety-evidence oracle model, not a claim to have invented the underlying probability theory.

## Contract

There are n >= k+1 independent baseline-adequate evidence witnesses, with pairwise-disjoint nonempty component supports. An update chosen before checking can invalidate any set of <= k witnesses, at one distinct changed component each. A trusted query Check(i) returns a signed yes/no current-version receipt and costs one unit. The algorithm must output a positive signed receipt. Random coins are independent of the fixed update. Cost is the number of signed checks, and the minimax objective is the worst case, over fixed admissible updates, of the expected number of checks. A manifest is *not* supplied.

## Theorem F — Randomization changes the information-cost frontier

The minimax expected number of checks among all zero-error randomized algorithms is exactly

    V_random(n,k) = (n+1)/(n-k+1).

By contrast, the deterministic minimax *worst-case* number is k+1.

**Achievability.** Choose a uniformly random permutation of all witnesses, then check them until receiving the first YES. If exactly k witnesses were invalidated, the first YES is the minimum order position among the n-k good witnesses. The expectation of the minimum of a uniformly chosen (n-k)-subset of positions {1,...,n} is (n+1)/(n-k+1). Fewer invalidated rows can only reduce that expectation. Hence the worst-case fixed update costs exactly this value.

**Lower bound.** Choose the adversarial update from the distribution that invalidates a uniformly random k-subset of the n rows. For any deterministic adaptive strategy, conditional on j negative answers the remaining invalid set is a uniformly random (k-j)-subset of as-yet-unqueried rows. Thus the probability of the next YES depends only on n,k,j, not on which unqueried row is selected. The distribution of the stopping index is consequently the same negative-hypergeometric distribution as in a fixed-order search; its expectation is (n+1)/(n-k+1). A randomized strategy is a distribution over deterministic strategies; averaging the lower bound shows that at least one fixed admissible update attains an expected cost no smaller than this value. Combining both directions gives equality.

**Separation:** When n=k+1, deterministic worst-case checking costs k+1 units whereas randomized minimax expected checking costs (k+2)/2. This does *not* improve worst-case path cost or eliminate the need for trustworthy returned receipts.

## Exact finite audit

A separate script [audit_randomized_queries.py](audit_randomized_queries.py) exhaustively enumerates every invalid k-subset and every ordering for all n from 1 to 7, comparing the mean stopping rank with the exact Fraction (n+1)/(n-k+1). All cases passed.

## Boundary and next operator

For unequal check prices the problem is a more substantive weighted adaptive testing game; applying the equal-price answer silently would be invalid. For partially authenticated or noisy change manifests, the relative costs of manifest validation and leaf-check calls must also be modeled and compared under a single oracle contract. That is the natural next research objective.

No priority, external peer-review, proof-assistant, or real-world deployment claim accompanies this elementary minimax identity.
