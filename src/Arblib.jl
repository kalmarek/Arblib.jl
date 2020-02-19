module Arblib

include(joinpath(@__DIR__, "..", "deps", "deps.jl"))

function __init__()
    check_deps()
end

export Arf, Arb, Acb

import Base: isfinite, isinf, isinteger, isnan, isone, isreal, iszero

include("macros.jl")
include("arb_types.jl")
include("types.jl")
include("rounding.jl")
include("precision.jl")

include("constructors.jl")

include("predicates.jl")
include("show.jl")

end # module
