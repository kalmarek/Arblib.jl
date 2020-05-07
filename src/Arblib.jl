module Arblib

using LoadFlint

include(joinpath(@__DIR__, "..", "deps", "deps.jl"))

function __init__()
    check_deps()
end

export Arf, Arb, Acb

import Base: isfinite, isinf, isinteger, isnan, isone, isreal, iszero

macro libarb(function_name)
    return (:($function_name), libarb)
end

include("arb_types.jl")
include("types.jl")
include("rounding.jl")
include("arbcall.jl")

include("precision.jl")

include("constructors.jl")

include("predicates.jl")
include("show.jl")

include("arb.jl")

end # module
