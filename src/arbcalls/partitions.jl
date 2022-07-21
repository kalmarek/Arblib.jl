###
### **partitions.h** -- computation of the partition function
###

### Computation of the partition function
#ni arbcall"void partitions_rademacher_bound(arf_t b, const fmpz_t n, ulong N)"
#ni arbcall"void partitions_hrr_sum_arb(arb_t x, const fmpz_t n, slong N0, slong N, int use_doubles)"
#ni arbcall"void partitions_fmpz_fmpz(fmpz_t p, const fmpz_t n, int use_doubles)"
#ni arbcall"void partitions_fmpz_ui(fmpz_t p, ulong n)"
#ni arbcall"void partitions_fmpz_ui_using_doubles(fmpz_t p, ulong n)"
#ni arbcall"void partitions_leading_fmpz(arb_t res, const fmpz_t n, slong prec)"
