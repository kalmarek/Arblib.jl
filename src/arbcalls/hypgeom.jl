###
### **hypgeom.h** -- support for hypergeometric series
###

### Strategy for error bounding

### Types, macros and constants

### Memory management
#ni arbcall"void hypgeom_init(hypgeom_t hyp)"
#ni arbcall"void hypgeom_clear(hypgeom_t hyp)"

### Error bounding
arbcall"slong hypgeom_estimate_terms(const mag_t z, int r, slong d)"
arbcall"slong hypgeom_bound(mag_t error, int r, slong C, slong D, slong K, const mag_t TK, const mag_t z, slong prec)"
#ni arbcall"void hypgeom_precompute(hypgeom_t hyp)"

### Summation
#ni arbcall"void arb_hypgeom_sum(arb_t P, arb_t Q, const hypgeom_t hyp, slong n, slong prec)"
#ni arbcall"void arb_hypgeom_infsum(arb_t P, arb_t Q, hypgeom_t hyp, slong tol, slong prec)"
