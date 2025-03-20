ENV["NEMO_THREADED"] = 1

using Arblib, Test, LinearAlgebra, Random, Serialization, SpecialFunctions
using Documenter

import Aqua

DocMeta.setdocmeta!(Arblib, :DocTestSetup, :(using Arblib); recursive = true)

@testset "Arblib" begin
    doctest(Arblib)
    # Some methods are excluded from the check for ambiguities. There
    # are two reasons for these exclusions, methods in Base we don't
    # care about and false positives from Aqua.

    # The methods in Base that we don't care about are construction
    # from AbstractChar or Base.TwicePrecision. Both of these have
    # default constructors for Number types that clash with our catch
    # all constructors. They do not seem important enough to warrant
    # extra code for handling them.

    # One set of false positives are for Arf(::Rational) and
    # Arb(::Rational). The other set is for + and * with mix of
    # ArbSeries and AcbSeries.
    Aqua.test_all(
        Arblib,
        ambiguities = (
            exclude = [
                Mag,
                NFloat,
                NFloatRef,
                Arf,
                Acf,
                Arb,
                Acb,
                ArbSeries,
                AcbSeries,
                +,
                *,
            ],
        ),
    )

    include("ArbCall/runtests.jl")

    include("arb_types.jl")
    include("rounding.jl")
    include("types.jl")
    include("hash.jl")
    include("serialize.jl")
    include("precision.jl")
    include("manual_overrides.jl")
    include("setters.jl")
    include("constructors.jl")
    include("conversion.jl")
    include("predicates.jl")
    include("show.jl")
    include("promotion.jl")
    include("examples.jl")
    include("arithmetic.jl")
    include("elementary.jl")
    include("minmax.jl")
    include("rand.jl")
    include("float.jl")
    include("interval.jl")
    include("multi-argument.jl")
    include("vector.jl")
    include("matrix.jl")
    include("eigen.jl")
    include("calc_integrate.jl")
    include("ref.jl")
    include("poly.jl")
    include("series.jl")
    include("special-functions.jl")
    include("threading.jl")
end
