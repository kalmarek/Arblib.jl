module Arblib

using Arb_jll
import LinearAlgebra
import Serialization
import SpecialFunctions

# So that the parsed contains method extends the base function
import Base: contains

export Mag,
    MagRef,
    Arf,
    ArfRef,
    Arb,
    ArbRef,
    Acb,
    AcbRef,
    ArbVector,
    AcbVector,
    ArbMatrix,
    AcbMatrix,
    ArbRefVector,
    AcbRefVector,
    ArbRefMatrix,
    AcbRefMatrix,
    ArbPoly,
    ArbSeries,
    AcbPoly,
    AcbSeries,
    ref

macro libarb(function_name)
    return (:($function_name), libarb)
end

macro libflint(function_name)
    return (:($function_name), Arb_jll.libflint)
end

const __isthreaded = Ref(false)

function __init__()
    __isthreaded[] = Base.get(ENV, "NEMO_THREADED", "") == "1"
end

function flint_set_num_threads(a::Integer)
    if !__isthreaded[]
        error("To use threaded flint, julia has to be started with NEMO_THREADED=1")
    else
        ccall(@libflint(flint_set_num_threads), Nothing, (Cint,), a)
    end
end

include("arb_types.jl")
include("fmpz.jl")
include("rounding.jl")
include("types.jl")
include("hash.jl")
include("serialize.jl")

include("ArbCall/ArbCall.jl")
import .ArbCall: @arbcall_str, @arbfpwrapcall_str
include("manual_overrides.jl")

include("precision.jl")

include("setters.jl")
include("constructors.jl")
include("predicates.jl")
include("show.jl")
include("promotion.jl")
include("arithmetic.jl")
include("elementary.jl")
include("minmax.jl")
include("rand.jl")
include("float.jl")
include("interval.jl")

include("ref.jl")
include("vector.jl")
include("matrix.jl")
include("array_common.jl")
include("eigen.jl")
include("poly.jl")
include("calc_integrate.jl")
include("special-functions.jl")

include("arbcalls/mag.jl")
include("arbcalls/arf.jl")
include("arbcalls/arb.jl")
include("arbcalls/acb.jl")
include("arbcalls/arb_poly.jl")
include("arbcalls/arb_fmpz_poly.jl")
include("arbcalls/acb_poly.jl")
include("arbcalls/acb_dft.jl")
include("arbcalls/arb_mat.jl")
include("arbcalls/acb_mat.jl")
include("arbcalls/acb_hypgeom.jl")
include("arbcalls/arb_hypgeom.jl")
include("arbcalls/acb_elliptic.jl")
include("arbcalls/acb_modular.jl")
include("arbcalls/dirichlet.jl")
include("arbcalls/acb_dirichlet.jl")
include("arbcalls/bernoulli.jl")
include("arbcalls/hypgeom.jl")
include("arbcalls/partitions.jl")
include("arbcalls/arb_calc.jl")
include("arbcalls/acb_calc.jl")
include("arbcalls/arb_fpwrap.jl")
include("arbcalls/double_interval.jl")
include("arbcalls/fmpz_extras.jl")
include("arbcalls/bool_mat.jl")
include("arbcalls/dlog.jl")
include("arbcalls/eigen.jl")

end # module
