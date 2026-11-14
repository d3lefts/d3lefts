# Pinned GitHub Actions canary (2026-11-14)

NIGHTFALL's critical pinned-Lean path is upgrading from GitHub Actions Node 20 legacy majors to **Node 24**. These tags were checked using the official upstream Git references on November 14, 2026; the workflow uses their **immutable commit SHAs**, not moving major tags.

| Action | Selected upstream release | Commit SHA |
|---|---|---|
| actions/checkout | v7.0.1 | `3d3c42e5aac5ba805825da76410c181273ba90b1` |
| actions/cache | v6.1.0 | `55cc8345863c7cc4c66a329aec7e433d2d1c52a9` |
| actions/upload-artifact | v7.0.2 | `cf430e030ddbb5b0abf93d22962f4752f3646cd9` |
| actions/github-script | v9.0.0 | `3a2844b7e9c422d3c10d287c895573f7108da1b3` (annotated tag resolved to commit) |

The last version is recorded for future cleanup but **github-script is not currently called** in the critical read-only Q2 pipeline. This canary upgrades the shared Lean setup action, the consolidated Q2 theorem pipeline, its Lean compatibility replay, the Lean bridge v2 job, and the lightweight toolchain pin audit.

### Validation gates

- Re-run all 13 named pinned Lean compatibility declarations under the same `leanprover/lean4:v4.36.0-rc2` and Mathlib commit `9d581dfff2e41de989072ea63abf3daf69311520`; source correctness/pin must not change.
- Verify cache hit/miss and `Mathlib.olean`; check updated artifact upload with source and axiom receipt artifacts.
- Verify source CI governance, historical provenance index and ordinary website checks.
- Roll out remaining **non-Q2** workflows only after this canary passes; do not bulk rewrite frozen source or mark mathematical theorems certified from an action migration.

**Status at creation:** canary candidate. GitHub CI must independently establish runtime compatibility. A SHA/ref lookup is supply-chain provenance, not a test of action behavior.
