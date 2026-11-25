# NIGHTFALL local Lean certification protocol — v1

**Mandatory for every theorem and every contributor, effective 2026-11-25.**
The compiler lock remains [lean-compiler-lock.json](lean-compiler-lock.json). There are no paper-dependent cache keys, special dependency lists, or paper-dependent resource rules in this shared protocol. Theorem selection is data: exact module names, source paths, imports and named terminal declarations. Historical proof sources and receipts retain their original identity and credit.

## Recovery before computation

1. Read the current assignment, main, parallel branches, existing Proof Passports, historical named receipts and previous handoff bundles. If the same original statement and exact dependency closure already have a valid terminal receipt, **reuse it without compiling or replaying it again**. If a certificate is only scoped, preserve its actual scope and do not promote it.
2. Restore the pinned local runtime from a previously verified immutable snapshot, not a cold build. The existing portable runtime export [45650723011](https://github.com/d3lefts/d3lefts/actions/runs/45650723011) and its SHA-256 chunk manifest are an available historical recovery source, not a theorem receipt. Verify all archive chunks and restore only the compiler and external libraries; do not put untracked project objects into the external runtime search path. Keep the verified runtime immutable during a run. Direct external import bytes, compiler/exporter/checker bytes, runtime manifest and compiler lock participate in the new cache identities.
3. Restore previously verified object and receipt stores. The cache is a content-addressed store, independent of the research domain or paper. Preserve old receipts as admissible historical evidence; no automatic conversion of unverifiable old object provenance and no forced rebuild for metadata reconciliation.
4. Freeze an exact terminal target and its dependency graph. Prefer narrow imports and small modules for new work. If unchanged historical source imports the umbrella Mathlib module, explain why in its plan row; do not edit a statement merely to make compilation easier. Refactor only with source-exact dependency accounting and manuscript-to-terminal equivalence review.

## Canonical executable

Use `scripts/lean_checkpoint.py` locally. A plan is an ordinary JSON file:

```json
{
  "modules": {
    "Example.Base": {"source": "path/to/Base.lean", "imports": []},
    "Example.Terminal": {"source": "path/to/Terminal.lean", "imports": ["Example.Base"]}
  },
  "terminal": {"module": "Example.Terminal", "declarations": ["Example.main"]}
}
```

Imports list the actual direct project module dependencies; external Lean/Mathlib modules resolve from the verified runtime. The runner independently compares Lean's resolved import paths to the plan. Do not conceal project dependencies in external library roots. The terminal declaration names and original statement scope must be reviewed against the frozen claim. A cache hit alone is not certification.

Run with an exact trusted runtime manifest and the actual restored library roots:

```bash
python3 scripts/lean_checkpoint.py \
  --root "$REPO" --plan "$PLAN" --store "$STORE" \
  --runtime-manifest "$RUNTIME_MANIFEST" \
  --lean "$RUNTIME/lean/bin/lean" \
  --checker "$RUNTIME/lean/bin/leanchecker" \
  --base-path "$RUNTIME/lean/lib/lean" \
  --base-path "$RUNTIME/mathlib-lib" \
  --seed-store "$RECOVERED_STORE" \
  --build Example.Terminal
```

Add one --base-path for each required verified external package library. Omit absent optional seed-store or package roots. The default is **reuse only**; each --build explicitly permits one genuinely missing module. A missing dependency not explicitly authorized stops immediately; no hidden cold fallback. The runner uses an isolated import overlay, source and ancestor object hashes, a store lock, atomic module checkpoints, and a fresh dependency-closed export of named declarations via leanexport / leanchecker --from-export when there is no matching terminal receipt. Exact successful receipts are reused, including from a verified seed store. Successful source, object and proof-export artifacts carry their hashes and exit receipts. A failed attempt keeps its diagnostics but never becomes a successful entry.

## Resource budget and failure taxonomy

- Run one local elaborator/exporter/checker at a time. Defaults: 2560 MiB process RSS+swap threshold, 300 seconds per subprocess, single-thread Lean environment. The Linux polling guard also observes cgroup anonymous-memory pressure when available. These are protective limits, not a hard proof of maximum memory use. Adjust only with documented capacity and budget; never keep raising limits through a paging loop.
- Resource timeout/memory: preserve successful ancestors, exact failing command, elapsed time, sampled RSS/swap and diagnostics. Reduce the actual import closure or split the next proof into independently checkable small modules. Do not restart an unchanged failed closure.
- Compiler/elaboration failure: repair the precise source diagnostic, not the entire dependency tree. Mathematical failure: keep the original unproved statement open and hand it back to the mathematical author; no theorem-shaped assumptions, custom axioms, sorry, weakened scope or trivial replacement. Kernel or axiom failure: stop and invalidate the affected receipt.
- A completed terminal needs exact source/dependency identity, named axiom audit and successful dependency-closed fresh kernel verification (or an already authenticated exact receipt), plus separate statement-equivalence review. Allowed axioms are only the pinned lock's standard three. Peer review, novelty and publication gates remain distinct.

## Persistent custody and handoff

The store contains immutable objects/<key>/ and receipts/<key>/. Each handoff retains their source, manifest, compiled files, logs and successful exports. Export the verified store to durable approved storage or a conversation artifact, not solely disposable scratch space. For example, after closing the runner:

```bash
tar -C "$STORE" -czf lean-checkpoint-store.tar.gz objects receipts
sha256sum lean-checkpoint-store.tar.gz > lean-checkpoint-store.tar.gz.sha256
```

On recovery, verify the recorded archive hash before safe extraction, pass the extracted directory with --seed-store, and check exact module/receipt hashes through the runner. Register immutable archive location, SHA-256, compiler lock, named terminal, scope and original source/dependency evidence in the existing Proof Passport system. Never treat an untrusted self-written manifest as authentication of an historical run. Historical build artifacts may be recovered through their original verified manifests; they are not automatically converted into this store unless exact identities and actual receipts are established. Cache schema changes require a migration or explicit invalidation record.

## Role and verification rules

All five roles must read this protocol before any Lean work. Ryev maintains the shared runtime/cache and durable receipt custody. Authors own the original statements and missing proof obligations; Lemnis or another non-author independently attacks their mathematical correspondence; Vesper checks scope and receipt integration. No role creates a paper-specific shared compiler or cache. Legacy scoped proof workflows are historical/target evidence, not a competing canonical procedure. No unnecessary GitHub Lean build substitutes for local certification; remote compilation requires explicit authorization. The lightweight CI control job does not compile any research theorem or promote any claim.

## Implementation verification, 2026-11-25

Pinned Lean 4.36.0-rc2 core was recovered from the existing verified portable snapshot; no research theorem was recompiled. The actual two-module local smoke test compiled A and B, exported the named terminal beta and obtained `Lean default kernel accepts the solution`. Warm reuse and fresh-store restoration with --seed-store returned the same exact receipt without compilation or kernel replay. A terminal-only revision compiled only B; changed ancestor A was rejected without explicit authorization. Eleven executable controls passed for dependency ordering/cycles, missing target/dependency/axiom records, standard/custom/sorry axioms, resource timeout, failed process and corrupt artifact. The smoke test is a small integration test, not measured performance on large Mathlib imports or certification of any research theorem. The runtime archive must be verified externally; the runner checks its stated pins and actual direct inputs but does not independently rehash every transitive external runtime object on each invocation. Full historical cache migration remains a separate custody operation; no certificate is revoked by this protocol.

Runner source Git blob: `fd353780c79e7bf96b119e7c50cc29cfcb1c05c4`. Control source Git blob: `e5425607132a5e0726891e0fe8d78eacc29ad95f`.
