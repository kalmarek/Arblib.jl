# arb_mat_struct and acb_mat_struct methods
clear!(v::arb_vec_struct) =
    ccall(@libflint(_arb_vec_clear), Cvoid, (Ptr{arb_struct}, Int), v.entries, v.n)
clear!(v::acb_vec_struct) =
    ccall(@libflint(_acb_vec_clear), Cvoid, (Ptr{acb_struct}, Int), v.entries, v.n)

Base.unsafe_convert(::Type{Ptr{arb_struct}}, v::arb_vec_struct) = v.entries
Base.unsafe_convert(::Type{Ptr{acb_struct}}, v::acb_vec_struct) = v.entries

Base.size(v::Union{arb_vec_struct,acb_vec_struct}) = (v.n,)

Base.getindex(v::arb_vec_struct, i::Integer) = v.entries + (i - 1) * sizeof(arb_struct)
Base.getindex(v::acb_vec_struct, i::Integer) = v.entries + (i - 1) * sizeof(acb_struct)

Base.setindex!(v::Union{arb_vec_struct,acb_vec_struct}, x, i::Integer) = (set!(v[i], x); x)

Base.cconvert(::Type{Ptr{arb_struct}}, v::ArbVectorOrRef) = cstruct(v)
Base.cconvert(::Type{Ptr{acb_struct}}, v::AcbVectorOrRef) = cstruct(v)

# AbstractVector interface

const Vectors = Union{ArbVectorOrRef,AcbVectorOrRef}

Base.size(v::Vectors) = size(cstruct(v))

"""
    ref(v::Union{ArbVectorOrRef,AcbVectorOrRef}, i)

Similar to `v[i]` but instead of an `Arb` or `Acb` returns an `ArbRef`
or `AcbRef` which still shares the memory with the `i`-th entry of
`v`.
"""
Base.@propagate_inbounds function ref(v::ArbVectorOrRef, i::Integer)
    @boundscheck checkbounds(v, i)
    return ArbRef(cstruct(v)[i], precision(v), cstruct(v))
end
Base.@propagate_inbounds function ref(v::AcbVectorOrRef, i::Integer)
    @boundscheck checkbounds(v, i)
    return AcbRef(cstruct(v)[i], precision(v), cstruct(v))
end

Base.@propagate_inbounds function Base.getindex(v::Union{ArbVector,AcbVector}, i::Integer)
    @boundscheck checkbounds(v, i)
    return set!(eltype(v)(prec = precision(v)), cstruct(v)[i])
end

Base.@propagate_inbounds Base.getindex(v::Union{ArbRefVector,AcbRefVector}, i::Integer) =
    ref(v, i)

Base.@propagate_inbounds function Base.setindex!(v::Vectors, x, i::Integer)
    ref(v, i)[] = x
    return x
end

# General constructors

for (T, TOrRef) in [
    (:ArbVector, :ArbVectorOrRef),
    (:ArbRefVector, :ArbVectorOrRef),
    (:AcbVector, :AcbVectorOrRef),
    (:AcbRefVector, :AcbVectorOrRef),
]
    @eval $T(n::Integer; prec::Integer = DEFAULT_PRECISION[]) =
        $T(cstructtype($T)(n), shallow = true; prec)

    @eval $T(v::$TOrRef; shallow::Bool = false, prec::Integer = precision(v)) =
        $T(cstruct(v); shallow, prec)

    @eval function $T(v::AbstractVector; prec::Integer = _precision(v))
        V = $T(length(v); prec)
        @inbounds for (i, vᵢ) in enumerate(v)
            V[i] = vᵢ
        end
        return V
    end
end

Base.copy(v::Vectors) = copy!(similar(v), v)
function Base.copy!(w::T, v::T) where {T<:Vectors}
    length(w) == length(v) || throw(DimensionMismatch())
    return set!(w, v)
end
function Base.copyto!(w::T, v::T) where {T<:Vectors}
    length(w) >= length(v) || throw(DimensionMismatch())
    return set!(w, v)
end

# Arithmetic

for (jf, af) in [(:+, :add!), (:-, :sub!)]
    @eval function Base.$jf(
        v::T,
        w::T,
    ) where {T<:Union{ArbVector,ArbRefVector,AcbVector,AcbRefVector}}
        @boundscheck (length(v) == length(w) || throw(DimensionMismatch()))
        u = T(length(v); prec = _precision(v, w))
        return $af(u, v, w)
    end
end

Base.:(-)(v::Vectors) = neg!(similar(v), v)
