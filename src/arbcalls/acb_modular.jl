###
### **acb_modular.h** -- modular forms of complex variables
###

### The modular group
#ni arbcall"void psl2z_init(psl2z_t g)"
#ni arbcall"void psl2z_clear(psl2z_t g)"
#ni arbcall"void psl2z_swap(psl2z_t f, psl2z_t g)"
#ni arbcall"void psl2z_set(psl2z_t f, const psl2z_t g)"
#ni arbcall"void psl2z_one(psl2z_t g)"
#ni arbcall"int psl2z_is_one(const psl2z_t g)"
#ni arbcall"void psl2z_print(const psl2z_t g)"
#ns arbcall"void psl2z_fprint(FILE * file, const psl2z_t g)"
#ni arbcall"int psl2z_equal(const psl2z_t f, const psl2z_t g)"
#ni arbcall"void psl2z_mul(psl2z_t h, const psl2z_t f, const psl2z_t g)"
#ni arbcall"void psl2z_inv(psl2z_t h, const psl2z_t g)"
#ni arbcall"int psl2z_is_correct(const psl2z_t g)"
#ni arbcall"void psl2z_randtest(psl2z_t g, flint_rand_t state, slong bits)"

### Modular transformations
#ni arbcall"void acb_modular_transform(acb_t w, const psl2z_t g, const acb_t z, slong prec)"
#ni arbcall"void acb_modular_fundamental_domain_approx_d(psl2z_t g, double x, double y, double one_minus_eps)"
#ni arbcall"void acb_modular_fundamental_domain_approx_arf(psl2z_t g, const arf_t x, const arf_t y, const arf_t one_minus_eps, slong prec)"
#ni arbcall"void acb_modular_fundamental_domain_approx(acb_t w, psl2z_t g, const acb_t z, const arf_t one_minus_eps, slong prec)"
arbcall"int acb_modular_is_in_fundamental_domain(const acb_t z, const arf_t tol, slong prec)"

### Addition sequences
arbcall"void acb_modular_fill_addseq(slong * tab, slong len)"

### Jacobi theta functions
#ni arbcall"void acb_modular_theta_transform(int * R, int * S, int * C, const psl2z_t g)"
arbcall"void acb_modular_addseq_theta(slong * exponents, slong * aindex, slong * bindex, slong num)"
arbcall"void acb_modular_theta_sum(acb_ptr theta1, acb_ptr theta2, acb_ptr theta3, acb_ptr theta4, const acb_t w, int w_is_unit, const acb_t q, slong len, slong prec)"
arbcall"void acb_modular_theta_const_sum_basecase(acb_t theta2, acb_t theta3, acb_t theta4, const acb_t q, slong N, slong prec)"
arbcall"void acb_modular_theta_const_sum_rs(acb_t theta2, acb_t theta3, acb_t theta4, const acb_t q, slong N, slong prec)"
arbcall"void acb_modular_theta_const_sum(acb_t theta2, acb_t theta3, acb_t theta4, const acb_t q, slong prec)"
arbcall"void acb_modular_theta_notransform(acb_t theta1, acb_t theta2, acb_t theta3, acb_t theta4, const acb_t z, const acb_t tau, slong prec)"
arbcall"void acb_modular_theta(acb_t theta1, acb_t theta2, acb_t theta3, acb_t theta4, const acb_t z, const acb_t tau, slong prec)"
arbcall"void acb_modular_theta_jet_notransform(acb_ptr theta1, acb_ptr theta2, acb_ptr theta3, acb_ptr theta4, const acb_t z, const acb_t tau, slong len, slong prec)"
arbcall"void acb_modular_theta_jet(acb_ptr theta1, acb_ptr theta2, acb_ptr theta3, acb_ptr theta4, const acb_t z, const acb_t tau, slong len, slong prec)"
arbcall"void _acb_modular_theta_series(acb_ptr theta1, acb_ptr theta2, acb_ptr theta3, acb_ptr theta4, acb_srcptr z, slong zlen, const acb_t tau, slong len, slong prec)"
arbcall"void acb_modular_theta_series(acb_poly_t theta1, acb_poly_t theta2, acb_poly_t theta3, acb_poly_t theta4, const acb_poly_t z, const acb_t tau, slong len, slong prec)"

### Dedekind eta function
arbcall"void acb_modular_addseq_eta(slong * exponents, slong * aindex, slong * bindex, slong num)"
arbcall"void acb_modular_eta_sum(acb_t eta, const acb_t q, slong prec)"
#ni arbcall"int acb_modular_epsilon_arg(const psl2z_t g)"
arbcall"void acb_modular_eta(acb_t r, const acb_t tau, slong prec)"

### Modular forms
arbcall"void acb_modular_j(acb_t r, const acb_t tau, slong prec)"
arbcall"void acb_modular_lambda(acb_t r, const acb_t tau, slong prec)"
arbcall"void acb_modular_delta(acb_t r, const acb_t tau, slong prec)"
arbcall"void acb_modular_eisenstein(acb_ptr r, const acb_t tau, slong len, slong prec)"

### Elliptic integrals and functions
arbcall"void acb_modular_elliptic_k(acb_t w, const acb_t m, slong prec)"
arbcall"void acb_modular_elliptic_k_cpx(acb_ptr w, const acb_t m, slong len, slong prec)"
arbcall"void acb_modular_elliptic_e(acb_t w, const acb_t m, slong prec)"
arbcall"void acb_modular_elliptic_p(acb_t wp, const acb_t z, const acb_t tau, slong prec)"
arbcall"void acb_modular_elliptic_p_zpx(acb_ptr wp, const acb_t z, const acb_t tau, slong len, slong prec)"

### Class polynomials
#ni arbcall"void acb_modular_hilbert_class_poly(fmpz_poly_t res, slong D)"
