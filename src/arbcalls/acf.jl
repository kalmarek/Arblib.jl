###
### **acf.h** -- complex floating-point numbers
###

### Types, macros and constants

### Memory management
arbcall"void acf_init(acf_t x)"
arbcall"void acf_clear(acf_t x)"
arbcall"void acf_swap(acf_t z, acf_t x)"
arbcall"slong acf_allocated_bytes(const acf_t x)"

### Basic manipulation
#ni arbcall"arf_ptr acf_real_ptr(acf_t z)"
#ni arbcall"arf_ptr acf_imag_ptr(acf_t z)"
arbcall"void acf_set(acf_t z, const acf_t x)"
arbcall"int acf_equal(const acf_t x, const acf_t y)"

### Arithmetic
arbcall"int acf_add(acf_t res, const acf_t x, const acf_t y, slong prec, arf_rnd_t rnd)"
arbcall"int acf_sub(acf_t res, const acf_t x, const acf_t y, slong prec, arf_rnd_t rnd)"
arbcall"int acf_mul(acf_t res, const acf_t x, const acf_t y, slong prec, arf_rnd_t rnd)"

### Approximate arithmetic
arbcall"void acf_approx_inv(acf_t res, const acf_t x, slong prec, arf_rnd_t rnd)"
arbcall"void acf_approx_div(acf_t res, const acf_t x, const acf_t y, slong prec, arf_rnd_t rnd)"
arbcall"void acf_approx_sqrt(acf_t res, const acf_t x, slong prec, arf_rnd_t rnd)"
#ni arbcall"void acf_approx_dot(acf_t res, const acf_t initial, int subtract, acf_srcptr x, slong xstep, acf_srcptr y, slong ystep, slong len, slong prec, arf_rnd_t rnd)"
