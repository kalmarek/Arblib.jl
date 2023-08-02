# Series
The Arb library has good support for computing with polynomials as
Taylor expansions. The types [`ArbSeries`](@ref) and
[`AcbSeries`](@ref) are intended to make this easy to use from Julia.
They are given by an [`ArbPoly`](@ref)/[`AcbPoly`](@ref) together with
the length of the expansion.
