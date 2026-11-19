# Exponential Product-Mixture Complexity of Gaussian-Sign Forrelation

**NIGHTFALL companion paper, public working preprint v0.1 (19 November 2026).**

The exact unconditioned Gaussian-sign Forrelation input law needs at least

\[
M \ge \exp\!\left(N\phi(2/\pi)\right)
= \exp(0.21920054682616779\ldots N)
\]

latent components in any representation by products of the two \(N\)-bit blocks. This is **stronger** than the earlier \(M\ge \exp((2/\pi^2)N)\), whose exponent is \(0.20264236728467554\ldots\).

The lower bound is robust: if an \(M\)-component mixture is within total variation \(\eta\le1/2\), then

\[
\log M\ge N[\phi(2/\pi)-2\eta\log2]-2h_2(\eta).
\]

At \(\eta=1\%\), the rate coefficient is \(0.20533760321496889\ldots\).

**Reading order:** [Full companion paper](COMPANION_PAPER.md) · [PDF version](Companion_Forrelation_Product_Mixture_v0_1.pdf) · [Proof Passport](PROOF_PASSPORT.md) · [Exact finite checker](check_reproduction.py).

The underlying Gaussian-sign source is Aaronson–Ambainis's Forrelation construction. The information/mixture mechanism is standard prior art; only this explicit specialization and strengthening are under novelty review. The Gaussian sign-correlation step and strengthened bound are **paper-proved, not end-to-end Lean certified**. General MGF-to-mixture support is kernel-certified separately in NIGHTFALL PR #869.

This is a **public non-refereed working preprint**. It is not an arXiv or journal submission. Final contributor attribution and independent human review remain open.
