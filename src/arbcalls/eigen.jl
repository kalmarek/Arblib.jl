# calls to prepare artificial julia functions accepting C_NULL

arbcall"int acb_mat_approx_eig_qr(acb_ptr E, void * L, acb_mat_t R, const acb_mat_t A, const mag_t tol, slong maxiter, slong prec)"
arbcall"int acb_mat_approx_eig_qr(acb_ptr E, void * L, acb_mat_t R, const acb_mat_t A, void * tol, slong maxiter, slong prec)"

arbcall"int acb_mat_approx_eig_qr(acb_ptr E, acb_mat_t L, void * R, const acb_mat_t A, const mag_t tol, slong maxiter, slong prec)"
arbcall"int acb_mat_approx_eig_qr(acb_ptr E, acb_mat_t L, void * R, const acb_mat_t A, void * tol, slong maxiter, slong prec)"

arbcall"int acb_mat_approx_eig_qr(acb_ptr E, void * L, void * R, const acb_mat_t A, const mag_t tol, slong maxiter, slong prec)"
arbcall"int acb_mat_approx_eig_qr(acb_ptr E, void * L, void * R, const acb_mat_t A, void * tol, slong maxiter, slong prec)"

arbcall"void acb_mat_eig_enclosure_rump(acb_t lambda, void * J, acb_mat_t R, const acb_mat_t A, const acb_t lambda_approx, const acb_mat_t R_approx, slong prec)"

arbcall"int acb_mat_eig_simple_rump(acb_ptr E, void * L, acb_mat_t R, const acb_mat_t A, acb_srcptr E_approx, const acb_mat_t R_approx, slong prec)"
arbcall"int acb_mat_eig_simple_rump(acb_ptr E, acb_mat_t L, void * R, const acb_mat_t A, acb_srcptr E_approx, const acb_mat_t R_approx, slong prec)"
arbcall"int acb_mat_eig_simple_rump(acb_ptr E, void * L, void * R, const acb_mat_t A, acb_srcptr E_approx, const acb_mat_t R_approx, slong prec)"

arbcall"int acb_mat_eig_simple_vdhoeven_mourrain(acb_ptr E, void * L, acb_mat_t R, const acb_mat_t A, acb_srcptr E_approx, const acb_mat_t R_approx, slong prec)"
arbcall"int acb_mat_eig_simple_vdhoeven_mourrain(acb_ptr E, acb_mat_t L, void * R, const acb_mat_t A, acb_srcptr E_approx, const acb_mat_t R_approx, slong prec)"
arbcall"int acb_mat_eig_simple_vdhoeven_mourrain(acb_ptr E, void * L, void * R, const acb_mat_t A, acb_srcptr E_approx, const acb_mat_t R_approx, slong prec)"

arbcall"int acb_mat_eig_simple(acb_ptr E, void * L, acb_mat_t R, const acb_mat_t A, acb_srcptr E_approx, const acb_mat_t R_approx, slong prec)"
arbcall"int acb_mat_eig_simple(acb_ptr E, acb_mat_t L, void * R, const acb_mat_t A, acb_srcptr E_approx, const acb_mat_t R_approx, slong prec)"
arbcall"int acb_mat_eig_simple(acb_ptr E, void * L, void * R, const acb_mat_t A, acb_srcptr E_approx, const acb_mat_t R_approx, slong prec)"
