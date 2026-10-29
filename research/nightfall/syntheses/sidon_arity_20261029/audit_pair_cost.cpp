// Exact independent two-insertion Sidon deletion census.
// C++17, standard library only. Fixed (91,10,1) perfect difference set.
// Outputs exact core/deletion cross-tab. No floating point or external code.
#include <array>
#include <algorithm>
#include <cassert>
#include <iostream>
#include <map>
#include <set>
#include <utility>
#include <vector>
using namespace std;
constexpr int V=91;
const array<int,10> d={0,1,3,9,27,49,56,61,77,81};
int md(int x){return (x%V+V)%V;}
int main(){
 vector<int> ext;
 for(int a=0;a<V;a++) if(find(d.begin(),d.end(),a)==d.end()) ext.push_back(a);
 map<int,vector<int>> hist;
 map<pair<int,int>,pair<int,int>> witnesses;
 map<int,vector<pair<int,int>>> examples;
 int checked=0, maxcost=0,mincost=100;
 for(int ai=0;ai<(int)ext.size();ai++)for(int bi=ai+1;bi<(int)ext.size();bi++){
   int a=ext[ai],b=ext[bi];
   set<int> collision_supports;
   for(int fresh:{a,b})for(int i=0;i<10;i++)for(int j=i;j<10;j++)for(int k=0;k<10;k++){
     if(md(d[i]+d[j]-d[k])!=fresh) continue;
     int supp=(1<<i)|(1<<j)|(1<<k);
     collision_supports.insert(supp);
   }
   array<int,10> deg{};
   for(int supp:collision_supports)for(int i=0;i<10;i++)if((supp>>i)&1)deg[i]++;
   int c=0;for(int x:deg)if(x>=3)c++;
   int best_retained=-1;
   for(int mask=0;mask<(1<<10);mask++){
     if(__builtin_popcount((unsigned)mask)<=best_retained)continue;
     int used[91]={};
     vector<int> X={a,b};
     for(int i=0;i<10;i++)if(mask>>i&1)X.push_back(d[i]);
     bool ok=true;
     for(int i=0;i<(int)X.size()&&ok;i++)for(int j=i;j<(int)X.size();j++){
       int s=md(X[i]+X[j]);
       if(used[s]){ok=false;break;}
       used[s]=1;
     }
     if(ok)best_retained=__builtin_popcount((unsigned)mask);
   }
   assert(best_retained>=0);
   int cost=10-best_retained;
   hist[c].push_back(cost);
   examples[c].push_back({a,b});
   if(!witnesses.count({c,cost}))witnesses[{c,cost}]={a,b};
   checked++;
   maxcost=max(maxcost,cost); mincost=min(mincost,cost);
 }
 cout<<"checked="<<checked<<" optimal-deletion range="<<mincost<<".."<<maxcost<<"\n";
 for(auto &kv:hist){map<int,int> cc;for(int n:kv.second)cc[n]++;cout<<"core="<<kv.first<<" total="<<kv.second.size()<<" deletion_hist=";for(auto c:cc)cout<<" "<<c.first<<":"<<c.second;cout<<"\n";}
 cout<<"witnesses core,cost -> (a,b)\n";
 for(auto kv:witnesses)cout<<kv.first.first<<","<<kv.first.second<<" -> ("<<kv.second.first<<","<<kv.second.second<<")\n";
}
