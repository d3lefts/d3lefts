# NIGHTFALL — Exact Semantic Fencing and End-to-End Conditional Authority (v0.3)

**Research direction:** Devin J. Wright · **Method:** AI-assisted construction, proof analysis and finite checkers · **Date:** 2026-11-14  
**Status:** conditional paper proofs plus same-session independent finite algorithms and bounded transactional demonstrations. **NOT** Lean certified; **NOT** externally/non-author reviewed; **NOT** a verified physical or distributed deployment; worldwide originality **unresolved**.

## Objective and assumptions

Minimize total authenticated observation and effect-time enforcement cost for a changing, nonlinear, heterogeneous, interacting autonomous system while preserving an explicit safety invariant.

* Finite exact-cost model: configurations `X=∏_i X_i`, safety predicate `S_a⊆X` for proposed consequential effect `a`; possibly coupled source constraints and a coherent authenticated baseline evidence set `B⊆X`. An allowed history `p` starts from `b(p)∈B`, ends in `x(p)`, and records every source version changed via `D(p)`.
* Source version counters are authenticated, monotone/ABA-free, and advance for **every relevant change**, including policy, credentials, authority and externally imposed state changes. Histories include all possible unsafe transitions; a missing source invalidates the application.
* Each effect is mediated by a trusted gate that atomically compares selected source versions **and** commits the modeled effect at one linearization point. No bypass is permitted. The gate cannot re-evaluate values or the safety predicate; it only performs version-equality tests. A failed check aborts.
* Cost bounds count additive positive read and version-check prices under this particular interface. Evidence reads are exact from the **same coherent snapshot**; concurrent edits during acquisition require a larger protocol model. Exact classification of original snapshot outcomes is required (the always-deny trivial policy is excluded).

## Theorem 1 — Exact version-only semantic fence

Let `U_a(B)={p: b(p)∈B, x(p)∉S_a}` and `H_a(B)={D(p):p∈U_a(B)}`. For `B⊆S_a`, an atomic version-only fence `J` is sound for every permitted history **iff** `J∩D ≠ ∅` for every `D∈H_a(B)`.

Hence its optimal successful-path cost is exactly

```text
G_a(B) = min_{J⊆I} [ Σ_{i∈J} w_i | ∀D∈H_a(B), J∩D≠∅ ].
```

If an unsafe history has `D=∅`, no such fence is sufficient (cost `+∞`).

**Sufficiency:** every accepted commit has unchanged versions for `J`. An unsafe accepted history would define a hyperedge avoiding `J`, contradiction.  
**Necessity:** an unsafe history avoiding `J` gives exactly the same version-equality results as the unchanged, safely granted history; a version-only gate accepting that unchanged history accepts the unsafe one.  
**Matching adaptive lower bound:** on the no-change execution, every test result is "unchanged"; the set tested along this accepting transcript must hit each unsafe hyperedge. Early aborts can reduce reject costs, but do not reduce the *worst-case successful-path* minimum.

This characterizes a **restricted guard design space**, not all possible verification methods.

## Theorem 2 — Exact joint evidence/enforcement minimax

For finite worlds, an exact observation `o_j:X→Y_j` costs `c_j>0` and splits `B` into nonempty fibers `B_{j,y}`. Define `h(x)=1` iff `x∈S_a`. The optimal worst-case total (coherent-snapshot observation + successful-commit fence) is

```text
W(B) = min(
  T(B),
  min_{j splitting B} [ c_j + max_{y∈o_j(B)} W(B_{j,y}) ]
)
T(B) = 0       if h(B)={0}, deny correctly
       G_a(B)  if h(B)={1}, grant with safe fence
       +∞      if h is nonconstant on B.
```

Informative observation shrinks finite `B`; induction over `|B|` proves the recurrence and matching adaptive lower bound. Crucially **observations can remain optimal after the initial safety label is already constant**, because they lower the future fence price.

### Exact two-source separation

Sources are bits. `S_a=X\{11}`; coherent baseline `B={00,01,10}` is already certified safe. Each source version check costs 1; reading either baseline bit costs 1/4. Immediate minimum fence costs 2. Reading one bit and fencing the other costs `1/4+1=5/4` in both observation outcomes: an exact 37.5% gain over stopping when classified.

### Unbounded family

Selector `s∈{1,…,r}` with r branches; the unsafe predicate is simultaneously selector- and selected-branch-sensitive. The initially certified-safe evidence set requires checking all r branch versions and the selector (cost `r+1`), while one authenticated selector read (cost `ε`) allows checking just the selector and selected branch (cost `2+ε`). Ratio `(r+1)/(2+ε)→∞`. This is an *interface-relative* separation, not a universal bound on physical recertification expense.

## Theorem 3 — Conditional perpetual safety

Let `K` be a safe invariant, and for each protected effect `a` let `S_a` imply that every modeled `a`-successor from `K` remains in `K`. Let trusted environmental and fallback steps also preserve `K`. If every consequential agent effect is mediated, evidence is sound/current, source changes are complete/ABA-free, and checking/commit is atomic, then every execution from `K` stays in `K`, regardless of agent policy, intelligence, or internal computation. Proof: induct on the linearized transition trace. This **does not** certify completeness of physical-world instrumentation, actuator mediation, external resources or a particular distributed transaction implementation.

**Liveness limitation:** an adversary repeatedly invalidating relevant sources may prevent any effect from committing. Safety alone does not guarantee progress. Unbounded forced recertifications with positive prices may give infinite undiscounted cost.

## Reproduction, provenance and limitations

The complete session bundle is SHA-256 `36dc45bfd81e1a8d1b9a6e7fb3b83d10638589b0d9f07e54f805e5283c1e01a7` (original conversation artifact). Re-ran locally 2026-11-14:

* 1,700 independently implemented finite Bellman checks, with 61 strict post-label gains.
* 350 heterogeneous 2×3×4 source-history audits.
* Selector separation r=2..6, exact model results.
* Atomic gate bounded interleavings: 661 states; 1,186 transitions; 123 modeled commits; 0 unsafe. Three broken variants each admit seven unsafe effect edges.
* Five real SQLite single-database transactional tests: coherent guarded commit and ABA rejection, plus intentionally failing stale/missing/split-check variants.

These computations are finite and do **not** constitute independent human review or a Lean proof. The SQLite prototype models transactionally recorded effects, not physical actuators.

### Strongest antecedents and priority risks

* He and Yu, *Cognitive Admission Control* (2026), https://arxiv.org/abs/2609.16313.
* Shajari, *Assurance-Conditioned Continuous Authorization* (2026), https://arxiv.org/abs/2611.05632.
* Liu, Tyszberowicz, Beckert, FASE 2026, https://doi.org/10.1007/978-3-032-22774-4_10.
* Zhang and Xu, *Certified Task-Conditioned Active Observability* (2026), https://arxiv.org/abs/2609.28520.
* Xin Heng, *Global Coherence* (2026), https://arxiv.org/abs/2610.02036 — **especially close** adaptive-context, versioned provenance, and atomic-commit antecedent.
* Classical optimistic concurrency, predicate validation and weighted hitting set.

**Do not claim** adaptive observation, incremental repair, or source-versioned effect-time enforcement as originally discovered here. The narrower candidate for priority review is **matching minimal semantic-version-fence cost jointly optimized with post-certification observation**, especially the unbounded price separation.

**Next decisive experiment:** independently changing, source-matched services or authentic Tennessee Eastman simulator logs; measure sensing, planning, synchronization, checking, commits, aborts and retries under adversarial races. Compare full rebuild, dependency slice, semantic static fence and joint policy at matched safety obligations. Mechanize the conditional proofs in pinned Lean. Record non-author objections.

This is an archival research record, not a declaration of deployment safety or publication-level novelty.
