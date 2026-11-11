# Paper A — Exact Recovery of Finite-Range Functions on Arbitrary Product Domains

**[Read the complete manuscript](MANUSCRIPT.md)** · Devin J. Wright / NIGHTFALL · 11 November 2026.

**Status:** Public analytic manuscript for adversarial review; no independent non-author refereeing, complete Lean proof, originality certificate or journal acceptance.

**Main claim:** For a real \(q\)-value Hoeffding-degree-\(d\) observable over an arbitrary independent product, the manuscript derives almost-sure adaptive exact recovery within \(d\lfloor d^2\min\{(q-1)^2,2R/\Delta\}\rfloor\) whole-coordinate queries. It also proves a finite Hilbert/vector-palette reduction and gives its own countable-support, posterior section, positive-measure witness and simultaneous-hybrid argument. The conservative factor **2** is deliberate; previous \(R/\Delta\) drafts are not silently promoted.

**Upstream attribution:** Midrijanis degree/block-sensitivity decision-tree mechanism; Tal Boolean block-sensitivity versus degree; Nisan–Szegedy; classical Hoeffding/Efron–Stein; endpoint Markov and Filmus–Hatami–Keller–Lifshitz bounded-cube tools.

**Evidence:** [v1.1 analytic source](../../research/nightfall/2026-11-five-closures/FIVE_CLOSURES_V11.md) · [adversarial measure-theory audit](../../research/nightfall/formalization/product_space/EXACT_RECOVERY_ADVERSARIAL_AUDIT_20261110.md) · [finite Lean and checker receipt](../../research/nightfall/formalization/product_space/RECOVERY_CERTIFICATE_RECEIPT_20261110.md).

**Independent audit requested:** Validate arbitrary completed products, positive-measure sensitivity, hybrid-degree preservation and selection measurability. Finite Lean components and finite replay do not verify the full paper.
