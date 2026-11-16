// Generates a signed LOCAL checkpoint. External anchoring requires
// transferring it to a separately controlled custodian and pinning its key.
import { join, dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { PgParticipationStore } from './pg-participation.mjs';
import { signingKey, exportEvidence } from './evidence.mjs';
const store=await PgParticipationStore.connect();
try{
  const tenant=process.argv[2]||'student-demo';
  const checkpoint=await store.checkpoint(tenant);
  const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
  const key=signingKey(process.env.COMMONWEALTH_PG_CHECKPOINT_KEY??join(root,'data','pg-checkpoint-key.pem'));
  const signed=exportEvidence(checkpoint,key);
  signed.signerTrust='UNVERIFIED_UNLESS_PUBLIC_KEY_PINNED_OUTSIDE_DATABASE_OPERATOR';
  process.stdout.write(JSON.stringify(signed,null,2)+'\n');
}finally{await store.close();}
