# Flagship reproducibility reference package

Published preprint: [10.5281/zenodo.24511398](https://doi.org/10.5281/zenodo.24511398). Community: [NIGHTFALL — Independent Mathematical Research](https://zenodo.org/communities/nightfall-research/records).

The [manifest](manifest.json) records exact Git commit and blob identities, named Lean terminals, compiler lock and successful historical CI runs. It distinguishes merged and branch-only certificates and the sampling lemma from the full sharpness theorem. The published paper is not modified. This is a reference package, not a redistributed source archive or a new kernel replay.

## Reproduce

Clone the public repository. For each manifest entry, retrieve its exact commit and check `git rev-parse <ref>:<path>` against the listed blob. Follow the historical pinned workflow at that same ref, not a floating main checkout. The full dependency closure and toolchain are pinned by their original Git trees. For query-local and diagonal proofs consult the respective exact-head workflows and receipts. For the core strict-slack theorem use the Route1WynerGeneral module and require leanchecker plus an allowed-axiom report for the named terminal. A green workflow is not an independent human review. The converse is paper-level, with a separate certified sampling lemma.

No source bytes or binary receipts are republished by this reference package; future rights-cleared archives require the release gate in [the archival procedure](../README.md). Artifact download availability and the published PDF byte hash have not been independently verified. Do not represent this reference package as a full offline build or a new Lean certification.
