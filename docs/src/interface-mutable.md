# Mutable arithmetic
The high level interface can be combined with the low level wrapper to
allow for efficient computations using mutable arithmetic.

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

eval(p, x) = begin
    res = zero(x)
    xi = one(x)
    for i in 0:Arblib.degree(p)
        res += p[i] * xi
        xi *= x
    end
    return res
end

eval!(res, p, x) = begin
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
