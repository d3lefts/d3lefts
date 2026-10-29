// Independent adversarial replay B. Standard C++17.
// Does not import or call the primary max-clique algorithm; constructs collision
// graph from literal OLD+NEW cross sums, then searches for an 11-clique in its
// complement with Bron--Kerbosch pivoting. A counterexample aborts with status 1.
#include <algorithm>
#include <array>
#include <cassert>
#include <cstdint>
#include <iostream>
#include <numeric>
#include <vector>
using namespace std;
constexpr int V=651,K=26;
constexpr int D[K]={21,72,81,86,88,105,197,217,247,278,316,334,357,360,368,405,430,434,440,462,483,498,525,537,538,584};
constexpr int O[23]={1,23,70,150,200,604,655,664,669,671,688,800,899,940,988,1013,1017,1045,1066,1081,1108,1121,1167};
uint32_t allowed[K];unsigned long long visited=0;
bool exists11(int size,uint32_t P,uint32_t X){
    visited++;
    if(size>=11)return true;
    if(size+__builtin_popcount(P)<11)return false;
    if(!P)return false;
    uint32_t pivotset=P|X;
    int pivot=-1,best=-1;
    while(pivotset){int u=__builtin_ctz(pivotset);pivotset&=pivotset-1;
        int deg=__builtin_popcount(P&allowed[u]);if(deg>best){best=deg;pivot=u;}}
    uint32_t candidates=P&~(pivot>=0?allowed[pivot]:0);
    while(candidates){
        int v=__builtin_ctz(candidates);uint32_t bit=1u<<v;candidates&=~bit;
        if(exists11(size+1,P&allowed[v],X&allowed[v]))return true;
        P&=~bit;X|=bit;
        if(size+__builtin_popcount(P)<11)return false;
    }
    return false;
}
bool literal_sidon(const vector<int>& S){
    int maxsum=2*S.back();vector<int> counts(maxsum+1);
    for(int i=0;i<(int)S.size();i++)for(int j=i;j<(int)S.size();j++){
        if(++counts[S[i]+S[j]]!=1)return false;
    }
    return true;
}
int main(){
    vector<int> old(O,O+23);assert(is_sorted(old.begin(),old.end()));assert(literal_sidon(old));
    // Reconstruct the first generation from the frozen q25 PR #192 cut and deletion indices.
    const int removed[]={6,8,9,11,13,14,18,23};
    vector<int> rebuilt={1,23,70,150,200};
    for(int j=0;j<K;j++)if(find(begin(removed),end(removed),j)==end(removed))rebuilt.push_back(583+D[j]);
    sort(rebuilt.begin(),rebuilt.end());assert(rebuilt==old);
    bool residues[V]={};int nres=0;
    for(int x:D)for(int y:D)if(x!=y){int d=(x-y+V)%V;assert(d>0&&!residues[d]);residues[d]=true;nres++;}
    assert(nres==650);
    // Same residue profile as the integer Sidon prefix, but a non-Sidon canonical lift.
    vector<int> canonical;for(int x:old)canonical.push_back(x%V);
    sort(canonical.begin(),canonical.end());
    assert(unique(canonical.begin(),canonical.end())==canonical.end());
    assert(!literal_sidon(canonical)); // 1+23=4+20=24.

    unsigned long long cases=0,totalConflict=0,minConflict=1000,maxConflict=0;
    for(int u=1;u<V;u++)if(gcd(u,V)==1){
        for(int c=0;c<V;c++){
            int B[K];for(int j=0;j<K;j++)B[j]=(u*D[j]+c)%V;
            sort(B,B+K);
            // For every cross-sum old[i]+new[j], check whether another old/new
            // pair has the SAME ORDINARY INTEGER SUM (no modular arithmetic).
            uint32_t seen[1900]={};
            uint32_t conflict[K]={};
            for(int i=0;i<23;i++)for(int j=0;j<K;j++){
                int s=O[i]+B[j];assert(s>=0&&s<1900);
                seen[s]|=1u<<j;
            }
            for(uint32_t mask:seen)if(__builtin_popcount(mask)>1){
                uint32_t m=mask;
                while(m){int j=__builtin_ctz(m);m&=m-1;conflict[j]|=mask&~(1u<<j);}
            }
            int edges=0;
            for(int j=0;j<K;j++){
                allowed[j]=((1u<<K)-1)&~conflict[j]&~(1u<<j);
                edges+=__builtin_popcount(conflict[j]);
            }
            edges/=2;
            minConflict=min(minConflict,(unsigned long long)edges);
            maxConflict=max(maxConflict,(unsigned long long)edges);
            totalConflict+=edges;
            cases++;
            if(exists11(0,(1u<<K)-1,0)){
                cerr<<"FAIL 11-retained counterexample u="<<u<<" c="<<c<<"\n";
                return 1;
            }
        }
    }
    assert(cases==234360);
    assert(minConflict==86&&maxConflict==162);
    cout<<"PASS independent literal-cross-sum Bron-Kerbosch: cases="<<cases
        <<" no 11-mark extension, conflict edges range="<<minConflict<<".."<<maxConflict
        <<" total="<<totalConflict<<" nodes="<<visited<<"\n";
    // Witness from independent first program: verify it is truly a 33-mark Sidon set.
    int W[]={0,11,172,203,259,356,366,418,500,619};
    vector<int> full=old;for(int w:W)full.push_back(2334+w);
    assert(literal_sidon(full));
    int B[K];for(int j=0;j<K;j++)B[j]=(92*D[j]+72)%V;
    sort(B,B+K);
    for(int w:W)assert(binary_search(B,B+K,w));
    // Every excluded new source mark individually breaks the 33-mark witness.
    for(int b:B)if(find(begin(W),end(W),b)==end(W)){
        vector<int> attempt=full;attempt.push_back(2334+b);
        sort(attempt.begin(),attempt.end());assert(!literal_sidon(attempt));
    }
    // Sharp band-separation boundary negative control: T=2333 is invalid
    // since 1+2333=1167+1167=2334.
    vector<int> tooClose=old;for(int w:W)tooClose.push_back(2333+w);
    assert(!literal_sidon(tooClose));
    // Deliberate corruption must fail.
    vector<int> broken=full;broken.push_back(full.back());sort(broken.begin(),broken.end());
    assert(!literal_sidon(broken));
    cout<<"PASS literal 33-mark Sidon witness at T=2334; T=2333 and duplicate-mark controls rejected\n";
}
