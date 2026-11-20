"""Public author calibration for trusted code. Usage: python check.py candidate"""
import sqlite3, tempfile, sys
from pathlib import Path
if not __debug__:
    raise RuntimeError('Calibration requires assertions enabled')
sys.path.insert(0,sys.argv[1])
import legacy as v1, rollout as v2

def check(group, db, path):
    if group==0:
        assert v2.read(db,'b')=={'primary':1} and v2.read(db,'a')=={'primary':0}
        v1.ship(db,'a')
        assert v2.read(db,'a')=={'primary':1}
    if group==1:
        v2.write(db,'b','other',False)
        assert v1.status(db,'b')=='partial'
        v2.write(db,'b','other',True)
        assert v1.status(db,'b')=='shipped'
    if group==2:
        v2.write(db,'a','extra',True)
        v2.write(db,'a','extra',False)
        v2.install(db)
        assert v2.read(db,'a')=={'extra':1,'primary':0}
    if group==3:
        assert v2.backfill(db,1)==1
        v1.ship(db,'a')
        assert v2.backfill(db,1)==1 and v2.backfill(db,1)==0
    if group==4:
        db.execute('BEGIN')
        assert v2.backfill(db,1)==1
        v2.write(db,'a','extra',True)
        db.rollback()
        with sqlite3.connect(path) as fresh:
            assert 'extra' not in v2.read(fresh,'a')
            assert v2.backfill(fresh,1)==1 and v2.backfill(fresh,1)==0

for group in range(5):
    with tempfile.TemporaryDirectory() as td:
        path=Path(td)/'db'
        with sqlite3.connect(path) as db:
            v1.bootstrap(db)
            db.executemany('INSERT INTO orders VALUES (?)',[('a',),('b',)])
            v1.ship(db,'b')
            v2.install(db)
            db.commit()
            try: check(group,db,path)
            except AssertionError: print(group,'fail')
            else: print(group,'pass')
