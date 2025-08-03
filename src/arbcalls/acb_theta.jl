###
### **acb_theta.h** -- Riemann theta functions
###

### Main user functions
arbcall"ulong acb_theta_char_set_slong_vec(const slong * vec, slong len)"
arbcall"void acb_theta_one(acb_t th, acb_srcptr z, const acb_mat_t tau, ulong ab, slong prec)"
arbcall"void acb_theta_all(acb_ptr th, acb_srcptr z, const acb_mat_t tau, int sqr, slong prec)"
arbcall"void acb_theta_jet(acb_ptr th, acb_srcptr zs, slong nb, const acb_mat_t tau, slong ord, ulong ab, int all, int sqr, slong prec)"

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
arbcall"void acb_siegel_cho_yinv(arb_mat_t cho, arb_mat_t yinv, const acb_mat_t tau, slong prec)"
#ni arbcall"void acb_siegel_reduce(fmpz_mat_t mat, const acb_mat_t tau, slong prec)"
arbcall"int acb_siegel_is_reduced(const acb_mat_t tau, slong tol_exp, slong prec)"
#ni arbcall"slong acb_siegel_kappa(acb_t sqrtdet, const fmpz_mat_t mat, const acb_mat_t tau, int sqr, slong prec)"
#ni arbcall"slong acb_siegel_kappa2(const fmpz_mat_t mat)"
#ns arbcall"void acb_siegel_randtest(acb_mat_t tau, flint_rand_t state, slong prec, slong mag_bits)"
#ns arbcall"void acb_siegel_randtest_reduced(acb_mat_t tau, flint_rand_t state, slong prec, slong mag_bits)"
#ns arbcall"void acb_siegel_randtest_compact(acb_mat_t tau, flint_rand_t state, int exact, slong prec)"
#ns arbcall"void acb_siegel_randtest_vec(acb_ptr z, flint_rand_t state, slong g, slong prec)"
#ns arbcall"void acb_siegel_randtest_vec_reduced(acb_ptr zs, flint_rand_t state, slong nb, const acb_mat_t tau, int exact, slong prec)"

### Theta characteristics
arbcall"int acb_theta_char_bit(ulong ch, slong j, slong n)"
arbcall"void acb_theta_char_get_arb(arb_ptr v, ulong a, slong g)"
arbcall"void acb_theta_char_get_acb(acb_ptr v, ulong a, slong g)"
arbcall"slong acb_theta_char_dot(ulong a, ulong b, slong g)"
arbcall"slong acb_theta_char_dot_slong(ulong a, const slong * n, slong g)"
arbcall"int acb_theta_char_is_even(ulong ab, slong g)"
#ni arbcall"void acb_theta_char_table(ulong * ch, slong * e, const fmpz_mat_t mat, ulong ab, int all)"
#ni arbcall"void acb_theta_char_shuffle(acb_ptr res, const fmpz_mat_t mat, acb_srcptr th, int sqr, slong prec)"

### Toolbox for derivatives
arbcall"slong acb_theta_jet_nb(slong ord, slong g)"
arbcall"slong acb_theta_jet_total_order(const slong * tup, slong g)"
arbcall"void acb_theta_jet_tuples(slong * tups, slong ord, slong g)"
arbcall"slong acb_theta_jet_index(const slong * tup, slong g)"
arbcall"void acb_theta_jet_mul(acb_ptr res, acb_srcptr v1, acb_srcptr v2, slong ord, slong g, slong prec)"
arbcall"void acb_theta_jet_compose(acb_ptr res, acb_srcptr v, const acb_mat_t N, slong ord, slong prec)"
arbcall"void acb_theta_jet_exp_pi_i(acb_ptr res, arb_srcptr a, slong ord, slong g, slong prec)"
arbcall"void acb_theta_jet_exp_qf(acb_ptr res, acb_srcptr z, const acb_mat_t N, slong ord, slong prec)"

### Ellipsoids
#ni arbcall"void acb_theta_eld_init(acb_theta_eld_t E, slong d, slong g)"
#ni arbcall"void acb_theta_eld_clear(acb_theta_eld_t E)"
#ni arbcall"int acb_theta_eld_set(acb_theta_eld_t E, const arb_mat_t C, const arf_t R2, arb_srcptr v)"
#ni arbcall"slong acb_theta_eld_nb_pts(acb_theta_eld_t E)"
#ni arbcall"void acb_theta_eld_points(slong * pts, const acb_theta_eld_t E)"
#ni arbcall"slong acb_theta_eld_box(const acb_theta_eld_t E, slong j)"
#ni arbcall"slong acb_theta_eld_nb_border(acb_theta_eld_t E)"
#ni arbcall"void acb_theta_eld_border(slong * pts, const acb_theta_eld_t E)"
#ni arbcall"int acb_theta_eld_contains(const acb_theta_eld_t E, slong * pt)"
#ni arbcall"void acb_theta_eld_print(const acb_theta_eld_t E)"
arbcall"void acb_theta_eld_distances(arb_ptr ds, acb_srcptr zs, slong nb, const acb_mat_t tau, slong prec)"

### Error bounds in summation algorithms
arbcall"void acb_theta_sum_radius(arf_t R2, arf_t eps, const arb_mat_t cho, slong ord, slong prec)"
arbcall"void acb_theta_sum_jet_radius(arf_t R2, arf_t eps, const arb_mat_t cho, arb_srcptr v, slong ord, slong prec)"
arbcall"void acb_theta_sum_term(acb_t res, acb_srcptr z, const acb_mat_t tau, slong * tup, slong * n, slong prec)"
arbcall"slong acb_theta_sum_addprec(const arb_t d)"

### Context structures in summation algorithms
#ni arbcall"void acb_theta_ctx_tau_init(acb_theta_ctx_tau_t ctx, int allow_shift, slong g)"
#ni arbcall"void acb_theta_ctx_tau_clear(acb_theta_ctx_tau_t ctx)"
#ni arbcall"void acb_theta_ctx_z_init(acb_theta_ctx_z_t ctx, slong g)"
#ni arbcall"void acb_theta_ctx_z_clear(acb_theta_ctx_z_t ctx)"
#ni arbcall"acb_theta_ctx_z_struct * acb_theta_ctx_z_vec_init(slong nb, slong g)"
#ni arbcall"void acb_theta_ctx_z_vec_clear(acb_theta_ctx_z_struct * vec, slong nb)"
arbcall"void acb_theta_ctx_exp_inv(acb_t exp_inv, const acb_t exp, const acb_t x, int is_real, slong prec)"
arbcall"void acb_theta_ctx_sqr_inv(acb_t sqr_inv, const acb_t inv, const acb_t sqr, int is_real, slong prec)"
#ni arbcall"void acb_theta_ctx_tau_set(acb_theta_ctx_tau_t ctx, const acb_mat_t tau, slong prec)"
#ni arbcall"void acb_theta_ctx_tau_dupl(acb_theta_ctx_tau_t ctx, slong prec)"
#ni arbcall"int acb_theta_ctx_tau_overlaps(const acb_theta_ctx_tau_t ctx1, const acb_theta_ctx_tau_t ctx2)"
#ni arbcall"void acb_theta_ctx_z_set(acb_theta_ctx_z_t ctx, acb_srcptr z, const acb_theta_ctx_tau_t ctx_tau, slong prec)"
#ni arbcall"void acb_theta_ctx_z_dupl(acb_theta_ctx_z_t ctx, slong prec)"
#ni arbcall"void acb_theta_ctx_z_add_real(acb_theta_ctx_z_t res, const acb_theta_ctx_z_t ctx, const acb_theta_ctx_z_t ctx_real, slong prec)"
#ni arbcall"void acb_theta_ctx_z_common_v(arb_ptr v, const acb_theta_ctx_z_struct * vec, slong nb, slong prec)"
#ni arbcall"int acb_theta_ctx_z_overlaps(const acb_theta_ctx_z_t ctx1, const acb_theta_ctx_z_t ctx2)"

### Summation algorithms
#ni arbcall"void acb_theta_sum_sqr_pow(acb_ptr * sqr_pow, const acb_mat_t exp_tau, const acb_theta_eld_t E, slong prec)"
#ni arbcall"void acb_theta_sum_work(acb_ptr th, slong len, acb_srcptr exp_z, acb_srcptr exp_z_inv, const acb_mat_t exp_tau, const acb_mat_t exp_tau_inv, const acb_ptr * sqr_pow, const acb_theta_eld_t E, slong ord, slong prec, acb_theta_sum_worker_t worker)"
#ni arbcall"void acb_theta_sum(acb_ptr th, const acb_theta_ctx_z_struct * vec, slong nb, const acb_theta_ctx_tau_t ctx_tau, arb_srcptr distances, int all_a, int all_b, int tilde, slong prec)"
#ni arbcall"void acb_theta_sum_jet(acb_ptr th, const acb_theta_ctx_z_struct * vec, slong nb, const acb_theta_ctx_tau_t ctx_tau, slong ord, int all_a, int all_b, slong prec)"

### AGM steps
arbcall"void acb_theta_agm_sqrt(acb_ptr res, acb_srcptr a, acb_srcptr roots, slong nb, slong prec)"
arbcall"void acb_theta_agm_mul(acb_ptr res, acb_srcptr a1, acb_srcptr a2, slong g, int all, slong prec)"
arbcall"void acb_theta_agm_mul_tight(acb_ptr res, acb_srcptr a0, acb_srcptr a, arb_srcptr d0, arb_srcptr d, slong g, int all, slong prec)"

### Quasilinear algorithms on reduced input
arbcall"int acb_theta_ql_nb_steps(slong * pattern, const acb_mat_t tau, int cst, slong prec)"
#ni arbcall"int acb_theta_ql_lower_dim(acb_ptr * new_zs, acb_ptr * cofactors, slong ** pts, slong * nb, arf_t err, slong * fullprec, acb_srcptr z, const acb_mat_t tau, arb_srcptr distances, slong s, ulong a, slong prec)"
arbcall"void acb_theta_ql_recombine(acb_ptr th, acb_srcptr th0, acb_srcptr cofactors, const slong * pts, slong nb, const arf_t err, slong fullprec, slong s, ulong a, int all, slong g, slong prec)"
arbcall"int acb_theta_ql_setup(acb_ptr rts, acb_ptr rts_all, acb_ptr t, slong * guard, slong * easy_steps, acb_srcptr zs, slong nb, const acb_mat_t tau, arb_srcptr distances, slong nb_steps, int all, slong prec)"
arbcall"void acb_theta_ql_exact(acb_ptr th, acb_srcptr zs, slong nb, const acb_mat_t tau, const slong * pattern, int all, int shifted_prec, slong prec)"
arbcall"void acb_theta_ql_local_bound(arb_t c, arb_t rho, acb_srcptr z, const acb_mat_t tau, slong ord)"
arbcall"void acb_theta_ql_jet_error(arb_ptr err, acb_srcptr z, const acb_mat_t tau, acb_srcptr dth, slong ord, slong prec)"
arbcall"void acb_theta_ql_jet_fd(acb_ptr th, acb_srcptr zs, slong nb, const acb_mat_t tau, slong ord, int all, slong prec)"
arbcall"void acb_theta_ql_jet(acb_ptr th, acb_srcptr zs, slong nb, const acb_mat_t tau, slong ord, int all, slong prec)"

### Reduction and main functions
arbcall"void acb_theta_jet_notransform(acb_ptr th, acb_srcptr zs, slong nb, const acb_mat_t tau, slong ord, ulong ab, int all, int sqr, slong prec)"
#ni arbcall"int acb_theta_reduce_tau(acb_ptr new_zs, acb_mat_t new_tau, fmpz_mat_t mat, acb_mat_t N, acb_mat_t ct, acb_ptr exps, acb_srcptr zs, slong nb, const acb_mat_t tau, slong prec)"
arbcall"int acb_theta_reduce_z(acb_ptr new_zs, arb_ptr rs, acb_ptr cs, acb_srcptr zs, slong nb, const acb_mat_t tau, slong prec)"

### Dimension 2 specifics
arbcall"void acb_theta_g2_detk_symj(acb_poly_t res, const acb_mat_t m, const acb_poly_t f, slong k, slong j, slong prec)"
arbcall"void acb_theta_g2_transvectant(acb_poly_t res, const acb_poly_t g, const acb_poly_t h, slong m, slong n, slong k, int lead, slong prec)"
#ni arbcall"slong acb_theta_g2_character(const fmpz_mat_t mat)"
arbcall"void acb_theta_g2_even_weight(acb_t psi4, acb_t psi6, acb_t chi10, acb_t chi12, acb_srcptr th2, slong prec)"
arbcall"void acb_theta_g2_chi5(acb_t res, acb_srcptr th, slong prec)"
arbcall"void acb_theta_g2_chi35(acb_t res, acb_srcptr th, slong prec)"
arbcall"void acb_theta_g2_chi3_6(acb_poly_t res, acb_srcptr dth, slong prec)"
arbcall"void acb_theta_g2_sextic_chi5(acb_poly_t res, acb_t chi5, const acb_mat_t tau, slong prec)"
#ni arbcall"void acb_theta_g2_covariants(acb_poly_struct * res, const acb_poly_t f, int lead, slong prec)"

### Tests

### Profiling
