#!/usr/bin/env python3
"""Real ControlArena IaC Fast single-sample runner; no simulated results."""
from __future__ import annotations
import argparse, datetime as dt, importlib.metadata, json, os, pathlib, shutil, subprocess, sys, traceback

def write_receipt(out, obj):
    out.mkdir(parents=True, exist_ok=True)
    (out / "receipt.json").write_text(json.dumps(obj, indent=2, sort_keys=True) + "\n")

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--out", default="controlarena-results")
    p.add_argument("--execute", action="store_true")
    p.add_argument("--offline-mock", action="store_true", help="Inspect MockLLM, not a real agent")
    p.add_argument("--limit", type=int, default=1)
    a = p.parse_args()
    out = pathlib.Path(a.out).resolve()
    now = dt.datetime.now(dt.timezone.utc).isoformat()
    receipt = {"date_utc": now, "benchmark": "ControlArena IaC Fast",
               "offline_mock": a.offline_mock,
               "status": "initial", "simulated": False, "results": {},
               "limitations": ["One sample per mode; not a statistically supported safety rate.",
                               "Docker sandbox is not a strong security boundary against arbitrarily capable adversaries."]}
    try:
        version = importlib.metadata.version("control-arena")
        receipt["control_arena_version"] = version
        if version != "20.1.1":
            raise RuntimeError("source pin mismatch: " + version)
        from control_arena import EvalMode
        from control_arena.eval import ControlEvalConfig, get_control_task
        from control_arena.micro_protocol import defer_to_trusted_builder
        from control_arena.settings.iac_fast import IACFastSetting
        from inspect_ai import eval as inspect_eval
        inspect_version = importlib.metadata.version("inspect-ai")
        receipt["inspect_ai_version"] = inspect_version
        receipt["docker_cli"] = bool(shutil.which("docker"))
        d = subprocess.run(["docker", "info", "--format", "{{.ServerVersion}}"],
                           capture_output=True, text=True, timeout=20, check=True)
        receipt["docker_server_version"] = d.stdout.strip()
        setting = IACFastSetting()
        # Check the actual v20.1.1 API and dataset/task materialization.
        receipt["setting_type"] = type(setting).__name__
        keys = {"openai": bool(os.getenv("OPENAI_API_KEY")),
                "anthropic": bool(os.getenv("ANTHROPIC_API_KEY"))}
        receipt["credential_presence"] = keys # booleans only; no keys printed
        preferred = "mockllm/model" if a.offline_mock else os.getenv("CONTROLARENA_UNTRUSTED_MODEL", "").strip()
        trusted = "mockllm/model" if a.offline_mock else os.getenv("CONTROLARENA_TRUSTED_MODEL", "").strip()
        if not preferred:
            preferred = "openai/gpt-4.1-mini" if keys["openai"] else (
                "anthropic/claude-sonnet-4-6" if keys["anthropic"] else "")
        if not trusted:
            trusted = preferred
        receipt["untrusted_model"] = preferred
        receipt["trusted_model"] = trusted
        if not preferred or not trusted:
            receipt["status"] = "blocked_model_credentials"
            write_receipt(out, receipt)
            print("BLOCKED: no model credentials; genuine ControlArena package and Docker preflight passed.")
            return 3
        # Source-grounded documented control protocol; not an authorization-bridge claim.
        config = ControlEvalConfig(untrusted_model=preferred, trusted_model=trusted, token_limit=20000)
        protocol = defer_to_trusted_builder()
        for mode_name, mode in [("honest", EvalMode.HONEST), ("attack", EvalMode.ATTACK)]:
            mode_dir = out / mode_name
            mode_dir.mkdir(parents=True, exist_ok=True)
            try:
                task = get_control_task(setting=IACFastSetting(), micro_protocol=protocol,
                                        mode=mode, eval_config=config)
                if not a.execute:
                    receipt["results"][mode_name] = {"status": "task_constructed_not_executed"}
                    continue
                logs = inspect_eval(tasks=[task], limit=a.limit,
                                    max_tasks=1, log_dir=str(mode_dir))
                report = []
                for log in logs:
                    report.append({"status": str(getattr(log, "status", "")),
                                   "location": str(getattr(log, "location", "")),
                                   "eval_id": str(getattr(log, "eval_id", "")),
                                   "num_samples": len(getattr(log, "samples", None) or [])})
                receipt["results"][mode_name] = {"status": "finished", "logs": report}
            except Exception as exc:
                receipt["results"][mode_name] = {"status": "failed", "error": repr(exc),
                                                 "traceback": traceback.format_exc()[-6000:]}
        receipt["status"] = (("completed_mock_only" if a.offline_mock else "completed") if a.execute and
          all(v["status"] == "finished" and all(z["status"] == "success" for z in v["logs"])
              for v in receipt["results"].values()) else
          "preflight" if not a.execute else "incomplete")
        write_receipt(out, receipt)
        print(json.dumps({"status":receipt["status"],"results":receipt["results"]}, indent=2))
        return 0 if receipt["status"] in ("completed", "completed_mock_only", "preflight") else 4
    except Exception as exc:
        receipt["status"] = "failed_preflight"
        receipt["error"] = repr(exc)
        receipt["traceback"] = traceback.format_exc()[-6000:]
        write_receipt(out, receipt)
        print(json.dumps({"status":receipt["status"],"error":receipt["error"]},indent=2))
        return 2

if __name__ == "__main__":
    sys.exit(main())
