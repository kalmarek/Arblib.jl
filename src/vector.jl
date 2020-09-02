## ArbVector basic definitions
function clear!(v::arb_vec_struct)
    ccall(@libarb(_arb_vec_clear), Cvoid, (Ptr{arb_struct}, Clong), v.entries, v.n)
end
Base.cconvert(::Type{Ptr{arb_struct}}, v::Union{ArbVector,ArbRefVector}) = v.arb_vec
Base.unsafe_convert(::Type{Ptr{arb_struct}}, v::arb_vec_struct) = v.entries

# AbstractVector interface for ArbVector
Base.size(v::arb_vec_struct) = (v.n,)
Base.size(v::Union{ArbVector,ArbRefVector}) = size(v.arb_vec)

Base.getindex(v::arb_vec_struct, i::Integer) = v.entries + (i - 1) * sizeof(arb_struct)
Base.@propagate_inbounds function Base.getindex(v::ArbVector, i::Integer)
    @boundscheck checkbounds(v, i)
    x = Arb(prec = precision(v))
    x[] = v.arb_vec[i]
    x
end
Base.@propagate_inbounds function Base.getindex(v::ArbRefVector, i::Integer)
    @boundscheck checkbounds(v, i)
    return ArbRef(v.arb_vec[i], precision(v), cstruct(v))
end

"""
    ref(v::ArbVector, i)

Similar to `v[i]` but instead of an `Arb` returns an `ArbRef` which still shares the
memory with the `i`-th entry of `v`.
"""
Base.@propagate_inbounds function ref(v::Union{ArbVector,ArbRefVector}, i::Integer)
    @boundscheck checkbounds(v, i)
    return ArbRef(v.arb_vec[i], precision(v), cstruct(v))
end

Base.setindex!(v::arb_vec_struct, x, i::Integer) = (set!(v[i], x); x)
Base.@propagate_inbounds function Base.setindex!(
    v::Union{ArbVector,ArbRefVector},
    x,
    i::Integer,
)
    @boundscheck checkbounds(v, i)
    v.arb_vec[i] = x
    return x
end


## AcbVector basic definitions
function clear!(v::acb_vec_struct)
    ccall(@libarb(_acb_vec_clear), Cvoid, (Ptr{acb_struct}, Clong), v.entries, v.n)
end
Base.cconvert(::Type{Ptr{acb_struct}}, v::Union{AcbVector,AcbRefVector}) = v.acb_vec
Base.unsafe_convert(::Type{Ptr{acb_struct}}, v::acb_vec_struct) = v.entries

# AbstractVector interface for ACbVector
Base.size(v::acb_vec_struct) = (v.n,)
Base.size(v::Union{AcbVector,AcbRefVector}) = size(v.acb_vec)

Base.getindex(v::acb_vec_struct, i::Integer) = v.entries + (i - 1) * sizeof(acb_struct)
Base.@propagate_inbounds function Base.getindex(v::AcbVector, i::Integer)
    @boundscheck checkbounds(v, i)
    x = Acb(prec = precision(v))
    x[] = v.acb_vec[i]
    x
end
Base.@propagate_inbounds function Base.getindex(v::AcbRefVector, i::Integer)
    @boundscheck checkbounds(v, i)
    return AcbRef(v.acb_vec[i], precision(v), cstruct(v))
end

"""
    ref(v::AcbVector, i)

Similar to `v[i]` but instead of an `Acb` returns an `AcbRef` which still shares the
memory with the `i`-th entry of `v`.
"""
Base.@propagate_inbounds function ref(v::Union{AcbVector,AcbRefVector}, i::Integer)
    @boundscheck checkbounds(v, i)
    return AcbRef(v.acb_vec[i], precision(v), cstruct(v))
end

Base.setindex!(v::acb_vec_struct, x, i::Integer) = (set!(v[i], x); x)
Base.@propagate_inbounds function Base.setindex!(
    v::Union{AcbVector,AcbRefVector},
    x,
    i::Integer,
)
    @boundscheck checkbounds(v, i)
    v.acb_vec[i] = x
    return x
end

## Common methods
const Vectors = Union{ArbVector,ArbRefVector,AcbVector,AcbRefVector}

# General constructor
for T in [:ArbVector, :ArbRefVector, :AcbVector, :AcbRefVector]
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
    @eval function Base.$jf(v::T, w::T) where {T<:Vectors}
        @boundscheck (length(v) == length(w) || throw(DimensionMismatch()))
        C = T(size(A, 1), size(B, 2); prec = max(precision(A), precision(B)))
        $af(C, A, B)
        C
    end
end
function Base.:(-)(v::T) where {T<:Vectors}
    w = T(length(v); prec = precision(v))
    neg!(w, v)
    w
end

Base.copy(v::T) where {T<:Vectors} = copy!(T(length(v); prec = precision(v)), v)
Base.copy!(w::T, v::T) where {T<:Vectors} = set!(w, v)
Base.copyto!(w::T, v::T) where {T<:Vectors} = set!(w, v)
