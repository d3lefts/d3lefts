// Exact codimension-two affine quotient histogram comparison:
// F27 glued x^2 vs x^4. No external inputs or libraries.
#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <algorithm>
#include <vector>
#include <array>
#include <set>
using namespace std;
constexpr int Q=27,N=19683,K=53;
static uint8_t dots[2][N][K];
static long long hist[2][54],total=0;
static int pw[9];
array<int,3> digs(int a){return {a%3,(a/3)%3,a/9};}
int enc(array<int,3>a){return ((a[0]%3+3)%3)+3*((a[1]%3+3)%3)+9*((a[2]%3+3)%3);}
int mul(int x,int y){
 auto a=digs(x),b=digs(y);int c[5]={};
 for(int i=0;i<3;i++)for(int j=0;j<3;j++)c[i+j]+=a[i]*b[j];
 // T^3=T-1 and T^4=T^2-T.
 c[2]+=c[4];c[1]-=c[4];c[1]+=c[3];c[0]-=c[3];
 return enc({c[0],c[1],c[2]});
}
int power(int x,int n){int a=1;while(n){if(n&1)a=mul(a,x);x=mul(x,x);n>>=1;}return a;}
void build(int e,int out[K][9]){
 set<array<int,9>> points;
 for(int t=0;t<Q;t++){
  auto a=digs(t),b=digs(power(t,e));
  points.insert({a[0],a[1],a[2],b[0],b[1],b[2],0,0,0});
  auto c=digs(mul(2,power(t,e)));
  points.insert({0,0,0,c[0],c[1],c[2],a[0],a[1],a[2]});
 }
 if(points.size()!=K){fprintf(stderr,"bad source size\n");exit(2);}
 int i=0;for(auto v:points){for(int j=0;j<9;j++)out[i][j]=v[j];i++;}
}
void enumerate(int pos,const vector<int>&f1,const vector<int>&f2,int r1,int r2){
 if(pos<(int)f1.size()){
  for(int v=0;v<3;v++)enumerate(pos+1,f1,f2,r1+v*pw[f1[pos]],r2);
  return;
 }
 int j=pos-(int)f1.size();
 if(j<(int)f2.size()){
  for(int v=0;v<3;v++)enumerate(pos+1,f1,f2,r1,r2+v*pw[f2[j]]);
  return;
 }
 for(int e=0;e<2;e++){
  uint8_t cnt[9]={};auto*a=dots[e][r1],*b=dots[e][r2];
  for(int i=0;i<K;i++)cnt[a[i]+3*b[i]]++;
  int mx=0;for(auto c:cnt)mx=max(mx,(int)c);
  hist[e][mx]++;
 }
 total++;
}
int main(){
 int A[2][K][9];build(2,A[0]);build(4,A[1]);
 pw[0]=1;for(int i=1;i<9;i++)pw[i]=3*pw[i-1];
 for(int r=0;r<N;r++){
  int c[9],v=r;for(int j=0;j<9;j++){c[j]=v%3;v/=3;}
  for(int e=0;e<2;e++)for(int i=0;i<K;i++){
   int s=0;for(int j=0;j<9;j++)s+=c[j]*A[e][i][j];
   dots[e][r][i]=s%3;
  }
 }
 for(int i=0;i<9;i++)for(int j=i+1;j<9;j++){
  vector<int>f1,f2;
  for(int h=i+1;h<9;h++)if(h!=j)f1.push_back(h);
  for(int h=j+1;h<9;h++)f2.push_back(h);
  enumerate(0,f1,f2,pw[i],pw[j]);
 }
 if(total!=8069620){fprintf(stderr,"bad subspace count\n");return 3;}
 for(int k=0;k<54;k++)if(hist[0][k]!=hist[1][k]){
  fprintf(stderr,"distinct histograms at %d\n",k);return 4;
 }
 printf("PASS: %lld codimension-two quotients; identical histograms\n",total);
 for(int k=0;k<54;k++)if(hist[0][k])printf("max=%d count=%lld\n",k,hist[0][k]);
 return 0;
}
