/* Curated NIGHTFALL theoretical mathematics / computer science map.
 * Source-bound editorial snapshot; NOT an exhaustive literature survey. */
(function(root,factory){const data=factory();if(typeof module==='object'&&module.exports)module.exports=data;if(root)root.NightfallTheoryData=data;})(typeof window!=='undefined'?window:null,function(){return {
  "schema": "nightfall-theory-atlas-v1",
  "snapshot": "2026-11-17",
  "scope": "Manually curated research map, not an exhaustive survey, global citation crawl, or independent theorem audit.",
  "stages": [
    {
      "id": "foundation",
      "label": "01 / FOUNDATIONS"
    },
    {
      "id": "construction",
      "label": "02 / CONSTRUCTIONS"
    },
    {
      "id": "transfer",
      "label": "03 / TRANSFERS"
    },
    {
      "id": "frontier",
      "label": "04 / FRONTIERS"
    }
  ],
  "fields": [
    {
      "id": "products",
      "title": "Product-space analysis",
      "subtitle": "Influence · ANOVA · independence",
      "question": "Can a local resampling observable control global variance on an arbitrary independent product?",
      "accent": "#ccac82"
    },
    {
      "id": "queries",
      "title": "Query & information complexity",
      "subtitle": "Observation · oracle access · adaptation",
      "question": "What is the least information a decision actually needs?",
      "accent": "#b5beb1"
    },
    {
      "id": "combinatorics",
      "title": "Extremal combinatorics",
      "subtitle": "Witnesses · constructions · global bounds",
      "question": "When does an exact finite witness become a theorem about the optimum?",
      "accent": "#d1a58e"
    },
    {
      "id": "quantum",
      "title": "Quantum information",
      "subtitle": "Operator inequalities · measurement models",
      "question": "Which classical inferences remain valid under a physical quantum oracle?",
      "accent": "#b2b9d0"
    },
    {
      "id": "formal",
      "title": "Formal mathematics",
      "subtitle": "Kernel checks · assumptions · provenance",
      "question": "What exactly did the compiler verify, and what remains outside its statement?",
      "accent": "#e6cba0"
    },
    {
      "id": "agents",
      "title": "Agent security & assurance",
      "subtitle": "Capabilities · authority · effect time",
      "question": "What is the minimum cost of authorizing an autonomous action safely?",
      "accent": "#9bc7bc"
    }
  ],
  "nodes": [
    {
      "id": "aa",
      "field": "products",
      "stage": "foundation",
      "title": "Boolean-cube influence",
      "status": "published",
      "sourceLabel": "Turturean · AA proof",
      "source": "https://arxiv.org/abs/2611.09773",
      "scope": "A published Boolean-cube low-degree influence antecedent, credited to its author and not represented here as a result about arbitrary product laws.",
      "evidence": "Dated external paper; source-level statement and conventions must be compared before reuse.",
      "limit": "A Boolean cube is not automatically a heterogeneous or non-atomic source space.",
      "next": "Check the exact oracle, variance normalization and influence definitions."
    },
    {
      "id": "q2-finite",
      "field": "products",
      "stage": "construction",
      "title": "Finite Q2 · C105.416",
      "status": "kernel",
      "sourceLabel": "Supported native finite theorem",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/formalization/universal/InfinitePiQ2NativeSupportedTerminal.lean",
      "scope": "A Lean-checked finite heterogeneous-product, degree-two influence inequality with boundedness and degree assumptions restricted to positive source support.",
      "evidence": "Named pinned Lean declarations; see the finite Q2 catalogue and PR #740 for the exact supported scope.",
      "limit": "Finiteness of the coordinate set and native alphabets is essential to this theorem.",
      "next": "Reproduce the exact declaration and inspect its imported source assumptions."
    },
    {
      "id": "q2-l2",
      "field": "products",
      "stage": "transfer",
      "title": "Original-source L² bridge",
      "status": "kernel",
      "sourceLabel": "All-L² heat-bath source",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/formalization/universal/InfinitePiQ2AllL2LabelIntertwining.lean",
      "scope": "Genuine original-source / label-pullback heat-bath intertwining extends from bounded representatives to all label L² vectors; an individual refreshed label alphabet is finite.",
      "evidence": "Scoped compiler and standard-axiom audit from merged PR #753, not a final infinite-product Q2 theorem.",
      "limit": "A certified intertwining lemma does not itself furnish the finite-table inequality for every information projection.",
      "next": "Compose the label projection, supported table, influence and limit steps in one final declaration."
    },
    {
      "id": "q2-infinite",
      "field": "products",
      "stage": "frontier",
      "title": "Unconditional infinite Q2",
      "status": "open",
      "sourceLabel": "Infinite-product Q2 proof ledger",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/catalogue/CLAIMS.json",
      "scope": "Target: original-law variance-squared influence for arbitrary-index independent products, without an artificial atom floor.",
      "evidence": "Finite C105.416 and several source/L² transfer components exist as separately scoped certificates.",
      "limit": "The complete finite-information projection-to-bound-to-limit theorem has not been established here as a single end-to-end kernel certificate.",
      "next": "Construct and certify the genuine common finite-label approximation and discharge the terminal composition."
    },
    {
      "id": "degree",
      "field": "queries",
      "stage": "foundation",
      "title": "Low-degree decision trees",
      "status": "published",
      "sourceLabel": "Theory background and inherited work",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/papers/exact-recovery/MANUSCRIPT.md",
      "scope": "Decision-tree, block-sensitivity and polynomial-degree methods motivate the observation problem; their published antecedents require explicit credit.",
      "evidence": "Classical conceptual background and inherited results, not a new NIGHTFALL theorem.",
      "limit": "Oracle definitions and exact versus approximate recovery models cannot be exchanged.",
      "next": "Fix the oracle, information cost and success criterion before comparing bounds."
    },
    {
      "id": "palette",
      "field": "queries",
      "stage": "construction",
      "title": "Finite-palette exact recovery",
      "status": "analytic",
      "sourceLabel": "Paper A · manuscript",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/papers/exact-recovery/MANUSCRIPT.md",
      "scope": "Analytic proposal for almost-sure whole-coordinate recovery of bounded-degree finite-range observables on independent products.",
      "evidence": "Written proof and selected finite formal components; separate end-to-end checking remains incomplete.",
      "limit": "Not a quantum-query simulation theorem and not universally kernel-certified.",
      "next": "Independent review of measurable-product selection and simultaneous almost-sure claims."
    },
    {
      "id": "spectral",
      "field": "queries",
      "stage": "transfer",
      "title": "Spectral adaptive prediction",
      "status": "analytic",
      "sourceLabel": "Paper B · manuscript",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/papers/spectral-adaptive-prediction/MANUSCRIPT.md",
      "scope": "Dimension-sensitive Hilbert prediction studied under a known-law adaptive observation model; target risk is controlled by a spectral tail.",
      "evidence": "Analytic manuscript with narrowly certified mathematical components.",
      "limit": "Finite scalar certificates do not establish the full posterior/Hilbert argument.",
      "next": "Check posterior null sets, greedy stopping and end-to-end model definitions."
    },
    {
      "id": "oracles",
      "field": "queries",
      "stage": "frontier",
      "title": "Same-oracle complexity",
      "status": "open",
      "sourceLabel": "Specialized oracle manuscript",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/papers/specialized-complexity/MANUSCRIPT.md",
      "scope": "Compare adaptive and nonadaptive costs only when the same physical or mathematical oracle is available to each algorithm.",
      "evidence": "Specialized finite-field and observation examples; model-specific claims only.",
      "limit": "A powered finite-field sensing oracle is not a classical whole-coordinate query.",
      "next": "Prove any claimed complexity transfer under explicitly matched oracle semantics."
    },
    {
      "id": "sidon",
      "field": "combinatorics",
      "stage": "foundation",
      "title": "Additive structure & Sidon sets",
      "status": "published",
      "sourceLabel": "Sidon problem context",
      "source": "https://en.wikipedia.org/wiki/Sidon_sequence",
      "scope": "Classical uniqueness of pair sums and related additive-combinatorial extremal questions.",
      "evidence": "Established background; NOT a claim that NIGHTFALL originated Sidon theory.",
      "limit": "Finite examples do not imply a new asymptotic extremal proportion.",
      "next": "Identify the exact finite predicate and the historical asymptotic comparator."
    },
    {
      "id": "sidon30",
      "field": "combinatorics",
      "stage": "construction",
      "title": "30-point Sidon witness",
      "status": "finite",
      "sourceLabel": "Witness and checker",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/sidon-finite-30/README.md",
      "scope": "One reported exact 30-element weak (4,5) set whose largest Sidon subset has size 17.",
      "evidence": "Public finite witness and standalone exhaustive checker for the declared discrete instance.",
      "limit": "No proof of a stronger asymptotic (4,5)-to-Sidon theorem.",
      "next": "Replay the independent finite checker and audit its exact predicate."
    },
    {
      "id": "overlap",
      "field": "combinatorics",
      "stage": "transfer",
      "title": "Minimum overlap · #36",
      "status": "finite",
      "sourceLabel": "Erdős finite witness scope",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/erdos/STATUS_AND_PRIOR_ART_20261028.md",
      "scope": "Exact-rational finite step-function constructions provide upper bounds for a continuous overlap objective.",
      "evidence": "Finite integer arithmetic and grid-to-continuum certification as recorded in the public status ledger.",
      "limit": "An upper-bound witness is neither a matching global lower bound nor a universal optimum proof.",
      "next": "Check the witness version, signed-shift convention and exact replay before comparing bounds."
    },
    {
      "id": "optimum",
      "field": "combinatorics",
      "stage": "frontier",
      "title": "Prove the global optimum",
      "status": "open",
      "sourceLabel": "Erdős problem research status",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/erdos/STATUS_AND_PRIOR_ART_20261028.md",
      "scope": "Find exact analytical lower bounds or an optimality certificate matching a valid feasible construction.",
      "evidence": "Current upper and lower bounds are distinct kinds of evidence.",
      "limit": "Numerical local minimization and a competition score do not establish global minimality.",
      "next": "Search for dual certificates and structural transitions rather than sub-tolerance numerical polishing."
    },
    {
      "id": "sld0",
      "field": "quantum",
      "stage": "foundation",
      "title": "Quantum Fisher geometry",
      "status": "published",
      "sourceLabel": "Quantum observability overview",
      "source": "quantum-observability.html",
      "scope": "Classical quantum-statistical background: the symmetric logarithmic derivative relates states, parameter sensitivity and quantum information.",
      "evidence": "Published field concepts; the page distinguishes physical assumptions from algebraic operations.",
      "limit": "A classical observation rule does not specify a realizable quantum measurement.",
      "next": "State the state family, observable, loss and physical measurement oracle."
    },
    {
      "id": "sld",
      "field": "quantum",
      "stage": "construction",
      "title": "SLD tensor inequalities",
      "status": "analytic",
      "sourceLabel": "Quantum SLD theorem and audit",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/papers/quantum-sld-tensorization/THEOREM_AND_AUDIT.md",
      "scope": "Proposed sharp inverse-SLD tensor Loewner bounds for faithful finite-dimensional product-average states under stated local condition numbers.",
      "evidence": "Analytic proof source and finite validation with external mathematical review outstanding.",
      "limit": "Specialized finite-dimensional assumptions must be kept visible.",
      "next": "Independent check of sharpness, equality/saturation cases and physical preparation."
    },
    {
      "id": "werner",
      "field": "quantum",
      "stage": "transfer",
      "title": "Werner-state continuation",
      "status": "conditional",
      "sourceLabel": "Werner continuation ledger",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/nightfall/projects/werner-atlas/ANALYTIC_CONTINUATION.md",
      "scope": "Inverse-copy-number continuation under separately named sharp published endpoint premises and spectator contraction.",
      "evidence": "Conditional analytic construction, not an unconditional classification theorem.",
      "limit": "Its source premises and notation corrections remain essential.",
      "next": "Recheck the inherited endpoint inequalities and tensor indexing independently."
    },
    {
      "id": "physical",
      "field": "quantum",
      "stage": "frontier",
      "title": "Physical query equivalence",
      "status": "open",
      "sourceLabel": "Operational quantum ANOVA",
      "source": "quantum-observability.html",
      "scope": "Determine which abstract query reductions survive the actual POVM, state-preparation and measurement resources.",
      "evidence": "Partial operator identities and model-specific finite checks; not a universal physical simulator.",
      "limit": "No automatic equivalence between arbitrary finite-field or classical oracle calls and laboratory measurements.",
      "next": "Certify a same-primitive measurement model and an end-to-end error bound."
    },
    {
      "id": "mathlib",
      "field": "formal",
      "stage": "foundation",
      "title": "Lean & mathlib",
      "status": "published",
      "sourceLabel": "Mathlib project papers",
      "source": "https://mathlib.org/papers.html",
      "scope": "An existing community library and kernel for checking exact logical dependencies in formal mathematics.",
      "evidence": "External toolchain and library provenance, not a NIGHTFALL invention.",
      "limit": "Kernel acceptance proves the elaborated statement, including all its exact hypotheses.",
      "next": "Inspect imported declarations, local axioms, compiler pin and source identity."
    },
    {
      "id": "receipts",
      "field": "formal",
      "stage": "construction",
      "title": "Exact-source Lean receipts",
      "status": "method",
      "sourceLabel": "NIGHTFALL compiler provenance",
      "source": "lean-certificate-provenance.html",
      "scope": "Pinned source, exact dependency hashes, named theorem printouts and permitted axiom lists travel with each narrow certificate.",
      "evidence": "Source-custody practice; trust is bounded by the compiled declaration and supply chain.",
      "limit": "A green job on a lemma does not certify a theorem that merely cites the lemma.",
      "next": "Replay the entire named build and compare terminal theorem statements."
    },
    {
      "id": "passport",
      "field": "formal",
      "stage": "transfer",
      "title": "Proof Passports",
      "status": "method",
      "sourceLabel": "Active passport ledger",
      "source": "active-proof-passport.html",
      "scope": "Link claims, premises, machine checkers, counterexamples, revisions and remaining obligations, with separate validity and novelty status.",
      "evidence": "Research governance protocol, not an independent proof of the claims it describes.",
      "limit": "Editorial status can lag compiler activity; source and receipt are authoritative for exact scopes.",
      "next": "Challenge each dependency edge and record corrections with source hashes."
    },
    {
      "id": "closure",
      "field": "formal",
      "stage": "frontier",
      "title": "End-to-end compositional proof",
      "status": "open",
      "sourceLabel": "Canonical status ledger",
      "source": "https://github.com/d3lefts/d3lefts/blob/main/research/catalogue/README.md",
      "scope": "Close every arrow from theorem hypotheses through trusted imports to the final quantified target.",
      "evidence": "Component checks and historical reproducibility may support only proper subgraphs.",
      "limit": "Unproved terminal composition remains open even when all visible sublemmas have a receipt.",
      "next": "Demand one exact-head named terminal declaration and adversarial non-author review."
    },
    {
      "id": "camel",
      "field": "agents",
      "stage": "foundation",
      "title": "Capability-based CaMeL",
      "status": "published",
      "sourceLabel": "Debenedetti et al. · CaMeL",
      "source": "https://arxiv.org/abs/2503.18813",
      "scope": "A published design for protecting LLM agents from prompt injection with capability and data-flow restrictions.",
      "evidence": "External prior art; NIGHTFALL does not claim to originate capability mediation.",
      "limit": "Demonstrated security is benchmark- and policy-specific.",
      "next": "Test utility and safety jointly under the same task/action semantics."
    },
    {
      "id": "asua",
      "field": "agents",
      "stage": "construction",
      "title": "Safety under abstraction",
      "status": "finite",
      "sourceLabel": "Agent safety analysis",
      "source": "agent-safety-under-abstraction.html",
      "scope": "Finite task/call-level measurements and abstraction-induced false denial rates under defined legitimate and injection tasks.",
      "evidence": "Reported evaluation and conditional mathematical interface, not a general proof of deployable agent safety.",
      "limit": "Action sets, side effects and baseline tasks matter; real-world enforcement is a separate obligation.",
      "next": "Independently replay side-effect classifications and strong prior-art baselines."
    },
    {
      "id": "permission",
      "field": "agents",
      "stage": "transfer",
      "title": "The price of permission",
      "status": "analytic",
      "sourceLabel": "Permission lab and model",
      "source": "permission-lab.html",
      "scope": "Investigate the cost of authorizing consequential actions subject to safety, legitimate availability, freshness and effect-time enforcement.",
      "evidence": "Synthetic exact comparisons and analytic model proposals; scope-aware baselines can tie.",
      "limit": "No general deployable enforcement theorem follows from synthetic examples.",
      "next": "Formalize effect-time monitors and measure them against a complete scope-aware baseline."
    },
    {
      "id": "effect",
      "field": "agents",
      "stage": "frontier",
      "title": "Change-stable authority",
      "status": "open",
      "sourceLabel": "Permission and proof ledger",
      "source": "cost-of-knowing.html",
      "scope": "Minimum-cost permission and recertification under changes to source authority, without revealing unnecessary private evidence.",
      "evidence": "Bounded counterexamples, discrete proofs and partial architecture.",
      "limit": "Privacy, authenticated version changes and complete effect-time enforcement are not yet jointly certified.",
      "next": "Check cryptographic evidence binding and recertification after adversarial authority changes."
    }
  ],
  "edges": [
    {
      "from": "aa",
      "to": "q2-finite",
      "kind": "context",
      "note": "Boolean-cube influence motivates the product-law extension; it is not a proof of the heterogeneous finite theorem."
    },
    {
      "from": "q2-finite",
      "to": "q2-l2",
      "kind": "method",
      "note": "These independently checked components address finite inequalities and genuine source/label operator transport respectively."
    },
    {
      "from": "q2-l2",
      "to": "q2-infinite",
      "kind": "open",
      "note": "A common finite-information projection and bound-to-limit composition must still be discharged."
    },
    {
      "from": "degree",
      "to": "palette",
      "kind": "context",
      "note": "Decision-tree sensitivity ideas motivate the exact finite-range observation manuscript."
    },
    {
      "from": "palette",
      "to": "spectral",
      "kind": "comparison",
      "note": "Exact finite-palette recovery and approximate Hilbert prediction use different loss and oracle contracts."
    },
    {
      "from": "spectral",
      "to": "oracles",
      "kind": "open",
      "note": "Whole-coordinate observation bounds cannot automatically transfer to a specialized or physical oracle."
    },
    {
      "from": "sidon",
      "to": "sidon30",
      "kind": "context",
      "note": "The explicit 30-point witness tests one finite Sidon extremal instance."
    },
    {
      "from": "sidon30",
      "to": "optimum",
      "kind": "open",
      "note": "Finite constructions leave asymptotic extremal questions and priority comparisons unresolved."
    },
    {
      "from": "overlap",
      "to": "optimum",
      "kind": "open",
      "note": "An upper-bound witness requires a matching lower-bound or dual certificate for optimality."
    },
    {
      "from": "sld0",
      "to": "sld",
      "kind": "context",
      "note": "The SLD construction is stated in a specific quantum Fisher geometry model."
    },
    {
      "from": "sld",
      "to": "werner",
      "kind": "comparison",
      "note": "Both use finite-dimensional operator methods, but neither theorem is asserted to imply the other."
    },
    {
      "from": "werner",
      "to": "physical",
      "kind": "open",
      "note": "Operator and state assumptions must be connected to a realizable measurement protocol."
    },
    {
      "from": "mathlib",
      "to": "receipts",
      "kind": "method",
      "note": "Named declarations are kernel checked under an immutable toolchain/dependency pin."
    },
    {
      "from": "receipts",
      "to": "passport",
      "kind": "method",
      "note": "Receipts become inspectable dependency and claim-scope records."
    },
    {
      "from": "passport",
      "to": "closure",
      "kind": "open",
      "note": "A passport lists the remaining arrows; it does not prove them."
    },
    {
      "from": "camel",
      "to": "asua",
      "kind": "comparison",
      "note": "Published capability mediation provides an external security comparator, not an inherited NIGHTFALL result."
    },
    {
      "from": "asua",
      "to": "permission",
      "kind": "method",
      "note": "The legitimate-availability tradeoff motivates an explicit permission cost objective."
    },
    {
      "from": "permission",
      "to": "effect",
      "kind": "open",
      "note": "Strong effect-time authorization and change-stable privacy remain a combined open target."
    },
    {
      "from": "q2-l2",
      "to": "receipts",
      "kind": "method",
      "note": "The all-L² operator proof is a named source-specific Lean certificate, not the terminal Q2 bound."
    },
    {
      "from": "q2-infinite",
      "to": "closure",
      "kind": "open",
      "note": "The infinite Q2 target requires a source-specific, unconditional end-to-end declaration."
    },
    {
      "from": "palette",
      "to": "q2-finite",
      "kind": "comparison",
      "note": "Both study independent products, but approximate influence and exact identification are separate claims."
    },
    {
      "from": "sld",
      "to": "receipts",
      "kind": "open",
      "note": "Analytic quantum sharpness is not upgraded by unrelated Lean components."
    },
    {
      "from": "permission",
      "to": "passport",
      "kind": "method",
      "note": "Permission claims can expose source authority, dependencies and recertification obligations."
    },
    {
      "from": "oracles",
      "to": "physical",
      "kind": "comparison",
      "note": "Oracle resource accounting is the key to transferring complexity estimates into physical models."
    }
  ]
};});
