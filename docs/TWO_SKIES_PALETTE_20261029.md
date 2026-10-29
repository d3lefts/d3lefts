# NIGHTFALL | CONSTELLATION — Two Skies

**29 October 2026 · Active visual contract · No scientific claim changes**

The appearance switch exchanges distinct editorial experiences. It does not alter source records, proofs, evidence thresholds, or review status.

## Archive / golden hour

The reference is a cocoa-brown, starlit browser theme, with sunset-yellow light. The earlier pale parchment design is retired.

| Role | Value | Application |
|---|---|---|
| Cocoa sky | `#28190F` | Overall background |
| Deep chocolate | `#1B100B` | Dark featured panels and navigation |
| Raised cocoa | `#3B281D` | Cards, tools and reading surfaces |
| Soft cocoa | `#332116` | Secondary panels |
| Warm cream | `#F7E8DB` | Primary text |
| Warm secondary | `#CEB6A7` | Metadata and descriptions |
| Golden hour | `#EDC16E` | Selected states, primary actions |
| Late-sun yellow | `#F5D88F` | Hover, focus |
| Warm rule | `#75574A` | Dividers |

## Underbelly / new moon

Absolute-black-near canvas; deep navy and indigo structure; pale jasmine text and cool lunar gold. No crescent on this side, because it represents a new-moon sky.

| Role | Value | Application |
|---|---|---|
| New-moon black | `#04060B` | Global canvas |
| Midnight navy | `#0C1527` | Cards and evidence |
| Indigo | `#16223C` | Selected and lifted layers |
| Jasmine | `#F1EEDC` | Primary text |
| Moonlit gold | `#E6DEAA` | Active controls, trust-navigation cues |
| Moonlight hover | `#F2E8BB` | Focused elements |
| Starlit violet | `#B4B5D9` | Secondary atmosphere |
| Quiet lavender | `#BEC3D6` | Metadata |
| Deep divider | `#33405D` | Panels and structure |

## Rules

- The dark Underbelly remains the default first visit; the Archive is selectable and persists as a preference.
- Source labels and evidentiary classifications remain legible and are never inferred from hue.
- Living Paper reading surfaces remain free of star textures.
- Main text and button ink have tested WCAG AA contrast against their intended filled backgrounds.
- `docs/two-skies.css` is loaded last on every themed page; `scripts/check_palette_contract.mjs` checks palette tokens, neon regressions, and CSS inclusion.
- Mobile/desktop screenshots, reversible theme switching, source links and reduced-motion checks are covered by the website CI.

## Rare oxblood accent in New Moon

Oxblood is an **atmospheric punctuation mark**, never a scientific-status legend, focus ring, or main action. The archived blackcherry value `#4A1F24` is now the `--nf-oxblood-rare` variable in the Night skin, with an illuminated `#A76573` companion for visible fine edges. It is limited to the flagship section divider, a low-intensity cinematic glow and one illustrative constellation node, and the final-colophon hairline. Navy, indigo, jasmine and moonlight remain the dominant palette.

## Consistency policy

The active palettes are determined by `docs/two-skies.css` and `docs/mobile-scroll-cinema.css`, both loaded after the historical stylesheets. Older base declarations remain documented as fallback history, not a license to reintroduce parchment. The computed-style browser audit checks large displayed surfaces in both modes for obsolete background colors and tests mobile overflow. The homepage's three formerly hardcoded instrument colors now use the palette tokens.
