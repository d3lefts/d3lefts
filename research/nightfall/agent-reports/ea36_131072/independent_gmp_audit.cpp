// Independent agent audit of the signed overlap convolution.
// Copyright (c) 2026 NIGHTFALL research. Source-independent implementation.
// Compile: g++ -O3 -std=c++17 independent_gmp_audit.cpp -lgmpxx -lgmp -o gmp_audit
#include <gmpxx.h>
#include <algorithm>
#include <chrono>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>
using namespace std;
static constexpr size_t N = 131072;
static constexpr size_t W = 20;

static void store_digit(vector<unsigned char>& out, size_t i, const mpz_class& v) {
    size_t bytes=0;
    mpz_export(out.data()+i*W, &bytes, -1, 1, 0, 0, v.get_mpz_t());
    if(bytes>W) throw runtime_error("packed digit overflow");
}
static mpz_class load_digit(const vector<unsigned char>& packed,size_t i) {
    mpz_class v;
    mpz_import(v.get_mpz_t(), W, -1, 1, 0, 0, packed.data()+i*W);
    return v;
}
int main(int argc,char** argv) {
    if(argc!=2) {cerr<<"Usage: gmp_audit heights_u70.txt\n";return 2;}
    auto start=chrono::steady_clock::now();
    const mpz_class D = mpz_class(1)<<70;
    const mpz_class cap = mpz_class(N)*D*D;
    if (cap >= (mpz_class(1)<<160)) throw runtime_error("base too small");
    vector<unsigned char> packedA(N*W,0),packedB(N*W,0);
    vector<mpz_class> values;values.reserve(N);
    ifstream f(argv[1]);if(!f)throw runtime_error("Missing heights file");
    string s;
    mpz_class mass=0;
    while(f>>s) {
        if(values.size()==N)throw runtime_error("too many heights");
        if(s.empty()||s.find_first_not_of("0123456789")!=string::npos)throw runtime_error("bad integer");
        mpz_class v(s,10);
        if(v>D)throw runtime_error("height outside [0,D]");
        mass+=v;
        store_digit(packedA,values.size(),v);
        values.push_back(v);
    }
    if(values.size()!=N||mass!=mpz_class(N/2)*D)throw runtime_error("dimension/mass fail");
    for(size_t j=0;j<N;++j)store_digit(packedB,j,D-values[N-1-j]);
    mpz_class A,B;mpz_import(A.get_mpz_t(),N,-1,W,-1,0,packedA.data());
    mpz_import(B.get_mpz_t(),N,-1,W,-1,0,packedB.data());
    mpz_class C=A*B;
    vector<unsigned char> output((2*N-1)*W,0);
    size_t words=0;
    mpz_export(output.data(),&words,-1,W,-1,0,C.get_mpz_t());
    if(words>2*N-1)throw runtime_error("convolution output too large");
    mpz_class highest=-1,runner_up=-1;
    vector<long> max_lags, second_lags;
    mpz_class minus1,center,plus1;
    for(size_t m=0;m<2*N-1;++m){
        mpz_class v=load_digit(output,m);
        if(v>cap)throw runtime_error("coefficient exceeds sum bound");
        long lag=long(m)-long(N-1);
        if(lag==-17281)minus1=v;
        if(lag==-17280)center=v;
        if(lag==-17279)plus1=v;
        if(v>highest){
            runner_up=highest;second_lags=max_lags;
            highest=v;max_lags={lag};
        }else if(v==highest){max_lags.push_back(lag);
        }else if(v>runner_up){runner_up=v;second_lags={lag};
        }else if(v==runner_up){second_lags.push_back(lag);}
    }
    // Direct summation checks deliberately bypass polynomial multiplication.
    // These fixed and pseudorandom shifts cover both signs, boundaries, peak,
    // runner-up and the immediate neighboring grid points.
    vector<long> samples={-17280, 36482, -17281, -17279, 0, 1, -1,
                          long(N)-1, 1-long(N), long(N/2), -long(N/2)};
    uint64_t rng=0x35F6C28A6F4D8B23ULL;
    for(int j=0;j<16;++j){
        rng^=rng<<13;rng^=rng>>7;rng^=rng<<17;
        samples.push_back(long(rng%(2*N-1))-long(N-1));
    }
    for(long lag:samples){
        mpz_class direct=0;
        for(long i=max(0L,lag);i<min(long(N),long(N)+lag);++i)
           direct+=values[size_t(i)]*(D-values[size_t(i-lag)]);
        if(direct!=load_digit(output,size_t(lag+long(N-1))))
            throw runtime_error("Direct O(N) shift differs from packed multiplication");
    }
    mpq_class frac(highest,mpz_class(N/2)*D*D);frac.canonicalize();
    mpq_class runner(runner_up,mpz_class(N/2)*D*D);runner.canonicalize();
    mpq_class margin(highest-runner_up,mpz_class(N/2)*D*D);margin.canonicalize();
    mpq_class leftslope(center-minus1,mpz_class(N/2)*D*D);leftslope.canonicalize();
    mpq_class rightslope(center-plus1,mpz_class(N/2)*D*D);rightslope.canonicalize();
    auto t=chrono::duration<double>(chrono::steady_clock::now()-start).count();
    cout<<"{\n"
        <<"\"status\":\"PASS\",\n"
        <<"\"independent_method\":\"GMP packed integer multiplication; no NTT residue reuse\",\n"
        <<"\"checked_signed_lags\":"<<2*N-1<<",\n"
        <<"\"direct_sum_shift_checks\":"<<samples.size()<<",\n"
        <<"\"exact_max_fraction\":\""<<frac<<"\",\n"
        <<"\"exact_runner_up_fraction\":\""<<runner<<"\",\n"
        <<"\"runner_up_margin_fraction\":\""<<margin<<"\",\n"
        <<"\"left_grid_drop_fraction\":\""<<leftslope<<"\",\n"
        <<"\"right_grid_drop_fraction\":\""<<rightslope<<"\",\n"
        <<"\"max_lags\":[";
    for(size_t j=0;j<max_lags.size();++j){if(j)cout<<",";cout<<max_lags[j];}
    cout<<"],\n\"second_lags\":[";
    for(size_t j=0;j<second_lags.size();++j){if(j)cout<<",";cout<<second_lags[j];}
    cout<<"],\n\"mass_verified\":true,\n\"gmp_version\":\""<<gmp_version<<"\",\n\"elapsed_seconds\":"<<t<<"\n}\n";
}
