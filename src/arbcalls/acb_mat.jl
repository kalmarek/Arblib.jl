###
### **acb_mat.h** -- matrices over the complex numbers
###

### Types, macros and constants

### Memory management
arbcall"void acb_mat_init(acb_mat_t mat, slong r, slong c)"
arbcall"void acb_mat_clear(acb_mat_t mat)"
arbcall"slong acb_mat_allocated_bytes(const acb_mat_t x)"
arbcall"void acb_mat_window_init(acb_mat_t window, const acb_mat_t mat, slong r1, slong c1, slong r2, slong c2)"
arbcall"void acb_mat_window_clear(acb_mat_t window)"

### Conversions
arbcall"void acb_mat_set(acb_mat_t dest, const acb_mat_t src)"
#ni arbcall"void acb_mat_set_fmpz_mat(acb_mat_t dest, const fmpz_mat_t src)"
#ni arbcall"void acb_mat_set_round_fmpz_mat(acb_mat_t dest, const fmpz_mat_t src, slong prec)"
#ni arbcall"void acb_mat_set_fmpq_mat(acb_mat_t dest, const fmpq_mat_t src, slong prec)"
arbcall"void acb_mat_set_arb_mat(acb_mat_t dest, const arb_mat_t src)"
arbcall"void acb_mat_set_round_arb_mat(acb_mat_t dest, const arb_mat_t src, slong prec)"
arbcall"void acb_mat_get_real(arb_mat_t re, const arb_mat_t mat)"
arbcall"void acb_mat_get_imag(arb_mat_t im, const arb_mat_t mat)"
arbcall"void acb_mat_set_real_imag(acb_mat_t mat, const arb_mat_t re, const arb_mat_t im)"

### Random generation
#ns arbcall"void acb_mat_randtest(acb_mat_t mat, flint_rand_t state, slong prec, slong mag_bits)"
#ns arbcall"void acb_mat_randtest_eig(acb_mat_t mat, flint_rand_t state, acb_srcptr E, slong prec)"

### Input and output
arbcall"void acb_mat_printd(const acb_mat_t mat, slong digits)"
#ns arbcall"void acb_mat_fprintd(FILE * file, const acb_mat_t mat, slong digits)"

### Comparisons
arbcall"int acb_mat_equal(const acb_mat_t mat1, const acb_mat_t mat2)"
arbcall"int acb_mat_overlaps(const acb_mat_t mat1, const acb_mat_t mat2)"
arbcall"int acb_mat_contains(const acb_mat_t mat1, const acb_mat_t mat2)"
#ni arbcall"int acb_mat_contains_fmpz_mat(const acb_mat_t mat1, const fmpz_mat_t mat2)"
#ni arbcall"int acb_mat_contains_fmpq_mat(const acb_mat_t mat1, const fmpq_mat_t mat2)"
arbcall"int acb_mat_eq(const acb_mat_t mat1, const acb_mat_t mat2)"
arbcall"int acb_mat_ne(const acb_mat_t mat1, const acb_mat_t mat2)"
arbcall"int acb_mat_is_real(const acb_mat_t mat)"
arbcall"int acb_mat_is_empty(const acb_mat_t mat)"
arbcall"int acb_mat_is_square(const acb_mat_t mat)"
arbcall"int acb_mat_is_exact(const acb_mat_t mat)"
arbcall"int acb_mat_is_zero(const acb_mat_t mat)"
arbcall"int acb_mat_is_finite(const acb_mat_t mat)"
arbcall"int acb_mat_is_triu(const acb_mat_t mat)"
arbcall"int acb_mat_is_tril(const acb_mat_t mat)"
arbcall"int acb_mat_is_diag(const acb_mat_t mat)"

### Special matrices
arbcall"void acb_mat_zero(acb_mat_t mat)"
arbcall"void acb_mat_one(acb_mat_t mat)"
arbcall"void acb_mat_ones(acb_mat_t mat)"
arbcall"void acb_mat_onei(acb_mat_t mat)"
arbcall"void acb_mat_indeterminate(acb_mat_t mat)"
arbcall"void acb_mat_dft(acb_mat_t mat, int type, slong prec)"

### Transpose
arbcall"void acb_mat_transpose(acb_mat_t dest, const acb_mat_t src)"
arbcall"void acb_mat_conjugate_transpose(acb_mat_t dest, const acb_mat_t src)"
arbcall"void acb_mat_conjugate(acb_mat_t dest, const acb_mat_t src)"

### Norms
arbcall"void acb_mat_bound_inf_norm(mag_t b, const acb_mat_t A)"
arbcall"void acb_mat_frobenius_norm(arb_t res, const acb_mat_t A, slong prec)"
arbcall"void acb_mat_bound_frobenius_norm(mag_t res, const acb_mat_t A)"

### Arithmetic
arbcall"void acb_mat_neg(acb_mat_t dest, const acb_mat_t src)"
arbcall"void acb_mat_add(acb_mat_t res, const acb_mat_t mat1, const acb_mat_t mat2, slong prec)"
arbcall"void acb_mat_sub(acb_mat_t res, const acb_mat_t mat1, const acb_mat_t mat2, slong prec)"
arbcall"void acb_mat_mul_classical(acb_mat_t res, const acb_mat_t mat1, const acb_mat_t mat2, slong prec)"
arbcall"void acb_mat_mul_threaded(acb_mat_t res, const acb_mat_t mat1, const acb_mat_t mat2, slong prec)"
arbcall"void acb_mat_mul_reorder(acb_mat_t res, const acb_mat_t mat1, const acb_mat_t mat2, slong prec)"
arbcall"void acb_mat_mul(acb_mat_t res, const acb_mat_t mat1, const acb_mat_t mat2, slong prec)"
arbcall"void acb_mat_mul_entrywise(acb_mat_t res, const acb_mat_t mat1, const acb_mat_t mat2, slong prec)"
arbcall"void acb_mat_sqr_classical(acb_mat_t res, const acb_mat_t mat, slong prec)"
arbcall"void acb_mat_sqr(acb_mat_t res, const acb_mat_t mat, slong prec)"
arbcall"void acb_mat_pow_ui(acb_mat_t res, const acb_mat_t mat, ulong exp, slong prec)"
arbcall"void acb_mat_approx_mul(acb_mat_t res, const acb_mat_t mat1, const acb_mat_t mat2, slong prec)"

### Scalar arithmetic
arbcall"void acb_mat_scalar_mul_2exp_si(acb_mat_t B, const acb_mat_t A, slong c)"
arbcall"void acb_mat_scalar_addmul_si(acb_mat_t B, const acb_mat_t A, slong c, slong prec)"
#ni arbcall"void acb_mat_scalar_addmul_fmpz(acb_mat_t B, const acb_mat_t A, const fmpz_t c, slong prec)"
arbcall"void acb_mat_scalar_addmul_arb(acb_mat_t B, const acb_mat_t A, const arb_t c, slong prec)"
arbcall"void acb_mat_scalar_addmul_acb(acb_mat_t B, const acb_mat_t A, const acb_t c, slong prec)"
arbcall"void acb_mat_scalar_mul_si(acb_mat_t B, const acb_mat_t A, slong c, slong prec)"
#ni arbcall"void acb_mat_scalar_mul_fmpz(acb_mat_t B, const acb_mat_t A, const fmpz_t c, slong prec)"
arbcall"void acb_mat_scalar_mul_arb(acb_mat_t B, const acb_mat_t A, const arb_t c, slong prec)"
arbcall"void acb_mat_scalar_mul_acb(acb_mat_t B, const acb_mat_t A, const acb_t c, slong prec)"
arbcall"void acb_mat_scalar_div_si(acb_mat_t B, const acb_mat_t A, slong c, slong prec)"
#ni arbcall"void acb_mat_scalar_div_fmpz(acb_mat_t B, const acb_mat_t A, const fmpz_t c, slong prec)"
arbcall"void acb_mat_scalar_div_arb(acb_mat_t B, const acb_mat_t A, const arb_t c, slong prec)"
arbcall"void acb_mat_scalar_div_acb(acb_mat_t B, const acb_mat_t A, const acb_t c, slong prec)"

### Vector arithmetic
#mo arbcall"void _acb_mat_vector_mul_row(acb_ptr res, acb_srcptr v, const acb_mat_t A, slong prec)" # same as acb_mat_vector_mul_row (except not allowing aliasing)
#mo arbcall"void _acb_mat_vector_mul_col(acb_ptr res, const acb_mat_t A, acb_srcptr v, slong prec)" # same as acb_mat_vector_mul_col (except not allowing aliasing)
arbcall"void acb_mat_vector_mul_row(acb_ptr res, acb_srcptr v, const acb_mat_t A, slong prec)"
arbcall"void acb_mat_vector_mul_col(acb_ptr res, const acb_mat_t A, acb_srcptr v, slong prec)"

### Gaussian elimination and solving
arbcall"int acb_mat_lu_classical(slong * perm, acb_mat_t LU, const acb_mat_t A, slong prec)"
arbcall"int acb_mat_lu_recursive(slong * perm, acb_mat_t LU, const acb_mat_t A, slong prec)"
arbcall"int acb_mat_lu(slong * perm, acb_mat_t LU, const acb_mat_t A, slong prec)"
arbcall"void acb_mat_solve_tril_classical(acb_mat_t X, const acb_mat_t L, const acb_mat_t B, int unit, slong prec)"
arbcall"void acb_mat_solve_tril_recursive(acb_mat_t X, const acb_mat_t L, const acb_mat_t B, int unit, slong prec)"
arbcall"void acb_mat_solve_tril(acb_mat_t X, const acb_mat_t L, const acb_mat_t B, int unit, slong prec)"
arbcall"void acb_mat_solve_triu_classical(acb_mat_t X, const acb_mat_t U, const acb_mat_t B, int unit, slong prec)"
arbcall"void acb_mat_solve_triu_recursive(acb_mat_t X, const acb_mat_t U, const acb_mat_t B, int unit, slong prec)"
arbcall"void acb_mat_solve_triu(acb_mat_t X, const acb_mat_t U, const acb_mat_t B, int unit, slong prec)"
arbcall"void acb_mat_solve_lu_precomp(acb_mat_t X, const slong * perm, const acb_mat_t LU, const acb_mat_t B, slong prec)"
arbcall"int acb_mat_solve(acb_mat_t X, const acb_mat_t A, const acb_mat_t B, slong prec)"
arbcall"int acb_mat_solve_lu(acb_mat_t X, const acb_mat_t A, const acb_mat_t B, slong prec)"
arbcall"int acb_mat_solve_precond(acb_mat_t X, const acb_mat_t A, const acb_mat_t B, slong prec)"
arbcall"int acb_mat_inv(acb_mat_t X, const acb_mat_t A, slong prec)"
arbcall"void acb_mat_det_lu(acb_t det, const acb_mat_t A, slong prec)"
arbcall"void acb_mat_det_precond(acb_t det, const acb_mat_t A, slong prec)"
arbcall"void acb_mat_det(acb_t det, const acb_mat_t A, slong prec)"
arbcall"void acb_mat_approx_solve_triu(acb_mat_t X, const acb_mat_t U, const acb_mat_t B, int unit, slong prec)"
arbcall"void acb_mat_approx_solve_tril(acb_mat_t X, const acb_mat_t L, const acb_mat_t B, int unit, slong prec)"
arbcall"int acb_mat_approx_lu(slong * P, acb_mat_t LU, const acb_mat_t A, slong prec)"
arbcall"void acb_mat_approx_solve_lu_precomp(acb_mat_t X, const slong * perm, const acb_mat_t A, const acb_mat_t B, slong prec)"
arbcall"int acb_mat_approx_solve(acb_mat_t X, const acb_mat_t A, const acb_mat_t B, slong prec)"
arbcall"int acb_mat_approx_inv(acb_mat_t X, const acb_mat_t A, slong prec)"

### Characteristic polynomial and companion matrix
arbcall"void _acb_mat_charpoly(acb_ptr poly, const acb_mat_t mat, slong prec)"
arbcall"void acb_mat_charpoly(acb_poly_t poly, const acb_mat_t mat, slong prec)"
arbcall"void _acb_mat_companion(acb_mat_t mat, acb_srcptr poly, slong prec)"
arbcall"void acb_mat_companion(acb_mat_t mat, const acb_poly_t poly, slong prec)"

### Special functions
arbcall"void acb_mat_exp_taylor_sum(acb_mat_t S, const acb_mat_t A, slong N, slong prec)"
arbcall"void acb_mat_exp(acb_mat_t B, const acb_mat_t A, slong prec)"
arbcall"void acb_mat_trace(acb_t trace, const acb_mat_t mat, slong prec)"
arbcall"void _acb_mat_diag_prod(acb_t res, const acb_mat_t mat, slong a, slong b, slong prec)"
arbcall"void acb_mat_diag_prod(acb_t res, const acb_mat_t mat, slong prec)"

### Component and error operations
arbcall"void acb_mat_get_mid(acb_mat_t B, const acb_mat_t A)"
arbcall"void acb_mat_add_error_mag(acb_mat_t mat, const mag_t err)"

### Eigenvalues and eigenvectors
arbcall"int acb_mat_approx_eig_qr(acb_ptr E, acb_mat_t L, acb_mat_t R, const acb_mat_t A, const mag_t tol, slong maxiter, slong prec)"
arbcall"void acb_mat_eig_global_enclosure(mag_t eps, const acb_mat_t A, acb_srcptr E, const acb_mat_t R, slong prec)"
arbcall"void acb_mat_eig_enclosure_rump(acb_t lambda, acb_mat_t J, acb_mat_t R, const acb_mat_t A, const acb_t lambda_approx, const acb_mat_t R_approx, slong prec)"
arbcall"int acb_mat_eig_simple_rump(acb_ptr E, acb_mat_t L, acb_mat_t R, const acb_mat_t A, acb_srcptr E_approx, const acb_mat_t R_approx, slong prec)"
arbcall"int acb_mat_eig_simple_vdhoeven_mourrain(acb_ptr E, acb_mat_t L, acb_mat_t R, const acb_mat_t A, acb_srcptr E_approx, const acb_mat_t R_approx, slong prec)"
arbcall"int acb_mat_eig_simple(acb_ptr E, acb_mat_t L, acb_mat_t R, const acb_mat_t A, acb_srcptr E_approx, const acb_mat_t R_approx, slong prec)"
arbcall"int acb_mat_eig_multiple_rump(acb_ptr E, const acb_mat_t A, acb_srcptr E_approx, const acb_mat_t R_approx, slong prec)"
arbcall"int acb_mat_eig_multiple(acb_ptr E, const acb_mat_t A, acb_srcptr E_approx, const acb_mat_t R_approx, slong prec)"
