ENV["NEMO_THREADED"] = 1

using Arblib, Test, LinearAlgebra, Random, Serialization, SpecialFunctions
using Documenter

DocMeta.setdocmeta!(Arblib, :DocTestSetup, :(using Arblib); recursive = true)

@testset "Arblib" begin
    doctest(Arblib)

    include("ArbCall/runtests.jl")

    include("arb_types.jl")
    include("types.jl")
    include("hash.jl")
    include("serialize.jl")
    include("precision.jl")
    include("manual_overrides.jl")
    include("setters.jl")
    include("constructors.jl")
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
