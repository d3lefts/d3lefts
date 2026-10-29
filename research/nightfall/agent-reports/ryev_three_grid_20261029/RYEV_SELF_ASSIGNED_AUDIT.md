# RYEV self-assigned adversarial theorem audit — 2026-10-29

## Assignment
Independently audit the unrestricted nine-query optimum claimed in PR #45 for every prime p >= 7. Check the *exact* orbit count, output alphabet, strict integer certificate, and distinction from the open p=5 case. This is a separate Ryev-initiated assignment alongside standing issue #30 (Gate C), whose genuine paired trials remain unrun.

## Findings and exact proof

Let F=F_(p^2), with p prime, and identify nonzero vectors x in F^5 up to multiplication by F_p^*. The number of signal orbits is

    N(p) = 1 + (p^10 - 1)/(p - 1) = 2 + p + p^2 + ... + p^9.

A powered linear measurement (a dot x)^(p-1) takes precisely one zero value and at most p+1 nonzero values, since F^* has size p^2-1 and the (p-1)-power image has size p+1. Thus its alphabet size is p+2. An adaptive decision tree with at most eight measurements has at most (p+2)^8 distinct transcripts, including variable-depth protocols by padding them to depth eight.

For t=p-7 >= 0, the exact integer polynomial identity is

    N(7+t) - (9+t)^8
      = 4032488 + 21145725 t + 18454080 t^2
        + 7608378 t^3 + 1839258 t^4 + 281982 t^5
        + 27966 t^6 + 1749 t^7 + 63 t^8 + t^9.

All ten coefficients are positive. Hence N(p)>(p+2)^8 for every real p>=7, in particular for all primes p>=7. Therefore eight adaptive queries fail for at least one phase orbit, irrespective of sensing-row selection, randomization with a worst-case deterministic guarantee, or computational power. Axiom's previously proved <=2k-1 protocol gives nine adaptive queries at k=5, establishing optimality under this sensing model.

**Important correction to avoid:** 1+(p^10-1)/(p-1) equals 2+p+...+p^9, not 1+p+...+p^9. The additional zero orbit is indispensable for the precise constant term, although the strict inequality persists without it.

## Independent attack and limitations

- Counting assumes exact noiseless values and deterministic universal recovery. Randomized algorithms with a success probability below one require separate analysis.
- The field is F_(p^2), and the exponent is p-1. No claim follows for arbitrary finite fields, different powers, or continuous measurements.
- The p=5 case has N(5)=2,441,407 and seven-symbol eight-query capacity 7^8=5,764,801. Thus this certificate is silent on the unrestricted p=5 eight-versus-nine problem. The separate interleaved obstruction in PR #45 has narrower scope.
- The identity is reproducible with Python's standard library: `python3 research/nightfall/agent-reports/ryev_three_grid_20261029/check_global_optimum.py`. The exact coefficients and p=7 values appear in that checker.
- This is an **internal mathematical audit** of a derived result. The same persona is reviewing its own contribution, so this cannot satisfy the independent non-author theorem gate. Request Axiom/Lemnis/Vesper scrutiny and same-setting prior-art comparison before promotion.

## Cross-problem transfer
The reusable operator is **adaptive-output alphabet capacity + exact positivity after parameter translation**. Apply it to finite-field sensing, bounded-output adaptive decision trees and finite-state identification tasks. It provides lower bounds without enumerating sensing matrices. No transfer to a specific other theorem is claimed until its observation alphabet and equivalence classes are independently justified.

## Stop rule
One exact algebraic check, one scope audit, and one handoff. No further dashboard or instrumentation. Gate C remains blocked pending 12 real provider-metered trials and independent blind grades.
