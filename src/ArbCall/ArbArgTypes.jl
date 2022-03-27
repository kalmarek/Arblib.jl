struct UnsupportedArgumentType <: Exception
    key::String
end

struct ArbArgTypes
    supported::Dict{String,DataType}
    unsupported::Set{String}
    supported_reversed::Dict{DataType,String}
end

function ArbArgTypes(supported, unsupported)
    supported_reversed = Dict(value => key for (key, value) in supported)
    return ArbArgTypes(supported, unsupported, supported_reversed)
end

function Base.getindex(arbargtypes::ArbArgTypes, key::AbstractString)
    haskey(arbargtypes.supported, key) && return arbargtypes.supported[key]
    key in arbargtypes.unsupported && throw(UnsupportedArgumentType(key))
    throw(KeyError(key))
end

const arbargtypes = ArbArgTypes(
    Dict{String,DataType}(
        "void" => Cvoid,
        "void *" => Ptr{Cvoid},
        "int" => Cint,
        "slong" => Int,
        "ulong" => UInt,
        "double" => Cdouble,
        "double *" => Vector{Float64},
        "complex_double" => ComplexF64,
        "complex_double *" => Vector{ComplexF64},
        "arf_t" => Arf,
        "arb_t" => Arb,
        "acb_t" => Acb,
        "mag_t" => Mag,
        "arb_srcptr" => ArbVector,
        "arb_ptr" => ArbVector,
        "acb_srcptr" => AcbVector,
        "acb_ptr" => AcbVector,
        "arb_poly_t" => ArbPoly,
        "acb_poly_t" => AcbPoly,
        "arb_mat_t" => ArbMatrix,
        "acb_mat_t" => AcbMatrix,
        "arf_rnd_t" => arb_rnd,
        "mpfr_t" => BigFloat,
        "mpfr_rnd_t" => Base.MPFR.MPFRRoundingMode,
        "mpz_t" => BigInt,
        "char *" => Cstring,
        "slong *" => Vector{Int},
        "ulong *" => Vector{UInt},
    ),
    Set(["FILE *", "fmpr_t", "fmpr_rnd_t", "flint_rand_t", "bool_mat_t"]),
    Dict{DataType,String}(
        Cvoid => "void",
        Ptr{Cvoid} => "void *",
        Cint => "int",
        Int => "slong",
        UInt => "ulong",
        Cdouble => "double",
        Vector{Float64} => "double *",
        ComplexF64 => "complex_double",
        Vector{ComplexF64} => "complex_double *",
        Arf => "arf_t",
        Arb => "arb_t",
        Acb => "acb_t",
        Mag => "mag_t",
        ArbVector => "arb_ptr",
        AcbVector => "acb_ptr",
        ArbPoly => "arb_poly_t",
        AcbPoly => "acb_poly_t",
        ArbMatrix => "arb_mat_t",
        AcbMatrix => "acb_mat_t",
        arb_rnd => "arf_rnd_t",
        BigFloat => "mpfr_t",
        Base.MPFR.MPFRRoundingMode => "mpfr_rnd_t",
        BigInt => "mpz_t",
        Cstring => "char *",
        Vector{Int} => "slong *",
        Vector{UInt} => "ulong *",
    ),
)
