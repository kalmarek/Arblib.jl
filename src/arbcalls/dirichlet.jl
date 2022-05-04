###
### **dirichlet.h** -- Dirichlet characters
###

### Dirichlet characters

### Multiplicative group modulo *q*
#ni arbcall"void dirichlet_group_init(dirichlet_group_t G, ulong q)"
#ni arbcall"void dirichlet_subgroup_init(dirichlet_group_t H, const dirichlet_group_t G, ulong h)"
#ni arbcall"void dirichlet_group_clear(dirichlet_group_t G)"
#ni arbcall"ulong dirichlet_group_size(const dirichlet_group_t G)"
#ni arbcall"ulong dirichlet_group_num_primitive(const dirichlet_group_t G)"
#ni arbcall"void dirichlet_group_dlog_precompute(dirichlet_group_t G, ulong num)"
#ni arbcall"void dirichlet_group_dlog_clear(dirichlet_group_t G, ulong num)"

### Character type
#ni arbcall"void dirichlet_char_init(dirichlet_char_t chi, const dirichlet_group_t G)"
#ni arbcall"void dirichlet_char_clear(dirichlet_char_t chi)"
#ni arbcall"void dirichlet_char_print(const dirichlet_group_t G, const dirichlet_char_t chi)"
#ni arbcall"void dirichlet_char_log(dirichlet_char_t x, const dirichlet_group_t G, ulong m)"
#ni arbcall"ulong dirichlet_char_exp(const dirichlet_group_t G, const dirichlet_char_t x)"
#ni arbcall"ulong _dirichlet_char_exp(dirichlet_char_t x, const dirichlet_group_t G)"
#ni arbcall"void dirichlet_char_one(dirichlet_char_t x, const dirichlet_group_t G)"
#ni arbcall"void dirichlet_char_first_primitive(dirichlet_char_t x, const dirichlet_group_t G)"
#ni arbcall"void dirichlet_char_set(dirichlet_char_t x, const dirichlet_group_t G, const dirichlet_char_t y)"
#ni arbcall"int dirichlet_char_next(dirichlet_char_t x, const dirichlet_group_t G)"
#ni arbcall"int dirichlet_char_next_primitive(dirichlet_char_t x, const dirichlet_group_t G)"
#ni arbcall"ulong dirichlet_index_char(const dirichlet_group_t G, const dirichlet_char_t x)"
#ni arbcall"void dirichlet_char_index(dirichlet_char_t x, const dirichlet_group_t G, ulong j)"
#ni arbcall"int dirichlet_char_eq(const dirichlet_char_t x, const dirichlet_char_t y)"
#ni arbcall"int dirichlet_char_eq_deep(const dirichlet_group_t G, const dirichlet_char_t x, const dirichlet_char_t y)"

### Character properties
#ni arbcall"int dirichlet_char_is_principal(const dirichlet_group_t G, const dirichlet_char_t chi)"
#ni arbcall"ulong dirichlet_conductor_ui(const dirichlet_group_t G, ulong a)"
#ni arbcall"ulong dirichlet_conductor_char(const dirichlet_group_t G, const dirichlet_char_t x)"
#ni arbcall"int dirichlet_parity_ui(const dirichlet_group_t G, ulong a)"
#ni arbcall"int dirichlet_parity_char(const dirichlet_group_t G, const dirichlet_char_t x)"
#ni arbcall"ulong dirichlet_order_ui(const dirichlet_group_t G, ulong a)"
#ni arbcall"ulong dirichlet_order_char(const dirichlet_group_t G, const dirichlet_char_t x)"
#ni arbcall"int dirichlet_char_is_real(const dirichlet_group_t G, const dirichlet_char_t chi)"
#ni arbcall"int dirichlet_char_is_primitive(const dirichlet_group_t G, const dirichlet_char_t chi)"

### Character evaluation
#ni arbcall"ulong dirichlet_pairing(const dirichlet_group_t G, ulong m, ulong n)"
#ni arbcall"ulong dirichlet_pairing_char(const dirichlet_group_t G, const dirichlet_char_t chi, const dirichlet_char_t psi)"
#ni arbcall"ulong dirichlet_chi(const dirichlet_group_t G, const dirichlet_char_t chi, ulong n)"
#ni arbcall"void dirichlet_chi_vec(ulong * v, const dirichlet_group_t G, const dirichlet_char_t chi, slong nv)"
#ni arbcall"void dirichlet_chi_vec_order(ulong * v, const dirichlet_group_t G, const dirichlet_char_t chi, ulong order, slong nv)"

### Character operations
#ni arbcall"void dirichlet_char_mul(dirichlet_char_t chi12, const dirichlet_group_t G, const dirichlet_char_t chi1, const dirichlet_char_t chi2)"
#ni arbcall"void dirichlet_char_pow(dirichlet_char_t c, const dirichlet_group_t G, const dirichlet_char_t a, ulong n)"
#ni arbcall"void dirichlet_char_lift(dirichlet_char_t chi_G, const dirichlet_group_t G, const dirichlet_char_t chi_H, const dirichlet_group_t H)"
#ni arbcall"void dirichlet_char_lower(dirichlet_char_t chi_H, const dirichlet_group_t H, const dirichlet_char_t chi_G, const dirichlet_group_t G)"
