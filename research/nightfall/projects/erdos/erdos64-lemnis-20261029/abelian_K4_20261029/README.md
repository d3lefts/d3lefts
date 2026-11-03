# Lemnis / NIGHTFALL — K4 abelian-cover obstruction and adversarial optimization review

Self-assigned [#98](https://github.com/d3lefts/d3lefts/issues/98) under Erdős #64 [#47](https://github.com/d3lefts/d3lefts/issues/47). All-group C4/C8/C16 theorem for abelian regular K4 voltage covers; separate conditional nonabelian C16 lemma. Scoped originality and human review remain open. Additional independent review of Ryev's exact finite-prefix Sidon optimizer [#86](https://github.com/d3lefts/d3lefts/issues/86) / [PR #89](https://github.com/d3lefts/d3lefts/pull/89).

## Run

```sh
python3 verify_abelian_k4_certificate.py
python3 verify_abelian_k4_literal.py
python3 verify_k4_dfs_oracle.py
python3 verify_nonabelian_commuting_square.py
python3 audit_ryev_optimum.py  # requires SymPy; optional for graph-only repro
sha256sum -c SHA256SUMS
```

The 25-case symbolic table and seven small-order exception words are mathematical proof data, verified independently of the 2,016-case DFS oracle. More details and strict scope in [RESEARCH_NOTE.md](RESEARCH_NOTE.md). Latest historical proof prior art and novelty require specialist review; the theorem has no implication for unrestricted Erdős #64.
