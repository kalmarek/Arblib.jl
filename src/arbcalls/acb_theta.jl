###
### **acb_theta.h** -- Riemann theta functions
###

### Main user functions
arbcall"void acb_theta_all(acb_ptr th, acb_srcptr z, const acb_mat_t tau, int sqr, slong prec)"
arbcall"void acb_theta_naive_fixed_ab(acb_ptr th, ulong ab, acb_srcptr zs, slong nb, const acb_mat_t tau, slong prec)"
arbcall"void acb_theta_naive_all(acb_ptr th, acb_srcptr zs, slong nb, const acb_mat_t tau, slong prec)"
arbcall"void acb_theta_jet_all(acb_ptr dth, acb_srcptr z, const acb_mat_t tau, slong ord, slong prec)"
arbcall"void acb_theta_jet_naive_fixed_ab(acb_ptr dth, ulong ab, acb_srcptr z, const acb_mat_t tau, slong ord, slong prec)"
arbcall"void acb_theta_jet_naive_all(acb_ptr dth, acb_srcptr z, const acb_mat_t tau, slong ord, slong prec)"

### Example of usage

### The Siegel modular group
#ni arbcall"slong sp2gz_dim(const fmpz_mat_t mat)"
#ni arbcall"void sp2gz_set_blocks(fmpz_mat_t mat, const fmpz_mat_t alpha, const fmpz_mat_t beta, const fmpz_mat_t gamma, const fmpz_mat_t delta)"
#ni arbcall"void sp2gz_j(fmpz_mat_t mat)"
#ni arbcall"void sp2gz_block_diag(fmpz_mat_t mat, const fmpz_mat_t U)"
#ni arbcall"void sp2gz_trig(fmpz_mat_t mat, const fmpz_mat_t S)"
#ni arbcall"void sp2gz_embed(fmpz_mat_t res, const fmpz_mat_t mat)"
#ni arbcall"void sp2gz_restrict(fmpz_mat_t res, const fmpz_mat_t mat)"
arbcall"slong sp2gz_nb_fundamental(slong g)"
#ni arbcall"void sp2gz_fundamental(fmpz_mat_t mat, slong j)"
#ni arbcall"int sp2gz_is_correct(const fmpz_mat_t mat)"
#ni arbcall"int sp2gz_is_j(const fmpz_mat_t mat)"
#ni arbcall"int sp2gz_is_block_diag(const fmpz_mat_t mat)"
#ni arbcall"int sp2gz_is_trig(const fmpz_mat_t mat)"
#ni arbcall"int sp2gz_is_embedded(fmpz_mat_t res, const fmpz_mat_t mat)"
#ni arbcall"void sp2gz_inv(fmpz_mat_t inv, const fmpz_mat_t mat)"
#ni arbcall"fmpz_mat_struct * sp2gz_decompose(slong * nb, const fmpz_mat_t mat)"
#ni arbcall"void sp2gz_randtest(fmpz_mat_t mat, flint_rand_t state, slong bits)"

### The Siegel half space
#ni arbcall"void acb_siegel_cocycle(acb_mat_t c, const fmpz_mat_t mat, const acb_mat_t tau, slong prec)"
#ni arbcall"void acb_siegel_transform_cocycle_inv(acb_mat_t w, acb_mat_t c, acb_mat_t cinv, const fmpz_mat_t mat, const acb_mat_t tau, slong prec)"
#ni arbcall"void acb_siegel_transform(acb_mat_t w, const fmpz_mat_t mat, const acb_mat_t tau, slong prec)"
#ni arbcall"void acb_siegel_transform_z(acb_ptr r, acb_mat_t w, const fmpz_mat_t mat, acb_srcptr z, const acb_mat_t tau, slong prec)"
arbcall"void acb_siegel_cho(arb_mat_t C, const acb_mat_t tau, slong prec)"
arbcall"void acb_siegel_yinv(arb_mat_t Yinv, const acb_mat_t tau, slong prec)"
#ni arbcall"void acb_siegel_reduce(fmpz_mat_t mat, const acb_mat_t tau, slong prec)"
arbcall"int acb_siegel_is_reduced(const acb_mat_t tau, slong tol_exp, slong prec)"
#ns arbcall"void acb_siegel_randtest(acb_mat_t tau, flint_rand_t state, slong prec, slong mag_bits)"
#ns arbcall"void acb_siegel_randtest_reduced(acb_mat_t tau, flint_rand_t state, slong prec, slong mag_bits)"
#ns arbcall"void acb_siegel_randtest_vec(acb_ptr z, flint_rand_t state, slong g, slong prec)"

### Theta characteristics
arbcall"void acb_theta_char_get_slong(slong * n, ulong a, slong g)"
arbcall"ulong acb_theta_char_get_a(const slong * n, slong g)"
arbcall"void acb_theta_char_get_arb(arb_ptr v, ulong a, slong g)"
arbcall"void acb_theta_char_get_acb(acb_ptr v, ulong a, slong g)"
arbcall"slong acb_theta_char_dot(ulong a, ulong b, slong g)"
arbcall"slong acb_theta_char_dot_slong(ulong a, const slong * n, slong g)"
arbcall"void acb_theta_char_dot_acb(acb_t x, ulong a, acb_srcptr z, slong g, slong prec)"
arbcall"int acb_theta_char_is_even(ulong ab, slong g)"
arbcall"int acb_theta_char_is_goepel(ulong ch1, ulong ch2, ulong ch3, ulong ch4, slong g)"
arbcall"int acb_theta_char_is_syzygous(ulong ch1, ulong ch2, ulong ch3, slong g)"

### Ellipsoids: types and macros

### Ellipsoids: memory management and computations
#ni arbcall"void acb_theta_eld_init(acb_theta_eld_t E, slong d, slong g)"
#ni arbcall"void acb_theta_eld_clear(acb_theta_eld_t E)"
#ni arbcall"int acb_theta_eld_set(acb_theta_eld_t E, const arb_mat_t C, const arf_t R2, arb_srcptr v)"
#ni arbcall"void acb_theta_eld_points(slong * pts, const acb_theta_eld_t E)"
#ni arbcall"void acb_theta_eld_border(slong * pts, const acb_theta_eld_t E)"
#ni arbcall"int acb_theta_eld_contains(const acb_theta_eld_t E, slong * pt)"
#ni arbcall"void acb_theta_eld_print(const acb_theta_eld_t E)"

### Naive algorithms: error bounds
arbcall"void acb_theta_naive_radius(arf_t R2, arf_t eps, const arb_mat_t C, slong ord, slong prec)"
arbcall"void acb_theta_naive_reduce(arb_ptr v, acb_ptr new_zs, arb_ptr as, acb_ptr cs, arb_ptr us, acb_srcptr zs, slong nb, const acb_mat_t tau, slong prec)"
arbcall"void acb_theta_naive_term(acb_t res, acb_srcptr z, const acb_mat_t tau, slong * tup, slong * n, slong prec)"

### Naive algorithms: main functions
#ni arbcall"void acb_theta_naive_worker(acb_ptr th, slong len, acb_srcptr zs, slong nb, const acb_mat_t tau, const acb_theta_eld_t E, slong ord, slong prec, acb_theta_naive_worker_t worker)"
arbcall"void acb_theta_naive_00(acb_ptr th, acb_srcptr zs, slong nb, const acb_mat_t tau, slong prec)"
arbcall"void acb_theta_naive_0b(acb_ptr th, acb_srcptr zs, slong nb, const acb_mat_t tau, slong prec)"
arbcall"void acb_theta_naive_fixed_a(acb_ptr th, ulong a, acb_srcptr zs, slong nb, const acb_mat_t tau, slong prec)"

### Naive algorithms for derivatives
arbcall"slong acb_theta_jet_nb(slong ord, slong g)"
arbcall"slong acb_theta_jet_total_order(const slong * tup, slong g)"
arbcall"void acb_theta_jet_tuples(slong * tups, slong ord, slong g)"
arbcall"slong acb_theta_jet_index(const slong * tup, slong g)"
arbcall"void acb_theta_jet_mul(acb_ptr res, acb_srcptr v1, acb_srcptr v2, slong ord, slong g, slong prec)"
arbcall"void acb_theta_jet_compose(acb_ptr res, acb_srcptr v, const acb_mat_t N, slong ord, slong prec)"
arbcall"void acb_theta_jet_exp_pi_i(acb_ptr res, arb_srcptr a, slong ord, slong g, slong prec)"
arbcall"void acb_theta_jet_naive_radius(arf_t R2, arf_t eps, arb_srcptr v, const arb_mat_t C, slong ord, slong prec)"
arbcall"void acb_theta_jet_naive_00(acb_ptr dth, acb_srcptr z, const acb_mat_t tau, slong ord, slong prec)"
arbcall"void acb_theta_jet_error_bounds(arb_ptr err, acb_srcptr z, const acb_mat_t tau, acb_srcptr dth, slong ord, slong prec)"

### Quasi-linear algorithms: presentation

### Quasi-linear algorithms: distances
arbcall"void acb_theta_dist_pt(arb_t d, arb_srcptr v, const arb_mat_t C, slong * n, slong prec)"
arbcall"void acb_theta_dist_lat(arb_t d, arb_srcptr v, const arb_mat_t C, slong prec)"
arbcall"void acb_theta_dist_a0(arb_ptr d, acb_srcptr z, const acb_mat_t tau, slong prec)"
arbcall"slong acb_theta_dist_addprec(const arb_t d)"

### Quasi-linear algorithms: AGM steps
arbcall"void acb_theta_agm_hadamard(acb_ptr res, acb_srcptr a, slong g, slong prec)"
arbcall"void acb_theta_agm_sqrt(acb_ptr res, acb_srcptr a, acb_srcptr rts, slong nb, slong prec)"
arbcall"void acb_theta_agm_mul(acb_ptr res, acb_srcptr a1, acb_srcptr a2, slong g, slong prec)"
arbcall"void acb_theta_agm_mul_tight(acb_ptr res, acb_srcptr a0, acb_srcptr a, arb_srcptr d0, arb_srcptr d, slong g, slong prec)"

### Quasi-linear algorithms: main functions
arbcall"int acb_theta_ql_a0_naive(acb_ptr th, acb_srcptr t, acb_srcptr z, arb_srcptr d0, arb_srcptr d, const acb_mat_t tau, slong guard, slong prec)"
#ni arbcall"int acb_theta_ql_a0_split(acb_ptr th, acb_srcptr t, acb_srcptr z, arb_srcptr d, const acb_mat_t tau, slong s, slong guard, slong prec, acb_theta_ql_worker_t worker)"
#ni arbcall"int acb_theta_ql_a0_steps(acb_ptr th, acb_srcptr t, acb_srcptr z, arb_srcptr d0, arb_srcptr d, const acb_mat_t tau, slong nb_steps, slong s, slong guard, slong prec, acb_theta_ql_worker_t worker)"
arbcall"slong acb_theta_ql_a0_nb_steps(const arb_mat_t C, slong s, slong prec)"
arbcall"int acb_theta_ql_a0(acb_ptr th, acb_srcptr t, acb_srcptr z, arb_srcptr d0, arb_srcptr d, const acb_mat_t tau, slong guard, slong prec)"
arbcall"slong acb_theta_ql_reduce(acb_ptr new_z, acb_t c, arb_t u, slong * n1, acb_srcptr z, const acb_mat_t tau, slong prec)"
arbcall"void acb_theta_ql_all(acb_ptr th, acb_srcptr z, const acb_mat_t tau, int sqr, slong prec)"

### Quasi-linear algorithms: derivatives
arbcall"void acb_theta_jet_ql_bounds(arb_t c, arb_t rho, acb_srcptr z, const acb_mat_t tau, slong ord)"
arbcall"void acb_theta_jet_ql_radius(arf_t eps, arf_t err, const arb_t c, const arb_t rho, slong ord, slong g, slong prec)"
arbcall"void acb_theta_jet_ql_finite_diff(acb_ptr dth, const arf_t eps, const arf_t err, acb_srcptr val, slong ord, slong g, slong prec)"
arbcall"void acb_theta_jet_ql_all(acb_ptr dth, acb_srcptr z, const acb_mat_t tau, slong ord, slong prec)"

### The transformation formula
#ni arbcall"ulong acb_theta_transform_char(slong * e, const fmpz_mat_t mat, ulong ab)"
arbcall"void acb_theta_transform_sqrtdet(acb_t res, const acb_mat_t tau, slong prec)"
#ni arbcall"slong acb_theta_transform_kappa(acb_t sqrtdet, const fmpz_mat_t mat, const acb_mat_t tau, slong prec)"
#ni arbcall"slong acb_theta_transform_kappa2(const fmpz_mat_t mat)"
#ni arbcall"void acb_theta_transform_proj(acb_ptr res, const fmpz_mat_t mat, acb_srcptr th, int sqr, slong prec)"

### Dimension 2 specifics
arbcall"void acb_theta_g2_jet_naive_1(acb_ptr dth, const acb_mat_t tau, slong prec)"
arbcall"void acb_theta_g2_detk_symj(acb_poly_t res, const acb_mat_t m, const acb_poly_t f, slong k, slong j, slong prec)"
arbcall"void acb_theta_g2_transvectant(acb_poly_t res, const acb_poly_t g, const acb_poly_t h, slong m, slong n, slong k, slong prec)"
arbcall"void acb_theta_g2_transvectant_lead(acb_t res, const acb_poly_t g, const acb_poly_t h, slong m, slong n, slong k, slong prec)"
#ni arbcall"slong acb_theta_g2_character(const fmpz_mat_t mat)"
arbcall"void acb_theta_g2_psi4(acb_t res, acb_srcptr th2, slong prec)"
arbcall"void acb_theta_g2_psi6(acb_t res, acb_srcptr th2, slong prec)"
arbcall"void acb_theta_g2_chi10(acb_t res, acb_srcptr th2, slong prec)"
arbcall"void acb_theta_g2_chi12(acb_t res, acb_srcptr th2, slong prec)"
arbcall"void acb_theta_g2_chi5(acb_t res, acb_srcptr th, slong prec)"
arbcall"void acb_theta_g2_chi35(acb_t res, acb_srcptr th, slong prec)"
arbcall"void acb_theta_g2_chi3_6(acb_poly_t res, acb_srcptr dth, slong prec)"
arbcall"void acb_theta_g2_sextic(acb_poly_t res, const acb_mat_t tau, slong prec)"
arbcall"void acb_theta_g2_sextic_chi5(acb_poly_t res, acb_t chi5, const acb_mat_t tau, slong prec)"
#ni arbcall"void acb_theta_g2_covariants(acb_poly_struct * res, const acb_poly_t f, slong prec)"
arbcall"void acb_theta_g2_covariants_lead(acb_ptr res, const acb_poly_t f, slong prec)"

### Tests

### Profiling
