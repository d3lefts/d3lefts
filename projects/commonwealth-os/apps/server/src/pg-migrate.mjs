// Offline SQLite v1.3 -> encrypted PostgreSQL v1.4.
import { existsSync } from 'node:fs';
import { resolve } from 'node:path';
import { PgParticipationStore } from './pg-participation.mjs';
const file=process.argv[2];
if(!file||!existsSync(file)){console.error('Usage: npm run migrate:pg -- /absolute/path/to/cold-commonwealth.sqlite');process.exit(2);}
const store=await PgParticipationStore.connect();
try{
  // Stop all SQLite writers and retain an independently backed-up copy.
  const imported=await store.migrateSqlite(resolve(file));
  for(const item of imported){
    const after=await store.checkpoint(item.tenant);
    if(after.sequence!==item.sequence||after.headHash!==item.headHash)throw Error('POSTGRES_REPLAY_MISMATCH');
  }
  console.log(JSON.stringify({mode:'SYNTHETIC_ONLY',migration:'REPLAY_VERIFIED',imported,realAuthority:false}));
}finally{await store.close();}
