// Exhaust all 2^23 vertex subsets in the directed odd cycle C23.
// For every occupancy k, the minimum number of adjacent occupied pairs
// must be max(0, 2*k-23). This independently checks the counting lemma.
#include <algorithm>
#include <array>
#include <cassert>
#include <cstdint>
#include <iostream>
int main(){
  constexpr int p=23, M=(1<<p)-1;
  std::array<int,p+1> min_edges;
  min_edges.fill(p+1);
  for(uint32_t a=0;a<(1u<<p);++a){
    auto shifted=((a<<1)|(a>>(p-1)))&M;
    int k=__builtin_popcount(a);
    int e=__builtin_popcount(a&shifted);
    min_edges[k]=std::min(min_edges[k],e);
    if(e<std::max(0,k-(p-1)/2)) return 1;
  }
  for(int k=0;k<=p;k++){
    if(min_edges[k]!=std::max(0,2*k-p)) return 2;
  }
  assert(256-23*11==3);
  std::cout<<"PASS 2^23 cycle masks; minimum p23 eight-code overlap = 3\n";
}
