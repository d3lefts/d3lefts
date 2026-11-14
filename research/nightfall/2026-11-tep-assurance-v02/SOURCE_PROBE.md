# Authenticated-reference-file monitoring probe: first actual-source result

**Not DTU 2021 and not COSTEP 2026.** This is a historical Braatz/Chiang-lineage reference trace from `jkitchin/tennessee-eastman-profbraatz` pinned at `9a6c8e5fcef4a2850778704e7793c87b0a187005`. The remote GitHub connector returned exact blob SHAs and file contents; `original_tep_probe.py` verifies these Git object hashes before replaying under a separate network-enabled Python runtime.

**Model/fault:** historical TEP, fault IDV(1) (A/C feed-ratio step with B composition held constant). 52 signals. Training source `d00.dat`: 52×500, transposed to 500×52. Test source `d00_te.dat` and fault `d01_te.dat`: both 960×52. This is a material source-schema anomaly relative to the associated README's blanket description. Training and test series are **not claimed to be paired random seeds**.

**Pre-registered sensor selection:** XMEAS(4) feed flow, XMEAS(5) recycle flow, XMEAS(7) reactor pressure, XMEAS(9) reactor temperature, XMEAS(40) product G fraction. Use training mean and sample SD for each variable. Flag each post-window sample when `abs(value-training_mean)>3*sample_SD`. Interpret index 160 (8 h at 3-min sampling) as a **working assumption** from standard TEP test protocol; not yet verified from per-file run manifest.

| Signal | Normal flags /800 | IDV1 flags /800 | Standardized post-window mean difference |
|--|--:|--:|--:|
| XMEAS(4) | 4 | 743 | −7.0984 |
| XMEAS(5) | 0 | 2 | −0.0325 |
| XMEAS(7) | 12 | 268 | +0.9425 |
| XMEAS(9) | 5 | 2 | +0.0013 |
| XMEAS(40) | 0 | 0 | −0.0264 |

**Sensitivity, window index 150 / 160 / 170:** XMEAS(4) fault counts 743/743/743 (denominators 810/800/790); normal counts 4/4/4. XMEAS(7) fault counts 268/268/261; normal 12/12/12. XMEAS(40) always zero. This is a descriptive sensitivity check, not a statistical uncertainty analysis. Fault-1 affects channels asymmetrically; it does **not** demonstrate mission-conditioned recertification superiority.

**Audit:** Two independent aggregation passes using the source text and a fixed commit agreed on counts at onset 160. The second pass tested onset 150/160/170. The source was not locally materialized in the execution container, so the Python replay script has passed syntax and synthetic rejection tests only. The current status is `source-based provisional`; no claim of external replication or certified safety.

**Required next step:** Obtain provider-certified DTU paired run subset and independent COSTEP Simulink output. Only then compare source-matched FASE-style analysis slicing, evidence selection, and per-mission operational safety predicates.
