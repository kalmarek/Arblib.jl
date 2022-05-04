###
### **bernoulli.h** -- support for Bernoulli numbers
###

### Generation of Bernoulli numbers
#ni arbcall"void bernoulli_rev_init(bernoulli_rev_t iter, ulong n)"
#ni arbcall"void bernoulli_rev_next(fmpz_t numer, fmpz_t denom, bernoulli_rev_t iter)"
#ni arbcall"void bernoulli_rev_clear(bernoulli_rev_t iter)"

### Caching
arbcall"void bernoulli_cache_compute(slong n)"

### Bounding
arbcall"slong bernoulli_bound_2exp_si(ulong n)"

### Isolated Bernoulli numbers
arbcall"ulong bernoulli_mod_p_harvey(ulong n, ulong p)"
#ni arbcall"void _bernoulli_fmpq_ui_zeta(fmpz_t num, fmpz_t den, ulong n)"
#ni arbcall"void _bernoulli_fmpq_ui_multi_mod(fmpz_t num, fmpz_t den, ulong n, double alpha)"
#ni arbcall"void _bernoulli_fmpq_ui(fmpz_t num, fmpz_t den, ulong n)"
#ni arbcall"void bernoulli_fmpq_ui(fmpq_t b, ulong n)"
