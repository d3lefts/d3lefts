# Thesis prospectus | The Convoluted Costs of Knowing
## Structural Observability, Information Acquisition, and Lifecycle Assurance in Complex Systems
**Candidate:** Devin J. Wright | **Degree target:** supervised M.S. in Systems Engineering, thesis option | **Version:** 0.1 (2026-11-13)
**Status:** Provisional proposal and computational pilot; not a completed or defended academic master's thesis. Substantial AI assistance in drafting and proof exploration must be disclosed according to university policy.

### Engineering problem
Mission-critical systems frequently contain enough information in their full internal state to support a safe decision, but lack a cheap and trustworthy interface to obtain it. The engineering cost depends jointly on mission requirements, system architecture, sensing, inference, verification, and software/configuration changes. A model can be accurate but difficult to diagnose; a decision can be accurate but expensive to justify; a certificate can be sound for one version but invalid after a silent change.

**Research question:** With a fixed task and an explicitly priced, authenticated observation and evidence interface, how does architecture change the minimum *lifecycle* cost of correct and independently checkable decisions? Which structural conditions permit a nontrivial matching upper and lower bound?

### Formal specification
Finite state space `X`, mission family `T_v:X->Y_v` indexed by authenticated configuration version `v`, feasible sensor-installation architectures `z`, observation channels `P_{v,s}(response|state,history)` for sensors `s` installed by `z`, cost `c_s`, and acceptance predicate `Verify(v,z,certificate)`. An adaptive policy `pi` may use only these channels and may terminate with an answer and evidence object. Optimize an explicitly weighted sum of installation, sensing, computation, initial checking and justified revalidation costs over a specified mission distribution, subject to an error guarantee. Keep those resources separately reported before aggregation. The required error notion (Bayesian versus worst case), task revelation timing, authenticated updates and verifier trust base must be fixed *before* making comparisons.

### Work package I: structural observability
For deterministic finite sensors, define `s(x)` as the measured symbol. A selected architecture exactly observes task `T` iff every pair with `T(x)!=T(x')` is separated by an installed sensor. Equivalently, the observation partition refines the task partition. **Classical factorization / test-cover criterion, not original.** This exact finite benchmark is reproducible.

The source portfolio extends these ideas to low-interaction product observables. A dependent-separator note gives a **conditional** theorem: after reading a known separator of size `s`, conditional independent blocks of size at most `k` can be handled using an imported degree-two quadratic-influence premise, yielding a state-read budget in the source note. This does not establish a general Gibbs theorem, free separator discovery, or a new terminal Lean certificate.

**Research ambition:** identify a structurally useful observation class *beyond* classical deterministic test cover, with a source-faithful local dependence certificate and a precise failure example.

### Work package II: information acquisition
Specify the measurement-access oracle before choosing an algorithm. Distinguish state-coordinate reads, model-value queries, posterior-model draws, synthetic sample generation, arithmetic, and checker calls. Existing source findings give exact posterior risk splitting and an independent two-model cross-posterior influence identity; the adaptive read bound that uses Q2 is conditional on that theorem and on strong posterior evaluation access.

**Research ambition:** a non-subsumed architecture-dependent upper/lower bound under exactly the same implementable noisy adaptive oracle. Quantify the value of an informative interface without granting a unit-cost answer oracle. Compare directly with task-conditioned active observability (Zhang and Xu, 2026), optimal sensor selection, controlled sensing, and group-test cover.

### Work package III: lifecycle assurance
Define a certificate as a *version-scoped* evidence object, not a general assurance narrative. Its checker must establish the task and sensor semantics from authenticated premises. For full-table evidence with `N` states, if `k` rows change and all other rows are cryptographically or otherwise genuinely authenticated as unchanged, at most `kN-k(k+1)/2` unordered state pairs require rechecking. The formula counts exactly all pairs incident to a changed row. It is a simple combinatorial upper bound under strong trust assumptions, not a breakthrough. Changes to sensor semantics or mission criteria can invalidate the entire existing proof and require a full rebuild.

**Research ambition:** quantify which update classes admit verified sublinear revalidation, and give explicit impossibility examples when source authentication is absent. Compare with ACCESS, contract-based verification, dynamic set cover, and incremental verification.

### Exact computational pilot: two-bit task-conditioned sensing
Let `X=(x0,x1)` be two independent fair bits. A mission asks for parity with probability `p` and for `x0` with probability `1-p`, revealed before state measurements. Architecture A installs `x0,x1` sensors at unit cost each. Architecture B installs `x0,parity`, where the parity sensor costs four units plus a two-unit value-specific proof-audit fee. All sensor queries cost one unit per use; the other primitive readouts have no additional audit fee in this *illustrative* model.

- A: initial cost 2 and expected per-mission read cost `1+p`.
- B: initial cost 7 and expected per-mission read cost 1.
- Over `T` missions: `C_A(T)=2+T(1+p)`; `C_B(T)=7+T`. The improved interface pays off iff `Tp>5`. For `p=3/4`, crossover is `T>20/3`; at `T=8`, `C_A=16`, `C_B=15`.

The exact results follow by elementary algebra and exhaustive finite observation trees. The example is **not** a claimed novel theorem, and the direct parity sensor is an additional observation resource whose installation and audit costs are explicitly charged.

### Proposed thesis acceptance tests
A credible defended thesis must contain: (a) fixed real or public engineering application constraints, requirements traceability and mission loss; (b) at least one theorem or impossibility result exceeding the two-bit classical baseline, with same-interface construction and lower bound; (c) independent checker implementation, negative controls and reproducible inputs; (d) source-faithful proof dependency ledger; (e) comparative ablations that turn sensors, update trust and decision timing on/off; and (f) documented prior-art contrasts and declared AI involvement. **No novelty credit until non-author scrutiny.**

### Engineering demonstration plan
Use a public synthetic modular asset-monitoring or logistics-support model, with no restricted operational data. Specify at least 3 system architectures, 2 mission classes, 2 noise regimes, 2 update modes (authenticated local / unreported global), and a finite loss function. Compare matched-oracle sensing policies, computation, check/recheck resources and mission error. Include negative controls where the new sensor is uninformative or changes authenticity fails.

### External comparators
- University of South Alabama MSSE thesis degree requirements: https://bulletin.southalabama.edu/programs-az/engineering/systems-engineering/systems-engineering-ms/systems-engineering-ms.pdf
- Zhang & Xu, Certified Task-Conditioned Active Observability (2026), https://arxiv.org/abs/2609.28520
- Tzoumas, Carlone & Pappas, LQG Control and Sensing Co-Design (2021), https://scispace.com/papers/lqg-control-and-sensing-co-design-4ysbqejuj8
- Wei et al., ACCESS (2024), https://www.sciencedirect.com/science/article/pii/S0164121224000773
- Turturean, A proof of the Aaronson-Ambainis conjecture (2026), https://arxiv.org/abs/2611.09773 (imported work; scope-specific)
- Source ledger: [RESEARCH_STATUS.md](RESEARCH_STATUS.md).

### Research integrity and stop rule
No numerical polish may mask a missing structural result. If the target class collapses to existing controlled sensing/test cover, record the subsumption and change operator family. If Q2 is not source-certified, keep observation claims conditional; do not make the master's contribution dependent on the unresolved theorem. Submit/release academic work only after personal review, compliant AI disclosure and faculty guidance.

**The university, not this portfolio, determines admission, credit, assessment and whether the work qualifies as an actual thesis.**
