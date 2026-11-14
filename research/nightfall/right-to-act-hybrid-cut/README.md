# The Right to Act: Hybrid Assurance Cuts (Research v1.4)

**Status:** Exact finite restricted mathematics, source-matched independent checks and abstract atomic promotion specification. Not a novel priority claim, not a certified reference monitor, and not an AI-control field result.

Research addendum: [The Cost of Delegated Authority](RESEARCH_ADDENDUM.md).

This project isolates the tractability boundary for **minimum-cost mission-conditioned recertification**:

1. Edge-local guards and source-valid certificates: rational directed min-cut = max-flow certificate.
2. Shared evidence over multiple hazard paths: weighted Set Cover, NP-hard generally.
3. Laminar evidence supports: exact containment-tree dynamic programming.
4. Stale source/policy receipts, new graph paths, revocation, and source/promotion races: fail-closed only inside the specified abstract trusted boundary.

## Reproduce

```bash
cd research/nightfall/right-to-act-hybrid-cut
python -m pip install pytest==8.4.2
python hybrid_cut.py example_network.json --output rebuilt_result.json
python independent_checker.py example_network.json rebuilt_result.json --random-cases 500
python -m pytest -q test_promotions.py test_shared.py
sha256sum --check SHA256SUMS.txt
```

The frozen fixture yields full=18, local=12, joint=4 exact rational cost units. The separate exhaustive checker validates 500 deterministic random graphs; the test suite checks 400 laminar shared-evidence instances and abstract promotion invalidation. These costs are synthetic, not measured ControlArena savings.

The actual isolated GitHub ControlArena/Inspect baseline lives on separate [draft PR #492](https://github.com/d3lefts/d3lefts/pull/492), which has completed real small-model tasks but **not** integrated this promotion kernel with effect-time enforcement. See the addendum for exclusions and prior art (PACE, FASE 2026, AID-Guard, Zhang-Xu, Elmasry).

No code in this folder invokes a live model, touches production infrastructure, or enforces authorization outside Python process memory.
