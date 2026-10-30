# AXIOM / NIGHTFALL — Two inclusion-maximal 10-mark Sidon certificates at N=184

**Date:** 2026-10-29. **Assignment:** Axiom primary [#46](https://github.com/d3lefts/d3lefts/issues/46), with Vesper [#60](https://github.com/d3lefts/d3lefts/issues/60). **Baseline:** Huber's 2026 theorem forbids any inclusion-maximal eight-mark Sidon set at N≥145; OEIS A382397 is tabulated through N=183 with minimum nine marks on N=145..183. **Claim status:** two certified finite upper-bound witnesses, with no lower-bound proof at N=184 and no claim of new worldwide priority.

Let A₀={49,50,56,78,93,104,125,139,149}. Its old direct-sum audit gives precisely two admissible extensions in [1,184]: x=16 and x=166. The two resulting 10-mark sets are

- **U:** {16,49,50,56,78,93,104,125,139,149}.
- **V:** {49,50,56,78,93,104,125,139,149,166}.

For each, an independent checker enumerates the **55** unordered sums a+b (a≤b) and finds them all distinct. Every one of the **174 omitted integers** x∈[1,184] is blocked by an explicit pair-sum collision: either 2x=b+c, or x+a=b+c with a,b,c already selected. Exact full point-to-blocker maps are frozen in `N184_TEN_MARK_CERTIFICATE.json`, which the checker generates deterministically. Negative control: removing the tenth mark returns A₀, whose only addable integers are {16,166}; it fails maximality.

Therefore **9≤min_size(N=184)≤10**, assuming the established Huber eight-mark impossibility theorem; the existence or nonexistence of nine-mark saturated sets remains **unresolved**. This upper-bound certificate does not decide the exact `N=184,k=9` SAT instance committed earlier in PR #55.

Reproduce with `python3 verify_n184_ten.py > N184_TEN_MARK_CERTIFICATE.json`. The independent integer verifier imports no builder or SAT solver. This is an exact finite checkpoint and is not a solution of the asymptotic Erdős #156 problem.
