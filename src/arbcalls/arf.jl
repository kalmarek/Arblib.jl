###
### **arf.h** -- arbitrary-precision floating-point numbers
###

### Types, macros and constants

### Memory management
arbcall"void arf_init(arf_t x)"
arbcall"void arf_clear(arf_t x)"
arbcall"slong arf_allocated_bytes(const arf_t x)"

### Special values
arbcall"void arf_zero(arf_t res)"
arbcall"void arf_one(arf_t res)"
arbcall"void arf_pos_inf(arf_t res)"
arbcall"void arf_neg_inf(arf_t res)"
arbcall"void arf_nan(arf_t res)"
arbcall"int arf_is_zero(const arf_t x)"
arbcall"int arf_is_one(const arf_t x)"
arbcall"int arf_is_pos_inf(const arf_t x)"
arbcall"int arf_is_neg_inf(const arf_t x)"
arbcall"int arf_is_nan(const arf_t x)"
arbcall"int arf_is_inf(const arf_t x)"
arbcall"int arf_is_normal(const arf_t x)"
arbcall"int arf_is_special(const arf_t x)"
arbcall"int arf_is_finite(const arf_t x)"

### Assignment, rounding and conversions
arbcall"void arf_set(arf_t res, const arf_t x)"
arbcall"void arf_set_mpz(arf_t res, const mpz_t x)"
#ni arbcall"void arf_set_fmpz(arf_t res, const fmpz_t x)"
arbcall"void arf_set_ui(arf_t res, ulong x)"
arbcall"void arf_set_si(arf_t res, slong x)"
arbcall"void arf_set_mpfr(arf_t res, const mpfr_t x)"
#ns arbcall"void arf_set_fmpr(arf_t res, const fmpr_t x)"
arbcall"void arf_set_d(arf_t res, double x)"
arbcall"void arf_swap(arf_t x, arf_t y)"
arbcall"void arf_init_set_ui(arf_t res, ulong x)"
arbcall"void arf_init_set_si(arf_t res, slong x)"
arbcall"int arf_set_round(arf_t res, const arf_t x, slong prec, arf_rnd_t rnd)"
arbcall"int arf_set_round_si(arf_t res, slong x, slong prec, arf_rnd_t rnd)"
arbcall"int arf_set_round_ui(arf_t res, ulong x, slong prec, arf_rnd_t rnd)"
arbcall"int arf_set_round_mpz(arf_t res, const mpz_t x, slong prec, arf_rnd_t rnd)"
#ni arbcall"int arf_set_round_fmpz(arf_t res, const fmpz_t x, slong prec, arf_rnd_t rnd)"
arbcall"void arf_set_si_2exp_si(arf_t res, slong m, slong e)"
arbcall"void arf_set_ui_2exp_si(arf_t res, ulong m, slong e)"
#ni arbcall"void arf_set_fmpz_2exp(arf_t res, const fmpz_t m, const fmpz_t e)"
#ni arbcall"int arf_set_round_fmpz_2exp(arf_t res, const fmpz_t x, const fmpz_t e, slong prec, arf_rnd_t rnd)"
#ni arbcall"void arf_get_fmpz_2exp(fmpz_t m, fmpz_t e, const arf_t x)"
#ni arbcall"void arf_frexp(arf_t m, fmpz_t e, const arf_t x)"
#mo arbcall"double arf_get_d(const arf_t x, arf_rnd_t rnd)" # clashes with arf_get_si
#ns arbcall"void arf_get_fmpr(fmpr_t res, const arf_t x)"
arbcall"int arf_get_mpfr(mpfr_t res, const arf_t x, mpfr_rnd_t rnd)"
#ni arbcall"int arf_get_fmpz(fmpz_t res, const arf_t x, arf_rnd_t rnd)"
#mo arbcall"slong arf_get_si(const arf_t x, arf_rnd_t rnd)" # clashes with arf_get_d
#ni arbcall"int arf_get_fmpz_fixed_fmpz(fmpz_t res, const arf_t x, const fmpz_t e)"
#ni arbcall"int arf_get_fmpz_fixed_si(fmpz_t res, const arf_t x, slong e)"
arbcall"void arf_floor(arf_t res, const arf_t x)"
arbcall"void arf_ceil(arf_t res, const arf_t x)"
#ni arbcall"void arf_get_fmpq(fmpq_t res, const arf_t x)"

### Comparisons and bounds
arbcall"int arf_equal(const arf_t x, const arf_t y)"
arbcall"int arf_equal_si(const arf_t x, slong y)"
arbcall"int arf_cmp(const arf_t x, const arf_t y)"
arbcall"int arf_cmp_si(const arf_t x, slong y)"
arbcall"int arf_cmp_ui(const arf_t x, ulong y)"
arbcall"int arf_cmp_d(const arf_t x, double y)"
arbcall"int arf_cmpabs(const arf_t x, const arf_t y)"
arbcall"int arf_cmpabs_ui(const arf_t x, ulong y)"
arbcall"int arf_cmpabs_d(const arf_t x, double y)"
arbcall"int arf_cmpabs_mag(const arf_t x, const mag_t y)"
arbcall"int arf_cmp_2exp_si(const arf_t x, slong e)"
arbcall"int arf_cmpabs_2exp_si(const arf_t x, slong e)"
arbcall"int arf_sgn(const arf_t x)"
arbcall"void arf_min(arf_t res, const arf_t a, const arf_t b)"
arbcall"void arf_max(arf_t res, const arf_t a, const arf_t b)"
arbcall"slong arf_bits(const arf_t x)"
arbcall"int arf_is_int(const arf_t x)"
arbcall"int arf_is_int_2exp_si(const arf_t x, slong e)"
#ni arbcall"void arf_abs_bound_lt_2exp_fmpz(fmpz_t res, const arf_t x)"
#ni arbcall"void arf_abs_bound_le_2exp_fmpz(fmpz_t res, const arf_t x)"
arbcall"slong arf_abs_bound_lt_2exp_si(const arf_t x)"

### Magnitude functions
arbcall"void arf_get_mag(mag_t res, const arf_t x)"
arbcall"void arf_get_mag_lower(mag_t res, const arf_t x)"
arbcall"void arf_set_mag(arf_t res, const mag_t x)"
arbcall"void mag_init_set_arf(mag_t res, const arf_t x)"
arbcall"void mag_fast_init_set_arf(mag_t res, const arf_t x)"
arbcall"void arf_mag_set_ulp(mag_t res, const arf_t x, slong prec)"
arbcall"void arf_mag_add_ulp(mag_t res, const mag_t x, const arf_t y, slong prec)"
arbcall"void arf_mag_fast_add_ulp(mag_t res, const mag_t x, const arf_t y, slong prec)"

### Shallow assignment
arbcall"void arf_init_set_shallow(arf_t z, const arf_t x)"
arbcall"void arf_init_set_mag_shallow(arf_t z, const mag_t x)"
arbcall"void arf_init_neg_shallow(arf_t z, const arf_t x)"
arbcall"void arf_init_neg_mag_shallow(arf_t z, const mag_t x)"

### Random number generation
#ns arbcall"void arf_randtest(arf_t res, flint_rand_t state, slong bits, slong mag_bits)"
#ns arbcall"void arf_randtest_not_zero(arf_t res, flint_rand_t state, slong bits, slong mag_bits)"
#ns arbcall"void arf_randtest_special(arf_t res, flint_rand_t state, slong bits, slong mag_bits)"

### Input and output
arbcall"void arf_debug(const arf_t x)"
#mo arbcall"void arf_print(const arf_t x)" # clashes with Base.print
arbcall"void arf_printd(const arf_t x, slong d)"
#ns arbcall"void arf_fprint(FILE * file, const arf_t x)"
#ns arbcall"void arf_fprintd(FILE * file, const arf_t y, slong d)"
arbcall"char * arf_dump_str(const arf_t x)"
arbcall"int arf_load_str(arf_t x, const char * str)"
#ns arbcall"int arf_dump_file(FILE * stream, const arf_t x)"
#ns arbcall"int arf_load_file(arf_t x, FILE * stream)"

### Addition and multiplication
arbcall"void arf_abs(arf_t res, const arf_t x)"
arbcall"void arf_neg(arf_t res, const arf_t x)"
arbcall"int arf_neg_round(arf_t res, const arf_t x, slong prec, arf_rnd_t rnd)"
arbcall"int arf_add(arf_t res, const arf_t x, const arf_t y, slong prec, arf_rnd_t rnd)"
arbcall"int arf_add_si(arf_t res, const arf_t x, slong y, slong prec, arf_rnd_t rnd)"
arbcall"int arf_add_ui(arf_t res, const arf_t x, ulong y, slong prec, arf_rnd_t rnd)"
#ni arbcall"int arf_add_fmpz(arf_t res, const arf_t x, const fmpz_t y, slong prec, arf_rnd_t rnd)"
#ni arbcall"int arf_add_fmpz_2exp(arf_t res, const arf_t x, const fmpz_t y, const fmpz_t e, slong prec, arf_rnd_t rnd)"
arbcall"int arf_sub(arf_t res, const arf_t x, const arf_t y, slong prec, arf_rnd_t rnd)"
arbcall"int arf_sub_si(arf_t res, const arf_t x, slong y, slong prec, arf_rnd_t rnd)"
arbcall"int arf_sub_ui(arf_t res, const arf_t x, ulong y, slong prec, arf_rnd_t rnd)"
#ni arbcall"int arf_sub_fmpz(arf_t res, const arf_t x, const fmpz_t y, slong prec, arf_rnd_t rnd)"
arbcall"void arf_mul_2exp_si(arf_t res, const arf_t x, slong e)"
#ni arbcall"void arf_mul_2exp_fmpz(arf_t res, const arf_t x, const fmpz_t e)"
#mo arbcall"int arf_mul(arf_t res, const arf_t x, const arf_t y, slong prec, arf_rnd_t rnd)" # defined using #DEFINE in C which doesn't work in Julia
arbcall"int arf_mul_ui(arf_t res, const arf_t x, ulong y, slong prec, arf_rnd_t rnd)"
arbcall"int arf_mul_si(arf_t res, const arf_t x, slong y, slong prec, arf_rnd_t rnd)"
arbcall"int arf_mul_mpz(arf_t res, const arf_t x, const mpz_t y, slong prec, arf_rnd_t rnd)"
#ni arbcall"int arf_mul_fmpz(arf_t res, const arf_t x, const fmpz_t y, slong prec, arf_rnd_t rnd)"
arbcall"int arf_addmul(arf_t z, const arf_t x, const arf_t y, slong prec, arf_rnd_t rnd)"
arbcall"int arf_addmul_ui(arf_t z, const arf_t x, ulong y, slong prec, arf_rnd_t rnd)"
arbcall"int arf_addmul_si(arf_t z, const arf_t x, slong y, slong prec, arf_rnd_t rnd)"
arbcall"int arf_addmul_mpz(arf_t z, const arf_t x, const mpz_t y, slong prec, arf_rnd_t rnd)"
#ni arbcall"int arf_addmul_fmpz(arf_t z, const arf_t x, const fmpz_t y, slong prec, arf_rnd_t rnd)"
arbcall"int arf_submul(arf_t z, const arf_t x, const arf_t y, slong prec, arf_rnd_t rnd)"
arbcall"int arf_submul_ui(arf_t z, const arf_t x, ulong y, slong prec, arf_rnd_t rnd)"
arbcall"int arf_submul_si(arf_t z, const arf_t x, slong y, slong prec, arf_rnd_t rnd)"
arbcall"int arf_submul_mpz(arf_t z, const arf_t x, const mpz_t y, slong prec, arf_rnd_t rnd)"
#ni arbcall"int arf_submul_fmpz(arf_t z, const arf_t x, const fmpz_t y, slong prec, arf_rnd_t rnd)"
arbcall"int arf_sosq(arf_t res, const arf_t x, const arf_t y, slong prec, arf_rnd_t rnd)"

### Summation
#ni arbcall"int arf_sum(arf_t res, arf_srcptr terms, slong len, slong prec, arf_rnd_t rnd)"

### Division
arbcall"int arf_div(arf_t res, const arf_t x, const arf_t y, slong prec, arf_rnd_t rnd)"
arbcall"int arf_div_ui(arf_t res, const arf_t x, ulong y, slong prec, arf_rnd_t rnd)"
arbcall"int arf_ui_div(arf_t res, ulong x, const arf_t y, slong prec, arf_rnd_t rnd)"
arbcall"int arf_div_si(arf_t res, const arf_t x, slong y, slong prec, arf_rnd_t rnd)"
arbcall"int arf_si_div(arf_t res, slong x, const arf_t y, slong prec, arf_rnd_t rnd)"
#ni arbcall"int arf_div_fmpz(arf_t res, const arf_t x, const fmpz_t y, slong prec, arf_rnd_t rnd)"
#ni arbcall"int arf_fmpz_div(arf_t res, const fmpz_t x, const arf_t y, slong prec, arf_rnd_t rnd)"
#ni arbcall"int arf_fmpz_div_fmpz(arf_t res, const fmpz_t x, const fmpz_t y, slong prec, arf_rnd_t rnd)"

### Square roots
arbcall"int arf_sqrt(arf_t res, const arf_t x, slong prec, arf_rnd_t rnd)"
arbcall"int arf_sqrt_ui(arf_t res, ulong x, slong prec, arf_rnd_t rnd)"
#ni arbcall"int arf_sqrt_fmpz(arf_t res, const fmpz_t x, slong prec, arf_rnd_t rnd)"
arbcall"int arf_rsqrt(arf_t res, const arf_t x, slong prec, arf_rnd_t rnd)"
arbcall"int arf_root(arf_t res, const arf_t x, ulong k, slong prec, arf_rnd_t rnd)"

### Complex arithmetic
arbcall"int arf_complex_mul(arf_t e, arf_t f, const arf_t a, const arf_t b, const arf_t c, const arf_t d, slong prec, arf_rnd_t rnd)"
arbcall"int arf_complex_mul_fallback(arf_t e, arf_t f, const arf_t a, const arf_t b, const arf_t c, const arf_t d, slong prec, arf_rnd_t rnd)"
arbcall"int arf_complex_sqr(arf_t e, arf_t f, const arf_t a, const arf_t b, slong prec, arf_rnd_t rnd)"

### Low-level methods
#ni arbcall"int _arf_get_integer_mpn(mp_ptr y, mp_srcptr xp, mp_size_t xn, slong exp)"
#ni arbcall"int _arf_set_mpn_fixed(arf_t z, mp_srcptr xp, mp_size_t xn, mp_size_t fixn, int negative, slong prec, arf_rnd_t rnd)"
arbcall"int _arf_set_round_ui(arf_t z, ulong x, int sgnbit, slong prec, arf_rnd_t rnd)"
#ni arbcall"int _arf_set_round_uiui(arf_t z, slong * fix, mp_limb_t hi, mp_limb_t lo, int sgnbit, slong prec, arf_rnd_t rnd)"
#ni arbcall"int _arf_set_round_mpn(arf_t z, slong * exp_shift, mp_srcptr x, mp_size_t xn, int sgnbit, slong prec, arf_rnd_t rnd)"
