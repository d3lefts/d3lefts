# Commonwealth Discover — Gen Z political archetypes / visual reference v1.0

**Selected direction:** the Gen Z editorial-sticker treatment approved in the Commonwealth conversation, 2026-11-15. Source image generation ID: `a6a0ab03-676d-4e83-a218-a6b391512052` (the original rendered raster remains in the design conversation). This repository guide and the 12 **original vector sticker illustrations** are durable, editable implementation references, not an assertion that the rendered screenshot's raster is checked in.

## Design contract

- **Mood:** dark midnight UI, neon/holographic gradient CTAs, oversaturated four-column collectible-card grid, halftone/risograph grain, mischievous stickers, pop-cultural visual objects, editorial typography, emoji-like characters rather than classical portrait AI art.
- **Typography:** heavy sans display; white paper-cutout ribbons with black titles; short clear copy. No serif heads in Discover.
- **Colors:** each archetype owns one saturated accent; the general canvas stays midnight `#090c20`. Meet legible contrast over busy illustrations with separate dark copy panels.
- **Layout:** 4 columns desktop, 2 tablet, 1 narrow phone for readability; illustrations above labels, titles and 2–3 readable lines of profile text. The actual 20-question CTA precedes the collection, with the quiz form accessible via anchor.
- **Behaviors:** show all 12 archetypes, allow complete/skip/restart/back, always return a clearly marked *illustrative* archetype, and never interpret unanswered/neutral positions as a policy stance. A zero-answer result is a clearly identified **starter pick**, not a measured profile. The voluntary Living Voter profile stays separate and is local to the page.
- **Integrity:** no real vote, official endorsement, score of civic virtue, behavioral targeting, registration, credential checks, tracking, or unconsented storage.
- **Share surface:** share just the explicitly accepted *archetype name and brief description*; never include question responses, individual history, or claims of psychometric validation.
- **Reproduce:** `node scripts/test_commonwealth_intelligence.cjs` and (with Playwright/Chromium) `node scripts/test_commonwealth_journey.mjs`; inspect `docs/commonwealth-archetypes.js` for canonical labels and vector asset identifiers.

## Twelve original archetype profiles

### 01 · The Civic Creator

![The Civic Creator illustration](../../../docs/commonwealth-archetypes/civic-creator.svg)

**Community-led change · #ff3887** — Make it real.

Turns collective ideas into real local experiments. Likes participatory projects, open meetings, and communities that help shape the rules.

### 02 · The Tech Reformist

![The Tech Reformist illustration](../../../docs/commonwealth-archetypes/tech-reformist.svg)

**Open-source government · #2869ff** — Patch the system.

Wants transparent systems, less paperwork, and public services that actually work. Sees technology as a tool for accountability, not a substitute for people.

### 03 · The Climate Guardian

![The Climate Guardian illustration](../../../docs/commonwealth-archetypes/climate-guardian.svg)

**Energy and resilience · #22c99d** — Future-proof it.

Focuses on clean energy, resilient infrastructure, and protecting shared environments. Thinks long-term public decisions should count environmental costs.

### 04 · The Liberty Defender

![The Liberty Defender illustration](../../../docs/commonwealth-archetypes/liberty-defender.svg)

**Rights and due process · #ffca25** — Know your rights.

Keeps personal freedoms, privacy, and due process in view. Wants public authority clearly limited, accountable, and open to challenge.

### 05 · The Equality Champion

![The Equality Champion illustration](../../../docs/commonwealth-archetypes/equality-champion.svg)

**Fair access and opportunity · #a84cff** — Everyone counts.

Prioritizes equal treatment, accessible institutions, and removing barriers to participation. Sees civil rights as a practical public responsibility.

### 06 · The Working American

![The Working American illustration](../../../docs/commonwealth-archetypes/working-american.svg)

**Jobs and livelihoods · #ff793c** — Built by us.

Looks at policy through wages, training, affordability, and stable work. Wants local economies where people can build secure lives.

### 07 · The Community Builder

![The Community Builder illustration](../../../docs/commonwealth-archetypes/community-builder.svg)

**Neighborhood power · #f33fca** — People make places.

Starts with neighbors, schools, and the places people share. Values local relationships and public investments people can see firsthand.

### 08 · The Global Minded

![The Global Minded illustration](../../../docs/commonwealth-archetypes/global-minded.svg)

**Diplomacy and cooperation · #22cfea** — Think bigger.

Looks beyond borders to cooperation, trade, diplomacy, and shared problems. Values practical alliances while questioning their costs and commitments.

### 09 · The Security Sentinel

![The Security Sentinel illustration](../../../docs/commonwealth-archetypes/security-sentinel.svg)

**Safety and preparedness · #20bddb** — Stay ready.

Emphasizes public safety, resilience, cybersecurity, and disaster readiness. Wants strong safeguards, clearly defined powers, and preparedness before crisis.

### 10 · The Care Advocate

![The Care Advocate illustration](../../../docs/commonwealth-archetypes/care-advocate.svg)

**Health and family support · #ff4ea8** — Care is infrastructure.

Focuses on access to healthcare, caregiving, and the daily conditions of family life. Measures policy by how it affects people who rely on services.

### 11 · The Opportunity Builder

![The Opportunity Builder illustration](../../../docs/commonwealth-archetypes/opportunity-builder.svg)

**Enterprise and mobility · #f4ae21** — Open more doors.

Favors paths to entrepreneurship, skills, and economic opportunity. Examines how rules can help or hinder people starting something new.

### 12 · The Balanced Pragmatist

![The Balanced Pragmatist illustration](../../../docs/commonwealth-archetypes/balanced-pragmatist.svg)

**Tradeoffs and evidence · #a38aff** — Show the receipts.

Looks for measurable outcomes, realistic budgets, and workable compromises. Changes course when a policy experiment does not deliver.


### Scoring / inference limitations

The 20-question exercise is descriptive product fiction, not a psychometric instrument. Topic-linked scoring records only explicit directional responses; it does not infer support for unrelated policies. Ties use a stable documented order, not a claim of statistical certainty. Neutral and skipped inputs are zero-weight. With no directional answers, the starter badge is a transparent sample. The illustrated persona should never be used to infer how someone votes or to target political persuasion.

### Implementation provenance

- Design direction: user-selected ChatGPT-generated concept (generation ID above); source-image metadata is retained in this guide.
- Vector icons: authored specifically for this demo as reproducible SVG artwork.
- This guide is not evidence of user testing, product-market fit, government affiliation, or legal certification.
