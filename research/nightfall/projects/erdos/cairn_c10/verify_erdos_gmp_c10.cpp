#include <gmpxx.h>
#include <vector>
#include <array>
#include <cstdint>
#include <iostream>
#include <fstream>
#include <string>
#include <stdexcept>
#include <algorithm>
#include <iterator>
#include <set>

constexpr size_t N=131072;
constexpr size_t W=20;
using Digit=std::array<unsigned char,W>;
static int cmp(const Digit &a, const Digit &b){ for(int j=int(W)-1;j>=0;--j){if(a[j]!=b[j])return a[j]>b[j]?1:-1;}return 0; }
static Digit read_digit(const std::vector<unsigned char>&blob, size_t j){ Digit d{}; std::copy_n(blob.begin()+j*W,W,d.begin()); return d; }
static mpz_class to_mpz(const Digit&d){mpz_class a;mpz_import(a.get_mpz_t(),1,-1,W,-1,0,d.data());return a;}
static mpz_class direct_shift(const std::vector<mpz_class>&a,const mpz_class&D,long lag){mpz_class s=0;for(long i=0;i<long(N);++i){long j=i-lag;if(j>=0&&j<long(N))s+=a[i]*(D-a[j]);}return s;}
int main(int argc,char**argv){
 if(argc!=2){std::cerr<<"usage: checker heights\n";return 2;}
 std::ifstream f(argv[1]);if(!f){std::cerr<<"input absent\n";return 2;}
 const mpz_class D=mpz_class(1)<<70; const mpz_class H=N/2; const mpz_class MAXCOEFF=mpz_class(N)*D*D;
 if(MAXCOEFF >=(mpz_class(1) << (8*W)))throw std::runtime_error("carry risk");
 std::vector<mpz_class>a; a.reserve(N); std::string token;mpz_class mass=0;
 while(f>>token){mpz_class x(token,10);if(x<0||x>D)throw std::runtime_error("bounds");a.push_back(x);mass+=x;}
 if(a.size()!=N||mass!=H*D)throw std::runtime_error("mass/count");
 std::vector<unsigned char>ab(W*N,0),bb(W*N,0);
 for(size_t i=0;i<N;++i){size_t count=0;mpz_export(ab.data()+W*i,&count,-1,W,-1,0,a[i].get_mpz_t());mpz_class v=D-a[N-1-i];count=0;mpz_export(bb.data()+W*i,&count,-1,W,-1,0,v.get_mpz_t());}
 mpz_class A,B;mpz_import(A.get_mpz_t(),N,-1,W,-1,0,ab.data());mpz_import(B.get_mpz_t(),N,-1,W,-1,0,bb.data());
 std::cerr<<"multiplying GMP integers of "<<mpz_sizeinbase(A.get_mpz_t(),2)<<" and "<<mpz_sizeinbase(B.get_mpz_t(),2)<<" bits...\n";
 mpz_class P=A*B;
 std::vector<unsigned char>coeff((2*N-1)*W,0);size_t used=0;mpz_export(coeff.data(),&used,-1,W,-1,0,P.get_mpz_t());
 if(used>2*N-1)throw std::runtime_error("coefficient overflow");
 Digit peak{},runner{}; long lag=-99999,runner_lag=-99999; size_t ties=0;
 for(size_t j=0;j<2*N-1;++j){Digit d=read_digit(coeff,j);int v=cmp(d,peak);long k=(long)j-(long)(N-1);
 if(v>0){runner=peak;runner_lag=lag;peak=d;lag=k;ties=1;}
 else if(v==0){ties++;}
 else if(cmp(d,runner)>0){runner=d;runner_lag=k;}
 }
 mpz_class pk=to_mpz(peak),run=to_mpz(runner);
 const mpz_class want_p("34788888032212764146872525963225147703298526879");
 const mpz_class want_q("91343852333181432387730302044767688728495783936");
 mpz_class denom=H*D*D;
 if(pk*want_q != want_p*denom || lag!=-17280||ties!=1)throw std::runtime_error("certificate mismatch");
 std::vector<long>check={-((long)N-1),-17280,-17281,-17279,0,36482,(long)N-1,237,-237};
 for(long k:check){long pos=k+(long)N-1;auto p=to_mpz(read_digit(coeff,(size_t)pos));auto d=direct_shift(a,D,k);if(p!=d)throw std::runtime_error("direct-sum mismatch at " +std::to_string(k));}
 std::cout<<"PASS\ncount="<<N<<"\nunit_mass="<<mass.get_str()<<"\nall_signed_lags="<<(2*N-1)
 <<"\\nmax_numerator="<<pk.get_str()<<"\\ndenominator="<<denom.get_str()<<"\\nunique_lag="<<lag<<"\\nrunner_numerator="<<run.get_str()<<"\\nrunner_lag="<<runner_lag<<"\\n";
}
