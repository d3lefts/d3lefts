// Exact fixed two-site rank-two tensor-target primitive XOR counts, L=2..7.
// Uses O(3^(2L)) pair construction and O(pair-frequencies) contraction
// per target. No enumeration of row quadruples at large tensor depths.
#include <bits/stdc++.h>
using namespace std;
using U=unsigned __int128;
struct H {
 size_t operator()(U v) const {
  uint64_t a=v,b=v>>64;
  auto mix=[](uint64_t x){
   x^=x>>30;x*=0xbf58476d1ce4e5ULL;
   x^=x>>27;x*=0x94d049bb133111ebULL;
   return x^(x>>31);
  };
  return mix(a)^mix(b+0x9e3779b97f4a7c15ULL);
 }
};
U tensor_row(unsigned idx,int L) {
 vector<int> pos{0};
 for(int k=0;k<L;k++) {
  unsigned f=idx%3+1;idx/=3;
  vector<int> next;
  for(int v:pos){
   if(f!=2)next.push_back(2*v);
   if(f!=1)next.push_back(2*v+1);
  }
  pos.swap(next);
 }
 U ans=0;for(int v:pos)ans|=U(1)<<v;
 return ans;
}
int main(){
 for(int L=2;L<=7;L++){
  int n=1;for(int i=0;i<L;i++)n*=3;
  vector<U> rows;rows.reserve(n);
  for(int i=0;i<n;i++)rows.push_back(tensor_row(i,L));
  unordered_map<U,uint32_t,H> p;p.reserve((size_t)n*n/2);
  for(int i=0;i<n;i++)for(int j=i+1;j<n;j++)p[rows[i]^rows[j]]++;
  auto get=[&](U z)->uint64_t {
   auto it=p.find(z);return it==p.end()?0:it->second;
  };
  // z=(e0 tensor e0 + e1 tensor e1) tensor e0^(L-2).
  U z=tensor_row(0,L)^tensor_row(4,L);
  assert(find(rows.begin(),rows.end(),z)==rows.end());
  uint64_t A2=get(z),sum3=0,conv=0;
  for(U r:rows)sum3+=get(z^r);
  for(const auto& [v,c]:p)conv+=uint64_t(c)*get(v^z);
  assert(sum3%3==0);
  assert(conv>=uint64_t(2)*(n-2)*A2);
  assert((conv-uint64_t(2)*(n-2)*A2)%6==0);
  uint64_t A3=sum3/3;
  uint64_t A4=(conv-uint64_t(2)*(n-2)*A2)/6;
  uint64_t expected3=uint64_t(6)*L-5;
  uint64_t expected4=uint64_t(15)*L*L-uint64_t(21)*L-12;
  assert(A2==3 && A3==expected3 && A4==expected4);
  cout<<"L="<<L<<" fixed rank-two primitive sizes 2,3,4="
      <<A2<<","<<A3<<","<<A4<<" TOTAL="<<A2+A3+A4
      <<" PASS"<<endl;
 }
 cout<<"PASS fixed-rank-two tensor-core polynomial exact through L=7"<<endl;
}
