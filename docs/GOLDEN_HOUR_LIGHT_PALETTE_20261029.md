# NIGHTFALL / LIGHT — GOLDEN-HOUR EDITORIAL ARCHIVE

**29 October 2026 · Theme-only change · Scientific content and status unchanged**

The light theme is now a Southern California golden-hour research archive: **rose parchment**, **blackcherry oxblood**, and **sunlit terracotta**. Dusk remains the distinct **navy, violet and champagne observatory**.

| Role | Hex | Application |
| --- | --- | --- |
| Page paper | `#F4E7DF` | Red-tinted parchment canvas |
| Raised paper | `#F8EEE8` | Cards, evidence tables, reading and tools |
| Soft clay | `#EEDFD6` | Grouped panels and the constellation field |
| Warm rule | `#C9B2A6` | Borders and separators |
| Editorial ink | `#2A1F1D` | Long-form body text |
| Secondary ink | `#5C4944` | Captions and secondary data |
| **Blackcherry oxblood** | **`#4A1F24`** | Brand identity, dark feature sections, header, authoritative structure |
| Soft oxblood | `#6A2D35` | Editorial headline emphasis |
| Deep oxblood | `#3A161B` | Reserved contrast |
| **Sunset orange** | **`#D97A4A`** | Primary actions and active finite inputs |
| Apricot highlight | `#E3A065` | Hover and warm numerical accents |
| Amber | `#C96A3B` | Secondary decoration only; inadequate as normal-sized text on oxblood |

## Contrast engineering

Using WCAG relative luminance:
- Oxblood `#4A1F24` on parchment `#F4E7DF`: approximately **11.47:1**.
- Dark ink `#2A1F1D` on sunset orange `#D97A4A`: approximately **5.21:1**.
- Oxblood `#4A1F24` on sunset orange: approximately **4.52:1**, passes normal-size AA narrowly.
- Secondary ink `#5C4944` on parchment: approximately **6.96:1**.

Primary actions use sunset orange with oxblood text; hover becomes the lighter apricot, never the lower-contrast burnt-orange background. Small labels remain oxblood or dark ink. No orange small text on light parchment.

## Component rules

1. **Homepage**: oxblood featured panels and wordmark, soft clay cards, sunset buttons, warmer hero and footer, no neon lime.
2. **Constellation and Observatory**: light warm archive surfaces; active objects and scientific relationship types remain clearly *labeled*, with no visual implication of proof transfer or upgraded confidence.
3. **Living Papers and exact calculations**: clean rose parchment, oxblood mathematical framing, warm orange controls. Source witness and exact numeric values remain untouched. Some dark oxblood evidence panels provide editorial rhythm.
4. **Contributor Journey**: light claim cards, oxblood evidence contract and user-authorized sunset actions, retained unreviewed labels.
5. **Discovery Engine, Claim Lab and Research Desk**: formerly green/dark workbench chrome becomes a genuine light editorial palette. The dark setting remains separately navy/violet/champagne.

## Implementation and protection

`docs/golden-hour-light.css` is a dedicated theme-only sheet imported by the existing, shared `docs/ethereal-theme.css`. **Every selector is conditional on `html:not([data-nf-theme="dusk"])`**, leaving dusk's styles and calculations unchanged; the existing global control persists both directions.

Visual acceptance: `scripts/test_golden_hour_light.mjs` covers 10 key pages on 390px and 1280px viewports, computed colors, contrast, overflow, missing assets, and reversible dusk. The complete website suite also covers site navigation, tools, source integrity, and 25-page theme behavior. Changes must not be promoted unless these tests pass.
