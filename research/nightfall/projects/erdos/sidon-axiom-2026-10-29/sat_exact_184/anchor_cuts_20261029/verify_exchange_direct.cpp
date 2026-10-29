// Independent full 3.6M replay using unordered SUMS and direct insertion tests.
// Does not reference original difference/coverage algorithm.
#include <algorithm>
#include <array>
#include <iostream>
#include <vector>
using namespace std;
static const int N=184;
const vector<vector<int>> seeds={{16,49,50,56,78,93,104,125,139,149},{49,50,56,78,93,104,125,139,149,166}};
struct Tally{long long count=0,sidon=0,saturated=0;int minholes=999;};
int sum_oracle(const vector<int>& marks){
 bool sums[369]={};bool used[185]={};
 for(int x:marks){if(used[x]||x<1||x>N)return -1;used[x]=true;}
 for(int i=0;i<9;i++)for(int j=i;j<9;j++){
  int s=marks[i]+marks[j];if(sums[s])return -1;sums[s]=true;
 }
 int holes=0;
 for(int x=1;x<=N;x++)if(!used[x]){
  bool blocked=sums[2*x];
  if(!blocked)for(int y:marks)if(sums[x+y]){blocked=true;break;}
  if(!blocked)++holes;
 }
 return holes;
}
int main(){
 for(size_t si=0;si<seeds.size();si++)for(int r=1;r<=3;r++){
  vector<int> external;bool ins[185]={};for(int x:seeds[si])ins[x]=true;
  for(int x=1;x<=N;x++)if(!ins[x])external.push_back(x);
  Tally result;
  vector<int> kept,added;
  auto test=[&](){vector<int> candidate=kept;candidate.insert(candidate.end(),added.begin(),added.end());
   result.count++;int h=sum_oracle(candidate);
   if(h>=0){result.sidon++;result.minholes=min(result.minholes,h);if(h==0)result.saturated++;}
  };
  auto genadd=[&](auto&& self,int start,int need)->void{
   if(need==0){test();return;}
   for(int j=start;j<=(int)external.size()-need;j++){
    added.push_back(external[j]);self(self,j+1,need-1);added.pop_back();}
  };
  auto genkeep=[&](auto&& self,int start,int need)->void{
   if(need==0){genadd(genadd,0,r-1);return;}
   for(int j=start;j<=10-need;j++){
    kept.push_back(seeds[si][j]);self(self,j+1,need-1);kept.pop_back();}
  };
  genkeep(genkeep,0,10-r);
  cout<<"seed="<<si+1<<" r="<<r<<" tested="<<result.count<<" sidon="<<result.sidon<<" saturated="<<result.saturated<<" minholes="<<result.minholes<<"\n";
 }
}
