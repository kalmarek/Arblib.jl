module Arblib

using FLINT_jll
using Arb_jll

export Arf, Arb, Acb

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

include("arbcalls/mag.jl")
include("arbcalls/arf.jl")
include("arbcalls/arb.jl")
include("arbcalls/acb.jl")

end # module
