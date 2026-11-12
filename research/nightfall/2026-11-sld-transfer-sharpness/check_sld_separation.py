#!/usr/bin/env python3
"""Independent replay for NIGHTFALL SLD sharpness / rank-one tensor lemma.

Two independent representations are checked:
  * exact Fraction arithmetic for the character-filter construction and the
    resulting rational gain/visibility coefficients;
  * direct complex-density-matrix averaging and quantum SLD Bayes gain;
  * random simple Hermitian tensor inequalities, checked from the eigenbasis
    formula, independently of the Jensen proof.

The finite tests are NOT a formal proof of a universal theorem.
"""
from fractions import Fraction as F
from itertools import product
from math import pi, sqrt
import numpy as np


def exact_character(exponents):
    """Exactly E[cos(sum theta_j) prod omega^(s_j x_j)], omega^3=1."""
    n = len(exponents)
    return (F(1, 2) if all((1+s)%3==0 for s in exponents) else F(0)) + (
            F(1, 2) if all((-1+s)%3==0 for s in exponents) else F(0))


def exact_check():
    for n in range(1, 9):
        for s in product((-1, 0, 1), repeat=n):
            got = exact_character(s)
            target = F(1,2) if all(x==-1 for x in s) or all(x==1 for x in s) else F(0)
            assert got == target, (n,s,got,target)
        p, q = F(3,4),F(1,4)
        u2 = p*q
        a = 2*u2
        gain = u2**n/(p**n+q**n)
        gain_closed = F(3**n, 4**n*(3**n+1))
        assert gain == gain_closed
        assert gain/(a**n * F(1,2)) == F(2**(n+1),3**n+1)
        print(f"EXACT d={n} a={a} V=I=1/2 quantum_gain={gain} normalized_ratio={gain/(a**n * F(1,2))}")
    print("PASS: exact root-of-unity filter and formulas d=1..8")


def direct_density_check():
    p=0.75; q=0.25; u=sqrt(p*q)
    omega=np.exp(2j*pi/3)
    rho=[np.array([[p,u*omega**(-j)],[u*omega**j,q]],complex) for j in range(3)]
    assert all(np.linalg.norm(r@r-r)<1e-12 for r in rho)
    local_mean=sum(rho)/3
    assert np.max(np.abs(local_mean-np.diag([p,q])))<1e-12
    # Direct local Gram in L^2-orthonormal cosine/sine basis.
    g=np.array([[sqrt(2)*np.cos(2*pi*j/3), sqrt(2)*np.sin(2*pi*j/3)] for j in range(3)])
    tangent=[sum(g[j,k]*rho[j] for j in range(3))/3 for k in range(2)]
    gram=np.zeros((2,2),float)
    for k in range(2):
        for l in range(2):
            gram[k,l]=sum((2*tangent[k][r,c]*tangent[l][c,r]/(local_mean[r,r]+local_mean[c,c])).real for r in range(2) for c in range(2))
    assert np.max(np.abs(gram-(3/8)*np.eye(2)))<1e-12, gram
    for n in range(1, 7):
        N=2**n
        B=np.zeros((N,N),complex); A=np.zeros((N,N),complex)
        for xs in product(range(3),repeat=n):
            prod_rho=np.array([[1.]],complex)
            for j in xs: prod_rho=np.kron(prod_rho,rho[j])
            B+=prod_rho/3**n
            A+=np.cos(2*pi*sum(xs)/3)*prod_rho/3**n
        eig=np.real(np.diag(B))
        assert np.max(np.abs(B-np.diag(eig)))<3e-12
        mask=np.ones_like(A,dtype=bool);mask[0,-1]=False; mask[-1,0]=False
        assert np.max(np.abs(A[mask]))<3e-12
        observed=np.sum(2*np.abs(A)**2/(eig[:,None]+eig[None,:])).real
        expected=F(3**n,4**n*(3**n+1))
        assert abs(observed-float(expected))<1e-11,(n,observed,expected)
        # Partial traces of the extreme offdiagonal A are zero on any proper Q.
        assert np.max(np.abs(A[0,-1]-sqrt(p*q)**n/2))<3e-12
        print(f"MATRIX d={n} gain={observed:.12g} predicted={float(expected):.12g}")
    print('PASS: direct matrices, noncommuting pure qubits, local Gram d<=6')


def energy(bdiag,H):
    """Bures/SLD scalar Bayes energy from spectral sum, diagonal reference b."""
    return float(np.sum(2*np.abs(H)**2/(bdiag[:,None]+bdiag[None,:])).real)


def check_tensor_lemma():
    rng=np.random.default_rng(20261111)
    minratio=float('inf')
    for n in (2,3,4):
        for _ in range(200):
            ds=rng.integers(2,4,size=n)
            spectra=[]; tangents=[]
            for dim in ds:
                vals=rng.uniform(.02,1,size=dim); vals/=sum(vals)
                X=rng.normal(size=(dim,dim))+1j*rng.normal(size=(dim,dim))
                H=X+X.conj().T
                spectra.append(vals); tangents.append(H)
            eig=np.array([1.]);bigH=np.array([[1]],complex);small=1.
            for vals,H in zip(spectra,tangents):
                eig=np.kron(eig,vals)
                bigH=np.kron(bigH,H)
                small*=energy(vals,H)
            large=energy(eig,bigH)
            ratio=large/small
            minratio=min(minratio,ratio)
            assert ratio>=1-2e-12,(n,ratio)
    print(f"PASS: 600 independently sampled Hermitian tensor inequality models; min ratio={minratio:.12g}")


if __name__=='__main__':
    exact_check()
    direct_density_check()
    check_tensor_lemma()
    print('ALL CHECKS PASS')
