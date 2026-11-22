#!/usr/bin/env python3
"""A seeded numerical collision against a genuinely adaptive R^4, m=6 policy.
NOT a proof of the global theorem; only a separate stress test of the
artificial-history reduction and the direct measurement transcript.
Requires numpy and scipy. Run: python phase_collision_probe.py
"""
import numpy as np
from scipy.optimize import least_squares

N, M = 4, 6
BASE = np.array([
    [1, 2,-1, 1], [2,-1, 1, 2], [1, 1, 2,-2],
    [-1,2, 1, 1], [2, 1,-2, 1], [1,-2, 2, 2]], float)/7
D = np.array(
    [[[((i+2*j+3*k)%7)-3 for i in range(N)]
      for k in range(M)] for j in range(M)], float)/29
COLOR = (0, 1, 0, 1, 0, 1)

def row(j, h):
    a = BASE[j].copy()
    for k,y in enumerate(h):
        a += D[j,k]*y/(1+y)
    return a/3   # continuous and norm <=1 for nonnegative histories

def fake(z):
    u, v = z[:N], z[N:]
    h, eq = [], []
    for j in range(M):
        a = row(j,h)
        if COLOR[j] == 0:
            eq.append(np.dot(a,u))
            h.append(float(np.dot(a,v)**2))
        else:
            eq.append(np.dot(a,v))
            h.append(float(np.dot(a,u)**2))
    return np.array(eq),np.array(h)

def actual(x):
    h = []
    for j in range(M):
        a = row(j,h)
        h.append(float(np.dot(a,x)**2))
    return np.array(h)

def objective(z):
    eq, _ = fake(z)
    return np.r_[eq, np.dot(z[:N],z[:N])-1, np.dot(z[N:],z[N:])-1]

def main():
    rng = np.random.default_rng(20261122)
    best = None
    for trial in range(50):
        z = np.r_[rng.normal(size=N),rng.normal(size=N)]
        z[:N] /= np.linalg.norm(z[:N])
        z[N:] /= np.linalg.norm(z[N:])
        fit = least_squares(objective,z,xtol=1e-12,ftol=1e-12,
                            gtol=1e-12,max_nfev=3000)
        err = np.max(np.abs(objective(fit.x)))
        if best is None or err < best[0]:
            best = (err,fit.x,trial)
        if err < 1e-10:
            break
    err,z,trial = best
    u,v = z[:N],z[N:]
    difference = float(np.max(np.abs(actual(u+v)-actual(u-v))))
    print('trial:',trial)
    print('max artificial residual:',format(err,'.4g'))
    print('max true transcript difference:',format(difference,'.4g'))
    print('u:',repr(u.tolist()))
    print('v:',repr(v.tolist()))
    assert err < 1e-8 and difference < 1e-8
    h,g=fake(z)
    for z2,tag in ((np.r_[-u,v],0),(np.r_[u,-v],1)):
        hh,gg=fake(z2)
        assert np.max(np.abs(hh-h)) < 1e-12
        assert np.max(np.abs(gg-np.array([
            -t if COLOR[j] == tag else t for j,t in enumerate(g)]))) < 1e-12
    print('PASS: illustrative numeric collision; NOT a topology certificate')

if __name__ == '__main__':
    main()
