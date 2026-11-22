// Separate exact verifier using inclusion-exclusion on uncovered-set size.
// Does not call or import the surjection recurrence implementation.
#include <bits/stdc++.h>
using namespace std;
using I=__int128_t;using U=uint64_t;
string dec(I x){if(!x)return"0";string s;while(x){s.push_back((char)('0'+x%10));x/=10;}reverse(s.begin(),s.end());return s;}
vector<int> prime_odd(int h){vector<int> p;for(int a=3;a<h;a+=2){bool isprime=true;for(int k=3;k*k<=a;k+=2)if(a%k==0){isprime=false;break;}if(isprime)p.push_back(a);}return p;}
I cmb(int a,int b){if(b<0||b>a)return 0;I c=1;for(int j=1;j<=b;j++)c=c*(a-j+1)/j;return c;}
I count_ie(int h,int k,int exceptional,vector<int> big){I result=0;int qstar=(h/2)-1;bool star=(find(big.begin(),big.end(),qstar)!=big.end());for(int j=0;j<=k;j++){
 I sum=0;
 for(int e=0;e<=min(j,exceptional);e++){
  int regular_selected=j-e;
  if(regular_selected>k-exceptional)continue;
  I weight=cmb(exceptional,e)*cmb(k-exceptional,regular_selected);
  for(int q:big){int allowed=q-((h%q)==0?1:2);weight*=allowed-j+((star&&q==qstar)?e:0);}
  sum+=weight;
 }
 result+=(j%2?-sum:sum);
}
return result;
}
int main(int argc,char**argv){if(argc<2)return 1;int h=atoi(argv[1]);int t=h/2-1;assert(h>=4 && h%2==0 && t<63);
 U maskmax=(1ULL<<t)-1;
 unordered_map<U,U> cur;cur[maskmax]=1;
 vector<int> big;
 for(int q:prime_odd(h)){
  if(q*2>=h-2){big.push_back(q);continue;}
  vector<U> removals;
  for(int residue=1;residue<q;residue++){
   if((residue+h)%q==0)continue;
   U cover=0;
   for(int j=0;j<t;j++)if((residue+2*j+2)%q==0)cover|=1ULL<<j;
   removals.push_back(cover);
  }
  unordered_map<U,U> out;
  for(auto [uncovered,multiplicity]:cur)for(U covered:removals)out[uncovered&(~covered)]+=multiplicity;
  cur.swap(out);
 }
 vector<array<I,3>> buckets(big.size()+1);
 for(auto [remaining,mult]:cur){int k=__builtin_popcountll(remaining);if(k>(int)big.size())continue;
  int e=0;if(find(big.begin(),big.end(),h/2-1)!=big.end())e=(remaining&1ULL?1:0)+(remaining&(1ULL<<(t-1))?1:0);
  buckets[k][e]+=mult;
 }
 I ans=0;for(int k=0;k<=(int)big.size();k++)for(int s=0;s<=2;s++)if(buckets[k][s]){
  I ways=count_ie(h,k,s,big);assert(ways>=0);ans+=buckets[k][s]*ways;
 }
 cout<<"h="<<h<<" omega="<<dec(ans)<<" states="<<cur.size()<<"\n";
}
