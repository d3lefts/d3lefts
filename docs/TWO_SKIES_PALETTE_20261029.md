# NIGHTFALL | CONSTELLATION — Two Skies

**29 October 2026 · Active visual contract · No scientific claim changes**

The appearance switch exchanges distinct editorial experiences. It does not alter source records, proofs, evidence thresholds, or review status.

## Archive / golden hour

The current Archive is an afterglow sky: aubergine, plum, dusty rose, coral cloudlight, and apricot controls. The previous cocoa-brown treatment was retired after mobile contrast review. The earlier pale parchment iteration remains in history.

| Role | Value | Application |
|---|---|---|
| Aubergine sky | `#39243C` | Overall background |
| Dark plum | `#302039` | Featured panels and navigation |
| Rose-plum panel | `#583A57` | Cards, tools and reading surfaces |
| Heather-plum surface | `#493047` | Secondary panels |
| Warm ivory | `#FFF0E8` | Primary text |
| Blush copy | `#F0CCD8` | Metadata and descriptions |
| Apricot sun | `#FFC39E` | Selected states, primary actions |
| Soft peach light | `#FFDFC5` | Hover, focus |
| Muted lilac rose | `#A07B95` | Dividers |

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

- The dark Underbelly remains the default first visit; the sunset Archive is selectable and persists as a preference.
- Source labels and evidentiary classifications remain legible and are never inferred from hue.
- Living Paper reading surfaces remain free of star textures.
- Main text and button ink have tested WCAG AA contrast against their intended filled backgrounds.
- `docs/two-skies.css` is loaded last on every themed page; `scripts/check_palette_contract.mjs` checks palette tokens, neon regressions, and CSS inclusion.
- Mobile/desktop screenshots, reversible theme switching, source links and reduced-motion checks are covered by the website CI.

## Rare oxblood accent in New Moon

Oxblood is an **atmospheric punctuation mark**, never a scientific-status legend, focus ring, or main action. The archived blackcherry value `#4A1F24` is now the `--nf-oxblood-rare` variable in the Night skin, with an illuminated `#A76573` companion for visible fine edges. It is limited to the flagship section divider, a low-intensity cinematic glow and one illustrative constellation node, and the final-colophon hairline. Navy, indigo, jasmine and moonlight remain the dominant palette.

## Consistency policy

The active palettes are determined by `docs/two-skies.css`, `docs/home-dual-experience.css`, `docs/home-opening-cinema.css`, and `docs/mobile-scroll-cinema.css`, layered after historical stylesheets as applicable. Older base declarations remain documented as fallback history, not a license to reintroduce parchment. The computed-style browser audit checks large displayed surfaces in both modes for obsolete background colors and tests mobile overflow. The homepage's three formerly hardcoded instrument colors now use the palette tokens.

## Sunset review correction — 29 October 2026

Mobile screenshots 4–9 exposed a cocoa-heavy canvas and unreadable inherited dark labels on dark paper. The archive now uses aubergine sky, blush-plum panels, coral-to-peach cinematic gradients, and WCAG-AA-conscious ivory, muted blush, and apricot text. Contributor labels, source-bound cards, process stages, input controls, and links have explicit Archive contrast contracts. The navy New Moon tokens, research text, proof scopes, and evidence states are unchanged. Sunset ink `#302039` against apricot `#FFC39E` is approximately 9.5:1; blush text `#F0CCD8` against raised plum `#70465F` is approximately 5.2:1. These are token-pair checks; full page-level browser verification is tracked separately.
