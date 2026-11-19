"""Serialized, crash-consistent single-document authority state on Linux."""
import contextlib
import fcntl
import json
import os
from pathlib import Path
import tempfile

class Store:
    def __init__(self, path):
        self.path = Path(path)
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.lock = self.path.with_suffix(self.path.suffix + '.lock')

    @contextlib.contextmanager
    def locked(self):
        with self.lock.open('a+b') as lockfile:
            fcntl.flock(lockfile, fcntl.LOCK_EX)
            try:
                yield
            finally:
                fcntl.flock(lockfile, fcntl.LOCK_UN)

    def read(self):
        return json.loads(self.path.read_text('utf-8'))

    def write(self, value):
        fd, tmp = tempfile.mkstemp(prefix='.authority-', dir=self.path.parent)
        try:
            with os.fdopen(fd, 'w', encoding='utf-8') as stream:
                os.fchmod(stream.fileno(), 0o600)
                json.dump(value, stream, sort_keys=True, separators=(',', ':'), allow_nan=False)
                stream.write('\n')
                stream.flush()
                os.fsync(stream.fileno())
            os.replace(tmp, self.path)
            dfd = os.open(self.path.parent, os.O_RDONLY)
            try:
                os.fsync(dfd)
            finally:
                os.close(dfd)
        finally:
            if os.path.exists(tmp):
                os.unlink(tmp)
