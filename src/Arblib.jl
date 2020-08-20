module Arblib

using LoadFlint
const libflint = LoadFlint.libflint
import LinearAlgebra

using Arb_jll

export Arf, Arb, ArbRef, Acb, AcbRef, ArbVector, AcbVector, ArbMatrix, AcbMatrix

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
include("arithmetic.jl")

include("vector.jl")
include("matrix.jl")

include("arbcalls/mag.jl")
include("arbcalls/arf.jl")
include("arbcalls/arb.jl")
include("arbcalls/acb.jl")
include("arbcalls/arb_mat.jl")
include("arbcalls/acb_mat.jl")

end # module
