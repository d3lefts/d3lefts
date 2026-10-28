# Transport Control — Run 001

**7 October 2026 · Synthetic pilot v0.1 · Completed bounded run**

The immediate result is a conditional response law: retries improve valid output only in combination with specified selection and dependence assumptions. A scalar pass rate does not identify that law. Adding validity labels and measuring retry dependence made larger-budget predictions accurate in this constructed setting. A deliberate behavior shift broke those predictions. This is an executed mechanism check, not evidence of a frontier-model capability gain or a long autonomous operating horizon.

## Objective and authority

The active objective was recovered as *Evaluation Is a Transport Problem: Capability Under Transformation*: predict performance under changes to the evaluation environment, compare against simple recalibration, and state where predictions cease to be supported. This run narrows that objective to retry budgets, selection rules, and audit information. It leaves the separate *Emergence* project and the frozen *Proof After Scarcity* v0.1 experiment untouched.

All executed work was local numerical analysis, public-source reading, and creation of this reproducible record. No model API was called, no money was spent, no other person was contacted, and no model parameters were changed. The update is to the experimental model and protocol, not to the assistant's underlying weights. Execution ends at this checkpoint; no background experiment is implied.

## 1. What was learned before fitting

Let each candidate be a valid pass with probability $v$, an invalid scored pass with probability $i$, or a failure with probability $f=1-v-i$. Write $q=v+i$ for the raw pass probability. These are mutually exclusive, exhaustive outcomes in the pilot. Validity is supplied by a perfect independent oracle here; building or validating such an oracle on real tasks remains an empirical obligation.

For independent candidates and budget $k$, raw any-pass success is

$$S_k=1-(1-q)^k.$$

The selected output has valid-success probability

| Selection rule | Valid selected output | Required interpretation |
|---|---|---|
| First scored pass | $V_k^{first}=\frac{v}{q}[1-(1-q)^k]$ | Stop at the first raw pass; return failure if none. |
| Audit and retain a valid pass | $V_k^{audit}=1-(1-v)^k$ | Reject invalid candidates using a perfect audit. Audit cost is unpriced. |
| Invalid pass takes priority | $V_k^{priority}=(1-i)^k-f^k$ | Select an invalid pass whenever one exists; otherwise select a valid pass if available. This is a stress selector, not a claim about an observed model. |

For $q=0$, first-pass validity is defined as zero. A retained failure counts as zero success under every selector.

**Proof.** First-pass success decomposes into $\sum_{j=1}^k f^{j-1}v$. Audited success is the complement of no valid candidate. Priority success requires no invalid candidate and at least one valid candidate. No additional claim about model behavior is needed for these identities.

**Nonidentifiability.** Worlds $(v,i,f)=(0.45,0.05,0.50)$ and $(0.05,0.45,0.50)$ have the same complete raw-pass process under independent retries. At $k=8$, both score $S_8=0.99609375$, but first-pass valid success is respectively $0.896484375$ and $0.099609375$. Therefore no function of raw pass scores alone can correctly recover valid success in both worlds. An invalid-pass audit supplies information absent from that scalar score.

**More retries can hurt.** At $(v,i,f)=(0.4,0.1,0.5)$, the priority selector gives valid success $0.604$ at $k=3$, $0.42656096$ at $k=8$, and approximately $0.185287$ at $k=16$. Meanwhile raw any-pass success approaches one. The selector and the candidate process both belong in a capability claim.

![Synthetic response curves and the measured transport boundary](figures/response_law_and_boundary.png)

## 2. The dependence repair

In the correlated regimes, each episode draws a category-probability vector $\theta\sim\mathrm{Dirichlet}(cv,ci,cf)$, then draws all candidates conditionally independently from that vector. Episodes are independent. This creates exchangeable retries with unchanged one-attempt marginals. Smaller concentration $c$ means stronger within-episode dependence; $c=\infty$ is the independent limit.

Define

$$M_c(x,k)=\frac{(cx)^{\overline k}}{c^{\overline k}},\qquad M_\infty(x,k)=x^k,$$

where $a^{\overline k}=a(a+1)\cdots(a+k-1)$. Then

$$V_k^{audit}=1-M_c(1-v,k),\qquad V_k^{priority}=M_c(1-i,k)-M_c(f,k),$$

$$V_k^{first}=\frac{v}{q}[1-M_c(f,k)].$$

The first-pass expression uses the Dirichlet independence of the valid share among passes, $\theta_v/(\theta_v+\theta_i)$, and the total pass probability $\theta_v+\theta_i$. Their respective expectations factor. The other expressions are direct beta moments.

The controller first estimates $(v,i,f)$ from 512 separately sampled single-candidate episodes. It then uses 512 four-candidate calibration episodes to choose the independent law or a finite-concentration model. The diagnostic and candidate concentrations were fixed in advance. It selected dependence for all 32 correlated profiles and for none of the 16 independent profiles. This observed diagnostic performance is restricted to these constructed alternatives.

## 3. Frozen evaluation

The study used 16 $(q,v/q)$ profiles in each of three regimes, three selectors, training budgets $1,2,4$, and held-out budgets $8,16$. The held-out evaluation contains 196,608 independent simulated episodes, giving 288 scored cells. Budget prefixes and selectors reuse the same episode, so those cells are dependent. The predeclared stress test uses a separate 196,608 episodes.

The protocol and implementation were archived before generating outcomes. The runner saved fitted parameters, held-out predictions, and control choices before generating held-out outcomes. No predictor was retuned using held-out results. This is a local prospective freeze of a deliberately designed simulation, not blinded discovery or an externally registered study.

The mechanism predictor knows the generator's functional family. Its performance is therefore an implementation and identifiability check. The same-information logistic comparator receives the same source audit rates and estimated dependence, plus calibration outcomes at the smaller budgets. It is a useful ablation, not an exhaustive search for the best statistical baseline. No result here establishes superiority over all possible recalibration methods.

Mean held-out Bernoulli log loss, in nats per selected output; lower is better:

| Predictor | Independent | Correlated, c=2 | Correlated, c=8 |
|---|---:|---:|---:|
| Source validity, unchanged | 0.72790 | 0.63032 | 0.69258 |
| Scalar affine recalibration | 0.56312 | 0.83601 | 0.67742 |
| Same-information logistic baseline | 0.31439 | 0.46806 | 0.36355 |
| Independent-attempt law | 0.29958 | 0.63084 | 0.38373 |
| Dependence-adapted law | 0.29958 | 0.44690 | 0.35711 |
| Generator oracle (reference) | 0.29784 | 0.44572 | 0.35564 |


The oracle uses generator parameters and is included only as a reference. The source-validity baseline already has audit information; scalar affine recalibration has validity-labelled calibration targets but only a raw source score at prediction time. These information differences are explicit.

| Regime | Improvement vs same-information baseline | 95% paired interval | Clears 0.005-nat margin? |
|---|---:|---:|---|
| Independent | 0.01482 | [0.00986, 0.02027] | Yes |
| Correlated, c=2 | 0.02116 | [0.01479, 0.02720] | Yes |
| Correlated, c=8 | 0.00644 | [0.00393, 0.00907] | No |


Intervals resample the 16 constructed profiles within each regime, retaining all paired selectors and budgets. They describe variation across this grid and are not population guarantees for real models or tasks. In the $c=8$ regime, the predeclared practical advantage over the same-information baseline was **not established**. This negative result is retained.

The fitted dependence law's mean absolute probability error was 0.01038 under independence, 0.01480 at $c=2$, and 0.01037 at $c=8$. In the predeclared behavior-shift stress test, the valid share was multiplied by 0.35 at held-out budgets while raw one-attempt pass probability stayed fixed. Errors rose to 0.29331, 0.34846, and 0.32797 respectively. The method cannot infer an unobserved change in strategy from a stable raw pass score.

## 4. Control outcome and correction

The frozen controller chose the smallest allowed budget predicted to produce audited valid success of at least 0.90, or abstained when no budget qualified. It used point estimates; it did not claim a probability guarantee.

| Regime | Actions / 16 profiles | True success probability >= 0.90 | Abstentions | Minimum feasible budget matched, including abstentions |
|---|---:|---:|---:|---:|
| Independent | 14 | 13 / 14 | 2 | 13 / 16 |
| Correlated, c=2 | 6 | 6 / 6 | 10 | 15 / 16 |
| Correlated, c=8 | 11 | 11 / 11 | 5 | 14 / 16 |


Across regimes it acted on 31 profiles, met the true 0.90 criterion on 30, and abstained on 17. It matched the generator's minimum feasible budget, including correct abstention, on 42 of 48 profiles. Verification cost is absent from this minimum-budget calculation.

The missed target is informative: profile 15 was predicted to reach 0.914314 at budget one, but its true valid success was 0.882000; the observed held-out success was 0.876465. Sampling uncertainty was enough to cross the decision threshold. A good average prediction loss did not guarantee a safe individual control choice.

**Post-run analytical correction, not a scored v0.1 result.** Let $\Theta$ be a simultaneous $1-\delta$ confidence set for the response parameters. Choose an action $a$ only if

$$\inf_{\theta\in\Theta}V(a;\theta)\ge\tau.$$

On the event that the true parameter lies in $\Theta$, any chosen action meets $\tau$. This remains true for choosing the action after observing the confidence set. The guarantee relies on correct response-law assumptions and the stated coverage; an arbitrary fitted interval is insufficient.

For the independent regime alone, a concrete fixed-sample lower bound across 16 profiles is

$$v_L=\max\!\left(0,\widehat v-\sqrt{\frac{\log(16/\delta)}{2n}}\right).$$

The one-sided Hoeffding inequality and a union bound give simultaneous coverage. Selecting $k$ only when $1-(1-v_L)^k\ge0.90$ therefore handles all allowed budget choices on that event. For the failed profile, the unsmoothed source rate was 469/512; at $\delta=0.05$, $v_L=0.840961$ and this rule selects budget 2. This retrospective calculation illustrates the repair; it is not a new prospective success. The correlated case needs a confidence set that also covers dependence.

Learning does not guarantee that every realized next prediction improves. The operational update is to distinguish prediction, uncertainty, and the validity of the response law, and to refrain from a threshold claim when any of them is unsupported.

## 5. Relation to the 270-hour discussion

METR's 26 June 2026 report gives a 50% time-horizon estimate of 11.3 hours when detected cheating is scored as failure, over 270 hours when it is scored as success, and 71 hours when those runs are discarded. METR explicitly says none is robust and that the >270-hour figure lies beyond the suite's reliable range. These are alternative scoring treatments of an evaluation, not a demonstrated prediction or operating horizon for this assistant. The source is motivation only; its underlying traces were not used in this experiment. [METR, primary report](https://metr.org/blog/2026-06-26-gpt-5-6-sol/).

No numerical prediction beyond 270 hours follows from the pilot. A scoring change applied to fixed traces measures a reporting response. A scoring rule announced before execution can change the behavior distribution as well. Those interventions require separate experimental arms.

## 6. Exact validity envelope

The formulas apply to the declared outcome partition, fixed selector semantics, stable marginals across budgets, and either independence or the stationary Dirichlet mixture. They assume exact validity labels. The experiment does not test adaptive candidate generation, feedback, imperfect audits, model changes, different task families, unforeseen tools, or future releases. These are untested dimensions, not inferred successes. No general empirical validity envelope or frequentist predictive-interval coverage has been established.

The bound on the executed task was reached: one frozen fit, one held-out test, one predeclared stress test, and no outcome-driven refitting. The immediate mathematical obstruction was resolved by specifying the additional observable and its conditional response law. Real-model transport remains open.

## 7. Next empirical action, prepared but not executed

Use independently audited attempt traces from one authorized evaluation environment. Preserve every attempt, its raw score, its validity decision, the selection rule, the assigned retry budget, and whether budget or scorer information was visible before execution. Keep tasks, seeds, model version, prompt, tools, and feedback policy fixed or explicitly blocked. Retain uncertainty in an audit as an unknown label rather than silently turning it into a valid or invalid outcome.

The next smallest live pilot should first verify the validity audit and retry stationarity. It should predict held-out budgets before inspecting their outcomes, compare the same-information baseline, and retain the original kill criterion. A claim about task, model, or environment transport requires its own holdout; this run supplies none of those claims.

The available primary report did not supply the attempt-level audited records needed here. A next test has therefore been prepared using separate evaluation agents, which require explicit user authorization in this session. It is capped at **24 fresh sessions and 144 candidate strings**: six finite constraint tasks, two announced candidate budgets (four and eight), and two repetitions. Every task has been exhaustively checked to have exactly one fully valid answer and multiple answers that pass a sparse raw score. The exact prompts, answer keys, evaluator, and bounded plan are in `next_live_pilot/`. No separate agents have been launched.

This proposed batch is an instrumentation and falsification pilot. Candidates generated together within one answer are not independent retries. There is no claim that two fresh sessions give representative stochastic samples, and budget-order confounding is recorded. A ceiling or floor result will count as uninformative. The session cap does not imply a guaranteed token or monetary cost. No outside API, purchases, publication, messages to other people, or deployment is part of the proposed action. Existing authorized audited logs remain an alternative through `live_data_contract.json`.

## 8. Reproduction and integrity

Requires Python 3.10+ with NumPy and SciPy. Matplotlib is needed only to rebuild the figure and this record.

```bash
python pilot/response_law.py --output reproduced_output
```

Use a fresh output directory; the runner refuses to overwrite a completed result. The canonical source/calibration seed is 20261007; the profile bootstrap seed is 20261008. The core code contains no network or model invocation. It independently enumerates all short categorical traces: 216 checks passed with maximum absolute error 4.44e-16. Monte Carlo results are not substituted for those exact checks.

- Protocol SHA-256: `c3cd9d49c5cb170903f923263192a6392ae551fc04532390ccc8441861085f18`
- Frozen implementation SHA-256: `dabdd30da8bc9c066816f771654f57b5130ac270491ddb57112f6f35700c3bb0`
- Prediction-lock SHA-256: `409bbd4dc7c02b4827f8be87a979c2c5464e12971a9f51db68b387843120c042`

`output/results.json` contains all cell-level scores, failed decisions, and stress results. `training_traces.npz` and `heldout_traces.npz` preserve the generated category traces (0 valid pass, 1 invalid scored pass, 2 failure). These arrays contain simulated outcomes, not model transcripts. `MANIFEST.json` hashes the deliverables. The frozen protocol and implementation hashes were checked again after the run and remained unchanged.

**Claim card.** Supported: exact conditional retry laws; raw-score nonidentifiability; verified implementation; measured synthetic holdout behavior. Unestablished: superiority in every regime, guaranteed threshold control from point estimates, real-model efficacy, novel scientific priority, emergence, or prediction beyond a long-horizon benchmark estimate.
