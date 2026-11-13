# Change-stable safety decisions — theorem and audit bundle

**Researcher:** Devin J. Wright / NIGHTFALL independent programme  
**Date:** 13 November 2026  
**Status:** Internally proved finite-model statements and falsification tests. **Not externally reviewed, Lean-certified, or a deployed safety assurance system.**

## Read in order

1. [Predecessor theorem lineage](PREDECESSOR_RESULTS_20261113.md): evidence survival as Hitting Set; exact independent-group safety-margin/order-statistic frontier.
2. [Tree-convex and bounded-exception theorem](TREE_CONVEX_CERTIFICATES_20261113.md): exact worst-case safety margin; exact minimum trusted-evidence cost under a per-version checker cap; tree dynamic programming; complete update certificates with s exceptional components.
3. [Bounded evidence sparsification corollary](BOUNDED_EVIDENCE_SPARSIFICATION_20261113.md): robust subcertificate of size at most M(s,k); existence of an equally cheap bounded-size optimum; sharp three-item witness for (s,k)=(1,1).\n4. [Typed minimum trusted checking theorem](TRUSTED_QUERY_LOWER_BOUND_20261113.md): exact deterministic worst-case cost of securing a fresh signed positive receipt without an authenticated update manifest; shows why manifest-assisted reuse is a different oracle.\n5. [Randomized checking corollary](RANDOMIZED_CHECKING_COROLLARY_20261113.md): exact equal-price minimax *expected* check count (n+1)/(n-k+1); explicitly does not preserve the deterministic worst-case lower bound.

## Reproduce

Run these commands from this directory with Python 3.11+; no additional packages:

    python3 audit.py
    python3 audit_sparsification.py\n    python3 audit_trusted_queries.py\n    python3 audit_randomized_queries.py

Implementations are in [tree_certificate.py](tree_certificate.py) and [exceptional_dependencies.py](exceptional_dependencies.py). Test programs use direct exhaustive component-change simulations and subset enumeration to challenge the derived formulas.

The local original audit scripts on 13 November separately passed 5,000 tree-margin, 5,000 packing/piercing, 4,518 finite optimization, 69,557 update witness, 7,500 near-tree and 1,155 robust sparsification examples. A targeted GitHub Actions workflow now runs the normalized repository scripts. Cite individual hosted workflow run IDs and exact commits for current CI evidence; prior local tests are a separate historical checkpoint.

## What is, and is not, trusted

The formal system models finite, authentic, complete lists of component dependencies and system updates. It does not infer dependencies from source code, detect hidden shared state, authenticate change reports, certify AI model behavior, or infer real-world hazard coverage. A checker validates the combinatorial inference *conditional on these inputs*. The source files and cited classical theorems retain their own provenance and priority status.

## Next falsifier

Use an independently inspected, versioned agent guard to extract dependency supports. Find an authenticated host tree and the **smallest justified exceptional set** without selecting it post hoc to obtain favorable results. Compare full re-verification, incremental assurance, dynamic Set Cover and the present proof-bundle checker on the same decision contract and resource units. If the exception set is large or original assumptions cannot be authenticated, report the failure and demote deployment claims.

No manuscript submission, publication, or release of a real safety guard has been authorized by this research note.
