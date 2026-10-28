# The Counterfactual Authorization Gap — September 28, 2026

**Researcher:** Devin J. Wright. **Status:** complete self-contained mathematical manuscript, prior-art aware; external proof review and priority search remain outstanding.

The paper analyzes least privilege at the level of *reachable capabilities* of agents using sets of admissible tools, grants and resources. For the closure TC induced by compositional rules, a reference class Q defines the envelope
```
E(Q) = ⋃_{q ∈ Q} TC(q),   Δ(J,Q) = TC(J) \ E(Q).
```
The counterfactual gap Δ is the set of capabilities that the actual configuration can realize while no admissible reference configuration can.

The manuscript distinguishes resource budget excess from capability excess; constructs a resource frontier for each target; supplies counterexamples showing that individual-component checks can miss conjunctions; and presents proofs of NP-completeness of absorption and coNP-completeness of escape for binary Horn systems. Unary-rule and bounded-budget subclasses provide tractable comparison cases. Sound but incomplete certificates are given for certain positive escape findings.

The author explicitly treats closure/hypergraph combinatorics and related authorization safety results as prior art. The proposed research contribution is the reference-class capability-envelope treatment and its exact audit boundary. **The complexity classifications are researcher theorem claims pending independent expert verification.**

[Read the original September manuscript LaTeX](counterfactual_authorization_gap_arxiv.tex).

Adjacent manuscript: *Compositional Escape in Agent Authorization* (Sept 2026), addressing witness sizes via closure geometry; an additional, separately scoped research line rather than a guarantee of general security.
