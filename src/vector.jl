## ArbVector basic definitions
function clear!(v::arb_vec_struct)
    ccall(@libarb(_arb_vec_clear), Cvoid, (Ptr{arb_struct}, Clong), v.entries, v.n)
end
Base.unsafe_convert(::Type{Ptr{arb_struct}}, v::arb_vec_struct) = v.entries
Base.cconvert(::Type{Ptr{arb_struct}}, v::ArbVector) = v.arb_vec

# AbstractVector interface for ArbVector
Base.size(v::arb_vec_struct) = (v.n,)
Base.size(v::ArbVector) = size(v.arb_vec)

Base.getindex(v::arb_vec_struct, i::Integer) = v.entries + (i - 1) * sizeof(arb_struct)
Base.@propagate_inbounds function Base.getindex(v::ArbVector, i::Integer)
    @boundscheck checkbounds(v, i)
    return ArbRef(v.arb_vec[i], precision(v), cstruct(v))
end

Base.setindex!(v::arb_vec_struct, x, i::Integer) = (set!(v[i], x); x)
Base.@propagate_inbounds function Base.setindex!(v::ArbVector, x, i::Integer)
    @boundscheck checkbounds(v, i)
    v.arb_vec[i] = x
    return x
end


## AcbVector basic definitions
function clear!(v::acb_vec_struct)
    ccall(@libarb(_acb_vec_clear), Cvoid, (Ptr{acb_struct}, Clong), v.entries, v.n)
end
Base.cconvert(::Type{Ptr{acb_struct}}, v::AcbVector) = v.acb_vec
Base.unsafe_convert(::Type{Ptr{acb_struct}}, v::acb_vec_struct) = v.entries

# AbstractVector interface for ACbVector
Base.size(v::acb_vec_struct) = (v.n,)
Base.size(v::AcbVector) = size(v.acb_vec)

Base.getindex(v::acb_vec_struct, i::Integer) = v.entries + (i - 1) * sizeof(acb_struct)
Base.@propagate_inbounds function Base.getindex(v::AcbVector, i::Integer)
    @boundscheck checkbounds(v, i)
    return AcbRef(v.acb_vec[i], precision(v), cstruct(v))
end

Base.setindex!(v::acb_vec_struct, x, i::Integer) = (set!(v[i], x); x)
Base.@propagate_inbounds function Base.setindex!(v::AcbVector, x, i::Integer)
    @boundscheck checkbounds(v, i)
    v.acb_vec[i] = x
    return x
end

## Common methods

# General constructor
for T in [:ArbVector, :AcbVector]
    @eval function $T(v::AbstractVector, prec::Integer = _precision(first(v)))
        V = $T(length(v); prec = prec)
        @inbounds for (i, vᵢ) in enumerate(v)
            V[i] = vᵢ
        end
        return V
    end
end

# Arithmetic
for (jf, af) in [(:+, :add!), (:-, :sub!)]
    @eval function Base.$jf(v::T, w::T) where {T<:Union{ArbVector,AcbVector}}
        @boundscheck (length(v) == length(w) || throw(DimensionMismatch()))
        C = T(size(A, 1), size(B, 2); prec = max(precision(A), precision(B)))
        $af(C, A, B)
        C
    end
end
function Base.:(-)(v::T) where {T<:Union{ArbVector,AcbVector}}
    w = T(length(v); prec = precision(v))
    neg!(w, v)
    w
end

Base.copy(v::T) where {T<:Union{ArbVector,AcbVector}} =
    copy!(T(length(v); prec = precision(v)), v)
Base.copy!(w::T, v::T) where {T<:Union{ArbVector,AcbVector}} = set!(w, v)
Base.copyto!(w::T, v::T) where {T<:Union{ArbVector,AcbVector}} = set!(w, v)
