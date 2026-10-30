#!/usr/bin/env python3
"""Independent brute pair-sum appendability check, no blocker-formula imports."""
import sys,json,itertools,hashlib

def valid(A):
    s=[x+y for i,x in enumerate(A) for y in A[i:]]
    return len(s)==len(set(s))

def missing(A,N):
    assert valid(A)
    return [x for x in range(1,N+1) if x not in A and valid(list(A)+[x])]

if __name__=='__main__':
    path=sys.argv[1];raw=open(path,'rb').read();c=json.loads(raw)
    assert c['schema']=='nightfall-sidon156-one-mark-lift-v1'
    A=c['source_witness'];N=c['N']; assert N==184
    assert len(A)==8 and valid(A)
    assert not [x for x in range(1,145) if x not in A and valid(A+[x])]
    assert len(c['one_mark_extensions'])==40
    best=(100000,None)
    valid_count=0
    for i,row in enumerate(c['one_mark_extensions']):
        x=i+145;assert row['new_mark']==x
        B=A+[x]
        assert row['sidon']==valid(B)
        if valid(B):
            valid_count+=1
            holes=missing(B,N)
            assert holes==row['missing']
            if len(holes)<best[0]:best=(len(holes),x)
            assert holes
        else: assert row['missing'] is None
    assert valid_count==24 and best==(10,152)
    B=c['near_candidate'];assert len(B)==9 and len(set(B))==9
    assert missing(B,N)==c['near_candidate_missing']==[16,166]
    print('PASS fixed Huber 144 witness; 40 candidate ninth marks; 24 valid, minimum 10 holes at x=152')
    print('PASS separate 9-mark near-candidate; missing [16,166]; NOT a maximal set')
    print('CERTIFICATE_SHA256',hashlib.sha256(raw).hexdigest())
