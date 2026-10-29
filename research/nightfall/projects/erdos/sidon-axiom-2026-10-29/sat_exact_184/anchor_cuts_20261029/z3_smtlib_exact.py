#!/usr/bin/env python3
"""Z3 C-API independent SAT route for frozen DIMACS; exit 0 is test only, never claim UNSAT w/o independent proof."""
import argparse, ctypes, hashlib, sys, time
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('cnf');p.add_argument('--timeout',type=int,default=15000);p.add_argument('--model',default='');p.add_argument('--smt',default='');args=p.parse_args()
lib=ctypes.CDLL('libz3.so.4')
lib.Z3_mk_config.restype=ctypes.c_void_p
lib.Z3_mk_context.argtypes=[ctypes.c_void_p]; lib.Z3_mk_context.restype=ctypes.c_void_p
lib.Z3_eval_smtlib2_string.argtypes=[ctypes.c_void_p,ctypes.c_char_p];lib.Z3_eval_smtlib2_string.restype=ctypes.c_char_p
lib.Z3_del_context.argtypes=[ctypes.c_void_p];lib.Z3_del_config.argtypes=[ctypes.c_void_p]
lines=Path(args.cnf).read_text().splitlines()
head=next(l for l in lines if l.startswith('p cnf'))
_,_,vs,cs=head.split();nv=int(vs);nc=int(cs)
clauses=[]
for l in lines:
 if not l or l[0] in 'cp':continue
 ints=[int(x) for x in l.split()];assert ints[-1]==0
 clauses.append(ints[:-1])
assert len(clauses)==nc
print('INPUT',args.cnf,'variables',nv,'clauses',nc,'sha256',hashlib.sha256(Path(args.cnf).read_bytes()).hexdigest(),flush=True)
ss=[f'(set-option :timeout {args.timeout})',f'(set-option :produce-models true)']
ss.extend(f'(declare-const v{i} Bool)' for i in range(1,nv+1))
for clause in clauses:
 parts=['v'+str(l) if l>0 else '(not v'+str(-l)+')' for l in clause]
 ss.append('(assert '+('false' if not parts else parts[0] if len(parts)==1 else '(or '+' '.join(parts)+')')+')')
ss.append('(check-sat)')
if args.model: ss.append('(get-value ('+' '.join('v'+str(i) for i in range(1,185))+'))')
script='\n'.join(ss)+'\n'
if args.smt:Path(args.smt).write_text(script)
ctx=lib.Z3_mk_context(lib.Z3_mk_config())
t0=time.time()
res=lib.Z3_eval_smtlib2_string(ctx,script.encode('utf-8'))
output=(res or b'').decode(errors='replace')
print('Z3_RESULT',repr(output[:8000]),'elapsed_sec',round(time.time()-t0,2),flush=True)
if args.model and output.startswith('sat') and args.model:
 import re
 ids=[int(n) for n in re.findall(r'\(v(\d+) true\)',output)]
 Path(args.model).write_text(' '.join(map(str,ids))+'\n')
 print('MODEL_TRUE',ids[:184],flush=True)
lib.Z3_del_context(ctx)
