# NIGHTFALL external verification and discovery upgrades — pilot v1

Date: 2026-11-23. Status: **pilot, not a replacement for kernel replay or independent mathematical review**.

## Source and credit
Google DeepMind / Google Quantum AI, Shirobokov et al., *Discovering formally verified quantum programs with AI*, arXiv:2611.09822v3; implementation https://github.com/google-deepmind/formal-quantum-computation (Apache-2.0 code). We do **not** vendor Google's comparator, claim its algorithms as ours, or imply that our Python wrapper is Google's Lean Comparator.

## Operational change in this PR
- Candidate authors can change the Lean construction, but **cannot silently alter the reviewed exact-type contract**: `scripts/external_lean_comparator.py` compares contract bytes against the trusted base branch.
- Existing `scripts/lean_bridge.py --strict --contract` performs pinned Lean compilation, exact proposition checks, and named axiom audits; comparator checks that its receipt matches the source, frozen contract, target list and allowed axioms.
- Dedicated CI tests mutate contract, source, axiom list, target list, compiler status and toolchain status. Fail closed.
- **Security boundary:** branch protection / required CI must be controlled by a human repository administrator. A PR author who can alter workflow policy or the trusted base can bypass this gate. The Python gate is receipt consistency, not an independent proof kernel. It must never promote a paper-level claim on its own.
- Baseline changes require a distinct owner-reviewed specification PR. A candidate solution PR that changes its own contract fails.

## Next adoption gates (not yet implemented)
1. **Quantum resource contracts:** specify expected query cost with branch-weighted costs, almost-sure termination, and separately stated worst-case gate/T count. Check arithmetic and oracle-model equivalence before porting to Route 1/Wyner. Do not assume Google's `Q*T` proxy models physical hardware.
2. **Discovery operators:** preregister representation changes (Fourier/real-space, one-hot vs binary lookup, measurement uncomputation, Bernstein approximations) and compare at fixed correctness and resource scope. Preserve failures.
3. **Agent coordination:** shared versioned findings ledger with claim, exact scope, checker, credit, prior-art references, and counterexamples. Require an independent adversarial audit designed before reading the candidate.
4. **Measurement:** randomized matched-budget A/B comparison of existing proof checks versus frozen comparator, counting planted specification-drift and axiom failures, false positives, wall-time and compute cost. No efficacy claim before measurement.
5. **Promotion:** require kernel receipt, comparator pass, independent mathematical review, dated prior-art audit and owner approval for publication or merging consequential claims.

## Pilot commands
```sh
python3 tests/test_external_lean_comparator.py
# CI additionally runs the existing pinned Lean bridge and then:
python3 scripts/external_lean_comparator.py --trusted-base origin/main \
  --contract research/nightfall/formalization/compiler/contract-smoke.json \
  --receipt lean-receipts/external-comparator-smoke.json
```

## Known limitations
- The comparator audits receipt fields rather than re-running Lean; independently rerun the compiler when the trust boundary requires it.
- GitHub-hosted runner output, toolchain pin and trusted branch must be protected.
- A frozen specification can be wrong. Human mathematical review remains required.
- This pilot covers one existing smoke theorem, **not every NIGHTFALL certificate**.
- DeepMind's large proof builds can exceed 230 GB RAM; no large quantum replay is claimed here.
