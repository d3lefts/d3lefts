#include <bits/stdc++.h>
using namespace std;
struct G {vector<array<int,3>> adj;};
bool cycle(const G& g, int L) {int N=g.adj.size();vector<char>seen(N);function<bool(int,int,int)>dfs=[&](int s,int v,int depth)->bool {
 if(depth==L) {for(int u:g.adj[v]) if(u==s)return true;return false;}
 for(int u:g.adj[v]) {if(u<=s||seen[u])continue;seen[u]=true;if(dfs(s,u,depth+1))return true;seen[u]=false;}return false;};
 for(int s=0;s<N;s++){seen[s]=1;for(int v:g.adj[s])if(v>s){seen[v]=1;if(dfs(s,v,2))return true;seen[v]=0;}seen[s]=0;}return false;}
G haar(int m, int a){G g;g.adj.resize(2*m, array<int,3>{-1,-1,-1});int S[]={0,1,a};for(int i=0;i<m;i++)for(int s:S){int v=m+(i+s)%m;auto put=[&](int u,int v){auto&x=g.adj[u];for(int j=0;j<3;j++)if(x[j]==-1){x[j]=v;return;}throw runtime_error("overflow");};put(i,v);put(v,i);}return g;}
int main(int argc,char**argv){int maxm=argc>1?atoi(argv[1]):80;int tot=0,passed4=0,passed8=0,passed16=0;vector<pair<int,int>>examples;
 for(int m=7;m<=maxm;m++){for(int a=2;a<m-1;a++) {if(a>m-a+1)continue;tot++;auto g=haar(m,a);if(cycle(g,4))continue;passed4++;if(cycle(g,8))continue;passed8++;if(cycle(g,16))continue;passed16++;examples.push_back({m,a});}}
 cout<<"max_m "<<maxm<<" searched "<<tot<<" noC4 "<<passed4<<" noC4C8 "<<passed8<<" noC4C8C16 "<<passed16<<"\n";
 for(auto [m,a]:examples)cout<<"SURVIVOR "<<m<<" "<<a<<" vertices "<<2*m<<"\n";
}
