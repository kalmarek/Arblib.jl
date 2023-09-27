# Series
Taylor series arithmetic allows for the computation of truncated
Taylor series of functions and is a form of higher order automatic
differentiation. See e.g.
[`TaylorSeries.jl`](https://github.com/JuliaDiff/TaylorSeries.jl) and
[`TaylorDiff.jl`](https://github.com/JuliaDiff/TaylorDiff.jl) for
implementations of Taylor series in Julia.

The Arb library has good support for computing with polynomials as
Taylor expansions. The types [`ArbSeries`](@ref) and
[`AcbSeries`](@ref) are intended to make this easy to use from Julia.
They are given by an [`ArbPoly`](@ref)/[`AcbPoly`](@ref) together with
the length of the expansion.

## Example
```@repl 1
using Arblib

x0 = Arb(1 // 3, prec = 64)
x = ArbSeries((x0, 1), degree = 5)

sin(x)

sin(x)^2 + cos(x)^2
```
