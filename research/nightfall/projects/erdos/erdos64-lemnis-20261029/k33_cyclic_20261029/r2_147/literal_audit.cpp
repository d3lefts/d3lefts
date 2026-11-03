#include <array>
#include <iostream>
#include <vector>
#include <map>
#include <set>
using namespace std;
int W[3][3]={{0,0,0},{0,1,5},{0,17,64}};
vector<array<int,3>> G;
long long counts[17] = {};
void walk(int root,int x,int parent,int len,vector<char>& seen) {
 for(int y:G[x]) {
  if(y==root) {if(len+1<=16 && len+1>=4 && (len+1)%2==0) counts[len+1]++;continue;}
  if(y==parent||seen[y]||len>=15)continue;
  seen[y]=true;walk(root,y,x,len+1,seen);seen[y]=false;
 }
}
int main(int argc,char**argv){
 int m=argc>1?stoi(argv[1]):147;
 if(argc==6){W[1][1]=stoi(argv[2]);W[1][2]=stoi(argv[3]);W[2][1]=stoi(argv[4]);W[2][2]=stoi(argv[5]);}
 G.assign(6*m,{});
 for(int a=0;a<3;a++)for(int b=0;b<3;b++)for(int x=0;x<m;x++) {
  int u=a*m+x, v=(b+3)*m+(x+W[a][b])%m;G[u][b]=v;G[v][a]=u;
 }
 for(int s=0;s<6;s++)for(int x=0;x<m;x++){
   int u=s*m+x;set<int> nei(G[u].begin(),G[u].end());if(nei.size()!=3){cerr<<"non-cubic";return 1;}
 }
 vector<char> seen(6*m);
 for(int i=0;i<6;i++){int root=i*m;seen[root]=true;walk(root,root,-1,0,seen);seen[root]=false;}
 cout<<"m="<<m<<" |V|="<<6*m<<" rooted cycle orbits: ";
 for(int n=4;n<=16;n+=2)cout<<"C"<<n<<":"<<counts[n]<<" ";cout<<"\n";
 string word="03140523041325140314031403140314";
 int fiber=0;set<pair<int,int>> states;
 for(int i=0;i<32;i++){
   int u=word[i]-'0',v=word[(i+1)%32]-'0';
   if(!states.insert({u,(fiber%m+m)%m}).second) {cerr<<"32 repeated state at "<<i<<"\n";return 2;}
   int a=u<3?u:v, b=u<3?v:u;
   if(a>=3||b<3){cerr<<"invalid base edge\n";return 3;}
   int off=W[a][b-3]*(u<3?1:-1); fiber+=off;
 }
 if(fiber%m){cerr<<"32 did not close: fiber "<<fiber<<"\n";return 4;}
 cout<<"C32 simple, 32 unique vertices, closed integer voltage="<<fiber<<"\n";
 if(counts[4]||counts[8]||counts[16])return 5;
}
