#!/usr/bin/env python3
"""Abstract atomic promotion evaluator.

This is an executable finite-state *specification*, not a filesystem/network
reference monitor. Sound guards and evidence verification are assumptions.
No action is dispatched to real infrastructure.
"""
from __future__ import annotations
from collections import deque
from dataclasses import dataclass
from threading import RLock
from hybrid_cut import Network, Edge


@dataclass(frozen=True)
class Ticket:
    epoch: int
    policy: str
    side: frozenset[str]
    cut_edges: tuple[str,...]


class LocalPromotionKernel:
    def __init__(self, net: Network):
        self._lock = RLock()
        self.policy = net.policy
        self.edges = {e.id: e for e in net.edges}
        self.digest = {e.id:e.digest for e in net.edges}
        self.certificates = {
            e.id: (e.cached_policy,e.cached_digest)
            for e in net.edges
            if e.reusable(net.policy)
        }
        self.guards=set()
        self.epoch=0
        self.promotions=[]
        self.disabled=False
        self.source=net.source
        self.target=net.target

    def _cut(self,side):
        return tuple(sorted(e.id for e in self.edges.values() if e.u in side and e.v not in side))

    def ticket(self,side):
        with self._lock:
            side=frozenset(side)
            if self.source not in side or self.target in side:
                raise ValueError('invalid directed cut side')
            return Ticket(self.epoch,self.policy,side,self._cut(side))

    def set_guard(self,edge_id):
        with self._lock:
            if edge_id not in self.edges: raise KeyError(edge_id)
            self.guards.add(edge_id)

    def install_certificate(self,edge_id,expected_digest,verification_succeeded=False):
        """verification_succeeded is externally asserted; no genuine verifier here."""
        with self._lock:
            if not verification_succeeded or self.digest.get(edge_id)!=expected_digest:
                return False
            self.certificates[edge_id]=(self.policy,expected_digest)
            return True

    def update_source(self,edge_id,new_digest):
        with self._lock:
            if edge_id not in self.edges: raise KeyError(edge_id)
            self.digest[edge_id]=new_digest
            self.epoch+=1

    def update_policy(self,new_policy):
        with self._lock:
            self.policy=new_policy
            self.epoch+=1

    def add_effect_path(self,edge:Edge):
        with self._lock:
            if edge.id in self.edges: raise ValueError('duplicate edge')
            self.edges[edge.id]=edge
            self.digest[edge.id]=edge.digest
            self.epoch+=1

    def revoke(self):
        with self._lock:
            self.disabled=True
            self.epoch+=1

    def reachable_unsafe(self):
        """Path test on DECLARED graph after proven-sealed edges are excluded."""
        sealed={edge_id for edge_id in self.edges
                if edge_id in self.guards or self.certificates.get(edge_id)==(self.policy,self.digest[edge_id])}
        todo=deque([self.source]);seen={self.source}
        while todo:
            u=todo.popleft()
            if u==self.target:return True
            for e in self.edges.values():
                if e.id not in sealed and e.u==u and e.v not in seen:
                    seen.add(e.v);todo.append(e.v)
        return False

    def promote(self,ticket:Ticket,label:str):
        """Atomic in-process state append; never dispatches real protected effect."""
        with self._lock:
            if self.disabled or ticket.policy!=self.policy or ticket.epoch!=self.epoch:
                return False
            if ticket.cut_edges!=self._cut(ticket.side):return False
            for edge_id in ticket.cut_edges:
                if (edge_id not in self.guards and
                    self.certificates.get(edge_id)!=(self.policy,self.digest[edge_id])):
                    return False
            if self.reachable_unsafe():return False
            self.promotions.append((self.epoch,label))
            return True
