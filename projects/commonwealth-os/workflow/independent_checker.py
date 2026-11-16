"""Independent algorithmic REPLAY CHECKER for Commonwealth OS synthetic legislative demos.

Does not import the transition implementation. Evidence is still caller-supplied:
this provides reproducibility / consistency, NOT independently attested authority,
verified signatures, tamper-proof storage, or secure secret ballot guarantees.
"""
from hashlib import sha256
import json


def _h(x):
    return sha256(json.dumps(x, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode()).hexdigest()


def verify(passport: dict, evidence: dict) -> tuple[bool, tuple[str, ...]]:
    errors = []
    def check(ok, msg):
        if not ok: errors.append(msg)

    try:
        tenant, item_id = evidence["tenant"], evidence["item_id"]
        roster, attending = set(evidence["roster"]), set(evidence["attendance"])
        rule = evidence["rules"]
        snapshot = {k: rule[k] for k in ("version", "quorum", "method", "scope_valid", "authority_valid", "official_enabled", "authorization_ref")}
        rulehash = _h(snapshot)
        rosterhash = _h(sorted(roster))
        events = evidence["events"]
        check(passport["institution"] == tenant and passport["item_id"] == item_id, "item/tenant mismatch")
        check(passport["jurisdiction"] == evidence["jurisdiction"], "jurisdiction mismatch")
        check(passport["mode"] == evidence["mode"] and evidence["mode"] in ("DEMO", "ADVISORY"), "official mode not independently attested")
        check(not passport["legal_authority"] and not passport["independent_review"], "unsupported certification label")
        check(rule["method"] == "MAJORITY_CAST_EXCLUDING_ABSTENTIONS", "unknown threshold method")
        check(rule["current"] is True and rule["no_stay"] is True and rule["scope_valid"] is True and rule["authority_valid"] is True, "rule flags not valid")
        check(0 < rule["quorum"] <= len(roster), "invalid quorum threshold")
        check(attending <= roster and len(attending) >= rule["quorum"], "invalid attending or quorum")
        check(len(roster) == len(evidence["roster"]) and len(attending) == len(evidence["attendance"]), "duplicate roster/attendance evidence")
        check(passport["rules_hash"] == rulehash and passport["roster_hash"] == rosterhash, "snapshot hash mismatch")
        check(len(events) > 0, "missing events")
        prev = "0"*64
        stage = None
        cast_map = {}
        text = None
        revision = None
        lock_hash = None
        lock_rule = None
        outcome = None
        certifier = None
        reviewers = []
        publication_hash = None
        for i, ev in enumerate(events, start=1):
            data = {k: ev[k] for k in ("seq", "name", "actor", "payload", "prior")}
            check(ev["seq"] == i and ev["prior"] == prev and ev["hash"] == _h(data), f"invalid event hash/sequence {i}")
            prev = ev["hash"]
            name, actor, payload = ev["name"], ev["actor"], ev["payload"]
            actor_meta = evidence["actors"].get(actor)
            check(actor_meta is not None and actor_meta.get("tenant") == tenant and actor_meta.get("is_human") is True, "missing/cross-tenant/synthetic actor")
            roles = set(actor_meta["roles"]) if actor_meta else set()
            role_req = {"CREATE":"AUTHOR", "SUBMIT_REVIEW":"AUTHOR", "AMEND":"AUTHOR", "SET_AGENDA":"CLERK", "OPEN_DEBATE":"PRESIDER", "LOCK_MOTION":"PRESIDER", "OPEN_BALLOT":"PRESIDER", "CLOSE_BALLOT":"PRESIDER", "CERTIFY":"CLERK", "PREPARE_PUBLICATION":"CLERK", "REVIEW_PUBLICATION":"RELEASE_REVIEWER", "APPROVE_PUBLICATION_PREVIEW":"RELEASE_REVIEWER"}
            if name in role_req:
                check(role_req[name] in roles, "missing transition role: "+name)
            elif name != "CAST":
                check(False, "unknown event: "+name)
            if name == "CREATE":
                check(i==1 and stage is None, "create not first")
                stage = "DRAFT"; text=payload["text"]; revision=payload["revision"]
                check(revision==1, "bad first revision")
                check(payload["mode"] == evidence["mode"], "create mode mismatch")
                check(payload["motion_hash"] == _h({"tenant":tenant,"item_id":item_id,"revision":revision,"text":text}), "creation hash mismatch")
            elif name == "AMEND":
                check(stage in ("DRAFT", "IN_REVIEW", "AGENDA_SET", "DELIBERATING"), "invalid amendment stage")
                old = _h({"tenant":tenant,"item_id":item_id,"revision":revision,"text":text})
                check(payload["from_hash"] == old, "amend prior hash")
                check(payload["revision"] == revision+1, "amend revision progression")
                text=payload["text"]; revision=payload["revision"]
                check(payload["to_hash"] == _h({"tenant":tenant,"item_id":item_id,"revision":revision,"text":text}), "amend next hash")
                stage="DRAFT"
            elif name in ("SUBMIT_REVIEW", "SET_AGENDA", "OPEN_DEBATE", "LOCK_MOTION", "OPEN_BALLOT", "CLOSE_BALLOT"):
                transitions={"SUBMIT_REVIEW":("DRAFT","IN_REVIEW"),"SET_AGENDA":("IN_REVIEW","AGENDA_SET"),"OPEN_DEBATE":("AGENDA_SET","DELIBERATING"),"LOCK_MOTION":("DELIBERATING","MOTION_LOCKED"),"OPEN_BALLOT":("MOTION_LOCKED","BALLOT_OPEN"),"CLOSE_BALLOT":("BALLOT_OPEN","BALLOT_CLOSED")}
                before,after=transitions[name]
                check(stage==before, "invalid transition "+name)
                motion = _h({"tenant":tenant,"item_id":item_id,"revision":revision,"text":text})
                check(payload["motion"]==motion and payload["rule"]==rulehash,"transition context changed")
                if name=="LOCK_MOTION": lock_hash=motion;lock_rule=rulehash
                if name in ("OPEN_BALLOT", "CLOSE_BALLOT"):
                    check(lock_hash==motion and lock_rule==rulehash, "ballot stale lock")
                stage=after
            elif name == "CAST":
                check(stage=="BALLOT_OPEN", "cast outside open ballot")
                check(actor in roster and actor in attending,"ineligible cast")
                check(actor not in cast_map,"duplicate cast")
                check(payload["voter"]==actor and payload["motion"]==lock_hash,"ballot context/voter mismatch")
                check(payload["choice"] in ("AYE","NAY","ABSTAIN"),"invalid choice")
                cast_map[actor]=payload["choice"]
            elif name=="CERTIFY":
                check(stage=="BALLOT_CLOSED", "certify not closed")
                check(actor not in roster and actor != evidence["author"],"certifier not independent")
                y = sum(c=="AYE" for c in cast_map.values()); n = sum(c=="NAY" for c in cast_map.values()); z = sum(c=="ABSTAIN" for c in cast_map.values())
                outcome = "PASSED" if y>n and y+n>0 else "FAILED"
                state="CERTIFIED" if outcome=="PASSED" else "REJECTED"
                check(payload["outcome"]==state and payload["tally"]==[y,n,z],"certification tally mismatch")
                check(payload["motion"]==lock_hash,"certified motion mismatch")
                certifier=actor; stage=state
            elif name=="PREPARE_PUBLICATION":
                check(stage in ("CERTIFIED","REJECTED") and actor==certifier,"bad publication preparation")
                check(payload["no_personal_data"] is True, "unredacted release claim")
                stage="PUBLICATION_REVIEW"
            elif name=="REVIEW_PUBLICATION":
                check(stage=="PUBLICATION_REVIEW", "review at wrong stage")
                check(actor not in reviewers and actor not in (certifier,evidence["author"]),"reviewer not independent")
                check(payload["reviewer"]==actor,"reviewer mismatch")
                reviewers.append(actor)
                check(len(reviewers)==1,"unexpected intermediate review")
            elif name=="APPROVE_PUBLICATION_PREVIEW":
                check(stage=="PUBLICATION_REVIEW", "publication at wrong stage")
                check(actor not in reviewers and actor not in (certifier,evidence["author"]),"reviewer not independent")
                reviewers.append(actor)
                check(len(reviewers)==2,"approval requires two independent reviewers")
                publication_hash=_h({"item":item_id,"motion":lock_hash,"outcome":evidence["tally"],"certifier":certifier,"reviewers":tuple(reviewers)})
                check(payload["public_projection_hash"]==publication_hash,"published projection hash mismatch")
                stage="PUBLISHED"
        check(prev==passport["event_root"], "event root mismatch")
        check(stage==evidence["status"], "final state mismatch")
        check(text==evidence["text"] and revision==evidence["revision"], "final revision mismatch")
        check(lock_hash==passport["motion_hash"], "passport motion hash")
        check(certifier==passport["certifier"], "certifier mismatch")
        check(outcome==passport["outcome"], "outcome mismatch")
        check(sorted(cast_map.items())==sorted(map(tuple,evidence["casts"])), "cast evidence mismatch")
        check(evidence["tally"]==passport["tally"],"passport tally mismatch")
        check(publication_hash==passport["publication_hash"],"publication hash mismatch")
        check(tuple(reviewers)==tuple(evidence["release_reviewers"]),"reviewer set mismatch")
        check(outcome is not None,"missing certification")
    except (KeyError, TypeError, ValueError, AttributeError) as exc:
        errors.append("incomplete or invalid evidence: "+str(exc))
    return (not errors, tuple(errors))
