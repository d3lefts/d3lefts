// Exact full-label audit of second-query restricted pencils in F16/F4.
// Independently checks all 4^8·16 rows for each of six first-query branches.
// Compiled: g++ -O3 -std=c++17 pencil_full.cpp -o pencil_full && ./pencil_full
#include <algorithm>
#include <array>
#include <cassert>
#include <cstdint>
#include <iostream>
#include <vector>
using namespace std;

uint8_t mult(int a,int b) {
    int z=0;
    for(int i=0;i<4;i++) {
        if((b>>i)&1) z^=a;
        a<<=1;
        if(a&16) a^=19;
    }
    return z&15;
}

int main() {
    const int a[8]={2,2,3,3,4,4,5,5};
    const int H[3]={1,6,7};
    int powers[16],classId[16],options[8][4];
    for(int x=0;x<16;x++)powers[x]=mult(mult(x,x),x);
    vector<int> image(powers,powers+16);
    sort(image.begin(),image.end());
    image.erase(unique(image.begin(),image.end()),image.end());
    assert(image.size()==6);
    for(int x=0;x<16;x++)
        classId[x]=lower_bound(image.begin(),image.end(),powers[x])-image.begin();
    for(int i=0;i<8;i++) {
        options[i][0]=0;
        for(int j=0;j<3;j++)options[i][j+1]=mult(a[i],H[j]);
    }
    vector<array<uint8_t,8>> states[6];
    for(int index=0;index<6561;index++) {
        int z=index,v=0;
        array<uint8_t,8> x;
        for(int j=0;j<8;j++) {
            x[j]=H[z%3];z/=3;
            v^=mult(a[j],x[j]);
        }
        states[classId[v]].push_back(x);
    }
    const int expectedN[]={417,1224,1230,1230,1230,1230};
    const int expectedMin[]={78,225,225,225,225,225};
    const int expectedPass[]={1047504,0,0,0,0,0};
    int proj[16][16];
    for(int raw=0;raw<16;raw++)
        for(int anchor=0;anchor<16;anchor++)
            proj[raw][anchor]=classId[raw^anchor];
    int contrib[8][4][3];
    for(int i=0;i<8;i++)
        for(int j=0;j<4;j++)
            for(int k=0;k<3;k++)
                contrib[i][j][k]=mult(options[i][j],H[k]);
    for(int branch=0;branch<6;branch++) {
        auto &st=states[branch];
        assert(st.size()==(size_t)expectedN[branch]);
        vector<array<uint8_t,8>> digits;
        digits.reserve(st.size());
        for(auto &x:st) {
            array<uint8_t,8> d;
            for(int i=0;i<8;i++) {
                int k=0;
                while(H[k]!=x[i]) {k++;assert(k<3);}
                d[i]=k;
            }
            digits.push_back(d);
        }
        int best=6562;
        int feasible=0;
        array<int,6> bestBuckets{};
        int witness=-1;
        for(int cfg=0;cfg<65536;cfg++) {
            int z=cfg,d[8];
            for(int i=0;i<8;i++) {d[i]=z&3;z>>=2;}
            int rawCount[16]={};
            for(auto &x:digits) {
                int s=0;
                for(int i=0;i<8;i++)s^=contrib[i][d[i]][x[i]];
                rawCount[s]++;
            }
            for(int anchor=0;anchor<16;anchor++) {
                int outputs[6]={};
                for(int raw=0;raw<16;raw++)
                    outputs[proj[raw][anchor]]+=rawCount[raw];
                int worst=*max_element(outputs,outputs+6);
                if(worst<=216) feasible++;
                if(worst<best) {
                    best=worst;witness=16*cfg+anchor;
                    for(int i=0;i<6;i++)bestBuckets[i]=outputs[i];
                }
            }
        }
        assert(best==expectedMin[branch]);
        assert(feasible==expectedPass[branch]);
        cout<<"PASS branch "<<branch<<" size "<<st.size()
            <<" minmax "<<best<<" eligible "<<feasible
            <<" / 1048576 witness "<<witness<<" fibers ";
        for(int i=0;i<6;i++)
            cout<<bestBuckets[i]<<(i==5?'\n':',');
    }
    cout<<"PASS all six branches of fixed first-row pencil; ";
    cout<<"five nonzero branches require > 6^3 states\n";
}
