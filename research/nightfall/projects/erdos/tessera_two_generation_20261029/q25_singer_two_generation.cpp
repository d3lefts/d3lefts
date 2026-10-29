// Exact q25 affine Singer two-generation restricted finite search. C++17.
// This code computes a maximum independent set of the mixed-difference collision graph
// for every unit multiplier u mod 651 and every cyclic cut c, with a fixed protected
// 23-mark first-generation integer Sidon prefix from PR #192.
#include <algorithm>
#include <array>
#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <numeric>
#include <vector>
#include <chrono>
using namespace std;
static constexpr int V=651,K=26;
const int D[K]={21,72,81,86,88,105,197,217,247,278,316,334,357,360,368,405,430,434,440,462,483,498,525,537,538,584};
const int OLD[]={1,23,70,150,200,604,655,664,669,671,688,800,899,940,988,1013,1017,1045,1066,1081,1108,1121,1167};
const int NOLD=sizeof(OLD)/sizeof(int);
uint32_t neigh[K];
int incumbent=0;vector<int> solution;
unsigned long long nodes=0, tested=0, colored_pruned=0;
int color_order(uint32_t P, int* vert,int* bound){
    int n=0, color=0;
    while(P){
        color++;
        uint32_t available=P;
        while(available){
            int v=__builtin_ctz(available);uint32_t bit=1u<<v;
            vert[n]=v;bound[n]=color;n++;
            P&=~bit;
            available&=~bit;
            available&=~neigh[v];
        }
    }
    return n;
}
void clique(uint32_t P,vector<int>& current){
    nodes++;
    if(!P){if((int)current.size()>incumbent){incumbent=current.size();solution=current;}return;}
    int vtx[K],ub[K];int n=color_order(P,vtx,ub);
    for(int i=n-1;i>=0;i--){
        if((int)current.size()+ub[i]<=incumbent){colored_pruned++;return;}
        int v=vtx[i];current.push_back(v);
        uint32_t Q=P&neigh[v];
        if(Q)clique(Q,current);
        else if((int)current.size()>incumbent){incumbent=current.size();solution=current;}
        current.pop_back();P&=~(1u<<v);
    }
}
int main(){
    bool eold[2000]={};
    for(int i=0;i<NOLD;i++)for(int j=i+1;j<NOLD;j++){
        int d=OLD[j]-OLD[i];
        if(d<=0||d>=2000||eold[d]){cerr<<"invalid old Sidon difference "<<d<<"\n";return 1;}
        eold[d]=true;
    }
    bool moddiff[V]={};
    for(int i=0;i<K;i++)for(int j=0;j<K;j++)if(i!=j){int d=(D[i]-D[j]+V)%V;if(moddiff[d]){cerr<<"not perfect\n";return 1;}moddiff[d]=true;}
    for(int d=1;d<V;d++)if(!moddiff[d]){cerr<<"missing diff\n";return 1;}
    int global=0,bu=0,bc=0;vector<int> bestvals;
    unsigned long long all=0, upper_le=0, exact_calls=0, total_edges=0, max_edges=0,min_edges=1000;
    array<unsigned long long,27> colors{};
    auto start=chrono::steady_clock::now();
    for(int u=1;u<V;u++)if(gcd(u,V)==1){
        for(int c=0;c<V;c++){
            int B[K];for(int i=0;i<K;i++)B[i]=(u*D[i]+c)%V;
            sort(B,B+K);
            for(int i=0;i<K;i++)neigh[i]=0;
            int edges=0;
            for(int i=0;i<K;i++)for(int j=i+1;j<K;j++){
                if(!eold[B[j]-B[i]]){neigh[i]|=1u<<j;neigh[j]|=1u<<i;}
                else edges++;
            }
            total_edges+=edges;max_edges=max(max_edges,(unsigned long long)edges);min_edges=min(min_edges,(unsigned long long)edges);
            int vv[K],bb[K];int n=color_order((1u<<K)-1,vv,bb);
            int color=bb[n-1];colors[color]++;
            all++;
            if(color<=global){upper_le++;continue;}
            exact_calls++;
            incumbent=global;solution.clear();vector<int> current;
            clique((1u<<K)-1,current);
            if(incumbent>global){
                global=incumbent;bu=u;bc=c;
                bestvals.clear();for(int j:solution)bestvals.push_back(B[j]);
                sort(bestvals.begin(),bestvals.end());
                cerr<<"NEW_BEST "<<global<<" u="<<bu<<" c="<<bc<<" color="<<color<<" after="<<all<<"\n";
            }
        }
    }
    auto ms=chrono::duration_cast<chrono::milliseconds>(chrono::steady_clock::now()-start).count();
    cout<<"{\"v\":"<<V<<",\"source_K\":"<<K<<",\"protected_old_size\":"<<NOLD<<",\"all_affine_cases\":"<<all<<",\"max_new_retained\":"<<global<<",\"min_new_deletions\":"<<K-global<<",\"witness_unit\":"<<bu<<",\"witness_cut\":"<<bc<<",\"witness_new_values\":[";
    for(size_t i=0;i<bestvals.size();i++)cout<<(i?",":"")<<bestvals[i];
    cout<<"],\"color_bound_sufficient\":"<<upper_le<<",\"exact_search_cases\":"<<exact_calls<<",\"search_nodes\":"<<nodes<<",\"min_collision_edges\":"<<min_edges<<",\"max_collision_edges\":"<<max_edges<<",\"mean_collision_edges\":"<<(double)total_edges/all<<",\"time_ms\":"<<ms<<",\"color_hist\":{";
    bool first=true;for(int i=0;i<=K;i++)if(colors[i]){cout<<(first?"":",")<<"\""<<i<<"\":"<<colors[i];first=false;}cout<<"}}\n";
}
