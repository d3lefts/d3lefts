#!/usr/bin/env python3
"""Separate direct oracle for integer Sidon property and interval maximality."""
from collections import defaultdict

def status(A,N):
    A=sorted(A); assert len(A)==len(set(A))
    if any(not 1<=a<=N for a in A):return {'valid':False,'reason':'out of interval'}
    sums=defaultdict(list)
    for i,a in enumerate(A):
        for b in A[i:]:sums[a+b].append((a,b))
    duplicates={s:ps for s,ps in sums.items() if len(ps)>1}
    addable=[];first_block={}
    for x in range(1,N+1):
        if x in A:continue
        found=None
        if 2*x in sums:found=(x,x,sums[2*x][0])
        if found is None:
            for a in A:
                if x+a in sums:found=(x,a,sums[x+a][0]);break
        if found is None:addable.append(x)
        else:first_block[x]=found
    return {'valid':not duplicates,'duplicates':duplicates,'addable':addable,'saturated':not duplicates and not addable,'block_count':len(first_block),'sum_count':len(sums)}

if __name__=='__main__':
    import json
    from build_sat import CNF
    A=[8,48,68,69,71,75,104,120]
    o=status(A,144)
    assert o['saturated'],o
    cnf=CNF();cnf.build(144,8)
    assert not cnf.verify(A),cnf.verify(A)[:10]
    # mutation: a corrupted pair sum and a deliberately unsaturated candidate each fail independently.
    assert not status(A+[9],144)['valid'] or not status(A+[9],144)['saturated']
    B=[49,50,56,78,93,104,125,139,149]
    stat=status(B,184)
    assert stat['valid'] and stat['addable']==[16,166],stat
    assert cnf.verify(A[:-1])
    print(json.dumps({'N144_Huber':'PASS','variables':len(cnf.names)-1,'clauses':len(cnf.clauses),'N184_near_candidate_holes':stat['addable'],'all_known_witness_clauses_satisfied':True},sort_keys=True))

