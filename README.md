# Arblib.jl

[![][docs-stable-img]][docs-stable-url]
[![][docs-dev-img]][docs-dev-url]
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10081695.svg)](https://doi.org/10.5281/zenodo.10081695)
[![ci](https://github.com/kalmarek/Arblib.jl/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/kalmarek/Arblib.jl/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/kalmarek/Arblib.jl/graph/badge.svg?token=i1YYEc2Vht)](https://codecov.io/gh/kalmarek/Arblib.jl)

This package is a thin, efficient wrapper around
[Arb](http://arblib.org) - a C library for arbitrary-precision ball
arithmetic. Since 2023 Arb is part of [Flint](https://flintlib.org/).

## Installation

```julia
using Pkg
pkg"add Arblib"
```

## What is Arb?

From the Arb documentation:

> Arb is a C library for rigorous real and complex arithmetic with arbitrary precision. Arb tracks numerical errors automatically using ball arithmetic, a form of interval arithmetic based on a midpoint-radius representation. On top of this, Arb provides a wide range of mathematical functionality, including polynomials, power series, matrices, integration, root-finding, and many transcendental functions. Arb is designed with efficiency as a primary goal, and is usually competitive with or faster than other arbitrary-precision packages.

## Types

The following table indicates how Arb C-types can be translated to the Julia side.
Note that all Julia structs additionally contain a `precision` field storing the precision
used.
Julia types with `Ref` in their name are similar to the `Ref` type in
base Julia. They contain a pointer to an object of the corresponding
type, as well as a reference to it parent object to protect it from
garbage collection.

| Arb  | Julia  |
|----- |------- |
| `mag_t`  | `Mag` or `MagRef` |
| `arf_t`  | `Arf` or `ArfRef`  |
| `arb_t`  | `Arb` or `ArbRef`  |
| `acb_t`  | `Acb` or `AcbRef` |
| `arb_t*`  | `ArbVector` or `ArbRefVector` |
| `acb_t*` | `AcbVector` or `AcbRefVector` |
| `arb_mat_t`  | `ArbMatrix` or `ArbRefMatrix` |
| `acb_mat_t`  | `AcbMatrix` or `AcbRefMatrix`  |
| `arb_poly_t`  | `ArbPoly` or `ArbSeries` |
| `acb_poly_t`  | `AcbPoly` or `AcbSeries` |

Indexing of an `ArbMatrix` returns an `Arb` whereas indexing `ArbRefMatrix` returns an `ArbRef`.
An `ArbMatrix` `A` can also be index using the `ref` function , e.g, `ref(A, i, j)` to obtain
an `ArbRef`.

Additionally, there are multiple union types defined to capture a `Ref` and non-`Ref` version.
For example `Arb` and `ArbRef` are subtypes of `ArbLike`. Similarly, we provide
`MagLike`, `ArfLike`, `ArbLike`, `AcbLike`, `ArbVectorLike`, `AcbVectorLike`, `ArbMatrixLike`,
`AcbMatrixLike`.

Both `ArbPoly` and `ArbSeries` wrap the `arb_poly_t` type. The
difference is that `ArbSeries` has a fixed length and is therefore
suitable for use when Taylor series are computed using the `_series`
functions in Arb. Similar for `AcbPoly` and `AcbSeries`.

**Example**:

```julia
julia> A = ArbMatrix([1 2; 3 4]; prec=64)
2×2 ArbMatrix:
 1.000000000000000000  2.000000000000000000
 3.000000000000000000  4.000000000000000000

julia> a = A[1,2]
2.000000000000000000

julia> Arblib.set!(a, 12)
12.00000000000000000

# Memory in A not changed
julia> A
2×2 ArbMatrix:
 1.000000000000000000  2.000000000000000000
 3.000000000000000000  4.000000000000000000

julia> b = ref(A, 1, 2)
2.000000000000000000

julia> Arblib.set!(b, 12)
12.00000000000000000

# Memory in A also changed
julia> A
2×2 ArbMatrix:
 1.000000000000000000  12.00000000000000000
 3.000000000000000000   4.000000000000000000
```

## Naming convention

Arb functions are wrapped by parsing the Arb documentation and applying the following set of rules to "Juliafy" the function names:

1. The parts of a function name which only refer to the type of input are removed since Julia has multiple dispatch to deal with this problem.
2. Functions which modify the first argument get an `!` appened.
3. For functions which take a precision argument this arguments becomes a `prec` keyword argument
   which is by default set to the precision of the first argument (if applicable).
4. For functions which take a rounding mode argument this arguments becomes a `rnd` keyword argument
   which is by default set to `RoundNearest`.

**Example:**
The function

```C
arb_add_si(arb_t z, const arb_t x, slong y, slong prec)`
```

becomes

```julia
add!(z::ArbLike, x::ArbLike, y::Int; prec = precision(z))
```

## Constructors and setters

Arb defines a number of functions for setting something to a specific
value, for example `void arb_set_si(arb_t y, slong x)`. All of these
are renamed to `set!` and rely on multiple dispatch to choose the
correct one. In addition to the ones defined in Arb there is a number
of methods of `set!` added in Arblib to make it more convenient to
work with. For example there are setters for `Rational` and all
irrationals defined in `Base.MathConstants`. For `Arb` there is also a
setter which takes a tuple `(a, b)` representing an interval and
returns a ball containing this interval.

Almost all of the constructors are simple wrappers around these
setters. This means that it's usually more informative to look at the
methods for `set!` than for say `Arb` to figure out what constructors
exists. Both `Arb` and `Acb` are constructed in such a way that the
result will always enclose the input.

**Example:**

``` julia
x = Arblib.set!(Arb(), π)
y = Arb(π)

x = Arblib.set!(Arb(), 5//13)
y = Arb(5//13)

x = Arblib.set!(Arb(), (0, π))
y = Arb((0, π))
```

## Pitfalls when interacting with the Julia ecosystem

Arb is made for rigorous numerics and any functions which do not
produce rigorous results are clearly marked as such. This is not the
case with Julia in general and you therefore have to be careful when
interacting with the ecosystem if you want your results to be
completely rigorous. Below are three things which you have to be extra
careful with.

### Implicit promotion

Julia automatically promotes types in many cases and in particular you
have to watch out for temporary non-rigorous values. For example
`2(π*(Arb(ℯ)))` is okay, but not `2π*Arb(ℯ)`

``` julia
julia> 2(π*(Arb(ℯ)))
[17.079468445347134130927101739093148990069777071530229923759202260358457222314 +/- 9.19e-76]

julia> 2π*Arb(ℯ)
[17.079468445347133465140073658536286170170195258393831755094914544308087031794 +/- 7.93e-76]

julia> Arblib.overlaps(2(π*(Arb(ℯ))), 2π*Arb(ℯ))
false
```

### Non-rigorous approximations

In many cases this is obvious, for example Julias built in methods for
solving linear systems will not produce rigorous results.

TODO: Come up with more examples

### Implementation details

In some cases the implementation in Julia implicitly makes certain
assumptions to improve performance and this can lead to issues. For
example, prior to Julia version 1.8 the `minimum` and `maximum`
methods in Julia checked for `NaN` results (on which is short fuses)
using `x == x`, which works for most numerical types but not for `Arb`
(`x == x` is only true if the radius is zero). See
<https://github.com/JuliaLang/julia/issues/36287> and in particular
<https://github.com/JuliaLang/julia/issues/45932> for more details.
Since Julia version 1.8 the `minimum` and `maximum` methods work
correctly for `Arb`, for earlier versions of Julia it only works
correctly in some cases.

These types of problems are the hardest to find since they are not
clear from the documentation but you have to read the implementation,
`@which` and `@less` are your friends in these cases.

## Example

Here is the naive sine compuation example form the [Arb
documentation](http://arblib.org/using.html#a-worked-example-the-sine-function)
in Julia:

```julia
using Arblib

function sin_naive!(res::Arb, x::Arb)
    s, t, u = zero(x), zero(x), zero(x)
    tol = one(x)
    Arblib.mul_2exp!(tol, tol, -precision(tol))
    k = 0
    while true
        Arblib.pow!(t, x, UInt(2k + 1))
        Arblib.fac!(u, UInt(2k + 1))
        Arblib.div!(t, t, u)
        Arblib.abs!(u, t)

        if u ≤ tol
            Arblib.add_error!(s, u)
            break
        end
        if iseven(k)
            Arblib.add!(s, s, t)
        else
            Arblib.sub!(s, s, t)
        end
        k += 1
    end
    Arblib.set!(res, s)
end

let prec = 64
    while true
        x = Arb("2016.1"; prec = prec)
        y = zero(x)
        y = sin_naive!(y, x)
        print("Using $(lpad(prec, 5)) bits, sin(x) = ")
        println(Arblib.string_nice(y, 10))
        y < zero(y) && break
        prec *= 2
    end
end
```

## Special functions

Arblib extends the methods from
[SpecialFunctions.jl](https://github.com/JuliaMath/SpecialFunctions.jl)
with versions from Arb. In some cases the Arb version is more general
than the version in SpecialFunctions, for example `ellipk` is not
implemented for complex arguments in SpecialFunctions but it is in
Arb. We refer to the Arb documentation for details about the
Arb-versions.

Some methods from SpecialFunctions are however not implemented in Arb
and does are not extended, these are mostly scaled version of methods.
Arb does however implement many special functions that are not in
SpecialFunction and at the moment there is no user friendly interface
for most of them.

## Support for multi-threading

Enabling a threaded version of flint can be done by setting the
environment variable `NEMO_THREADED=1`. Note that this should be
set before `Arblib.jl` is loaded. To set the actual number of threads,
use `Arblib.flint_set_num_threads($numberofthreads)`.

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://Kalmarek.github.io/Arblib.jl/dev/
[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://Kalmarek.github.io/Arblib.jl/stable
