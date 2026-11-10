# NIGHTFALL — finite-palette certificate-to-observation theorem (proof candidate v0.3)

Date: 2026-11-10. Research lead: Devin J. Wright. This is a **draft claim**, not a formally certified combined theorem, external referee report, novelty clearance, or publication authorization.

## Main finite-product result

Let X=(X_i)_{i in I} be a finite independent product with arbitrary coordinate-specific finite alphabets and strictly positive atom probabilities. Let f be nonconstant, real-valued, Hoeffding interaction degree at most d>=1, and have valid input-dependent rows a_x satisfying

    |f(x)-f(y)| <= sum_{i:x_i != y_i} a_x,i,  a_x,i>=0, sum_i a_x,i<=K.

Suppose the finite output palette is a_1<...<a_q. Let theta_k=a_{k+1}-a_k, H=sum_k 1/theta_k, R=a_q-a_1, and Delta=min_k theta_k.

**Threshold-to-squared-influence lemma.** There is a concrete probability law pi on coordinates, computed from the localized certificate-overlap profiles of an adjacent output cut, satisfying

    E_{i~pi} I_i(f) >= Var(f)/(K^2 H^2)
                          >= Delta^4 Var(f)/(K^2 R^2).

Here I_i(f)=(1/2)E(f(X)-f(X^(i)))^2.

**Simultaneous adaptive policy.** Each cycle first queries one maximal-order nonzero Hoeffding interaction block S (|S|<=d); unless the posterior is now constant, it then queries one coordinate sampled from the preceding threshold-overlap law on the remaining product. After r completed cycles, the conditional-mean predictor has

    MSE_r <= d Var(f) (1 - 1/(d K^2 H^2))^r.

Every input is exactly determined after at most

    (d+1) floor[d^2 min{(q-1)^2, R/Delta}]

whole-coordinate observations. A cycle costs at most d+1 observations. In the two-value case H=1/R and the certificate rate reduces to the original Boolean rate exactly.

## Self-contained proof of the new transfer

For each gap let g_k=1_{f>a_k}. The telescoping identity f=a_1+sum_k theta_k g_k and centered L2 triangle inequality give

    sqrt(Var(f)) <= sum_k theta_k sqrt(Var(g_k))
                 <= (sum_k 1/theta_k) sqrt(max_k theta_k^4 Var(g_k)).

Choose k attaining the maximum. The vectors lambda_x=a_x/theta_k are valid **Boolean fractional-certificate rows** for g_k: crossing this cut requires |f(x)-f(y)|>=theta_k, hence original-row cost along the differing coordinates is at least theta_k. Thus the lambda costs are <=K/theta_k, uniformly in x.

The finite-product localized two-sided certificate theorem and its overlap sampler (merged PRs #298, #300, #304 and #308) give

    E_{i~pi} I_i(g_k) >= Var(g_k) theta_k^2/K^2.

A changed value of g_k under resampling forces |f(X)-f(X^(i))|>=theta_k, so I_i(f)>=theta_k^2 I_i(g_k). Hence

    E_{i~pi} I_i(f) >= theta_k^4 Var(g_k)/K^2 >= Var(f)/(K^2 H^2).

The exact posterior ANOVA identities give T(f)=sum_i I_i(f), Var(f)<=T(f)<=d Var(f) and E[T(f|X_i)]=T(f)-I_i(f). After a fixed block S, E[T(f|X_S)]=T(f)-sum_{i in S} I_i(f)<=T(f). The additional certificate-sampled coordinate therefore contracts expected T at least by factor 1-1/(dK^2H^2). Iterating gives the MSE bound.

For exact stopping, a highest-order nonzero Hoeffding component f_S forces sensitivity to resampling of S at every point of a finite full-support product: D_S f=f_S, where D_S=prod_{i in S}(Id-E_i), and a constant S-section would imply f_S=0. Each cycle consumes one disjoint sensitive block at the original input. For m disjoint blocks, the resulting m-switch Boolean cube has real polynomial degree <=d because each original coordinate belongs to at most one switch block. Tal's bs(H)<=deg(H)^2 applied to the degree-(q-1)d indicator polynomial yields m<=(q-1)^2 d^2. Independently, the pointwise Filmus–Hatami–Keller–Lifshitz L1 bound yields m<=d^2 R/Delta. Thus there cannot be more than floor[d^2 min{(q-1)^2,R/Delta}] cycles.

## Scope and audit gates

- Proven by written derivation *conditional on the named imported theorems*, not by a single end-to-end Lean declaration.
- Component Lean receipts: finite localized product inequality, overlap sampler, concrete sampler and finite posterior/Markov algebra in merged PRs #298, #300, #303, #304, #308 and #309. The finite maximal-interaction switching core is in merged #301.
- Full heterogeneous probability-space instantiation, combined adaptive policy and threshold-to-real squared-influence lemma remain to be formalized in one pinned toolchain.
- Independent exact-rational / square-root-interval falsification: 280 finite functions (exhaustive biased two-bit ternary; heterogeneous biased 3/4-bit; deliberately low-degree 4/5-bit), 634 visited states, 167 sampler states. All checks passed. Finite tests do not prove a general result.
- Local proof package: `NIGHTFALL_Finite_Palette_Observability_v03_20261110.zip` (PDF, LaTeX, Python checker, claim ledger, hashes) is supplied in the research conversation. This public draft PR does not contain the packaged file bytes; it preserves the claim and the next formalization obligations.
- The arbitrary/uncountable completed-product exact recovery bound remains a **separate** almost-sure written proof candidate requiring specialist verification of countable support, sections, measurable choices, simultaneous valid hybrids and positive-measure sensitivity (never arbitrary null-set replacement witnesses).
- Historical novelty and priority: unresolved. OSSS, Nisan–Szegedy, Tal, FHKL, Midrijanis, Turturean and Soltani Moakhar et al. are relevant prior art. No efficiency bound on computing the policy. Not an unrestricted (2,4) squared-influence result.
- **Do not merge or publish this claim solely from the internal derivation.** Obtain independent mathematical review and a pinned end-to-end formal proof.

## Cheapest decisive next proof

Formalize, in the same Lean 4.33 workspace as the merged finite two-sided bridge, a new lemma for adjacent output cuts:
- `lambda_x = original_row_x / gap` satisfies the concrete Boolean row predicate;
- output squared influence dominates `gap^2 * threshold_boolean_influence`;
- the telescoping finite-palette variance inequality holds over normalized masses;
- the concrete sampler lower bound gives `E_pi I_i(f)>=Var(f)/(K^2 H^2)`.

Then instantiate the existing posterior query kernel, degree energy and block sensitivity stopping budget, and replay the finite checker independently.
