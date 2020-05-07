###
### **mag.h** -- fixed-precision unsigned floating-point numbers for bounds
###

### Types, macros and constants

### Memory management
arbcall"void mag_init(mag_t x)"
arbcall"void mag_clear(mag_t x)"
arbcall"void mag_swap(mag_t x, mag_t y)"
#arbcall"mag_ptr _mag_vec_init(slong n)"
#arbcall"void _mag_vec_clear(mag_ptr v, slong n)"
arbcall"slong mag_allocated_bytes(const mag_t x)"

### Special values
arbcall"void mag_zero(mag_t res)"
arbcall"void mag_one(mag_t res)"
arbcall"void mag_inf(mag_t res)"
arbcall"int mag_is_special(const mag_t x)"
arbcall"int mag_is_zero(const mag_t x)"
arbcall"int mag_is_inf(const mag_t x)"
arbcall"int mag_is_finite(const mag_t x)"

### Assignment and conversions
arbcall"void mag_init_set(mag_t res, const mag_t x)"
arbcall"void mag_set(mag_t res, const mag_t x)"
arbcall"void mag_set_d(mag_t res, double x)"
#arbcall"void mag_set_fmpr(mag_t res, const fmpr_t x)"
arbcall"void mag_set_ui(mag_t res, ulong x)"
#arbcall"void mag_set_fmpz(mag_t res, const fmpz_t x)"
arbcall"void mag_set_d_lower(mag_t res, double x)"
arbcall"void mag_set_ui_lower(mag_t res, ulong x)"
#arbcall"void mag_set_fmpz_lower(mag_t res, const fmpz_t x)"
#arbcall"void mag_set_d_2exp_fmpz(mag_t res, double x, const fmpz_t y)"
#arbcall"void mag_set_fmpz_2exp_fmpz(mag_t res, const fmpz_t x, const fmpz_t y)"
arbcall"void mag_set_ui_2exp_si(mag_t res, ulong x, slong y)"
#arbcall"void mag_set_d_2exp_fmpz_lower(mag_t res, double x, const fmpz_t y)"
#arbcall"void mag_set_fmpz_2exp_fmpz_lower(mag_t res, const fmpz_t x, const fmpz_t y)"
arbcall"double mag_get_d(const mag_t x)"
arbcall"double mag_get_d_log2_approx(const mag_t x)"
#arbcall"void mag_get_fmpr(fmpr_t res, const mag_t x)"
#arbcall"void mag_get_fmpq(fmpq_t res, const mag_t x)"
#arbcall"void mag_get_fmpz(fmpz_t res, const mag_t x)"
#arbcall"void mag_get_fmpz_lower(fmpz_t res, const mag_t x)"

### Comparisons
arbcall"int mag_equal(const mag_t x, const mag_t y)"
arbcall"int mag_cmp(const mag_t x, const mag_t y)"
arbcall"int mag_cmp_2exp_si(const mag_t x, slong y)"
arbcall"void mag_min(mag_t res, const mag_t x, const mag_t y)"
arbcall"void mag_max(mag_t res, const mag_t x, const mag_t y)"

### Input and output
arbcall"void mag_print(const mag_t x)"
#arbcall"void mag_fprint(FILE * file, const mag_t x)"
arbcall"char * mag_dump_str(const mag_t x)"
arbcall"int mag_load_str(mag_t x, const char * str)"
#arbcall"int mag_dump_file(FILE * stream, const mag_t x)"
#arbcall"int mag_load_file(mag_t x, FILE * stream)"

### Random generation
#arbcall"void mag_randtest(mag_t res, flint_rand_t state, slong expbits)"
#arbcall"void mag_randtest_special(mag_t res, flint_rand_t state, slong expbits)"

### Arithmetic
arbcall"void mag_add(mag_t res, const mag_t x, const mag_t y)"
arbcall"void mag_add_ui(mag_t res, const mag_t x, ulong y)"
arbcall"void mag_add_lower(mag_t res, const mag_t x, const mag_t y)"
arbcall"void mag_add_ui_lower(mag_t res, const mag_t x, ulong y)"
#arbcall"void mag_add_2exp_fmpz(mag_t res, const mag_t x, const fmpz_t e)"
arbcall"void mag_add_ui_2exp_si(mag_t res, const mag_t x, ulong y, slong e)"
arbcall"void mag_sub(mag_t res, const mag_t x, const mag_t y)"
arbcall"void mag_sub_lower(mag_t res, const mag_t x, const mag_t y)"
arbcall"void mag_mul_2exp_si(mag_t res, const mag_t x, slong y)"
#arbcall"void mag_mul_2exp_fmpz(mag_t res, const mag_t x, const fmpz_t y)"
arbcall"void mag_mul(mag_t res, const mag_t x, const mag_t y)"
arbcall"void mag_mul_ui(mag_t res, const mag_t x, ulong y)"
#arbcall"void mag_mul_fmpz(mag_t res, const mag_t x, const fmpz_t y)"
arbcall"void mag_mul_lower(mag_t res, const mag_t x, const mag_t y)"
arbcall"void mag_mul_ui_lower(mag_t res, const mag_t x, ulong y)"
#arbcall"void mag_mul_fmpz_lower(mag_t res, const mag_t x, const fmpz_t y)"
arbcall"void mag_addmul(mag_t z, const mag_t x, const mag_t y)"
arbcall"void mag_div(mag_t res, const mag_t x, const mag_t y)"
arbcall"void mag_div_ui(mag_t res, const mag_t x, ulong y)"
#arbcall"void mag_div_fmpz(mag_t res, const mag_t x, const fmpz_t y)"
arbcall"void mag_div_lower(mag_t res, const mag_t x, const mag_t y)"
arbcall"void mag_inv(mag_t res, const mag_t x)"
arbcall"void mag_inv_lower(mag_t res, const mag_t x)"

### Fast, unsafe arithmetic
arbcall"void mag_fast_init_set(mag_t x, const mag_t y)"
arbcall"void mag_fast_zero(mag_t res)"
arbcall"int mag_fast_is_zero(const mag_t x)"
arbcall"void mag_fast_mul(mag_t res, const mag_t x, const mag_t y)"
arbcall"void mag_fast_addmul(mag_t z, const mag_t x, const mag_t y)"
arbcall"void mag_fast_add_2exp_si(mag_t res, const mag_t x, slong e)"
arbcall"void mag_fast_mul_2exp_si(mag_t res, const mag_t x, slong e)"

### Powers and logarithms
arbcall"void mag_pow_ui(mag_t res, const mag_t x, ulong e)"
#arbcall"void mag_pow_fmpz(mag_t res, const mag_t x, const fmpz_t e)"
arbcall"void mag_pow_ui_lower(mag_t res, const mag_t x, ulong e)"
#arbcall"void mag_pow_fmpz_lower(mag_t res, const mag_t x, const fmpz_t e)"
arbcall"void mag_sqrt(mag_t res, const mag_t x)"
arbcall"void mag_sqrt_lower(mag_t res, const mag_t x)"
arbcall"void mag_rsqrt(mag_t res, const mag_t x)"
arbcall"void mag_rsqrt_lower(mag_t res, const mag_t x)"
arbcall"void mag_hypot(mag_t res, const mag_t x, const mag_t y)"
arbcall"void mag_root(mag_t res, const mag_t x, ulong n)"
arbcall"void mag_log(mag_t res, const mag_t x)"
arbcall"void mag_log_lower(mag_t res, const mag_t x)"
arbcall"void mag_neg_log(mag_t res, const mag_t x)"
arbcall"void mag_neg_log_lower(mag_t res, const mag_t x)"
arbcall"void mag_log_ui(mag_t res, ulong n)"
arbcall"void mag_log1p(mag_t res, const mag_t x)"
arbcall"void mag_exp(mag_t res, const mag_t x)"
arbcall"void mag_exp_lower(mag_t res, const mag_t x)"
arbcall"void mag_expinv(mag_t res, const mag_t x)"
arbcall"void mag_expinv_lower(mag_t res, const mag_t x)"
arbcall"void mag_expm1(mag_t res, const mag_t x)"
arbcall"void mag_exp_tail(mag_t res, const mag_t x, ulong N)"
arbcall"void mag_binpow_uiui(mag_t res, ulong m, ulong n)"
arbcall"void mag_geom_series(mag_t res, const mag_t x, ulong N)"

### Special functions
arbcall"void mag_const_pi(mag_t res)"
arbcall"void mag_const_pi_lower(mag_t res)"
arbcall"void mag_atan(mag_t res, const mag_t x)"
arbcall"void mag_atan_lower(mag_t res, const mag_t x)"
arbcall"void mag_cosh(mag_t res, const mag_t x)"
arbcall"void mag_cosh_lower(mag_t res, const mag_t x)"
arbcall"void mag_sinh(mag_t res, const mag_t x)"
arbcall"void mag_sinh_lower(mag_t res, const mag_t x)"
arbcall"void mag_fac_ui(mag_t res, ulong n)"
arbcall"void mag_rfac_ui(mag_t res, ulong n)"
arbcall"void mag_bin_uiui(mag_t res, ulong n, ulong k)"
arbcall"void mag_bernoulli_div_fac_ui(mag_t res, ulong n)"
arbcall"void mag_polylog_tail(mag_t res, const mag_t z, slong s, ulong d, ulong N)"
arbcall"void mag_hurwitz_zeta_uiui(mag_t res, ulong s, ulong a)"
