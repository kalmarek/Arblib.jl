# Methods

The methods for the low level wrapper are automatically generated by
parsing the Arb documentation. This is handled by the `Arblib.ArbCall`
module.

## Parsing
The parsing is handled by

``` @docs
Arblib.ArbCall.parse_and_generate_arbdoc
```

Note that the parsing is done ahead of time and the generated files in
`src/arbcalls/` are added to git. As a user of the package you
therefore typically don't need to care about this step.

## Generated methods
The automatic generation of the methods is handled by

``` @docs
Arblib.ArbCall.@arbcall_str
Arblib.ArbCall.ArbFunction
Arblib.ArbCall.jlcode(af::Arblib.ArbCall.ArbFunction)
```

The main things to understand is how the name of the generated
function is determined, how the arguments are handled and the return
value.

### Naming
The name of the Arb function is "Juliafied" using the following
guidelines:

1. Prefixes and suffixes a function name which only refer to the type
   of input are removed since Julia has multiple dispatch to deal with
   this problem.
2. Functions which modify the first argument get an `!` appended to
   the name.

The implementation is based on heuristics for determining when part of
the function name is referring to the type or when the function
modifies the argument. This works well for the majority of functions
but gives a few odd cases.

### Arguments
The arguments of the function are represented by

``` @docs
Arblib.ArbCall.Carg
```

For the generated method the allowed types for the argument is
determined by

``` @docs
Arblib.ArbCall.jltype
Arblib.ArbCall.ctype
```

Some arguments are automatically converted to keyword arguments.
1. For functions which take a precision argument this argument becomes
   a `prec::Integer` keyword argument which is by default set to the
   precision of the first argument (if applicable).
2. For functions which take a rounding mode argument this argument
   becomes a `rnd::Union{Arblib.arb_rnd,RoundingMode}` keyword
   argument which is by default set to `RoundNearest`.
3. For functions which takes a flag argument this argument becomes a
   `flag::Integer` keyword argument which is by default set to `0`.
4. For functions which takes an argument giving the length of the
   vector preceding the argument this argument becomes a keyword
   argument which is by default set to the length of the preceding
   vector. In this case the name of the keyword argument is the same
   as the argument name in the function declaration.

As with the naming the implementation is based on heuristics for
determining when an argument is supposed to be a certain kind of
keyword argument.

### Return value
The returned value is determined in the following way

1. For functions which have the C function has return type `void` and
   modify the first argument the generated method returns the first
   argument. This is follows the normal convention in Julia.
2. For predicates, for which the C function returns `int`, the return
   value is converted to a `Bool`.
3. Otherwise the return type is the same as for the C function.

### Examples

For example Arb declares the following functions

1. `void arb_zero(arb_t x)`
2. `slong arb_rel_error_bits(const arb_t x)`
3. `int arb_is_zero(const arb_t x)`
4. `void arb_add(arb_t z, const arb_t x, const arb_t y, slong prec)`
5. `void arb_add_arf(arb_t z, const arb_t x, const arf_t y, slong prec)`
6. `void arb_add_ui(arb_t z, const arb_t x, ulong y, slong prec)`
7. `void arb_add_si(arb_t z, const arb_t x, slong y, slong prec)`
8. `void arb_sin(arb_t s, const arb_t x, slong prec)`
9. `void arb_cos(arb_t c, const arb_t x, slong prec)`
10. `void arb_sin_cos(arb_t s, arb_t c, const arb_t x, slong prec)`
11. `int arf_add(arf_t res, const arf_t x, const arf_t y, slong prec, arf_rnd_t rnd)`
12. `void arb_poly_sin_series(arb_poly_t s, const arb_poly_t h, slong n, slong prec)`

For which the following methods are generated

1. `zero!(x::ArbLike)::ArbLike`
2. `rel_error_bits(x::ArbLike)::Int`
3. `is_zero(x::ArbLike)::Bool`
4. `add!(z::ArbLike, x::ArbLike, y::ArbLike; prec::Integer = _precision(z))::ArbLike`
5. `add!(z::ArbLike, x::ArbLike, y::ArfLike; prec::Integer = _precision(z))::ArbLike`
6. `add!(z::ArbLike, x::ArbLike, y::Unsigned; prec::Integer = _precision(z))::ArbLike`
7. `add!(z::ArbLike, x::ArbLike, y::Integer; prec::Integer = _precision(z))::ArbLike`
8. `sin!(s::ArbLike, x::ArbLike; prec::Integer = _precision(s))::ArbLike`
9. `cos!(c::ArbLike, x::ArbLike; prec::Integer = _precision(c))::ArbLike`
10. `sin_cos!(s::ArbLike, c::ArbLike, x::ArbLike, prec::Integer = _precision(s))::ArbLike`
11. `add!(res::ArfLike, x::ArfLike, y::ArfLike; prec::Integer = _precision(res), rnd::Union{Arblib.arb_rnd, RoundingMode} = RoundNearest)::Int32`
12. `sin_series!(s::ArbPolyLike, h::ArbPolyLike, n::Integer; prec::Integer = _precision(s))::ArbPolyLike`

### Series methods
Arb has several functions mean for computing truncated Taylor series
(e.g. `arb_sin_series`). These functions have special handling, to
make them more convenient to use. In addition to the procedure
discussed above they generate one more method. This extra method
removes the "_series" suffix from the method name, restricts the input
type to only series types (and not polynomial types) and takes the
default length of the computed series from the first argument. As an
example the function
- `void arb_poly_sin_series(arb_poly_t s, const arb_poly_t h, slong n, slong prec)`
generates the method
- `sin!(s::ArbSeries, h::ArbSeries, n::Integer = length(s); prec::Integer = _precision(s))::ArbSeries`
in addition to the usual one (see the examples above).

The main motivation for these extra methods is to make it easier to
write generic code using mutability, see [Mutable arithmetic](@ref).
