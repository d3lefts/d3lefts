#include <bits/stdc++.h>
using namespace std;
mt19937_64 rng(20261029);
int randint(int n){return rng()%n;}
struct Ev {int missed, collisions;};
Ev eval(const array<int,9>&a,int N){
 bool dif[3000]={0}; int collisions=0;
 for(int i=0;i<9;i++)for(int j=0;j<i;j++){int d=abs(a[i]-a[j]); if(!d)collisions+=10; else {if(dif[d])collisions++;dif[d]=true;}}
 if(collisions)return {N,collisions};
 bool covered[3000]={0};
 for(int i=0;i<9;i++)covered[a[i]]=true;
 for(int i=0;i<9;i++)for(int d=1;d<N;d++)if(dif[d]){
 int x=a[i]+d,y=a[i]-d;
 if(x<=N)covered[x]=true;
 if(y>=1)covered[y]=true;
 }
 for(int i=0;i<9;i++)for(int j=0;j<i;j++)if((a[i]+a[j])%2==0)covered[(a[i]+a[j])/2]=true;
 int missed=0;for(int i=1;i<=N;i++)missed+=!covered[i];
 return {missed,0};
}
int main(int argc,char**argv){int N=argc>1?atoi(argv[1]):184; int restarts=argc>2?atoi(argv[2]):20; int iters=argc>3?atoi(argv[3]):100000;
 int best=100000;array<int,9> besta{};
 for(int run=0;run<restarts;run++){
 array<int,9>a; int cur=100000;
 for(int j=0;j<100000;j++){for(int i=0;i<9;i++)a[i]=randint(N)+1;auto e=eval(a,N);if(e.collisions==0){cur=e.missed;break;}}
 if(cur==100000)continue;
 if(cur<best){best=cur;besta=a;}
 for(int iter=0;iter<iters;iter++){
   auto b=a;int m=randint(100);int count=(m<65?1:m<95?2:3);
   for(int h=0;h<count;h++){int pos=randint(9);int typ=randint(100);int v=(typ<30 ? b[pos]+(randint(11)-5) : (typ<45 ? b[pos]+(randint(61)-30) : randint(N)+1));b[pos]=max(1,min(N,v));}
   auto e=eval(b,N);if(e.collisions)continue;
   int next=e.missed;
   if(next<best){best=next;besta=b;sort(besta.begin(),besta.end());cerr<<"N="<<N<<" best="<<best<<" step="<<run*iters+iter<<" A=";for(int x:besta)cerr<<x<<",";cerr<<"\n";if(!best){for(int x:besta)cout<<x<<" ";cout<<"\n";return 0;}}
   double frac=(iter%20000)/20000.;double temp=3.0*pow(0.1/3.0,frac);
   if(next<=cur || uniform_real_distribution<double>(0,1)(rng)<exp((cur-next)/temp)){a=b;cur=next;}
 }
 }
 cerr<<"FINAL best="<<best<<" A=";for(int x:besta)cerr<<x<<",";cerr<<"\n";
}
