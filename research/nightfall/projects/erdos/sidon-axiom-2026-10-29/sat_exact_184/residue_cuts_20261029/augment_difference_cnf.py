#!/usr/bin/env python3
"""Derived SAT cuts for N184 k9. The original difference CNF is unchanged logically."""
import sys,json,hashlib,argparse
from pathlib import Path
try:
    from build_difference_sat import CNF
except ModuleNotFoundError:
    # On GitHub the prior exact difference-CNF builder is a sibling directory.
    sys.path.insert(0,str(Path(__file__).resolve().parent.parent / 'difference_sat_20261029'))
    from build_difference_sat import CNF
from residue_bounds import census

def attach(cnf, N,k,selected=None):
    X=cnf.X
    if selected is None: selected=(3,7,9,10)
    summaries=[]; keys=[]
    for m in selected:
        report=census(N,k,m)
        caps=report['per_residue_max_allowed']
        for residue,cap in enumerate(caps):
            if cap<0:raise ValueError('no admissible residue profiles: would need global UNSAT certificate')
            vals=[(a,X[a]) for a in range(1,N+1) if a%m==residue]
            if len(vals)<=cap:continue
            # Sinz at-most-K sequential counter: one-way prefix-at-least flags.
            # Exact existential encoding, with no reverse gates required.
            n=len(vals)
            counter={}
            for i in range(1,n):
                for level in range(1,min(i,cap)+1):
                    counter[i,level]=cnf.v(('sinz',m,residue,i,level))
            for i in range(1,n):
                xi=vals[i-1][1]
                cnf.c(-xi,counter[i,1])
                if i>1:
                    for level in range(1,min(i-1,cap)+1):
                        cnf.c(-counter[i-1,level],counter[i,level])
                    for level in range(2,min(i,cap)+1):
                        cnf.c(-xi,-counter[i-1,level-1],counter[i,level])
            for i in range(cap+1,n+1):
                cnf.c(-vals[i-1][1],-counter[i-1,cap])
            keys.append((m,residue,cap))
        summaries.append({'m':m,'caps':caps,'profiles':report['total_profiles'],'rejected':report['profile_capacity_rejected']})
    return {'cuts':keys,'censuses':summaries}

def expanded_assignment(cnf,base_values,marks):
    selected=set(marks)
    out=dict(base_values)
    for var,key in enumerate(cnf.keys[1:],1):
        if var in out:continue
        kind,m,r,pos,j=key
        if kind!='sinz':raise AssertionError(key)
        residue_positions=[a for a in range(1,cnf.N+1) if a%m==r]
        out[var]=sum(a in selected for a in residue_positions[:pos])>=j
    assert len(out)==len(cnf.keys)-1
    return out

def check_literals(cnf,model):
    return [i for i,clause in enumerate(cnf.clauses) if not any(model[abs(t)] == (t>0) for t in clause)]

def main():
    p=argparse.ArgumentParser();p.add_argument('--output',default='sidon_N184_k9_residue.cnf');p.add_argument('--quick',action='store_true');a=p.parse_args()
    n,k=184,9
    cnf=CNF().build(n,k);base_vars=len(cnf.keys)-1;base_clauses=len(cnf.clauses)
    marks=[1,2,4,10,14,37,91,109,154]
    ref=cnf.assignment(marks);bad_base=check_literals(cnf,ref)
    assert bad_base, 'known unsaturated fixture must fail base'
    add=attach(cnf,n,k)
    full=expanded_assignment(cnf,ref,marks)
    bad_new=check_literals(cnf,full)
    assert bad_new, 'known unsaturated fixture cannot satisfy augmented'
    assert all(z[0]=='sinz' for z in cnf.keys[base_vars+1:])
    info={'N':n,'k':k,'base_vars':base_vars,'base_clauses':base_clauses,'augmented_vars':len(cnf.keys)-1,'augmented_clauses':len(cnf.clauses),'new_vars':len(cnf.keys)-1-base_vars,'new_clauses':len(cnf.clauses)-base_clauses,'residue_cuts':len(add['cuts']), 'censuses':add['censuses'],'known_unsaturated_fixture':marks,'baseline_failed_clauses':len(bad_base),'augmented_failed_clauses':len(bad_new)}
    if not a.quick:
        cnf.save(a.output)
        info['cnf_sha256']=hashlib.sha256(Path(a.output).read_bytes()).hexdigest()
    print(json.dumps(info,sort_keys=True))

if __name__=='__main__':main()
