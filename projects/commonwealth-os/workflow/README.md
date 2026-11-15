# Synthetic legislative workflow — executable reference v1.1

[Formal specification](FORMAL_WORKFLOW_v1_1.md) · [State transition reference](workflow_model.py) · [Independent replay checker](independent_checker.py) · [Tests](test_workflow.py)

Run with Python 3.11+ (stdlib only):

```bash
python -m unittest -v test_workflow.py
```

**Status:** synthetic/fictional reference; not a public election system or proof of real legal authority. The checker is intentionally independent of the implementation module, but remains internal to this research program and accepts self-provided identity/role/authority evidence. The reference **always refuses official mode**. 

Version relation: this package refines the Commonwealth OS initial v1.0 design baseline, without changing the pilot rollout order or enabling city-record import.