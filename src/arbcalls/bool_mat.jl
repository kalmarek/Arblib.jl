###
### **bool_mat.h** -- matrices over booleans
###

### Types, macros and constants
#ns arbcall"int bool_mat_get_entry(const bool_mat_t mat, slong i, slong j)"
#ns arbcall"void bool_mat_set_entry(bool_mat_t mat, slong i, slong j, int x)"

### Memory management
#ns arbcall"void bool_mat_init(bool_mat_t mat, slong r, slong c)"
#ns arbcall"void bool_mat_clear(bool_mat_t mat)"
#ns arbcall"int bool_mat_is_empty(const bool_mat_t mat)"
#ns arbcall"int bool_mat_is_square(const bool_mat_t mat)"

### Conversions
#ns arbcall"void bool_mat_set(bool_mat_t dest, const bool_mat_t src)"

### Input and output
#ns arbcall"void bool_mat_print(const bool_mat_t mat)"
#ns arbcall"void bool_mat_fprint(FILE * file, const bool_mat_t mat)"

### Value comparisons
#ns arbcall"int bool_mat_equal(const bool_mat_t mat1, const bool_mat_t mat2)"
#ns arbcall"int bool_mat_any(const bool_mat_t mat)"
#ns arbcall"int bool_mat_all(const bool_mat_t mat)"
#ns arbcall"int bool_mat_is_diagonal(const bool_mat_t A)"
#ns arbcall"int bool_mat_is_lower_triangular(const bool_mat_t A)"
#ns arbcall"int bool_mat_is_transitive(const bool_mat_t mat)"
#ns arbcall"int bool_mat_is_nilpotent(const bool_mat_t A)"

### Random generation
#ns arbcall"void bool_mat_randtest(bool_mat_t mat, flint_rand_t state)"
#ns arbcall"void bool_mat_randtest_diagonal(bool_mat_t mat, flint_rand_t state)"
#ns arbcall"void bool_mat_randtest_nilpotent(bool_mat_t mat, flint_rand_t state)"

### Special matrices
#ns arbcall"void bool_mat_zero(bool_mat_t mat)"
#ns arbcall"void bool_mat_one(bool_mat_t mat)"
#ns arbcall"void bool_mat_directed_path(bool_mat_t A)"
#ns arbcall"void bool_mat_directed_cycle(bool_mat_t A)"

### Transpose
#ns arbcall"void bool_mat_transpose(bool_mat_t dest, const bool_mat_t src)"

### Arithmetic
#ns arbcall"void bool_mat_complement(bool_mat_t B, const bool_mat_t A)"
#ns arbcall"void bool_mat_add(bool_mat_t res, const bool_mat_t mat1, const bool_mat_t mat2)"
#ns arbcall"void bool_mat_mul(bool_mat_t res, const bool_mat_t mat1, const bool_mat_t mat2)"
#ns arbcall"void bool_mat_mul_entrywise(bool_mat_t res, const bool_mat_t mat1, const bool_mat_t mat2)"
#ns arbcall"void bool_mat_sqr(bool_mat_t B, const bool_mat_t A)"
#ns arbcall"void bool_mat_pow_ui(bool_mat_t B, const bool_mat_t A, ulong exp)"

### Special functions
#ns arbcall"int bool_mat_trace(const bool_mat_t mat)"
#ns arbcall"slong bool_mat_nilpotency_degree(const bool_mat_t A)"
#ns arbcall"void bool_mat_transitive_closure(bool_mat_t B, const bool_mat_t A)"
#ns arbcall"slong bool_mat_get_strongly_connected_components(slong * p, const bool_mat_t A)"
#ni arbcall"slong bool_mat_all_pairs_longest_walk(fmpz_mat_t B, const bool_mat_t A)"
