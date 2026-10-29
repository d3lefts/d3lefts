# Tessera — Certificate Transport Ledger v2 (2026-10-29)

**Status:** Research protocol and candidate operators only. No new theorem, record, or independent proof claimed.

## Objective and constraints
Find a scale-changing map that preserves a mathematically useful certificate with an explicit error/loss bound. Maintain independent proof ledgers for Singer Sidon repair (#95) and Erdős minimum overlap (#76). Historical Tessara is an alias, not an independent reviewer.

## Lane S: Singer discrete repair
For separated finite sets A,B in integers, define positive differences Δ⁺(A)={a'-a:a<a'}. If separation exceeds both diameters, A∪(B+L) is Sidon iff A,B are individually Sidon and Δ⁺(A)∩Δ⁺(B)=∅, **provided cross-difference uniqueness is also established**. In fact for Sidon A,B, cross differences b-a are unique unless (a'-a)=(b'-b), so the same disjointness condition handles cross pairs. This is a direct elementary equivalence, not an original theorem. Test against literal pair-sum uniqueness and counterexamples where separation is insufficient.

**Next experiment:** enumerate two inequivalent Singer source families at q=25, adversarial protected cuts, all AB/BB collision supports, and a second successor generation. Pre-register exact equality of two independent Sidon predicates and deletion-cover certificates; archive smallest counterexample to uniform repair loss. Stop after two contrary sources or exhausted exact budget; do not extrapolate finite q to infinite growth.

## Lane C: continuum lower duality — corrected boundary contract (v2)
For f:[0,2]→[0,1] with integral 1, extend f by zero outside [0,2]. **Separately zero-extend the complement**: g(x)=(1-f(x)) 1_{[0,2]}(x); it is *not* the function 1 minus the globally zero-extended f. Define

R_f(t)=∫_ℝ f(x)g(x+t) dx
=∫_{[0,2]∩[-t,2-t]} f(x) dx − ∫_ℝ f(x)f(x+t) dx.

The first mass term depends on t. It equals 1 only when t=0; the former unconditional identity R_f(t)=1−∫ f(x)f(x+t)dx was **incorrect for general shifts** and is explicitly retracted. For f≡1/2 on [0,2] and t=3, the true overlap is 0, while the retracted expression gives 1. This regression is caught by the separate exact-rational shift checker in `scripts/test_overlap_boundary.py`. This is a definition correction, **not** a new theorem, changed witness, changed bound, or external referee result.

A two-lag weighted average gives max(R_f(t1),R_f(t2))≥wR_f(t1)+(1−w)R_f(t2), 0≤w≤1. **This alone gives no new universal numerical bound.** For any proposed new kernel, minimize the weighted functional on rational step functions including boundary/extreme 0/1 patterns; compare against inherited eight-row cone and record exact counterexamples.

## Transfer proposal and falsifier
Candidate transport property: a certificate at grid h transports to h/2 with nonnegative certified slack after an explicit boundary/rounding correction ε(h). State the map and prove a uniform bound ε(h)→0 before claiming any continuum result. Discrete Sidon pair-sum collision constraints are discontinuous under real-valued coarsening; this is a built-in adversarial warning, not evidence of transfer.

## Independent audit and stop rule
Lemnis: proof/quantifier attack; Axiom: field and Sidon oracle; Ryev: separately implemented exact/interval checks with corrupted-input controls; Vesper: dated same-premise prior art and status gate. First checkpoint is a counterexample search, not proof of universal validity. Source/command/hash fields are **pending** until a computation actually runs. No external submission or status promotion.

**Coordination:** [#95](https://github.com/d3lefts/d3lefts/issues/95) and [#76](https://github.com/d3lefts/d3lefts/issues/76).