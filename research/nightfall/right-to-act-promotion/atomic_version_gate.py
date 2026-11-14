"""Version-bound offline ControlArena promotion: cooperative trusted-directory model.

Source worktrees are untrusted; only a snapshotted source version selected
under a trusted lock can be synthesized. Policy and source revision both advance
one durable epoch. This is NOT isolation against native code that can write to
the trusted directory or an AWS deployment reference monitor.
"""
from __future__ import annotations
from dataclasses import dataclass
from pathlib import Path
from contextlib import contextmanager
import fcntl
import hashlib
import json
import os
import shutil
import tempfile
from promotion_runner import canon, hash_source, digest_json, synth
from independent_effect_verifier import check_promotion

@dataclass(frozen=True)
class Ticket:
    epoch: int
    version: str
    source_hash: str
    policy_hash: str
    baseline_hash: str
    template_hash: str

class VersionedGate:
    def __init__(self, baseline, policy, trusted):
        self.baseline=baseline
        self.base_hash=digest_json(baseline)
        self.dir=Path(trusted)
        self.dir.mkdir(parents=True,exist_ok=True)
        self.snapshots=self.dir/'snapshots'
        self.snapshots.mkdir(exist_ok=True)
        self.lock=self.dir/'gate.lock'
        self.state_file=self.dir/'state.json'
        self.published=self.dir/'published.json'
        with self._locked():
            if not self.state_file.exists():
                self._write(self.state_file,dict(epoch=1,revoked=False,
                    base_hash=self.base_hash,version=None,source_hash=None,
                    policy=policy,policy_hash=digest_json(policy)))
            self._state()

    @contextmanager
    def _locked(self):
        with self.lock.open('a+b') as f:
            fcntl.flock(f,fcntl.LOCK_EX)
            try:yield
            finally:fcntl.flock(f,fcntl.LOCK_UN)

    def _write(self,path,obj):
        fd,name=tempfile.mkstemp(prefix='.atomic-',dir=self.dir)
        try:
            with os.fdopen(fd,'wb') as f:
                f.write(canon(obj));f.flush();os.fsync(f.fileno())
            os.replace(name,path)
            fd_dir=os.open(self.dir,os.O_RDONLY)
            try:os.fsync(fd_dir)
            finally:os.close(fd_dir)
        finally:
            if os.path.exists(name):os.unlink(name)

    def _state(self):
        s=json.loads(self.state_file.read_text())
        keys={'epoch','revoked','base_hash','version','source_hash','policy','policy_hash'}
        if (set(s)!=keys or type(s['epoch']) is not int or s['epoch']<1
                or type(s['revoked']) is not bool
                or s['base_hash']!=self.base_hash
                or s['policy_hash']!=digest_json(s['policy'])
                or ((s['version'] is None)!=(s['source_hash'] is None))):
            raise RuntimeError('corrupt or mismatched trusted authority state')
        if s['version'] is not None and (not isinstance(s['version'],str)
                or not s['version'].startswith('v-')
                or not s['version'][2:].isdigit()):
            raise RuntimeError('invalid version identifier')
        return s

    def _snapshot(self,s):
        if s['version'] is None:raise RuntimeError('no admitted source')
        folder=self.snapshots/s['version']
        if not folder.is_dir() or folder.is_symlink() or hash_source(folder)!=s['source_hash']:
            raise RuntimeError('admitted snapshot changed or missing')
        return folder

    def admit(self,worktree):
        """Trusted intake under same lock; only captured snapshot is authoritative."""
        worktree=Path(worktree)
        with self._locked():
            s=self._state()
            if s['revoked']:raise RuntimeError('revoked')
            before=hash_source(worktree) # rejects symlinks
            version=f"v-{s['epoch']+1:08d}"
            destination=self.snapshots/version
            if destination.exists():raise RuntimeError('version collision')
            temp=Path(tempfile.mkdtemp(prefix='.source-',dir=self.dir))
            try:
                shutil.copytree(worktree,temp/'tree',ignore=shutil.ignore_patterns(
                    'cdk.out','__pycache__','.pytest_cache','.git','.venv'))
                after=hash_source(temp/'tree')
                if before!=after or hash_source(worktree)!=before:
                    raise RuntimeError('source changed during admission')
                os.replace(temp/'tree',destination)
            finally:shutil.rmtree(temp,ignore_errors=True)
            s.update(epoch=s['epoch']+1,version=version,source_hash=before)
            self._write(self.state_file,s)
            return version,before

    def revise_policy(self,policy):
        with self._locked():
            s=self._state()
            if s['revoked']:raise RuntimeError('revoked')
            s.update(epoch=s['epoch']+1,policy=policy,policy_hash=digest_json(policy))
            self._write(self.state_file,s)
            return s['epoch']

    def revoke(self):
        with self._locked():
            s=self._state()
            s.update(epoch=s['epoch']+1,revoked=True)
            self._write(self.state_file,s)
            return s['epoch']

    def _check(self,s):
        snapshot=self._snapshot(s)
        with tempfile.TemporaryDirectory(prefix='.check-',dir=self.dir) as tmp:
            work=Path(tmp)/'source'
            shutil.copytree(snapshot,work)
            if hash_source(work)!=s['source_hash']:
                raise RuntimeError('snapshot copy mismatch')
            artifact,seconds=synth(work)
            proof=check_promotion(self.baseline,artifact,s['policy'])
            if hash_source(snapshot)!=s['source_hash']:
                raise RuntimeError('snapshot changed during check')
            return artifact,proof,seconds

    def prepare(self):
        with self._locked():
            s=self._state()
            if s['revoked']:raise RuntimeError('revoked')
        artifact,proof,seconds=self._check(s)
        return Ticket(s['epoch'],s['version'],s['source_hash'],s['policy_hash'],
                      self.base_hash,digest_json(artifact)),proof,seconds

    def promote(self,ticket):
        with self._locked():
            s=self._state()
            if s['revoked'] or s['epoch']!=ticket.epoch:
                return False,'revoked or version epoch changed',None
            if (s['version']!=ticket.version or s['source_hash']!=ticket.source_hash
                or s['policy_hash']!=ticket.policy_hash or
                self.base_hash!=ticket.baseline_hash):
                return False,'source/policy/baseline mismatch',None
            try:
                artifact,proof,seconds=self._check(s)
            except Exception as exc:
                return False,'effect verification failed: '+repr(exc),None
            if digest_json(artifact)!=ticket.template_hash:
                return False,'synthesized template changed after certification',None
            record=dict(template=artifact,version=s['version'],
                        source_hash=s['source_hash'],policy_hash=s['policy_hash'],
                        baseline_hash=self.base_hash,epoch=s['epoch'],
                        template_hash=ticket.template_hash)
            self._write(self.published,record)
            return True,'verified atomic local publication',dict(
                record_sha256=digest_json(record),proof=proof,seconds=seconds)
