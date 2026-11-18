"""Canonical wire data and HMAC utilities; no outside network dependencies."""
import hashlib
import hmac
import json

def canonical(value):
    return (json.dumps(value, sort_keys=True, separators=(',', ':'), ensure_ascii=True, allow_nan=False) + '\n').encode('ascii')

def digest(value):
    return hashlib.sha256(canonical(value)).hexdigest()

def sign(key, body):
    return hmac.new(key, canonical(body), hashlib.sha256).hexdigest()

def packet(key, body):
    return {'body': body, 'signature': sign(key, body)}

def verify(key, envelope):
    return (isinstance(envelope, dict) and isinstance(envelope.get('body'), dict)
            and isinstance(envelope.get('signature'), str)
            and hmac.compare_digest(envelope['signature'], sign(key, envelope['body'])))
