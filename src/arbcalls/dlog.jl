###
### **dlog.h** -- discrete logarithms mod ulong primes
###

### Types, macros and constants

### Single evaluation
#ni arbcall"ulong dlog_once(ulong b, ulong a, const nmod_t mod, ulong n)"

### Precomputations
#ni arbcall"void dlog_precomp_n_init(dlog_precomp_t pre, ulong a, ulong mod, ulong n, ulong num)"
#ni arbcall"ulong dlog_precomp(const dlog_precomp_t pre, ulong b)"
#ni arbcall"void dlog_precomp_clear(dlog_precomp_t pre)"
#ni arbcall"void dlog_precomp_modpe_init(dlog_precomp_t pre, ulong a, ulong p, ulong e, ulong pe, ulong num)"
#ni arbcall"void dlog_precomp_p_init(dlog_precomp_t pre, ulong a, ulong mod, ulong p, ulong num)"
#ni arbcall"void dlog_precomp_pe_init(dlog_precomp_t pre, ulong a, ulong mod, ulong p, ulong e, ulong pe, ulong num)"
#ni arbcall"void dlog_precomp_small_init(dlog_precomp_t pre, ulong a, ulong mod, ulong n, ulong num)"

### Vector evaluations
arbcall"void dlog_vec_fill(ulong * v, ulong nv, ulong x)"
#ni arbcall"void dlog_vec_set_not_found(ulong * v, ulong nv, nmod_t mod)"
#ni arbcall"void dlog_vec(ulong * v, ulong nv, ulong a, ulong va, nmod_t mod, ulong na, nmod_t order)"
#ni arbcall"void dlog_vec_add(ulong * v, ulong nv, ulong a, ulong va, nmod_t mod, ulong na, nmod_t order)"
#ni arbcall"void dlog_vec_loop(ulong * v, ulong nv, ulong a, ulong va, nmod_t mod, ulong na, nmod_t order)"
#ni arbcall"void dlog_vec_loop_add(ulong * v, ulong nv, ulong a, ulong va, nmod_t mod, ulong na, nmod_t order)"
#ni arbcall"void dlog_vec_eratos(ulong * v, ulong nv, ulong a, ulong va, nmod_t mod, ulong na, nmod_t order)"
#ni arbcall"void dlog_vec_eratos_add(ulong * v, ulong nv, ulong a, ulong va, nmod_t mod, ulong na, nmod_t order)"
#ni arbcall"void dlog_vec_sieve_add(ulong * v, ulong nv, ulong a, ulong va, nmod_t mod, ulong na, nmod_t order)"
#ni arbcall"void dlog_vec_sieve(ulong * v, ulong nv, ulong a, ulong va, nmod_t mod, ulong na, nmod_t order)"

### Internal discrete logarithm strategies
#ni arbcall"ulong dlog_table_init(dlog_table_t t, ulong a, ulong mod)"
#ni arbcall"void dlog_table_clear(dlog_table_t t)"
#ni arbcall"ulong dlog_table(dlog_table_t t, ulong b)"
#ni arbcall"ulong dlog_bsgs_init(dlog_bsgs_t t, ulong a, ulong mod, ulong n, ulong m)"
#ni arbcall"void dlog_bsgs_clear(dlog_bsgs_t t)"
#ni arbcall"ulong dlog_bsgs(dlog_bsgs_t t, ulong b)"
#ni arbcall"ulong dlog_modpe_init(dlog_modpe_t t, ulong a, ulong p, ulong e, ulong pe, ulong num)"
#ni arbcall"void dlog_modpe_clear(dlog_modpe_t t)"
#ni arbcall"ulong dlog_modpe(dlog_modpe_t t, ulong b)"
#ni arbcall"ulong dlog_crt_init(dlog_crt_t t, ulong a, ulong mod, ulong n, ulong num)"
#ni arbcall"void dlog_crt_clear(dlog_crt_t t)"
#ni arbcall"ulong dlog_crt(dlog_crt_t t, ulong b)"
#ni arbcall"ulong dlog_power_init(dlog_power_t t, ulong a, ulong mod, ulong p, ulong e, ulong num)"
#ni arbcall"void dlog_power_clear(dlog_power_t t)"
#ni arbcall"ulong dlog_power(dlog_power_t t, ulong b)"
#ni arbcall"ulong dlog_rho_init(dlog_rho_t t, ulong a, ulong mod, ulong n, ulong num)"
#ni arbcall"void dlog_rho_clear(dlog_rho_t t)"
#ni arbcall"ulong dlog_rho(dlog_rho_t t, ulong b)"
