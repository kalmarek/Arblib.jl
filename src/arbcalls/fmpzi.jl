###
### **fmpzi.h** -- Gaussian integers
###

### Types, macros and constants

### Basic manipulation
#ni arbcall"void fmpzi_init(fmpzi_t x)"
#ni arbcall"void fmpzi_clear(fmpzi_t x)"
#ni arbcall"int fmpzi_equal(const fmpzi_t x, const fmpzi_t y)"
#ni arbcall"void fmpzi_zero(fmpzi_t x)"
#ni arbcall"void fmpzi_one(fmpzi_t x)"
#ni arbcall"void fmpzi_set(fmpzi_t res, const fmpzi_t x)"
#ni arbcall"void fmpzi_set_si_si(fmpzi_t res, slong a, slong b)"
#ni arbcall"void fmpzi_swap(fmpzi_t x, fmpzi_t y)"
#ni arbcall"void fmpzi_print(const fmpzi_t x)"
#ni arbcall"void fmpzi_randtest(fmpzi_t res, flint_rand_t state, mp_bitcnt_t bits)"

### Arithmetic
#ni arbcall"void fmpzi_conj(fmpzi_t res, const fmpzi_t x)"
#ni arbcall"void fmpzi_neg(fmpzi_t res, const fmpzi_t x)"
#ni arbcall"void fmpzi_add(fmpzi_t res, const fmpzi_t x, const fmpzi_t y)"
#ni arbcall"void fmpzi_sub(fmpzi_t res, const fmpzi_t x, const fmpzi_t y)"
#ni arbcall"void fmpzi_sqr(fmpzi_t res, const fmpzi_t x)"
#ni arbcall"void fmpzi_mul(fmpzi_t res, const fmpzi_t x, const fmpzi_t y)"
#ni arbcall"void fmpzi_pow_ui(fmpzi_t res, const fmpzi_t x, ulong exp)"
