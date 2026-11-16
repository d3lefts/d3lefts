"""Synthetic fixtures and adversarial unit tests; stdlib-only."""
from __future__ import annotations
import copy
from dataclasses import asdict, replace
from itertools import product
import unittest

from workflow_model import (
    Actor, Rules, establish, amend, advance, cast, certify,
    prepare_publication, approve_publication, abort, check_log, passport, digest
)
from independent_checker import verify

T = "fictional-uah-sga"
AUTHOR = Actor("author", T, frozenset({"AUTHOR"}))
CLERK = Actor("clerk", T, frozenset({"CLERK"}))
CHAIR = Actor("presider", T, frozenset({"PRESIDER"}))
REVIEWER1 = Actor("reviewer-1", T, frozenset({"RELEASE_REVIEWER"}))
REVIEWER2 = Actor("reviewer-2", T, frozenset({"RELEASE_REVIEWER"}))
VOTERS = [Actor("member"+str(i), T, frozenset({"MEMBER"})) for i in range(1,4)]
ALL = [AUTHOR, CLERK, CHAIR, REVIEWER1, REVIEWER2] + VOTERS


def fixture(*, mode="DEMO", rules=None, attendance=None):
    return establish("SB-014", T, "fictional-student-senate", mode, AUTHOR,
                     "Resolve to extend fictional study-space hours.",
                     rules or Rules("rules-v1", quorum=2),
                     {p.id for p in VOTERS},
                     attendance if attendance is not None else {p.id for p in VOTERS})


def reach_open(w):
    for actor, action in ((AUTHOR,"SUBMIT_REVIEW"),(CLERK,"SET_AGENDA"),(CHAIR,"OPEN_DEBATE"),
                          (CHAIR,"LOCK_MOTION"),(CHAIR,"OPEN_BALLOT")):
        w = advance(w,actor,action)
    return w


def decision(choices=("AYE","AYE","NAY"), *, amended=False, publish=True):
    w = fixture()
    if amended: w=amend(w,AUTHOR,"Resolve to extend fictional study-space hours on weekdays.")
    w=reach_open(w)
    for a,choice in zip(VOTERS,choices): w=cast(w,a,choice)
    w=advance(w,CHAIR,"CLOSE_BALLOT")
    w=certify(w,CLERK)
    if publish:
        w=prepare_publication(w,CLERK)
        w=approve_publication(w,REVIEWER1)
        w=approve_publication(w,REVIEWER2)
    return w


def evidence(w):
    return {"tenant":w.tenant, "jurisdiction":w.jurisdiction, "item_id":w.item_id,
            "mode":w.mode, "rules":asdict(w.rules), "roster":sorted(w.roster),
            "attendance":sorted(w.attendance), "events":[asdict(e) for e in w.events],
            "actors":{a.id:{"tenant":a.tenant,"is_human":a.is_human,"roles":sorted(a.roles)} for a in ALL},
            "status":w.status,"text":w.text,"revision":w.revision,"author":w.author,
            "casts":[list(pair) for pair in w.casts],"tally":list(w.tally) if w.tally else None,
            "release_reviewers":list(w.release_reviewers)}


class WorkflowTests(unittest.TestCase):
    def test_happy_path(self):
        w=decision()
        self.assertEqual((w.status,w.tally),("PUBLISHED",(2,1,0)))
        self.assertTrue(check_log(w))
        self.assertEqual(verify(passport(w), evidence(w)),(True,()))

    def test_amendment_forces_new_review(self):
        w=advance(fixture(),AUTHOR,"SUBMIT_REVIEW")
        w=amend(w,AUTHOR,"Changed proposal")
        self.assertEqual((w.status,w.revision),("DRAFT",2))
        with self.assertRaises(ValueError): advance(w,CLERK,"SET_AGENDA")
        self.assertTrue(verify(passport(decision(amended=True)),evidence(decision(amended=True)))[0])

    def test_no_amend_after_lock(self):
        w=reach_open(fixture())
        with self.assertRaises(ValueError): amend(w,AUTHOR,"Rewrite")

    def test_no_duplicate_cast(self):
        w=cast(reach_open(fixture()),VOTERS[0],"AYE")
        with self.assertRaises(ValueError): cast(w,VOTERS[0],"NAY")

    def test_cross_tenant_no_cast(self):
        w=reach_open(fixture())
        with self.assertRaises(PermissionError): cast(w,Actor(VOTERS[0].id,"other",frozenset({"MEMBER"})),"AYE")

    def test_synthetic_cannot_act(self):
        bot=Actor("agent",T,frozenset({"AUTHOR","CLERK","PRESIDER","RELEASE_REVIEWER"}),False)
        with self.assertRaises(PermissionError): establish("a",T,"j","DEMO",bot,"text",Rules("r",2),{"a","b"},{"a","b"})
        with self.assertRaises(PermissionError): advance(fixture(),bot,"SUBMIT_REVIEW")
        with self.assertRaises(PermissionError): cast(reach_open(fixture()),Actor(VOTERS[0].id,T,frozenset(),False),"AYE")

    def test_official_disabled(self):
        w=fixture(mode="OFFICIAL")
        for actor,action in ((AUTHOR,"SUBMIT_REVIEW"),(CLERK,"SET_AGENDA"),(CHAIR,"OPEN_DEBATE")):
            w=advance(w,actor,action)
        with self.assertRaises(ValueError): advance(w,CHAIR,"LOCK_MOTION")

    def test_official_enabled_claim_still_fails_closed(self):
        w=fixture(mode="OFFICIAL",rules=Rules("r",2,official_enabled=True,authorization_ref="fictional"))
        for actor,action in ((AUTHOR,"SUBMIT_REVIEW"),(CLERK,"SET_AGENDA"),(CHAIR,"OPEN_DEBATE")):
            w=advance(w,actor,action)
        with self.assertRaises(ValueError): advance(w,CHAIR,"LOCK_MOTION")

    def test_quorum_missing(self):
        w=fixture(attendance={VOTERS[0].id})
        for actor,action in ((AUTHOR,"SUBMIT_REVIEW"),(CLERK,"SET_AGENDA"),(CHAIR,"OPEN_DEBATE")):
            w=advance(w,actor,action)
        with self.assertRaises(ValueError): advance(w,CHAIR,"LOCK_MOTION")

    def test_current_rule_lost(self):
        w=reach_open(fixture())
        w=replace(w,rules=replace(w.rules,current=False))
        with self.assertRaises(ValueError): cast(w,VOTERS[0],"AYE")
        with self.assertRaises(ValueError): advance(w,CHAIR,"CLOSE_BALLOT")

    def test_stay(self):
        w=replace(reach_open(fixture()),rules=Rules("rules-v1",2,no_stay=False))
        with self.assertRaises(ValueError): advance(w,CHAIR,"CLOSE_BALLOT")

    def test_rule_version_tamper(self):
        w=reach_open(fixture())
        w=replace(w,rules=Rules("rules-v2",2))
        with self.assertRaises(ValueError): cast(w,VOTERS[0],"AYE")
        with self.assertRaises(ValueError): advance(w,CHAIR,"CLOSE_BALLOT")

    def test_roster_tamper(self):
        w=reach_open(fixture())
        w=replace(w,roster=frozenset({VOTERS[0].id,VOTERS[1].id}))
        with self.assertRaises(ValueError): advance(w,CHAIR,"CLOSE_BALLOT")

    def test_insufficient_or_ineligible_voter(self):
        w=reach_open(fixture())
        with self.assertRaises(ValueError): cast(w,AUTHOR,"AYE")
        with self.assertRaises(ValueError): cast(w,VOTERS[0],"APPROVE")

    def test_double_release_reviewer(self):
        w=prepare_publication(decision(publish=False),CLERK)
        w=approve_publication(w,REVIEWER1)
        with self.assertRaises(ValueError):approve_publication(w,REVIEWER1)
        with self.assertRaises(PermissionError): approve_publication(w,AUTHOR)

    def test_author_not_clerk(self):
        w=advance(reach_open(fixture()),CHAIR,"CLOSE_BALLOT")
        with self.assertRaises(PermissionError): certify(w,AUTHOR)

    def test_no_publish_without_certification(self):
        with self.assertRaises(ValueError):prepare_publication(fixture(),CLERK)

    def test_abort_does_not_permit_draft_mutation(self):
        w=abort(reach_open(fixture()),CHAIR,"Motion withdrawn")
        self.assertEqual(w.status,"VOIDED")
        with self.assertRaises(ValueError):amend(w,AUTHOR,"Restart")

    def test_defeated_measure_is_certified_failure(self):
        w=decision(("NAY","NAY","AYE"))
        self.assertEqual(w.status,"PUBLISHED")
        self.assertEqual(passport(w)["outcome"],"FAILED")
        self.assertTrue(verify(passport(w),evidence(w))[0])

    def test_abstentions_not_ayes(self):
        w=decision(("ABSTAIN","ABSTAIN","ABSTAIN"),publish=False)
        self.assertEqual((w.status,w.tally),("REJECTED",(0,0,3)))
        self.assertTrue(verify(passport(w),evidence(w))[0])

    def test_checker_rejects_tally_forgery(self):
        w=decision();p=passport(w);p["tally"]=[3,0,0]
        self.assertFalse(verify(p,evidence(w))[0])

    def test_checker_rejects_changed_source(self):
        w=decision();e=evidence(w);e["text"]="New text injected"
        self.assertFalse(verify(passport(w),e)[0])

    def test_checker_rejects_changed_vote(self):
        w=decision();e=evidence(w)
        for event in e["events"]:
            if event["name"]=="CAST":
                event["payload"]["choice"]="NAY";break
        self.assertFalse(verify(passport(w),e)[0])

    def test_checker_rejects_changed_actors(self):
        w=decision();e=evidence(w);e["actors"]["clerk"]["is_human"]=False
        self.assertFalse(verify(passport(w),e)[0])

    def test_checker_rejects_missing_event(self):
        w=decision();e=evidence(w);e["events"].pop(3)
        self.assertFalse(verify(passport(w),e)[0])

    def test_checker_rejects_wrong_roster(self):
        w=decision();e=evidence(w);e["roster"].remove(VOTERS[1].id)
        self.assertFalse(verify(passport(w),e)[0])

    def test_checker_rejects_fake_reviewers(self):
        w=decision();e=evidence(w);e["release_reviewers"]=["clerk","clerk"]
        self.assertFalse(verify(passport(w),e)[0])

    def test_exhaustive_ternary_ballots_small_instance(self):
        # All 3^3 outcomes, independently rechecked with no shared tally implementation.
        for choices in product(("AYE","NAY","ABSTAIN"),repeat=3):
            w=decision(choices,publish=True)
            expected=(choices.count("AYE"),choices.count("NAY"),choices.count("ABSTAIN"))
            self.assertEqual(w.tally,expected)
            self.assertEqual(passport(w)["outcome"],"PASSED" if expected[0]>expected[1] else "FAILED")
            self.assertEqual(verify(passport(w),evidence(w)),(True,()))


if __name__=="__main__": unittest.main(verbosity=2)
