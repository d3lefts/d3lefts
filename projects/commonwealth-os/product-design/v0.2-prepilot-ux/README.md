# Commonwealth OS — Prepilot Browser UX v0.2

**Status:** Interactive, synthetic UX prototype. Not production voting or verified government software.

This deliverable is a standalone browser-design vertical slice for invited prepilot participants, aligned with Commonwealth OS Product Design v1.0. It covers invitation, representative dashboard, review of a versioned fictional proposal, simulated amendment, demo ballot with explicit confirmation, and an illustrative Democratic Assurance Proof Passport. It also includes deliberate stale-revision and missing-rule failure cases. It does **not** authenticate real users, ingest authoritative laws, administer binding votes, certify ballots, or prove the actual legality or security of a governance process.

## Run

Open `index.html` directly in a current browser; no server or network needed. No secret or user-data handling is required.

## Test

```bash
python -m pip install playwright
python -m playwright install chromium
python smoke_test.py
```

The test covers walkthrough navigation, version-locked simulated amendment and vote, nondefault choice, explicit confirmation, provisional evidence, adversarial failed sample checks, export and mobile width. Tested locally 2026-11-15 against installed Chromium; result PASS. This is not a security or election-integrity audit.

## Design handoff

See `FIGMA_HANDOFF.md` for screen inventory, visual tokens, layout and Figma sync details. Current Figma home: https://www.figma.com/design/TtmaHUDRPMsDP1in4qQ5QN . This v0.2 slice was **not** written to the Figma canvas because the Starter-plan MCP tool quota had been reached. The workspace does contain earlier editable journey and starter browser screens.

Screenshots (`passport_desktop.png`, `review_mobile.png`) are reference renders; the HTML remains the editable browser source.

## Integration boundaries

The existing Commonwealth OS `apps/browser` and `apps/server` parallel engineering work are distinct. This prototype lives in `product-design/v0.2-prepilot-ux` and must not be advertised as a secure replacement for a reviewed legislative state machine. Keep all fictional fixture assertions distinct from the official-source and independent-verifier gates.

## Provenance

Original packaged UX ZIP SHA-256: `d3066e0808a1c2a69d4f75f9f3274519354e310c46799941ffbe6c769e25fce0`. A copy is maintained in the Commonwealth OS Google Drive Product Design archive. This source directory adds a README but does not purport to be byte-identical to the original ZIP.
