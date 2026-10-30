#!/usr/bin/env python3
"""Independent, deliberately brute-force verifier: no builder imports or helpers."""
import json,sys,itertools,hashlib

def run(path):
    raw=open(path,'rb').read()
    data=json.loads(raw)
    assert data['schema']=='nightfall-singer-deletion-barrier-v1'
    for row in data['examples']:
        v=row['modulus']; S=row['difference_set']; k=row['k']
        assert len(S)==k and len(set(S))==k and all(0<=x<v for x in S)
        assert v==k*(k-1)+1
        diff=[]
        for x in S:
            for y in S:
                if x!=y: diff.append((x-y)%v)
        assert sorted(diff)==list(range(1,v))
        assert len(row['deletions'])==v-k
        for item in row['deletions']:
            a=item['a']; assert a not in S and 0<=a<v
            T=0
            for x in S:
                for y in S:
                    for z in S:
                        if (x+y-z-a)%v==0: T+=1
            assert T==item['ordered_triples']==k
            # This is a second code path: directly check pair sums, not differences.
            min_r=k+1
            for r in range(k+1):
                found=False
                for removed in itertools.combinations(S,r):
                    kept=[x for x in S if x not in removed]
                    elems=kept+[a]
                    pairs=[(elems[i]+elems[j])%v for i in range(len(elems)) for j in range(i,len(elems))]
                    if len(set(pairs))==len(pairs):
                        found=True
                        assert r>=((k+3)//4)
                        break
                if found: min_r=r; break
            assert min_r==item['minimum_deletions'],(v,a,min_r,item['minimum_deletions'])
        assert row['minimum_deletions_across_a']==min(x['minimum_deletions'] for x in row['deletions'])
        assert row['maximum_deletions_across_a']==max(x['minimum_deletions'] for x in row['deletions'])
        print(f"PASS v={v} k={k} external-a={v-k} min/max deletions={row['minimum_deletions_across_a']}/{row['maximum_deletions_across_a']}")
    print('CERTIFICATE_SHA256',hashlib.sha256(raw).hexdigest())

if __name__=='__main__': run(sys.argv[1])
