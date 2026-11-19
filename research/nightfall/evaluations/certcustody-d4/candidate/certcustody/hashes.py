"""Source-byte identity and canonical receipt utilities."""
import hashlib
import hmac
import json

def git_blob(data):
    return hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()

def canonical(obj):
    return (json.dumps(obj, sort_keys=True, separators=(',', ':'), ensure_ascii=True, allow_nan=False) + '\n').encode()

def signature(key, obj):
    return hmac.new(key, canonical(obj), hashlib.sha256).hexdigest()

def valid_signature(key, obj, sig):
    return isinstance(sig, str) and hmac.compare_digest(signature(key, obj), sig)
