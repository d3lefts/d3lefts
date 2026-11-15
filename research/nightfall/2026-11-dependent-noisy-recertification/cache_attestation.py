#!/usr/bin/env python3
"""Ed25519 authenticated *scope-bound* cached-evidence prototype.

Crypto authenticates bytes, not correctness/freshness of the attested model.
For demo/tests keys are generated in memory; deploy using hardware-backed keys,
trusted clocks, protected provenance and change-impact monitoring.
"""
from __future__ import annotations
from fractions import Fraction as Q
from hashlib import sha256
import json
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey
from cryptography.exceptions import InvalidSignature

def canonical(v):
    return json.dumps(v,sort_keys=True,separators=(',',':'),ensure_ascii=True).encode()

def digest(obj):return sha256(canonical(obj)).hexdigest()

# P(U=u|B=b), rows b=0,1. Sensor Z is cached noisy reading of U.
PU1=[Q(1,4),Q(3,4)]
CHANNEL_ERROR=Q(1,4)

def conditional_source():
    return {'p_u1_given_b':[str(q) for q in PU1],
            'alphabet':'binary', 'conditional_separator':['b'],
            'factor_scope':'U|B'}

def channel_source():
    return {'sensor':'cached_z','p_error':str(CHANNEL_ERROR),
            'noise_independent_of_active_sensors_given_u':True}

def message(z):
    # Sufficient stat retained is u itself; future mission may depend on U.
    return {f'{b}:{u}':str((PU1[b] if u else (1-PU1[b])) *
                        ((1-CHANNEL_ERROR) if z==u else CHANNEL_ERROR))
            for b in (0,1) for u in (0,1)}

def issue(secret:Ed25519PrivateKey,epoch:int,z:int):
    payload={
        'schema':'nightfall.cache.v0.2',
        'mission_id':'modular-agent-match-v0.2',
        'region_id':'U-sector',
        'boundary':['b'],
        'obs_type':'cached_z',
        'obs_value':z,
        'observation_epoch':epoch,
        'issued_epoch':epoch,
        'expires_epoch':epoch+3,
        'serial':'NF-U-001',
        'factor_digest':digest(conditional_source()),
        'channel_digest':digest(channel_source()),
        'message_digest':digest(message(z)),
        'derivation':'exact-conditional-sum-v1',
    }
    return {'payload':payload,'signature':secret.sign(canonical(payload)).hex(), 'key_id':'unit-test-issuer'}

class CacheReject(Exception):pass

def validate(token,public_key, now_epoch, accepted_factor_hash=None,
             accepted_channel_hash=None, expected_mission='modular-agent-match-v0.2',
             revoked=frozenset(), expected_impact_complete=True):
    if not expected_impact_complete: raise CacheReject('unverified change-impact closure')
    if token.get('key_id')!='unit-test-issuer':raise CacheReject('unknown trust anchor')
    p=token.get('payload',{})
    try:
        public_key.verify(bytes.fromhex(token['signature']), canonical(p))
    except (KeyError,ValueError,InvalidSignature) as e:
        raise CacheReject('signature invalid') from e
    if p.get('schema')!='nightfall.cache.v0.2':raise CacheReject('schema mismatch')
    if p.get('mission_id')!=expected_mission:raise CacheReject('mission mismatch')
    if p.get('region_id')!='U-sector' or p.get('boundary')!=['b']:
        raise CacheReject('region or separator mismatch')
    if p.get('obs_type')!='cached_z' or p.get('obs_value') not in (0,1):
        raise CacheReject('invalid observation')
    if p.get('serial') in revoked:raise CacheReject('revoked certificate')
    if not p['observation_epoch']<=p['issued_epoch']<=now_epoch<=p['expires_epoch']:
        raise CacheReject('expired or future cache')
    if p.get('factor_digest')!=(accepted_factor_hash or digest(conditional_source())):
        raise CacheReject('conditional source changed')
    if p.get('channel_digest')!=(accepted_channel_hash or digest(channel_source())):
        raise CacheReject('sensor channel changed')
    if p.get('message_digest')!=digest(message(p['obs_value'])):
        raise CacheReject('message content changed')
    if p.get('derivation')!='exact-conditional-sum-v1':
        raise CacheReject('derivation version changed')
    return message(p['obs_value'])

def posterior_u_given_z(message_dict, prior_b1):
    prior=(1-prior_b1,prior_b1)
    num=sum((prior[b]*Q(message_dict[f'{b}:1']) for b in (0,1)),Q(0))
    den=sum((prior[b]*Q(message_dict[f'{b}:{u}']) for b in (0,1) for u in (0,1)),Q(0))
    return num/den

def audit():
    priv=Ed25519PrivateKey.generate();pub=priv.public_key()
    t=issue(priv,epoch=12,z=1)
    m=validate(t,pub,now_epoch=13)
    assert posterior_u_given_z(m,Q(1,2))==Q(3,4)
    assert posterior_u_given_z(m,Q(1,3))==Q(15,22)
    checks=[]
    def reject(name,token,**opts):
        try:validate(token,pub,now_epoch=opts.pop('now_epoch',13),**opts)
        except CacheReject:checks.append(name)
        else:raise AssertionError(f'FAIL-OPEN {name}')
    import copy
    tamper=copy.deepcopy(t);tamper['payload']['obs_value']=0
    reject('tampered observation',tamper)
    reject('expired evidence',t,now_epoch=16)
    reject('changed conditional factor',t,accepted_factor_hash='0'*64)
    reject('changed observation channel',t,accepted_channel_hash='0'*64)
    reject('revocation',t,revoked=frozenset({'NF-U-001'}))
    reject('wrong mission',t,expected_mission='another mission')
    reject('incomplete impact closure',t,expected_impact_complete=False)
    wrongkey=Ed25519PrivateKey.generate().public_key()
    reject('wrong public key',t) if False else None
    try:validate(t,wrongkey,13)
    except CacheReject:checks.append('wrong trust anchor')
    else: raise AssertionError('FAIL-OPEN wrong trust anchor')
    assert len(checks)==8
    return {'status':'PASS','reused_message_exact':True,
            'old_unconditional_posterior':'3/4','current_unconditional_posterior':'15/22',
            'rejection_cases':checks}

if __name__=='__main__': print(json.dumps(audit(),sort_keys=True))

