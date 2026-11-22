// Exact frangible residue count via coverage-mask states and finite-difference surjection.
// For q > h/2-1 any uncovered even offset can be covered; exceptional q=h/2-1
// (if prime) cannot cover the two extreme even offsets.
#include <bits/stdc++.h>
using namespace std;
using i128=__int128_t;using u64=uint64_t;
string out(i128 x){if(!x)return"0";bool neg=x<0;if(neg)x=-x;string s;while(x){s.push_back(char('0'+x%10));x/=10;}if(neg)s.push_back('-');reverse(s.begin(),s.end());return s;}
vector<int> prime_list(int N){vector<int> p;for(int i=3;i<N;i+=2){bool ok=true;for(int k=3;k*k<=i;k+=2)if(i%k==0){ok=false;break;}if(ok)p.push_back(i);}return p;}
i128 choose(int n,int k){if(k<0||k>n)return 0;i128 c=1;for(int j=1;j<=k;j++)c=c*(n-j+1)/j;return c;}
vector<i128> surjection(vector<int> A,int up){vector<i128> res(up+1);for(int k=0;k<=up;k++){i128 s=0;for(int j=0;j<=k;j++){i128 term=choose(k,j);for(int a:A)term*=a-j;if(j&1)s-=term;else s+=term;}res[k]=s;}return res;}
int main(int argc,char**argv){if(argc<2)return 1;int h=atoi(argv[1]);int n=h/2-1;assert(h>=4&&h%2==0&&n<63);u64 full=(1ULL<<n)-1;vector<int> small,large;for(int p:prime_list(h))(p<=h/2-2?small:large).push_back(p);
 unordered_map<u64,u64> st;st[full]=1;
 for(int p:small){vector<pair<u64,int>> rm;unordered_map<u64,int> residue_masks;for(int r=1;r<p;r++){if((r+h)%p==0)continue;u64 mask=0;for(int j=1;j<=n;j++)if((r+2*j)%p==0)mask|=1ULL<<(j-1);residue_masks[mask]++;}for(auto [a,b]:residue_masks)rm.push_back({a,b});unordered_map<u64,u64> next;next.reserve(st.size()*2);for(auto [U,c]:st)for(auto [mask,mult]:rm)next[U&~mask]+=c*mult;st.swap(next);}
 int special=-1;vector<int> A;for(int p:large){if(p==h/2-1){special=p;continue;}A.push_back(p-(h%p==0?1:2));}auto T=surjection(A,large.size());i128 total=0;
 for(auto [U,mult]:st){int k=__builtin_popcountll(U);if(k>(int)large.size())continue;int s=((U&1ULL)!=0)+((U&(1ULL<<(n-1)))!=0);i128 cnt=0;
 if(special==-1)cnt=T[k];else{int good=k-s;int outside=(special-2)-good;cnt=(i128)outside*T[k];if(good)cnt+=(i128)good*T[k-1];}
 if(cnt<0){cerr<<"negative count"<<endl;return 2;}total+=(i128)mult*cnt;}
 cout<<"h="<<h<<" omega="<<out(total)<<" mod4="<<out(total%4)<<" states="<<st.size()<<" small="<<small.size()<<" large="<<large.size()<<" special="<<special<<"\n";
}
