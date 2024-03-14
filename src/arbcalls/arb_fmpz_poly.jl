###
### **arb_fmpz_poly.h** -- extra methods for integer polynomials
###

### Evaluation
#ni arbcall"void _arb_fmpz_poly_evaluate_arb_horner(arb_t res, const fmpz * poly, slong len, const arb_t x, slong prec)"
#ni arbcall"void arb_fmpz_poly_evaluate_arb_horner(arb_t res, const fmpz_poly_t poly, const arb_t x, slong prec)"
#ni arbcall"void _arb_fmpz_poly_evaluate_arb_rectangular(arb_t res, const fmpz * poly, slong len, const arb_t x, slong prec)"
#ni arbcall"void arb_fmpz_poly_evaluate_arb_rectangular(arb_t res, const fmpz_poly_t poly, const arb_t x, slong prec)"
#ni arbcall"void _arb_fmpz_poly_evaluate_arb(arb_t res, const fmpz * poly, slong len, const arb_t x, slong prec)"
#ni arbcall"void arb_fmpz_poly_evaluate_arb(arb_t res, const fmpz_poly_t poly, const arb_t x, slong prec)"
#ni arbcall"void _arb_fmpz_poly_evaluate_acb_horner(acb_t res, const fmpz * poly, slong len, const acb_t x, slong prec)"
#ni arbcall"void arb_fmpz_poly_evaluate_acb_horner(acb_t res, const fmpz_poly_t poly, const acb_t x, slong prec)"
#ni arbcall"void _arb_fmpz_poly_evaluate_acb_rectangular(acb_t res, const fmpz * poly, slong len, const acb_t x, slong prec)"
#ni arbcall"void arb_fmpz_poly_evaluate_acb_rectangular(acb_t res, const fmpz_poly_t poly, const acb_t x, slong prec)"
#ni arbcall"void _arb_fmpz_poly_evaluate_acb(acb_t res, const fmpz * poly, slong len, const acb_t x, slong prec)"
#ni arbcall"void arb_fmpz_poly_evaluate_acb(acb_t res, const fmpz_poly_t poly, const acb_t x, slong prec)"

### Utility methods
#ni arbcall"ulong arb_fmpz_poly_deflation(const fmpz_poly_t poly)"
#ni arbcall"void arb_fmpz_poly_deflate(fmpz_poly_t res, const fmpz_poly_t poly, ulong deflation)"

### Polynomial roots
#ni arbcall"void arb_fmpz_poly_complex_roots(acb_ptr roots, const fmpz_poly_t poly, int flags, slong prec)"

### Special polynomials
#ni arbcall"void arb_fmpz_poly_gauss_period_minpoly(fmpz_poly_t res, ulong q, ulong n)"
