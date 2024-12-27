# Mutable arithmetic
The high level interface can be combined with the low level wrapper to
allow for efficient computations using mutable arithmetic. Making use
of mutable arithmetic can in some cases have a significant impact on
the performance of the code, in particular for multithreaded code
(where avoiding to run the GC is generally more important) and code
running many iterations of simple computations.

In the future it would be nice to have an interface to
[MutableArithmetics.jl](https://github.com/jump-dev/MutableArithmetics.jl),
see [#118](https://github.com/kalmarek/Arblib.jl/issues/118).

The following methods are useful for mutating part of a value

``` @docs
Arblib.radref
Arblib.midref
Arblib.realref
Arblib.imagref
Arblib.ref
```

## Examples

Compare computing ``\sqrt{x^2 + y^2}`` using mutable arithmetic with
the default.

``` @repl
using Arblib, BenchmarkTools

x = Arb(1 // 3)
y = Arb(1 // 5)
res = zero(x)

f(x, y) = sqrt(x^2 + y^2)
f!(res, x, y) = begin
    Arblib.sqr!(res, x)
    Arblib.fma!(res, res, y, y)
    return Arblib.sqrt!(res, res)
end

@benchmark f($x, $y) samples=10000 evals=500
@benchmark f!($res, $x, $y) samples=10000 evals=500
```

!!! warning "Aliasing between input and output"
    This implementation of the function `f!` doesn't handle aliasing
    between `res` and `x`. Most cases of aliasing between two
    variables can be checked for with `===` (so `res === x` in this
    case). Using `===` does however not catch all possible cases of
    aliasing, for example it would not catch the aliasing between
    `Arblib.realref(z)` and `Arblib.realref(z, prec = 2precision(z))`.

Set the radius of the real part of an `Acb`.

``` @repl
using Arblib

z = Acb(1, 2)
Arblib.set!(Arblib.radref(Arblib.realref(z)), 1e-10)
z
```

Compare a naive implementation of polynomial evaluation using
mutable arithmetic with one not using using it.

``` @repl
using Arblib, BenchmarkTools

p = ArbPoly(1:10)
x = Arb(1 // 3)
res = zero(x)

function eval(p, x)
    res = zero(x)
    xi = one(x)
    for i in 0:Arblib.degree(p)
        res += p[i] * xi
        xi *= x
    end
    return res
end

function eval!(res, p, x)
    Arblib.zero!(res)
    xi = one(x)
    for i in 0:Arblib.degree(p)
        Arblib.addmul!(res, Arblib.ref(p, i), xi)
        Arblib.mul!(xi, xi, x)
    end
    return res
end

@benchmark eval($p, $x) samples = 10000 evals = 30
@benchmark eval!($res, $p, $x) samples = 10000 evals = 30
@benchmark $p($x) samples = 10000 evals = 30 # Arb implementation for reference
```

### Mutable arithmetic handling both `Arb/Acb` and `ArbSeries/AcbSeries`
Since `Arblib.jl` version `1.3.0` adjustments have been made to the
low level wrapper to make it easier to write code using mutable
arithmetic that can handle both the scalar types `Arb` and `Acb` as
well as the series types `ArbSeries` and `AcbSeries`. For example the
following implementation of `sin(atan(x) / x)` can support all of
these types.

``` @repl
using Arblib

function f!(res, x)
    Arblib.atan!(res, x)
    Arblib.div!(res, res, x)
    Arblib.sin!(res, res)
    return res
end

f!(Arb(prec = 53), Arb(2))
f!(Acb(prec = 53), Acb(2, 3))
f!(ArbSeries(degree = 2, prec = 53), ArbSeries((2, 1)))
f!(AcbSeries(degree = 2, prec = 53), AcbSeries((2 + 3im, 1)))
```

To make this possible there is special handling of the series
functions in Arb, see [Series methods](@ref) for more details.
