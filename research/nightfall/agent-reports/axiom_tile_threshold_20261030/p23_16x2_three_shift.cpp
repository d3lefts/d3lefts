// Exact finite no-go for the GF(23)^2 16x2 base plus 3 arbitrary shifts.
// Every valid 8-generator cube has a full ordinary sumset; moreover
// base B+B has NO sum with multiplicity one, so every group element
// in T+T has an off-diagonal representation. No general p=23 no-go.
#include <array>
#include <cstdint>
#include <iostream>
using namespace std;
constexpr int P=23,Q=P*P;
using Bits=array<uint64_t,9>;
int add(int a,int b){return ((a%P+b%P)%P)+P*((a/P+b/P)%P);}
void put(Bits &b,int i){b[i>>6]|=1ull<<(i&63);}
int count(Bits const&b){int n=0;for(auto w:b)n+=__builtin_popcountll(w);return n;}
Bits join(Bits a,Bits const&b){for(int j=0;j<9;j++)a[j]|=b[j];return a;}
int main(){
 Bits tile[Q]{},rect[Q]{};
 int baseCount[Q]{};
 for(int x=0;x<16;x++)for(int y=0;y<2;y++){
  int z=x+P*y;
  for(int sh=0;sh<Q;sh++)put(tile[sh],add(sh,z));
  for(int xx=0;xx<16;xx++)for(int yy=0;yy<2;yy++)
   baseCount[add(z,xx+P*yy)]++;
 }
 for(int z=0;z<Q;z++)if(baseCount[z]==1){
  cerr<<"Unexpected unique base pair sum\n";return 1;
 }
 for(int x=0;x<31;x++)for(int y=0;y<3;y++)
  for(int sh=0;sh<Q;sh++)put(rect[sh],add(sh,x+P*y));
 long long four=0,eight=0;
 for(int v=1;v<Q;v++)for(int w=v+1;w<Q;w++){
  int vw=add(v,w);
  Bits u=join(join(join(tile[0],tile[v]),tile[w]),tile[vw]);
  if(count(u)!=128)continue;
  four++;
  for(int t=1;t<Q;t++){
   Bits full=join(join(join(join(u,tile[t]),tile[add(v,t)]),tile[add(w,t)]),tile[add(vw,t)]);
   if(count(full)!=256)continue;
   eight++;
   int shifts[27],n=0;
   for(int a=0;a<=2;a++)for(int b=0;b<=2;b++)for(int c=0;c<=2;c++){
    int z=0;
    for(int i=0;i<a;i++)z=add(z,v);
    for(int i=0;i<b;i++)z=add(z,w);
    for(int i=0;i<c;i++)z=add(z,t);
    shifts[n++]=z;
   }
   Bits coverage{};
   for(int j=0;j<27;j++)coverage=join(coverage,rect[shifts[j]]);
   if(count(coverage)!=Q){
    cout<<"FAIL v="<<v<<" w="<<w<<" t="<<t<<" covered="<<count(coverage)<<"\n";
    return 2;
   }
  }
 }
 cout<<"PASS four="<<four<<" eight="<<eight<<" full sumsets; no off-diagonal loophole\n";
 return four==76176&&eight==5840160?0:3;
}
