#include <bits/stdc++.h>
using namespace std;
constexpr int N=184;
const array<int,10> seeds[2]={{{16,49,50,56,78,93,104,125,139,149}},{{49,50,56,78,93,104,125,139,149,166}}};
struct Data {long long tested=0,sidon=0,saturated=0; int best=999;array<int,9> witness{}; long long bestcount=0;};
int holes(const array<int,9>& a) {
 bool used[185]={}; bool diff[185]={};
 for(int x:a){if(x<1||x>N||used[x])return -1;used[x]=true;}
 for(int i=0;i<9;i++)for(int j=i+1;j<9;j++){
  int d=abs(a[j]-a[i]); if(diff[d])return -1;diff[d]=true;
 }
 bool covered[185]={};for(int a0:a)covered[a0]=true;
 for(int a0:a)for(int d=1;d<=183;d++)if(diff[d]) {
   if(a0+d<=N)covered[a0+d]=true;
   if(a0-d>=1)covered[a0-d]=true;
 }
 for(int i=0;i<9;i++)for(int j=i+1;j<9;j++){
  int s=a[i]+a[j];if(s%2==0)covered[s/2]=true;
 }
 int n=0;for(int x=1;x<=N;x++)if(!covered[x])n++;
 return n;
}
void account(Data& d, array<int,9> a){
 d.tested++;int h=holes(a);if(h<0)return;d.sidon++;
 sort(a.begin(),a.end());if(h<d.best){d.best=h;d.witness=a;d.bestcount=1;}
 else if(h==d.best){d.bestcount++;if(a<d.witness)d.witness=a;}
 if(h==0)d.saturated++;
}
int main(){
 for(int si=0;si<2;si++){
  array<int,10> seed=seeds[si];bool old[185]={};for(int a:seed)old[a]=true;
  vector<int> outside;for(int i=1;i<=N;i++)if(!old[i])outside.push_back(i);
  for(int r=1;r<=3;r++){
   Data d;vector<int> removed;vector<int> added;
   function<void(int,int)> addrec = [&](int at,int need){
    if(!need){array<int,9> a{};int idx=0;for(int i=0;i<10;i++)if(find(removed.begin(),removed.end(),i)==removed.end())a[idx++]=seed[i];
     for(int x:added)a[idx++]=x;
     if(idx!=9)abort();account(d,a);return;}
    for(int i=at;i<=(int)outside.size()-need;i++){added.push_back(outside[i]);addrec(i+1,need-1);added.pop_back();}
   };
   function<void(int,int)> remrec = [&](int at,int need){if(!need){addrec(0,r-1);return;}for(int i=at;i<=10-need;i++){removed.push_back(i);remrec(i+1,need-1);removed.pop_back();}};
   auto begin=chrono::steady_clock::now();remrec(0,r);
   auto dur=chrono::duration<double>(chrono::steady_clock::now()-begin).count();
   cout<<"seed="<<si+1<<" deletions="<<r<<" additions="<<r-1<<" examined="<<d.tested<<" sidon="<<d.sidon<<" saturated="<<d.saturated<<" min_holes="<<d.best<<" tied_best="<<d.bestcount<<" best={";
   for(int i=0;i<9;i++)cout<<(i?",":"")<<d.witness[i];cout<<"} sec="<<setprecision(4)<<dur<<"\n"<<flush;
  }
 }
}
