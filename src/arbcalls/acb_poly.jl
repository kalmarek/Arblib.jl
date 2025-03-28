###
### **acb_poly.h** -- polynomials over the complex numbers
###

### Types, macros and constants

### Memory management
arbcall"void acb_poly_init(acb_poly_t poly)"
arbcall"void acb_poly_clear(acb_poly_t poly)"
arbcall"void acb_poly_fit_length(acb_poly_t poly, slong len)"
arbcall"void _acb_poly_set_length(acb_poly_t poly, slong len)"
arbcall"void _acb_poly_normalise(acb_poly_t poly)"
arbcall"void acb_poly_swap(acb_poly_t poly1, acb_poly_t poly2)"
arbcall"slong acb_poly_allocated_bytes(const acb_poly_t x)"

### Basic properties and manipulation
#mo arbcall"slong acb_poly_length(const acb_poly_t poly)" # clashes with Base.length
arbcall"slong acb_poly_degree(const acb_poly_t poly)"
arbcall"int acb_poly_is_zero(const acb_poly_t poly)"
arbcall"int acb_poly_is_one(const acb_poly_t poly)"
arbcall"int acb_poly_is_x(const acb_poly_t poly)"
arbcall"void acb_poly_zero(acb_poly_t poly)"
arbcall"void acb_poly_one(acb_poly_t poly)"
arbcall"void acb_poly_set(acb_poly_t dest, const acb_poly_t src)"
arbcall"void acb_poly_set_round(acb_poly_t dest, const acb_poly_t src, slong prec)"
arbcall"void acb_poly_set_trunc(acb_poly_t dest, const acb_poly_t src, slong n)"
arbcall"void acb_poly_set_trunc_round(acb_poly_t dest, const acb_poly_t src, slong n, slong prec)"
arbcall"void acb_poly_set_coeff_si(acb_poly_t poly, slong n, slong c)"
arbcall"void acb_poly_set_coeff_acb(acb_poly_t poly, slong n, const acb_t c)"
arbcall"void acb_poly_get_coeff_acb(acb_t v, const acb_poly_t poly, slong n)"
arbcall"void _acb_poly_shift_right(acb_ptr res, acb_srcptr poly, slong len, slong n)"
arbcall"void acb_poly_shift_right(acb_poly_t res, const acb_poly_t poly, slong n)"
arbcall"void _acb_poly_shift_left(acb_ptr res, acb_srcptr poly, slong len, slong n)"
arbcall"void acb_poly_shift_left(acb_poly_t res, const acb_poly_t poly, slong n)"
arbcall"void acb_poly_truncate(acb_poly_t poly, slong n)"
arbcall"slong acb_poly_valuation(const acb_poly_t poly)"

### Input and output
arbcall"void acb_poly_printd(const acb_poly_t poly, slong digits)"
#ns arbcall"void acb_poly_fprintd(FILE * file, const acb_poly_t poly, slong digits)"

### Random generation
#ns arbcall"void acb_poly_randtest(acb_poly_t poly, flint_rand_t state, slong len, slong prec, slong mag_bits)"

### Comparisons
arbcall"int acb_poly_equal(const acb_poly_t A, const acb_poly_t B)"
arbcall"int acb_poly_contains(const acb_poly_t poly1, const acb_poly_t poly2)"
#ni arbcall"int acb_poly_contains_fmpz_poly(const acb_poly_t poly1, const fmpz_poly_t poly2)"
#ni arbcall"int acb_poly_contains_fmpq_poly(const acb_poly_t poly1, const fmpq_poly_t poly2)"
arbcall"int _acb_poly_overlaps(acb_srcptr poly1, slong len1, acb_srcptr poly2, slong len2)"
arbcall"int acb_poly_overlaps(const acb_poly_t poly1, const acb_poly_t poly2)"
#ni arbcall"int acb_poly_get_unique_fmpz_poly(fmpz_poly_t z, const acb_poly_t x)"
arbcall"int acb_poly_is_real(const acb_poly_t poly)"

### Conversions
#ni arbcall"void acb_poly_set_fmpz_poly(acb_poly_t poly, const fmpz_poly_t re, slong prec)"
#ni arbcall"void acb_poly_set2_fmpz_poly(acb_poly_t poly, const fmpz_poly_t re, const fmpz_poly_t im, slong prec)"
arbcall"void acb_poly_set_arb_poly(acb_poly_t poly, const arb_poly_t re)"
arbcall"void acb_poly_set2_arb_poly(acb_poly_t poly, const arb_poly_t re, const arb_poly_t im)"
#ni arbcall"void acb_poly_set_fmpq_poly(acb_poly_t poly, const fmpq_poly_t re, slong prec)"
#ni arbcall"void acb_poly_set2_fmpq_poly(acb_poly_t poly, const fmpq_poly_t re, const fmpq_poly_t im, slong prec)"
arbcall"void acb_poly_set_acb(acb_poly_t poly, const acb_t src)"
arbcall"void acb_poly_set_si(acb_poly_t poly, slong src)"

### Bounds
arbcall"void _acb_poly_majorant(arb_ptr res, acb_srcptr poly, slong len, slong prec)"
arbcall"void acb_poly_majorant(arb_poly_t res, const acb_poly_t poly, slong prec)"

### Arithmetic
#mo arbcall"void _acb_poly_add(acb_ptr C, acb_srcptr A, slong lenA, acb_srcptr B, slong lenB, slong prec)" # clashes with _acb_vec_add
arbcall"void acb_poly_add(acb_poly_t C, const acb_poly_t A, const acb_poly_t B, slong prec)"
arbcall"void acb_poly_add_si(acb_poly_t C, const acb_poly_t A, slong B, slong prec)"
#mo arbcall"void _acb_poly_sub(acb_ptr C, acb_srcptr A, slong lenA, acb_srcptr B, slong lenB, slong prec)" # clashes with _acb_vec_sub
arbcall"void acb_poly_sub(acb_poly_t C, const acb_poly_t A, const acb_poly_t B, slong prec)"
arbcall"void acb_poly_add_series(acb_poly_t C, const acb_poly_t A, const acb_poly_t B, slong len, slong prec)"
arbcall"void acb_poly_sub_series(acb_poly_t C, const acb_poly_t A, const acb_poly_t B, slong len, slong prec)"
arbcall"void acb_poly_neg(acb_poly_t C, const acb_poly_t A)"
arbcall"void acb_poly_scalar_mul_2exp_si(acb_poly_t C, const acb_poly_t A, slong c)"
arbcall"void acb_poly_scalar_mul(acb_poly_t C, const acb_poly_t A, const acb_t c, slong prec)"
arbcall"void acb_poly_scalar_div(acb_poly_t C, const acb_poly_t A, const acb_t c, slong prec)"
arbcall"void _acb_poly_mullow_classical(acb_ptr C, acb_srcptr A, slong lenA, acb_srcptr B, slong lenB, slong n, slong prec)"
arbcall"void _acb_poly_mullow_transpose(acb_ptr C, acb_srcptr A, slong lenA, acb_srcptr B, slong lenB, slong n, slong prec)"
arbcall"void _acb_poly_mullow_transpose_gauss(acb_ptr C, acb_srcptr A, slong lenA, acb_srcptr B, slong lenB, slong n, slong prec)"
arbcall"void _acb_poly_mullow(acb_ptr C, acb_srcptr A, slong lenA, acb_srcptr B, slong lenB, slong n, slong prec)"
arbcall"void acb_poly_mullow_classical(acb_poly_t C, const acb_poly_t A, const acb_poly_t B, slong n, slong prec)"
arbcall"void acb_poly_mullow_transpose(acb_poly_t C, const acb_poly_t A, const acb_poly_t B, slong n, slong prec)"
arbcall"void acb_poly_mullow_transpose_gauss(acb_poly_t C, const acb_poly_t A, const acb_poly_t B, slong n, slong prec)"
arbcall"void acb_poly_mullow(acb_poly_t C, const acb_poly_t A, const acb_poly_t B, slong n, slong prec)"
arbcall"void _acb_poly_mul(acb_ptr C, acb_srcptr A, slong lenA, acb_srcptr B, slong lenB, slong prec)"
arbcall"void acb_poly_mul(acb_poly_t C, const acb_poly_t A1, const acb_poly_t B2, slong prec)"
arbcall"void _acb_poly_inv_series(acb_ptr Qinv, acb_srcptr Q, slong Qlen, slong len, slong prec)"
arbcall"void acb_poly_inv_series(acb_poly_t Qinv, const acb_poly_t Q, slong n, slong prec)"
arbcall"void _acb_poly_div_series(acb_ptr Q, acb_srcptr A, slong Alen, acb_srcptr B, slong Blen, slong n, slong prec)"
arbcall"void acb_poly_div_series(acb_poly_t Q, const acb_poly_t A, const acb_poly_t B, slong n, slong prec)"
arbcall"void _acb_poly_div(acb_ptr Q, acb_srcptr A, slong lenA, acb_srcptr B, slong lenB, slong prec)"
arbcall"void _acb_poly_rem(acb_ptr R, acb_srcptr A, slong lenA, acb_srcptr B, slong lenB, slong prec)"
arbcall"void _acb_poly_divrem(acb_ptr Q, acb_ptr R, acb_srcptr A, slong lenA, acb_srcptr B, slong lenB, slong prec)"
arbcall"int acb_poly_divrem(acb_poly_t Q, acb_poly_t R, const acb_poly_t A, const acb_poly_t B, slong prec)"
arbcall"void _acb_poly_div_root(acb_ptr Q, acb_t R, acb_srcptr A, slong len, const acb_t c, slong prec)"

### Composition
arbcall"void _acb_poly_taylor_shift(acb_ptr g, const acb_t c, slong n, slong prec)"
arbcall"void acb_poly_taylor_shift(acb_poly_t g, const acb_poly_t f, const acb_t c, slong prec)"
arbcall"void _acb_poly_compose(acb_ptr res, acb_srcptr poly1, slong len1, acb_srcptr poly2, slong len2, slong prec)"
arbcall"void acb_poly_compose(acb_poly_t res, const acb_poly_t poly1, const acb_poly_t poly2, slong prec)"
arbcall"void _acb_poly_compose_series(acb_ptr res, acb_srcptr poly1, slong len1, acb_srcptr poly2, slong len2, slong n, slong prec)"
arbcall"void acb_poly_compose_series(acb_poly_t res, const acb_poly_t poly1, const acb_poly_t poly2, slong n, slong prec)"
arbcall"void _acb_poly_revert_series(acb_ptr h, acb_srcptr f, slong flen, slong n, slong prec)"
arbcall"void acb_poly_revert_series(acb_poly_t h, const acb_poly_t f, slong n, slong prec)"

### Evaluation
arbcall"void _acb_poly_evaluate_horner(acb_t y, acb_srcptr f, slong len, const acb_t x, slong prec)"
arbcall"void acb_poly_evaluate_horner(acb_t y, const acb_poly_t f, const acb_t x, slong prec)"
arbcall"void _acb_poly_evaluate_rectangular(acb_t y, acb_srcptr f, slong len, const acb_t x, slong prec)"
arbcall"void acb_poly_evaluate_rectangular(acb_t y, const acb_poly_t f, const acb_t x, slong prec)"
arbcall"void _acb_poly_evaluate(acb_t y, acb_srcptr f, slong len, const acb_t x, slong prec)"
arbcall"void acb_poly_evaluate(acb_t y, const acb_poly_t f, const acb_t x, slong prec)"
arbcall"void _acb_poly_evaluate2_horner(acb_t y, acb_t z, acb_srcptr f, slong len, const acb_t x, slong prec)"
arbcall"void acb_poly_evaluate2_horner(acb_t y, acb_t z, const acb_poly_t f, const acb_t x, slong prec)"
arbcall"void _acb_poly_evaluate2_rectangular(acb_t y, acb_t z, acb_srcptr f, slong len, const acb_t x, slong prec)"
arbcall"void acb_poly_evaluate2_rectangular(acb_t y, acb_t z, const acb_poly_t f, const acb_t x, slong prec)"
arbcall"void _acb_poly_evaluate2(acb_t y, acb_t z, acb_srcptr f, slong len, const acb_t x, slong prec)"
arbcall"void acb_poly_evaluate2(acb_t y, acb_t z, const acb_poly_t f, const acb_t x, slong prec)"

### Product trees
arbcall"void _acb_poly_product_roots(acb_ptr poly, acb_srcptr xs, slong n, slong prec)"
arbcall"void acb_poly_product_roots(acb_poly_t poly, acb_srcptr xs, slong n, slong prec)"
#ni arbcall"acb_ptr * _acb_poly_tree_alloc(slong len)"
#ni arbcall"void _acb_poly_tree_free(acb_ptr * tree, slong len)"
#ni arbcall"void _acb_poly_tree_build(acb_ptr * tree, acb_srcptr roots, slong len, slong prec)"

### Multipoint evaluation
arbcall"void _acb_poly_evaluate_vec_iter(acb_ptr ys, acb_srcptr poly, slong plen, acb_srcptr xs, slong n, slong prec)"
arbcall"void acb_poly_evaluate_vec_iter(acb_ptr ys, const acb_poly_t poly, acb_srcptr xs, slong n, slong prec)"
#ni arbcall"void _acb_poly_evaluate_vec_fast_precomp(acb_ptr vs, acb_srcptr poly, slong plen, acb_ptr * tree, slong len, slong prec)"
arbcall"void _acb_poly_evaluate_vec_fast(acb_ptr ys, acb_srcptr poly, slong plen, acb_srcptr xs, slong n, slong prec)"
arbcall"void acb_poly_evaluate_vec_fast(acb_ptr ys, const acb_poly_t poly, acb_srcptr xs, slong n, slong prec)"

### Interpolation
arbcall"void _acb_poly_interpolate_newton(acb_ptr poly, acb_srcptr xs, acb_srcptr ys, slong n, slong prec)"
arbcall"void acb_poly_interpolate_newton(acb_poly_t poly, acb_srcptr xs, acb_srcptr ys, slong n, slong prec)"
arbcall"void _acb_poly_interpolate_barycentric(acb_ptr poly, acb_srcptr xs, acb_srcptr ys, slong n, slong prec)"
arbcall"void acb_poly_interpolate_barycentric(acb_poly_t poly, acb_srcptr xs, acb_srcptr ys, slong n, slong prec)"
#ni arbcall"void _acb_poly_interpolation_weights(acb_ptr w, acb_ptr * tree, slong len, slong prec)"
#ni arbcall"void _acb_poly_interpolate_fast_precomp(acb_ptr poly, acb_srcptr ys, acb_ptr * tree, acb_srcptr weights, slong len, slong prec)"
arbcall"void _acb_poly_interpolate_fast(acb_ptr poly, acb_srcptr xs, acb_srcptr ys, slong len, slong prec)"
arbcall"void acb_poly_interpolate_fast(acb_poly_t poly, acb_srcptr xs, acb_srcptr ys, slong n, slong prec)"

### Differentiation
arbcall"void _acb_poly_derivative(acb_ptr res, acb_srcptr poly, slong len, slong prec)"
arbcall"void acb_poly_derivative(acb_poly_t res, const acb_poly_t poly, slong prec)"
arbcall"void _acb_poly_nth_derivative(acb_ptr res, acb_srcptr poly, ulong n, slong len, slong prec)"
arbcall"void acb_poly_nth_derivative(acb_poly_t res, const acb_poly_t poly, ulong n, slong prec)"
arbcall"void _acb_poly_integral(acb_ptr res, acb_srcptr poly, slong len, slong prec)"
arbcall"void acb_poly_integral(acb_poly_t res, const acb_poly_t poly, slong prec)"

### Transforms
arbcall"void _acb_poly_borel_transform(acb_ptr res, acb_srcptr poly, slong len, slong prec)"
arbcall"void acb_poly_borel_transform(acb_poly_t res, const acb_poly_t poly, slong prec)"
arbcall"void _acb_poly_inv_borel_transform(acb_ptr res, acb_srcptr poly, slong len, slong prec)"
arbcall"void acb_poly_inv_borel_transform(acb_poly_t res, const acb_poly_t poly, slong prec)"
arbcall"void _acb_poly_binomial_transform_basecase(acb_ptr b, acb_srcptr a, slong alen, slong len, slong prec)"
arbcall"void acb_poly_binomial_transform_basecase(acb_poly_t b, const acb_poly_t a, slong len, slong prec)"
arbcall"void _acb_poly_binomial_transform_convolution(acb_ptr b, acb_srcptr a, slong alen, slong len, slong prec)"
arbcall"void acb_poly_binomial_transform_convolution(acb_poly_t b, const acb_poly_t a, slong len, slong prec)"
arbcall"void _acb_poly_binomial_transform(acb_ptr b, acb_srcptr a, slong alen, slong len, slong prec)"
arbcall"void acb_poly_binomial_transform(acb_poly_t b, const acb_poly_t a, slong len, slong prec)"
arbcall"void _acb_poly_graeffe_transform(acb_ptr b, acb_srcptr a, slong len, slong prec)"
arbcall"void acb_poly_graeffe_transform(acb_poly_t b, const acb_poly_t a, slong prec)"

### Elementary functions
arbcall"void _acb_poly_pow_ui_trunc_binexp(acb_ptr res, acb_srcptr f, slong flen, ulong exp, slong len, slong prec)"
arbcall"void acb_poly_pow_ui_trunc_binexp(acb_poly_t res, const acb_poly_t poly, ulong exp, slong len, slong prec)"
arbcall"void _acb_poly_pow_ui(acb_ptr res, acb_srcptr f, slong flen, ulong exp, slong prec)"
arbcall"void acb_poly_pow_ui(acb_poly_t res, const acb_poly_t poly, ulong exp, slong prec)"
arbcall"void _acb_poly_pow_series(acb_ptr h, acb_srcptr f, slong flen, acb_srcptr g, slong glen, slong len, slong prec)"
arbcall"void acb_poly_pow_series(acb_poly_t h, const acb_poly_t f, const acb_poly_t g, slong len, slong prec)"
arbcall"void _acb_poly_pow_acb_series(acb_ptr h, acb_srcptr f, slong flen, const acb_t g, slong len, slong prec)"
arbcall"void acb_poly_pow_acb_series(acb_poly_t h, const acb_poly_t f, const acb_t g, slong len, slong prec)"
arbcall"void _acb_poly_sqrt_series(acb_ptr g, acb_srcptr h, slong hlen, slong n, slong prec)"
arbcall"void acb_poly_sqrt_series(acb_poly_t g, const acb_poly_t h, slong n, slong prec)"
arbcall"void _acb_poly_rsqrt_series(acb_ptr g, acb_srcptr h, slong hlen, slong n, slong prec)"
arbcall"void acb_poly_rsqrt_series(acb_poly_t g, const acb_poly_t h, slong n, slong prec)"
arbcall"void _acb_poly_log_series(acb_ptr res, acb_srcptr f, slong flen, slong n, slong prec)"
arbcall"void acb_poly_log_series(acb_poly_t res, const acb_poly_t f, slong n, slong prec)"
arbcall"void _acb_poly_log1p_series(acb_ptr res, acb_srcptr f, slong flen, slong n, slong prec)"
arbcall"void acb_poly_log1p_series(acb_poly_t res, const acb_poly_t f, slong n, slong prec)"
arbcall"void _acb_poly_atan_series(acb_ptr res, acb_srcptr f, slong flen, slong n, slong prec)"
arbcall"void acb_poly_atan_series(acb_poly_t res, const acb_poly_t f, slong n, slong prec)"
arbcall"void _acb_poly_exp_series_basecase(acb_ptr f, acb_srcptr h, slong hlen, slong n, slong prec)"
arbcall"void acb_poly_exp_series_basecase(acb_poly_t f, const acb_poly_t h, slong n, slong prec)"
arbcall"void _acb_poly_exp_series(acb_ptr f, acb_srcptr h, slong hlen, slong n, slong prec)"
arbcall"void acb_poly_exp_series(acb_poly_t f, const acb_poly_t h, slong n, slong prec)"
arbcall"void _acb_poly_exp_pi_i_series(acb_ptr f, acb_srcptr h, slong hlen, slong n, slong prec)"
arbcall"void acb_poly_exp_pi_i_series(acb_poly_t f, const acb_poly_t h, slong n, slong prec)"
arbcall"void _acb_poly_sin_cos_series(acb_ptr s, acb_ptr c, acb_srcptr h, slong hlen, slong n, slong prec)"
arbcall"void acb_poly_sin_cos_series(acb_poly_t s, acb_poly_t c, const acb_poly_t h, slong n, slong prec)"
arbcall"void _acb_poly_sin_series(acb_ptr s, acb_srcptr h, slong hlen, slong n, slong prec)"
arbcall"void acb_poly_sin_series(acb_poly_t s, const acb_poly_t h, slong n, slong prec)"
arbcall"void _acb_poly_cos_series(acb_ptr c, acb_srcptr h, slong hlen, slong n, slong prec)"
arbcall"void acb_poly_cos_series(acb_poly_t c, const acb_poly_t h, slong n, slong prec)"
arbcall"void _acb_poly_tan_series(acb_ptr g, acb_srcptr h, slong hlen, slong len, slong prec)"
arbcall"void acb_poly_tan_series(acb_poly_t g, const acb_poly_t h, slong n, slong prec)"
arbcall"void _acb_poly_sin_cos_pi_series(acb_ptr s, acb_ptr c, acb_srcptr h, slong hlen, slong n, slong prec)"
arbcall"void acb_poly_sin_cos_pi_series(acb_poly_t s, acb_poly_t c, const acb_poly_t h, slong n, slong prec)"
arbcall"void _acb_poly_sin_pi_series(acb_ptr s, acb_srcptr h, slong hlen, slong n, slong prec)"
arbcall"void acb_poly_sin_pi_series(acb_poly_t s, const acb_poly_t h, slong n, slong prec)"
arbcall"void _acb_poly_cos_pi_series(acb_ptr c, acb_srcptr h, slong hlen, slong n, slong prec)"
arbcall"void acb_poly_cos_pi_series(acb_poly_t c, const acb_poly_t h, slong n, slong prec)"
arbcall"void _acb_poly_cot_pi_series(acb_ptr c, acb_srcptr h, slong hlen, slong n, slong prec)"
arbcall"void acb_poly_cot_pi_series(acb_poly_t c, const acb_poly_t h, slong n, slong prec)"
arbcall"void _acb_poly_sinh_cosh_series_basecase(acb_ptr s, acb_ptr c, acb_srcptr h, slong hlen, slong n, slong prec)"
arbcall"void acb_poly_sinh_cosh_series_basecase(acb_poly_t s, acb_poly_t c, const acb_poly_t h, slong n, slong prec)"
arbcall"void _acb_poly_sinh_cosh_series_exponential(acb_ptr s, acb_ptr c, acb_srcptr h, slong hlen, slong n, slong prec)"
arbcall"void acb_poly_sinh_cosh_series_exponential(acb_poly_t s, acb_poly_t c, const acb_poly_t h, slong n, slong prec)"
arbcall"void _acb_poly_sinh_cosh_series(acb_ptr s, acb_ptr c, acb_srcptr h, slong hlen, slong n, slong prec)"
arbcall"void acb_poly_sinh_cosh_series(acb_poly_t s, acb_poly_t c, const acb_poly_t h, slong n, slong prec)"
arbcall"void _acb_poly_sinh_series(acb_ptr s, acb_srcptr h, slong hlen, slong n, slong prec)"
arbcall"void acb_poly_sinh_series(acb_poly_t s, const acb_poly_t h, slong n, slong prec)"
arbcall"void _acb_poly_cosh_series(acb_ptr c, acb_srcptr h, slong hlen, slong n, slong prec)"
arbcall"void acb_poly_cosh_series(acb_poly_t c, const acb_poly_t h, slong n, slong prec)"
arbcall"void _acb_poly_sinc_series(acb_ptr s, acb_srcptr h, slong hlen, slong n, slong prec)"
arbcall"void acb_poly_sinc_series(acb_poly_t s, const acb_poly_t h, slong n, slong prec)"
arbcall"void _acb_poly_sinc_pi_series(acb_ptr s, acb_srcptr h, slong hlen, slong n, slong prec)"
arbcall"void acb_poly_sinc_pi_series(acb_poly_t s, const acb_poly_t h, slong n, slong prec)"

### Lambert W function
#ni arbcall"void _acb_poly_lambertw_series(acb_ptr res, acb_srcptr z, slong zlen, const fmpz_t k, int flags, slong len, slong prec)"
#ni arbcall"void acb_poly_lambertw_series(acb_poly_t res, const acb_poly_t z, const fmpz_t k, int flags, slong len, slong prec)"

### Gamma function
arbcall"void _acb_poly_gamma_series(acb_ptr res, acb_srcptr h, slong hlen, slong n, slong prec)"
arbcall"void acb_poly_gamma_series(acb_poly_t res, const acb_poly_t h, slong n, slong prec)"
arbcall"void _acb_poly_rgamma_series(acb_ptr res, acb_srcptr h, slong hlen, slong n, slong prec)"
arbcall"void acb_poly_rgamma_series(acb_poly_t res, const acb_poly_t h, slong n, slong prec)"
arbcall"void _acb_poly_lgamma_series(acb_ptr res, acb_srcptr h, slong hlen, slong n, slong prec)"
arbcall"void acb_poly_lgamma_series(acb_poly_t res, const acb_poly_t h, slong n, slong prec)"
arbcall"void _acb_poly_digamma_series(acb_ptr res, acb_srcptr h, slong hlen, slong n, slong prec)"
arbcall"void acb_poly_digamma_series(acb_poly_t res, const acb_poly_t h, slong n, slong prec)"
arbcall"void _acb_poly_rising_ui_series(acb_ptr res, acb_srcptr f, slong flen, ulong r, slong trunc, slong prec)"
arbcall"void acb_poly_rising_ui_series(acb_poly_t res, const acb_poly_t f, ulong r, slong trunc, slong prec)"

### Power sums
arbcall"void _acb_poly_powsum_series_naive(acb_ptr z, const acb_t s, const acb_t a, const acb_t q, slong n, slong len, slong prec)"
arbcall"void _acb_poly_powsum_series_naive_threaded(acb_ptr z, const acb_t s, const acb_t a, const acb_t q, slong n, slong len, slong prec)"
arbcall"void _acb_poly_powsum_one_series_sieved(acb_ptr z, const acb_t s, slong n, slong len, slong prec)"

### Zeta function
arbcall"void _acb_poly_zeta_em_choose_param(mag_t bound, ulong * N, ulong * M, const acb_t s, const acb_t a, slong d, slong target, slong prec)"
arbcall"void _acb_poly_zeta_em_bound1(mag_t bound, const acb_t s, const acb_t a, slong N, slong M, slong d, slong wp)"
arbcall"void _acb_poly_zeta_em_bound(arb_ptr vec, const acb_t s, const acb_t a, ulong N, ulong M, slong d, slong wp)"
arbcall"void _acb_poly_zeta_em_tail_naive(acb_ptr z, const acb_t s, const acb_t Na, acb_srcptr Nasx, slong M, slong len, slong prec)"
arbcall"void _acb_poly_zeta_em_tail_bsplit(acb_ptr z, const acb_t s, const acb_t Na, acb_srcptr Nasx, slong M, slong len, slong prec)"
arbcall"void _acb_poly_zeta_em_sum(acb_ptr z, const acb_t s, const acb_t a, int deflate, ulong N, ulong M, slong d, slong prec)"
arbcall"void _acb_poly_zeta_cpx_series(acb_ptr z, const acb_t s, const acb_t a, int deflate, slong d, slong prec)"
arbcall"void _acb_poly_zeta_series(acb_ptr res, acb_srcptr h, slong hlen, const acb_t a, int deflate, slong len, slong prec)"
arbcall"void acb_poly_zeta_series(acb_poly_t res, const acb_poly_t f, const acb_t a, int deflate, slong n, slong prec)"

### Other special functions
arbcall"void _acb_poly_polylog_cpx_small(acb_ptr w, const acb_t s, const acb_t z, slong len, slong prec)"
arbcall"void _acb_poly_polylog_cpx_zeta(acb_ptr w, const acb_t s, const acb_t z, slong len, slong prec)"
arbcall"void _acb_poly_polylog_cpx(acb_ptr w, const acb_t s, const acb_t z, slong len, slong prec)"
arbcall"void _acb_poly_polylog_series(acb_ptr w, acb_srcptr s, slong slen, const acb_t z, slong len, slong prec)"
arbcall"void acb_poly_polylog_series(acb_poly_t w, const acb_poly_t s, const acb_t z, slong len, slong prec)"
arbcall"void _acb_poly_erf_series(acb_ptr res, acb_srcptr z, slong zlen, slong n, slong prec)"
arbcall"void acb_poly_erf_series(acb_poly_t res, const acb_poly_t z, slong n, slong prec)"
arbcall"void _acb_poly_agm1_series(acb_ptr res, acb_srcptr z, slong zlen, slong len, slong prec)"
arbcall"void acb_poly_agm1_series(acb_poly_t res, const acb_poly_t z, slong n, slong prec)"
#mo arbcall"void _acb_poly_elliptic_k_series(acb_ptr res, acb_srcptr z, slong zlen, slong len, slong prec)" # alias to _acb_elliptic_k_series
#mo arbcall"void acb_poly_elliptic_k_series(acb_poly_t res, const acb_poly_t z, slong n, slong prec)" # alias to acb_elliptic_k_series
#mo arbcall"void _acb_poly_elliptic_p_series(acb_ptr res, acb_srcptr z, slong zlen, const acb_t tau, slong len, slong prec)" # alias to _acb_elliptic_p_series
#mo arbcall"void acb_poly_elliptic_p_series(acb_poly_t res, const acb_poly_t z, const acb_t tau, slong n, slong prec)" # alias to acb_elliptic_p_series

### Root-finding
arbcall"void _acb_poly_root_bound_fujiwara(mag_t bound, acb_srcptr poly, slong len)"
arbcall"void acb_poly_root_bound_fujiwara(mag_t bound, acb_poly_t poly)"
arbcall"void _acb_poly_root_inclusion(acb_t r, const acb_t m, acb_srcptr poly, acb_srcptr polyder, slong len, slong prec)"
arbcall"slong _acb_poly_validate_roots(acb_ptr roots, acb_srcptr poly, slong len, slong prec)"
arbcall"slong _acb_poly_find_roots(acb_ptr roots, acb_srcptr poly, acb_srcptr initial, slong len, slong maxiter, slong prec)"
arbcall"slong acb_poly_find_roots(acb_ptr roots, const acb_poly_t poly, acb_srcptr initial, slong maxiter, slong prec)"
arbcall"int _acb_poly_validate_real_roots(acb_srcptr roots, acb_srcptr poly, slong len, slong prec)"
arbcall"int acb_poly_validate_real_roots(acb_srcptr roots, const acb_poly_t poly, slong prec)"
