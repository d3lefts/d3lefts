# NIGHTFALL | CONSTELLATION — Two Skies

**29 October 2026 · Active visual contract · No scientific claim changes**

The appearance switch exchanges distinct editorial experiences. It does not alter source records, proofs, evidence thresholds, or review status.

## Archive / golden hour

The reference is Sunset Boulevard at blue hour: plum and violet, rose haze, and apricot sunlight. It replaces the too-brown cocoa archive while retaining luminous type and a starlit atmosphere.

| Role | Value | Application |
|---|---|---|
| Twilight plum | `#241A34` | Overall background |
| Night plum | `#191327` | Dark featured panels and navigation |
| Velvet violet | `#3B2C4B` | Cards, tools and reading surfaces |
| Rose-violet | `#31233F` | Secondary panels |
| Pearl cream | `#FFF0E7` | Primary text |
| Orchid mist | `#DEC9DE` | Metadata and descriptions |
| Apricot light | `#F5B78B` | Selected states, primary actions |
| Peach light | `#F8D2AA` | Hover, focus |
| Violet rule | `#826682` | Dividers |

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

The screenshot-led October 29 revision corrects contrast on the Contributor Path: process panels, status labels, result links, workspace and empty state; it keeps the Night theme navy, replacing only the anomalous wine-red process field.\n\nThe active palettes are determined by `docs/two-skies.css` and `docs/mobile-scroll-cinema.css`, both loaded after the historical stylesheets. Older base declarations remain documented as fallback history, not a license to reintroduce parchment. The computed-style browser audit checks large displayed surfaces in both modes for obsolete background colors and tests mobile overflow. The homepage's three formerly hardcoded instrument colors now use the palette tokens.
