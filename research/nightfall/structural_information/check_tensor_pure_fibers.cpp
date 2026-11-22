// Exact, independent pair-XOR contraction for primitive pure-tensor fibers.
// C++17, levels 1..7. No quantum assumptions, floating point or inferred data.
#include <bits/stdc++.h>
using namespace std;
using U = unsigned __int128;
struct H {
 size_t operator()(U x) const {
  uint64_t a=(uint64_t)x,b=(uint64_t)(x>>64);
  auto mix=[](uint64_t z) { z^=z>>30; z*=0xbf58476d1ce4e5b9ULL;
   z^=z>>27; z*=0x94d049bb133111ebULL; return z^(z>>31);};
  return mix(a)^mix(b+0x9e3779b97f4a7c15ULL);
 }
};
using Count=unordered_map<U,uint32_t,H>;
uint32_t get(const Count& p,U z) {
 auto it=p.find(z); return it==p.end()?0:it->second;
}
U row(unsigned index,int L) {
 vector<int> pos{0};
 for(int j=0;j<L;j++){
  unsigned digit=index%3+1; index/=3; vector<int> next;
  for(int v:pos) {
   if(digit!=2) next.push_back(2*v);
   if(digit!=1) next.push_back(2*v+1);
  }
  pos.swap(next);
 }
 U mask=0;for(int k:pos)mask |= (U(1)<<k);
 return mask;
}
uint64_t choose(int n,int k) {
 uint64_t r=1; for(int j=1;j<=k;j++)r=r*(n-j+1)/j;
 return r;
}
int main(int argc,char**argv) {
 int maxL=argc>1?stoi(argv[1]):7;
 assert(1<=maxL&&maxL<=7);
 for(int L=1;L<=maxL;L++){
  int n=1;for(int i=0;i<L;i++)n*=3;
  vector<U> rows;rows.reserve(n);
  for(int i=0;i<n;i++)rows.push_back(row(i,L));
  unordered_set<U,H> R(rows.begin(),rows.end());
  assert((int)R.size()==n);
  Count p;p.reserve((size_t)n*n/3);
  for(int i=0;i<n;i++)for(int j=i+1;j<n;j++)p[rows[i]^rows[j]]++;
  uint64_t pairtotal=0;for(const auto& it:p)pairtotal+=it.second;
  assert(pairtotal==uint64_t(n)*(n-1)/2);
  uint64_t zero=0;for(U r:rows)zero+=get(p,r);
  assert(zero%3==0);zero/=3;
  assert(zero==uint64_t(L)*n/3);
  // Complete ordered pair-frequency classification.  Row frequencies have
  // p=L, non-row frequencies p=3 (two varying sites) or p=1 (>=3 sites).
  uint64_t nrow=0,nthree=0,none=0;
  for (const auto& kv:p) {
   if(R.count(kv.first)) {++nrow; assert(kv.second==(uint32_t)L);}
   else if(kv.second==3) ++nthree;
   else {assert(kv.second==1); ++none;}
  }
  assert(nrow==(uint64_t)n);
  assert(nthree==2*uint64_t(n/3)*choose(L,2));
  uint64_t expected_one=0;
  for(int h=3;h<=L;h++)
   expected_one+=uint64_t(n)*(uint64_t(1)<<(h-1))*choose(L,h);
  assert(none==expected_one);
  assert(nrow+nthree+none==p.size());
  auto count=[&](U z) {
   uint64_t two=get(p,z), inR=R.count(z)?1:0;
   uint64_t ordered=0;
   for(const auto& it:p)ordered+=uint64_t(it.second)*get(p,it.first^z);
   uint64_t overlap=2*two*(n-2);
   assert(ordered>=overlap&&(ordered-overlap)%6==0);
   uint64_t allfour=(ordered-overlap)/6;
   assert(allfour>=inR*(zero-two));
   uint64_t primitivefour=allfour-inR*(zero-two);
   uint64_t triplenum=0;for(U r:rows)triplenum+=get(p,r^z);
   assert(triplenum>=inR*(n-1)&&(triplenum-inR*(n-1))%3==0);
   return array<uint64_t,5>{inR,two,
      (triplenum-inR*(n-1))/3,allfour,primitivefour};
  };
  auto a=count(rows.front()), b=count(rows[n/2]);
  assert(a==b);
  assert(a[0]==1&&a[1]==uint64_t(L));
  assert(a[2]==4*choose(L,2));
  assert(a[4]==5*choose(L,2)+30*choose(L,3));
  cout<<"L="<<L<<" rows="<<n<<" fibers="<<p.size()
      <<" zero-triples="<<zero<<" p3freq="<<nthree<<" p1freq="<<none<<" primitive 1,2,3,4="
      <<a[0]<<","<<a[1]<<","<<a[2]<<","<<a[4]
      <<" TOTAL="<<(a[0]+a[1]+a[2]+a[4])<<" PASS\n"<<flush;
 }
}
