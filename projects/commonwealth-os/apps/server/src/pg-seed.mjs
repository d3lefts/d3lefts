// Fresh fictional PostgreSQL tenants. Tokens printed once to local stdout.
import { PgParticipationStore } from './pg-participation.mjs';
const store=await PgParticipationStore.connect();
try{
  for(const tenant of ['student-demo','union-demo','municipal-demo']){
    const actors=[
      {id:'admin',role:'admin'},{id:'chair',role:'chair'},
      {id:'clerk',role:'clerk'},{id:'auditor',role:'auditor'},
      {id:'member-a',role:'member',eligible:true},{id:'member-b',role:'member',eligible:true},
      {id:'member-c',role:'member',eligible:true}
    ];
    const tokens=await store.provision(tenant,actors);
    for(const [id,token] of Object.entries(tokens))console.log(JSON.stringify({institution:tenant,id,token,fictional:true}));
  }
}finally{await store.close();}
console.error('Keep fictional demo credentials local. Do not commit, record, or reuse them for real civic identities.');
