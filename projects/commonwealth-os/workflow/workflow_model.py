"""Commonwealth OS: pure, DEMONSTRATION-ONLY legislative transition reference.

A software model, not a voting machine, signature validator, official authority
oracle, constitutional proof or cryptographic election protocol.
"""
from __future__ import annotations

from dataclasses import dataclass, replace
from hashlib import sha256
import json
from typing import Literal

Mode = Literal["DEMO", "ADVISORY", "OFFICIAL"]
Status = Literal[
    "DRAFT", "IN_REVIEW", "AGENDA_SET", "DELIBERATING", "MOTION_LOCKED",
    "BALLOT_OPEN", "BALLOT_CLOSED", "CERTIFIED", "REJECTED",
    "PUBLICATION_REVIEW", "PUBLISHED", "VOIDED",
]
Choice = Literal["AYE", "NAY", "ABSTAIN"]


def digest(payload: object) -> str:
    return sha256(json.dumps(payload, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode()).hexdigest()


@dataclass(frozen=True)
class Actor:
    id: str
    tenant: str
    roles: frozenset[str]
    is_human: bool = True


@dataclass(frozen=True)
class Rules:
    version: str
    quorum: int
    method: str = "MAJORITY_CAST_EXCLUDING_ABSTENTIONS"
    current: bool = True
    scope_valid: bool = True
    no_stay: bool = True
    authority_valid: bool = True
    official_enabled: bool = False
    authorization_ref: str = ""

    def snapshot(self) -> dict:
        return {"version": self.version, "quorum": self.quorum, "method": self.method,
                "scope_valid": self.scope_valid, "authority_valid": self.authority_valid,
                "official_enabled": self.official_enabled,
                "authorization_ref": self.authorization_ref}


@dataclass(frozen=True)
class Event:
    seq: int
    name: str
    actor: str
    payload: dict
    prior: str
    hash: str


@dataclass(frozen=True)
class Workflow:
    item_id: str
    tenant: str
    jurisdiction: str
    mode: Mode
    author: str
    revision: int
    text: str
    rules: Rules
    roster: frozenset[str]
    attendance: frozenset[str]
    status: Status = "DRAFT"
    locked_motion_hash: str = ""
    locked_rule_hash: str = ""
    locked_roster_hash: str = ""
    casts: tuple[tuple[str, Choice], ...] = ()
    certifier: str = ""
    tally: tuple[int, int, int] | None = None
    release_reviewers: tuple[str, ...] = ()
    publication_hash: str = ""
    events: tuple[Event, ...] = ()

    @property
    def motion_hash(self) -> str:
        return digest({"tenant": self.tenant, "item_id": self.item_id,
                       "revision": self.revision, "text": self.text})

    @property
    def log_root(self) -> str:
        return self.events[-1].hash if self.events else "0" * 64


def _check_actor(w: Workflow, a: Actor, role: str) -> None:
    if not a.is_human or a.tenant != w.tenant or role not in a.roles:
        raise PermissionError(f"actor lacks human {role} authority in tenant")


def _require(cond: bool, message: str) -> None:
    if not cond:
        raise ValueError(message)


def _append(w: Workflow, a: Actor, name: str, payload: dict) -> Workflow:
    seq = len(w.events) + 1
    prior = w.log_root
    event_hash = digest({"seq": seq, "name": name, "actor": a.id, "payload": payload, "prior": prior})
    return replace(w, events=w.events + (Event(seq, name, a.id, payload, prior, event_hash),))


def establish(item_id: str, tenant: str, jurisdiction: str, mode: Mode,
              author: Actor, text: str, rules: Rules,
              roster: set[str], attendance: set[str]) -> Workflow:
    if not author.is_human or author.tenant != tenant or "AUTHOR" not in author.roles:
        raise PermissionError("only human institutional authors can create items")
    _require(bool(item_id and tenant and jurisdiction and text and rules.version), "empty required field")
    _require(rules.quorum > 0 and rules.quorum <= len(roster), "invalid quorum")
    _require(set(attendance) <= set(roster), "attendance contains unknown person")
    _require(mode in ("DEMO", "ADVISORY", "OFFICIAL"), "unsupported mode")
    w = Workflow(item_id, tenant, jurisdiction, mode, author.id, 1, text, rules,
                 frozenset(roster), frozenset(attendance))
    return _append(w, author, "CREATE", {"motion_hash": w.motion_hash, "mode": mode, "text": text, "revision": 1})


def amend(w: Workflow, a: Actor, new_text: str) -> Workflow:
    _check_actor(w, a, "AUTHOR")
    _require(w.status in ("DRAFT", "IN_REVIEW", "AGENDA_SET", "DELIBERATING"), "amendment forbidden after motion lock")
    _require(bool(new_text) and new_text != w.text, "no revision")
    # A revision restarts formal review and cannot reuse earlier approval.
    v = replace(w, text=new_text, revision=w.revision + 1, status="DRAFT")
    return _append(v, a, "AMEND", {"from_hash": w.motion_hash, "to_hash": v.motion_hash, "text": new_text, "revision": v.revision})


def advance(w: Workflow, a: Actor, action: str) -> Workflow:
    transitions = {
        "SUBMIT_REVIEW": ("DRAFT", "IN_REVIEW", "AUTHOR"),
        "SET_AGENDA": ("IN_REVIEW", "AGENDA_SET", "CLERK"),
        "OPEN_DEBATE": ("AGENDA_SET", "DELIBERATING", "PRESIDER"),
        "LOCK_MOTION": ("DELIBERATING", "MOTION_LOCKED", "PRESIDER"),
        "OPEN_BALLOT": ("MOTION_LOCKED", "BALLOT_OPEN", "PRESIDER"),
        "CLOSE_BALLOT": ("BALLOT_OPEN", "BALLOT_CLOSED", "PRESIDER"),
    }
    if action not in transitions:
        raise ValueError("invalid action")
    before, after, role = transitions[action]
    _check_actor(w, a, role)
    _require(w.status == before, "invalid state transition")
    if action in ("LOCK_MOTION", "OPEN_BALLOT", "CLOSE_BALLOT"):
        _require(w.mode != "OFFICIAL", "this demonstration reference cannot execute official votes")
        _require(w.rules.current and w.rules.no_stay and w.rules.scope_valid and w.rules.authority_valid,
                 "stale, stayed, out-of-scope or unauthorized rules")
        _require(w.rules.method == "MAJORITY_CAST_EXCLUDING_ABSTENTIONS", "unsupported tally rule")
        _require(len(w.attendance & w.roster) >= w.rules.quorum, "quorum missing")
        if w.mode == "OFFICIAL":
            _require(w.rules.official_enabled and bool(w.rules.authorization_ref), "official mode disabled")
    if action == "LOCK_MOTION":
        w = replace(w, locked_motion_hash=w.motion_hash,
                    locked_rule_hash=digest(w.rules.snapshot()),
                    locked_roster_hash=digest(sorted(w.roster)))
    if action in ("OPEN_BALLOT", "CLOSE_BALLOT"):
        _require(w.locked_motion_hash == w.motion_hash, "motion changed")
        _require(w.locked_rule_hash == digest(w.rules.snapshot()), "rule changed")
        _require(w.locked_roster_hash == digest(sorted(w.roster)), "roster changed")
    return _append(replace(w, status=after), a, action, {"motion": w.motion_hash, "rule": digest(w.rules.snapshot())})


def cast(w: Workflow, a: Actor, choice: Choice) -> Workflow:
    if not a.is_human or a.tenant != w.tenant:
        raise PermissionError("human vote authority and correct tenant required")
    _require(w.status == "BALLOT_OPEN", "ballot not open")
    _require(choice in ("AYE", "NAY", "ABSTAIN"), "invalid choice")
    _require(a.id in w.roster and a.id in w.attendance, "not eligible/present")
    _require(a.id not in (p for p, _ in w.casts), "duplicate vote")
    _require(w.rules.current and w.rules.no_stay and w.rules.authority_valid, "revoked/stale")
    _require(w.motion_hash == w.locked_motion_hash and w.locked_rule_hash == digest(w.rules.snapshot()), "ballot context changed")
    return _append(replace(w, casts=w.casts + ((a.id, choice),)), a, "CAST",
                   {"voter": a.id, "choice": choice, "motion": w.locked_motion_hash})


def tally(w: Workflow) -> tuple[int, int, int]:
    return tuple(sum(1 for _, c in w.casts if c == k) for k in ("AYE", "NAY", "ABSTAIN"))


def certify(w: Workflow, a: Actor) -> Workflow:
    _check_actor(w, a, "CLERK")
    _require(w.status == "BALLOT_CLOSED", "not closed")
    _require(a.id not in (w.author,) and a.id not in w.roster, "certifier not independent of proposer and electorate")
    _require(w.rules.current and w.rules.no_stay and w.rules.scope_valid and w.rules.authority_valid,
             "rule/authority no longer valid")
    _require(w.locked_motion_hash == w.motion_hash and w.locked_rule_hash == digest(w.rules.snapshot()),
             "certification context changed")
    _require(w.locked_roster_hash == digest(sorted(w.roster)), "voter roster changed")
    _require(len(w.attendance & w.roster) >= w.rules.quorum, "quorum no longer valid")
    _require(len(set(p for p, _ in w.casts)) == len(w.casts), "duplicate ballots")
    _require(all(p in w.roster and p in w.attendance for p, _ in w.casts), "ineligible ballots")
    _require(w.mode != "OFFICIAL", "this demonstration reference cannot certify official votes")
    yes, no, abst = tally(w)
    passed = yes > no and yes + no > 0
    next_state = "CERTIFIED" if passed else "REJECTED"
    return _append(replace(w, status=next_state, certifier=a.id, tally=(yes, no, abst)), a, "CERTIFY",
                   {"outcome": next_state, "tally": [yes, no, abst], "motion": w.motion_hash})


def prepare_publication(w: Workflow, a: Actor) -> Workflow:
    _check_actor(w, a, "CLERK")
    _require(w.status in ("CERTIFIED", "REJECTED"), "unresolved decision")
    # Demo-only PUBLIC PREVIEW. In production public document is a separately-reviewed redacted projection.
    return _append(replace(w, status="PUBLICATION_REVIEW"), a, "PREPARE_PUBLICATION",
                   {"source_root": w.log_root, "no_personal_data": True})


def approve_publication(w: Workflow, a: Actor) -> Workflow:
    _check_actor(w, a, "RELEASE_REVIEWER")
    _require(w.status == "PUBLICATION_REVIEW", "not under release review")
    _require(a.id != w.certifier and a.id != w.author and a.id not in w.release_reviewers,
             "release reviewer must be separate")
    reviewers = w.release_reviewers + (a.id,)
    if len(reviewers) < 2:
        return _append(replace(w, release_reviewers=reviewers), a, "REVIEW_PUBLICATION", {"reviewer": a.id})
    h = digest({"item": w.item_id, "motion": w.locked_motion_hash, "outcome": w.tally,
                "certifier": w.certifier, "reviewers": reviewers})
    return _append(replace(w, release_reviewers=reviewers, status="PUBLISHED", publication_hash=h),
                   a, "APPROVE_PUBLICATION_PREVIEW", {"public_projection_hash": h})


def abort(w: Workflow, a: Actor, reason: str) -> Workflow:
    _check_actor(w, a, "PRESIDER")
    _require(w.status not in ("CERTIFIED", "REJECTED", "PUBLICATION_REVIEW", "PUBLISHED", "VOIDED"),
             "post-decision correction must create a new related record")
    _require(bool(reason), "reason required")
    return _append(replace(w, status="VOIDED"), a, "VOID", {"reason": reason})


def check_log(w: Workflow) -> bool:
    prior = "0" * 64
    for i, e in enumerate(w.events, 1):
        if e.seq != i or e.prior != prior or e.hash != digest(
            {"seq": i, "name": e.name, "actor": e.actor, "payload": e.payload, "prior": prior}):
            return False
        prior = e.hash
    return True


def passport(w: Workflow) -> dict:
    _require(w.status in ("CERTIFIED", "REJECTED", "PUBLICATION_REVIEW", "PUBLISHED"), "not decided")
    return {"version": "1.1-demo", "institution": w.tenant, "jurisdiction": w.jurisdiction,
            "item_id": w.item_id, "mode": w.mode, "outcome": "PASSED" if w.tally[0] > w.tally[1] and w.tally[0]+w.tally[1]>0 else "FAILED",
            "motion_hash": w.locked_motion_hash, "rules_hash": w.locked_rule_hash,
            "roster_hash": w.locked_roster_hash, "event_root": w.log_root, "tally": list(w.tally),
            "certifier": w.certifier, "publication_hash": w.publication_hash or None,
            "claims": ["SIMULATED_TALLY", "SIMULATED_AUTHORITY_CHECK"],
            "legal_authority": False, "independent_review": False}
