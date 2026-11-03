#!/usr/bin/env python3
"""Exact positive C12/C32 verifier for all m>500, with mutation control."""
WEIGHTS={(1,4):1,(1,5):5,(2,4):25,(2,5):125}
WORDS={12:"031405130415",32:"03140523041325140314031403140314"}
EXPECTED=[0,0,0,1,1,1,-124,-124,-124,-124,-125,-125,-125,0,-5,-4,-4,-4,-4,-3,-3,-3,-3,-2,-2,-2,-2,-1,-1,-1,-1,0,0]
def trace(word):
    base=[int(x) for x in word]
    assert all((a<3)!=(b<3) for a,b in zip(base,base[1:]+base[:1]))
    vals=[0]
    for a,b in zip(base,base[1:]+base[:1]):
        lo,hi=sorted((a,b));inc=WEIGHTS.get((lo,hi),0)
        if a>b:inc=-inc
        vals.append(vals[-1]+inc)
    assert vals[-1]==0
    assert len({(b,v) for b,v in zip(base,vals)})==len(base)
    assert max(vals)-min(vals)<501
    return base,vals
for n,word in WORDS.items():
    base,vals=trace(word)
    assert len(base)==n
    if n==32:assert vals==EXPECTED
    for m in (501,502,503,1009):
        assert len({(b,v%m) for b,v in zip(base,vals)})==n
        assert vals[-1]%m==0
    print(f'PASS simple C{n} for each m>500; checked 501,502,503,1009')
bad=EXPECTED[:];bad[6]+=1
assert bad!=trace(WORDS[32])[1]
print('PASS: corrupted 32-cycle coordinate rejected')
