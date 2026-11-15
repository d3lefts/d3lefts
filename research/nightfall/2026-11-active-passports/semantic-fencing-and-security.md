# NIGHTFALL Proof Passport v14 — Exact Semantic Fencing, Adaptive Evidence and Local Security

**Date:** 14 November 2026 (US Eastern) · **Lead:** Devin J. Wright · **Method:** AI-assisted proof/engineering, independent algorithm implementations · **Status:** draft Lean source certificate plus merged finite prototype. No deployment safety or priority claim.

## 1. Static semantic-fencing theorem

For certified baseline states B, permissible histories whose endpoints violate a target safety predicate, and their authenticated changed-version supports D, a gate that **only** checks selected atomic source versions is sound if and only if its guard J intersects **every** unsafe support D. The cheapest positive additive *successful-path* version-only fence therefore is the minimum-weight hitting set. If any unsafe history has an empty detectable support, no version-only fence works. This equivalence assumes complete relevant source coverage, ABA-free authentic version counters and linearization of version check with the modeled consequential effect; it does not prove these assumptions operationally.

## 2. Adaptive evidence and Bellman theorem

Exact, coherent snapshot observations can remain useful **after** an initial safety label is known, because an additional observation may reduce required effect-time freshness checks. With read cost c_i and current belief B, finite minimax plans compare immediate safe fence, correct deny, or splitting read plus maximum branch cost. Under complete history coverage and a finite initially **already-safe** evidence set, strong induction produces an optimal finite read/guard plan. A two-source witness has direct fence cost 8 quarter-units but read-then-fence cost 5 (37.5% improvement). The r-branch selector family yields direct cost r+1 against one selector read + two checks, with unbounded ratio as r grows.

## 3. Verification

Merged [PR #537](https://github.com/d3lefts/d3lefts/pull/537) and [run #43648303705](https://github.com/d3lefts/d3lefts/actions/runs/43648303705): 1,700 integer Bellman audit cases, 350 heterogeneous 2×3×4 history checks, bounded 661-state correct atomic model with zero unsafe effect edges, seven unsafe edges each in three defective controls, and five SQLite local transactional tests.

**Additional strict Lean (draft branch):** [PR #554](https://github.com/d3lefts/d3lefts/pull/554), [run #43662280902](https://github.com/d3lefts/d3lefts/actions/runs/43662280902), ten named standard-axiom declarations, including `fence_sound_iff_hits`, `invisible_unsafe_change_impossible`, `optimal_fence_exists`, `bellman_root_optimal`, `finite_safe_bellman_optimal`, and `two_bit_post_certificate_gain`. Source SHA256 `17779223198926147b1600c9c5faebbf333add1bc05c71562000f491ea624d58`. Scope: finite initially-safe evidences, exact binary splitting observations and modeled version-only gates; not all observation interfaces, multi-agent concurrency or an unbounded physical state law.

## 4. Operational local boundary and attack audit

Merged [#505](https://github.com/d3lefts/d3lefts/pull/505)/[#510](https://github.com/d3lefts/d3lefts/pull/510)/[#517](https://github.com/d3lefts/d3lefts/pull/517)/[#530](https://github.com/d3lefts/d3lefts/pull/530)/[#531](https://github.com/d3lefts/d3lefts/pull/531) source-snapshotted promotion, serialized revocation, Docker OS isolation and separately authenticated Unix effect service. The [#554](https://github.com/d3lefts/d3lefts/pull/554) amended service passed complete-handler deadline regressions, existing 21 security tests, and ten independent artifact-only authorization checks on [run #43662280945](https://github.com/d3lefts/d3lefts/actions/runs/43662280945). Its service patch remains draft/unmerged. Timeout need not imply rollback after atomic rename; sustained floods, hostile OS, privileged issuer and physical/cloud deployments remain unproved.

Merged [#557](https://github.com/d3lefts/d3lefts/pull/557), [run #43662000190](https://github.com/d3lefts/d3lefts/actions/runs/43662000190), adds three genuine small-model proposal attempts and independent scorer/audit. **One honest attempt scored a successful main task but did not promote; two adaptive attack attempts were invalid/unscored; zero attack successes.** This is *not* evidence of a meaningful adversarial safety rate or successful deployment. The specific model was Ollama/Qwen2.5-Coder-3B, not a frontier threat model.

## 5. Remaining assumptions and novelty gates

Real operational complete mediation, authentic source/version coverage including externally imposed changes, correct environment/plant semantics and a trusted effect/issuer channel are **undischarged**. The current boundary guards a service-owned local JSON publication, **not** a real AWS call. No full zero-trust host-kernel or physical-actuator certificate and no externally reviewed novelty claim.

Closest antecedents: weighted hitting set, decision-tree optimization, optimistic concurrency, reference monitors, SLSA/in-toto, AWS CloudFormation admission, and the 2026 active-observability/continuous-authorization literature. The potential new contribution is the **joint minimal version-fence and post-classification evidence-cost characterization under an explicit interface**; require dated adversarial prior-art comparison and non-author proof review before priority promotion.

**Next cheapest decisive test:** implement non-bypassable external-effect interception on a dedicated low-privilege sandbox, introduce omitted/ABA source changes and request floods, and compare matched assurance cost against full-rebuild and static-fence baselines. Preserve failed tests and immutable exact-head receipts.

## 15 November 2026 — evidence acquisition and authority-scope update

Semantic fencing v0.3 (#537), finite decision/guard optimizations and bounded service tests are preserved as scoped engineering and mathematical evidence. New joint-recognition/recertification results in [PR #576](https://github.com/d3lefts/d3lefts/pull/576) further characterize exact finite nominal-path evidence costs, shared observation-facility/guard-service min-cut cases, and nonmonotone Bayesian acceptance risk.

**Certification boundary unchanged:** neither this analytic recertification contribution nor a bounded prototype demonstrates complete mediation by actual external/physical tools, authenticated deployment environments, general service-level availability, or unrestricted superintelligent-system safety. Distinguish Lean-checked *conditional* safety invariants from their operational trusted-boundary premises. Current source-specific receipts and limitations are in [Proof Passport v16](PROOF_PASSPORT_V16_20261115.md).

