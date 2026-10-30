// Axiom #249 independent exact 2x4 full-field normalization exhaust.
// Standard C++17; one-pass polynomial schoolbook GF16 and 6-word bitset
// collision ledger. Disjoint from audit_two_query.py's xtime/big-int method.
#include <array>
#include <cassert>
#include <cstdint>
#include <iostream>
#include <vector>
using namespace std;

static uint8_t table[16][16], cubed[16];
struct Row {
  array<int,4> a;
  array<uint64_t,6> equal_pairs{};
  int count=0;
};

int main(){
  for(int a=0;a<16;a++)for(int b=0;b<16;b++){
    int p=0;
    for(int i=0;i<4;i++)for(int j=0;j<4;j++)
      if((a&(1<<i))&&(b&(1<<j)))p^=(1<<(i+j));
    for(int j=6;j>=4;j--)if(p&(1<<j))p^=19<<(j-4);
    table[a][b]=p;
  }
  for(int a=0;a<16;a++)cubed[a]=table[table[a][a]][a];
  assert(cubed[1]==1&&cubed[6]==1&&cubed[7]==1);
  vector<array<int,4>> states;
  for(int a:{1,6,7})for(int b:{1,6,7})for(int c:{1,6,7})
    states.push_back({1,a,b,c});
  vector<Row> rows;
  for(int a=0;a<16;a++)for(int b=0;b<16;b++)
  for(int c=0;c<16;c++)for(int d=0;d<16;d++){
    array<int,4> v{a,b,c,d};
    int first=0;
    while(first<4&&v[first]==0)first++;
    if(first==4||v[first]!=1)continue;
    Row row;row.a=v;
    int outputs[27];
    for(int j=0;j<27;j++){
      int z=0;
      for(int k=0;k<4;k++)z^=table[v[k]][states[j][k]];
      outputs[j]=cubed[z];
    }
    int pair=0;
    for(int j=0;j<27;j++)for(int k=j+1;k<27;k++,pair++)
      if(outputs[j]==outputs[k]){
        row.equal_pairs[pair/64] |= uint64_t(1)<<(pair%64);
        row.count++;
      }
    assert(pair==351);
    rows.push_back(row);
  }
  assert(rows.size()==4369);
  int min_single=352,min_joint=352;
  long long count=0;
  array<int,4> best_a{},best_b{};
  for(size_t i=0;i<rows.size();i++){
    if(rows[i].count<min_single)min_single=rows[i].count;
    for(size_t j=i;j<rows.size();j++){
      int shared=0;
      for(int k=0;k<6;k++)
        shared+=__builtin_popcountll(rows[i].equal_pairs[k]&rows[j].equal_pairs[k]);
      count++;
      if(shared<min_joint){
        min_joint=shared;best_a=rows[i].a;best_b=rows[j].a;
      }
    }
  }
  assert(count==9546265);
  assert(min_single==51&&min_joint==4);
  assert((best_a==array<int,4>{0,1,2,3}));
  assert((best_b==array<int,4>{1,2,3,9}));
  cout<<"PASS rows="<<rows.size()<<" unordered_pairs="<<count
      <<" single_min="<<min_single<<" joint_min="<<min_joint
      <<" invalid_pair=[0,1,2,3];[1,2,3,9]\n";
}
