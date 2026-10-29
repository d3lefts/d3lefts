// NIGHTFALL / RYEV Q7 translation-closed face join.
// Exhausts 69751 unordered pairs of 373 frozen near-extremal Q6 source faces
// under all 64 relative Q6 XOR translations. A maximum matching too SMALL
// yields a candidate Q7 >=305 witness. Large matchings are explicit blockers.
// Internal exact finite computation; historical catalogue is incomplete.
#include <array>
#include <vector>
#include <set>
#include <string>
#include <fstream>
#include <iostream>
#include <sstream>
#include <algorithm>
#include <cstdint>
#include <cassert>
#include <stdexcept>
#include <iomanip>
using namespace std;
using M=array<uint64_t,3>;
struct Edge{int u,v,d;};
struct Face{M mask{};int count=0,origin=-1,fixed=-1,half=-1;};
static vector<Edge> e6,e7;
static int id6[64][6],id7[128][7];
static int lpar[32],nl=0;
static uint64_t adj[64];
static int mate[64];
static uint64_t seen=0;
static int calls=0;
static void must(bool b,const char *msg){if(!b)throw runtime_error(msg);}
static string hexline(int n,int t){ostringstream o;o<<n<<":"<<t;return o.str();}
static void geometry(){
 for(int v=0;v<64;v++)for(int d=0;d<6;d++)id6[v][d]=-1;
 for(int v=0;v<128;v++)for(int d=0;d<7;d++)id7[v][d]=-1;
 for(int d=0;d<6;d++)for(int v=0;v<64;v++)if(!(v&(1<<d))){
  id6[v][d]=(int)e6.size();e6.push_back({v,v|(1<<d),d});
 }
 for(int d=0;d<7;d++)for(int v=0;v<128;v++)if(!(v&(1<<d))){
  id7[v][d]=(int)e7.size();e7.push_back({v,v|(1<<d),d});
 }
 must(e6.size()==192&&e7.size()==448,"Incorrect Q6/Q7 edge enumeration");
 for(int v=0;v<64;v++)if((__builtin_popcount((unsigned)v)&1)==0)lpar[nl++]=v;
 must(nl==32,"Q6 parity mismatch");
}
static bool aug(int u){
 uint64_t moves=adj[u]&~seen;
 while(moves){
  uint64_t bit=moves&-moves;moves^=bit;
  int v=__builtin_ctzll(bit);
  if(seen&bit)continue;
  seen|=bit;
  if(mate[v]<0||aug(mate[v])){mate[v]=u;return true;}
 }
 return false;
}
static int matching(const M &common,int cutoff){
 fill(begin(adj),end(adj),0);
 for(int w=0;w<3;w++){
  uint64_t bits=common[w];
  while(bits){
   int k=__builtin_ctzll(bits);bits&=bits-1;
   const auto &e=e6[w*64+k];
   int u=e.u,v=e.v;
   if(__builtin_popcount((unsigned)u)&1)swap(u,v);
   adj[u]|=1ull<<v;
  }
 }
 fill(begin(mate),end(mate),-1);
 int n=0;
 for(int k=0;k<32;k++){seen=0;if(aug(lpar[k])){++n;if(n>cutoff)return n;}}
 return n;
}
static vector<Face> source_faces(const string &src){
 ifstream f(src,ios::binary);must((bool)f,"Missing source catalogue");
 string line;vector<string> lines;
 while(getline(f,line)){if(!line.empty()&&line.back()=='\r')line.pop_back();if(!line.empty())lines.push_back(line);}
 must(lines.size()==180,"Expected exactly 180 frozen catalogue masks");
 set<string> raw_unique(lines.begin(),lines.end());
 must(raw_unique.size()==180,"Repeated source mask");
 vector<Face> faces;
 set<M> distinct;
 int total131=0,total132=0;
 for(int k=0;k<180;k++){
  const string &h=lines[k];must(h.size()==112,"Wrong source mask width");
  bool selected[448]={};
  int selected_count=0;
  for(int i=0;i<448;i++){
   int byte=stoi(h.substr(2*(i/8),2),nullptr,16);
   selected[i]=(byte & (128>>(i%8)))!=0;
   selected_count+=(int)selected[i];
  }
  must(selected_count==304,"Source witness not 304 edges");
  // Independent Q7 coordinate-square no-C4 audit.
  for(int a=0;a<7;a++)for(int b=a+1;b<7;b++)
   for(int v=0;v<128;v++)if(!(v&((1<<a)|(1<<b)))){
    int u=v|(1<<a),w=v|(1<<b);
    int four=selected[id7[v][a]]+selected[id7[v][b]]+
             selected[id7[w][a]]+selected[id7[u][b]];
    must(four<4,"Supplied Q7 source has a complete four-cycle");
   }
  for(int fixed=0;fixed<7;fixed++)for(int half=0;half<2;half++){
   Face face;face.origin=k;face.fixed=fixed;face.half=half;
   for(int i=0;i<448;i++)if(selected[i]){
    const Edge &e=e7[i];
    if(e.d==fixed||((e.u>>fixed)&1)!=half)continue;
    int vv=(e.u&((1<<fixed)-1))|((e.u>>(fixed+1))<<fixed);
    int dd=e.d-(e.d>fixed);
    int id=id6[vv][dd];must(id>=0,"Invalid Q6 fold index");
    face.mask[id>>6]|=1ull<<(id&63);
    face.count++;
   }
   if(face.count<131)continue;
   if(face.count==131)total131++;
   if(face.count==132)total132++;
   must(face.count<=132,"Source Q6 exceeds exact 132 bound");
   if(distinct.insert(face.mask).second)faces.push_back(face);
  }
 }
 must(total131==660&&total132==333,"Unexpected Q6 source face multiplicities");
 must(faces.size()==373,"Expected 373 distinct published high Q6 faces");
 int counts[2]={};for(const auto &f:faces){must(f.count==131||f.count==132,"Face count drift");counts[f.count-131]++;}
 must(counts[0]==253&&counts[1]==120,"Unexpected 253/120 high-face split");
 return faces;
}
static vector<array<M,64>> all_translate(const vector<Face>& faces){
 int mapping[64][192];
 for(int t=0;t<64;t++)for(int k=0;k<192;k++){
  const auto &e=e6[k];
  int v=e.u^t;
  if(v&(1<<e.d))v^=1<<e.d;
  int new_id=id6[v][e.d];must(new_id>=0,"Translation failed cube-edge map");
  mapping[t][k]=new_id;
 }
 vector<array<M,64>> translated(faces.size());
 for(size_t i=0;i<faces.size();i++)for(int t=0;t<64;t++){
  M &m=translated[i][t];m={0,0,0};
  for(int w=0;w<3;w++){uint64_t b=faces[i].mask[w];while(b){
    int e=64*w+__builtin_ctzll(b);b&=b-1;
    int destination=mapping[t][e];
    m[destination>>6]|=1ull<<(destination&63);
  }}
  int count=__builtin_popcountll(m[0])+__builtin_popcountll(m[1])+__builtin_popcountll(m[2]);
  must(count==faces[i].count,"Translation changed face cardinality");
 }
 return translated;
}
static vector<pair<int,int>> build_witness(const Face&A,const M&B){
 // Full optimum matching has already been computed, if threshold failed.
 // Use König's alternating-tree construction for an independent set of size 64−nu.
 bool matchedLeft[64]={};for(int v=0;v<64;v++)if(mate[v]>=0)matchedLeft[mate[v]]=true;
 bool seenLeft[64]={},seenRight[64]={};
 vector<int> stack;
 for(int j=0;j<32;j++){int u=lpar[j];if(!matchedLeft[u]){stack.push_back(u);seenLeft[u]=true;}}
 while(!stack.empty()){
  int u=stack.back();stack.pop_back();
  uint64_t b=adj[u];
  while(b){
   int v=__builtin_ctzll(b);b&=b-1;
   if(mate[v]==u||seenRight[v])continue;
   seenRight[v]=true;
   int w=mate[v];
   if(w>=0&&!seenLeft[w]){seenLeft[w]=true;stack.push_back(w);}
  }
 }
 bool independent[64]={};
 for(int v=0;v<64;v++)independent[v]=((__builtin_popcount((unsigned)v)&1)==0)?seenLeft[v]:!seenRight[v];
 vector<pair<int,int>> edges;
 for(int k=0;k<192;k++)if(A.mask[k>>6]&(1ull<<(k&63))){
  edges.push_back({e6[k].u,e6[k].v});
 }
 for(int k=0;k<192;k++)if(B[k>>6]&(1ull<<(k&63))){
  edges.push_back({e6[k].u+64,e6[k].v+64});
 }
 for(int v=0;v<64;v++)if(independent[v])edges.push_back({v,v+64});
 sort(edges.begin(),edges.end());
 set<pair<int,int>> E(edges.begin(),edges.end());
 must(edges.size()==E.size(),"Duplicate joined edge");
 // Independent 672-square oracle, distinct from matching.
 for(int v=0;v<128;v++)for(int a=0;a<7;a++)if(!(v&(1<<a)))
  for(int b=a+1;b<7;b++)if(!(v&(1<<b))){
   int x=v|(1<<a),y=v|(1<<b),z=x|(1<<b);
   int n=(int)E.count({v,x})+(int)E.count({v,y})+
         (int)E.count({x,z})+(int)E.count({y,z});
   must(n<=3,"Joined matching candidate creates C4");
  }
 return edges;
}
int main(int argc,char**argv){
 try{
  must(argc==2,"Usage: q7_translation.cpp /path/canonical_180.txt");
  geometry();
  auto faces=source_faces(argv[1]);
  auto translated=all_translate(faces);
  uint64_t checked=0,classes[3]={},boundary[3]={},failures=0;
  const uint64_t expected=69751ull*64;
  for(size_t i=0;i<faces.size();i++)for(size_t j=i;j<faces.size();j++){
   const Face &A=faces[i],&B=faces[j];
   int type=(A.count-131)+(B.count-131);
   int threshold=A.count+B.count+64-305;
   must(threshold==21+type,"Incorrect 305 threshold");
   for(int t=0;t<64;t++){
    const M &bm=translated[j][t];
    M overlap={A.mask[0]&bm[0],A.mask[1]&bm[1],A.mask[2]&bm[2]};
    int nu=matching(overlap,threshold);
    checked++;classes[type]++;
    if(nu==threshold+1){boundary[type]++;continue;}
    must(nu<=threshold,"Unexpected cutoff protocol");
    failures++;
    // Need full maximum matching, then the exact minimum vertex cover.
    nu=matching(overlap,64);
    int score=A.count+B.count+64-nu;
    must(score>=305,"Threshold mismatch");
    auto witness=build_witness(A,bm);
    must((int)witness.size()==score,"Matching/cover dual inconsistent");
    ofstream out("q7_translation_candidate_edges.txt",ios::binary);
    for(auto [u,v]:witness)out<<u<<" "<<v<<"\n";
    out.close();
    cout<<"FOUND_CANDIDATE_EDGE_COUNT "<<score<<" seedFaces "<<i<<" "<<j<<" translation "<<t
        <<" matching "<<nu<<" trials "<<checked<<"\n";
    cout<<"PRIORITY_AND_INDEPENDENT_VERIFICATION_REQUIRED\n";
    return 0;
   }
  }
  must(checked==expected,"Incomplete 4,464,064 pair/translation enumeration");
  must(classes[0]==32131ull*64&&classes[1]==30360ull*64&&classes[2]==7260ull*64,
       "Wrong class cardinality");
  cout<<"FORMAT nightfall-q7-translation-closed-catalogue-v1\n"
      <<"SOURCE 180 Minamoto Q7 seed masks; 373 distinct 131/132 Q6 half-faces\n"
      <<"PAIRS 69751\nTRANSLATIONS 64\nTRIALS "<<checked
      <<"\nCLASS_131_131 "<<classes[0]
      <<"\nCLASS_131_132 "<<classes[1]
      <<"\nCLASS_132_132 "<<classes[2]
      <<"\nTHRESHOLD_REJECTIONS "<<(checked-failures)
      <<"\nCANDIDATES "<<failures
      <<"\nCONCLUSION TRANSLATION_SUBGROUP_JOIN_MAX_304\n";
  return 0;
 }catch(const exception &e){cerr<<"REJECTED "<<e.what()<<"\n";return 3;}
}
