#!/usr/bin/env python3
"""Second REAL local coding-model run, same mediator and task budget as #845.

The only intended experimental difference is the model weights identity:
qwen2.5-coder:1.5b instead of qwen2.5-coder:3b. No hidden grader runs.
This is an exploratory calibration, not a pre-registered scored comparison.
Python -I requires explicit sibling import by file path.
"""
from pathlib import Path
import importlib.util

file = Path(__file__).resolve().with_name("local_model_swe_pilot.py")
spec = importlib.util.spec_from_file_location("nightfall_first_pilot", file)
assert spec is not None and spec.loader is not None
impl = importlib.util.module_from_spec(spec)
spec.loader.exec_module(impl)
impl.MODEL = "qwen2.5-coder:1.5b"
if __name__ == "__main__":
    impl.main()
