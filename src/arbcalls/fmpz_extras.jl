###
### **fmpz_extras.h** -- extra methods for FLINT integers
###

### Memory-related methods
#ni arbcall"slong fmpz_allocated_bytes(const fmpz_t x)"

### Convenience methods
#ni arbcall"void fmpz_adiv_q_2exp(fmpz_t z, const fmpz_t x, flint_bitcnt_t exp)"
#ni arbcall"void fmpz_ui_mul_ui(fmpz_t x, ulong a, ulong b)"
#ni arbcall"void fmpz_max(fmpz_t z, const fmpz_t x, const fmpz_t y)"
#ni arbcall"void fmpz_min(fmpz_t z, const fmpz_t x, const fmpz_t y)"

### Inlined arithmetic
#ni arbcall"void fmpz_add_inline(fmpz_t z, const fmpz_t x, const fmpz_t y)"
#ni arbcall"void fmpz_add_si_inline(fmpz_t z, const fmpz_t x, slong y)"
#ni arbcall"void fmpz_add_ui_inline(fmpz_t z, const fmpz_t x, ulong y)"
#ni arbcall"void fmpz_sub_si_inline(fmpz_t z, const fmpz_t x, slong y)"
#ni arbcall"void fmpz_add2_fmpz_si_inline(fmpz_t z, const fmpz_t x, const fmpz_t y, slong c)"
#ni arbcall"mp_size_t _fmpz_size(const fmpz_t x)"
#ni arbcall"slong _fmpz_sub_small(const fmpz_t x, const fmpz_t y)"
#ni arbcall"void _fmpz_set_si_small(fmpz_t x, slong v)"

### Low-level conversions
#ni arbcall"void fmpz_set_mpn_large(fmpz_t z, mp_srcptr src, mp_size_t n, int negative)"
#ni arbcall"void fmpz_lshift_mpn(fmpz_t z, mp_srcptr src, mp_size_t n, int negative, flint_bitcnt_t shift)"
