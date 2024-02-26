###
### **arb_mat.h** -- matrices over the real numbers
###

### Types, macros and constants

### Memory management
arbcall"void arb_mat_init(arb_mat_t mat, slong r, slong c)"
arbcall"void arb_mat_clear(arb_mat_t mat)"
arbcall"slong arb_mat_allocated_bytes(const arb_mat_t x)"
arbcall"void arb_mat_window_init(arb_mat_t window, const arb_mat_t mat, slong r1, slong c1, slong r2, slong c2)"
arbcall"void arb_mat_window_clear(arb_mat_t window)"

### Conversions
arbcall"void arb_mat_set(arb_mat_t dest, const arb_mat_t src)"
#ni arbcall"void arb_mat_set_fmpz_mat(arb_mat_t dest, const fmpz_mat_t src)"
#ni arbcall"void arb_mat_set_round_fmpz_mat(arb_mat_t dest, const fmpz_mat_t src, slong prec)"
#ni arbcall"void arb_mat_set_fmpq_mat(arb_mat_t dest, const fmpq_mat_t src, slong prec)"

### Random generation
#ns arbcall"void arb_mat_randtest(arb_mat_t mat, flint_rand_t state, slong prec, slong mag_bits)"
#ns arbcall"void arb_mat_randtest_cho(arb_mat_t mat, flint_rand_t state, slong prec, slong mag_bits)"
#ns arbcall"void arb_mat_randtest_spd(arb_mat_t mat, flint_rand_t state, slong prec, slong mag_bits)"

### Input and output
arbcall"void arb_mat_printd(const arb_mat_t mat, slong digits)"
#ns arbcall"void arb_mat_fprintd(FILE * file, const arb_mat_t mat, slong digits)"

### Comparisons
arbcall"int arb_mat_equal(const arb_mat_t mat1, const arb_mat_t mat2)"
arbcall"int arb_mat_overlaps(const arb_mat_t mat1, const arb_mat_t mat2)"
arbcall"int arb_mat_contains(const arb_mat_t mat1, const arb_mat_t mat2)"
#ni arbcall"int arb_mat_contains_fmpz_mat(const arb_mat_t mat1, const fmpz_mat_t mat2)"
#ni arbcall"int arb_mat_contains_fmpq_mat(const arb_mat_t mat1, const fmpq_mat_t mat2)"
arbcall"int arb_mat_eq(const arb_mat_t mat1, const arb_mat_t mat2)"
arbcall"int arb_mat_ne(const arb_mat_t mat1, const arb_mat_t mat2)"
arbcall"int arb_mat_is_empty(const arb_mat_t mat)"
arbcall"int arb_mat_is_square(const arb_mat_t mat)"
arbcall"int arb_mat_is_exact(const arb_mat_t mat)"
arbcall"int arb_mat_is_zero(const arb_mat_t mat)"
arbcall"int arb_mat_is_finite(const arb_mat_t mat)"
arbcall"int arb_mat_is_triu(const arb_mat_t mat)"
arbcall"int arb_mat_is_tril(const arb_mat_t mat)"
arbcall"int arb_mat_is_diag(const arb_mat_t mat)"

### Special matrices
arbcall"void arb_mat_zero(arb_mat_t mat)"
arbcall"void arb_mat_one(arb_mat_t mat)"
arbcall"void arb_mat_ones(arb_mat_t mat)"
arbcall"void arb_mat_indeterminate(arb_mat_t mat)"
arbcall"void arb_mat_hilbert(arb_mat_t mat, slong prec)"
arbcall"void arb_mat_pascal(arb_mat_t mat, int triangular, slong prec)"
arbcall"void arb_mat_stirling(arb_mat_t mat, int kind, slong prec)"
arbcall"void arb_mat_dct(arb_mat_t mat, int type, slong prec)"

### Transpose
arbcall"void arb_mat_transpose(arb_mat_t dest, const arb_mat_t src)"

### Norms
arbcall"void arb_mat_bound_inf_norm(mag_t b, const arb_mat_t A)"
arbcall"void arb_mat_frobenius_norm(arb_t res, const arb_mat_t A, slong prec)"
arbcall"void arb_mat_bound_frobenius_norm(mag_t res, const arb_mat_t A)"

### Arithmetic
arbcall"void arb_mat_neg(arb_mat_t dest, const arb_mat_t src)"
arbcall"void arb_mat_add(arb_mat_t res, const arb_mat_t mat1, const arb_mat_t mat2, slong prec)"
arbcall"void arb_mat_sub(arb_mat_t res, const arb_mat_t mat1, const arb_mat_t mat2, slong prec)"
arbcall"void arb_mat_mul_classical(arb_mat_t C, const arb_mat_t A, const arb_mat_t B, slong prec)"
arbcall"void arb_mat_mul_threaded(arb_mat_t C, const arb_mat_t A, const arb_mat_t B, slong prec)"
arbcall"void arb_mat_mul_block(arb_mat_t C, const arb_mat_t A, const arb_mat_t B, slong prec)"
arbcall"void arb_mat_mul(arb_mat_t res, const arb_mat_t mat1, const arb_mat_t mat2, slong prec)"
arbcall"void arb_mat_mul_entrywise(arb_mat_t C, const arb_mat_t A, const arb_mat_t B, slong prec)"
arbcall"void arb_mat_sqr_classical(arb_mat_t B, const arb_mat_t A, slong prec)"
arbcall"void arb_mat_sqr(arb_mat_t res, const arb_mat_t mat, slong prec)"
arbcall"void arb_mat_pow_ui(arb_mat_t res, const arb_mat_t mat, ulong exp, slong prec)"
#ni arbcall"void _arb_mat_addmul_rad_mag_fast(arb_mat_t C, mag_srcptr A, mag_srcptr B, slong ar, slong ac, slong bc)"
arbcall"void arb_mat_approx_mul(arb_mat_t res, const arb_mat_t mat1, const arb_mat_t mat2, slong prec)"

### Scalar arithmetic
arbcall"void arb_mat_scalar_mul_2exp_si(arb_mat_t B, const arb_mat_t A, slong c)"
arbcall"void arb_mat_scalar_addmul_si(arb_mat_t B, const arb_mat_t A, slong c, slong prec)"
#ni arbcall"void arb_mat_scalar_addmul_fmpz(arb_mat_t B, const arb_mat_t A, const fmpz_t c, slong prec)"
arbcall"void arb_mat_scalar_addmul_arb(arb_mat_t B, const arb_mat_t A, const arb_t c, slong prec)"
arbcall"void arb_mat_scalar_mul_si(arb_mat_t B, const arb_mat_t A, slong c, slong prec)"
#ni arbcall"void arb_mat_scalar_mul_fmpz(arb_mat_t B, const arb_mat_t A, const fmpz_t c, slong prec)"
arbcall"void arb_mat_scalar_mul_arb(arb_mat_t B, const arb_mat_t A, const arb_t c, slong prec)"
arbcall"void arb_mat_scalar_div_si(arb_mat_t B, const arb_mat_t A, slong c, slong prec)"
#ni arbcall"void arb_mat_scalar_div_fmpz(arb_mat_t B, const arb_mat_t A, const fmpz_t c, slong prec)"
arbcall"void arb_mat_scalar_div_arb(arb_mat_t B, const arb_mat_t A, const arb_t c, slong prec)"

### Vector arithmetic
arbcall"void _arb_mat_vector_mul_row(arb_ptr res, arb_srcptr v, const arb_mat_t A, slong prec)"
arbcall"void _arb_mat_vector_mul_col(arb_ptr res, const arb_mat_t A, arb_srcptr v, slong prec)"
arbcall"void arb_mat_vector_mul_row(arb_ptr res, arb_srcptr v, const arb_mat_t A, slong prec)"
arbcall"void arb_mat_vector_mul_col(arb_ptr res, const arb_mat_t A, arb_srcptr v, slong prec)"

### Gaussian elimination and solving
arbcall"int arb_mat_lu_classical(slong * perm, arb_mat_t LU, const arb_mat_t A, slong prec)"
arbcall"int arb_mat_lu_recursive(slong * perm, arb_mat_t LU, const arb_mat_t A, slong prec)"
arbcall"int arb_mat_lu(slong * perm, arb_mat_t LU, const arb_mat_t A, slong prec)"
arbcall"void arb_mat_solve_tril_classical(arb_mat_t X, const arb_mat_t L, const arb_mat_t B, int unit, slong prec)"
arbcall"void arb_mat_solve_tril_recursive(arb_mat_t X, const arb_mat_t L, const arb_mat_t B, int unit, slong prec)"
arbcall"void arb_mat_solve_tril(arb_mat_t X, const arb_mat_t L, const arb_mat_t B, int unit, slong prec)"
arbcall"void arb_mat_solve_triu_classical(arb_mat_t X, const arb_mat_t U, const arb_mat_t B, int unit, slong prec)"
arbcall"void arb_mat_solve_triu_recursive(arb_mat_t X, const arb_mat_t U, const arb_mat_t B, int unit, slong prec)"
arbcall"void arb_mat_solve_triu(arb_mat_t X, const arb_mat_t U, const arb_mat_t B, int unit, slong prec)"
arbcall"void arb_mat_solve_lu_precomp(arb_mat_t X, const slong * perm, const arb_mat_t LU, const arb_mat_t B, slong prec)"
arbcall"int arb_mat_solve(arb_mat_t X, const arb_mat_t A, const arb_mat_t B, slong prec)"
arbcall"int arb_mat_solve_lu(arb_mat_t X, const arb_mat_t A, const arb_mat_t B, slong prec)"
arbcall"int arb_mat_solve_precond(arb_mat_t X, const arb_mat_t A, const arb_mat_t B, slong prec)"
arbcall"int arb_mat_solve_preapprox(arb_mat_t X, const arb_mat_t A, const arb_mat_t B, const arb_mat_t R, const arb_mat_t T, slong prec)"
arbcall"int arb_mat_inv(arb_mat_t X, const arb_mat_t A, slong prec)"
arbcall"void arb_mat_det_lu(arb_t det, const arb_mat_t A, slong prec)"
arbcall"void arb_mat_det_precond(arb_t det, const arb_mat_t A, slong prec)"
arbcall"void arb_mat_det(arb_t det, const arb_mat_t A, slong prec)"
arbcall"void arb_mat_approx_solve_triu(arb_mat_t X, const arb_mat_t U, const arb_mat_t B, int unit, slong prec)"
arbcall"void arb_mat_approx_solve_tril(arb_mat_t X, const arb_mat_t L, const arb_mat_t B, int unit, slong prec)"
arbcall"int arb_mat_approx_lu(slong * P, arb_mat_t LU, const arb_mat_t A, slong prec)"
arbcall"void arb_mat_approx_solve_lu_precomp(arb_mat_t X, const slong * perm, const arb_mat_t A, const arb_mat_t B, slong prec)"
arbcall"int arb_mat_approx_solve(arb_mat_t X, const arb_mat_t A, const arb_mat_t B, slong prec)"
arbcall"int arb_mat_approx_inv(arb_mat_t X, const arb_mat_t A, slong prec)"

### Cholesky decomposition and solving
arbcall"int _arb_mat_cholesky_banachiewicz(arb_mat_t A, slong prec)"
arbcall"int arb_mat_cho(arb_mat_t L, const arb_mat_t A, slong prec)"
arbcall"void arb_mat_solve_cho_precomp(arb_mat_t X, const arb_mat_t L, const arb_mat_t B, slong prec)"
arbcall"int arb_mat_spd_solve(arb_mat_t X, const arb_mat_t A, const arb_mat_t B, slong prec)"
arbcall"void arb_mat_inv_cho_precomp(arb_mat_t X, const arb_mat_t L, slong prec)"
arbcall"int arb_mat_spd_inv(arb_mat_t X, const arb_mat_t A, slong prec)"
arbcall"int _arb_mat_ldl_inplace(arb_mat_t A, slong prec)"
arbcall"int _arb_mat_ldl_golub_and_van_loan(arb_mat_t A, slong prec)"
arbcall"int arb_mat_ldl(arb_mat_t res, const arb_mat_t A, slong prec)"
arbcall"void arb_mat_solve_ldl_precomp(arb_mat_t X, const arb_mat_t L, const arb_mat_t B, slong prec)"
arbcall"void arb_mat_inv_ldl_precomp(arb_mat_t X, const arb_mat_t L, slong prec)"

### Characteristic polynomial and companion matrix
arbcall"void _arb_mat_charpoly(arb_ptr poly, const arb_mat_t mat, slong prec)"
arbcall"void arb_mat_charpoly(arb_poly_t poly, const arb_mat_t mat, slong prec)"
arbcall"void _arb_mat_companion(arb_mat_t mat, arb_srcptr poly, slong prec)"
arbcall"void arb_mat_companion(arb_mat_t mat, const arb_poly_t poly, slong prec)"

### Special functions
arbcall"void arb_mat_exp_taylor_sum(arb_mat_t S, const arb_mat_t A, slong N, slong prec)"
arbcall"void arb_mat_exp(arb_mat_t B, const arb_mat_t A, slong prec)"
arbcall"void arb_mat_trace(arb_t trace, const arb_mat_t mat, slong prec)"
arbcall"void _arb_mat_diag_prod(arb_t res, const arb_mat_t mat, slong a, slong b, slong prec)"
arbcall"void arb_mat_diag_prod(arb_t res, const arb_mat_t mat, slong prec)"

### Sparsity structure
#ni arbcall"void arb_mat_entrywise_is_zero(fmpz_mat_t dest, const arb_mat_t src)"
#ni arbcall"void arb_mat_entrywise_not_is_zero(fmpz_mat_t dest, const arb_mat_t src)"
arbcall"slong arb_mat_count_is_zero(const arb_mat_t mat)"
arbcall"slong arb_mat_count_not_is_zero(const arb_mat_t mat)"

### Component and error operations
arbcall"void arb_mat_get_mid(arb_mat_t B, const arb_mat_t A)"
arbcall"void arb_mat_add_error_mag(arb_mat_t mat, const mag_t err)"

### Eigenvalues and eigenvectors

### LLL reduction
#ni arbcall"int arb_mat_spd_get_fmpz_mat(fmpz_mat_t B, const arb_mat_t A, slong prec)"
#ni arbcall"void arb_mat_spd_lll_reduce(fmpz_mat_t U, const arb_mat_t A, slong prec)"
arbcall"int arb_mat_spd_is_lll_reduced(const arb_mat_t A, slong tol_exp, slong prec)"
