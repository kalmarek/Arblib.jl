# Rigorous numerics
Arb is made for rigorous numerics and any functions which do not
produce rigorous results are clearly marked as such. This is not the
case with Julia in general and you therefore have to be careful when
interacting with the ecosystem if you want your results to be
completely rigorous. Below we discuss some things to be extra careful
with.

## Implicit promotion
Julia automatically promotes types in many cases and in particular you
have to watch out for temporary non-rigorous values. For example
`2(π * Arb(1 // 3))` is okay, but not `2π * Arb(1 // 3)`

``` repl
x = 2(π * Arb(1 // 3))
y = 2π * Arb(1 // 3)
Arblib.overlaps(x, y)
```

## Non-rigorous algorithms
Standard numerical algorithms typically return (hopefully good)
approximations. These algorithms can then not directly be used in
rigorous numerical computations unless the error can be bounded.

For example Julias built in methods for solving linear systems doesn't
produce rigorous results. Instead you would have to use the solves
provided by Arb, such as `Arblib.solve!`.

Other examples would include integration and solving of differential
equations.

## Implementation details
In some cases the implementation in Julia implicitly makes certain
assumptions to improve performance and this can lead to issues.

For example, prior to Julia version 1.8 the `minimum` and `maximum`
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
