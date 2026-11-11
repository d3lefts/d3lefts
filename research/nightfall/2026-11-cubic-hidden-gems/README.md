# Review packet — three reusable cubic proof operators

Read `PROOF_NOTE.md`. Reproduce the tests with:

```
python3 -I check_exact.py
python3 -I verify_l1_quadratic.py
python3 -I verify_bounded_controls.py
sha256sum -c SHA256SUMS
```

The first checker independently tests mixed-alphabet ANOVA and the optimized partition, as well as exact cyclic hypergraph identities. The two further checkers are source-preserving replays from the user's prior cubic research package, included for cross-session provenance and confirmation.

This is a **proposed repository addition**; no GitHub change was made. It is not a claim of globally original priority, external refereeing, or a proof of unrestricted degree-three exponent two.

Direct precedent for one-block decoupling: O'Donnell and Zhao, CCC 2016, https://arxiv.org/abs/1512.01603. The existing NIGHTFALL quadratic theorem and its proof are imported dependencies.
