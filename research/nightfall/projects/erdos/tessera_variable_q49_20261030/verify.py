#!/usr/bin/env python3
"""Exact, no-solver verifier: two q49 successor repairs of a protected q25 set."""
from hashlib import sha256
from math import ceil,gcd
from generate_field import singer
V=2451
D=singer()
BASE=(1,23,70,150,200,604,655,664,669,671,688,800,899,940,988,1013,1017,1045,1066,1081,1108,1121,1167)
BLOCK1=(15,33,157,322,473,657,898,1051,1211,1212,1437,1449,1702,1776,1931,2123,2398,2428)
BLOCK2=(100,235,258,505,817,860,1084,1619,1713,1953,2187,2353,2384)
H0='feb60c46538147823f59d57f0cc868c40a1b7deab3256ede8a9e2f02c57980dd'
H1='fbe94e71d0367fb9da77951f5a847296b60c61699239d764a08e3ec808500ced'
H2='10a14f4a22a89850c569c066dffbdb016392cdb2e5743cb659ce8c68615b8cb8'
def digest(S):return sha256(('\n'.join(map(str,S))+'\n').encode()).hexdigest()
def sums(S):return [a+b for i,a in enumerate(S) for b in S[i:]]
def diffs(S):return [b-a for i,a in enumerate(S) for b in S[i+1:]]
def sidon(S):
    ss=sums(S);dd=diffs(S)
    assert ss and len(ss)==len(set(ss))==len(S)*(len(S)+1)//2
    assert len(dd)==len(set(dd))
def cut(u,c):return tuple(sorted((u*d+c)%V for d in D))
def extend(old,u,c,keep,T):
    Q=cut(u,c)
    assert gcd(u,V)==1 and set(keep)<=set(Q) and len(set(keep))==len(keep)
    assert T>2*max(old) and T>max(old)+max(Q)
    assert set(diffs(old)).isdisjoint(diffs(keep))
    S=tuple(sorted(old+tuple(T+x for x in keep)))
    sidon(S)
    # Independent negative control: restoring one forbidden source mark
    # must cause an integer pair-sum collision.
    reject=next((x for x in Q if x not in keep and
                 len(set(sums(tuple(sorted(S+(T+x,))))))<
                 (len(S)+1)*(len(S)+2)//2),None)
    assert reject is not None
    return S,reject
assert len(D)==50 and len({(x-y)%V for x in D for y in D if x!=y})==V-1
sidon(BASE); assert digest(BASE)==H0
S1,invalid1=extend(BASE,1,1581,BLOCK1,3619)
S2,invalid2=extend(S1,2,0,BLOCK2,12095)
assert (len(S1),max(S1),len(sums(S1)))==(41,6047,861)
assert (len(S2),max(S2),len(sums(S2)))==(54,14479,1485)
assert digest(S1)==H1 and digest(S2)==H2
# Singer's uniqueness of every ordered modular difference gives, for every
# old positive diff 0<d<V, exactly V-d cuts realizing positive integer diff d.
def averaged_edge_check(old):
    old_small={d for d in diffs(old) if d<V}
    theoretical=sum(V-d for d in old_small)
    measured=0;best=V
    for c in range(V):
        Q=cut(1,c);newdiff=set(diffs(Q))
        count=len(old_small & newdiff)
        measured+=count
        best=min(best,count)
    assert measured==theoretical
    e_bound=theoretical//V
    # Caro-Wei / Turan bound alpha(G)>=ceil(K*K/(2*e+K))
    guarantee=ceil(50*50/(50+2*e_bound))
    assert best<=e_bound
    return theoretical,best,guarantee
for j,old in enumerate((BASE,S1)):
    total,minimum,guarantee=averaged_edge_check(old)
    print('PASS cut ledger',j,'sum',total,'minimum tested',minimum,
          'universal guaranteed surviving source marks',guarantee)
print('PASS q49 GF7^6 Singer',len(D),'all',V-1,'nonzero differences')
print('PASS stage2',len(S1),'max',max(S1),'pair sums',len(sums(S1)),
      'SHA256',digest(S1),'adversarial omitted mark',invalid1)
print('PASS stage3',len(S2),'max',max(S2),'pair sums',len(sums(S2)),
      'SHA256',digest(S2),'adversarial omitted mark',invalid2)
