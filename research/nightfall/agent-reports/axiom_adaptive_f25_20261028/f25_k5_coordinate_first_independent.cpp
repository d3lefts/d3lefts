// Independent exhaustive obstruction verifier for coordinate-first F25 k=5 depth-three phase recovery.
// No Python/numpy library, no NIGHTFALL imports.  Build: g++ -O3 -std=c++17 -o /tmp/f25audit this.cpp && /tmp/f25audit
#include <array>
#include <vector>
#include <map>
#include <set>
#include <algorithm>
#include <iostream>
#include <cassert>
#include <cstdint>
using namespace std;
using V=array<uint8_t,5>;
static int add(int a,int b) {return ((a%5+b%5)%5)+5*((a/5+b/5)%5);}
static int mul(int a,int b) {return ((a%5)*(b%5)+2*(a/5)*(b/5))%5+5*(((a%5)*(b/5)+(a/5)*(b%5))%5);}
static array<int,25> sym;
static vector<V> pts,rows;
static array<array<int,256>,256> dirs;
static int inv[5]={0,1,3,2,4};
static int read(const V& r,const V& x) {int z=0;for(int i=0;i<5;i++)z=add(z,mul(r[i],x[i]));return sym[z];}
static int dir(const V& p,const V& q){int a[4];for(int i=0;i<4;i++)a[i]=(int(q[i+1])-int(p[i+1])+5)%5;int lead=0;for(int i=0;i<4;i++)if(a[i]){lead=a[i];break;}assert(lead);int out=0,v=1;for(int i=0;i<4;i++){out+=((a[i]*inv[lead])%5)*v;v*=5;}return out;}
static bool blocked7(const vector<int>& S) {
 assert(S.size()==7);
 for(int i:S){set<int> ds;for(int j:S)if(i!=j)ds.insert(dirs[i][j]);if(ds.size()==6)return false;}
 return true;
}
static vector<V> buildRows() {
 vector<V> out;out.reserve(406901);
 for(int at=0;at<5;at++){
  int count=1;for(int j=at+1;j<5;j++)count*=25;
  for(int z=0;z<count;z++){
   V a={0,0,0,0,0};a[at]=1;int t=z;
   for(int j=4;j>at;j--){a[j]=t%25;t/=25;}
   out.push_back(a);
  }
 }
 assert(out.size()==406901);return out;
}
struct Check{int n=0,good=0,collinear=0,unexcluded=0,minmax=99;};
static Check examine(V first,int outcome){
 vector<int> S;for(int j=0;j<256;j++)if(read(first,pts[j])==outcome)S.push_back(j);
 Check out;out.n=(int)S.size();
 int count[7];vector<int> group[7];
 for(auto& r:rows){
  fill(count,count+7,0);for(auto& v:group)v.clear();
  for(int k:S){int z=read(r,pts[k]);count[z]++;group[z].push_back(k);}
  int mx=*max_element(count,count+7);out.minmax=min(out.minmax,mx);
  if(mx>7)continue;
  out.good++;
  bool blocked=false;
  for(int y=0;y<7;y++)if(count[y]==7&&blocked7(group[y])){blocked=true;break;}
  if(blocked)out.collinear++;else out.unexcluded++;
 }
 return out;
}
int main(){
 // F25=F5[u]/(u^2-2), output labels determined by 7 distinct fourth powers.
 map<int,int> lut;for(int a=0;a<25;a++){int aa=mul(a,a),z=mul(aa,aa);lut[z]=0;}
 int id=0;for(auto& q:lut)q.second=id++;
 assert(lut.size()==7);
 for(int a=0;a<25;a++){int aa=mul(a,a);sym[a]=lut.at(mul(aa,aa));}
 for(int a=1;a<=4;a++)for(int b=1;b<=4;b++)for(int c=1;c<=4;c++)for(int d=1;d<=4;d++)pts.push_back({1,(uint8_t)a,(uint8_t)b,(uint8_t)c,(uint8_t)d});
 assert(pts.size()==256);rows=buildRows();
 for(int i=0;i<256;i++)for(int j=0;j<256;j++)if(i!=j)dirs[i][j]=dir(pts[i],pts[j]);
 // Represent projective coefficient directions (x,y) in F5^2, with infinity=5 and zero=6.
 // Generate the full PGL2(5) action and count coefficient-multiset orbits (5 positions).
 set<array<int,6>> perms;
 auto slope=[](int x,int y){if(!x)return 5;int invx=1;while((invx*x)%5!=1)invx++;return (y*invx)%5;};
 for(int a=0;a<5;a++)for(int b=0;b<5;b++)for(int c=0;c<5;c++)for(int d=0;d<5;d++){
  if((a*d-b*c+25)%5==0)continue;
  array<int,6> p;
  for(int j=0;j<6;j++){int x=j==5?0:1,y=j==5?1:j;
   p[j]=slope((a*x+b*y)%5,(c*x+d*y)%5);}
  perms.insert(p);
 }
 assert(perms.size()==120);
 set<array<int,5>> multisets;
 for(int a=0;a<7;a++)for(int b=a;b<7;b++)for(int c=b;c<7;c++)for(int d=c;d<7;d++)for(int e=d;e<7;e++)multisets.insert({a,b,c,d,e});
 assert(multisets.size()==462);
 vector<pair<array<int,5>,int>> reps;
 while(!multisets.empty()){
  auto q=*multisets.begin();set<array<int,5>> orb;
  for(auto p:perms){auto v=q;for(auto& x:v)if(x!=6)x=p[x];sort(v.begin(),v.end());orb.insert(v);}
  for(auto x:orb)multisets.erase(x);
  reps.push_back({q,int(orb.size())});
 }
 assert(reps.size()==19);
 int hard=0,blocked=0;bool all=true;
 for(auto [q,size]:reps){
  V a;for(int i=0;i<5;i++){a[i]=q[i]==6?0:(q[i]==5?5:1+5*q[i]);}
  int hist[7]={};for(auto x:pts)hist[read(a,x)]++;
  int mx=*max_element(hist,hist+7);
  if(mx>49){cout<<"COUNT ";for(auto z:q)cout<<z;cout<<" max="<<mx<<"\n";blocked++;continue;}
  int which=int(max_element(hist,hist+7)-hist);
  // The (0,0,1,2,3) orbit has a decisive 41-point branch at outcome 2.
  if(q==array<int,5>{0,0,1,2,3})which=2;
  Check chk=examine(a,which);
  cout<<"EXACT ";for(auto z:q)cout<<z;
  cout<<" size="<<size<<" first_bucket="<<which<<" n="<<chk.n<<" min_second_fiber="<<chk.minmax
      <<" second_feasible="<<chk.good<<" seven_collinear="<<chk.collinear<<" UNEXCLUDED="<<chk.unexcluded<<"\n";
  if(chk.unexcluded)all=false;
  hard++;
 }
 cout<<"TOTAL projective coefficient-orbits="<<reps.size()<<" simple-count-blocked="<<blocked<<" hard-orbits="<<hard
     <<" all-checked="<<(all?"OBSTRUCTION-PASS":"INCOMPLETE")<<"\n";
 assert(all);
}