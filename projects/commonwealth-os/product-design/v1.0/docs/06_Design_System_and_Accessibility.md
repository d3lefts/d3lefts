# Design system, content style and accessibility

**Commonwealth OS / Product Design v1.0 — 15 November 2026**  
**Status:** Proposal / not institutionally authorized  
**Scope:** Huntsville institutional pilot; mobile-first  

## Visual direction

Working identity: **quiet civic technology** — institutional credibility with modern mobile usability. Existing prototype tokens (concept values, **not contrast-certified**) are: deep ink `#071B26`, body ink `#102631`, teal `#008B83`, pale mint `#B5ECBD`, canvas `#F8F8F4`, muted `#65808C`, border `#E3E8E6`. Prototype typography uses an accessible sans stack for body and a restrained serif for large headings. Audit all contrast pairs in actual states before use.

## Basic tokens

| Token | Proposed value | Purpose |
|---|---|---|
| `color.surface.base` | #F8F8F4 | Main background |
| `color.surface.elevated` | #FFFFFF | Cards |
| `color.text.primary` | #102631 | Main copy |
| `color.text.secondary` | #65808C | Supporting copy (contrast test required) |
| `color.brand.deep` | #071B26 | Navigation and primary controls |
| `color.brand.accent` | #008B83 | Interactive emphasis (contrast test required) |
| `color.brand.soft` | #B5ECBD | Selected / progress support |
| `radius.card` | 18px | Dense cards |
| `radius.button` | 12px | Main actions |
| `spacing.base` | 4px | Scale: 4,8,12,16,24,32 |

## Components

- **AuthorityBadge:** advisory, institution-authorized, binding-lawfully-verified, unknown; do not rely on color alone.
- **EvidenceChip:** official source / imported unverified / disputed / stale / synthetic.
- **PreferenceSelector:** three explicit choices, no preselected default, full keyboard and assistive tech controls.
- **VersionDiff:** inline changed clauses, effective date, semantic change classification and original PDF/text link.
- **BallotPanel:** motion hash, eligibility, expiration, vote method and final confirmation distinct from ordinary preferences.
- **ProofPassportCard:** audit status, hashes, rule links, current validation status, audit trail export.
- **AssistantDrawer:** tool scopes and provenance, clear AI nature, human confirmation for authorized actions.
- **ConsentPanel:** purpose-specific choices, retention, export/delete, institutional research constraints.

## Accessibility acceptance criteria

Target WCAG 2.2 AA for public-facing experience (to be formally audited); text zoom at 200% and 400% without functional loss where relevant; all controls accessible by keyboard and screen reader; focus order and visible focus, persistent descriptive labels, no color-only meanings, captions/transcripts for video, reduced-motion support, error recovery, 44px target guideline with appropriate WCAG target exceptions, bilingual/plain-language research in Huntsville when participants warrant it. Make real legal text available in native accessible format whenever possible.

## Motion and latency

No animated pressure or voting countdown manipulation. Respect system reduced-motion. Low-end Android and iPhone performance are explicit test devices. Offline preference draft saves may be allowed; **binding votes require a verified server receipt and reconnect-safe idempotency**, not a local success animation.

## Content standards

Use “Proposed,” “In effect,” “Repealed,” “Integrated (editorial),” “Verified by institution,” and “Not verified” precisely. Avoid “Your voice changed the law” without proven causality. Every aggregate statistic includes the eligible denominator, participant count, response rate and any weighting method. AI-generated material labelled as such with direct source links.
