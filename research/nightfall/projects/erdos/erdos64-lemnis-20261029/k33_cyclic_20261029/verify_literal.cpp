// Independent literal 6m-vertex graph verifier; checks one root per deck orbit.
#include <array>
#include <cassert>
#include <iostream>
#include <vector>
using namespace std;
struct Graph {
  int m; vector<array<int,3>> adj;
  explicit Graph(int mod):m(mod),adj(6*mod) {
    for(auto &a:adj)a.fill(-1);
    auto add=[&](int u,int v,int w) {
      for(int x=0;x<m;x++){
        int a=u*m+x,b=v*m+(x+w)%m;
        auto slot=[&](int y,int z){for(int &k:adj[y])if(k<0){k=z;return;}assert(false);};
        slot(a,b);slot(b,a);
      }
    };
    for(int u=0;u<3;u++)for(int v=3;v<6;v++){
      int w=0;
      if(u==1&&v==4)w=1;
      if(u==1&&v==5)w=5;
      if(u==2&&v==4)w=25;
      if(u==2&&v==5)w=125;
      add(u,v,w);
    }
    for(auto &a:adj)for(int x:a)assert(x>=0);
  }
};
int main(int argc,char**argv){
  int m=argc>1?stoi(argv[1]):501;assert(m>500);
  Graph G(m);array<long,17> cycles{};
  vector<unsigned char> used(G.adj.size());
  for(int base=0;base<6;base++){
    int root=base*m;used[root]=1;
    auto dfs=[&](auto&& self,int u,int parent,int depth)->void{
      if(depth==16)return;
      for(int v:G.adj[u]){
        if(v==root){
          if(depth+1>=4&&v!=parent)cycles[depth+1]++;
        } else if(v!=parent&&!used[v]){
          used[v]=1;self(self,v,u,depth+1);used[v]=0;
        }
      }
    };
    dfs(dfs,root,-1,0);used[root]=0;
  }
  for(int n:{4,6,8,10,16})assert(cycles[n]==0);
  assert(cycles[12]>0);
  cout<<"PASS: m="<<m<<", 6m vertices, no C4,C6,C8,C10,C16; C12 per-orbit directed roots="<<cycles[12]<<"\n";
}
