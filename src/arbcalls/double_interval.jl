###
### **double_interval.h** -- double-precision interval arithmetic and helpers
###

### Types, macros and constants

### Basic manipulation
#ni arbcall"di_t di_interval(double a, double b)"
#ni arbcall"di_t arb_get_di(const arb_t x)"
#ni arbcall"void arb_set_di(arb_t res, di_t x, slong prec)"
#ni arbcall"void di_print(di_t x)"
#ns arbcall"double d_randtest2(flint_rand_t state)"
#ns arbcall"di_t di_randtest(flint_rand_t state)"

### Arithmetic
#ni arbcall"di_t di_neg(di_t x)"

### Fast arithmetic
#ni arbcall"di_t di_fast_add(di_t x, di_t y)"
#ni arbcall"di_t di_fast_sub(di_t x, di_t y)"
#ni arbcall"di_t di_fast_mul(di_t x, di_t y)"
#ni arbcall"di_t di_fast_div(di_t x, di_t y)"
#ni arbcall"di_t di_fast_sqr(di_t x)"
#ni arbcall"di_t di_fast_add_d(di_t x, double y)"
#ni arbcall"di_t di_fast_sub_d(di_t x, double y)"
#ni arbcall"di_t di_fast_mul_d(di_t x, double y)"
#ni arbcall"di_t di_fast_div_d(di_t x, double y)"
#ni arbcall"di_t di_fast_log_nonnegative(di_t x)"
#ni arbcall"di_t di_fast_mid(di_t x)"
#ni arbcall"double di_fast_ubound_radius(di_t x)"
