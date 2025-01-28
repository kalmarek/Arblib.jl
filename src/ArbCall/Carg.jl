"""
    Carg{T}(name, isconst)
    Carg(str::AbstractString)

Struct representing a argument to a C function in the Arb library. The
corresponding Julia type is `T`, `name` is the name of the argument,
`isconst` is true if the argument is declared as a const.

```jldoctest
julia> Arblib.ArbCall.Carg("const arb_t x")
Arblib.ArbCall.Carg{Arb}(:x, true)
```
"""
struct Carg{T}
    name::Symbol
    isconst::Bool
end

Carg{T}(name::AbstractString, isconst::Bool) where {T} = Carg{T}(Symbol(name), isconst)

function Carg(str::AbstractString)
    m = match(r"(?<const>const)?\s*(?<type>\w+(\s\*)?)\s+(?<name>\w+)", str)
    isnothing(m) && throw(ArgumentError("string doesn't match c-argument pattern"))
    isconst =
        !isnothing(m[:const]) || (!isnothing(m[:type]) && endswith(m[:type], "_srcptr"))
    return Carg{arbargtypes[m[:type]]}(m[:name], isconst)
end

name(ca::Carg) = ca.name
isconst(ca::Carg) = ca.isconst
rawtype(::Carg{T}) where {T} = T

Base.:(==)(a::Carg{T}, b::Carg{S}) where {T,S} =
    T == S && name(a) == name(b) && isconst(a) == isconst(b)

function arbsignature(ca::Carg)
    arbtype = arbargtypes.supported_reversed[rawtype(ca)]

    if isconst(ca) && endswith(arbtype, "_ptr")
        const_arbtype = replace(arbtype, "_ptr" => "_srcptr")
        return "$const_arbtype $(name(ca))"
    else
        return ifelse(isconst(ca), "const ", "") * "$arbtype $(name(ca))"
    end
end

"""
    jltype(ca::Carg{T})

The most general Julia type for which we allow automatic conversion to
the [`Arblib.ArbCall.ctype`](@ref) of `ca`.

These conversations should be done without any loss of information,
for example for floating point numbers we only allow conversion from
types with lower precision. In general the conversion is done using
`Base.cconvert`.
"""
jltype(ca::Carg) = rawtype(ca)
# Primitive
jltype(::Carg{Cint}) = Integer
jltype(::Carg{Int}) = Integer
jltype(::Carg{UInt}) = Unsigned
jltype(::Carg{Float64}) = Union{Float16,Float32,Float64}
jltype(::Carg{ComplexF64}) = Union{ComplexF16,ComplexF32,ComplexF64}
jltype(::Carg{Cstring}) = AbstractString
jltype(::Carg{Vector{Int}}) = Vector{Int}
jltype(::Carg{Vector{UInt}}) = Vector{UInt}
jltype(::Carg{Vector{Float64}}) = Vector{Float64}
jltype(::Carg{Vector{ComplexF64}}) = Vector{ComplexF64}
# mpfr.h
jltype(::Carg{Base.MPFR.MPFRRoundingMode}) = Union{Base.MPFR.MPFRRoundingMode,RoundingMode}
# mag.h
jltype(::Carg{Mag}) = MagLike
# nfloat.h
jltype(::Carg{NFloat}) = NFloatLike
# arf.h
jltype(::Carg{Arf}) = ArfLike
jltype(::Carg{arb_rnd}) = Union{arb_rnd,RoundingMode}
# acf.h
jltype(::Carg{Acf}) = AcfLike
# arb.h
jltype(::Carg{Arb}) = ArbLike
jltype(::Carg{ArbVector}) = ArbVectorLike
# acb.h
jltype(::Carg{Acb}) = AcbLike
jltype(::Carg{AcbVector}) = AcbVectorLike
# arb_poly.h
jltype(::Carg{ArbPoly}) = ArbPolyLike
# acb_poly.h
jltype(::Carg{AcbPoly}) = AcbPolyLike
# arb_mat.h
jltype(::Carg{ArbMatrix}) = ArbMatrixLike
# acb_mat.h
jltype(::Carg{AcbMatrix}) = AcbMatrixLike

"""
    ctype(ca::Carg)

The type that should be used for the argument when passed to C code.
"""
ctype(ca::Carg) = rawtype(ca)
ctype(::Carg{Vector{T}}) where {T} = Ref{T}
ctype(::Carg{T}) where {T<:Union{BigFloat,BigInt}} = Ref{T}
ctype(::Carg{T}) where {T<:Union{Mag,Arf,Acf,Arb,Acb,ArbPoly,AcbPoly,ArbMatrix,AcbMatrix}} =
    Ref{cstructtype(T)}
ctype(::Carg{T}) where {T<:Union{ArbVector,arb_vec_struct}} = Ptr{arb_struct}
ctype(::Carg{T}) where {T<:Union{AcbVector,acb_vec_struct}} = Ptr{acb_struct}
ctype(::Carg{T}) where {T<:NFloat} = Ref{nfloat_struct}
ctype(::Carg{T}) where {T<:nfloat_ctx_struct} = Ref{nfloat_ctx_struct}

"""
    jlarg(ca::Carg{T}) where {T}

Return an `Expr` for representing the argument in a Julia function
header.

```jldoctest
julia> Arblib.ArbCall.jlarg(Arblib.ArbCall.Carg("const arb_t x"))
:(x::ArbLike)
julia> Arblib.ArbCall.jlarg(Arblib.ArbCall.Carg("slong prec"))
:(prec::Integer)
```
"""
jlarg(ca::Carg) = :($(name(ca))::$(jltype(ca)))

is_precision_argument(ca::Carg) = ca == Carg{Int}(:prec, false)

is_flag_argument(ca::Carg) = ca == Carg{Cint}(:flags, false)

is_rounding_argument(ca::Carg) =
    ca == Carg{arb_rnd}(:rnd, false) || ca == Carg{Base.MPFR.MPFRRoundingMode}(:rnd, false)

is_length_argument(ca::Carg, prev_ca::Carg) =
    (startswith(string(name(ca)), "len") || name(ca) == :n) &&
    rawtype(ca) == Int &&
    rawtype(prev_ca) ∈ (ArbVector, AcbVector)

is_ctx_argument(ca::Carg{T}) where {T} = T <: nfloat_ctx_struct

function extract_precision_argument(ca::Carg, first_ca::Carg)
    is_precision_argument(ca) ||
        throw(ArgumentError("argument is not a valid precision argument, $ca"))
    # If the first argument has a precision, then use this otherwise
    # make it a mandatory kwarg
    if rawtype(first_ca) <: ArbTypes && rawtype(first_ca) != Mag
        return Expr(:kw, jlarg(ca), :(_precision($(name(first_ca)))))
    else
        return jlarg(ca)
    end
end

function extract_flag_argument(ca::Carg)
    is_flag_argument(ca) ||
        throw(ArgumentError("argument is not a valid flag argument, $ca"))
    return Expr(:kw, jlarg(ca), 0)
end

function extract_rounding_argument(ca::Carg)
    is_rounding_argument(ca) ||
        throw(ArgumentError("argument is not a valid rounding argument, $ca"))
    return Expr(:kw, jlarg(ca), :(RoundNearest))
end

function extract_length_argument(ca::Carg, prev_ca::Carg)
    is_length_argument(ca, prev_ca) ||
        throw(ArgumentError("argument is not a valid length argument, $ca"))
    return Expr(:kw, jlarg(ca), :(length($(name(prev_ca)))))
end

# TODO: This needs to handle the case when it is not the first
# argument we should get the context from. This happens for e.g.
# nfloat_get_arf.
function extract_ctx_argument(ca::Carg, first_ca::Carg)
    is_ctx_argument(ca) || throw(ArgumentError("argument is not a valid ctx argument, $ca"))
    return Expr(:kw, jlarg(ca), :(_get_nfloat_ctx_struct($(name(first_ca)))))
end

"""
    is_fpwrap_res_argument(ca::Carg, T::Union{Float64,ComplexF64})

Return true if `ca` corresponds to a result argument in an
[`ArbFPWrapFunction`](@ref) with base type `T`.

The raw type of `ca` should be `Vector{T}` and it should not be a
`const`. Moreover the name should be `:res` or `resd` for some digit
`d`.
"""
is_fpwrap_res_argument(ca::Carg{S}, T::Union{Type{Float64},Type{ComplexF64}}) where {S} =
    S == Vector{T} && !isconst(ca) && !isnothing(match(r"res\d?$", string(name(ca))))
