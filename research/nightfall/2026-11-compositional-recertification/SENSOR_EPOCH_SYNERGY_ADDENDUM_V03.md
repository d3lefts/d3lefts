# NIGHTFALL sensor-epoch complementarity — v0.3 addendum

**Date:** November 13, 2026 (America/New_York). **Status:** Exact finite observational theorem; classical additive-noise/one-time-pad algebra; author-side exact-rational checker 28/28; not a new Shannon theorem, independent scholarly review or physical deployment.

## Model and result

Let a mission-critical unsafe/safe index K be uniform on Z_r, r≥2. The first sensor reports Y_1=K+U_1 mod r; the second is a reference sensor Y_2=U_2 mod r. Let U_1 be uniform on Z_r independent of K. Assume U_2=U_1+W, with W independent of (K,U_1), but W is not assumed zero. K represents an actual system distinction; U is a latent shared nuisance, e.g., common calibration offset or phase/reference state. Observations must be paired with truthful source and epoch identifiers before they can be combined.

**Theorem F.** Exactly,

  I(K;Y_1)=I(K;Y_2)=0,  I(K;Y_1,Y_2)=log₂ r-H(W).

Moreover, P(K=k|Y_1=y_1,Y_2=y_2)=P(W=k-y_1+y_2 mod r). In a trusted same-epoch read W=0, the pair recovers K exactly from Y_1−Y_2, although either sensor alone remains completely uninformative. If U_2 is independently re-randomized before the reference read (uniform W), the joint pair is uninformative. If W has full support, one pair cannot guarantee zero-error K identification despite positive mutual information when W is nonuniform.

**Proof.** U_1 is uniform and independent of K; hence Y_1 is independent of K. Since U_2=U_1+W and U_1 uniform independent of W, U_2 is uniform independent of (K,W); hence Y_2 independent of K. Also (Y_1,Y_2) is uniform on Z_r² and independent of W: for each fixed W=w the transformation (K,U_1)↦(K+U_1,U_1+w) is bijective. The identity K=Y_1−Y_2+W gives the conditional posterior and entropy formula. □

## Why this changes the research model

For any fixed K under the stable common-nuisance model, the **marginal** distributions of Y_1 and Y_2 do not depend on K. Thus their individual KL divergences between any two safety hypotheses are 0. Nevertheless, their **joint** law for a shared epoch has disjoint supports across different K when W=0; a paired read identifies K exactly. A protocol constrained to marginal KL information scores and per-sensor independent kernels would incorrectly declare this jointly informative experiment useless. Conversely, a protocol that combines non-atomic readings after a reference refresh can falsely conclude K from a difference that now contains unknown W. **The valid observation primitive is a source-authenticated, epoch-coupled experiment, not necessarily a single marginal sensor.**

This is neither a novel XOR identity nor a resolution of general correlated sensing. It identifies an exact representation transition: independent sensor labels → joint experiment kernels with common latent state and temporal binding. A theorem on full dynamic digital twins must model these joint kernels and epoch validity explicitly.

**Audit:** Standard-library Fraction checker exactly enumerates the joint posterior tables for r=2,...,8 and 4 noise laws per r (28 cases), verifies zero single-source information by exact joint independence, checks the posterior law exactly, and separately tests the entropy formula numerically. Repeated same-epoch observations do not create independent new information if the nuisance state persists; repeated *fresh independently corrupted pairs* may enable new statistical testing depending on the distribution of W. No repeated-sampling theorem is asserted here.

## Necessity of atomic version coupling

The two-source Shannon calculation is insufficient for safety authorization when subsystem and reference readings originate at inconsistent epochs. A valid certificate must either (i) bind both readings to an attested common nuisance/configuration epoch that is current at authorization, (ii) prove W is zero or bounded in the required contract, or (iii) retain uncertainty about W in the posterior and safety decision. Merely comparing timestamps cannot rule out a change between the final read and authorization without a linearization/commit guarantee.

## Next test

Build a **two-interface recertification model** with an authenticated source update, persistent common nuisance U, and an explicit reference-refresh event. Freeze an authorized mission and a clear zero-error or δ-risk contract. Compare unilateral, simultaneous paired, asynchronous paired and attested epoch-lock observations. Derive an exact minimal cost/lower bound on trusted *joint* probes; then attempt a source-matched compositional result when several modules share U. An independent model checker should seek same-transcript, opposite-safety counterexamples under stale reference attestations.