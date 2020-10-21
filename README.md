# Arblib.jl

This package is a thin, efficient wrapper around [Arb](http://arblib.org) - a C library for arbitrary-precision ball arithmetic.

The package is currently in early development. More features and
documentation will be added. While we try to avoid it there might be
breaking changes.

## Installation

```julia
using Pkg
pkg"add https://github.com/kalmarek/Arblib.jl.git"
```

## What is Arb?
From the Arb documentation:

>  Arb is a C library for rigorous real and complex arithmetic with arbitrary precision. Arb tracks numerical errors automatically using ball arithmetic, a form of interval arithmetic based on a midpoint-radius representation. On top of this, Arb provides a wide range of mathematical functionality, including polynomials, power series, matrices, integration, root-finding, and many transcendental functions. Arb is designed with efficiency as a primary goal, and is usually competitive with or faster than other arbitrary-precision packages.


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
| `acb_t* ` | `AcbVector` or `AcbRefVector` |
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

## Example

Here is the naive sine compuation example form the [Arb documentation](http://arblib.org/using.html#a-worked-example-the-sine-function) in Julia:

```julia
using Arblib

function sin_naive!(res, x)
    s, t, u = zero(x), zero(x), zero(x)
    tol = one(x)
    Arblib.mul_2exp!(tol, tol, -precision(tol))
    k = 0
    while true
        Arblib.pow!(t, x, 2k + 1)
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
