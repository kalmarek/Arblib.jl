struct Carg{ArgT}
    name::Symbol
    isconst::Bool
end

Carg{T}(n::AbstractString, isconst::Bool) where {T} = Carg{T}(Symbol(n), isconst)

Base.:(==)(a::Carg{T}, b::Carg{S}) where {T,S} =
    T == S && name(a) == name(b) && isconst(a) == isconst(b)

function Carg(str)
    m = match(r"(?<const>const)?\s*(?<type>\w+(\s\*)?)\s+(?<name>\w+)", str)
    isnothing(m) && throw(ArgumentError("string doesn't match c-argument pattern"))
    cnst =
        !isnothing(m[:const]) ||
        (!isnothing(m[:type]) && (m[:type] == "arb_srcptr" || m[:type] == "acb_srcptr"))
    return Carg{arbargtypes[m[:type]]}(m[:name], cnst)
end

name(ca::Carg) = ca.name
isconst(ca::Carg) = ca.isconst

rawtype(::Carg{T}) where {T} = T

jltype(ca::Carg) = rawtype(ca)
jltype(ca::Carg{Cint}) = Integer
jltype(ca::Carg{Int}) = Integer
jltype(ca::Carg{UInt}) = Unsigned
jltype(ca::Carg{Cdouble}) = Base.GMP.CdoubleMax
jltype(ca::Carg{ComplexF64}) = Union{ComplexF16,ComplexF32,ComplexF64}
jltype(ca::Carg{arb_rnd}) = Union{arb_rnd,RoundingMode}
jltype(ca::Carg{Base.MPFR.MPFRRoundingMode}) =
    Union{Base.MPFR.MPFRRoundingMode,RoundingMode}
jltype(ca::Carg{Cstring}) = AbstractString
jltype(ca::Carg{Vector{Int}}) = Vector{<:Integer}
jltype(ca::Carg{Vector{UInt}}) = Vector{<:Unsigned}
jltype(ca::Carg{Vector{Float64}}) = Vector{<:Base.GMP.CdoubleMax}
jltype(ca::Carg{Vector{ComplexF64}}) = Vector{<:Union{ComplexF16,ComplexF32,ComplexF64}}
jltype(::Carg{Mag}) = MagLike
jltype(::Carg{Arf}) = ArfLike
jltype(::Carg{Arb}) = ArbLike
jltype(::Carg{Acb}) = AcbLike
jltype(::Carg{ArbVector}) = ArbVectorLike
jltype(::Carg{AcbVector}) = AcbVectorLike
jltype(::Carg{ArbMatrix}) = ArbMatrixLike
jltype(::Carg{AcbMatrix}) = AcbMatrixLike
jltype(::Carg{ArbPoly}) = ArbPolyLike
jltype(::Carg{AcbPoly}) = AcbPolyLike

ctype(ca::Carg) = rawtype(ca)
ctype(::Carg{T}) where {T<:Union{ArbVector,arb_vec_struct}} = Ptr{arb_struct}
ctype(::Carg{T}) where {T<:Union{AcbVector,acb_vec_struct}} = Ptr{acb_struct}
ctype(::Carg{T}) where {T<:Union{Mag,Arf,Arb,Acb,ArbPoly,AcbPoly,ArbMatrix,AcbMatrix}} =
    Ref{cstructtype(T)}
ctype(::Carg{T}) where {T<:Union{BigFloat,BigInt}} = Ref{T}
ctype(::Carg{Vector{T}}) where {T} = Ref{T}
