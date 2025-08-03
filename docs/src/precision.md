# Precision
Similarly to `BigFloat`, most types in Arblib.jl support computations
with arbitrary precision. However, the way the precision is handled
differ slightly from how `BigFloat` handles it. The main points, which
are expanded upon below, are:
1. Precision can be specified when constructing a new value using the
   `prec` keyword argument.
2. The default precision that is used if no precision is specified can
   be changed, either globally or within a dynamical scope, using
   [`setprecision`](@ref).
3. Computations use the precision of the input(s). This is different
   to `BigFloat`, which always uses the default precision for all
   computations.
4. For `Arb` and `Acb` it is safe to mix values computed with
   different precisions, the error bounds keep track of the actual
   precision of the computations. This is not true for `Arf` and `Acf`
   (nor is it true for `BigFloat`), where mixing precisions can make
   the final result appear to be computed at a higher precision than
   it actually is.

## Specifying precision in constructor
Precision can be specified when constructing a new value using the
`prec` keyword argument.
``` @repl
using Arblib # hide

x = Arb(1 // 3, prec = 64)
precision(x)
Arb(1 // 3, prec = 128)
AcbSeries((π, 1, 1 // 3), prec = 53)
ArbVector([1, 2, 3], prec = 80)
```

## Using `setprecision`
Similarly to `BigFloat` there is a default precision that is used if
no precision is specified. The default precision can be changed,
either globally or within a dynamical scope, using
[`setprecision`](@ref).

``` @docs
Arblib.setprecision
```

## Handling of precision in computations
Contrary to `BigFloat`, most computations use the precision of the
arguments. For functions taking multiple arguments the maximum
precision of the arguments is used.

``` @repl
using Arblib # hide

x = Arb(1 // 3, prec = 64)
y = sin(x) # Result uses 64 bits of precision
precision(y)

a = Arb(π, prec = 128)
b = Arb(1 // 3, prec = 64)
c = a + b # Result uses 128 bits of precision
precision(c)
```

This makes it easy to use either a lower or higher precision for a
part of the computation. It can be useful to use lower precision when
evaluating terms that are significantly smaller in magnitude. Higher
precision can be helpful when evaluating close to a removable
singularity. Consider the artificial example of computing $e^x +
\sin(x)$ for $x$ near zero, the $\sin(x)$ term can then be computed
with significantly lower precision than the $e^x$ term.

``` @repl
using Arblib # hide

x = Arb(1e-70) # Input close to zero

exp(x) + sin(x) # Compute everything in full precision

exp(x) + sin(setprecision(x, 64)) # Compute sin term in lower precision
```

!!! tip

    For fine grained control of the precision used for each operation
    it is best to use the low level interface as discussed in
    [Mutable arithmetic](@ref).

### Common pitfalls
While the library does its best to preserve precision through
computations, there are still ways to accidentally cause some
operations to use the default precision instead.

The most common situation is methods that only see the type of a
value. Since the type doesn't carry any information about the
precision these methods fall back to the default precision. This for
example applies to `zero(T)` and `convert(T, x)` (and also to
`oftype(y, x)` which is equivalent to `convert(typeof(y), x)`). For
example, if we are interested in computing the function $f(x) = x +
2\pi$, and we implement it using `2oftype(x, π)` to compute $2\pi$,
that part of the computation will use the currently set default
precision and not the precision of `x`.

``` @repl
using Arblib # hide

f(x) = x + 2oftype(x, π)

y = f(Arb(1, prec = 53))
precision(y) # Results uses 256 bits of precision instead of 53

z = f(Arb(1, prec = 512))
precision(z) # Result uses 512 bits of precision as wanted
Arblib.rel_accuracy_bits(z) # But error bounds are only accurate to 256 bits
```

In the above case one solution would be to define `f(x::Arb) = x +
2Arb(π, prec = precision(x))`. In general there is however no generic
solution to this problem that doesn't require implementing a special
case for `f(x::Arb)`.
