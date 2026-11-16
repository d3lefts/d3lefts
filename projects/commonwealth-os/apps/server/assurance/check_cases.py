#!/usr/bin/env python3
"""Independent bounded oracle for synthetic decision traces; NOT a Lean->Node refinement proof."""
import sys, json, hashlib
TRANSITIONS={
 'CREATE':(None,'DRAFT'),'SUBMIT':('DRAFT','IN_REVIEW'),'AGENDA':('IN_REVIEW','AGENDA_SET'),
 'BEGIN':('AGENDA_SET','DELIBERATING'),'ATTEND':('DELIBERATING','DELIBERATING'),
 'LOCK':('DELIBERATING','MOTION_LOCKED'),'OPEN':('MOTION_LOCKED','BALLOT_OPEN'),
 'CAST':('BALLOT_OPEN','BALLOT_OPEN'),'CLOSE':('BALLOT_OPEN','BALLOT_CLOSED'),
 'REVIEW':('BALLOT_CLOSED','REVIEWED_DEMO')
}
ROLES={'CREATE':'member','SUBMIT':'member','AGENDA':'chair','BEGIN':'chair','ATTEND':'clerk','LOCK':'chair','OPEN':'chair','CAST':'member','CLOSE':'chair','REVIEW':'clerk'}

def oracle(record):
    votes=[];attendees=[];last=None;locked=None;reviewer=None
    assert len(record['trace']) == 12
    for step in record['trace']:
        name,role=step['action'],step['role']
        assert name in TRANSITIONS
        assert (step['from'],step['to']) == TRANSITIONS[name],(name,'state mismatch')
        assert step['from']==last and role==ROLES[name],(name,'role/state')
        if name=='ATTEND':
            attendees=step['details']['attendees'];assert sorted(attendees)==['member-a','member-b','member-c']
        elif name=='LOCK':
            locked=step['details'];assert len(attendees)>=record['policy']['quorum']
            assert locked['policyVersion']==1 and locked['lockedRevision']==1
        elif name in ('OPEN','CAST','CLOSE','REVIEW'):
            assert locked is not None
            for field in ('policyVersion','eligibilityVersion','lockedRevision'):
                assert step['details'][field]==locked[field],(name,field)
            if name=='CAST':
                assert step['actor'] in attendees
                assert step['actor'] not in {x[0] for x in votes}
                assert step['details']['voter']==step['actor']
                assert step['details']['choice'] in ('yes','no','abstain')
                votes.append((step['actor'],step['details']['choice']))
            elif name=='REVIEW':
                reviewer=step
                assert step['actor'] not in [a for a,v in votes] and step['actor']!='member-a'
        last=step['to']
    assert reviewer is not None and len(votes)==3
    assert [v for a,v in votes]==record['choices']
    p=record['policy'];yes=sum(v=='yes' for a,v in votes);no=sum(v=='no' for a,v in votes)
    abstain=sum(v=='abstain' for a,v in votes)
    denominator={'DECISIVE':yes+no,'CAST':len(votes),'PRESENT':len(attendees),'ELIGIBLE':3}[p['approvalBasis']]
    left=yes*p['yesDenominator'];right=denominator*p['yesNumerator']
    passed=denominator>0 and (left>right if p['strict'] else left>=right)
    expected='SUPPORTED_IN_SIMULATION' if passed else 'REJECTED_IN_SIMULATION'
    assert record['outcome']==expected,(record['basis'],record['strict'],record['choices'])
    assert reviewer['details']['counts']=={'yes':yes,'no':no,'abstain':abstain}
    assert reviewer['details']['outcome']==expected
    return 1

count=0;keys=set()
for raw in sys.stdin:
    if not raw.strip():continue
    data=json.loads(raw)
    key=(data['basis'],data['strict'],tuple(data['choices']))
    assert key not in keys,'duplicate trace'
    keys.add(key);count+=oracle(data)
assert count==216,(count,'incomplete finite enumeration')
print(json.dumps({'finite_cases':count,'result':'PASS','proof_status':'BOUNDED_TESTS_ONLY'}))
