#!/usr/bin/env python3
"""JP-01 source-blind event/assignment integrity preflight; synthetic only.
No human data, source-isolation proof, digital signatures, or efficacy claims.
"""
import argparse
import copy
import hashlib
import hmac
from itertools import permutations
import json
import re
import sys

VERSION = 'nightfall-jp01-instrument-v0.1'
ARMS = ('ordinary', 'adversary', 'blind')
HEX64 = re.compile(r'^[a-f0-9]{64}$')
ALIAS = re.compile(r'^p[0-9]{4,8}$')  # pseudonyms only; no emails or names
FIELDS = frozenset(('alias', 'decision_id', 'seq', 't', 'kind', 'role',
                    'visible_sources', 'content_sha256', 'prev_hash', 'event_hash'))
ORDER = {
    'ordinary': ('brief', 'lead', 'final'),
    'adversary': ('brief', 'lead', 'alternative', 'final'),
    'blind': ('brief', 'precommit', 'alternative', 'lead', 'final'),
}

class Refusal(ValueError):
    pass

def require(ok, message):
    if not ok:
        raise Refusal(message)

def canonical(obj):
    return json.dumps(obj, sort_keys=True, separators=(',', ':'), ensure_ascii=True).encode()

def digest(data):
    return hashlib.sha256(data).hexdigest()

def randomization(seed, aliases):
    """Deterministic balanced 3-person blocks and per-decision HMAC leans.
    This is a preflight proposal, not a power analysis or approved study randomizer.
    """
    require(len(seed) == 32 and isinstance(seed, bytes), 'Seed must be 32 bytes')
    require(len(aliases) % 3 == 0 and len(set(aliases)) == len(aliases),
            'Aliases must form complete distinct blocks of three')
    require(all(ALIAS.fullmatch(a) for a in aliases) and aliases == sorted(aliases),
            'Aliases must be sorted pseudonyms pNNNN')
    out = []
    for i, alias in enumerate(aliases):
        block = i // 3
        raw = hmac.digest(seed, ('jp01-v01|block|%d' % block).encode(), 'sha256')
        choice = next((b % 6 for b in raw if b < 252), None)
        require(choice is not None, 'Unusable block randomization digest')
        ordering = tuple(permutations(ARMS))[choice]
        leans = []
        for d in range(1, 5):
            h = hmac.digest(seed, ('jp01-v01|lean|%s|%d' % (alias,d)).encode(), 'sha256')
            leans.append(h[0] & 1)
        out.append(dict(alias=alias, arm=ordering[i % 3], leans=leans))
    return out

def add_event(events, alias, seq, t, decision_id, kind, role, visible_sources, content_sha256, previous):
    event = dict(alias=alias, seq=seq, t=t, decision_id=decision_id,
                 kind=kind, role=role, visible_sources=visible_sources,
                 content_sha256=content_sha256, prev_hash=previous)
    event['event_hash'] = digest(canonical(event))
    events.append(event)
    return event['event_hash']

def make_fixture(seed=bytes.fromhex('07'*32)):
    participants = randomization(seed, ['p%04d' % i for i in range(1,13)])
    manifest = dict(version=VERSION, label='SYNTHETIC_FIXTURE',
                    task_pack_sha256=digest(b'fixture-frozen-task-v1'),
                    prompt_pack_sha256=digest(b'fixture-frozen-prompt-v1'),
                    seed_sha256=digest(seed), participants=participants)
    events = []
    for p in participants:
        alias, arm = p['alias'], p['arm']
        prev = '0'*64; seq = 0
        plan = [(0, 'consent')] + [(d, k) for d in range(1,5) for k in ('brief',) + ORDER[arm][1:]] + [(0,'debrief')]
        for d,k in plan:
            seq += 1
            role = ('source_blind_adversary' if arm=='blind' else 'visible_adversary') if k=='alternative' else 'participant'
            view = ['brief','evidence'] if (k=='precommit' or (k=='alternative' and arm=='blind')) else (['brief','evidence','lead'] if k=='alternative' else [])
            prev = add_event(events,alias,seq,100000*int(alias[1:])+seq,d,k,role,view,
                             digest((alias+'|'+str(d)+'|'+k).encode()),prev)
    return manifest, events

def audit(manifest, events, seed=None):
    require(isinstance(manifest,dict) and manifest.get('version')==VERSION, 'Unknown instrument version')
    require(set(manifest)=={'version','label','task_pack_sha256','prompt_pack_sha256','seed_sha256','participants'}, 'Unexpected manifest fields')
    require(manifest.get('label') in ('SYNTHETIC_FIXTURE','REAL_UNRELEASED'), 'Explicit fixture/release label required')
    for key in ('task_pack_sha256','prompt_pack_sha256','seed_sha256'):
        require(isinstance(manifest.get(key),str) and HEX64.fullmatch(manifest[key]), 'Bad frozen '+key)
    subjects=manifest.get('participants')
    require(isinstance(subjects,list) and len(subjects)>=3, 'No complete participant manifest')
    aliases=[p.get('alias') for p in subjects if isinstance(p,dict)]
    require(len(aliases)==len(subjects) and len(set(aliases))==len(aliases), 'Duplicate participant alias')
    require(len(subjects)%3==0 and aliases==sorted(aliases) and all(ALIAS.fullmatch(a) for a in aliases), 'Invalid participant blocks')
    require(all(set(p)=={'alias','arm','leans'} and p.get('arm') in ARMS and
                isinstance(p.get('leans'),list) and len(p['leans'])==4 and
                all(type(z) is int and z in (0,1) for z in p['leans']) for p in subjects), 'Bad arm or lean vector')
    # A sha256 commitment alone cannot prove randomized assignment. Require withheld seed on audit.
    require(isinstance(seed,bytes) and len(seed)==32 and digest(seed)==manifest['seed_sha256'], 'Seed missing/mismatched: randomization cannot be audited')
    require(subjects==randomization(seed, aliases), 'Tampered or nonrandomized arm/lean manifest')
    require(isinstance(events,list) and events, 'Missing event ledger')
    by_id={a:[] for a in aliases}
    for event in events:
        require(isinstance(event,dict) and frozenset(event)==FIELDS, 'Unexpected/raw event fields (possible leakage)')
        require(event.get('alias') in by_id, 'Unknown participant event')
        require(isinstance(event.get('seq'),int) and not isinstance(event['seq'],bool), 'Noninteger event sequence')
        require(isinstance(event.get('t'),int) and not isinstance(event['t'],bool), 'Noninteger event timestamp')
        require(isinstance(event.get('content_sha256'),str) and HEX64.fullmatch(event['content_sha256']), 'Unredacted or bad content hash')
        require(isinstance(event.get('prev_hash'),str) and HEX64.fullmatch(event['prev_hash']), 'Invalid hash link')
        require(isinstance(event.get('event_hash'),str) and HEX64.fullmatch(event['event_hash']), 'Invalid event hash')
        require(event['event_hash']==digest(canonical({k:v for k,v in event.items() if k!='event_hash'})), 'Altered event or hash')
        by_id[event['alias']].append(event)
    for p in subjects:
        alias,arm=p['alias'],p['arm']; group=by_id[alias]
        expected=[(0,'consent')]+[(d,k) for d in range(1,5) for k in ORDER[arm]]+[(0,'debrief')]
        require(len(group)==len(expected), 'Missing/extra events for '+alias)
        previous='0'*64; prev_t=-1
        for i,(event,(d,kind)) in enumerate(zip(group,expected),1):
            require(event['seq']==i and event['t']>prev_t and event['prev_hash']==previous,
                    'Sequence/timestamp/hash-link broken for '+alias)
            require(event['decision_id']==d and event['kind']==kind, 'Precommit/consent/debrief order violation for '+alias)
            expect_role=('source_blind_adversary' if arm=='blind' else 'visible_adversary') if kind=='alternative' else 'participant'
            require(event['role']==expect_role, 'Reviewer role assignment mismatch')
            view=event['visible_sources']
            require(isinstance(view,list) and all(isinstance(v,str) for v in view), 'Malformed source visibility')
            if kind=='precommit' or (kind=='alternative' and arm=='blind'):
                require(view==['brief','evidence'], 'Blindness leakage in precommit/adversary source view')
            prev_t=event['t']; previous=event['event_hash']
    return dict(status='SYNTHETIC_INSTRUMENT_PREFLIGHT' if manifest['label']=='SYNTHETIC_FIXTURE' else 'METADATA_AUDIT_ONLY',
                subjects=len(subjects), events=len(events), arms={a:sum(p['arm']==a for p in subjects) for a in ARMS},
                manifest_randomization_replayed=True, chronological_consent_debrief=True,
                blind_view_declarations_checked=True,
                limitations=['Hash chains can be rewritten without external anchoring/signatures',
                             'Declared source visibility does not prove runtime isolation',
                             'Consent/debrief event presence does not prove meaningful informed consent',
                             'No participant outcomes, randomized human trial, independent grades, or effectiveness estimate'])

def selftest():
    seed=bytes.fromhex('07'*32)
    manifest,events=make_fixture(seed)
    good=audit(manifest,events,seed)
    assert good['subjects']==12 and good['events']>200
    bad=[]
    def changed_manifest(mutator):
        m=copy.deepcopy(manifest);mutator(m);return m,copy.deepcopy(events),seed
    def changed_events(mutator):
        e=copy.deepcopy(events);mutator(e);return copy.deepcopy(manifest),e,seed
    bad.append(changed_manifest(lambda m: m['participants'][0]['leans'].__setitem__(0,1-m['participants'][0]['leans'][0])))
    bad.append(changed_manifest(lambda m: m['participants'].__setitem__(1,copy.deepcopy(m['participants'][0]))))
    bad.append(changed_manifest(lambda m: m.__setitem__('version','nightfall-jp01-instrument-v9')))
    bad.append(changed_events(lambda e: e.__setitem__(0,dict(e[0],content_sha256='a'*64))))
    bad.append(changed_events(lambda e: e.pop(2)))
    bad.append(changed_events(lambda e: e.__setitem__(next(i for i,v in enumerate(e) if v['kind']=='precommit'), dict(e[next(i for i,v in enumerate(e) if v['kind']=='precommit')],visible_sources=['brief','evidence','lead']))))
    bad.append(changed_events(lambda e: e.__setitem__(1,dict(e[1],secret_preference=1))))
    bad.append((manifest,events,None))
    # Attack the order despite recomputing the full hash chain.
    corrupt=copy.deepcopy(events)
    idx=next(i for i,e in enumerate(corrupt) if e['kind']=='precommit')
    corrupt[idx]['kind']='lead'
    alias=corrupt[idx]['alias'];last='0'*64
    for e in corrupt:
        if e['alias']!=alias:continue
        e['prev_hash']=last
        e['event_hash']=digest(canonical({k:v for k,v in e.items() if k!='event_hash'}))
        last=e['event_hash']
    bad.append((manifest,corrupt,seed))
    for i,args in enumerate(bad,1):
        try:audit(*args)
        except Refusal:continue
        raise AssertionError('Mutation survived rejection: %d' % i)
    print(json.dumps(dict(good,negative_mutations_rejected=len(bad)),sort_keys=True,indent=2))
    print('NO HUMAN DATA; NO PRIVACY GUARANTEE; NO CAUSAL VALIDITY CLAIM')

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--self-test',action='store_true')
    p.add_argument('--manifest');p.add_argument('--events');p.add_argument('--seed-file',help='Private local 64-character hexadecimal seed (never commit)')
    args=p.parse_args()
    try:
        if args.self_test:selftest();return
        require(all((args.manifest,args.events,args.seed_file)), 'All three input paths required')
        with open(args.manifest,encoding='utf8') as f:manifest=json.load(f)
        with open(args.events,encoding='utf8') as f:events=[json.loads(line) for line in f if line.strip()]
        with open(args.seed_file,encoding='utf8') as f:seed=bytes.fromhex(f.read().strip())
        print(json.dumps(audit(manifest,events,seed),sort_keys=True,indent=2))
    except (OSError,ValueError,TypeError,KeyError) as exc:
        print('JP-01 INSTRUMENT REFUSED: '+str(exc),file=sys.stderr);sys.exit(2)
if __name__=='__main__':main()
