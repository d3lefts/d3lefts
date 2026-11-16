"""Independent replay checker for a deliberately bounded, fictional legal-proof calculus.

Only positive, fully grounded source facts and source-authorized Horn rules are
supported. An encoded legal interpretation remains an ASSUMPTION, not judicial truth.
No open-world negation, binding precedent resolution or real legal approval.
"""
from __future__ import annotations
import hashlib
import json
from datetime import datetime


def canon(value):
    return json.dumps(value, sort_keys=True, separators=(",", ":"), ensure_ascii=False)


def moment(value):
    dt = datetime.fromisoformat(value.replace("Z", "+00:00"))
    if dt.tzinfo is None:
        raise ValueError("timezone required")
    return dt


def _check_sources(case):
    errors, holds, srcs, facts, rules = [], [], {}, {}, {}
    if case.get("fictional") is not True or case.get("schema") != "commonwealth.synthetic.case.v1":
        errors.append("Only explicitly fictional v1 cases are supported")
    try:
        legal_at, known_at = moment(case["legal_at"]), moment(case["known_at"])
    except (KeyError, ValueError, TypeError):
        return {}, {}, {}, ["Bad legal_at or known_at"], []
    for s in case.get("sources", []):
        try:
            sid = s["id"]
            if sid in srcs:
                errors.append("Duplicate source " + sid)
                continue
            srcs[sid] = s
            if hashlib.sha256(s["raw_text"].encode("utf-8")).hexdigest() != s["content_sha256"]:
                errors.append("Source bytes changed: " + sid)
            if s["jurisdiction"] != case["jurisdiction"]:
                errors.append("Cross-jurisdiction source: " + sid)
            if not s["source_uri"].startswith("synthetic://"):
                errors.append("Unexpected external source: " + sid)
            if s["status"] != "ASSUMED_SYNTHETIC":
                holds.append("Unreviewed source: " + sid)
            if moment(s["observed_at"]) > known_at or moment(s["published_at"]) > known_at:
                holds.append("Source unknown at evidence cutoff: " + sid)
            if moment(s["effective_at"]) > legal_at:
                holds.append("Source not yet effective: " + sid)
            if moment(s["published_at"]) > moment(s["observed_at"]):
                errors.append("Publication after observation: " + sid)
            for f in s["facts"]:
                fid = f["id"]
                if fid in facts or fid in rules:
                    errors.append("Duplicate proposition ID: " + fid)
                if not isinstance(f["proposition"].get("args"), list):
                    errors.append("Bad fact arguments: " + fid)
                facts[fid] = (sid, f["proposition"])
            for r in s["rules"]:
                rid = r["id"]
                if rid in facts or rid in rules:
                    errors.append("Duplicate proposition ID: " + rid)
                if len(r.get("requires", [])) != len(set(r.get("requires", []))):
                    errors.append("Duplicate rule prerequisite: " + rid)
                if not r.get("requires"):
                    errors.append("Rules need explicit prerequisites: " + rid)
                if not isinstance(r["conclusion"].get("args"), list):
                    errors.append("Bad rule arguments: " + rid)
                rules[rid] = (sid, r)
        except (KeyError, TypeError, ValueError) as exc:
            errors.append("Malformed source: " + str(exc))
    for sid, s in srcs.items():
        for older in s.get("supersedes", []):
            if older not in srcs:
                errors.append("Missing superseded source: " + older)
            elif older == sid:
                errors.append("Self-supersession: " + sid)
            elif moment(s["effective_at"]) <= legal_at and moment(s["observed_at"]) <= known_at:
                holds.append("Superseded authority: " + older)
    for rid, (_, rule) in rules.items():
        if not all(fid in facts or fid in rules for fid in rule["requires"]):
            errors.append("Rule refers to missing proposition: " + rid)
    return srcs, facts, rules, sorted(set(errors)), sorted(set(holds))


def verify(case, proof):
    """Verify each proof step independently from source bytes and declared formalization."""
    srcs, facts, rules, errors, holds = _check_sources(case)
    findings = list(errors)
    if proof.get("case_id") != case.get("case_id") or proof.get("jurisdiction") != case.get("jurisdiction"):
        findings.append("Proof scope does not match case")
    if proof.get("legal_at") != case.get("legal_at") or proof.get("known_at") != case.get("known_at"):
        findings.append("Proof legal/knowledge snapshot differs")
    seen, accepted = set(), {}
    for step in proof.get("steps", []):
        try:
            sid, kind, conclusion = step["id"], step["kind"], step["conclusion"]
            if sid in seen:
                findings.append("Repeated proof step " + sid)
                continue
            seen.add(sid)
            if kind == "source_fact":
                source_id, fact_id = step["source_id"], step["fact_id"]
                if fact_id not in facts or facts[fact_id][0] != source_id or facts[fact_id][1] != conclusion:
                    findings.append("Unjustified source fact " + sid)
                    continue
                accepted[sid] = (fact_id, conclusion, {source_id})
            elif kind == "apply_rule":
                source_id, rule_id = step["source_id"], step["rule_id"]
                if rule_id not in rules or rules[rule_id][0] != source_id:
                    findings.append("Unknown rule " + sid)
                    continue
                rule = rules[rule_id][1]
                deps = step["premises"]
                if not isinstance(deps, list) or len(deps) != len(rule["requires"]):
                    findings.append("Incorrect premise count " + sid)
                    continue
                if any(k not in accepted for k in deps):
                    findings.append("Premise not previously established " + sid)
                    continue
                if [accepted[k][0] for k in deps] != rule["requires"] or conclusion != rule["conclusion"]:
                    findings.append("Invalid legal inference " + sid)
                    continue
                provenance = {source_id}
                for k in deps:
                    provenance.update(accepted[k][2])
                accepted[sid] = (rule_id, conclusion, provenance)
            else:
                findings.append("Unrecognized inference step " + sid)
        except (KeyError, TypeError, ValueError) as exc:
            findings.append("Malformed proof step: " + str(exc))
    goal_states = []
    for goal in case.get("goals", []):
        witness = next((step for step in accepted.values() if step[1] == goal), None)
        sources = sorted(witness[2]) if witness else []
        blockers = [h for h in holds if any(h.endswith(" " + s) for s in sources)]
        status = "MODEL_DERIVED" if witness and not blockers and not findings else "INDETERMINATE"
        goal_states.append({"goal": goal, "status": status, "sources": sources, "holds": blockers})
    status = "INVALID" if findings else ("INDETERMINATE" if holds else "MODEL_VALID")
    return {"status": status, "legal_authority": "NOT_ASSESSED", "real_world_effects": "DISABLED",
            "fictional": True, "findings": sorted(set(findings)), "holds": holds,
            "goals": goal_states, "checked_steps": len(accepted)}


def source_impact(case, proof, source_ids):
    """Conservative transitive source-to-step and goal invalidation; no silent reuse."""
    changed = set(source_ids)
    tainted_steps, step_sources = [], {}
    for step in proof.get("steps", []):
        if step.get("kind") == "source_fact":
            used = {step.get("source_id")}
        elif step.get("kind") == "apply_rule":
            used = {step.get("source_id")}
            for dep in step.get("premises", []):
                used.update(step_sources.get(dep, set()))
        else:
            used = set()
        step_sources[step.get("id")] = used
        if changed & used:
            tainted_steps.append(step.get("id"))
    proof_claims = {canon(step["conclusion"]): step["id"] for step in proof.get("steps", [])}
    affected = [goal for goal in case.get("goals", [])
                if proof_claims.get(canon(goal)) in tainted_steps]
    return {"changed_sources": sorted(changed), "affected_proof_steps": tainted_steps,
            "affected_goals": affected, "policy": "RECHECK_NOT_AUTO_REUSE"}
