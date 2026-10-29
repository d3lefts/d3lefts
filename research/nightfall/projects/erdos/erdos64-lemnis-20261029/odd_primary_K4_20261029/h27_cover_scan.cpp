#include <bits/stdc++.h>
using namespace std;
struct E {int b,g;};
int Gmul[27][27], invg[27];
inline int idx(int a,int b,int c){return a+3*b+9*c;}
int mulcalc(int u,int v){int a=u%3,b=(u/3)%3,c=u/9,aa=v%3,bb=(v/3)%3,cc=v/9;return idx((a+aa)%3,(b+bb)%3,(c+cc+a*bb)%3);}
void init(){for(int x=0;x<27;x++)for(int y=0;y<27;y++)Gmul[x][y]=mulcalc(x,y);for(int x=0;x<27;x++)for(int y=0;y<27;y++)if(Gmul[x][y]==0&&Gmul[y][x]==0)invg[x]=y;}
array<array<int,3>,108> adj;
inline int node(int base,int g){return base*27+g;}
void makecover(int a,int b,int c){for(auto &z:adj)z={-1,-1,-1};int cnt[108]={};auto add=[&](int i,int j,int vol){for(int g=0;g<27;g++){int u=node(i,g),v=node(j,Gmul[g][vol]);adj[u][cnt[u]++]=v;adj[v][cnt[v]++]=u;}};add(0,1,0);add(0,2,0);add(0,3,0);add(1,2,a);add(1,3,b);add(2,3,c);for(int z=0;z<108;z++)if(cnt[z]!=3)throw runtime_error("degree");}
int root,len; bool seen[108];
bool dfs(int v,int prev,int dep){if(dep==len){for(int z:adj[v])if(z==root)return true;return false;}for(int z:adj[v]){if(z==prev || seen[z] || z==root)continue;seen[z]=true;if(dfs(z,v,dep+1))return true;seen[z]=false;}return false;}
bool cyc(int n){len=n;for(int i=0;i<4;i++){root=node(i,0);memset(seen,0,sizeof(seen));seen[root]=true;for(int v:adj[root]){seen[v]=true;if(dfs(v,root,2))return true;seen[v]=false;}}return false;}
int main(int argc,char**argv){init();int maxTests= argc>1?atoi(argv[1]):2000;int total=0,n4=0,n8=0,n16=0,no16=0,conn=0;vector<array<int,3>> exceptions;for(int a=0;a<27;a++)for(int b=0;b<27;b++)for(int c=0;c<27;c++){
 int ab1=a%3,ab2=a/3%3,bb1=b%3,bb2=b/3%3,cb1=c%3,cb2=c/3%3;
 int d1=(ab1*bb2-ab2*bb1+9)%3,d2=(ab1*cb2-ab2*cb1+9)%3,d3=(bb1*cb2-bb2*cb1+9)%3;
 if(!(d1||d2||d3))continue;
 conn++;
 if(total>=maxTests)continue;
 total++;
 makecover(a,b,c);
 if(cyc(4)){n4++;continue;}if(cyc(8)){n8++;continue;}if(cyc(16)){n16++;continue;}no16++;if(exceptions.size()<15)exceptions.push_back({a,b,c});
 }cerr<<"H27 connected-eligible="<<conn<<" tested="<<total<<" C4="<<n4<<" no4_C8="<<n8<<" no4no8_C16="<<n16<<" no4no8no16="<<no16<<"\n";for(auto x:exceptions)cerr<<"CANDIDATE "<<x[0]<<" "<<x[1]<<" "<<x[2]<<"\n";
 if(maxTests>=16848 && (conn!=16848 || total!=16848 || n4!=1296 || n8!=3888 || n16!=11664 || no16!=0))return 2;
}
