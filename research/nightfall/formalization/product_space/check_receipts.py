#!/usr/bin/env python3
"""Fail-closed receipt verification for NIGHTFALL Lean kernel builds.

Receipts are evidence only when tied to actual checkout bytes and compiler pin;
a successful scope-limited theorem never certifies a stronger manuscript claim.
"""
import hashlib
import json
import re
import sys
from pathlib import Path

STANDARD = {'propext', 'Classical.choice', 'Quot.sound'}
HEX = re.compile(r'[0-9a-f]{64}\Z')
SCOPED = re.compile(r"^'([^']+)' (does not depend on any axioms|depends on axioms: \[([^\]]*)\])", re.M)


def require(condition, message):
    if not condition:
        raise ValueError(message)


def dependencies(stdout, name):
    matches = list(SCOPED.finditer(stdout))
    matches = [m for m in matches if m.group(1) == name]
    require(bool(matches), f'No named declaration axiom report: {name}')
    matched = matches[-1]
    if matched.group(2) == 'does not depend on any axioms':
        return set()
    return {x.strip() for x in (matched.group(3) or '').split(',') if x.strip()}


def verify_source_bytes(r):
    require(r.get('protocol') == 'nightfall-lean-bridge/v2', 'v2 receipt protocol required')
    for prefix in ('source', 'contract'):
        name = r.get(prefix + '_relpath')
        digest = r.get(prefix + '_sha256')
        if prefix == 'contract' and name is None:
            require(digest is None, 'orphaned contract hash')
            continue
        require(isinstance(name, str) and name != '', prefix + ' relative path missing')
        require(isinstance(digest, str) and HEX.fullmatch(digest) is not None, prefix + ' digest missing')
        root = Path.cwd().resolve()
        resolved = (root / name).resolve()
        require(resolved.is_relative_to(root), prefix + ' path escapes checkout')
        require(resolved.is_file(), prefix + ' file missing in checkout: ' + name)
        actual = hashlib.sha256(resolved.read_bytes()).hexdigest()
        require(actual == digest, prefix + ' contents differ from compiled bytes: ' + name)


def audit(path):
    r = json.loads(Path(path).read_text())
    require(r.get('status') == 'COMPILED', f"{path}: {r.get('status')}: {r.get('diagnostics')}")
    require(r.get('compiler_exit_code') == 0, f'{path}: missing successful compiler exit')
    require(r.get('version_matches_pin') is True, f'{path}: unverified compiler version')
    require(r.get('expected_toolchain', '').startswith('leanprover/lean4:v'), f'{path}: no pin')
    require(not r.get('policy_findings'), f"{path}: prohibited source constructs")
    names = r.get('declarations_requested')
    require(isinstance(names, list) and bool(names) and len(names) == len(set(names)), f'{path}: empty/duplicate names')
    require(not any(d.get('severity') == 'error' for d in r.get('diagnostics', [])), f'{path}: compiler diagnostics contain errors')
    verify_source_bytes(r)
    if r.get('contract_relpath'):
        contract = json.loads((Path.cwd() / r['contract_relpath']).read_text())
        require(contract.get('schema') == 'nightfall-theorem-contract/v1', f'{path}: invalid contract')
        require([d.get('declaration') for d in contract.get('targets', [])] == names,
                f'{path}: altered contract declarations')
        if contract.get('workspace_commit'):
            require(r.get('workspace_commit') == contract['workspace_commit'],
                    f'{path}: workspace pin differs from contract')
    stdout = r.get('stdout')
    require(isinstance(stdout, str), f'{path}: missing stdout')
    for name in names:
        deps = dependencies(stdout, name)
        require(deps <= STANDARD, f'{path}: {name}: unauthorized axioms {sorted(deps-STANDARD)}')
        require(r.get('axiom_audit', {}).get(name) in ('none_reported', 'allowlisted_dependencies', 'dependencies_reported'),
                f'{path}: bad bridge audit for {name}')
        require(set(r.get('axiom_dependencies', {}).get(name, [])) == deps,
                f'{path}: axiom metadata disagrees with compiler output')
        print(path, name, 'ACCEPT_STANDARD_AXIOMS', sorted(deps))


if __name__ == '__main__':
    if len(sys.argv) < 2:
        raise SystemExit('usage: check_receipts.py receipt.json [receipt2.json ...]')
    for p in sys.argv[1:]:
        audit(p)
