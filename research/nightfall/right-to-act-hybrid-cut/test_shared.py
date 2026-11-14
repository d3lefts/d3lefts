from fractions import Fraction
import random
import pytest
from shared_evidence import Test,exact_enumeration,laminar_dynamic_program,is_laminar,example


def test_shared_evidence_defeats_edge_local_cut():
    U,ts,guards=example()
    val,p=exact_enumeration(U,ts,guards)
    assert val==1
    assert sum(guards.values())==12
    assert laminar_dynamic_program(U,ts,guards)[0]==val
    assert 'one-joint-evidence' in p[0]


def test_crossing_family_rejected():
    ts=[Test('a',frozenset({'x','y'}),Fraction(1),Fraction(1)),
        Test('b',frozenset({'y','z'}),Fraction(1),Fraction(1))]
    assert not is_laminar(ts)
    with pytest.raises(ValueError):laminar_dynamic_program({'x','y','z'},ts,{x:Fraction(3) for x in ['x','y','z']})


def test_laminar_dp_independent_exact_enumeration_randomized():
    rng=random.Random(76180)
    for case in range(400):
        n=rng.randint(1,7)
        U={str(i) for i in range(n)}
        # A chain or disjoint family generated from nested partitions is laminar.
        groups=[frozenset(U)]
        for i in range(n):groups.append(frozenset({str(i)}))
        # Random disjoint pairs of consecutive items plus root, no crossing groups.
        for j in range(0,n-1,2):groups.append(frozenset({str(j),str(j+1)}))
        groups=list(set(groups))
        tests=[Test('t'+str(j),g,Fraction(rng.randrange(1,10),rng.randrange(1,4)),
                    Fraction(rng.randrange(1,10),rng.randrange(1,4))) for j,g in enumerate(groups) if rng.randrange(4)!=0]
        guards={x:Fraction(rng.randrange(1,10),rng.randrange(1,5)) for x in U}
        assert is_laminar(tests)
        a,_=exact_enumeration(U,tests,guards)
        b,_=laminar_dynamic_program(U,tests,guards)
        assert a==b,(case,a,b)
