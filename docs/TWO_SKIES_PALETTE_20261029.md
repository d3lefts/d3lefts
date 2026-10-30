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
| Apricot with 24k warmth | `#E7B768` | Selected states, primary actions |
| Soft gilded peach | `#F0CC8F` | Hover, focus |
| Violet rule | `#826682` | Dividers |

## Underbelly / new moon

Absolute-black-near canvas; deep navy and indigo structure; pale jasmine text and cool lunar gold. No crescent on this side, because it represents a new-moon sky.

| Role | Value | Application |
|---|---|---|
| New-moon black | `#04060B` | Global canvas |
| Midnight navy | `#0C1527` | Cards and evidence |
| Indigo | `#16223C` | Selected and lifted layers |
| Jasmine | `#F1EEDC` | Primary text |
| Gilded moonlight | `#E2D28C` | Active controls, trust-navigation cues |
| Pale-gold hover | `#EEE0A7` | Focused elements |
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

## New Moon / blood-colour exception

**29 October 2026, visual correction.** The New Moon no longer uses oxblood as a general-purpose accent. Its flagship section divider now runs from muted lavender through moonlight gold; the small opening and constellation nodes are starlit blue; its closing rule is indigo. This prevents the burgundy marks from competing with moonlight actions and improves visible contrast.

The **one exception is the atmospheric wine-red bloom in the large scroll-cinematic gradient** (`.nf-cinema-world--night`). Its original low-opacity radial-gradient stop `rgba(74,31,36,.21)` remains as part of the background artwork, never as text, button, evidence coding, hairline, or selected-state colour. The discontinued `--nf-oxblood-rare` and `--nf-oxblood-lit` palette variables are no longer defined. This is a narrowly scoped design exception; scientific statuses continue to be literal labels.

## Consistency policy

The screenshot-led October 29 revision corrects contrast on the Contributor Path: process panels, status labels, result links, workspace and empty state; it keeps the Night theme navy, replacing only the anomalous wine-red process field.\n\nThe active palettes are determined by `docs/two-skies.css` and `docs/mobile-scroll-cinema.css`, both loaded after the historical stylesheets. Older base declarations remain documented as fallback history, not a license to reintroduce parchment. The computed-style browser audit checks large displayed surfaces in both modes for obsolete background colors and tests mobile overflow. The homepage's three formerly hardcoded instrument colors now use the palette tokens.

## 24k trace refinement — 29 October 2026

The shared metallic reference is `#D4AF37`, a familiar digital approximation of 24k gold (not a literal rendered metal). Both experiences retain distinct matte primary accents: Archive `#E7B768` and New Moon `#E2D28C`. The warmer accent is paired with an apricot hover `#F0CC8F`; the cooler one with `#EEE0A7`. Metallic gold appears only as a short portion of fine navigation rules / selected cinematic strokes, never as normal body text or a proxy for evidence status. The Archive sunrise has less saturated pink and a softer glow; the New Moon retains its navy canvas and quiet lavender text.

Calculated WCAG contrast at designated pairings: Archive primary `#E7B768` on raised plum `#503757` = 5.61:1; Archive button ink `#191327` on `#E7B768` = 9.77:1; New Moon primary `#E2D28C` on canvas `#04060B` = 13.35:1. These token checks do not replace the cross-page computed-style browser tests.
