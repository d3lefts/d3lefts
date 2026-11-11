// NIGHTFALL: pointwise sensitivity squared-variance inequality audit.
// C++17, exact integer arithmetic, no external dependencies.
// g++ -O3 -std=c++17 -Wall -Wextra -pedantic check_pointwise_sensitivity_exact.cpp -o check_psi
// ./check_psi
#include <algorithm>
#include <cassert>
#include <cstdint>
#include <iostream>
#include <random>
#include <vector>

using std::uint64_t;
using U = uint64_t;

struct Quantities {
    U numerator; // 16 [N sum f^2 - (sum f)^2]^2
    U bound;     // R^2 N^3 max_i sum_x [f(x)-f(x^i)]^2
    int R;
    U max_diff_sq_sum;
};

Quantities direct_quantities(const std::vector<int>& f, int n) {
    const int N = 1 << n;
    assert(static_cast<int>(f.size()) == N);
    U s = 0, s2 = 0;
    for (int x : f) { assert(x >= 0 && x <= 2); s += x; s2 += x*x; }
    U A = U(N)*s2 - s*s;
    int R = 0;
    std::vector<U> ed(n, 0);
    for (int x=0; x<N; ++x) {
        int row = 0;
        for (int i=0; i<n; ++i) {
            int z = f[x] - f[x ^ (1 << i)];
            row += z >= 0 ? z : -z;
            ed[i] += U(z*z);
        }
        R = std::max(R,row);
    }
    U maxed = *std::max_element(ed.begin(), ed.end());
    return {16*A*A, U(R)*U(R)*U(N)*U(N)*U(N)*maxed, R, maxed};
}

// Independent representation for Boolean six-bit functions: bit-parallel flips
// and 3-bit full adders for the 64 pointwise sensitivities.
const U LOW[6]={0x5555555555555555ULL,0x3333333333333333ULL,
 0x0f0f0f0f0f0f0f0fULL,0x00ff00ff00ff00ffULL,
 0x0000ffff0000ffffULL,0x00000000ffffffffULL};

Quantities fast_boolean6(U f) {
    int p = __builtin_popcountll(f);
    U low=0, mid=0, high=0;
    U maxh=0;
    for (int i=0;i<6;++i) {
        int shift=1<<i;
        U flipped = ((f & LOW[i]) << shift) | ((f & ~LOW[i]) >> shift);
        U delta = f ^ flipped;
        maxh=std::max<U>(maxh,__builtin_popcountll(delta));
        U carry1=low&delta; low^=delta;
        U carry2=mid&carry1; mid^=carry1; high^=carry2;
    }
    // Each bit position of (high,mid,low) is the exact sensitivity at a vertex.
    int R=(high&mid)?6:(high&low)?5:high?4:(mid&low)?3:mid?2:low?1:0;
    U A=U(p)*U(64-p);
    return {16*A*A,U(R)*U(R)*U(64)*U(64)*U(64)*maxh,R,maxh};
}

std::vector<U> monotone_tables(int n) {
    std::vector<U> v={0,1};
    for (int k=0;k<n;++k) {
        const int span=1<<k;
        std::vector<U> next;
        for (U a:v) for (U b:v) if ((a & ~b)==0)
            next.push_back(a | (b<<span));
        v.swap(next);
    }
    return v;
}

void check_enumerations() {
    U bool_count=0, ternary_count=0, mon_count=0;
    U bool_eq=0, ternary_eq=0, mon_eq=0;
    for (U f=0;f<(U(1)<<16);++f) {
        if (f==0 || f==0xffff) continue;
        std::vector<int> table(16);
        for (int x=0;x<16;++x) table[x]=(f>>x)&1;
        Quantities q=direct_quantities(table,4);
        assert(q.numerator <= q.bound);
        bool_eq+=(q.numerator==q.bound);
        ++bool_count;
    }
    for (int code=0;code<6561;++code) {
        int rem=code;
        std::vector<int> table(8);
        for (int& x:table) {x=rem%3;rem/=3;}
        bool constant=std::all_of(table.begin()+1,table.end(),[&](int x){return x==table[0];});
        if (constant) continue;
        Quantities q=direct_quantities(table,3);
        assert(q.numerator <= q.bound);
        ternary_eq+=(q.numerator==q.bound);
        ++ternary_count;
    }
    assert(bool_count==65534 && ternary_count==6558);
    // Falsification guard: dictator attains the claimed constant 1/4 and
    // violates the strictly stronger constant 1/8.
    std::vector<int> dictator(8);
    for(int x=0;x<8;++x) dictator[x]=x&1;
    Quantities dc=direct_quantities(dictator,3);
    assert(dc.numerator==dc.bound && dc.numerator>dc.bound/2);
    std::mt19937_64 random(20261111);
    for (int t=0;t<1000;++t) {
        U f=random();
        std::vector<int> table(64);
        for (int x=0;x<64;++x) table[x]=(f>>x)&1;
        Quantities a=direct_quantities(table,6), b=fast_boolean6(f);
        assert(a.numerator==b.numerator && a.bound==b.bound && a.R==b.R
          && a.max_diff_sq_sum==b.max_diff_sq_sum);
    }
    auto m5=monotone_tables(5);
    assert(m5.size()==7581);
    for(U a:m5) for(U b:m5) if((a&~b)==0) {
        U f=a | (b<<32);
        ++mon_count;
        if(f==0 || f==~U(0)) continue;
        Quantities q=fast_boolean6(f);
        assert(q.numerator<=q.bound);
        mon_eq+=(q.numerator==q.bound);
    }
    assert(mon_count==7828354 && mon_eq==6);
    std::cout<<"boolean_4 nonconstant="<<bool_count<<" violations=0 equality="<<bool_eq<<"\n";
    std::cout<<"ternary_3 nonconstant="<<ternary_count<<" violations=0 equality="<<ternary_eq<<"\n";
    std::cout<<"monotone_boolean_6 total="<<mon_count<<" nonconstant="<<mon_count-2
             <<" violations=0 equality="<<mon_eq<<"\n";
    std::cout<<"randomized_representation_crosscheck=1000 PASS; dictator_negative_control PASS\n";
}

bool paired_block_family(U x,int m){
    // m blocks, each m disjoint bit pairs; a block accepts exactly when it
    // contains exactly one fully occupied pair and no other occupied bit.
    for(int j=0;j<m;++j){
        int ones=0,goodpairs=0;
        for(int p=0;p<m;++p){
            int a=(x>>(2*(m*j+p)))&1;
            int b=(x>>(2*(m*j+p)+1))&1;
            ones+=a+b; goodpairs+=(a&&b);
        }
        if(ones==2 && goodpairs==1) return true;
    }
    return false;
}

void check_separation(){
    for(int m=1;m<=3;++m){
        int n=2*m*m, R=0;
        for(U x=0;x<(U(1)<<n);++x){
            int row=0;
            bool value=paired_block_family(x,m);
            for(int i=0;i<n;++i)
                row+=(value != paired_block_family(x^(U(1)<<i),m));
            R=std::max(R,row);
        }
        assert(R==2*m);
        // At zero, flipping both bits in each of the m^2 disjoint pairs
        // changes the output. Consequently every fractional row at zero
        // has cost at least m^2 (sum pair constraints).
        assert(!paired_block_family(0,m));
        for(int p=0;p<m*m;++p)
            assert(paired_block_family(U(3)<<(2*p),m));
        std::cout<<"paired_block m="<<m<<" n="<<n<<" R="<<R
                 <<" fractional_cost_lower_bound="<<m*m<<" PASS\n";
    }
}

int main(){check_enumerations();check_separation();}
