"use strict";
/* Curated, versioned canonical source for on-site Proof Passports and Mechanism Atlas. */
(function(global){
const REGISTRY={
  "schema": "nightfall-proof-passports-v1",
  "asOf": "2026-10-29",
  "editorialScope": "Curated claim-level source records, not a synchronization of all 33 curated research documents. Evidence classifications describe only the stated scopes.",
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
        "level": "pending",
        "label": "Complete archive mirror pending",
        "detail": "Checker source is public. The complete frozen witness archive is pending public Release upload (issue #5)."
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
        "Full frozen binary provenance remains required for remote reproduction."
      ],
      "open": [
        "Publicly mirror the original frozen 131,072-cell witness bytes.",
        "Independent external reproduction and source identity comparison.",
        "Recover accepted competition input identity (issue #6)."
      ],
      "sources": [
        {
          "label": "Claim scope and prior-art audit",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/erdos/STATUS_AND_PRIOR_ART_20261028.md"
        },
        {
          "label": "Evidence access and missing archives",
          "url": "evidence.html"
        },
        {
          "label": "External archive task #5",
          "url": "https://github.com/d3lefts/d3lefts/issues/5"
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
      "short": "Two-round extension-degree packing retrieves r−1 relative phases per mixed query: at most k+⌈(k−1)/(r−1)⌉ queries over F_(q^r), q>2.",
      "statement": "For K=F_(q^r), r≥2, q>2, adaptive powered-linear queries (a·x)^(q−1) deterministically reconstruct every x up to F_q× in k+⌈max(s−1,0)/(r−1)⌉ measurements, where s is the support size. If 2≤k≤r, the worst-case k+1 count is globally optimal. When q=2, exactly k queries are optimal.",
      "conditions": "Two rounds, explicitly represented extension field, noiseless K-linear queries with a selectable basis, first-round coordinate phases, second-round batch mixing, global F_q× ambiguity; q=2 exception stated separately.",
      "measurement": "k + ⌈(k−1)/(r−1)⌉",
      "metric": "Worst-case two-round queries · q>2",
      "validity": {
        "level": "working",
        "label": "Complete batched proof argument · external review open",
        "detail": "An F_q-basis packs r−1 relative coordinate phases per adaptive query. Exact decision-tree counting proves k+1 optimal for 2≤k≤r, q>2. Independent mathematician review remains open."
      },
      "reproducibility": {
        "level": "finite",
        "label": "332,086 exact finite inputs pass",
        "detail": "Two independent checkers pass 332,086 exact input vectors across q=2,3,4,5 and extension degrees 2–4, with 3,000 constructive collisions (including characteristic two). The theorem covers all prime-power base fields."
      },
      "originality": {
        "level": "open",
        "label": "Same-model priority review open",
        "detail": "The complementary nonadaptive obstruction is a finite-field application of the known complement-property argument. Extension-degree batch packing, global optimality, and same-model adaptive separation require independent novelty review."
      },
      "significance": {
        "level": "prospective",
        "label": "Measurement-optimal high-extension decoding",
        "detail": "For q>2 and 2≤k≤r, k+1 adaptive measurements are globally optimal, while every fixed nonadaptive design needs at least 2k−1. A strict separation occurs for r≥3,k≥3."
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
          "label": "Batched theorem, proofs, lower bounds and prior-art boundary",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/adaptive-finite-field-decoder-2026-10-29/EXTENSION_DEGREE_PACKING_20261029.md"
        },
        {
          "label": "Prime-base exact decoder and nonadaptive collision checker",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/adaptive-finite-field-decoder-2026-10-29/verify_extension_packing.py"
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
      "title": "Proof After Scarcity: adverse test",
      "field": "Research systems",
      "kind": "Original bounded empirical result",
      "short": "An archived 20-case prioritization study reported upstream-first 11/20 versus risk-priority 8/20.",
      "statement": "In a bounded 20-case internal experiment, upstream-first selected 11/20 and the risk-priority method selected 8/20 under the reported evaluation rules.",
      "conditions": "One specified 20-case comparison, not a general population or transfer-efficacy theorem.",
      "measurement": "8/20 vs 11/20",
      "metric": "Reported adverse result",
      "validity": {
        "level": "empirical",
        "label": "Bounded negative experiment",
        "detail": "A narrow adverse comparison, not proof that either policy dominates generally."
      },
      "reproducibility": {
        "level": "partial",
        "label": "Experiment record archived",
        "detail": "The source dossier records protocol and outcomes; independent outside reproduction is a separate gate."
      },
      "originality": {
        "level": "scoped",
        "label": "Distinct bounded experiment",
        "detail": "The observation is original to this finite evaluation; broad verification-priority methods and related literature predate it."
      },
      "significance": {
        "level": "bounded",
        "label": "Research-systems correction",
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
          "label": "Adverse-test dossier",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/pas-overview.md"
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
          "label": "Adverse baseline comparison preserved",
          "detail": "The published site preserves 8/20 against the stronger 11/20 baseline, without claiming general improvement.",
          "url": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/pas-overview.md"
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
        "erdos36"
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
        "pas"
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
        "werner"
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
        "erdos36"
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
      "note": "Integer-convolution replay of the finite grid; full frozen witness release is still pending.",
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
      "note": "Provenance auditing identifies missing complete frozen public assets.",
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
      "label": "Missing public frozen witness release",
      "note": "Internal replay is recorded separately from public external reproducer access.",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/erdos/STATUS_AND_PRIOR_ART_20261028.md"
    }
  ]
};
const claimById=(id)=>REGISTRY.claims.find(x=>x.id===id)||null;
const mechanismById=(id)=>REGISTRY.mechanisms.find(x=>x.id===id)||null;
const events=REGISTRY.claims.flatMap(c=>c.history.map(e=>({...e,claimId:c.id,claimTitle:c.title}))).sort((a,b)=>b.date.localeCompare(a.date)||a.claimId.localeCompare(b.claimId));
global.NightfallRegistry=Object.freeze({...REGISTRY,claimById,mechanismById,events});
})(typeof window!=="undefined"?window:globalThis);
