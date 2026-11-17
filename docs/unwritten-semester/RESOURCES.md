## Primary references

This course is independently authored. It draws its *teaching format* from MIT's Missing Semester and its engineering context from established systems-engineering references. These links are recommended reading, not evidence that this course confers degree credit or reproduces their contents.

| Source | Why it matters | Access |
|---|---|---|
| [MIT — Missing Semester](https://missing.csail.mit.edu/) | Open, exercise-driven instruction in neglected practical skills; inspiration for course format | Public |
| [SEBoK](https://sebokwiki.org/wiki/Main_Page) | Broad systems-engineering knowledge map; consult the site for its current release | Public |
| [INCOSE Systems Engineering Handbook, 5th ed.](https://www.incose.org/resource/incose-systems-engineering-handbook-a-guide-for-system-life-cycle-processes-and-activities-5th-edition/) | State-of-practice lifecycle process reference, consistent with ISO/IEC/IEEE 15288:2023 | Full book may require purchase |
| [NASA Systems Engineering Handbook, Rev 2](https://ntrs.nasa.gov/citations/20170001761) | Detailed system design, integration, V&V, technical risk, configuration management | Public |
| [NASA — Good Requirements / V&V Appendices](https://www.nasa.gov/reference/system-engineering-handbook-appendix/) | Testable requirement and verification matrices | Public |
| [NASA — Systems Modeling Handbook, NASA-HDBK-1009 Rev A](https://standards.nasa.gov/node/3111) | How SysML-based system modeling integrates with NASA systems engineering practice | Public standards page |
| [NASA — Digital Engineering Acquisition Framework Handbook, NASA-HDBK-1004 Rev A](https://standards.nasa.gov/systems-engineering-and-integration) | Newly published digital engineering acquisition guidance; check applicability and revision status | Public standards index |
| [NASEM — Reproducibility and Replicability in Science](https://nap.nationalacademies.org/catalog/25303/reproducibility-and-replicability-in-science) | Distinguishing exact computational replay from empirical replication | Public report landing page |
| [NIST — Engineering Statistics Handbook](https://www.itl.nist.gov/div898/handbook/) | Experimental design, statistical uncertainty, quality methods | Public |
| [NIST — AI Risk Management Framework](https://www.nist.gov/itl/ai-risk-management-framework) | Operational risk management for AI-enabled subsystems | Public |
| [The Turing Way](https://the-turing-way.netlify.app/) | Reproducible research engineering and collaboration | Public |

## The toolchain

The course assumes basic familiarity with Python and the shell. **Only Python 3's standard library is required** for the provided laboratory. The site itself requires only a browser and optionally Python's built-in web server.

Optional tools worth learning *after* the basic course: Git for versioned source, a model-based systems engineering language or tool (e.g. SysML), graph analysis, a mathematical solver, a notebook environment, a reproducible build environment, continuous integration, and where appropriate a proof assistant. These are method choices; none independently guarantees sound science.

## Competency map

| Research capability | Course sessions | Working evidence |
|---|---|---|
| Research formulation and boundary-setting | 01, 02, 11 | Claim contract, ConOps, indistinguishability case |
| Requirements and architectural integration | 03, 04, 05 | Trace graph, interface architecture, model card |
| Experimental and decision rigor | 06, 07, 08 | Preregistration, value-of-information analysis, Pareto table |
| Verification, risk and lifecycle assurance | 09, 10, 12 | Scoped certificate, fault tree, recertification plan |
| Reproducibility and scholarly defense | 13, 14 | Provenance manifest, reviewer objections, defended claim |

## Terms of evidence

**Reproducible:** a result can be regenerated from recorded data, code, and conditions. **Replicable:** another study, often with independent data, tests the same scientific claim. **Verified computation:** a named checker confirms a named property of particular bytes or a formal model. **Validated model:** evidence supports the model's fitness for its intended use under stated conditions. **Novel contribution:** dated prior-art review supports a concrete originality claim. Do not treat these as interchangeable.

## Limitations

This is a cross-domain research-skills supplement, not a survey of every advanced technical specialty. A terminal degree normally demands substantial mathematics and domain-specific science beyond these sessions (e.g., stochastic processes, optimization, control, reliability, formal methods, advanced simulation, or domain experiments), an original contribution, supervision, ethics approval where relevant, and an independent dissertation defense. No accreditation, admission, certification, or professional standing is implied.

## Executable doctoral supplement

- [Research toolkit](toolkit.html): four working practicums and explicit validity boundaries.
- [Quantitative foundations bridge](math-bridge.html): probability, state-space observability, robust control, loss-based decisions, causal assumptions, and finite-state verification.
- [Source code and tests](README.md): standard-library simulation, audit, paired comparison, exhaustive enumeration, and byte-level provenance gates.
