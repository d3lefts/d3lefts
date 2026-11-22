// Independent complete nonzero XOR-frequency primitive histogram at levels L=1..4.
// No manuscript imports. Uses all XOR pair fibers and exact double convolution
// to count primitive unordered row sets of sizes 1..4; no four-set enumeration.
#include <bits/stdc++.h>
using namespace std;
using U=uint64_t;
U tensor_row(unsigned idx,int L) {
  vector<int> p{0};
  for(int k=0;k<L;k++){
    unsigned f=idx%3+1; idx/=3;vector<int> q;
    for(int j:p){if(f!=2)q.push_back(2*j);if(f!=1)q.push_back(2*j+1);}
    p.swap(q);
  }
  U m=0;for(int j:p)m|=U(1)<<j;return m;
}
int main() {
  const int expected[4][5]={
    {1,1,0,0,2}, {1,3,7,6,16}, {1,3,13,72,84},
    {1,4,24,150,179}};
  for(int L=1;L<=4;L++){
    int n=1;for(int i=0;i<L;i++)n*=3;
    int ambient=1<<(1<<L);
    vector<U> rows;vector<int> inR(ambient,0);
    for(int i=0;i<n;i++){rows.push_back(tensor_row(i,L));inR[rows.back()]=1;}
    vector<int> p(ambient,0);
    for(int i=0;i<n;i++)for(int j=i+1;j<n;j++)p[rows[i]^rows[j]]++;
    vector<int> frequencies;
    for(int v=1;v<ambient;v++)if(p[v])frequencies.push_back(v);
    vector<int64_t> convolution(ambient,0),triple_sum(ambient,0);
    for(int v:frequencies)for(int w:frequencies)
      convolution[v^w]+=int64_t(p[v])*p[w];
    for(int v:frequencies)for(int r:rows)triple_sum[v^r]+=p[v];
    int64_t zero_triples=0;
    for(int r:rows)zero_triples+=p[r];
    assert(zero_triples%3==0);zero_triples/=3;
    int64_t maxima[5]={},argmax[5]={};
    for(int z=1;z<ambient;z++){
      int64_t A1=inR[z],A2=p[z];
      int64_t numerator3=triple_sum[z]-(n-1)*inR[z];
      int64_t numerator4=convolution[z]-2*(n-2)*p[z];
      assert(numerator3%3==0&&numerator4%6==0);
      int64_t A3=numerator3/3;
      int64_t A4=numerator4/6-inR[z]*(zero_triples-p[z]);
      assert(A3>=0&&A4>=0);
      int64_t counts[]={A1,A2,A3,A4,A1+A2+A3+A4};
      for(int k=0;k<5;k++) if(counts[k]>maxima[k]) {
        maxima[k]=counts[k];argmax[k]=z;
      }
    }
    for(int k=0;k<5;k++)assert(maxima[k]==expected[L-1][k]);
    cout<<"L="<<L<<" distinct pair frequencies="<<frequencies.size()
      <<" maxima k1,k2,k3,k4,total=";
    for(int k=0;k<5;k++)cout<<maxima[k]<<"@z"<<argmax[k]<<" ";
    cout<<"PASS"<<endl;
  }
  // At L2 and L3 the maximum is at a NON-pure frequency, a negative
  // control against extrapolating pure-row counts to every frequency.
  cout<<"PASS exact all-frequency primitive histogram L<=4"<<endl;
}
