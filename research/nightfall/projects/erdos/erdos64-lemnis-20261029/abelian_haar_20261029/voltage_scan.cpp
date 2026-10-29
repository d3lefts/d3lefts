#include <bits/stdc++.h>
using namespace std;
using vi=vector<int>;
struct G{vector<array<int,3>> a;};
bool hascycle(G const&g,int L){int n=g.a.size();vector<char> vis(n);function<bool(int,int,int)>dfs=[&](int start,int v,int depth)->bool{if(depth==L){for(int u:g.a[v])if(u==start)return true;return false;}for(int u:g.a[v]){if(u<=start||vis[u])continue;vis[u]=1;if(dfs(start,u,depth+1))return true;vis[u]=0;}return false;};for(int st=0;st<n;st++){vis[st]=1;for(int v:g.a[st])if(v>st){vis[v]=1;if(dfs(st,v,2))return true;vis[v]=0;}vis[st]=0;}return false;}
G make(int q,int fam,mt19937_64& rng, bool cyclic){vector<pair<int,int>> E;int b=0;
if(fam==0){b=4;E={{0,1},{0,2},{0,3},{1,2},{1,3},{2,3}};}
else{b=6; E={{0,3},{0,4},{0,5},{1,3},{1,4},{1,5},{2,3},{2,4},{2,5}};}
G g;g.a.resize(b*q,array<int,3>{-1,-1,-1});vi ident(q);iota(ident.begin(),ident.end(),0);
// spanning tree: K4 edges indices 0,1,2; K3,3 0,1,2,3,6
set<int>tree=fam==0?set<int>{0,1,2}:set<int>{0,1,2,3,6};
for(int e=0;e<(int)E.size();e++){vi p=ident;if(!tree.count(e)){if(cyclic){int a=rng()%q;for(int i=0;i<q;i++)p[i]=(i+a)%q;}else shuffle(p.begin(),p.end(),rng);}auto [a,bv]=E[e];for(int i=0;i<q;i++) {int u=a*q+i,v=bv*q+p[i];auto put=[&](int a,int b){for(auto&x:g.a[a])if(x==-1){x=b;return;}throw runtime_error("bad degree");};put(u,v);put(v,u);}}
for(auto a:g.a)for(int x:a)assert(x>=0);return g;}
int main(int argc,char**argv){int draws=argc>1?atoi(argv[1]):100;bool cyclic=argc>3?atoi(argv[3]):0;uint64_t seed=argc>2?stoull(argv[2]):0x476491ull;mt19937_64 rng(seed);cout<<"seed="<<seed<<" draws="<<draws<<" cyclic="<<cyclic<<"\n";for(int fam=0;fam<2;fam++)for(int q: {13,17,19,23,29,37,47,67}) {int no4=0,no8=0,no16=0;for(int k=0;k<draws;k++){auto g=make(q,fam,rng,cyclic);if(hascycle(g,4))continue;no4++;if(hascycle(g,8))continue;no8++;if(hascycle(g,16))continue;no16++;}
 cout<<(fam==0?"K4":"K33")<<" fibers="<<q<<" vertices="<<(fam==0?4:6)*q<<" draws="<<draws<<" no4="<<no4<<" no4no8="<<no8<<" no4no8no16="<<no16<<"\n";}}
