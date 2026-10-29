#!/usr/bin/env python3
"""Independent integer-only verifier for prefix-compatible Sidon finite certificates.
Separate from builder; recomputes pair-sum uniqueness, difference uniqueness,
original-prefix preservation, finite density margin, and negative mutation.
"""
import sys,json,hashlib,math

def check(vals):
    d={};s={}
    for i,a in enumerate(vals):
        for b in vals[i+1:]:
            delta=b-a
            if delta in d:return False,{'kind':'difference','collision':(d[delta],(a,b))}
            d[delta]=(a,b)
        for b in vals[i:]:
            x=a+b
            if x in s:return False,{'kind':'sum','collision':(s[x],(a,b))}
            s[x]=(a,b)
    return True,{'sums':len(s),'differences':len(d)}

def main(path):
    record=json.load(open(path)); values=record['sorted_marks'];prefix=record['A'];p=record['p'];L=record['L'];
    assert all(isinstance(x,int) for x in values)
    assert values==sorted(set(values));assert set(prefix).issubset(values)
    assert len(values)==record['total'];assert max(values)==record['M'];assert L==p*p-1
    ok,details=check(values)
    assert ok,details
    assert 2*len(values)**2>record['M']  # finite > 1/sqrt(2) at M
    digest=hashlib.sha256(','.join(map(str,values)).encode()).hexdigest()
    assert digest==record['marks_sha256']
    # Independently compute a falsifying insertion of any omitted integer, if one exists.
    value_set=set(values); bad=None
    for z in range(1,max(values)+1):
        if z in value_set:continue
        # For isolated one-point insertion near the prefix, direct repeated-diff witness.
        # This loop is bounded to a short adversarial search; it is not maximality testing.
        if z>120:break
        ok2,detail2=check(sorted(values+[z]))
        if not ok2:bad={'insertion':z,'witness':detail2};break
    assert bad is not None
    print(json.dumps({'status':'PASS','p':p,'count':len(values),'max':max(values),
    'ratio':len(values)/math.sqrt(max(values)),'sums':details['sums'],
    'diffs':details['differences'],'sha256':digest,'negative_control':bad},sort_keys=True))
if __name__=='__main__':main(sys.argv[1])
