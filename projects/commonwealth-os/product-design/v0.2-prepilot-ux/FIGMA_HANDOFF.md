# Commonwealth OS — Prepilot UX Vertical Slice v0.2

**Source of truth for this design direction:** Commonwealth OS Product Design v1.0, `d3lefts/d3lefts/projects/commonwealth-os`, merged to `main`. These new layouts are **proposals**, not production code or a validated authorized voting system.

**Figma target:** https://www.figma.com/design/TtmaHUDRPMsDP1in4qQ5QN

**Status (2026-11-15):** Figma connection verified and existing Figma file editable, but additional Figma edits were blocked by the user's Figma Starter-plan MCP tool-call quota. The new screens are implemented in `index.html` as a self-contained, interactive, offline-capable browser prototype. No claim is made that they were written back into the Figma file.

## Scenarios and screens

1. `Invitation`: direct, honest prepilot purpose; fictional records; no political profiling.
2. `Today`: role-scoped institutional workspace, one next task.
3. `Review`: authoritative-provision *fixture* (synthetic source), version-specific text, compare revisions, evidence status.
4. `Amend`: proposed replacement text and rationale, preview diff, new immutable *demo* revision, invalidated previous demo receipts.
5. `Demo vote`: preflight; locked exact text and version; no preselected choice; review/confirm; session-only simulated receipt.
6. `Proof Passport`: provenance rows, simulated checks, deliberate stale-version and missing-rule counterexamples, export JSON explicitly marked uncertified.

## Visual handoff

- **Target Figma viewport:** desktop 1440 × 900; responsive tablet/mobile.
- **Colors:** base `#0B1625`; side `#102037`; primary panels `#162940`; surface raised `#1D334C`; accents `#72D5C8`; text `#EAF3FC`; muted `#A8BFD3`; warning `#F0D093`.
- **Typography:** Inter where available, system sans fallback; display 38–46, section 22–28, body 15–17 px.
- **Component candidates:** Simple Design System Button, neutral and danger variants, state tags, version timeline, split-column source panel, confirmation dialog.
- **Navigation:** one institutional shell, pinned role/authority context, review > amend > vote > verify stepper; all fields keep semantic labels, 44+px targets, visible focus.

## Test plan

- Can an unfamiliar representative locate the exact operative text before taking action?
- Do participants distinguish a demo vote, a policy preference, and an official ballot?
- When amendments increment a revision, are previous ballot assumptions invalidated?
- Does the confirmation show the exact motion and version?
- Can auditors detect stale motion text and missing rule evidence? Do they avoid treating the local checker as independent certification?
- Keyboard-only, reduced-motion, low-width, screen-reader basics.

## Integrity limitations

This is a **local JavaScript UX prototype**, not a secure voting system. There is no server, identity authority, signed append-only event log, independent verifier, authorization gate, public-record integration or certified governance process. Demo choice is held in memory only. Exported JSON is a design fixture, not cryptographic evidence.

## Figma continuation

Once Figma connector editing capacity is available, implement the new `Review`, `Amend`, `Demo vote`, and `Proof Passport` screens as editable native Figma layers in page `01 — Browser Screens`, positioned next to existing screens. Use the existing `02 — States & Research` for the blocked/stale/unknown variants. Avoid flattening full screens into screenshots.
