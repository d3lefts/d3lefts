# Source-matched Bellman policy passports for The Price of Permission

**Status:** Small finite exact construction with proposed Lean soundness bridge. The exact original source head and CI status are recorded in `docs/proof-object-passport.json`; do not replace pending status with kernel-checked until that specific run passes. No universal physical-world authority, mathematical priority, or non-author external review is implied.

## Recovering existing artifacts before adding an operator

- `research/nightfall/assurance/semantic-fencing-v0.3/semantic_fence.py` already implements the relevant joint observation/guard Bellman solver. Its original `joint_value` is our **untrusted certificate generator**.
- `research/nightfall/assurance/semantic-fencing-v0.3/independent_audit.py` already independently checks budgets, 1,700 synthetic instances, and the celebrated post-certification example.
- `research/nightfall/formalization/agent_safety/SemanticFencing.lean` already proves `finite_safe_bellman_optimal` abstractly and the exact two-source improvement `two_bit_post_certificate_gain`. There was no need to rediscover either theorem.
- `research/nightfall/price_permission/PRIMAL_DUAL_FENCE_OPTIMALITY_20261117.md` and `PricePermissionFenceDual.lean` certify a **static** model-bound fence by matching primal and dual values. This is a different action space from adaptive observation.

## Mechanism: a lower potential and a matching policy on the *original* worlds

The source model declares two binary versioned sources, initial safe states `B={00,01,10}`, unsafe final state `11`, exact read prices `(1,1)` and guarded version-check costs `(4,4)`, measured in quarter-units. The original transition model permits every baseline-to-final pair and records the set of changed coordinates via XOR. It assumes trusted atomic effect-time version comparison, complete state capture, authenticated ABA-free versions, immutable coherent snapshot observations, and exact Boolean reads.

All 7 nonempty subsets `C⊆B` are admissible belief states. An atomic grant is permitted only when the selected guarded coordinates intersect **every** changed-coordinate set from a baseline `b∈C` to an unsafe final world.

For the safe-belief minimax problem, the exact Bellman alternatives are:

\[
W(C)=\min\bigg\{G(C),\;
\min_{i\,\mathrm{splits}\, C}\!
\big[c_i+\max(W(C_{i,0}),W(C_{i,1}))\big]\bigg\},
\]

where `G(C)` minimizes cost over original-world sound guards.

The certificate stores a **lower value** `L(C)` and a **proposed action** at every nonempty `C⊆B`. Its small checker requires, for every `C`:

1. `L(C) ≤ cost(J)` for **every** sound direct guard `J`, calculated by original-world enumeration.
2. `L(C) ≤ c_i+max(L(C_{i,0}),L(C_{i,1}))` for **every** test that splits `C` into nonempty fibers.
3. The proposed action is feasible and attains equality with `L(C)`.
4. Every chosen read strictly decreases belief size; hence the policy tree terminates.

The first two conditions show `L(C)` is a lower bound for *every* finite valid policy, by induction over the tree. The third and fourth provide an executable policy with matching cost. Therefore `L(C)=W(C)`; neither an optimizer's verdict nor a precomputed table of purported optima is a trusted axiom.

### Concrete exact certificate

| Belief masks (bit position = world ID) | Value (quarter-units) | Matching action |
|---|---:|---|
| `1` = {00} | 4 | grant, guard source 0 |
| `2` = {01} | 4 | grant, guard source 1 |
| `3` = {00,01} | 4 | grant, guard source 1 |
| `4` = {10} | 4 | grant, guard source 0 |
| `5` = {00,10} | 4 | grant, guard source 0 |
| `6` = {01,10} | 5 | read source 0 |
| `7` = {00,01,10} | 5 | read source 0 |

The root's direct fence costs at least `8`; the adaptive policy costs `1+max(4,4)=5`. The gain is **3/8 of direct baseline cost = 37.5%**, within this model.

### Independent audits and formal bridge

- `generate_bellman_policy_certificate.py --check` regenerates the seven policy entries with the preexisting `semantic_fence.joint_value`. **Generator output is not accepted as proof.**
- `check_bellman_policy_certificate.py` reconstructs all unsafe histories and independently verifies every Bellman local inequality, every selected action and the original model hash; 19 failed-certificate mutations are included.
- `check_bellman_policy_independent.cjs` is a *different* yes/no decision procedure. For every belief state it independently establishes **feasible at L** and **infeasible at L−1** using raw world states and all possible guard masks; it does not use the policy table or optimizer recurrence to decide feasibility. Eleven negative controls attack the input and claims.
- `SemanticBellmanPotential.lean` **imports** original `SemanticFencing.lean`, then defines `BellmanLowerCertificate` and proves `bellman_lower_certificate_sound` and `bellman_matching_policy_optimal`. The separate `bellman_policy_type_contract.json` pins their expected types and the named axiom audit.
- The formal implication assumes a potential satisfying its conditions on all sets; the executable JSON check is limited to subsets of this baseline. The **instance-level JSON → Lean potential bridge remains unformalized**; no all-Lake replay or operational authorization certification follows from named Lean theorems alone.

### Reproduction

```sh
python3 -I research/nightfall/price_permission/generate_bellman_policy_certificate.py --check
python3 -I research/nightfall/price_permission/check_bellman_policy_certificate.py --self-test
python3 -I research/nightfall/price_permission/check_bellman_policy_certificate.py research/nightfall/price_permission/bellman_two_source_policy_certificate.json
node research/nightfall/price_permission/check_bellman_policy_independent.cjs
node scripts/check_bellman_policy_passport.cjs
node scripts/check_proof_object_passport.cjs
```

Run `.github/workflows/nightfall-bellman-policy-passport-lean.yml` for the pinned Lean kernel and exact-type receipt. Source change of the original solver, unsafe model, checker, formal theorem, or expected contract must invalidate the affected certification and trigger fresh CI.

## Transfer and stop rule

This **reusable dual method for adaptive policies** (locally checked Bellman subsolution + matching primal policy) transfers directly to finite adversarial recertification, dependent-sensor acquisition, and policy trees with exact mission-conditioned outcomes **once** their action and information semantics are faithfully encoded.

It does *not* extend unchanged to concurrent writes during observations, probabilities of error, noisy monitoring, privacy leaks, cross-action shared evidence, or unbounded real-time retries. Those require a richer state/action protocol, possible changes to the value function, and new independent counterexample tests.

Credit: NIGHTFALL prior semantic-fencing solver and Lean finite-safe Bellman proof; classical dynamic programming/subsolution certification and proof-carrying computation; Generalised Superintelligence's public checker-first approach for the process emphasis. This is engineering and mathematical formalization reuse, not a claim of a new general Bellman theorem.
