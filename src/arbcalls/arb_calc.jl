###
### **arb_calc.h** -- calculus with real-valued functions
###

### Types, macros and constants

### Debugging

### Subdivision-based root finding
#ni arbcall"void arf_interval_init(arf_interval_t v)"
#ni arbcall"void arf_interval_clear(arf_interval_t v)"
#ni arbcall"arf_interval_ptr _arf_interval_vec_init(slong n)"
#ni arbcall"void _arf_interval_vec_clear(arf_interval_ptr v, slong n)"
#ni arbcall"void arf_interval_set(arf_interval_t v, const arf_interval_t u)"
#ni arbcall"void arf_interval_swap(arf_interval_t v, arf_interval_t u)"
#ni arbcall"void arf_interval_get_arb(arb_t x, const arf_interval_t v, slong prec)"
#ni arbcall"void arf_interval_printd(const arf_interval_t v, slong n)"
#ns arbcall"void arf_interval_fprintd(FILE * file, const arf_interval_t v, slong n)"
#ni arbcall"slong arb_calc_isolate_roots(arf_interval_ptr * found, int ** flags, arb_calc_func_t func, void * param, const arf_interval_t interval, slong maxdepth, slong maxeval, slong maxfound, slong prec)"
#ni arbcall"int arb_calc_refine_root_bisect(arf_interval_t r, arb_calc_func_t func, void * param, const arf_interval_t start, slong iter, slong prec)"

### Newton-based root finding
#ni arbcall"void arb_calc_newton_conv_factor(arf_t conv_factor, arb_calc_func_t func, void * param, const arb_t conv_region, slong prec)"
#ni arbcall"int arb_calc_newton_step(arb_t xnew, arb_calc_func_t func, void * param, const arb_t x, const arb_t conv_region, const arf_t conv_factor, slong prec)"
#ni arbcall"int arb_calc_refine_root_newton(arb_t r, arb_calc_func_t func, void * param, const arb_t start, const arb_t conv_region, const arf_t conv_factor, slong eval_extra_prec, slong prec)"
