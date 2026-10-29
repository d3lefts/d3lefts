# NIGHTFALL | CONSTELLATION — Dusk Palette

**Historical palette (superseded 29 October 2026).** Current implementation and audit: [Two Skies palette](TWO_SKIES_PALETTE_20261029.md). Original values below are retained as design provenance.


**29 October 2026 · Scoped visual system · No scientific claim changes**

The dusk theme uses **midnight navy + violet + moon-gold**. The warm accent marks human-selected actions, focused objects, and research navigation. The original light/editorial research-paper theme remains unchanged. Scientific statuses and relationship types retain their literal labels, source and qualified scope.

| Role | Value | Usage |
|---|---|---|
| Midnight canvas | `#101727` | Sky and global backgrounds |
| Deep surface | `#1B263B` | Research cards, evidence trays and workspaces |
| Raised surface | `#222D45` | Selected/raised panels |
| Primary text | `#EDF0FB` | Reading and body copy |
| Secondary text | `#B7BED5` | Captions, metadata |
| Violet | `#CBBBEF` | Atmospheric secondary tone and conceptual links |
| **Moon-gold** | **`#D8C38A`** | Main action, focus mark, selected state |
| Champagne highlight | `#E6D4A6` | Hover and high-priority focus |
| Muted brass | `#8F7A4A` | Borders and hairlines only; too dark for small text on navy |
| Gold wash | `rgba(216,195,138,.16)` | Gentle selected-state glow |
| Button foreground | `#151B30` | Dark text atop gold |

## Accessible contrast

Static WCAG contrast checks for representative combinations:

- Moon-gold on midnight `#101727`: **10.30:1**.
- Navy `#151B30` on moon-gold: **9.82:1**.
- Caption `#B7BED5` on navy panel `#1B263B`: **8.18:1**.
- Brass `#8F7A4A` on navy panel: **3.64:1**, reserved for graphical accents, never standard text.

## Scientific visual meaning

A graph edge must remain labeled as an independently checked finite calculation, documented method, open premise, or untested analogy. Dusk may replace residual green color with gold/violet/coral/slate while preserving the **line style, type label, source link, and qualification note**. Presentation cannot reclassify a hypothesis as evidence or a locally tested result as independent peer review.

Dusk should remain calm around mathematical expressions: no stars on Living Paper reading surfaces, no motion if the visitor requests reduced motion. One global LIGHT / DUSK toggle persists across pages, and switching modes never changes research state.

## Implementation

All dusk changes live under `html[data-nf-theme="dusk"]` in `docs/ethereal-theme.css`, loaded after original page styles. The high-level tokens are `--nf-night`, `--nf-night-panel`, `--nf-violet`, `--nf-champagne`, `--nf-champagne-hover`, `--nf-brass`, `--nf-gold-wash`, `--nf-dusk-ink`, `--nf-dusk-muted`.

Validation: `scripts/test_ethereal_theme.mjs` covers both 390px mobile and 1280px desktop, primary navigation, research cards, Observatory selection, Constellation controls, 25 pages, reduced-motion behavior and preserving light-mode appearance.

## October 29 final palette check

The canonical lightray gold in midnight mode is `#D8C38A`; the `--nf-lightray-gold` alias shares this value with `--nf-champagne`. Navy and violet carry the atmospheric workbench; scientific annotations retain their labels and evidence scope.
