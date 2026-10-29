#include <algorithm>
#include <array>
#include <bit>
#include <cassert>
#include <cstdint>
#include <iostream>
#include <fstream>
#include <map>
#include <set>
#include <string>
#include <vector>
using namespace std;
struct Constraint { uint32_t mask; uint32_t bad4_8; uint32_t bad16; int len; };
vector<vector<int>> parse(const string &s) {
 int n=s.at(0)-63; assert(n==24 || n==26);
 vector<vector<int>> a(n); int bit=0;
 for(int j=1;j<n;j++)for(int i=0;i<j;i++) {
  int c=s.at(1+bit/6)-63;
  if(c & (1 << (5-(bit%6)))){a[i].push_back(j);a[j].push_back(i);}
  bit++;
 }
 for(auto &x:a) assert(x.size()==3);
 return a;
}
void dfs(int start,int u,uint32_t used,int len,const vector<vector<int>>&adj,map<int,set<uint32_t>>&cycs) {
 if(len>=3 && len<=16) for(int v:adj[u]) if(v==start) {cycs[len].insert(used);break;}
 if(len==16)return;
 for(int v:adj[u]) if(v>start && !(used & (1u<<v))) dfs(start,v,used|(1u<<v),len+1,adj,cycs);
}
int PATH_LO=1, PATH_HI=2;
uint32_t forbidden(int L,int target) {
 uint32_t mask=0;
 for(int m=0;m<=L;m++) if(L+PATH_LO*m<=target && target<=L+PATH_HI*m) mask |= (1u<<m);
 return mask;
}
int main(int argc,char**argv){
 if(argc==2 && string(argv[1])=="--gadget7"){PATH_LO=2;PATH_HI=6;}
 else if(argc!=1){cerr<<"usage: expand_search [--gadget7]\n";return 2;}
 vector<string> g6; string line; ifstream f("markstrom_24_and_26.g6"); while(getline(f,line))if(!line.empty())g6.push_back(line); assert(g6.size()==27);
 for(int idx=0;idx<(int)g6.size();idx++){
  auto adj=parse(g6[idx]); map<int,set<uint32_t>> cycs;
  int n=(int)adj.size(); for(int v=0;v<n;v++)dfs(v,v,1u<<v,1,adj,cycs);
  vector<Constraint> small, longc;
  for(auto &[L,sets]:cycs)for(uint32_t mask:sets){
   uint32_t b48=forbidden(L,4)|forbidden(L,8), b16=forbidden(L,16);
   if(b48)small.push_back({mask,b48,0,L});
   if(b16)longc.push_back({mask,0,b16,L});
  }
  // Triangle internal cycles length 3; gadget FhcYG internal cycles exclude C4.
  // For --gadget7 all terminal-pair path lengths are exactly {2,3,4,5,6}.
  uint64_t survivors48=0, survivorsAll=0;uint32_t bestMask=0;int bestSize=100;
  for(uint32_t S=0;S<(1u<<n);S++){
   bool good=true;
   for(auto &c:small) if(c.bad4_8 & (1u<<popcount(S & c.mask))) {good=false;break;}
   if(!good)continue;
   survivors48++;
   for(auto &c:longc) if(c.bad16 & (1u<<popcount(S & c.mask))) {good=false;break;}
   if(good){survivorsAll++; if(popcount(S)<bestSize){bestMask=S;bestSize=popcount(S);}}
  }
  cout << "base=" << idx+1 << " n=" << n << " small_masks=" << small.size() << " long_masks=" << longc.size() << " survivor_C4_C8=" << survivors48 << " survivor_C4_C8_C16=" << survivorsAll << " best_S=" << bestMask << " best_size=" << bestSize << "\n";
  cout.flush();
 }
}
