"use strict";
/* Curated, versioned canonical source for on-site Proof Passports and Mechanism Atlas. */
(function(global){
const REGISTRY={
  "schema": "nightfall-proof-passports-v1",
  "asOf": "2026-10-30",
  "editorialScope": "Eleven curated evidence passports (six existing and five added 2026-10-30), across an unchanged 33-dossier research library. Evidence tiers describe only their exact claims; no additions to the separate originality approval whitelist.",
  "dimensions": [
    "validity",
    "reproducibility",
    "originality",
    "significance"
  ],
  "claims": [
    {
      "id": "sidon30",
      "title": "30-point Sidon construction",
      "field": "Additive combinatorics",
      "kind": "Original finite construction",
      "short": "An explicit 30-integer weak (4,5) set has largest Sidon subset of size 17.",
      "statement": "For the published, explicitly enumerated 30-element weak Sidon (4,5) set B, the largest Sidon subset has cardinality h(B)=17.",
      "conditions": "Specific published 30-point coordinate list; weak (4,5) test; exact finite AP hitting-set exclusion. This is not an asymptotic bound.",
      "measurement": "17 / 30",
      "metric": "Exact finite maximum",
      "validity": {
        "level": "finite",
        "label": "Exact finite certificate",
        "detail": "An explicit 17-point subset and exhaustive finite exclusion of every 18-point Sidon subset are documented."
      },
      "reproducibility": {
        "level": "public",
        "label": "Public executable verifier",
        "detail": "30-point text input and a standalone standard-library Python verifier are published; external specialist review remains open."
      },
      "originality": {
        "level": "scoped",
        "label": "Distinct finite witness",
        "detail": "A finite compression construction; the asymptotic 5/9 reduction belongs to prior researchers."
      },
      "significance": {
        "level": "bounded",
        "label": "Finite extremal example",
        "detail": "A checkable concrete witness and proof DAG, without a claim of worldwide asymptotic priority."
      },
      "assumptions": [
        "The 30 coordinates are distinct and ordered.",
        "The weak (4,5) condition is checked on every four-point subset.",
        "Sidon means every unordered pair sum, including repeated indices, is unique within the subset.",
        "An exact exclusion search covers all 12-point AP transversals."
      ],
      "open": [
        "Independent external specialist audit of the finite certificate.",
        "Separate analysis of any broader infinite-family claims."
      ],
      "sources": [
        {
          "label": "Construction and proof scope",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/sidon-finite-30/README.md"
        },
        {
          "label": "Original witness bytes",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/sidon-finite-30/witness_30.txt"
        },
        {
          "label": "Independent Python finite checker",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/sidon-finite-30/verify_sidon30_standalone.py"
        },
        {
          "label": "Complete 28-constraint essentiality certificate (JSON)",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/sidon-finite-30/edge_essentiality_certificate.json"
        },
        {
          "label": "Independent edge-essentiality proof generator and checker",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/sidon-finite-30/edge_essentiality.py"
        }
      ],
      "tools": [
        "referee.html",
        "review.html#sidon"
      ],
      "history": [
        {
          "date": "2026-10-24",
          "kind": "published-note",
          "label": "Finite witness documented",
          "detail": "The 30-point construction and its finite-only scope were recorded.",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/sidon-finite-30/README.md"
        },
        {
          "date": "2026-10-28",
          "kind": "evidence",
          "label": "Proof DAG and standalone check documented",
          "detail": "The public note reports 7,801 proof states, 28 progressions and a separately executable Python checker.",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/sidon-finite-30/README.md"
        },
        {
          "date": "2026-10-28",
          "kind": "evidence",
          "label": "All 28 arithmetic-progression constraints proven essential",
          "detail": "For the fixed 30-point witness, the exact 12-cover exclusion and 28 explicit 18-survivor counterwitnesses independently regenerate from published source. A distinct finite hypergraph property; novelty review open.",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/sidon-finite-30/edge_essentiality.py"
        }
      ]
    },
    {
      "id": "erdos36",
      "title": "Erdős minimum overlap",
      "field": "Extremal optimization",
      "kind": "Original finite upper-bound witness",
      "short": "A 131,072-cell exact rational step-function witness has a reported continuous-shift upper-bound score.",
      "statement": "An explicitly defined 131,072-cell uniform-step construction on [0,2] has internally replayed continuous signed-shift maximum 0.380856370118029325246… under its stated conventions.",
      "conditions": "Integer heights over a common 2^70 denominator; exact mass one; zero extension; signed lag k with i−k indexing and breakpoint maximum.",
      "measurement": "0.380856370118…",
      "metric": "Internal exact upper bound",
      "validity": {
        "level": "finite",
        "label": "Internally exact-replayed finite witness",
        "detail": "The archived collaboration reports independent integer-convolution replay and a grid-to-continuum argument; external expert audit remains open."
      },
      "reproducibility": {
        "level": "public",
        "label": "Curated finite witness public; independent audit open",
        "detail": "The approved public mathematical ZIP contains the 131,072-cell heights and independent finite arithmetic checker; anonymous download SHA-256 and replay checks were recorded on 2026-10-29. Historical master archives remain private. This is public reproducibility, not external peer review."
      },
      "originality": {
        "level": "scoped",
        "label": "Distinct finite construction",
        "detail": "An explicit witness under a common normalization; mathematical comparison does not by itself establish competition entry identity."
      },
      "significance": {
        "level": "bounded",
        "label": "Strong numerical upper-bound candidate",
        "detail": "Lower numerical score than separately sourced comparison witnesses, contingent on independent reproduction and historical comparability."
      },
      "assumptions": [
        "Precisely specified signed lag convention and zero extension.",
        "All step heights lie in [0,1] and integrate to mass one.",
        "No equivalence is assumed between the accepted Arena input and the archive witness.",
        "The original height-array identity and public curated release checksum must be checked when reproducing the finite result."
      ],
      "open": [
        "Obtain independent, externally authored reproduction of the published 131,072-cell witness.",
        "Independent external reproduction and source identity comparison.",
        "Recover accepted competition input identity (issue #6).",
        "Independently audit the conditional lower-bound dual returns and inherited analytic and interval-arithmetic premises."
      ],
      "sources": [
        {
          "label": "Claim scope and prior-art audit",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/erdos/STATUS_AND_PRIOR_ART_20261028.md"
        },
        {
          "label": "Public witness, checksums and reproduction commands",
          "url": "evidence.html"
        },
        {
          "label": "Approved public binary release",
          "url": "https://github.com/d3lefts/d3lefts/releases/tag/nightfall-research-2026-10-28"
        },
        {
          "label": "Conditional lower-bound derivation and outstanding source obligations",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/agent-reports/ea36_lower_20261028/RESEARCH_NOTE.md"
        }
      ],
      "tools": [
        "referee.html",
        "review.html#erdos"
      ],
      "history": [
        {
          "date": "2026-10-27",
          "kind": "internal-replay",
          "label": "Internal bigint replay reported",
          "detail": "The audit reports an exact signed-shift maximum and independent implementation within the research collaboration.",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/agent-reports/ea36_131072/EA36_AGENT_AUDIT_REPORT.md"
        },
        {
          "date": "2026-10-28",
          "kind": "scope-correction",
          "label": "Mathematical witness separated from Arena entry",
          "detail": "The source audit distinguishes the internal construction, accepted leaderboard snapshot and rejected submission.",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/erdos/STATUS_AND_PRIOR_ART_20261028.md"
        },
        {
          "date": "2026-10-29",
          "kind": "public-evidence-release",
          "label": "Approved curated witness released and anonymous replay recorded",
          "detail": "The approved mathematical evidence ZIP provides the 131,072-cell heights and checker. Anonymous asset checks and independent-internal arithmetic replay passed; external peer review and accepted Arena payload recovery remain open.",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/CURATED_PUBLIC_DOWNLOAD_RECEIPT_20261029.json"
        }
      ]
    },
    {
      "id": "phase",
      "title": "Fourth-power finite-field reconstruction",
      "field": "Finite-field algebra",
      "kind": "Theorem campaign · conditional",
      "short": "A lattice-decoding research line has downstream exact checks and an unresolved foundational counting premise.",
      "statement": "A proposed fourth-power finite-field phase-retrieval decoder depends on a span-count premise; a 2⁻⁹⁶ tail estimate is conditional on that premise.",
      "conditions": "Specified finite-field extension and sampling regime; key span-count lemma and full decoder audit are unresolved.",
      "measurement": "2⁻⁹⁶",
      "metric": "Conditional tail estimate",
      "validity": {
        "level": "conditional",
        "label": "Conditional reduction",
        "detail": "Exact downstream calculations do not discharge the foundational span-count lemma."
      },
      "reproducibility": {
        "level": "partial",
        "label": "Partial downstream checks",
        "detail": "Arithmetic components are reported, while the foundational lemma, full decoder, and novelty audit are open."
      },
      "originality": {
        "level": "open",
        "label": "Priority audit open",
        "detail": "Do not treat the proposed reduction as an established new theorem."
      },
      "significance": {
        "level": "prospective",
        "label": "Potential recovery mechanism",
        "detail": "A successful proof could yield an efficient decoder within the stated regime; current status is conditional."
      },
      "assumptions": [
        "Foundational span-count premise must be established independently.",
        "Decoder correctness, failure probability and runtime require separate complete proofs."
      ],
      "open": [
        "Prove the missing span-count lemma without circularity.",
        "Independently validate the full decoding theorem and novelty."
      ],
      "sources": [
        {
          "label": "Current theorem and proof audit",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/finite-field-phase-retrieval-2026-10-28/README.md"
        }
      ],
      "tools": [
        "discovery.html",
        "exact-research.html"
      ],
      "history": [
        {
          "date": "2026-10-28",
          "kind": "scope-correction",
          "label": "Foundational lemma kept as an open premise",
          "detail": "The research library explicitly distinguishes the downstream tail bound from its unverified counting hypothesis.",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/finite-field-phase-retrieval-2026-10-28/README.md"
        }
      ]
    },
    {
      "id": "adaptive",
      "title": "Deterministic adaptive finite-field decoder",
      "field": "Finite-field algebra",
      "kind": "Algebraic proof candidate · independently coded exhaustive tests",
      "short": "New q=3 cancellation packing retrieves r relative signs per mixed query: k+⌈(k−1)/r⌉ worst-case; general q>2 baseline remains k+⌈(k−1)/(r−1)⌉.",
      "statement": "For K=F_(3^r), r≥2, two-round adaptive square measurements recover every x modulo ±1 using k+⌈max(s−1,0)/r⌉ queries, with exact k+1 optimality for 2≤k≤r+1; one mixed query packs r relative signs, sharply. For all q>2, the earlier bound k+⌈max(s−1,0)/(r−1)⌉ remains valid; q=2 optimum is k.",
      "conditions": "Two rounds, explicitly represented extension field, noiseless K-linear queries with a selectable basis, first-round coordinate phases, second-round batch mixing, global F_q× ambiguity; q=2 exception stated separately.",
      "measurement": "k + ⌈(k−1)/r⌉",
      "metric": "Worst-case two-round queries · q=3",
      "validity": {
        "level": "working",
        "label": "Complete batched proof argument · external review open",
        "detail": "For q=3, zero-pattern cancellation packs r relative signs per mixed query and reaches k+1 for 2≤k≤r+1; a linear-dependence argument proves this per-query packing is sharp. General q>2 packs r−1. Independent referee review remains open."
      },
      "reproducibility": {
        "level": "finite",
        "label": "332,086 exact finite inputs pass",
        "detail": "The previous two independent checkers pass 332,086 exact inputs and 3,000 nonadaptive collisions. A separate characteristic-three checker passes 54,461 additional reconstruction trials and six constructive one-query collisions. Mathematical validity for arbitrary r is carried by the supplied proof argument."
      },
      "originality": {
        "level": "open",
        "label": "Same-model priority review open",
        "detail": "The complementary nonadaptive obstruction is a finite-field application of the known complement-property argument. Extension-degree batch packing, global optimality, and same-model adaptive separation require independent novelty review."
      },
      "significance": {
        "level": "prospective",
        "label": "Measurement-optimal high-extension decoding",
        "detail": "For q=3 and 2≤k≤r+1, k+1 adaptive measurements are globally optimal, with further counting-optimal dimensions; every fixed nonadaptive design needs at least 2k−1. For other q>2, the earlier high-extension optimality range remains 2≤k≤r."
      },
      "assumptions": [
        "Oracle returns (a·x)^(q−1) with arbitrarily chosen K-linear rows; second-round rows adapt to first-round output.",
        "The extension-field basis and finite-field arithmetic are explicitly available.",
        "Exact reconstruction is modulo a single global factor in F_q×, with no noise guarantee.",
        "For q=2, power measurements reveal coordinates directly: exact minimum k.",
        "Comparisons with a separate random nonadaptive fourth-power lattice decoder involve different measurement hypotheses."
      ],
      "open": [
        "Non-author proof verification of extension-degree packed linear extraction and global lower-bound counting.",
        "Same-model novelty and priority audit, including existing complement-property and adaptive phase retrieval literature.",
        "Exact optimal measurement complexity for k>r and potentially compressed sparse-support localization.",
        "Noise and corrupt-response robustness without losing the phase-packing advantage."
      ],
      "sources": [
        {
          "label": "New characteristic-three cancellation packing theorem and sharp one-query obstruction",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/adaptive-finite-field-decoder-2026-10-29/CHARACTERISTIC_THREE_CANCELLATION_20261029.md"
        },
        {
          "label": "Characteristic-three cancellation exact verifier",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/adaptive-finite-field-decoder-2026-10-29/verify_q3_cancellation.py"
        },
        {
          "label": "Batched theorem, proofs, lower bounds and prior-art boundary",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/adaptive-finite-field-decoder-2026-10-29/EXTENSION_DEGREE_PACKING_20261029.md"
        },
        {
          "label": "Prime-base exact decoder and nonadaptive collision checker",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/adaptive-finite-field-decoder-2026-10-29/verify_extension_packing.py"
        },
        {
          "label": "Independent characteristic-two F4-subfield verifier",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/adaptive-finite-field-decoder-2026-10-29/verify_characteristic_two_subfield.py"
        },
        {
          "label": "Public proof dossier and audit scope",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/adaptive-finite-field-decoder-2026-10-29/README.md"
        },
        {
          "label": "Independent exhaustive Python checker",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/adaptive-finite-field-decoder-2026-10-29/checker.py"
        },
        {
          "label": "Separate sparse-prime coefficient menu audit",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/adaptive-finite-field-decoder-2026-10-29/separator_checker.py"
        }
      ],
      "tools": [
        "referee.html",
        "exact-research.html"
      ],
      "history": [
        {
          "date": "2026-10-29",
          "kind": "proof-candidate",
          "label": "Adaptive decoder promoted to fourth flagship",
          "detail": "Axiom's adaptive decoder, general-extension proof argument and independently coded exact finite audits published as a flagship research program. External referee and priority audit remain open.",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/adaptive-finite-field-decoder-2026-10-29/README.md"
        },
        {
          "date": "2026-10-29",
          "kind": "proof-candidate",
          "label": "Extension-degree packing improves adaptive measurement count",
          "detail": "General two-round bound k+ceil((k−1)/(r−1)), exact k+1 optimality when 2≤k≤r and q>2, and a same-model nonadaptive complement-property lower bound. Verified by 332,086 reconstructions and 3,000 collision certificates; external review pending.",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/adaptive-finite-field-decoder-2026-10-29/EXTENSION_DEGREE_PACKING_20261029.md"
        }
      ]
    },
    {
      "id": "werner",
      "title": "Werner-state finite-copy positivity",
      "field": "Quantum information",
      "kind": "Conditional certificate program",
      "short": "Exact rational certificates across copy counts rely on explicitly imported upstream inequalities.",
      "statement": "The finite-copy Werner program reports exact rational constructions, with quantitative undistillability conclusions conditional on identified source inequalities and scope.",
      "conditions": "Each bound requires its stated dimension, copy count, separability premise and upstream analytic inequality.",
      "measurement": "4–25",
      "metric": "Copy-count evidence atlas",
      "validity": {
        "level": "conditional",
        "label": "Exact identities · conditional conclusions",
        "detail": "Finite rational arithmetic and source-theorem-dependent deductions have distinct proof gates."
      },
      "reproducibility": {
        "level": "partial",
        "label": "Source-dependent checks",
        "detail": "Published research dossiers record certificates and assumptions; analytic source-premise verification remains an open task."
      },
      "originality": {
        "level": "open",
        "label": "Novelty varies by certificate",
        "detail": "No universal record or resolved endpoint is implied by the presence of exact arithmetic."
      },
      "significance": {
        "level": "prospective",
        "label": "Finite-copy quantum certificate program",
        "detail": "A route to improved thresholds where analytic assumptions are fully established."
      },
      "assumptions": [
        "Exact copy count and local dimension must be carried with each claim.",
        "Imported analytic positivity inequalities must be verified in their source scope."
      ],
      "open": [
        "Verify imported inequalities separately from exact rational identities.",
        "Commission independent review for highest-value individual thresholds."
      ],
      "sources": [
        {
          "label": "Four- through 25-copy research atlas",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/werner-final-4-25/README.md"
        }
      ],
      "tools": [
        "exact-research.html",
        "discovery.html"
      ],
      "history": [
        {
          "date": "2026-10-28",
          "kind": "scope-correction",
          "label": "Tiered certificate inventory",
          "detail": "The public library records exact rational steps separately from unresolved analytic source dependencies.",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/werner-final-4-25/README.md"
        }
      ]
    },
    {
      "id": "pas",
      "title": "Proof After Scarcity: archived retrospective check",
      "field": "Research systems",
      "kind": "Historical bounded empirical record",
      "short": "An archived 20-case prioritization study reported upstream-first 11/20 versus risk-priority 8/20.",
      "statement": "In a bounded 20-case internal experiment, upstream-first selected 11/20 and the risk-priority method selected 8/20 under the reported evaluation rules.",
      "conditions": "One specified 20-case comparison, not a general population or transfer-efficacy theorem.",
      "measurement": "8/20 vs 11/20",
      "metric": "Reported adverse result",
      "validity": {
        "level": "empirical",
        "label": "Archived outcome-aware comparison",
        "detail": "A narrow adverse comparison, not proof that either policy dominates generally."
      },
      "reproducibility": {
        "level": "partial",
        "label": "Experiment record archived",
        "detail": "The historical audit preserves recorded protocol and outcomes; independent reproduction remains open. New PAS v2 does not use this as proof of prospective advantage."
      },
      "originality": {
        "level": "scoped",
        "label": "Previously approved bounded audit",
        "detail": "The observation is original to this finite evaluation; broad verification-priority methods and related literature predate it."
      },
      "significance": {
        "level": "bounded",
        "label": "Retained methodological history",
        "detail": "Evidence for retaining failed prioritization tests and measuring verification strategy, not a general efficacy guarantee."
      },
      "assumptions": [
        "The compared strategies use the same frozen 20-case evaluation.",
        "Only this bounded benchmark and its reported outcome are asserted."
      ],
      "open": [
        "Replication on independently curated held-out problems.",
        "Assess whether any methodological changes improve matched-budget outcomes."
      ],
      "sources": [
        {
          "label": "Historical evaluation protocol and limitations",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/pas/RETROSPECTIVE_20261013.md"
        }
      ],
      "tools": [
        "claim-lab.html",
        "discovery.html"
      ],
      "history": [
        {
          "date": "2026-10-28",
          "kind": "negative-result",
          "label": "Retrospective comparison preserved separately from PAS v2",
          "detail": "The published site preserves 8/20 against the stronger 11/20 baseline, without claiming general improvement.",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/pas-overview.md"
        }
      ]
    },
    {
      "id": "asua-collateral",
      "title": "Information-limited safety guards",
      "field": "Agent safety",
      "kind": "Conditional mathematical model · finite benchmark observation",
      "short": "Sound enforcement can force legitimate-task denials when a guard cannot distinguish harmful and permitted calls.",
      "statement": "Under a universal soundness requirement and an observation map α, a permitted action sharing the same observed fiber with a forbidden action cannot be permitted by any guard using only α. In the scoped archived AgentDojo analysis, a name-only sound guard is reported to deny 45 of 60 legitimate user tasks.",
      "conditions": "The impossibility is conditional on the prescribed soundness contract, action partition and guard observation. The 45/60 count applies only to the archived 60-task finite cohort, not deployed CaMeL, general agents or actual completed tasks.",
      "measurement": "45 / 60",
      "metric": "Reported name-only collateral floor",
      "validity": {
        "level": "conditional",
        "label": "Formal fiber obstruction; data scope constrained",
        "detail": "The observation-fiber implication is elementary and written down. The benchmark count is source-reported; no new cross-version benchmark replay was performed for this passport."
      },
      "reproducibility": {
        "level": "partial",
        "label": "Manuscript accessible by description; public replay incomplete",
        "detail": "The public dossier records the 58-property reconstruction audit, but the original 43-page manuscript and full independent finite counter still require public mirroring."
      },
      "originality": {
        "level": "open",
        "label": "General factor criterion is prior art",
        "detail": "Factorization through observation fibers and set-cover formulations are established. Any new contribution must concern the exact safety contract, bounds or grounded operational measurements."
      },
      "significance": {
        "level": "prospective",
        "label": "Potential policy collateral benchmark",
        "detail": "Separates information-theoretic unavoidable denials from implementation errors, provided the benchmark and runner are harmonized."
      },
      "assumptions": [
        "A guard observes α(action) but cannot inspect distinctions inside an α-fiber.",
        "Soundness requires blocking every forbidden action under the stated action model.",
        "The reported 60-task set and side-effect interpretation are fixed; task success and guard decisions are different outcomes.",
        "No comparison is made to an incompatible AgentDojo or CaMeL benchmark revision."
      ],
      "open": [
        "Publish the frozen task/observation sets and standalone exact collision counter.",
        "Reconcile the shipped CaMeL runner version against the 60-task AgentDojo cohort before empirical comparisons.",
        "Run a held-out end-to-end guard evaluation distinguishing policy denials from model execution errors.",
        "Independent specialist audit of the formal model, conventional prior art and operational threat assumptions."
      ],
      "sources": [
        {
          "label": "ASUA scope, theoretical dependencies and bounded counts",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/agent-safety-under-abstraction/README.md"
        },
        {
          "label": "AI-safety independent review dossier",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/ai-safety-peer-review-2026-10-28/README.md"
        }
      ],
      "tools": [
        "adversary.html",
        "review.html"
      ],
      "history": [
        {
          "date": "2026-09-30",
          "label": "Finite reconstruction audit reported",
          "detail": "The research dossier records 58 finite property checks and a policy-simulator attachment-shape issue; no live-model result follows.",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/agent-safety-under-abstraction/README.md"
        }
      ]
    },
    {
      "id": "shadow-nonabelian",
      "title": "Nonabelian involution-shadow codes",
      "field": "Finite groups and coding",
      "kind": "Self-contained algebraic theorem candidate · public finite tests",
      "short": "The full distance spectrum and sharp erasure allocation reduce to coset-label occupancies for any finite group with a nontrivial involution.",
      "statement": "For finite G with nonidentity involutive automorphism S, H=Fix(S), q=|G|/|H| and m translation measurements, min_(x≠y) d_H(C_T(x),C_T(y)) = m − max_c n_c; its optimal value is m − ceil(m/q). The ordered-pair distance enumerator and every fixed-cardinality erasure ambiguity count also depend only on the occupancy vector.",
      "conditions": "Orbit symbols [xt]_S under right-translated measurements; twisted labels δ(t)=S(t)t⁻¹ whose fibers are left cosets tH, with no normal-subgroup assumption. The statement concerns message separation, which can be zero.",
      "measurement": "m − ⌈m/q⌉",
      "metric": "Sharp balanced distance",
      "validity": {
        "level": "working",
        "label": "Written universal algebraic proof; external referee open",
        "detail": "The source derives collision equivalence, coset fibers, sharp Hamming separation and erasure minimization. Universal quantifiers have not received kernel-level or human external review."
      },
      "reproducibility": {
        "level": "public",
        "label": "Public S₄ witness and independent finite checkers",
        "detail": "An explicit 24-element S₄ certificate, Cayley-table checker and erasure optimality checker are public. Historical broader test-count reports are not a new run here."
      },
      "originality": {
        "level": "open",
        "label": "Established Cartan-embedding mechanism",
        "detail": "The coset-label identity and related twisted permutation codes have prior art. Whether the combined distance-spectrum and erasure statement is new remains unresolved."
      },
      "significance": {
        "level": "prospective",
        "label": "One occupancy invariant controls multiple channels",
        "detail": "Unifies minimum distance, complete pair spectrum and identically distributed erasure reliability in a specific orbit-code family."
      },
      "assumptions": [
        "G is finite and S is a nonidentity automorphism satisfying S²=id.",
        "Translation labels are left-coset classes; the fixed subgroup need not be normal.",
        "The erasure-optimality conclusion assumes common coordinate survival probability; heterogeneous rates require a separate model.",
        "A positive message-separation bound is needed to claim an injective error-correcting code."
      ],
      "open": [
        "Independent proof review of all ordered-pair multiplicity and erasure formulas.",
        "Complete same-scope novelty assessment against twisted permutation codes, Cartan embeddings and orbit coding.",
        "Independently replay the published S₄ witness and the Cayley-table/erasure verifiers.",
        "Analyze nonuniform reliability without importing the symmetric-balancing conclusion."
      ],
      "sources": [
        {
          "label": "Universal algebraic proof, corrections and prior art",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/involution-shadow-codes/NONABELIAN_SHADOW_THEOREM.md"
        },
        {
          "label": "Explicit S₄ exact finite witness",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/involution-shadow-codes/S4_nonabelian_certificate.json"
        },
        {
          "label": "Cayley-table independent instance verifier",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/involution-shadow-codes/certify_nonabelian_instance.py"
        },
        {
          "label": "Independent erasure-optimality verifier",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/involution-shadow-codes/verify_nonabelian_erasure_optimum.py"
        },
        {
          "label": "Prior-art correction and review boundary",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/involution-shadow-codes/PRIOR_ART_ASSESSMENT_20261028.md"
        }
      ],
      "tools": [
        "referee.html",
        "exact-research.html"
      ],
      "history": [
        {
          "date": "2026-10-28",
          "label": "Nonabelian proof and S₄ certificate archived",
          "detail": "The public note reports a sharp distance formula and direct finite checks, while retaining unresolved external review.",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/involution-shadow-codes/NONABELIAN_SHADOW_THEOREM.md"
        },
        {
          "date": "2026-10-28",
          "label": "Left-coset and prior-art corrections published",
          "detail": "A right-coset terminology error was corrected; established Cartan and twisted-code constructions were credited.",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/involution-shadow-codes/PRIOR_ART_ASSESSMENT_20261028.md"
        }
      ]
    },
    {
      "id": "factor-network",
      "title": "Universal factor-network encoding",
      "field": "Algebraic computation",
      "kind": "Universal combinatorial proof · finite structural verifier",
      "short": "An explicit equality-bridge network preserves every finite factor partition function over any commutative semiring.",
      "statement": "For n q-ary variables, factor scope length L, v active variables and m factors, a trivalent occurrence/equality-bridge network with 3L−2v wires satisfies Z(F)=(q·1_R)^(n−v) Z(G(F)) for every commutative semiring R and every assignment of factor tables.",
      "conditions": "One occurrence vertex per scope position, right binary equality bridges and faithfully retained ordered factor ports. The edge-count minimality is ONLY within this bridge grammar; the identity includes repeated variables, unused variables and zero-arity factors.",
      "measurement": "3L − 2v",
      "metric": "Exact wires in bridge grammar",
      "validity": {
        "level": "working",
        "label": "Explicit universal assignment bijection",
        "detail": "The public proof constructs an inverse between satisfying wire labels and original active-variable assignments. No faster contraction algorithm or formal kernel proof is claimed."
      },
      "reproducibility": {
        "level": "public",
        "label": "Public per-instance certificate checker",
        "detail": "The transparent graph JSON and independent structural-checker source are in the repository; the dossier also reports broader stress tests whose original scripts are not all mirrored."
      },
      "originality": {
        "level": "scoped",
        "label": "COPY-tensor encoding is established prior art",
        "detail": "No priority is claimed for standard SAT-to-network reductions. Novelty, if any, is confined to this precise grammar-scoped edge accounting and proof-certificate implementation."
      },
      "significance": {
        "level": "bounded",
        "label": "Auditable reduction; no complexity collapse",
        "detail": "Turns a symbolic algebraic equivalence into a structurally inspectable finite certificate without asserting a subexponential SAT algorithm."
      },
      "assumptions": [
        "Alphabet Q is finite, |Q|=q≥2; coefficient operations form a commutative semiring.",
        "Input factor scopes preserve port order, including repeated variable positions.",
        "Graph wires connect occurrence indicators through same-variable binary equality bridges.",
        "The claim is an identity of partition functions, not a bound on contraction runtime."
      ],
      "open": [
        "Re-run the public structural checker on its frozen JSON example.",
        "Mirror the separately reported direct-contraction and adversarial scripts and outputs.",
        "Seek external independent proof audit and compare scope with established tensor-network/COPY representations.",
        "Keep unverified contraction-runtime hypotheses outside this reduction claim."
      ],
      "sources": [
        {
          "label": "Universal semiring identity, proof and prior work",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/sat-network-universal/THEOREM_AND_SCOPE.md"
        },
        {
          "label": "Public structural certificate checker",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/sat-network-universal/check_structural_certificate.py"
        },
        {
          "label": "Concrete machine-readable graph witness",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/sat-network-universal/example_graph.json"
        },
        {
          "label": "Finite agent audit verdict",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/sat-network-universal/AGENT_VERDICT.json"
        }
      ],
      "tools": [
        "referee.html",
        "exact-research.html"
      ],
      "history": [
        {
          "date": "2026-10-28",
          "label": "Proof and structural checker published",
          "detail": "The mathematical bijection and grammar-specific 3L−2v edge formula were documented with a public per-instance certificate checker.",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/sat-network-universal/THEOREM_AND_SCOPE.md"
        }
      ]
    },
    {
      "id": "erdos-dual-ceiling",
      "title": "Erdős eight-row dual ceiling",
      "field": "Exact optimization",
      "kind": "Scoped exact-rational obstruction · upstream premise conditional",
      "short": "A frozen eight-row rational certificate family has less than 6×10⁻¹⁵ room for further improvement without a new dual geometry.",
      "statement": "For the eight specifically frozen rational dual rows R_i(m), an explicit rational witness m₀ gives R_i(m₀)<0.380627474626686 for every i. Hence no nonnegative mixture of these unchanged rows can certify a uniform bound reaching 0.380627474626686 through their pointwise returns.",
      "conditions": "Frozen eight V5+ rows, common negative quadratic coefficient, original normalization, and nonnegative mixing only. The source-conditional lower deduction μ>0.38062747462668 requires Wetch's inherited analytic and interval-arithmetic premises.",
      "measurement": "< 6×10⁻¹⁵",
      "metric": "Remaining fixed-family headroom",
      "validity": {
        "level": "finite",
        "label": "Exact scoped rational ceiling reported",
        "detail": "A single rational evaluation bounds every unchanged row; the statement does not constrain other dual certificates or the true Erdős constant. Original row bytes must be independently checked."
      },
      "reproducibility": {
        "level": "partial",
        "label": "Checker source public; frozen input archive missing",
        "detail": "The standalone exact Fraction checker is mirrored. The frozen row files and complete original Arb integrals are not wholly mirrored or freshly recomputed."
      },
      "originality": {
        "level": "scoped",
        "label": "Internal proof-family saturation diagnosis",
        "detail": "The ceiling is a distinct restricted-family calculation, not an independent unconditional record or a new global bound."
      },
      "significance": {
        "level": "bounded",
        "label": "Search-direction certificate",
        "detail": "Rules out futile fine-tuning of the unchanged eight rows; a ≥10⁻⁸ advance needs a different valid dual direction or premise."
      },
      "assumptions": [
        "The original eight row coefficients and common quadratic term are precisely frozen.",
        "Only nonnegative combinations of the same valid dual returns are considered.",
        "The fixed rational evaluation point lies in the original intermediate mean region.",
        "All universal lower-bound assertions retain the unreplayed central and outer Arb/analytic dependencies."
      ],
      "open": [
        "Publicly mirror exact frozen eight-row input files and digests required by the checker.",
        "Independently recompute central/outer Arb enclosures and audit the analytic reduction.",
        "Review the exact fixed-row obstruction, checking convex-combination and endpoint arithmetic.",
        "Design a new feasible dual geometry; further row retuning is saturated to the stated precision."
      ],
      "sources": [
        {
          "label": "Exact ceiling derivation and conditional lower audit",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/agent-reports/ea36_lower_20261028/RESEARCH_NOTE.md"
        },
        {
          "label": "Standalone ceiling source (requires historical frozen inputs)",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/agent-reports/ea36_lower_20261028/verify_dual_ceiling.py"
        },
        {
          "label": "Upper/lower record identity and source audit",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/erdos/STATUS_AND_PRIOR_ART_20261028.md"
        }
      ],
      "tools": [
        "referee.html",
        "review.html#erdos"
      ],
      "history": [
        {
          "date": "2026-10-27",
          "label": "Conditional eight-row lower envelope archived",
          "detail": "The eight-row dual cover was frozen; the original independent Arb quadrature was retained as an upstream dependency.",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/agent-reports/ea36_lower_20261028/RESEARCH_NOTE.md"
        },
        {
          "date": "2026-10-28",
          "label": "Exact fixed-family ceiling documented",
          "detail": "An exact rational point m₀ demonstrates that nonnegative mixing of these rows cannot meet the next target; no new universal record follows.",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/agent-reports/ea36_lower_20261028/RESEARCH_NOTE.md"
        }
      ]
    },
    {
      "id": "phase-tail",
      "title": "Finite-field short-vector tail bound",
      "field": "Finite-field algorithms",
      "kind": "Conditional tail lemma · public exact downstream checkers",
      "short": "A sharper exact-combinatorial tail audit reports a 40-bit improvement in a fourth-power lattice-decoding failure estimate.",
      "statement": "For prime fields p≡1 (mod 4), parameters (δ,η)=(0.999,0.501) and log₂(p)≥3.69k+9.2, the manuscript derives a conditional P₁₁(p)<2⁻⁹⁶ tail estimate, versus its earlier 2⁻⁵⁶ estimate.",
      "conditions": "The improved conclusion depends on a Gaussian short-vector span-count lemma in the underlying manuscript. The two public scripts verify downstream exact rational/binomial and symbolic identities, not that crucial geometric lemma or a complete decoder.",
      "measurement": "2⁻⁹⁶",
      "metric": "Source-conditional tail estimate",
      "validity": {
        "level": "conditional",
        "label": "Critical span-count lemma unreviewed",
        "detail": "Algebraic downstream terms pass the archived proof scripts, but the assumption needed to translate the terms into an algorithmic probability bound is unestablished by those checks."
      },
      "reproducibility": {
        "level": "public",
        "label": "Two distinct public downstream verifiers",
        "detail": "One script uses exact rational arithmetic; the other independently regenerates symbolic expressions with SymPy. The full original manuscript/archive and decoder replay are still outstanding."
      },
      "originality": {
        "level": "open",
        "label": "Probability improvement contingent on lemma",
        "detail": "Prior exact lattice-decoding work and same-model comparisons require review; an arithmetic tightening is not itself a certified global algorithm improvement."
      },
      "significance": {
        "level": "prospective",
        "label": "Potentially smaller decoding failure tail",
        "detail": "The 40-bit improvement matters only after the span-count lemma and end-to-end decoding model survive independent audit."
      },
      "assumptions": [
        "Prime p≡1 mod 4 with the displayed log-field-size and parameter bounds.",
        "Use the unique extreme support term with binomial multiplicity one, as corrected in the certificate.",
        "Accept the unreviewed short-vector span-count lemma to infer P₁₁(p).",
        "No inference about unrelated adaptive sensing or different power oracles."
      ],
      "open": [
        "Give a standalone mathematical proof or explicit counterexample for the span-count lemma.",
        "Independently run both published exact downstream scripts and preserve command outputs.",
        "Mirror the complete manuscript and reproducibility package with hashes.",
        "Audit end-to-end decoder correctness and the strongest same-model prior art."
      ],
      "sources": [
        {
          "label": "Conditional tail theorem and premise boundary",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/finite-field-phase-retrieval-2026-10-28/README.md"
        },
        {
          "label": "Exact rational checker A",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/finite-field-phase-retrieval-2026-10-28/verify_tail_A.py"
        },
        {
          "label": "Independent symbolic checker B",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/finite-field-phase-retrieval-2026-10-28/verify_tail_B.py"
        }
      ],
      "tools": [
        "referee.html",
        "discovery.html"
      ],
      "history": [
        {
          "date": "2026-10-28",
          "label": "Corrected downstream tail check reported",
          "detail": "Two independent algebraic checks retained the extreme-support term weight one; the geometric premise and full original archive remain open.",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/finite-field-phase-retrieval-2026-10-28/README.md"
        }
      ]
    }
  ],
  "mechanisms": [
    {
      "id": "exact-enumeration",
      "title": "Exact finite enumeration",
      "description": "Reduce a finite claim to fully specified integer tests and exhaustive combinatorial constraints.",
      "scope": "A shared verification practice, not a theorem transported between problems.",
      "witnesses": [
        "sidon30",
        "erdos36",
        "factor-network"
      ],
      "kind": "verified-method"
    },
    {
      "id": "proof-provenance",
      "title": "Proof-carrying evidence",
      "description": "Keep a witness, its identity, verifier, scope and unresolved assumptions together so an audit can be replayed.",
      "scope": "An architectural pattern. Archive completeness and independent reviewer status remain separate.",
      "witnesses": [
        "sidon30",
        "erdos36",
        "pas",
        "asua-collateral",
        "factor-network"
      ],
      "kind": "verified-method"
    },
    {
      "id": "adversarial-controls",
      "title": "Adversarial falsification",
      "description": "Intentionally perturb finite input or a claimed output to see whether the verifier rejects false evidence.",
      "scope": "Referee demonstrates bounded negative controls; it does not prove global checker soundness.",
      "witnesses": [
        "sidon30",
        "erdos36",
        "pas"
      ],
      "kind": "verified-method"
    },
    {
      "id": "symmetry-reduction",
      "title": "Symmetry and representation",
      "description": "Use a problem's algebraic structure to reduce a search space or organize candidate certificates.",
      "scope": "Parallel motifs in finite-field and quantum projects; direct mathematical transfer remains untested.",
      "witnesses": [
        "phase",
        "werner",
        "shadow-nonabelian"
      ],
      "kind": "analogy"
    },
    {
      "id": "dependency-gates",
      "title": "Proof dependency gates",
      "description": "Record the unresolved source premise that limits a downstream bound or theorem.",
      "scope": "A shared research-review principle, not a new general mathematical theorem.",
      "witnesses": [
        "phase",
        "werner",
        "erdos36",
        "asua-collateral",
        "erdos-dual-ceiling",
        "phase-tail"
      ],
      "kind": "verified-method"
    }
  ],
  "edges": [
    {
      "from": "sidon30",
      "to": "exact-enumeration",
      "relation": "finite-check",
      "label": "Exhaustive 4-point and AP-transversal checks",
      "note": "The Sidon finite proof uses an explicit subset and complete AP-cover exclusion.",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/sidon-finite-30/README.md"
    },
    {
      "from": "erdos36",
      "to": "exact-enumeration",
      "relation": "finite-check",
      "label": "Exact signed-lag arithmetic",
      "note": "Integer-convolution replay of the finite grid is documented with a curated public witness release; independent external mathematical audit remains open.",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/erdos/STATUS_AND_PRIOR_ART_20261028.md"
    },
    {
      "from": "sidon30",
      "to": "proof-provenance",
      "relation": "method",
      "label": "Witness + verifier + DAG",
      "note": "A public text input and standalone exact checker accompany the reported proof DAG.",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/sidon-finite-30/README.md"
    },
    {
      "from": "erdos36",
      "to": "proof-provenance",
      "relation": "method",
      "label": "Input hash + independent replay",
      "note": "The curated finite witness and checksum manifest are publicly released; independent external mathematical replay remains open.",
      "source": "evidence.html"
    },
    {
      "from": "pas",
      "to": "proof-provenance",
      "relation": "method",
      "label": "Frozen adverse experiment",
      "note": "Preserve the unfavorable baseline outcome alongside method and scope.",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/pas-overview.md"
    },
    {
      "from": "sidon30",
      "to": "adversarial-controls",
      "relation": "finite-check",
      "label": "Corrupted subset rejection",
      "note": "Referee checks a deliberately falsified Sidon subset against the explicit witness.",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/referee/README.md"
    },
    {
      "from": "erdos36",
      "to": "adversarial-controls",
      "relation": "finite-check",
      "label": "Score-tamper rejection on a small fixture",
      "note": "Referee's 16-cell demonstration is distinct from the 131,072-cell archived witness.",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/referee/README.md"
    },
    {
      "from": "pas",
      "to": "adversarial-controls",
      "relation": "method",
      "label": "Adverse comparison retained",
      "note": "The 20-case experiment preserved a result unfavorable to the proposed risk-priority strategy.",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/pas-overview.md"
    },
    {
      "from": "phase",
      "to": "symmetry-reduction",
      "relation": "analogy",
      "label": "Fourth-power phase quotient",
      "note": "Algebraic phase ambiguities motivate a symmetry-aware representation; no Werner transfer is established.",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/finite-field-phase-retrieval-2026-10-28/README.md"
    },
    {
      "from": "werner",
      "to": "symmetry-reduction",
      "relation": "analogy",
      "label": "Finite-copy symmetry-reduced certificates",
      "note": "The research program uses symmetry-based certificate organization; no transfer from phase retrieval is claimed.",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/werner-final-4-25/README.md"
    },
    {
      "from": "phase",
      "to": "dependency-gates",
      "relation": "open-premise",
      "label": "Unproved span-count premise",
      "note": "The claimed tail reduction cannot be promoted without its foundational lemma.",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/finite-field-phase-retrieval-2026-10-28/README.md"
    },
    {
      "from": "werner",
      "to": "dependency-gates",
      "relation": "open-premise",
      "label": "Imported analytic inequalities",
      "note": "Exact rational certificates do not discharge analytic source dependencies.",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/werner-final-4-25/README.md"
    },
    {
      "from": "erdos36",
      "to": "dependency-gates",
      "relation": "open-premise",
      "label": "External independent witness review outstanding",
      "note": "The curated witness bytes and arithmetic checker are publicly downloadable; independent mathematical refereeing and the distinct accepted Arena payload remain outstanding.",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/erdos/STATUS_AND_PRIOR_ART_20261028.md"
    },
    {
      "from": "asua-collateral",
      "to": "dependency-gates",
      "relation": "open-premise",
      "label": "Availability of guard observations bounds enforceability",
      "note": "Finite benchmark figures require matched versions and source artifacts.",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/agent-safety-under-abstraction/README.md"
    },
    {
      "from": "asua-collateral",
      "to": "proof-provenance",
      "relation": "method",
      "label": "Observation fibers define necessary information",
      "note": "Distinguishable provenance is necessary before permitted and forbidden actions can be separated.",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/agent-safety-under-abstraction/README.md"
    },
    {
      "from": "shadow-nonabelian",
      "to": "symmetry-reduction",
      "relation": "method",
      "label": "Twisted coset labels control the distance enumerator",
      "note": "Source proves the left-coset occupancy reduction; priority review remains open.",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/involution-shadow-codes/NONABELIAN_SHADOW_THEOREM.md"
    },
    {
      "from": "factor-network",
      "to": "proof-provenance",
      "relation": "method",
      "label": "Equality-class structure checks a universal encoding",
      "note": "Verifier checks one connected equality class per active variable.",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/sat-network-universal/THEOREM_AND_SCOPE.md"
    },
    {
      "from": "factor-network",
      "to": "exact-enumeration",
      "relation": "finite-check",
      "label": "Finite structural and contraction checks",
      "note": "Published local structural verifier exists; broader test scripts remain to mirror.",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/sat-network-universal/THEOREM_AND_SCOPE.md"
    },
    {
      "from": "erdos-dual-ceiling",
      "to": "dependency-gates",
      "relation": "open-premise",
      "label": "Fixed-row rational ceiling leaves upstream analytic dependencies",
      "note": "Rational point obstruction is scoped; continuum integrals need fresh independent replay.",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/agent-reports/ea36_lower_20261028/RESEARCH_NOTE.md"
    },
    {
      "from": "phase-tail",
      "to": "dependency-gates",
      "relation": "open-premise",
      "label": "Gaussian span-count lemma blocks unconditional tail claim",
      "note": "Independent downstream algebra is insufficient to prove the short-vector counting premise.",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/finite-field-phase-retrieval-2026-10-28/README.md"
    }
  ]
};
const claimById=(id)=>REGISTRY.claims.find(x=>x.id===id)||null;
const mechanismById=(id)=>REGISTRY.mechanisms.find(x=>x.id===id)||null;
const events=REGISTRY.claims.flatMap(c=>c.history.map(e=>({...e,claimId:c.id,claimTitle:c.title}))).sort((a,b)=>b.date.localeCompare(a.date)||a.claimId.localeCompare(b.claimId));
global.NightfallRegistry=Object.freeze({...REGISTRY,claimById,mechanismById,events});
})(typeof window!=="undefined"?window:globalThis);
