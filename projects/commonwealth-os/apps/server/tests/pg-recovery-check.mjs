// Separate database recovery verification; read-only acceptance.
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { PgParticipationStore } from '../src/pg-participation.mjs';
const manifest=JSON.parse(readFileSync(process.argv[2],'utf8'));
const store=await PgParticipationStore.connect();
try{
  const replay=await store.checkpoint(manifest.tenant);
  assert.equal(replay.headHash,manifest.headHash);
  assert.equal(replay.sequence,manifest.sequence);
  assert.equal(replay.seedHash,manifest.seedHash);
  console.log(JSON.stringify({recovered:true,tenant:manifest.tenant,sequence:replay.sequence,matchedHeadHash:true,sourceCustody:'NOT_VERIFIED'}));
}finally{await store.close();}
