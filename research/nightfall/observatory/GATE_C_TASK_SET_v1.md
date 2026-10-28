# Gate C / immutable six-task input set

The machine-readable frozen input set is [GATE_C_TASK_SET_v1.json](GATE_C_TASK_SET_v1.json).

- Six matched research-decision prompts: two finite-field, two Werner, two spectral.
- Every trial sees the same frozen underlying scientific sources at Git commit `df9511c622c309046180fd0e015aca88577c58ec`.
- Same 2,000 total model-token budget, 20 external calls, and 30-minute clock per condition and prompt.
- Fixed seed 1729, blinded adjudication; the graph arm may inspect the frozen typed evidence graph; the flat arm receives identical primary sources in a list without relationship edges.
- Independent evaluators must record each source read, raw answer, proposed acceptance criterion, token/tool expenditure, outcome grading and all failures.

The manifest intentionally carries no gold response labels or results. The source repository can enforce the input freeze and fixed budgets, but only real paired trials and externally inspectable receipts can satisfy Gate C. **Evaluation result: pending.**
