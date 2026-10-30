#!/usr/bin/env python3
"""NIGHTFALL Lean 4 bridge: reproducible compilation and scoped proof receipts.

Standard-library only. Lean itself must be installed; this does not implement a
second theorem prover and never promotes compilation to originality or peer review.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path

PROTOCOL = "nightfall-lean-bridge/v1"
DIAGNOSTIC = re.compile(r"^(.*?):(\d+):(\d+): (error|warning|information): (.*)$")
UNTRUSTED = re.compile(r"\b(sorry|admit|axiom|constant|native_decide|unsafe|partial)\b")
DECLARATION = re.compile(r"[A-Za-z_][A-Za-z_0-9'.]*\Z")
NO_AXIOMS = re.compile(r"\bdoes not depend on any axioms\b", re.I)


def without_comments_and_strings(source: str) -> str:
    """Erase nested Lean comments and double-quoted strings for a conservative scan."""
    out = []
    i, nesting, string = 0, 0, False
    while i < len(source):
        c = source[i]
        d = source[i : i + 2]
        if nesting:
            if d == "/-":
                nesting += 1
                out.extend("  ")
                i += 2
            elif d == "-/":
                nesting -= 1
                out.extend("  ")
                i += 2
            else:
                out.append("\n" if c == "\n" else " ")
                i += 1
        elif string:
            if c == "\\" and i + 1 < len(source):
                out.extend("  ")
                i += 2
            elif c == '"':
                string = False
                out.append(" ")
                i += 1
            else:
                out.append("\n" if c == "\n" else " ")
                i += 1
        elif d == "/-":
            nesting = 1
            out.extend("  ")
            i += 2
        elif d == "--":
            end = source.find("\n", i)
            if end == -1:
                out.extend(" " * (len(source) - i))
                i = len(source)
            else:
                out.extend(" " * (end - i))
                i = end
        elif c == '"':
            string = True
            out.append(" ")
            i += 1
        else:
            out.append(c)
            i += 1
    return "".join(out)


def policy_findings(source: str) -> list[dict]:
    cleaned = without_comments_and_strings(source)
    lines = cleaned.splitlines()
    return [
        {"token": m.group(1), "line": i, "risk": "requires human review; cannot count as axiom-free proof"}
        for i, line in enumerate(lines, 1)
        for m in UNTRUSTED.finditer(line)
    ]


def diagnostics(output: str) -> list[dict]:
    found = []
    for line in output.splitlines():
        m = DIAGNOSTIC.match(line)
        if m:
            found.append({"file": m[1], "line": int(m[2]), "column": int(m[3]),
                          "severity": m[4], "message": m[5]})
    return found


def choose_compiler(override: str | None, workspace: Path) -> list[str] | None:
    if override:
        return [override] if Path(override).exists() or shutil.which(override) else None
    lake_project = any((workspace / n).exists() for n in ("lakefile.lean", "lakefile.toml"))
    if lake_project and shutil.which("lake"):
        return ["lake", "env", "lean"]
    lean = shutil.which("lean") or (str(Path.home() / ".elan/bin/lean") if (Path.home() / ".elan/bin/lean").exists() else None)
    return [lean] if lean else None


def invoke(cmd: list[str], cwd: Path, timeout: int) -> dict:
    try:
        p = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True, errors="replace", timeout=timeout)
        return {"returncode": p.returncode, "stdout": p.stdout, "stderr": p.stderr, "timed_out": False}
    except subprocess.TimeoutExpired as e:
        return {"returncode": None, "stdout": (e.stdout or b"").decode("utf-8", "replace") if isinstance(e.stdout, bytes) else (e.stdout or ""),
                "stderr": (e.stderr or b"").decode("utf-8", "replace") if isinstance(e.stderr, bytes) else (e.stderr or ""), "timed_out": True}
    except OSError as e:
        return {"returncode": None, "stdout": "", "stderr": str(e), "timed_out": False}


def check(source: Path, workspace: Path, declarations: list[str], timeout: int, compiler: str | None) -> dict:
    path = source.resolve()
    if path.suffix != ".lean" or not path.is_file():
        raise ValueError("source must be an existing .lean file")
    if any(not DECLARATION.fullmatch(n) for n in declarations):
        raise ValueError("--decl requires an ASCII Lean qualified identifier")
    content = path.read_bytes()
    source_text = content.decode("utf-8")
    expected = (workspace / "lean-toolchain").read_text().strip() if (workspace / "lean-toolchain").exists() else None
    cmd = choose_compiler(compiler, workspace)
    receipt = {
        "protocol": PROTOCOL,
        "time_utc": datetime.now(timezone.utc).isoformat(),
        "source": str(path), "source_sha256": hashlib.sha256(content).hexdigest(),
        "workspace": str(workspace), "expected_toolchain": expected,
        "declarations_requested": declarations,
        "policy_findings": policy_findings(source_text),
        "compiler": None, "compiler_version": None, "version_matches_pin": None,
        "invocation": None, "compiler_exit_code": None,
        "status": "UNAVAILABLE", "proof_scope": "not checked", "axiom_audit": {},
        "diagnostics": [], "stdout": "", "stderr": "",
    }
    if not cmd:
        receipt["stderr"] = "No Lean compiler available; install pinned toolchain with elan."
        return receipt
    version = invoke(cmd + ["--version"], workspace, min(timeout, 15))
    receipt["compiler"] = cmd
    receipt["compiler_version"] = (version["stdout"] + version["stderr"]).strip()
    match = re.search(r"\bversion\s+([0-9]+\.[0-9]+\.[0-9]+)", receipt["compiler_version"], re.I)
    if expected:
        receipt["version_matches_pin"] = bool(match and expected.endswith("v" + match[1]))
    temp_path = None
    try:
        run_path = path
        if declarations:
            with tempfile.NamedTemporaryFile(mode="w", suffix=".lean", prefix=".lean_bridge_", dir=path.parent,
                                             encoding="utf-8", delete=False) as out:
                out.write(source_text)
                out.write("\n\n" + "\n".join(f"#print axioms {n}" for n in declarations) + "\n")
                temp_path = Path(out.name)
            run_path = temp_path
        invocation = cmd + [str(run_path)]
        receipt["invocation"] = invocation
        result = invoke(invocation, workspace, timeout)
    finally:
        if temp_path is not None:
            temp_path.unlink(missing_ok=True)
    receipt["stdout"], receipt["stderr"] = result["stdout"], result["stderr"]
    receipt["compiler_exit_code"] = result["returncode"]
    output = result["stdout"] + "\n" + result["stderr"]
    receipt["diagnostics"] = diagnostics(output)
    if result["timed_out"]:
        receipt["status"] = "TIMEOUT"
    elif result["returncode"] is None:
        receipt["status"] = "UNAVAILABLE"
    elif result["returncode"] != 0:
        receipt["status"] = "COMPILATION_FAILED"
    elif receipt["version_matches_pin"] is False:
        receipt["status"] = "TOOLCHAIN_MISMATCH"
    else:
        receipt["status"] = "COMPILED"
    for name in declarations:
        marker = re.compile(r"\b" + re.escape(name) + r"\b[^\n]*?(?:does not depend on any axioms|depends on axioms)", re.I)
        found = marker.search(output)
        receipt["axiom_audit"][name] = (
            "none_reported" if found and NO_AXIOMS.search(found[0]) else
            "dependencies_reported" if found else "unresolved"
        )
    if receipt["status"] == "COMPILED":
        if receipt["policy_findings"]:
            receipt["proof_scope"] = "compiles; source contains constructs requiring review"
        elif declarations and all(v == "none_reported" for v in receipt["axiom_audit"].values()):
            receipt["proof_scope"] = "named declarations compile; no axioms reported by Lean"
        elif declarations:
            receipt["proof_scope"] = "named declarations compile; axiom dependencies need review"
        else:
            receipt["proof_scope"] = "source compiles; no named declaration dependency audit"
    return receipt


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, help="Lean source file to compile")
    parser.add_argument("--workspace", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--decl", action="append", default=[], help="qualified declaration for #print axioms (repeatable)")
    parser.add_argument("--compiler", help="path to the installed Lean executable (for custom environments)")
    parser.add_argument("--timeout", type=int, default=120)
    parser.add_argument("--strict", action="store_true", help="fail on policy tokens and any unverified axiom audit")
    parser.add_argument("--json-out", type=Path, help="write a reproducible JSON receipt")
    args = parser.parse_args(argv)
    if args.timeout < 1:
        parser.error("--timeout must be positive")
    if args.strict and not args.decl:
        parser.error("--strict requires at least one --decl")
    try:
        receipt = check(args.source, args.workspace.resolve(), args.decl, args.timeout, args.compiler)
    except (ValueError, UnicodeDecodeError, OSError) as e:
        parser.error(str(e))
    if args.json_out:
        args.json_out.parent.mkdir(parents=True, exist_ok=True)
        args.json_out.write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(json.dumps({k: receipt[k] for k in ("status", "proof_scope", "source_sha256", "compiler_version", "axiom_audit", "policy_findings")}, indent=2))
    if receipt["status"] != "COMPILED":
        return 2
    if args.strict and (receipt["policy_findings"] or any(v != "none_reported" for v in receipt["axiom_audit"].values())):
        return 3
    return 0


if __name__ == "__main__":
    sys.exit(main())
