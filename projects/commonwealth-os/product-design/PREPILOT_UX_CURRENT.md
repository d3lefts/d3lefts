# Prepilot Browser UX — Current Demonstrator

**Latest version:** v0.2, 2026-11-15. This is **synthetic UX code**, not binding-vote technology.

- [Launch the standalone browser demonstrator](v0.2-prepilot-ux/index.html) (download/raw-open if your browser does not render GitHub-hosted HTML).
- [Run the smoke test](v0.2-prepilot-ux/smoke_test.py): Playwright/Chromium; observed PASS on the local fixture.
- [Review the interface handoff](v0.2-prepilot-ux/FIGMA_HANDOFF.md) and [README](v0.2-prepilot-ux/README.md).
- [Figma visual workspace](https://www.figma.com/design/TtmaHUDRPMsDP1in4qQ5QN): the v0.2 screens are **not yet synced** because Figma Starter-plan MCP calls were exhausted; the prior two editable screens remain.
- [Original v0.2 ZIP in Google Drive](https://drive.google.com/file/d/1EJcnqDX_4xKoAdUUnsi74Z8DGOdAFO79/view); package SHA-256: `d3066e0808a1c2a69d4f75f9f3274519354e310c46799941ffbe6c769e25fce0`.

**Boundary:** The v0.2 UX file intentionally does not call the transactional server, state-machine verifier, real institutional authority, real identity service, or official law records. The actual `apps/browser` and `apps/server` engineering branches are separate, and a visual prototype should not be conflated with a cryptographically certified decision or an actual ballot.
