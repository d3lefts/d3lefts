#!/usr/bin/env python3
"""Independent fixed-radix exact upper certificate for PhaseShift V3."""
from pathlib import Path
from fractions import Fraction
import hashlib,sys
N=131072
D=1<<70
H=N//2
WIDTH=20
EXPECTED_HASH='46ba45724bb7ff98f6b28b4b7ef3bcf2390f747db8ca290ae0f2f0eaba63c59c'
P=34788888032172582064857141282352546289212755441
Q=91343852333181432387730302044767688728495783936

def verify(path):
 raw=Path(path).read_bytes()
 assert hashlib.sha256(raw).hexdigest()==EXPECTED_HASH
 a=list(map(int,raw.split()))
 assert len(a)==N and all(0<=v<=D for v in a) and sum(a)==H*D
 assert N*D*D<1<<(8*WIDTH)
 def pack(seq):return int.from_bytes(b''.join(int(x).to_bytes(WIDTH,'little') for x in seq),'little')
 x=pack(a);y=pack([D-v for v in a[::-1]])
 coeff=(x*y).to_bytes((2*N-1)*WIDTH,'little')
 s=[int.from_bytes(coeff[i*WIDTH:(i+1)*WIDTH],'little') for i in range(2*N-1)]
 peak=max(s)
 lags=[i-(N-1) for i,v in enumerate(s) if v==peak]
 assert Fraction(peak,H*D*D)==Fraction(P,Q) and lags==[-17354]
 runner=max(v for v in s if v<peak)
 runner_lags=[i-(N-1) for i,v in enumerate(s) if v==runner]
 assert runner_lags==[-5962,5962]
 for k in (-N+1,-17354,-5962,5962,0,36482,N-1):
  direct=sum(a[i]*(D-a[i-k]) for i in range(max(0,k),min(N,N+k)))
  assert direct==s[k+N-1],k
 print('PASS', N,'heights',2*N-1,'signed shifts; max',peak,'/',H*D*D,'at',lags,'runner at',runner_lags)

if __name__=='__main__':
 assert len(sys.argv)==2,'Usage: python3 verify_upper.py phase_v3_heights_u70.txt'
 verify(sys.argv[1])
