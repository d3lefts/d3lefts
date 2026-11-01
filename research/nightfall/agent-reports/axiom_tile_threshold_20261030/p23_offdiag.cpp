// Exhaustive independent C++ checker for the 8x4 + three shifts family.
// Counts ordered pair representations. If every m has >=2, the
// off-diagonal pair-sum set is all GF(23)^2: odd-order diagonal sums
// have at most one ordered diagonal representation.
#include <array>
#include <cstdint>
#include <iostream>
#include <vector>
#include <climits>
using namespace std;
constexpr int P=23,Q=P*P;
using Bits=array<uint64_t,9>;
int add(int a,int b){return ((a%P+b%P)%P)+P*((a/P+b/P)%P);}
int sub(int a,int b){return ((a%P-b%P+P)%P)+P*((a/P-b/P+P)%P);}
void put(Bits &b,int i){b[i>>6]|=1ull<<(i&63);}
int count(Bits const&b){int n=0;for(auto w:b)n+=__builtin_popcountll(w);return n;}
Bits join(Bits a,Bits const&b){for(int j=0;j<9;j++)a[j]|=b[j];return a;}
int main(){
 Bits tile[Q]{};
 int baseCount[Q]{};
 for(int x=0;x<8;x++)for(int y=0;y<4;y++){
  int z=x+P*y;
  for(int sh=0;sh<Q;sh++)put(tile[sh],add(sh,z));
  for(int xx=0;xx<8;xx++)for(int yy=0;yy<4;yy++)
   baseCount[add(z,xx+P*yy)]++;
 }
 vector<int> corners;
 for(int z=0;z<Q;z++)if(baseCount[z]==1)corners.push_back(z);
 if(corners.size()!=4)return 2;
 long long four=0,eight=0,unique=0;
 int minCount=INT_MAX;
 const int binom[]={1,2,1};
 for(int v=1;v<Q;v++)for(int w=v+1;w<Q;w++){
  int vw=add(v,w);
  Bits u=join(join(join(tile[0],tile[v]),tile[w]),tile[vw]);
  if(count(u)!=128)continue;
  four++;
  for(int t=1;t<Q;t++){
   Bits full=join(join(join(join(u,tile[t]),tile[add(v,t)]),tile[add(w,t)]),tile[add(vw,t)]);
   if(count(full)!=256)continue;
   eight++;
   int shifts[27],weights[27],n=0;
   for(int a=0;a<=2;a++)for(int b=0;b<=2;b++)for(int c=0;c<=2;c++){
    int z=0;
    for(int i=0;i<a;i++)z=add(z,v);
    for(int i=0;i<b;i++)z=add(z,w);
    for(int i=0;i<c;i++)z=add(z,t);
    shifts[n]=z;weights[n]=binom[a]*binom[b]*binom[c];n++;
   }
   int extreme[8];
   for(int a=0;a<2;a++)for(int b=0;b<2;b++)for(int c=0;c<2;c++){
    int z=0;
    for(int i=0;i<2*a;i++)z=add(z,v);
    for(int i=0;i<2*b;i++)z=add(z,w);
    for(int i=0;i<2*c;i++)z=add(z,t);
    extreme[(a<<2)|(b<<1)|c]=z;
   }
   // An ordered sum with multiplicity exactly 1 must be at one of
   // the four base corners and one of the eight extreme shifts.
   for(int z:extreme)for(int corner:corners){
    int m=add(z,corner),nrep=0;
    for(int j=0;j<27;j++){
     nrep+=weights[j]*baseCount[sub(m,shifts[j])];
     if(nrep>=2)break;
    }
    if(nrep<minCount)minCount=nrep;
    if(nrep==1){cout<<"FAIL unique sum "<<v<<" "<<w<<" "<<t<<" "<<m<<"\n";return 1;}
   }
  }
 }
 cout<<"PASS four="<<four<<" eight="<<eight<<" unique="<<unique<<" minCandidateCount="<<minCount<<"\n";
 if(four!=53640||eight!=2153616||unique||minCount!=2)return 3;
 cout<<"SCOPE: only 8x4 axis base + three arbitrary shifts; not global p23 impossibility\n";
}
