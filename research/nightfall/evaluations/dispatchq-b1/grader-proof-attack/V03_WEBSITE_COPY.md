# Evaluation Lab exhibit — DispatchQ-B1 grader attacked twice

**Project status:** Internally calibrated prototype; blind model evaluation and external reviewer pending.

**Summary (70 words):** We tried to break our own software-engineering grader before scoring an AI agent. Five defective reference mutations initially received perfect marks, prompting a new suite. A second preregistered audit found twelve additional incorrect implementations still scoring 100/100. We added twelve contract-derived, metamorphic checks, preserving the 100-point scale. The revised evaluator detects all twenty-four tested faults, and the correct reference retains full credit. The exact holdout remains private to prevent contamination.

**Evidence:** public audit receipt and PR; private scorer/source pinned by SHA-256 but not published. No model-performance claim. No Google/DeepMind affiliation.